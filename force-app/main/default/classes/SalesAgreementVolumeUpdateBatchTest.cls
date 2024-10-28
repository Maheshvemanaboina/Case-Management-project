@IsTest
public with sharing class SalesAgreementVolumeUpdateBatchTest {

    @TestSetup
    private static void dataSetup() {

        OrderStatusIntegration__c settings = new OrderStatusIntegration__c();
        settings.Name = 'test';
        settings.Endpoint__c = 'https://test.com';
        settings.API_Key__c = 'someTestKey';
        Database.insert(settings);

        List<Product2> testProducts = DataFactoryTest.getProductSKUs(2);
        Database.insert(testProducts);

        Pricebook2 priceBookObj = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        Database.update(priceBookObj);

        // Create test accounts //
        List<Account> testAccounts = DataFactoryTest.getAccountCommercialCustomers(2);
        testAccounts[0].OwnerId = testAccounts[1].OwnerId = UserInfo.getUserId();
        Database.insert(testAccounts);

        // Create a test partner role //
        DataFactoryTest.insertPartnerRole(testAccounts[0].Id, testAccounts[1].Id, 'Sold To');

        List<Account> testCustomerLocations = DataFactoryTest.getAccountCustomerLocations(1);
        testCustomerLocations[0].ParentId = testAccounts[0].Id;
        Database.insert(testCustomerLocations);

        List<Contact> testContacts = DataFactoryTest.getContacts(1);
        testContacts[0].Active__c = true;
        testContacts[0].Email = 'testemailfrieslandcamptina@test.com';
        Database.insert(testContacts);

        // Create a test opportunity //
        Opportunity testOpportunity = DataFactoryTest.getOpportunityNewBusinesses(1)[0];
        testOpportunity.OwnerId   = UserInfo.getUserId();
        testOpportunity.AccountId = testAccounts[0].Id;
        testOpportunity.StageName = 'Prospecting/Universe';
        testOpportunity.Reason_Won_Lost__c = '';
        testOpportunity.ContactId = testContacts[0].Id;
        Database.insert(testOpportunity);

        Sales_Area__c salesArea = new Sales_Area__c(
                Sales_Organization__c = '5953',
                Customer_Name__c = testOpportunity.AccountId,
                Active__c        = true
        );
        Database.insert(salesArea);

        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
                OwnerId                 = testOpportunity.OwnerId,
                SBQQ__Account__c        = testOpportunity.AccountId,
                SBQQ__Opportunity2__c   = testOpportunity.Id,
                SBQQ__PricebookId__c    = priceBookObj.Id,
                SBQQ__Primary__c        = true,
                SBQQ__PrimaryContact__c = testOpportunity.ContactId,
                Sales_Area__c           = salesArea.Id,
                EffectiveDate__c        = System.today(),
                SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
                SBQQ__StartDate__c      = System.today().addMonths( 2 ),
                SBQQ__EndDate__c        = System.today().addMonths( 3 )
        );
        Database.insert(testQuote);

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProducts) {
            pricebookEntries.add(new PricebookEntry(UnitPrice = 0.01, Product2Id = prod.Id, Pricebook2Id = priceBookObj.Id,
                    IsActive = true, UseStandardPrice = false));
        }
        Database.insert(pricebookEntries);

        SalesAgreement sa = new SalesAgreement();
        sa.SAP_Number__c = '000123';
        sa.ScheduleCount = 1;
        sa.StartDate = Date.today();
        sa.EndDate = Date.today() + 20;
        sa.PricebookId = priceBookObj.Id;
        sa.Name = 'test';
        sa.AccountId = testAccounts[0].Id;
        sa.Quote__c = testQuote.Id;
        Database.insert(sa);

        Integer position = 1;
        List<SalesAgreementProduct> prods = new List<SalesAgreementProduct>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            SalesAgreementProduct sap1 = new SalesAgreementProduct();
            sap1.SalesAgreementId = sa.Id;
            sap1.Ordered_Quantity__c = 5;
            sap1.Position_Number__c = position;
            sap1.PricebookEntryId = pricebookEntry.Id;
            sap1.InitialPlannedQuantity = 1;
            sap1.Name = 'test';
            prods.add(sap1);

            position++;
        }
        Database.insert(prods);
    }

    @IsTest
    private static void testScenario1() {
        Test.setMock(HttpCalloutMock.class, new SalesAgreementVolumeUpdateCalloutMock());

        List<SalesAgreementProduct> sapList = [SELECT Ordered_Quantity__c FROM SalesAgreementProduct];
        for (SalesAgreementProduct sap : sapList) {
            System.assertEquals(5, sap.Ordered_Quantity__c);
        }

        Test.startTest();
        Database.executeBatch(new SalesAgreementVolumeUpdateBatch());
        Test.stopTest();

        sapList = [SELECT Ordered_Quantity__c FROM SalesAgreementProduct];
        for (SalesAgreementProduct sap : sapList) {
            System.assertEquals(0, sap.Ordered_Quantity__c);
        }
    }

    @IsTest
    private static void testScenario2() {
        Test.setMock(HttpCalloutMock.class, new SalesAgreementVolumeUpdateCalloutMock());
        String cron = '0 0 23 * * ? *';

        Test.startTest();
        String jobId = System.schedule('SalesAgreementVolumeUpdateScheduleJob', cron, new SalesAgreementVolumeUpdateScheduleJob());

        CronTrigger ct = [
                SELECT Id, CronExpression
                FROM CronTrigger
                WHERE Id = :jobId ];
        Test.stopTest();

        System.assertEquals(cron, ct.CronExpression);
    }
}