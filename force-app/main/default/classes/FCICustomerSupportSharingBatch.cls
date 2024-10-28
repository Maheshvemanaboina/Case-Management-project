/*
    Author : Sibananda Bhuyan 10-02-2021
    Description : This class will be used to share FCI Customer Support as Batch
*/
global without sharing class FCICustomerSupportSharingBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator('SELECT Id,FCI_Customer_Support_Order_Process__c FROM FCI_Customer_Support__c');
    }

    global void execute(Database.BatchableContext bc, List<FCI_Customer_Support__c> fciCustomerSupportList){
        
        FCICustomerSupportSharingUtility.deleteFCICustomerSupportSharing( (new Map<Id,User>(UserUtility.getAllPartnerCommunityUsers())).keySet(), (new Map<Id,FCI_Customer_Support__c>(fciCustomerSupportList)).keySet());
        FCICustomerSupportSharingUtility.initiateFCICustomerSupportSharing(UserUtility.getAllPartnerCommunityUsers(), fciCustomerSupportList);
    }

    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('KPI Sharing Recalculation for FCI Customer Support', bc);

    }
}