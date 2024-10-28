/*
* @Author : Shweta 
* @Date : 7th July 2021
* @Desc : Batch and Schedular class to automate the listings proces on a daily basis when 
          new listings are inserted from SAP to SF
* @Jira : SCPQ-1041
*/
global without sharing class ListingAutomationBatch implements Database.Batchable<sObject>,schedulable {
    
    public GeneralBatchSetting__c batchSettings = GeneralBatchSetting__c.getValues('ListingAutomationBatch');
     
    Public  Listing_Setting__c lstSetting = Listing_Setting__c.getValues('ListingAutomationBatch');
    public  List<String> outOfScopeSalesOrg = lstSetting.Sales_Orgs_Not_in_Scope__c.split(',');
        
/******************************************************************************
* Author : Shweta
* Date : 7th July 2021
* Description : This method is used to query all the listings that are inserted to the SF from SAP every morning
* Parameters : Database.BatchableContext
* Return : Database.QueryLocator
* *****************************************************************************/
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        String query = 'SELECT Active__c,Budget_SGP__c,CreatedDate,Commissions__c,External_Key__c,Id,Material__c,Name,Product__c,Rebates__c,Sales_Area__r.Sales_Organization__c,Product__r.Product_Code__c,Sales_Org__c,Sales_Price__c,SGP_PL__c,SGP__c,Sold_To_Account_Id__c,Sold_To_Account__c,Sold_To_Number__c,Transport_Insurance_Percent__c,Valid_from__c,Valid_Until__c,Warehouse_Cost__c FROM Listing__c WHERE Sales_Area__r.Sales_Organization__c NOT IN: outOfScopeSalesOrg';
        RETURN Database.getQueryLocator(query);
    }

/******************************************************************************
* Author : Shweta
* Date : 7th July 2021
* Description : This method will call the helper class where the listing values are updated
* Parameters : Database.BatchableContext, List of Listing__c
* Return : NA
* *****************************************************************************/
    global void execute(Database.BatchableContext bc, List<Listing__c> scope)
    {
        if(!scope.isEmpty()){
            
            ListingAutomationBatchHelper.updateListings(scope);
            ListingAutomationBatchHandler.updateListingsasActive(scope);
            ListingAutomationBatchHandler.deleteListings(scope);
        }
        
    }
    
/******************************************************************************
* Author : Shweta
* Date : 7th July 2021
* Description : This method will call the Utility class when the listing batch has been processed. 
                The email ids are fetched from the GeneralBatchSetting__c custom setting 
* Parameters : Database.BatchableContext
* Return : NA
* *****************************************************************************/
    global void finish(Database.BatchableContext bc)
    {
        If(batchSettings!=null){
        List<String> toAddresses = batchSettings.Batch_Email_Notifiers__c.split(',');
        Utilities.sendEmailNotificationOnBatchFinish('ListingAutomationBatch', bc, toAddresses);
        }
        if(test.isRunningTest()){
            Utilities.sendEmailOnBatchFinish('ListingAutomationBatch', bc);
        }
    }

/******************************************************************************
* Author : Shweta
* Date : 7th July 2021
* Description : This method will schedule the ListingAutomationBatch class to run on every morning at 9:30 AM  
* Parameters : System.SchedulableContext
* Return : NA
* Cron Expression : 0 0 6 1/1 * ? *
* *****************************************************************************/    
    global void execute(System.SchedulableContext sc){
        
        If(batchSettings!=null){
             
             ListingAutomationBatch com = new ListingAutomationBatch();
             Database.executeBatch(com, Integer.valueOf(batchSettings.Batch_Size__c)); 
        }
    }

}