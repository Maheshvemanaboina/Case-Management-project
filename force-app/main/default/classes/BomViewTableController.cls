public with sharing class BomViewTableController {

    @AuraEnabled(Cacheable=true)
    public static List<BOMSummary> retrieveBOMHistoryWithCalculations(String quoteLineId) {
        List<BOM_History__c> bomHistories = [
                SELECT
                        Child_Material__c, Child_Material__r.Name, Quantity__c, CurrencyIsoCode,
                        Market_Price__c, MP_Cost_Price__c, Purchase_Price__c, PP_Cost_Price__c
                FROM
                        BOM_History__c
                WHERE
                        Quote_Line__c = :quoteLineId
                ORDER BY Name
        ];

        List<BOMSummary> bomSummaries = new List<BomViewTableController.BOMSummary>();
        Decimal totalMarketCostPrice = 0;
        Decimal totalPurchaseCostPrice = 0;
        String currencyCode = bomHistories[0].CurrencyIsoCode;

        for (BOM_History__c bomh : bomHistories) {
            bomSummaries.add(new BOMSummary(
                    bomh.Child_Material__r.Name,
                    bomh.Market_Price__c,
                    bomh.MP_Cost_Price__c,
                    bomh.Purchase_Price__c,
                    bomh.PP_Cost_Price__c,
                    currencyCode
            ));

            totalMarketCostPrice += bomh.MP_Cost_Price__c;
            totalPurchaseCostPrice += bomh.PP_Cost_Price__c;
        }

        bomSummaries.add(new BOMSummary(
                'TOTAL',
                null,
                totalMarketCostPrice,
                null,
                totalPurchaseCostPrice,
                currencyCode
        ));

        return bomSummaries;
    }

    public class BOMSummary {
        @AuraEnabled
        public String productName {get; set;}
        @AuraEnabled
        public Decimal marketPrice {get; set;}
        @AuraEnabled
        public Decimal marketCostPrice {get; set;}
        @AuraEnabled
        public Decimal purchasePrice {get; set;}
        @AuraEnabled
        public Decimal purchaseCostPrice {get; set;}
        @AuraEnabled
        public String currencyCode {get; set;}

        public BOMSummary(String productName, Decimal marketPrice, Decimal marketCostPrice, Decimal purchasePrice, Decimal purchaseCostPrice, String currencyCode) {
            this.productName = productName;
            this.marketPrice = marketPrice;
            this.marketCostPrice = marketCostPrice;
            this.purchasePrice = purchasePrice;
            this.purchaseCostPrice = purchaseCostPrice;
            this.currencyCode = currencyCode;
        }
    }

}