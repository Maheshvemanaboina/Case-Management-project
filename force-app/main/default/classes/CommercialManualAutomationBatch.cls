/*
* @Author : Shweta 
* @Date : 26th June 2021
* @Desc : Batch and Schedular class to automate the manual work of updating the commercial manual prices by shifting above on every month end
* @Jira : SCPQ-1026
*/
global without sharing class CommercialManualAutomationBatch implements Database.Batchable<sObject>,schedulable { 
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query='SELECT External_Key__c,Floor_Price_M00__c,Floor_Price_M01__c,Floor_Price_M02__c,Floor_Price_M03__c,Floor_Price_M04__c,Floor_Price_M05__c,Floor_Price_M06__c,Floor_Price_M07__c,Floor_Price_M08__c,Floor_Price_M09__c,Floor_Price_M10__c,Floor_Price_M11__c,Id,List_Price_M00__c,List_Price_M01__c,List_Price_M02__c,List_Price_M03__c,List_Price_M04__c,List_Price_M05__c,List_Price_M06__c,List_Price_M07__c,List_Price_M08__c,List_Price_M09__c,List_Price_M10__c,List_Price_M11__c,Name,Product_Code__c,Product__c FROM Commercial_Manual__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<Commercial_Manual__c> scope){
        CommercialManualAutomationBatchHandler.updateCommercialManual(scope);
    }
    global void finish(Database.BatchableContext bc){
       
        GeneralBatchSetting__c batchSettings = GeneralBatchSetting__c.getValues('CommercialManualAutomationBatch');
        List<String> toAddresses = batchSettings.Batch_Email_Notifiers__c.split(',');
        Utilities.sendEmailNotificationOnBatchFinish('CommercialManualAutomationBatch', bc, toAddresses);
        if(test.isRunningTest()){
            Utilities.sendEmailOnBatchFinish('CommercialMannualAutomationBatch', bc);
        }
    }
    global void execute(System.SchedulableContext sc){
        GeneralBatchSetting__c batchSetting = GeneralBatchSetting__c.getValues('CommercialManualAutomationBatch');
        
        If(batchSetting!=null){
             
             CommercialManualAutomationBatch com = new CommercialManualAutomationBatch();
             Database.executeBatch(com, Integer.valueOf(batchSetting.Batch_Size__c));
        }
        
    }
}