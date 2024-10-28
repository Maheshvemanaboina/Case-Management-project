/*
    Author : Sibananda Bhuyan 10-02-2021
    Description : This class will be used to share Sales Performance as Batch
*/
global without sharing class SalesFunnelSharingBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator('SELECT Id,Sales_Funnel_Sales_To_End_Customer__c FROM Sales_Funnel__c');
    }

    global void execute(Database.BatchableContext bc, List<Sales_Funnel__c> salesFunnelList){
        
        SalesFunnelSharingUtility.deleteSalesPerformanceSharing( (new Map<Id,User>(UserUtility.getAllPartnerCommunityUsers())).keySet(), (new Map<Id,Sales_Funnel__c>(salesFunnelList)).keySet());
        SalesFunnelSharingUtility.initiateSalesFunnelSharing(UserUtility.getAllPartnerCommunityUsers(), salesFunnelList);
    }

    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('KPI Sharing Recalculation for Sales Performance', bc);

    }
}