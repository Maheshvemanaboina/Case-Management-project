/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Handler class for BatchApexErrorEventTrigger. In order to work, batch classes need to extend Database.RaisesPlatformEvents

History
2019-07-31    Gianluca Calcagni    Created handler class
------------------------------------------------------------*/
public without sharing class BatchApexErrorEventTriggerHandler /*extends Database.RaisesPlatformEvents*/ {



    // CONSTANTS //

    public static final BatchSetting__mdt BATCH_SETTING = BatchApexErrorEventTriggerHelper.DEFAULT_BATCH_SETTING;



    // VARIABLES //

    public List<BatchApexErrorEvent> events;



    // CTORS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Initialises all the internal variables with trigger context variables
    Inputs:       none
    Returns:      this
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-04-10    Gianluca Calcagni    Created main constructor
    ------------------------------------------------------------*/
    public BatchApexErrorEventTriggerHandler( List<BatchApexErrorEvent> events ) {
        // Initialises the internal variables //
        this.events = events;
    }



    // METHODS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Stores the errors as logs for future reference
    Inputs:       none
    Returns:      void
    Test Class:   BatchApexErrorEventTriggerHelperTest

    History:
    2019-04-10    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public void run() {
        // Check if the settings are valid before proceeding //
        // REMARK: if the settings are missing or invalid, then do not proceed //
        if ( !BATCH_SETTING.BypassBatchApexErrorEventTrigger__c ) {
            // Collect the job IDs and use them to map the async apex jobs //
            Set<Id> jobIds = new Set<Id>();
            for ( BatchApexErrorEvent event : events ) {
                jobIds.add( event.AsyncApexJobId );
            }
            Map<Id, BatchApexErrorEventTriggerHelper.JobWrapper> jobsById = BatchApexErrorEventTriggerHelper.getAsyncApexJobs( jobIds );

            // Collect the parent job IDs //
            Set<Id> parentJobIds = new Set<Id>();
            for ( BatchApexErrorEventTriggerHelper.JobWrapper wrapper : jobsById.values() ) {
                parentJobIds.add( wrapper.parentJobId );
            }

            // Aggregate the errors currently stored and put their count in a map //
            Map<Id, Integer> errorCountById = BatchApexErrorEventTriggerHelper.getErrorCountById( parentJobIds );

            // Initialise the error records //
            Map<Id, List<DebugLog__c>> errorsById = new Map<Id, List<DebugLog__c>>();

            // Loop over the events //
            for ( BatchApexErrorEvent event : events ) {
                // Retrieve the wrapped async apex job //
                BatchApexErrorEventTriggerHelper.JobWrapper wrapper = jobsById.get( event.AsyncApexJobId );

                // Include an error in the map //
                BatchApexErrorEventTriggerHelper.includeError(
                    wrapper,
                    event,
                    errorCountById.get( wrapper.parentJobId ),
                    errorsById
                );
            }

            // Collect the errors and insert them //
            List<DebugLog__c> allErrors = new List<DebugLog__c>();
            for ( List<DebugLog__c> errors : errorsById.values() ) {
                allErrors.addAll( errors );
            }
            if ( !allErrors.isEmpty() ) {
                Database.insert( /*records*/allErrors, /*allOrNone*/false );
            }
        }
    }



}