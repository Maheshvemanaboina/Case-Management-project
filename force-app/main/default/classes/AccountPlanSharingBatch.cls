/*
    Author : Sibananda Bhuyan 10-02-2021
    Description : This class will be used to share Account Plan as Batch
*/
global without sharing class AccountPlanSharingBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator('SELECT Id FROM Field_of_Play__c');
    }

    global void execute(Database.BatchableContext bc, List<Field_of_Play__c> accountPlanList){
        
        AccountPlanSharingUtility.deleteAccountPlanSharing( (new Map<Id,User>(UserUtility.getAllPartnerCommunityUsers())).keySet(), (new Map<Id,Field_of_Play__c>(accountPlanList)).keySet());
        AccountPlanSharingUtility.initiateAccountPlanSharing(UserUtility.getAllPartnerCommunityUsers(), accountPlanList);
    }

    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('KPI Sharing Recalculation for Account Plan', bc);

    }
}