@IsTest
private class SalesAgreementReSyncHelperTest {
    @TestSetup
    private static void dataSetup() {

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

        Pricebook2 priceBookObj = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        Database.update(priceBookObj);

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
        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>{
                new SBQQ__QuoteLineGroup__c(
                        Name                    = 'Test Group 1',
                        SBQQ__Quote__c          = testQuote.Id,
                        SBQQ__Account__c        = testOpportunity.AccountId,
                        Ship_To_Customer__c     = testAccounts[1].Id,
                        Mode_of_Transport__c    = 'Sea',
                        IncoTerms__c            = 'CIP',
                        IncoTermsDestination__c = 'Amsterdam Schiphol'
                )
        };
        Database.insert(groups);

        SalesAgreement sa= new SalesAgreement();
        sa.Name = 'Test Agreement';
        sa.StartDate = Date.today();
        sa.AccountId = testAccounts[0].Id;
        sa.ScheduleCount = 10;
        sa.PricebookId = priceBookObj.Id;
        sa.Quote__c = testQuote.Id;
        sa.Quote_Line_Group__c = groups[0].Id;
        sa.SAP_Number__c = '000';
        insert sa;
    }

    @IsTest
    private static void testEventPublisher1() {
        SalesAgreement sa = [SELECT Id, Last_Integration_Status__c FROM SalesAgreement LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c FROM SBQQ__Quote__c LIMIT 1];

        quote.SBQQ__Type__c = 'Amendment';
        update quote;

        SalesAgreementReSyncHelper.processData(new List<String>{sa.Id});

        sa = [SELECT Id, Last_Integration_Status__c FROM SalesAgreement LIMIT 1];

        System.assertEquals('To Sync', sa.Last_Integration_Status__c);
    }

    @IsTest
    private static void testEventPublisher2() {
        SalesAgreement sa = [SELECT Id, Last_Integration_Status__c FROM SalesAgreement LIMIT 1];
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c FROM SBQQ__Quote__c LIMIT 1];

        quote.SBQQ__Type__c = 'Quote';
        update quote;

        SalesAgreementReSyncHelper.processData(new List<String>{sa.Id});

        sa = [SELECT Id, Last_Integration_Status__c FROM SalesAgreement LIMIT 1];

        System.assertEquals('To Sync', sa.Last_Integration_Status__c);
    }
}