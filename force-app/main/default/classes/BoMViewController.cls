/*------------------------------------------------------------
Author:       Lilith Van Biesen
Company:      Waeg
Description:  Apex Controller for the BoM View Lightning Component.

History
v1.0       2019-11-12    Lilith Van Biesen    Created class
------------------------------------------------------------*/

public with sharing class BoMViewController {
    
    public static final String PRODUCT_MATERIAL_RECORD_TYPE_DEVELOPER_NAME = 'Product_Material';

    //Retrieve parent Quote Line fields.
    @AuraEnabled
    public static SBQQ__QuoteLine__c getParentQuoteLine(String quotelineId){
        
        SBQQ__QuoteLine__c line = new SBQQ__QuoteLine__c();
        if(quotelineId != null && quotelineId != 'undefined'){
            line = [
                SELECT Id, SBQQ__ProductName__c, Product_Type__c, SBQQ__Quote__r.CurrencyIsoCode, 
                	convertCurrency(Total_COGS_MP__c), convertCurrency(Total_COGS_MP_Last__c),
                	convertCurrency(Total_COGS_PP_Current__c), convertCurrency(SGP_MP_Current__c),
                	convertCurrency(SGP_MP_Last__c), convertCurrency(SGP_PP__c) 
                FROM SBQQ__QuoteLine__c
                WHERE Id = :quotelineId
                ORDER BY SBQQ__Number__c ASC
        	];
        }
        return line;
    }
    
    //Retrieve the child Quote Lines with the relevant BOM fields.
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getChildQuoteLines(String quotelineId){
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        if(quotelineId != null && quotelineId != 'undefined'){
            lines = [
                SELECT Id, SBQQ__ProductName__c, convertCurrency(MP_Last_Time_Quoted__c), 
                	convertCurrency(New_MP__c), convertCurrency(Cost_Price_MP__c),
                	convertCurrency(MP_Cost_Price_Last_Time_Quoted__c), 
            		convertCurrency(PP_Current_Quote__c), convertCurrency(Cost_Price_PP__c), 
               		Delta_Ingredient_Price__c, Delta_Weighted_Ingr_Price__c,isContractRateApplied__c
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__RequiredBy__c = :quotelineId AND Product_RecordType_DeveloperName__c = :PRODUCT_MATERIAL_RECORD_TYPE_DEVELOPER_NAME
                ORDER BY SBQQ__Number__c ASC
        	];
        }
        return lines;
    }
}