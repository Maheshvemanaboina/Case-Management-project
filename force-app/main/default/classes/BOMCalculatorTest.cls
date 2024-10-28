@IsTest
private class BOMCalculatorTest {
    @TestSetup
    private static void setup() {

        // Insert test products
        List<Product2> testProductList  = DataFactoryTest.getProductSKUs(2);

        Product2 productSKU = testProductList[0] ;
        productSKU.Product_Code__c = '000000000000588389';
        productSKU.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'BGI_Product_SKU' ).getRecordTypeId();
        productSKU.Sales_Organization_Number__c = '5080';
        productSKU.Business_Segment_Non_Restricted__c = 'Industry';
        productSKU.Base_Unit_of_Measure__c = 'KG';
        productSKU.SBQQ__OptionSelectionMethod__c = 'Click';
        productSKU.SBQQ__PricingMethod__c = 'List';
        productSKU.SBQQ__SubscriptionBase__c = 'List';
        productSKU.SBQQ__SubscriptionType__c = 'Renewable';
        productSKU.SBQQ__DefaultQuantity__c = 100000;
        productSKU.SBQQ__AssetConversion__c = 'One per quote line';
        productSKU.SBQQ__AssetAmendmentBehavior__c = 'Default';
        productSKU.SBQQ__BlockPricingField__c = 'Quantity';

        Product2 productSKU2 = testProductList[1] ;
        productSKU2.Product_Code__c = '000000000000561653';
        productSKU2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'Product_Material' ).getRecordTypeId();
        productSKU2.Sales_Organization_Number__c = '5032';
        productSKU2.Base_Unit_of_Measure__c = 'KG';
        productSKU2.SBQQ__PricingMethod__c = 'List';
        productSKU2.SBQQ__SubscriptionBase__c = 'List';
        productSKU2.SBQQ__SubscriptionType__c = 'Renewable';
        productSKU2.SBQQ__DefaultQuantity__c = 100000;
        productSKU2.SBQQ__AssetConversion__c = 'One per quote line';
        productSKU2.SBQQ__AssetAmendmentBehavior__c = 'Default';
        productSKU2.SBQQ__BlockPricingField__c = 'Quantity';
        productSKU2.Product_Hierarchy_Code__c = '160355410044145999';
        productSKU2.Hierarchy_1__c = 'Food / Nutrition ingredients';
        productSKU2.Hierarchy_2__c = 'Kievit supply (NOT USED)';
        productSKU2.Hierarchy_3__c = 'Vana Sana Others Encapsulates (NOT USED)';
        productSKU2.Hierarchy_4__c = 'Bag';
        productSKU2.Hierarchy_5__c = 'No packaging Size';
        productSKU2.Hierarchy_6__c = 'No flavour';

        insert testProductList;

        // Insert test BOM
        CPQ_Bill_Of_Material_SAP__c newBom = new CPQ_Bill_Of_Material_SAP__c();
        newBom.Plant__c = '3061';
        newBom.Plant_Name__c = 'Kievit Meppel test Plant';
        newBom.Material__c = '000000000000588389';
        newBom.Component__c = '000000000000561653';
        newBom.Origin_Group__c = '1201';
        newBom.External_Key__c = '000000000000588389-000000000000561653';
        newBom.Price_Unit_for_Cost_Price__c = 10000;
        newBom.Price_Unit_UoM__c = 'KG';
        newBom.Quantity__c = 10;
        newBom.Quantity_UoM__c = 'KG';
        newBom.Standard_Price__c = 3618;
        newBom.Standard_Qty__c = 10000;
        newBom.Standard_Qty_UoM__c = 'KG';
        newBom.Period_Year__c = '201910';
        newBom.Market_Price_M00__c = 3594  ;
        newBom.Purchase_Price_P00__c = 3606;
        newBom.Market_Price_M01__c = 3595  ;
        newBom.Purchase_Price_P01__c = 3607;
        newBom.Market_Price_M02__c = 3596  ;
        newBom.Purchase_Price_P02__c = 3608;
        newBom.Market_Price_M03__c = 3597  ;
        newBom.Purchase_Price_P03__c = 3609;
        newBom.Market_Price_M04__c = 3598  ;
        newBom.Purchase_Price_P04__c = 3610;
        newBom.Market_Price_M05__c = 3599  ;
        newBom.Purchase_Price_P05__c = 3611;
        newBom.Market_Price_M06__c = 3600  ;
        newBom.Purchase_Price_P06__c = 3612;
        newBom.Market_Price_M07__c = 3601  ;
        newBom.Purchase_Price_P07__c = 3613;
        newBom.Market_Price_M08__c = 3602  ;
        newBom.Purchase_Price_P08__c = 3614;
        newBom.Market_Price_M09__c = 3603  ;
        newBom.Purchase_Price_P09__c = 3615;
        newBom.Market_Price_M10__c = 3604  ;
        newBom.Purchase_Price_P10__c = 3616;
        newBom.Market_Price_M11__c = 3605  ;
        newBom.Purchase_Price_P11__c = 3617;
        newBom.TECH_ToProcess__c = true;
        newBom.TECH_QuantityChanged__c = true;

        insert newBom;

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

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProductList) {
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
                SBQQ__ExpirationDate__c = System.today().addMonths(5),
                SBQQ__StartDate__c      = System.today().addMonths(-2),
                SBQQ__EndDate__c        = System.today().addMonths(10),
                CurrencyIsoCode         = 'USD'
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
        lines.add( new SBQQ__QuoteLine__c(
                SBQQ__Quote__c              = testQuote.Id,
                SBQQ__Group__c              = groups[0].Id,
                SBQQ__Product__c            = testProductList[0].Id,
                Product_Code__c             = testProductList[0].Product_Code__c,
                SBQQ__PricebookEntryId__c   = pricebookEntries[0].Id,
                SBQQ__Quantity__c           = 5,
                Unit_of_measure__c          = 'KG',
                SBQQ__ListPrice__c          = 1,
                SBQQ__Number__c             = 1
        ));

        SBQQ.TriggerControl.disable();
        Database.insert(lines);
        SBQQ.TriggerControl.enable();
    }

    @IsTest
    private static void testScenario1() {
        SBQQ__QuoteLine__c ql = [SELECT Id FROM SBQQ__QuoteLine__c];
        BOMCalculator.processData(new List<String>{ql.Id});
        List<BOM_History__c> histories = [SELECT Id, Quote_Line__c FROM BOM_History__c];

        System.assertEquals(1, histories.size());
        System.assertEquals(ql.Id, histories[0].Quote_Line__c);
    }
}