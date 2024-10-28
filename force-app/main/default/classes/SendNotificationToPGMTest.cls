@isTest
private class SendNotificationToPGMTest {
    final static String PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME = 'BGI_Product_SKU';

    @testSetup
    static void populateMockData() {
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
        // EmailTemplate e = new EmailTemplate (developerName = 'test', FolderId=UserInfo.getUserId(),   TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
        // insert e;
      
        Account sampleAccount = DataFactoryTest.getAccountCommercialCustomers( 1 )[ 0 ];
        sampleAccount.OwnerId       = userInfo.getUserId();
        sampleAccount.SAP_Number__c = '0000100655';
        Database.insert( sampleAccount );
        
        Contact sampleContact = DataFactoryTest.getContacts( 1 )[ 0 ];
        sampleContact.OwnerId   = userInfo.getUserId();
        sampleContact.AccountId = sampleAccount.Id;
        Database.insert( sampleContact );
        
        Opportunity sampleOpportunity = DataFactoryTest.getOpportunityNewBusinesses( 1 )[ 0 ];
        sampleOpportunity.OwnerId   =userInfo.getUserId();
        sampleOpportunity.AccountId = sampleAccount.Id;
        sampleOpportunity.ContactId = sampleContact.Id;
        sampleOpportunity.Business_Segment__c = 'Adult Nutrition';
        sampleOpportunity.Sub_Segment__c = 'Active Nutrition';
        sampleOpportunity.StageName = 'Prospecting';
        sampleOpportunity.Reason_Won_Lost__c = '';
        sampleOpportunity.Opportunity_Application__c = 'Multiple';
        Database.insert( sampleOpportunity );
        
        Sales_Area__c salesArea = new Sales_Area__c(
            /*SALES_ORG__c          = '5953',*/
            Sales_Organization__c = '5953',
            Customer_Name__c = sampleOpportunity.AccountId,
            Active__c        = true
        );
        Database.insert( salesArea );
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            OwnerId                 = sampleOpportunity.OwnerId,
            SBQQ__Account__c        = sampleOpportunity.AccountId,
            SBQQ__Opportunity2__c   = sampleOpportunity.Id,
            SBQQ__PriceBook__c      = Test.getStandardPricebookId(),
            SBQQ__Primary__c        = true,
            SBQQ__PrimaryContact__c = sampleOpportunity.ContactId,
            Sales_Area__c           = salesArea.Id,
            EffectiveDate__c        = System.today(),
            SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
            SBQQ__StartDate__c      = System.today().addMonths( 2 ),
            SBQQ__EndDate__c        = System.today().addMonths( 3 ),
            Sales_Region__c = 'EMEA'
        );
        Database.insert( quote );
        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>{
            new SBQQ__QuoteLineGroup__c(
                Name                    = 'Group 1',
                SBQQ__Quote__c          = quote.Id,
                SBQQ__Account__c        = sampleOpportunity.AccountId,
                Mode_of_Transport__c    = 'Sea',
                IncoTerms__c            = 'CIP',
                IncoTermsDestination__c = 'Amsterdam Schiphol'
                
                
            )
        };
            Database.insert( groups ); 
        List<Product2> records = new List<Product2>();
        records.add( new Product2(
                Name               = 'Sample Product ',
                RecordTypeId       = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId(),
                ProductCode        = 'Pro-00000000',
                IsActive           = true
            ));
        Database.insert(records);
        
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        lines.add( new SBQQ__QuoteLine__c(
                SBQQ__Quote__c     = quote.Id,
                SBQQ__Group__c     = groups[ 0 ].Id,
                SBQQ__Product__c   = records[0].Id,
                Product_RecordType_DeveloperName__c='BGI_Product_SKU',
                SBQQ__Quantity__c  = 5,
                Unit_of_measure__c = 'KG',
                SBQQ__ListPrice__c = 1,
                Floor_Price__c = 5
            ));
        Database.insert(lines);
    }

    @isTest
    static Void testSendNotification() {
        Map<Id,SBQQ__Quote__c> quotes = new Map<Id,SBQQ__Quote__c>([Select Id, name From SBQQ__Quote__c]);
        PGMEmailSetting__c cusSet = new PGMEmailSetting__c();
        cusSet.Name='1';
        cusSet.PGM_1__c ='test1@wrongdomain.wr';
        cusSet.PGM_2__c  ='test2@wrongdomain.wr';
        cusSet.PGM_3__c  = 'test3@wrongdomain.wr';
        cusSet.Application_Name__c='Multiple';
        insert cusSet;
        
        Quote_Region_Email_Setting__c  getEmailForRegion = new Quote_Region_Email_Setting__c();
        getEmailForRegion.Name = 'EMEA';
        getEmailForRegion.Email_1__c = 'test1@wrongdomain.wr';
        getEmailForRegion.Email_2__c = 'test2@wrongdomain.wr';
        getEmailForRegion.Email_3__c = 'test3@wrongdomain.wr';
        insert getEmailForRegion;
        
        test.startTest();
        SendNotificationToPGM.sendNotification(new List<Id>(quotes.keySet()));
        
        test.stopTest();

    }
}