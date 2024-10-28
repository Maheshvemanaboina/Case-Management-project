/*
    Author : Sibananda Bhuyan 10-02-2021
    Description : This class will be used to share Business Strategies as Batch
*/
global without sharing class BusinessStrategySharingBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator('SELECT Id,Business_Strategy_High_Low_Lights__c, Business_Strategy_Competition__c FROM Business_Strategy__c');
    }

    global void execute(Database.BatchableContext bc, List<Business_Strategy__c> businessStrategyList){
        
        BusinessStrategySharingUtility.deleteBusinessStrategySharing( (new Map<Id,User>(UserUtility.getAllPartnerCommunityUsers())).keySet(), (new Map<Id,Business_Strategy__c>(businessStrategyList)).keySet());
        BusinessStrategySharingUtility.initiateBusinessStrategySharing(UserUtility.getAllPartnerCommunityUsers(), businessStrategyList);
    }

    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('KPI Sharing Recalculation for Business Strategy', bc);

    }
}