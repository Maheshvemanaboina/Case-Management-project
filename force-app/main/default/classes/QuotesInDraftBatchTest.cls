@isTest
private class QuotesInDraftBatchTest {
    @testSetup
    public static void populateMockData() {
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
        testCustomerLocation.Name     = 'THIS is JUST a SAMPLE name';
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
        Sales_Area__c salesArea = new Sales_Area__c(
            /*SALES_ORG__c          = '5953',*/
            Sales_Organization__c = '5953',
            Customer_Name__c = sampleOpportunity.AccountId,
            Active__c        = true
        );
        Database.insert( salesArea );
        SBQQ__Quote__c quoteNonPrimary = new SBQQ__Quote__c(
            OwnerId                 = sampleOpportunity.OwnerId,
            SBQQ__Account__c        = sampleOpportunity.AccountId,
            SBQQ__Opportunity2__c   = sampleOpportunity.Id,
            SBQQ__PriceBook__c      = Test.getStandardPricebookId(),
            SBQQ__Primary__c        = false,
            SBQQ__Status__c        = 'Draft',
            SBQQ__PrimaryContact__c = sampleOpportunity.ContactId,
            Sales_Area__c           = salesArea.Id,
            EffectiveDate__c        = System.today(),
            SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
            SBQQ__StartDate__c      = System.today().addMonths( 2 ),
            SBQQ__EndDate__c        = System.today().addMonths( 3 )
        );
        Database.insert( quoteNonPrimary );
        //insert Partner Role Ship To in DB (sample) and Agent Role
        DataFactoryTest.insertPartnerRole(sampleAccount.Id, sampleAccount.Id, CPQUtility.SHIP_TO);
        DataFactoryTest.insertPartnerRole(sampleAccount.Id, sampleAccount.Id, CPQUtility.AGENT);

        sampleOpportunity.StageName = 'Closed Lost';
        sampleOpportunity.Reason_Won_Lost__c = 'Cancelled by Customer';
        update sampleOpportunity;

        quoteNonPrimary.SBQQ__Status__c = 'Draft';
        quoteNonPrimary.Reason_Opportunity_Won_Loss__c = '';
        update quoteNonPrimary;

        // Create a price list //
        insert new PriceBook2( Name = 'THIS is JUST a SAMPLE name', IsActive = true );

        // Create a custom setting to enable automation log processing and triggers //
        insert new Global_Automation_Setting__c( Skip_Apex_Trigger__c = false );
        TriggerHandler.skipTrigger = False;
    }

    @isTest
    public static void testQuotesInDraftBatch() {
        Boolean exceptionHappened = false; 
        Test.startTest();
        try {
            QuotesInDraftBatch quotesInDraftBatch = new QuotesInDraftBatch();
            Database.executeBatch(quotesInDraftBatch);
        }
        catch (Exception ex) {
            exceptionHappened = true;
            throw ex;
        }
        Test.stopTest();
        Assert.areEqual(false, exceptionHappened, 'no exception happened on quotes in draft batch job');
    }
}