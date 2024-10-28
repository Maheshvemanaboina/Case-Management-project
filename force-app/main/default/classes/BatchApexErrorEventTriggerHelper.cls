/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  The helper class of the trigger BatchApexErrorEventTrigger. Any batch class using this helper needs to extend Database.RaisesPlatformEvents. This class is without sharing to query AsyncApexJob and DebugLog__c

History
2019-07-31    Gianluca Calcagni    Created helper class
------------------------------------------------------------*/
public without sharing class BatchApexErrorEventTriggerHelper /*extends Database.RaisesPlatformEvents*/ {



    // CONSTANTS //

    public static final String            SUBJECT_FORMAT        = '{0} ({1})';
    public static final BatchSetting__mdt DEFAULT_BATCH_SETTING = [
        SELECT
            Id, BatchSize__c, BypassBatchApexErrorEventTrigger__c, Statuses__c, EmailTo__c, EmailCc__c, EmailBcc__c, EmailReplyTo__c,
            DoNotSendEmail__c,SendEmailOnErrorOnly__c, SendEmailAllOrNone__c, MaxErrorCount__c, MaxErrorCountEmail__c
        FROM
            BatchSetting__mdt
        WHERE
            MasterLabel = 'DefaultBatchSetting'
    ];



    // PROPERTIES //

    public BatchSetting__mdt setting;
    public JobWrapper        wrapper;
    public Integer           maxErrorCount;
    public String            orgName;



    // CTORS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Calls the main constructor
    Inputs:       the ID of an AsyncApexJob
    Returns:      this
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-07-31    Gianluca Calcagni    Created secondary constructor
    ------------------------------------------------------------*/
    public BatchApexErrorEventTriggerHelper( Id jobId ) {
        // Call the other constructor //
        this( jobId, null );
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Initialises all the internal variables with trigger context variables
    Inputs:       the ID of an AsyncApexJob
                  some batch settings to use
    Returns:      this
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-04-11    Gianluca Calcagni    Created main constructor
    ------------------------------------------------------------*/
    public BatchApexErrorEventTriggerHelper( Id jobId, BatchSetting__mdt setting ) {
        // Initialise the properties //
        this.setting       = setting != null ? setting : DEFAULT_BATCH_SETTING;
        this.wrapper       = getAsyncApexJobs( new Set<Id>{jobId} ).values()[ 0 ];
        this.maxErrorCount = this.setting.MaxErrorCountEmail__c != null ? (Integer) this.setting.MaxErrorCountEmail__c : 0;
        this.orgName       = System.Url.getSalesforceBaseUrl().toExternalForm().removeStart( 'https://' ).split( '\\.' )[ 0 ];
        //String batchName = String.valueOf( this ).split( ':' )[ 0 ];
    }



    // METHODS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Sends an email containing the details of the calling batch job
    Inputs:       none
    Returns:      void
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-07-31    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public void sendEmail() {
        // Check if an email shall be sent //
        if ( !setting.DoNotSendEmail__c ) {
            // Build the email body //
            String htmlBody = getHtmlBody( wrapper, maxErrorCount );

            // Build the text body //
            String textBody = htmlBody.replaceAll( '<br />', '\r\n' );

            // Initialise an empty email //
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // Assign the addresses, if present //
            if ( !String.isEmpty(setting.EmailTo__c)  )     mail.setToAddresses(  setting.EmailTo__c.split(';')  );
            if ( !String.isEmpty(setting.EmailCc__c)  )     mail.setCcAddresses(  setting.EmailCc__c.split(';')  );
            if ( !String.isEmpty(setting.EmailBcc__c) )     mail.setBccAddresses( setting.EmailBcc__c.split(';') );
            if ( !String.isEmpty(setting.EmailReplyTo__c) ) mail.setReplyTo(      setting.EmailReplyTo__c        );

            // Set other email properties //
            mail.setSubject(
                String.format(
                    SUBJECT_FORMAT,
                    new String[]{ wrapper.className, wrapper.jobId }
                )
            );
            mail.setSenderDisplayName(
                String.format(
                    SUBJECT_FORMAT,
                    new String[]{ UserInfo.getUserName(), orgName }
                )
            );
            mail.setUseSignature( false );
            mail.setPlainTextBody( textBody );
            mail.setHtmlBody( htmlBody );

            // Check if the email shall be sent in case of errors //
            if (
                !setting.SendEmailOnErrorOnly__c ||
                setting.SendEmailOnErrorOnly__c == ( wrapper.job.NumberOfErrors > 0 ) ||
                Test.isRunningTest()
            ) {
                // Send the email //
                Messaging.sendEmail(
                    /*emails*/    new Messaging.Email[]{ mail },
                    /*allOrNone*/ setting.SendEmailAllOrNone__c
                );
            }
        }
    }



    // FUNCTIONS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Builds an html body as a string text
    Inputs:       a wrapper containing the details from an AsyncApexJob
                  an integer containing the max number of errors that shall be counted
    Returns:      a string containing the html body of an email
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-07-31    Gianluca Calcagni    Created function
    ------------------------------------------------------------*/
    public static String getHtmlBody( JobWrapper wrapper, Integer maxErrorCount ) {
        // Retrieve the job //
        AsyncApexJob job = wrapper.job;

        // Initialise the result //
        String htmlBody = 'Start Date: ' + job.CreatedDate.formatLong() + '<br />';
        htmlBody += 'End Date: ' + job.CompletedDate.formatLong() + '<br />';
        htmlBody += job.NumberOfErrors == 0 ? 'No errors found.' : 'Failed jobs: ' + job.NumberOfErrors + ' out of ' + job.TotalJobItems;
        //htmlBody += '<br /><br />Some of the errors found:<br />';

        // Query some errors of this batch //
        // This operation may return no rows since the debug logs are created asynchronously //
        /*for ( DebugLog__c error : [
            SELECT
                Id, Error_Type__c, Message__c, StackTraceString__c
            FROM
                DebugLog__c
            WHERE
                RecordId__c = :job.Id
            ORDER BY
                CreatedDate
            LIMIT
                :maxErrorCount
        ] ) {
            // Include each error in the result //
            htmlBody += error.Error_Type__c + ': ' + error.Message__c + ' Stack trace: ' + error.StackTraceString__c + '<br />';
        }*/

        // Return the result //
        return htmlBody;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Aggregates some debug logs and counts their number
    Inputs:       a set of IDs of the parent AsyncApexJob
    Returns:      a map from the IDs to the number of debug logs currently stored
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-07-31    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static Map<Id, Integer> getErrorCountById( final Set<Id> jobIds ) {
        // Initialise the result //
        Map<Id, Integer> errorCountById = new Map<Id, Integer>();

        // Query the errors and aggregate them by job ID //
        for ( AggregateResult aggregatedResult : [SELECT COUNT(Id) cont, RecordId__c jobId FROM DebugLog__c WHERE RecordId__c IN :jobIds GROUP BY RecordId__c] ) {
            // Include the count in the result //
            errorCountById.put(
                (Id) aggregatedResult.get( 'jobId' ),
                (Integer) aggregatedResult.get( 'cont' )
            );
        }

        // Return the result //
        return errorCountById;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Includes a new error (=debug log) in a map given in input
    Inputs:       a wrapper containing an AsyncApexJob
                  a platform event of type BatchApexErrorEvent
                  an integer equal to the current number of debug logs stored for the job
                  a map in which to include a new error, in the form of a debug log
    Returns:      void
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-07-31    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static void includeError( final JobWrapper wrapper, final BatchApexErrorEvent event, final Integer errorCount, final Map<Id, List<DebugLog__c>> errorsById ) {
        // Check if a max count must be respected //
        Integer maxCount = (Integer) DEFAULT_BATCH_SETTING.MaxErrorCount__c;
        Integer count    = errorCount != null ? errorCount : 0;
        Boolean hasMax   = maxCount != null;

        // Check if a job was found and the number of errors did not hit the max yet //
        if ( wrapper != null && (!hasMax || count < maxCount) ) {
            // Create a new error //
            DebugLog__c error = new DebugLog__c(
                RecordId__c         = wrapper.parentJobId,
                //Cause__c            = wrapper.className,
                //DoesExceedJobScopeMaxLength__c = event.DoesExceedJobScopeMaxLength,
                Cause__c            = event.ExceptionType != null ? ( event.ExceptionType + ' for batch ' + wrapper.className ).left( 255 ) : wrapper.className,
                Comments__c         = event.JobScope != null ? event.JobScope.left( 32768 ) : null,
                Message__c          = event.Message != null ? event.Message.left( 32768 ) : null,
                //RequestId__c        = event.RequestId != null ? event.RequestId.left( 255 ) : null,
                StackTraceString__c = event.StackTrace != null ? event.StackTrace.left( 32768 ) : null
            );

            // Retrieve the related errors //
            List<DebugLog__c> errors = errorsById.get( wrapper.jobId );

            // Check if the errors have been found or not //
            if ( errors == null ) {
                // If not found, initialise the list and put it in the map //
                errorsById.put(
                    wrapper.jobId,
                    new List<DebugLog__c>{ error }
                );
            } else if ( !hasMax || errors.size() < maxCount ) {
                // If found, just include an error in the list //
                errors.add( error );
            }
        }
    }

    public static Map<Id, JobWrapper> getAsyncApexJobs( final Set<Id> jobIds ) {
        // Initialise the result //
        Map<Id, JobWrapper> result = new Map<Id, JobWrapper>();

        // Loop over the jobs //
        for ( AsyncApexJob job : [
            SELECT
                Id, CreatedDate, ParentJobId, ApexClassID, ApexClass.Name, CompletedDate, ExtendedStatus,
                JobItemsProcessed, JobType, MethodName, NumberOfErrors, Status, TotalJobItems
            FROM
                AsyncApexJob
            WHERE
                Id IN :jobIds
        ] ) {
            result.put(
                job.Id,
                new JobWrapper( job )
            );
        }

        // Return the result //
        return result;
    }



    // INNER CLASSES //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Wraps an AsyncApexJob. This is needed since the JobType and the ParentJobId properties are lost when used outside this class

    History:
    2019-07-31    Gianluca Calcagni    Created inner class
    ------------------------------------------------------------*/
    public class JobWrapper {
        // VARIABLES //
        public AsyncApexJob job         {get; set;}
        public String       className   {get; set;}
        public String       jobType     {get; set;}
        public Id           parentJobId {get; set;}
        public Id           jobId       {get; set;}
        // CTORS //
        public JobWrapper( AsyncApexJob job ) {
            this.job         = job;
            this.className   = job.ApexClass.Name;
            this.jobType     = job.JobType;
            this.parentJobId = job.JobType == 'BatchApexWorker' ? job.ParentJobId : job.Id;
            this.jobId       = job.Id;
        }
    }



}