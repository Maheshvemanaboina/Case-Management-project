/*
    Author : Sibananda Bhuyan 10-02-2021
    Description : This class will be used to share Commercial Activities as Batch
*/
global without sharing class CommercialActivitySharingBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator('SELECT Id,Commercial_Activity_Promotion_Activity__c, Commercial_Activity_Customer_Visit__c, Commercial_Activity_Sample__c FROM Commercial_Activity__c');
    }

    global void execute(Database.BatchableContext bc, List<Commercial_Activity__c> commercialActivityList){
        
        CommercialActivitySharingUtility.deleteCommercialActivitySharing( (new Map<Id,User>(UserUtility.getAllPartnerCommunityUsers())).keySet(), (new Map<Id,Commercial_Activity__c>(commercialActivityList)).keySet());
        CommercialActivitySharingUtility.initiateComActivitySharing(UserUtility.getAllPartnerCommunityUsers(), commercialActivityList);
    }

    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('KPI Sharing Recalculation for Commercial Activity', bc);

    }
}