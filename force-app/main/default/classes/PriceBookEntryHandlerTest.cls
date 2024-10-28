/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Tests the class PriceBookEntryHandler

History
2019-11-11    Gianluca Calcagni    Created test class
------------------------------------------------------------*/
@isTest
private class PriceBookEntryHandlerTest {



    // TEST SETUP //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Sets up sample data to be used for testing

    History:
    2019-11-11    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @testSetup
    private static void testSetup() {
        Global_Automation_Setting__c setting = Global_Automation_Setting__c.getInstance();
        setting.Skip_Apex_Trigger__c    = true;
        setting.Skip_Process_Builder__c = true;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;

        // Create some price lists and some custom settings //
        PriceBook2 pricebook = new PriceBook2(
            Name = 'Prototype',
            IsActive = true
        );
        insert pricebook;
        insert new BGI_Salesforce_Settings__c(
            No_Of_Opportunities_Per_Batch__c = 10,
            Default_Task_Owner__c            = UserInfo.getUserId().subString(0, 15),
            Financial_Year__c                = Date.newInstance( Date.today().year(), 12, 31 ),
            Batch_Status_Email_Recipients__c = 'xyz@test.com,abc@test.com',
            Batch_Job_Failue_Message__c      = 'test123',
            Batch_Job_Success_Message__c     = 'Failure',
            Email_Subject__c                 = 'subject',
            Sender_Display_Name__c           = 'displayname',
            Prototype_Price_Book_Id__c       = pricebook.Id
        );

        // Create a custom setting to enable automation log processing and triggers //
        setting.Skip_Apex_Trigger__c    = false;
        setting.Skip_Process_Builder__c = false;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;
    }



    // TEST UNITS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the method createPriceBookEntries with a positive result

    History:
    2019-11-11    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void createPriceBookEntriesTest_Positive() {
        // Re-activate the standard price book //
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        // Initialise a new product //
        Product2 sampleProduct = DataFactoryTest.getProductSKUs( 1 )[ 0 ];
        sampleProduct.Product_Code__c = '000000000000094500';
        sampleProduct.RecordTypeId = PriceBookEntryHandler.PRODUCT_PROTOTYPE_RECORD_TYPE_ID;

        // Assert that there are no debug logs //
        System.assertEquals( 0, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'Pre-existing debug logs found' );

        System.assertNotEquals( new PriceBook2[]{}, [SELECT Id, Name FROM PriceBook2 WHERE IsActive = TRUE AND IsStandard = TRUE LIMIT 1], 'Standard price book not found' );

        // Start the test, create the product, and then stop the test //
        Test.startTest();
        Database.insert( sampleProduct );
        Test.stopTest();

        // Requery the data and assert it is correct //
        System.assertEquals( new DebugLog__c[]{}, [SELECT Record__c, Message__c, Cause__c, TypeName__c, Fields__c, StackTraceString__c FROM DebugLog__c LIMIT 1], 'Debug log found!' );
        Integer newCount = [SELECT COUNT() FROM PriceBookEntry WHERE IsActive = TRUE AND PriceBook2.IsStandard = TRUE AND Product2Id = :sampleProduct.Id LIMIT 2000];
        System.assertNotEquals( 0, newCount, 'Price book entries not created' );
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the method createPriceBookEntries with a negative result

    History:
    2019-11-11    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void createPriceBookEntriesTest_Negative() {
        // Re-activate the standard price book //
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        // Initialise a new product //
        Product2 sampleProduct = DataFactoryTest.getProductSKUs( 1 )[ 0 ];
        sampleProduct.Product_Code__c = '000000000000094500';
        sampleProduct.RecordTypeId = PriceBookEntryHandler.PRODUCT_PROTOTYPE_RECORD_TYPE_ID;

        // Assert that there are no debug logs //
        System.assertEquals( 0, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'Pre-existing debug logs found' );

        // Start the test, create the product, and then stop the test //
        Test.startTest();
        PriceBookEntryHandler.throwException = true;
        Database.insert( sampleProduct );
        Test.stopTest();

        // Requery the data and assert it is correct //
        System.assertEquals( 1, [SELECT COUNT() FROM DebugLog__c LIMIT 1], 'New debug logs not found' );
    }



}