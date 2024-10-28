/*
    Author : Sibananda Bhuyan 10-02-2021
    Description : This class will be used to share Forecast Accuracy as Batch
*/
global without sharing class ForecastAccuracySharingBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator('SELECT Id,Forecast_Accuracy_Local_Stock__c FROM Forecast_Accuracy__c');
    }

    global void execute(Database.BatchableContext bc, List<Forecast_Accuracy__c> forecastAccuracyList){
        
        ForecastAccuracySharingUtility.deleteForecastAccuracySharing( (new Map<Id,User>(UserUtility.getAllPartnerCommunityUsers())).keySet(), (new Map<Id,Forecast_Accuracy__c>(forecastAccuracyList)).keySet());
        ForecastAccuracySharingUtility.initiateForecastAccuracySharing(UserUtility.getAllPartnerCommunityUsers(), forecastAccuracyList);
    }

    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('KPI Sharing Recalculation for Forecast Accuracy', bc);

    }
}