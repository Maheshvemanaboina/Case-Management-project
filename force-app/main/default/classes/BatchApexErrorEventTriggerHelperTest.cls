/*------------------------------------------------------------  
Author:        Author
Company:       Waeg
Description:   Unit tests for the trigger BatchApexErrorEventTrigger, its handler, and its helper

History
2018-07-31     Gianluca Calcagni    Created class
------------------------------------------------------------*/
@isTest
private class BatchApexErrorEventTriggerHelperTest {



    // CONSTANTS //

    private static final Integer SIZE   = 20;
    private static final Id      JOB_ID = '707000000000000';



    // TEST SETUP //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Sets up sample data to be used for testing

    History:
    2019-07-31    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @testSetup
    private static void testSetup() {
        // Create sample error logs //
        List<DebugLog__c> sampleErrors = new List<DebugLog__c>();
        for ( Integer index = 0; index < SIZE; ++index ) {
            sampleErrors.add(new DebugLog__c(
                RecordId__c = String.valueOf( JOB_ID )
            ));
        }
        insert sampleErrors;
    }



    // TEST UNITS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the batch class BatchApexErrorEventTest

    History:
    2019-07-31    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void batchApexErrorEventTest() {
        // Assert that the sample data is correct //
        System.assertEquals( SIZE, [SELECT COUNT() FROM DebugLog__c LIMIT :(SIZE+1)], 'Wrong number of sample errors' );
        
        // Start the test, schedule the batch, then stop the test //
        Test.startTest();
        Id jobId = Database.executeBatch( new BatchApexErrorEventTest(), SIZE );
        Test.stopTest();
        
        // Query the job //
        BatchApexErrorEventTriggerHelper.JobWrapper wrapper = BatchApexErrorEventTriggerHelper.getAsyncApexJobs( new Set<Id>{jobId} ).values()[ 0 ];
        

        // Assert that the result data is correct //
        System.assertEquals( SIZE+1, [SELECT COUNT() FROM DebugLog__c LIMIT :(SIZE+2)], 'Wrong number of sample errors' );
        System.assertEquals( 1, [SELECT COUNT() FROM DebugLog__c WHERE RecordId__c = :jobId LIMIT 2], 'Wrong number of generated errors' );
        System.assertNotEquals( null, BatchApexErrorEventTriggerHelper.getHtmlBody( wrapper, 1 ), 'Html body not built' );
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the method BatchApexErrorEventHelperTest.getErrorCountById

    History:
    2019-07-31    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void getErrorCountByIdTest() {
        // Assert that the sample data is correct //
        System.assertEquals( SIZE, [SELECT COUNT() FROM DebugLog__c LIMIT :(SIZE+1)], 'Wrong number of sample errors' );
        
        // Start the test, call the method, then stop the test //
        Test.startTest();
        Map<Id, Integer> errorCountById = BatchApexErrorEventTriggerHelper.getErrorCountById( new Set<Id>{JOB_ID} );
        Test.stopTest();

        // Assert that the result data is correct //
        System.assertEquals( 1,    errorCountById.size(),        'Map count incorrect' );
        System.assertEquals( SIZE, errorCountById.get( JOB_ID ), 'Count incorrect' );
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the method BatchApexErrorEventHelperTest.includeError

    History:
    2019-07-31    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void includeErrorTest() {
        // Assert that the sample data is correct //
        System.assertEquals( SIZE, [SELECT COUNT() FROM DebugLog__c LIMIT :(SIZE+1)], 'Wrong number of sample errors' );
        
        // Start the test, schedule the batch, then stop the test //
        Test.startTest();
        Id jobId = Database.executeBatch( new BatchApexErrorEventTest(), SIZE );
        Test.stopTest();
        
        // Query the job //
        BatchApexErrorEventTriggerHelper.JobWrapper wrapper = BatchApexErrorEventTriggerHelper.getAsyncApexJobs( new Set<Id>{jobId} ).values()[ 0 ];

        // Initialise some method inputs //
        BatchApexErrorEvent event = new BatchApexErrorEvent(
            AsyncApexJobId = jobId
        );
        Map<Id, List<DebugLog__c>> errorsById = new Map<Id, List<DebugLog__c>>{
            JOB_ID => [SELECT Id FROM DebugLog__c WHERE RecordId__c = :JOB_ID],
            jobId  => [SELECT Id FROM DebugLog__c WHERE RecordId__c = :jobId]
        };

        // Call the method //
        BatchApexErrorEventTriggerHelper.includeError(
            wrapper,
            event,
            0,
            errorsById
        );

        // Assert that the result data is correct //
        System.assertEquals( 2,    errorsById.size(),               'Map count incorrect' );
        System.assertEquals( SIZE, errorsById.get( JOB_ID ).size(), 'List count incorrect for ' + JOB_ID );
        System.assertEquals( 2,    errorsById.get( jobId  ).size(), 'List count incorrect for ' + jobId );
    }



}