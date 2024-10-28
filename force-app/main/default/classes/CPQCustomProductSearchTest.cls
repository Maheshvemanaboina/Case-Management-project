@IsTest
private class CPQCustomProductSearchTest {

    @TestSetup
    private static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'Poland';
        acc.BillingCity = 'Lublin';
        insert acc;

        Sales_Area__c salesArea = new Sales_Area__c();
        salesArea.Name = 'Test Sales Area';
        salesArea.SALES_ORG__c = 'Test Sales Org';
        salesArea.Active__c = true;
        salesArea.Customer_Name__c = acc.Id;
        insert salesArea;

        Partner_Role__c partnerRole = new Partner_Role__c();
        partnerRole.Name = 'Test Partner Role';
        partnerRole.Target_Account__c = acc.Id;
        insert partnerRole;

        Product2 product = new Product2();
        product.Name = 'Test Product';
        insert product;

        Listing__c listing = new Listing__c();
        listing.Sales_Area__c = salesArea.Id;
        listing.Sold_To_Account__c = partnerRole.Id;
        listing.Active__c = true;
        listing.Product__c = product.Id;
        insert listing;

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.Sales_Area__c = salesArea.Id;
        quote.SBQQ__Account__c = acc.Id;
        insert quote;
    }

    @IsTest
    private static void testScenario1() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c, Sales_Area__c FROM SBQQ__Quote__c LIMIT 1];
        CPQCustomProductSearch productSearch = new CPQCustomProductSearch();
        System.assertNotEquals(null, productSearch.getAdditionalSearchFilters(quote, null));
    }

    @IsTest
    private static void testScenario2() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c, Sales_Area__c FROM SBQQ__Quote__c LIMIT 1];
        CPQCustomProductSearch productSearch = new CPQCustomProductSearch();
        System.assertEquals(false, productSearch.isFilterHidden(quote, null));
        System.assertEquals(null, productSearch.getFilterDefaultValue(quote, null));
        System.assertEquals(false, productSearch.isSearchCustom(quote, null));
        System.assertEquals(null, productSearch.search(quote, null));
        System.assertEquals(null, productSearch.search(quote, null));
        System.assertEquals(false, productSearch.isInputHidden(quote, null));
        System.assertEquals(null, productSearch.getInputDefaultValue(quote, null));
        System.assertEquals(true, productSearch.isSuggestCustom(quote, null));
        System.assertEquals(null, productSearch.getAdditionalSuggestFilters(quote, null));
        System.assertEquals(null, productSearch.suggest(quote, null));
    }
}