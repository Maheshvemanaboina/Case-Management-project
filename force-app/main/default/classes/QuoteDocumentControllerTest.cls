/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Tests the class QuoteDocumentController

History
2019-11-07    Gianluca Calcagni    Created test class
2021-02-12    Sibananda Bhuyan     Updated Class to change AccountId as per new Account Design for Contact & Opportunity
------------------------------------------------------------*/
@isTest
private class QuoteDocumentControllerTest {



    // TEST SETUP //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Sets up sample data to be used for testing

    History:
    2019-11-07    Gianluca Calcagni    Created method
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
        sampleProduct.RecordTypeId = DataFactoryTest.getRecordTypeByDeveloperName( Schema.SObjectType.Product2 ).get( DataFactoryTest.PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId();
        Database.insert( sampleProduct );

        // Create a sample account //
        Account sampleAccount = DataFactoryTest.getAccountCommercialCustomers( 1 )[ 0 ];
        sampleAccount.OwnerId = sampleUser.Id;
        sampleAccount.active__c= true;
        Database.insert( sampleAccount );

        //Sibananda - Added below to retreive customer location to associate it with Contact and Opportunity as per the new Account design

        Account testCustomerLocation = DataFactoryTest.getAccountCustomerLocations(1)[0];
        testCustomerLocation.ParentId = sampleAccount.Id;
        testCustomerLocation.active__c=true;
        testCustomerLocation.Partner_Role__c='Sold-to';
        Database.insert( testCustomerLocation );

        // Create a sample contact //
        Contact sampleContact = DataFactoryTest.getContacts( 1 )[ 0 ];
        sampleContact.OwnerId   = sampleUser.Id;
        //sampleContact.AccountId = sampleAccount.Id;
        sampleContact.AccountId = testCustomerLocation.Id;
        sampleContact.active__c=true;
        sampleContact.Email='test@frieslandcampina.com';
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
        
        // Create a custom setting to enable automation log processing and triggers //
        insert new Global_Automation_Setting__c( Skip_Apex_Trigger__c = false );
        TriggerHandler.skipTrigger = false;
    }



    // TEST UNITS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Tests the constructor with a positive result

    History:
    2019-11-07    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @isTest
    private static void ctorTest() {
        // Run as a CPQ user //
        User sampleUser = [SELECT Id FROM User WHERE UserName = :DataFactoryTest.CPQ_STD_USERNAME];
        System.runAs( sampleUser ) {
            // Retrieve and assert some sample data //
            List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c ORDER BY Name LIMIT 1];
            System.assert( !quotes.isEmpty(), 'No quote was found' );
            quotes[ 0 ].Show_Services__c  = true;
            quotes[ 0 ].Show_FCA_Price__c = true;
            update quotes;
            List<SBQQ__QuoteLineGroup__c> groups = [SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quotes[0].Id ORDER BY Name LIMIT 1];
            System.assert( !groups.isEmpty(), 'No lines were found' );
            List<SBQQ__QuoteLine__c> lines = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotes[0].Id AND SBQQ__Group__c = :groups[0].Id ORDER BY Name LIMIT 1];
            //System.assert( !lines.isEmpty(), 'No lines were found' );

            // Set the current page //
            ApexPages.PageReference page = Page.QuoteDocumentView;
            Test.setCurrentPageReference( page );
            ApexPages.currentPage().getParameters().put( QuoteDocumentController.QUOTE_ID_URL_PARAM, quotes[0].Id );

            // Start the test, call the constructor, and then stop the test //
            Test.startTest();
            QuoteDocumentController controller = new QuoteDocumentController();
            Test.stopTest();

            // Requery the data and assert it is correct //
            System.assertNotEquals( null, controller.groups, 'Groups not found' );
            System.assertNotEquals( null, controller.format, 'Format not found' );

            // Run the helper methods for code coverage purposes //
            //groups[0].Customer_Offered_Price__c = null;
            //lines[0].Ex_Works_Price__c = 1;
            //QuoteDocumentController.setRollupPrice( groups[0], lines );
        }
    }



}