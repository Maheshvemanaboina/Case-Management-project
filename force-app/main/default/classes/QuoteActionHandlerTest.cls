/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Tests the class QuoteActionHandler

History
2019-10-29    Gianluca Calcagni    Created test class
2021-02-12    Sibananda Bhuyan     Updated Class to change AccountId as per new Account Design for Contact & Opportunity
------------------------------------------------------------*/
@isTest
private class QuoteActionHandlerTest {



    // CONSTANTS //

    private static final String SAMPLE_ACCOUNT_NAME = 'THIS is JUST a SAMPLE name';


    // TEST SETUP //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Sets up sample data to be used for testing

    History:
    2019-10-29    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @testSetup
    private static void testSetup() {
        TriggerHandler.skipTrigger = True;
        Global_Automation_Setting__c setting = Global_Automation_Setting__c.getInstance();
        setting.Skip_Apex_Trigger__c    = true;
        setting.Skip_Process_Builder__c = true;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;

        // Create a sample user //
        User sampleUser = DataFactoryTest.getCPQstdUser();
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
            insert sampleUser;
            PermissionSetAssignment[] assignments = new PermissionSetAssignment[]{};
            for ( PermissionSet permissionSet : DataFactoryTest.getCPQpermissions() ) {
                assignments.add(new PermissionSetAssignment(
                        PermissionSetId = permissionSet.Id,
                        AssigneeId      = sampleUser.Id
                ));
            }
            insert assignments;
        }

        // Create a sample product //
        Product2 sampleProduct = DataFactoryTest.getProductSKUs( 1 )[ 0 ];
        sampleProduct.Product_Code__c = '000000000000094500';
        sampleProduct.RecordTypeId = DataFactoryTest.getRecordTypeByDeveloperName( Schema.SObjectType.Product2 ).get( DataFactoryTest.PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId();
        Database.insert( sampleProduct );

        // Create a sample account //
        Account sampleAccount = DataFactoryTest.getAccountCommercialCustomers( 1 )[ 0 ];
        //sampleAccount.Name          = SAMPLE_ACCOUNT_NAME; associated this name with Customer location as per new account design (to avoid duplicate)
        sampleAccount.OwnerId       = sampleUser.Id;
        sampleAccount.SAP_Number__c = '0000100655';
        sampleAccount.active__c=true;
        Database.insert( sampleAccount );

        //Sibananda - Added below to retreive customer location to associate it with Contact and Opportunity as per the new Account design

        Account testCustomerLocation  = DataFactoryTest.getAccountCustomerLocations(1)[0];
        testCustomerLocation.ParentId = sampleAccount.Id;
        testCustomerLocation.Name     = SAMPLE_ACCOUNT_NAME;
        testCustomerLocation.active__c=true;
        testCustomerLocation.Partner_Role__c='Sold-to';
        Database.insert( testCustomerLocation );

        // Create a sample contact //
        Contact sampleContact = DataFactoryTest.getContacts( 1 )[ 0 ];
        sampleContact.OwnerId   = sampleUser.Id;
        //sampleContact.AccountId = sampleAccount.Id;
        sampleContact.AccountId = testCustomerLocation.Id;
        sampleContact.active__c=true;
        sampleContact.Email='test@gmail.com';
        Database.insert( sampleContact );

        // Create a sample opportunity //
        Opportunity sampleOpportunity = DataFactoryTest.getOpportunityNewBusinesses( 1 )[ 0 ];
        sampleOpportunity.OwnerId   = sampleUser.Id;
        //sampleOpportunity.AccountId = sampleAccount.Id;
        sampleOpportunity.AccountId = testCustomerLocation.Id;
        sampleOpportunity.ContactId = sampleContact.Id;
        sampleOpportunity.StageName = 'Prospecting';
        sampleOpportunity.Reason_Won_Lost__c = '';
        Database.insert( sampleOpportunity );

        // Create a sample quote with a group and line items //
        SBQQ__Quote__c quote = DataFactoryTest.createQuote( sampleOpportunity, new Product2[]{sampleProduct} );
        //insert Partner Role Ship To in DB (sample) and Agent Role
        DataFactoryTest.insertPartnerRole(sampleAccount.Id, sampleAccount.Id, CPQUtility.SHIP_TO);
        DataFactoryTest.insertPartnerRole(sampleAccount.Id, sampleAccount.Id, CPQUtility.AGENT);

        // Create a price list //
        insert new PriceBook2( Name = SAMPLE_ACCOUNT_NAME, IsActive = true );

        // Create a custom setting to enable automation log processing and triggers //
        insert new Global_Automation_Setting__c( Skip_Apex_Trigger__c = false );
        TriggerHandler.skipTrigger = False;
    }



    // TEST UNITS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the method updatePriceBookOnQuote with a positive result

    History:
    2019-10-29    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void updatePriceBookOnQuoteTest() {
        // Run as a CPQ user //
        TriggerHandler.skipTrigger = True;
        User sampleUser = [SELECT Id FROM User WHERE UserName = :DataFactoryTest.CPQ_STD_USERNAME];
        System.runAs( sampleUser ) {
            // Retrieve and assert some sample data //
            List<SBQQ__Quote__c> quotes    = [SELECT Id, SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE SBQQ__PriceBook__c = NULL AND SBQQ__Account__r.Name = :SAMPLE_ACCOUNT_NAME LIMIT 200];
            PriceBook2           priceBook = [SELECT Id FROM PriceBook2 WHERE Name = :SAMPLE_ACCOUNT_NAME AND IsActive = TRUE ORDER BY CreatedDate DESC LIMIT 1];
            System.assert( !quotes.isEmpty(), 'No quote was found' );

            // Create a list of quote IDs to input //
            List<String> quoteIds = new List<String>();
            for ( SBQQ__Quote__c quote : quotes ) {
                quoteIds.add( quote.Id );
            }

            // Start the test, run the invocable action, and then stop the test //
            Test.startTest();
            QuoteActionHandler.updatePriceBookOnQuote( quoteIds );
            Test.stopTest();

            // Requery the data and assert it is correct //
            quotes = [SELECT Id, SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds];
            System.assert( !quotes.isEmpty(), 'No quote was found' );
            for ( SBQQ__Quote__c quote : quotes ) {
                System.assertEquals( priceBook.Id, quote.SBQQ__PriceBook__c, 'Price book not valid for ' + quote );
            }
            TriggerHandler.skipTrigger = false;
        }
    }



}