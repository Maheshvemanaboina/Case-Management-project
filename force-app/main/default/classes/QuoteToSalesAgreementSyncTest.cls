@IsTest
private class QuoteToSalesAgreementSyncTest {
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
        List<Product2> testProducts = DataFactoryTest.getProductSKUs(7);

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
                SBQQ__ExpirationDate__c = System.today().addMonths(1),
                SBQQ__StartDate__c      = System.today().addMonths(2),
                SBQQ__EndDate__c        = System.today().addMonths(3)
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
                ),
                new SBQQ__QuoteLineGroup__c(
                        Name                    = 'Test Group 2',
                        SBQQ__Quote__c          = testQuote.Id,
                        SBQQ__Account__c        = testOpportunity.AccountId,
                        Mode_of_Transport__c    = 'Sea',
                        IncoTerms__c            = 'CIP',
                        IncoTermsDestination__c = 'Amsterdam Schiphol',
                        SBQQ__StartDate__c      = System.today().addMonths(2),
                        SBQQ__EndDate__c        = System.today().addMonths(3)
                ),
                new SBQQ__QuoteLineGroup__c(
                        Name                    = 'Test Group 3',
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

        lines.add(new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = testQuote.Id,
                SBQQ__Group__c              = groups[0].Id,
                SBQQ__Product__c            = pricebookEntries[0].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[0].Id,
                SBQQ__Quantity__c           = 5,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 10,
                SBQQ__Number__c             = 1
        ));

        lines.add(new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = testQuote.Id,
                SBQQ__Group__c              = groups[1].Id,
                SBQQ__Product__c            = pricebookEntries[1].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[1].Id,
                SBQQ__Quantity__c           = 15,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 10,
                SBQQ__Number__c             = 2
        ));

        lines.add(new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = testQuote.Id,
                SBQQ__Group__c              = groups[2].Id,
                SBQQ__Product__c            = pricebookEntries[2].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[2].Id,
                SBQQ__Quantity__c           = 15,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 10,
                SBQQ__Number__c             = 3
        ));

        SBQQ.TriggerControl.disable();
        Database.insert(lines);
        SBQQ.TriggerControl.enable();

        delete [SELECT Id FROM SBQQ__QuoteLineGroup__c WHERE Name = 'Group 1'];
    }

    @IsTest
    private static void testAgreementSync() {
        Test.startTest();
        SBQQ__Quote__c originalQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        // Create Sales Agreements
        QuoteToSalesAgreementConverter.processData(new List<String>{originalQuote.Id});

        SalesAgreement saList = [SELECT Id FROM SalesAgreement LIMIT 1];
        // Amend Sales Agreement
        SalesAgreementAmendmentCreator.processData(new List<String>{saList.Id});

        SBQQ__Quote__c amendmentQuote                   = getAmendmentQuote(originalQuote.Id);
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups   = getQuoteLineGroups(amendmentQuote.Id);
        Set<Id> unwantedPricebooks                      = getUnwantedPricebooks(quoteLineGroups);

        // Making changes to the Groups and Lines
        updateExistingData(quoteLineGroups, amendmentQuote);

        // Prepare new Group and Lines
        SBQQ__QuoteLineGroup__c newQLG = createNewGroup(amendmentQuote);
        createNewQuoteLines(unwantedPricebooks, amendmentQuote, newQLG, quoteLineGroups);

        // Sync amends to Agreements and Products
        QuoteToSalesAgreementSync.processData(new List<String>{amendmentQuote.Id});
        Test.stopTest();

        List<SalesAgreement> agreementsMarkedForUpdate = [SELECT Id, To_Update__c, Last_Integration_Status__c FROM SalesAgreement WHERE To_Update__c = TRUE];
        List<SalesAgreement> agreementsWaitingForCreation = [SELECT Id, To_Update__c, Last_Integration_Status__c FROM SalesAgreement WHERE To_Update__c = FALSE];
        List<SalesAgreementProduct> agreementProducts = [SELECT Id FROM SalesAgreementProduct];

        System.assertEquals(3, agreementsMarkedForUpdate.size());
        System.assertEquals(1, agreementsWaitingForCreation.size());
        System.assertEquals(7, agreementProducts.size());
    }


    /************** HELPER METHODS **************/
    private static SBQQ__Quote__c getAmendmentQuote(Id originalQuoteId) {
        return [
                SELECT
                        Id, SBQQ__Opportunity2__r.AccountId
                FROM
                        SBQQ__Quote__c
                WHERE
                        Id != :originalQuoteId
                LIMIT 1
        ];
    }

    private static List<SBQQ__QuoteLineGroup__c> getQuoteLineGroups(Id amendmentQuoteId) {
         return [
                SELECT
                        Id, IncoTerms__c,
                        (
                                SELECT
                                        Id, SBQQ__Quantity__c, SBQQ__PricebookEntryId__c
                                FROM
                                        SBQQ__LineItems__r
                        )
                FROM
                        SBQQ__QuoteLineGroup__c
                WHERE
                        SBQQ__Quote__c = :amendmentQuoteId
        ];
    }

    private static Set<Id> getUnwantedPricebooks(List<SBQQ__QuoteLineGroup__c> quoteLineGroups) {
        Set<Id> unwantedPricebooks = new Set<Id>();
        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroups) {
            for (SBQQ__QuoteLine__c ql : qlg.SBQQ__LineItems__r) {
                unwantedPricebooks.add(ql.SBQQ__PricebookEntryId__c);
            }
        }
        return unwantedPricebooks;
    }

    private static void updateExistingData(List<SBQQ__QuoteLineGroup__c> quoteLineGroups, SBQQ__Quote__c quote) {
        List<SObject> recordsToUpdate = new List<SObject>();
        quoteLineGroups[0].IncoTerms__c = 'CFR';
        quoteLineGroups[1].IncoTerms__c = 'CFR';

        for (SBQQ__QuoteLine__c ql : quoteLineGroups[1].SBQQ__LineItems__r) {
            ql.SBQQ__Quantity__c = 1000;
        }

        for (SBQQ__QuoteLine__c ql : quoteLineGroups[2].SBQQ__LineItems__r) {
            ql.SBQQ__Quantity__c = 1000;
        }

        quote.SBQQ__StartDate__c = Date.today().addMonths(1);

        recordsToUpdate.add(quote);
        recordsToUpdate.addAll(quoteLineGroups[1].SBQQ__LineItems__r);
        recordsToUpdate.addAll(quoteLineGroups[2].SBQQ__LineItems__r);
        recordsToUpdate.addAll(quoteLineGroups);

        update recordsToUpdate;
    }

    private static SBQQ__QuoteLineGroup__c createNewGroup(SBQQ__Quote__c amendmentQuote) {
        SBQQ__QuoteLineGroup__c newQLG = new SBQQ__QuoteLineGroup__c(
                Name                    = 'Test Group 4',
                SBQQ__Quote__c          = amendmentQuote.Id,
                SBQQ__Account__c        = amendmentQuote.SBQQ__Opportunity2__r.AccountId,
                Mode_of_Transport__c    = 'Sea',
                IncoTerms__c            = 'CIP',
                IncoTermsDestination__c = 'Amsterdam Schiphol',
                SBQQ__StartDate__c      = Date.today().addMonths(1),
                SBQQ__EndDate__c        = Date.today().addMonths(3)
        );
        insert newQLG;
        return newQLG;
    }

    private static void createNewQuoteLines(Set<Id> unwantedPricebooks,
            SBQQ__Quote__c amendmentQuote,
            SBQQ__QuoteLineGroup__c newQLG,
            List<SBQQ__QuoteLineGroup__c> quoteLineGroups) {

        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        List<PricebookEntry> pricebookEntries = [
                SELECT
                        Id, Product2Id
                FROM
                        PricebookEntry
                WHERE
                        Id NOT IN :unwantedPricebooks
        ];

        SBQQ__QuoteLine__c newQL1 = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = amendmentQuote.Id,
                SBQQ__Group__c              = newQLG.Id,
                SBQQ__Product__c            = pricebookEntries[0].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[0].Id,
                SBQQ__Quantity__c           = 15,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 10,
                SBQQ__Number__c             = 4
        );

        SBQQ__QuoteLine__c newQL2 = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = amendmentQuote.Id,
                SBQQ__Group__c              = quoteLineGroups[0].Id,
                SBQQ__Product__c            = pricebookEntries[1].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[1].Id,
                SBQQ__Quantity__c           = 15,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 10,
                SBQQ__Number__c             = 5
        );

        SBQQ__QuoteLine__c newQL3 = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = amendmentQuote.Id,
                SBQQ__Group__c              = quoteLineGroups[1].Id,
                SBQQ__Product__c            = pricebookEntries[2].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[2].Id,
                SBQQ__Quantity__c           = 15,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 10,
                SBQQ__Number__c             = 6
        );

        SBQQ__QuoteLine__c newQL4 = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = amendmentQuote.Id,
                SBQQ__Group__c              = quoteLineGroups[2].Id,
                SBQQ__Product__c            = pricebookEntries[3].Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntries[3].Id,
                SBQQ__Quantity__c           = 15,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 10,
                SBQQ__Number__c             = 7
        );

        quoteLinesToInsert.add(newQL1);
        quoteLinesToInsert.add(newQL2);
        quoteLinesToInsert.add(newQL3);
        quoteLinesToInsert.add(newQL4);

        SBQQ.TriggerControl.disable();
        insert quoteLinesToInsert;
        SBQQ.TriggerControl.enable();
    }
}