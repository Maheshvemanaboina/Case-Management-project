public with sharing class BOMCalculator {

    private static Integer duration;
    private static Integer pastDuration;
    private static Decimal totalMP;
    private static Decimal totalPP;
    private static Map<String, Decimal> conversionRatesMap;

    @InvocableMethod(Label='Calculate and create BOM History record' Description='Calculate and create BOM History record' Category='Quote')
    public static void processData(List<String> quoteLineId) {

        SBQQ__QuoteLine__c ql                                   = getQuoteLineData(quoteLineId[0]);
        List<CPQ_Bill_Of_Material_SAP__c> currentBoms           = retrieveCurrentBoms(ql.Product_Code__c);
        Map<String, Product2> sapCodeToProductComponentMap      = mapComponentsToSAPCodes(currentBoms);

        calculateDurations(ql.SBQQ__Group__r.SBQQ__StartDate__c, ql.SBQQ__Group__r.SBQQ__EndDate__c);
        getConversionRates();

        if (currentBoms.size() > 0) {
            List<BOM_History__c> bomHistoriesToAdd = new List<BOM_History__c>();
            for (CPQ_Bill_Of_Material_SAP__c bom : currentBoms) {
                calculateTotals(bom);
                Decimal quantity = (Decimal) bom.Quantity__c.setScale(2, System.RoundingMode.HALF_DOWN);
                bomHistoriesToAdd.add(new BOM_History__c(
                        Quote_Line__c = ql.Id,
                        Parent_Material__c = ql.SBQQ__Product__c,
                        Child_Material__c = sapCodeToProductComponentMap.get(bom.Component__c).Id,
                        Quantity__c = quantity,
                        CurrencyIsoCode = ql.SBQQ__Quote__r.CurrencyIsoCode,
                        External_Key__c = ql.Product_Code__c + '-' + bom.Component__c,
                        Market_Price__c = (Decimal) convertCurrency(totalMP / duration, ql.SBQQ__Quote__r.CurrencyIsoCode).setScale(2, System.RoundingMode.HALF_DOWN),
                        MP_Cost_Price__c = (Decimal) convertCurrency((quantity * (totalMP / duration)) / 1000, ql.SBQQ__Quote__r.CurrencyIsoCode).setScale(2, System.RoundingMode.HALF_DOWN),
                        M00__c = bom.Market_Price_M00__c,
                        M01__c = bom.Market_Price_M01__c,
                        M02__c = bom.Market_Price_M02__c,
                        M03__c = bom.Market_Price_M03__c,
                        M04__c = bom.Market_Price_M04__c,
                        M05__c = bom.Market_Price_M05__c,
                        M06__c = bom.Market_Price_M06__c,
                        M07__c = bom.Market_Price_M07__c,
                        M08__c = bom.Market_Price_M08__c,
                        M09__c = bom.Market_Price_M09__c,
                        M10__c = bom.Market_Price_M10__c,
                        M11__c = bom.Market_Price_M11__c,
                        Purchase_Price__c = (Decimal) convertCurrency(totalPP / duration, ql.SBQQ__Quote__r.CurrencyIsoCode).setScale(2, System.RoundingMode.HALF_DOWN),
                        PP_Cost_Price__c = (Decimal) convertCurrency((quantity * (totalPP / duration)) / 1000, ql.SBQQ__Quote__r.CurrencyIsoCode).setScale(2, System.RoundingMode.HALF_DOWN),
                        P00__c = bom.Purchase_Price_P00__c,
                        P01__c = bom.Purchase_Price_P01__c,
                        P02__c = bom.Purchase_Price_P02__c,
                        P03__c = bom.Purchase_Price_P03__c,
                        P04__c = bom.Purchase_Price_P04__c,
                        P05__c = bom.Purchase_Price_P05__c,
                        P06__c = bom.Purchase_Price_P06__c,
                        P07__c = bom.Purchase_Price_P07__c,
                        P08__c = bom.Purchase_Price_P08__c,
                        P09__c = bom.Purchase_Price_P09__c,
                        P10__c = bom.Purchase_Price_P10__c,
                        P11__c = bom.Purchase_Price_P11__c
                ));
            }

            List<BOM_History__c> bomHistoriesToDelete = [SELECT Id FROM BOM_History__c WHERE Quote_Line__c = :ql.Id];
            if (bomHistoriesToDelete.size() != 0) {
                Database.delete(bomHistoriesToDelete);
            }

            Database.insert(bomHistoriesToAdd);
        } else {
            throw new BOMCalcException('There are no BOM records available for your product');
        }
    }

    // Retrieve data about selected Quote Line
    private static SBQQ__QuoteLine__c getQuoteLineData(Id quoteLineId) {
        return [
                SELECT
                        Product_Code__c, SBQQ__Group__r.SBQQ__StartDate__c, SBQQ__Group__r.SBQQ__EndDate__c, SBQQ__Product__c,
                        SBQQ__Quote__r.CurrencyIsoCode
                FROM
                        SBQQ__QuoteLine__c
                WHERE
                        Id = :quoteLineId
        ];
    }

    // Retrieve current BOM records
    private static List<CPQ_Bill_Of_Material_SAP__c> retrieveCurrentBoms(String productCode) {
        return [
                SELECT
                        Material__c, Component__c, Market_Price_M00__c, Market_Price_M01__c, Market_Price_M02__c,
                        Market_Price_M03__c, Market_Price_M04__c, Market_Price_M05__c, Market_Price_M06__c,
                        Market_Price_M07__c, Market_Price_M08__c, Market_Price_M09__c, Market_Price_M10__c, Market_Price_M11__c,
                        Purchase_Price_P00__c, Purchase_Price_P01__c, Purchase_Price_P02__c, Purchase_Price_P03__c,
                        Purchase_Price_P04__c, Purchase_Price_P05__c, Purchase_Price_P06__c, Purchase_Price_P07__c,
                        Purchase_Price_P08__c, Purchase_Price_P09__c, Purchase_Price_P10__c, Purchase_Price_P11__c,
                        Quantity__c
                FROM
                        CPQ_Bill_Of_Material_SAP__c
                WHERE
                        Material__c = :productCode
        ];
    }

    // Calculate duration and past duration between dates
    private static void calculateDurations(Date startDate, Date endDate) {
        Date currentDate = Date.today();

        if (currentDate > startDate) {
            pastDuration = startDate.monthsBetween(currentDate);
        } else {
            pastDuration = 0;
        }
        duration = startDate.monthsBetween(endDate);
    }

    // Create a mapping for child products
    private static Map<String, Product2> mapComponentsToSAPCodes(List<CPQ_Bill_Of_Material_SAP__c> currentBoms) {
        Set<String> componentSAPCodes = new Set<String>();
        Map<String, Product2> sapCodeToProductMap = new Map<String, Product2>();
        for (CPQ_Bill_Of_Material_SAP__c bom : currentBoms) {
            componentSAPCodes.add(bom.Component__c);
        }

        List<Product2> componentProducts = [
                SELECT
                        Id, Product_Code__c
                FROM
                        Product2
                WHERE
                        Product_Code__c IN :componentSAPCodes
        ];

        for (Product2 prod : componentProducts) {
            sapCodeToProductMap.put(prod.Product_Code__c, prod);
        }

        return sapCodeToProductMap;
    }

    // Calculate totals for Purchase Price and Market Price for given BOM
    private static void calculateTotals(CPQ_Bill_Of_Material_SAP__c bom) {
        totalMP = 0;
        totalPP = 0;

        for (Integer i = 0; i < duration; i++) {
            if (pastDuration > 0 && i == 0) {
                totalMP = (Decimal) bom.get('Market_Price_M00__c') * pastDuration;
                totalPP = (Decimal) bom.get('Purchase_Price_P00__c') * pastDuration;
            }

            if (i < 10) {
                totalMP += (Decimal) bom.get('Market_Price_M0' + i + '__c');
                totalPP += (Decimal) bom.get('Purchase_Price_P0' + i + '__c');
            } else if (i < 12) {
                totalMP += (Decimal) bom.get('Market_Price_M' + i + '__c');
                totalPP += (Decimal) bom.get('Purchase_Price_P' + i + '__c');
            }
        }

        totalMP = (Decimal) totalMP.setScale(2, System.RoundingMode.HALF_DOWN);
        totalPP = (Decimal) totalPP.setScale(2, System.RoundingMode.HALF_DOWN);
    }

    // Retrieve conversion rates from database
    private static void getConversionRates() {
        conversionRatesMap = new Map<String, Decimal>();
        for (DatedConversionRate dcr : [
                SELECT
                        ConversionRate, IsoCode
                FROM
                        DatedConversionRate
                WHERE
                        StartDate <= TODAY
                        AND NextStartDate > TODAY
        ]) {
            conversionRatesMap.put(dcr.IsoCode, dcr.ConversionRate);
        }
    }

    // Convert value to quote currency
    private static Decimal convertCurrency(Decimal value, String isoCodeTarget) {
        Decimal result = 0;
        if (isoCodeTarget == 'EUR') {
            result = value;
        } else {
            result = value * conversionRatesMap.get(isoCodeTarget);
        }
        return result;
    }

    public class BOMCalcException extends Exception {}
}