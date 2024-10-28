@IsTest
private class StandardReportUtilsTest {
    @testSetup static void setup(){
        Account accobj = TestUtility.createAccount('FCI Test 1');
        insert accobj; 
        Account accobj2 = TestUtility.createAccount('Test 2');
        accobj2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId();
        insert accobj2; 
        
        Opportunity opp = TestUtility.createOpportunity('testOppname', Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID, accobj, accobj2);
        opp.Name = 'Clone Test Opp';
        opp.OwnerId = UserInfo.getUserId();
        opp.CloseDate = System.today();
        insert opp;
        System.assertEquals(System.today(),opp.CloseDate);
        // Create a test product //
        List<Product2> testProducts = DataFactoryTest.getProductSKUs(2);

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
                Customer_Name__c = opp.AccountId,
                Active__c        = true
        );
        Database.insert(salesArea);
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
                OwnerId                 = opp.OwnerId,
                SBQQ__Account__c        = opp.AccountId,
                SBQQ__Opportunity2__c   = opp.Id,
                SBQQ__PricebookId__c    = priceBookObj.Id,
                SBQQ__Primary__c        = true,
                SBQQ__PrimaryContact__c = opp.ContactId,
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
                        SBQQ__Account__c        = opp.AccountId,
                        Mode_of_Transport__c    = 'Sea',
                        IncoTerms__c            = 'CIP',
                        IncoTermsDestination__c = 'Amsterdam Schiphol',
                        SBQQ__StartDate__c      = System.today().addMonths(2),
                        SBQQ__EndDate__c        = System.today().addMonths(3)
                ),
                new SBQQ__QuoteLineGroup__c(
                        Name                    = 'Test Group 2',
                        SBQQ__Quote__c          = testQuote.Id,
                        SBQQ__Account__c        = opp.AccountId,
                        Mode_of_Transport__c    = 'Sea',
                        IncoTerms__c            = 'CIP',
                        IncoTermsDestination__c = 'Amsterdam Schiphol',
                        SBQQ__StartDate__c      = System.today().addMonths(2),
                        SBQQ__EndDate__c        = System.today().addMonths(3)
                )
        };
        Database.insert(groups);

        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            SBQQ__QuoteLine__c newLine = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = testQuote.Id,
                SBQQ__Group__c              = groups[0].Id,
                SBQQ__Product__c            = pricebookEntry.Product2Id,
                SBQQ__PricebookEntryId__c   = pricebookEntry.Id,
                SBQQ__Quantity__c           = 5,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 1
            );
            lines.add(newLine);
        }

        SBQQ.TriggerControl.disable();
        Database.insert(lines);
        SBQQ.TriggerControl.enable();
    }
    @IsTest
    static void getTabularReportResponseTest() {
        SBQQ__Quote__c quote = [select Id, Quote_Name__c from SBQQ__Quote__c limit 1];
        Test.startTest();
        quote.Quote_Name__c = quote.Quote_Name__c + ' changed';
        update quote;

        Id reportId = '00OUE0000007JHF2A2';
        StandardReportUtils.TabularReportResponse tabularReportRes = StandardReportUtils.getTabularReportResponse(reportId,'SBQQ__Quote__c.Id',quote.Id);

        Test.stopTest();

        System.assert(!tabularReportRes.reportFields.isEmpty());
    }
}