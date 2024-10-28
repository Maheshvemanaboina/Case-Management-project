/***************************************************************************************************************************************
* @Author : Shweta 
* @Date : 7th July 2021
* @Desc : Handler class for ListingAutomationBatch which updates the Listing values such as warehouse cost on daily basis when 
          new listings are inserted from SAP to SF
* @Jira : SCPQ-1041
*History
*Sr No.   Modified By      Modified Date         Ticket  no.        Description
* 1       Shweta           22/07/2021            SCPQ-1053          Calculating the Rebate value from the Rebate Danone and Rebate Overview Objects based 
                                                                    on the respective combinations as part of the user story SCPQ-1053
* 2       Shweta           03/08/2021            SCPQ-1062          Populating the Transport Insurance and Other(Other, Interest, Bank, Credit) costs from
                                                                    the Listing Setting Custom Setting.
* 3       Shweta           06/08/2021            SCPQ-1059          Calculating the Commission value from the Commissions A855,A854 & A809 and Commissions A852 & A853 Objects based 
                                                                    Objects based on the respective combinations as part of the user story SCPQ-1059
******************************************************************************************************************************************/
public without sharing class ListingAutomationBatchHelper {
    
    // PROPERTIES //
    @testVisible
    private static Boolean throwException = false;
    
/******************************************************************************
* Author : Shweta
* Date : 7th July 2021
* Description : This method is used to update the Warehouse Cost, Rebate values for all the listings that are inserted to the SF from SAP every morning
* Parameters : List of Listing__c
* Return : NA
* *****************************************************************************/
    public static void updateListings(List<Listing__c> newLists){
        
        Map<String,Rebate_Danone__c> danoneMap = new Map<String,Rebate_Danone__c>();
        Map<String,Rebate_Overview__c> overviewMap = new Map<String,Rebate_Overview__c>();
        Map<String,Commission_A852_A853__c> commissionA852Map = new Map<String,Commission_A852_A853__c>();
        Map<String,Commission_A855_A854_A809__c> commissionA855Map = new Map<String,Commission_A855_A854_A809__c>();
        Map<String,CPQ_Budget_SGP__c> budgetSGPMap = new Map<String,CPQ_Budget_SGP__c>();
        List<String> danoneKeyList = new List<String>();
        List<String> overviewKeyList = new List<String>();
        List<String> commKeyList = new List<String>();
        List<String> commercialKeyList = new List<String>();
        List<String> budgetSGPKeyList = new List<string>();
        List<Listing__c> updateListingList = new List<Listing__c>();
        //This will store the Rebate Danone keys and Rebate Overview Keys in the lists - SCPQ-1053
        //This will store the commission Keys in the lists - SCPQ-1059
        //This will store the Budget SGP keys in the List -SCPQ-1061
        for(Listing__c lists : newLists){
            
           danoneKeyList.add(lists.Sales_Area__r.Sales_Organization__c+''+lists.Sold_To_Number__c);
           overviewKeyList.add(lists.Sales_Area__r.Sales_Organization__c+''+lists.Sold_To_Number__c+''+lists.Product__r.Product_Code__c); 
           commKeyList.add(lists.Sales_Area__r.Sales_Organization__c+''+lists.Sold_To_Number__c);
           commercialKeyList.add(lists.Sales_Area__r.Sales_Organization__c+''+lists.Sold_To_Number__c+''+lists.Product__r.Product_Code__c);
           budgetSGPKeyList.add(lists.Sales_Area__r.Sales_Organization__c+''+lists.Product__r.Product_Code__c+''+lists.Sold_To_Number__c);
        }
        
        //This will populate the Rebate Danone Key and Rebate Danone record in the Map - SCPQ-1053
        for(Rebate_Danone__c rb : [Select Id, Rebate_Danone_Key__c,Rebate_Value__c,Customer__c FROM Rebate_Danone__c Where Rebate_Danone_Key__c IN: danoneKeyList ]){
            
            if(rb!=null){
               if(!danoneMap.containsKey(rb.Rebate_Danone_Key__c)){
               danoneMap.put(rb.Rebate_Danone_Key__c,rb); 
               }
            }
        }
        
        //This will populate the Rebate Overview Key and Rebate Overview record in the Map - SCPQ-1053
        for(Rebate_Overview__c ro : [SELECT Id, Product_code__c,Rebate_Overview_Key__c,Rebate_Overview_Value__c,Sales_Org__c,Sold_To_Account_Number__c FROM Rebate_Overview__c WHERE Rebate_Overview_Key__c IN:overviewKeyList]){
            
            if(ro!=null){
                if(!overviewMap.containsKey(ro.Rebate_Overview_Key__c)){
                    overviewMap.put(ro.Rebate_Overview_Key__c,ro);  
                }
            }
        }
        
        //This will populate the Commission Key and Commission_A852_A853__c record in the Map - SCPQ-1059
        for(Commission_A852_A853__c com : [Select Id, Key__c,Sales_Org__c,Sold_To_Account_Number__c,Commission_Amount__c FROM Commission_A852_A853__c Where Key__c IN: commKeyList ]){
            
            if(com!=null){
               if(!commissionA852Map.containsKey(com.Key__c)){
               commissionA852Map.put(com.Key__c,com); 
               }
            }
        }
        
        //This will populate the Commisssion Key and Commission_A855_A854_A809__c record in the Map - SCPQ-1059
        for(Commission_A855_A854_A809__c com : [Select Id, Commission_Key__c,Product_code__c,Sales_Org__c,Sold_To_Account_Number__c,Amount__c FROM Commission_A855_A854_A809__c Where Commission_Key__c IN: commercialKeyList ]){
            
            if(com!=null){
               if(!commissionA855Map.containsKey(com.Commission_Key__c)){
               commissionA855Map.put(com.Commission_Key__c,com); 
               }
            }
        }
        
        //This will populate the Budget SGP Key and Budget SGP record in the Map - SCPQ-1061
        for(CPQ_Budget_SGP__c com : [Select Id, CPQ_Budget_SGP_Key__c,Product_code__c,Sales_Org__c,Sold_To_Account_Number__c,SGP_KG__c FROM CPQ_Budget_SGP__c Where CPQ_Budget_SGP_Key__c IN: budgetSGPKeyList ]){
            
            if(com!=null){
               if(!budgetSGPMap.containsKey(com.CPQ_Budget_SGP_Key__c)){
               budgetSGPMap.put(com.CPQ_Budget_SGP_Key__c,com); 
               }
            }
        }
        
        //This will update the listing values in the Listing record - SCPQ-1053
        if(!newLists.isEmpty())
        {
            for(Listing__c lists : newLists)
            {
              String salesOrgSoldToKey =  lists.Sales_Area__r.Sales_Organization__c+''+lists.Sold_To_Number__c;
              String salesOrgSoldToProductCodeKey = lists.Sales_Area__r.Sales_Organization__c+''+lists.Sold_To_Number__c+''+lists.Product__r.Product_Code__c;
              String salesOrgProductCodeSoldToKey = lists.Sales_Area__r.Sales_Organization__c+''+lists.Product__r.Product_Code__c+''+lists.Sold_To_Number__c;
              
              Listing_Setting__c lstSetting = Listing_Setting__c.getValues('ListingAutomationBatch');
              Listing__c ls = new Listing__c();
                ls = lists;
                ls.Warehouse_Cost__c = lstSetting.Warehouse_Cost__c;
                ls.Transport_Insurance_Percent__c = lstSetting.Transport_insurance_costs__c;
                ls.Other_Other_Interest_Bank_Credit__c = lstSetting.Other_other_interest_bank_credit__c;
                
                //The Rebate value in Listing is assigned with Rebate Danone and Rebate Overview values based on the respective conditions - SCPQ-1053
                if(danoneMap.get(salesOrgSoldToKey)!=null && (danoneMap.get(salesOrgSoldToKey).Rebate_Value__c!=null && danoneMap.get(salesOrgSoldToKey).Rebate_Value__c!= 0) ){
                    System.debug('danoneKey ' + danoneMap.get(salesOrgSoldToKey) + danoneMap.get(salesOrgSoldToKey).Rebate_Value__c);
                    ls.Rebates__c = Math.abs(danoneMap.get(salesOrgSoldToKey).Rebate_Value__c);
                }
                else If(overviewMap.get(salesOrgSoldToProductCodeKey)!=null && (overviewMap.get(salesOrgSoldToProductCodeKey).Rebate_Overview_Value__c!= null && overviewMap.get(salesOrgSoldToProductCodeKey).Rebate_Overview_Value__c!= 0) ){
                    ls.Rebates__c = Math.abs(overviewMap.get(salesOrgSoldToProductCodeKey).Rebate_Overview_Value__c);
                }else{
                    
                    ls.Rebates__c = 0;
                }
                //The Commission value in Listing is assigned with Commissions A855,A854 & A809 and Commissions A852 & A853 values based on the respective conditions -SCPQ-1059
                if(commissionA852Map.get(salesOrgSoldToKey)!=null && (commissionA852Map.get(salesOrgSoldToKey).Commission_Amount__c!=null && commissionA852Map.get(salesOrgSoldToKey).Commission_Amount__c!= 0) ){
                    
                    ls.Commissions__c = Math.abs(commissionA852Map.get(salesOrgSoldToKey).Commission_Amount__c);
                }
                else If(commissionA855Map.get(salesOrgSoldToProductCodeKey)!=null && (commissionA855Map.get(salesOrgSoldToProductCodeKey).Amount__c!= null && commissionA855Map.get(salesOrgSoldToProductCodeKey).Amount__c!= 0) ){
                    ls.Commissions__c = Math.abs(commissionA855Map.get(salesOrgSoldToProductCodeKey).Amount__c);
                }else{
                    
                    ls.Commissions__c = 0;
                }
                //The Rebate value in Listing is assigned with Budget SGP values based on the respective conditions - SCPQ-1061
                if(budgetSGPMap.get(salesOrgProductCodeSoldToKey)!=null && (budgetSGPMap.get(salesOrgProductCodeSoldToKey).SGP_KG__c!=null && budgetSGPMap.get(salesOrgProductCodeSoldToKey).SGP_KG__c!= 0) ){
                    
                    ls.Budget_SGP__c = budgetSGPMap.get(salesOrgProductCodeSoldToKey).SGP_KG__c;
                }else{
                    
                    ls.Budget_SGP__c = 0;
                }
              
                updateListingList.add(ls);
                
            }
            
            if(updateListingList.size()>0 && !updateListingList.isEmpty())
            {
                try{
                    
                    Database.update(updateListingList);
                    // In case of testing, throw an exception //
                if ( throwException ) throw new NullPointerException();
                    
                }
                catch(Exception stackedError){
                    
                    String comment = 'Failed while attempting to update the Listing values';
                    Utilities.generateDebugLogsForErrorHandling(stackedError, updateListingList, comment);
                }
            }
        }
    }
}