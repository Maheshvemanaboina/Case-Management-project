/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Batch class used to test the BatchApexErrorEvent triggers
              DO NOT SCHEDULE THIS BATCH: IT IS USED FOR TESTING PURPOSES ONLY

History
2019-07-31    Gianluca Calcagni    Created batch class
------------------------------------------------------------*/
public without sharing class BatchApexErrorEventTest implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {
    // Query all the error logs //
    public Database.QueryLocator start( Database.BatchableContext context ) {
        return Database.getQueryLocator( [SELECT Id FROM DebugLog__c] );
    }
    // Throw some errors //
    public void execute( Database.BatchableContext context, List<SObject> scope ) {
        // Throw an exception in a try catch //
        try {
            throw new NullPointerException();
        } catch( Exception e ) {
            // Emulate BatchApexErrorEvent firing //
            EventBus.publish(new BatchApexErrorEvent(
                AsyncApexJobId              = context.getJobId(),
                DoesExceedJobScopeMaxLength = false,
                ExceptionType               = NullPointerException.class.getName(),
                JobScope                    = String.join( (Iterable<Id>)new Map<Id, SObject>(scope).keySet(), ',' ),
                Message                     = e.getMessage(),
                RequestId                   = null, // Not currently acccessibe via Apex
                StackTrace                  = e.getStackTraceString()
            ));
        }
    }
    // Call the batch helper and send an email //
    public void finish( Database.BatchableContext context ) {
        new BatchApexErrorEventTriggerHelper( context.getJobId() ).sendEmail();
    }
}