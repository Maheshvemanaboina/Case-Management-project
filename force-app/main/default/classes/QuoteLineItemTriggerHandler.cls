/*
* @Author : Shiva Karna 
* @Date : 20-July 2021
* @Desc : This handler class was called on QuoteLineITemTrigger and it will execute methods based on trigger
          Events.
* @Jira : SCPQ-1055
*/
public without sharing class QuoteLineItemTriggerHandler {

    public void OnBeforeInsert(List<SBQQ__QuoteLine__c> newQuoteLineitem) {
        //update Active Price Model is true
        updateActivePriceMode(newQuoteLineitem);
        calculateItemNumber(newQuoteLineitem);
    }
    public void OnBeforeUpdate(List<SBQQ__QuoteLine__c> newQuoteLineitem, List<SBQQ__QuoteLine__c> oldQuoteLineitem, Map<Id, SBQQ__QuoteLine__c> newQuoteLineitemMap, Map<Id, SBQQ__QuoteLine__c> oldQuoteLineitemMap) {
        //update Active Price Model is true
        updateActivePriceMode(newQuoteLineitem);
    }
    public void OnBeforeDelete(List<SBQQ__QuoteLine__c> oldQuoteLineitems) {
        checkIfRecordsShouldBeBlocked(oldQuoteLineitems);
    }
    public void OnAfterInsert(List<SBQQ__QuoteLine__c> newQuoteLineitem) {
    }
    public void OnAfterUpdate(List<SBQQ__QuoteLine__c> newQuoteLineitem, List<SBQQ__QuoteLine__c> oldQuoteLineitem, Map<Id, SBQQ__QuoteLine__c> newQuoteLineitemMap, Map<Id, SBQQ__QuoteLine__c> oldQuoteLineitemMap) {
    }
    /*------------------------------------------------------------
    Description: Method responsible for calculating real item number on Quote Line.
        The problem is that CPQ is changing those numbers when new items
        are added to different groups, but because those numbers are used
        as ID for integration with SAP, we need to populate a new custom field
        that won't be changing values
    ------------------------------------------------------------*/
    private void calculateItemNumber(List<SBQQ__QuoteLine__c> newQuoteLineitem) {
        Map<Id, List<SBQQ__QuoteLine__c>> quoteIdToQuoteLine = new Map<Id, List<SBQQ__QuoteLine__c>>();
        Map<Id, Decimal> quoteIdToExistingMaxQuoteLineNumber = new Map<Id, Decimal>();

        // Gather IDs of Quotes
        for (SBQQ__QuoteLine__c ql : newQuoteLineitem) {
            if (ql.Product_Type__c == 'Product SKU' && ql.Real_Item_Number__c == null) {
                if (quoteIdToQuoteLine.containsKey(ql.SBQQ__Quote__c)) {
                    quoteIdToQuoteLine.get(ql.SBQQ__Quote__c).add(ql);
                } else {
                    quoteIdToQuoteLine.put(ql.SBQQ__Quote__c, new List<SBQQ__QuoteLine__c>{ql});
                }
            }
        }

        // Query all existing Quote Lines and get the current existing maximum item number
        for (SBQQ__QuoteLine__c existingQuoteLine : [
                SELECT
                        Id, Real_Item_Number__c, SBQQ__Quote__c
                FROM
                        SBQQ__QuoteLine__c
                WHERE
                        SBQQ__Quote__c IN :quoteIdToQuoteLine.keySet()
                        AND Product_Type__c = 'Product SKU'
                ORDER BY
                        SBQQ__Quote__c
        ]) {
            if (quoteIdToExistingMaxQuoteLineNumber.containsKey(existingQuoteLine.SBQQ__Quote__c)) {
                quoteIdToExistingMaxQuoteLineNumber.put(existingQuoteLine.SBQQ__Quote__c, returnMaxValue(quoteIdToExistingMaxQuoteLineNumber.get(existingQuoteLine.SBQQ__Quote__c),
                        existingQuoteLine.Real_Item_Number__c));
            } else {
                quoteIdToExistingMaxQuoteLineNumber.put(existingQuoteLine.SBQQ__Quote__c, existingQuoteLine.Real_Item_Number__c);
            }
        }

        // Select the max item number under every quote
        for (Id quoteId : quoteIdToQuoteLine.keySet()) {
            Decimal itemNumber = quoteIdToExistingMaxQuoteLineNumber.get(quoteId) != null ? quoteIdToExistingMaxQuoteLineNumber.get(quoteId) + 1 : 1;

            for (SBQQ__QuoteLine__c ql : quoteIdToQuoteLine.get(quoteId)) {
                ql.Real_Item_Number__c = itemNumber;
                itemNumber++;
            }
        }
    }

    /*------------------------------------------------------------
    Description: Small method for getting a max value
    ------------------------------------------------------------*/
    private Decimal returnMaxValue(Decimal value1, Decimal value2) {
        if (value1 > value2) {
            return value1;
        } else {
            return value2;
        }
    }


    // LEGACY CODE

    //Update Active Price Model with true when it matches sold to and product sku with
    //Active Price Model object recors
    private void updateActivePriceMode(List<SBQQ__QuoteLine__c> newQuoteLineitem) {
        List<String> soldtoProdSku = new List<String>();
        for (SBQQ__QuoteLine__c quoteLine : newQuoteLineitem) {
            if (quoteLine.Product_RecordType_DeveloperName__c == 'BGI_Product_SKU') {
                soldtoProdSku.add(quoteLine.Sold_To_Account_Id__c + quoteLine.Product_Id__c);
            } else {
                soldtoProdSku.add(quoteLine.Sold_To_Account_Id__c + quoteLine.Product_Id__c);
            }
        }
        //retrive Active Price Models data with sold and SKU combination
        List<CPQ_Active_Price_Model__c> activePriceListv = [
                SELECT Id, SoldtoProductSKU__c, Price_Model__c, Material_Numbers__c, SAP_Numbers__c
                FROM
                        CPQ_Active_Price_Model__c
                WHERE SoldtoProductSKU__c IN :soldtoProdSku
        ];

        Map<String, CPQ_Active_Price_Model__c> priceModelMap = new Map<String, CPQ_Active_Price_Model__c>();
        for (CPQ_Active_Price_Model__c PriceModel : activePriceListv) {
            priceModelMap.put(PriceModel.SoldtoProductSKU__c, PriceModel);
        }
        for (SBQQ__QuoteLine__c quoteLine : newQuoteLineitem) {

            if (priceModelMap.containsKey(quoteLine.Sold_To_Account_Id__c + quoteLine.Product_Id__c)) {
                //update it to true for Service line items
                if (priceModelMap.get(quoteLine.Sold_To_Account_Id__c + quoteLine.Product_Id__c).Price_Model__c == true) {
                    quoteLine.Active_Price_Model__c = true;
                } else {
                    quoteLine.Active_Price_Model__c = false;
                }
            }
        }
    }

    private void checkIfRecordsShouldBeBlocked(List<SBQQ__QuoteLine__c> oldQuoteLineitems) {

        for (SBQQ__QuoteLine__c ql : oldQuoteLineitems) {
            if (ql.Quote_Type__c == 'Amendment' && ql.SBQQ__Source__c != null) {
                ql.addError('You are not allowed to delete a Quote Line for the Amendment Quote.');
            }
        }
    }
}