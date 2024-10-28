/*
    Author : Sibananda Bhuyan 12-04-2020
    Description : This is a handler class for Forecast Accuract Object. This class extends the virtual TriggerHandler class which has all the below methods
    1. processBeforeInsert()
    2. processBeforeUpdate()
    3. processBeforeDelete()
    4. processAfterInsert()
    5. processAfterUpdate()
    6. processAfterDelete()

    These are all are virtual method
    NOTE : Please use any of the above methods and override them in the below class to use them. DO NOT ADD ANY OTHER METHOD BELOW
    
*/
public with sharing class ForecastAccuracyTriggerHandler extends TriggerHandler {
     
    public override void processAfterInsert(){
        ForecastAccuracySharingUtility.shareAllForecastsAndKPIsWithCommunityUsers((List<Forecast_Accuracy__c>)trigger.new);
        ForecastAccuracyScoringHandler.UpdateBucketTotalScore((List<Forecast_Accuracy__c>)trigger.new,null);
    }
    
     public override void processBeforeUpdate(){
        ForecastAccuracyScoringHandler.updateScore((List<Forecast_Accuracy__c>)trigger.new);
    }
    
    //Creted by Vijay for the purpose of calculating the total at main bucket level.
    // Created date: 19-10-2021
    public override void processAfterUpdate(){
        ForecastAccuracyScoringHandler.UpdateBucketTotalScore((List<Forecast_Accuracy__c>)trigger.new,(Map<Id,Forecast_Accuracy__c>)trigger.oldMap);
    }
    
    // Creted by Vijay for the purpose of calculating the total score at main bucket level
    // Created date: 19-10-2021
    public override void processAfterDelete(){
        ForecastAccuracyScoringHandler.UpdateBucketTotalScore(null,(Map<Id,Forecast_Accuracy__c>)trigger.oldMap);
    }
    public override void processBeforeDelete(){
        KpisDeleteValidator.validateForecastAccuracy((List<Forecast_Accuracy__c>)trigger.old);        
    }
	
}