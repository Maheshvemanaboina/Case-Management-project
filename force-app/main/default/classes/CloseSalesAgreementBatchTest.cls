@isTest
public class CloseSalesAgreementBatchTest {

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

        // Create a test product //
        List<Product2> testProducts = DataFactoryTest.getProductSKUs(4);

        Database.insert(testProducts);

        Pricebook2 priceBookObj = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        Database.update(priceBookObj);

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProducts) {
            pricebookEntries.add(new PricebookEntry(UnitPrice = 0.01, Product2Id = prod.Id, Pricebook2Id = priceBookObj.Id,
                    IsActive = true, UseStandardPrice = false));
        }
        Database.insert(pricebookEntries);

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
                        Mode_of_Transport__c    = 'Sea',
                        IncoTerms__c            = 'CIP',
                        IncoTermsDestination__c = 'Amsterdam Schiphol',
                        SBQQ__StartDate__c      = System.today().addMonths(2),
                        SBQQ__EndDate__c        = System.today().addMonths(3)
                )
        };
        Database.insert(groups);

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        Integer i = 0;
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            lines.add( new SBQQ__QuoteLine__c(
                    SBQQ__Quote__c              = testQuote.Id,
                    SBQQ__Group__c              = groups[0].Id,
                    SBQQ__Product__c            = pricebookEntry.Product2Id,
                    SBQQ__PricebookEntryId__c   = pricebookEntry.Id,
                    SBQQ__Quantity__c           = 5,
                    Unit_of_measure__c          = 'KG',
                    SBQQ__ListPrice__c          = 1,
                    SBQQ__Number__c             = i++
            ));
        }

        SBQQ.TriggerControl.disable();
        Database.insert(lines);
        SBQQ.TriggerControl.enable();
       
    }  
    
    @IsTest
    private static void testBatch() {

        QuoteToSalesAgreementConverter.processData(new List<String>{[SELECT Id FROM SBQQ__Quote__c LIMIT 1].Id});
        
        SalesAgreement saRec =  new SalesAgreement();
        saRec = [SELECT Id FROM SalesAgreement LIMIT 1];
        saRec.SAP_Number__c = '0040001129';
        saRec.StartDate = date.today().adddays(-10);
        saRec.EndDate = date.today().adddays(-2);
        saRec.SAP_Contract_Status__c = 'Fully referenced';
        saRec.Last_Integration_Status__c = 'In Sync';
        update saRec;
     
        CloseSalesAgreementBatch ca = new CloseSalesAgreementBatch();
        Database.executeBatch(ca);
        
        saRec = [SELECT Id,Last_Integration_Date__c,Last_Integration_Status__c FROM SalesAgreement LIMIT 1];
        System.assertEquals('In Sync', saRec.Last_Integration_Status__c);
    }    
}