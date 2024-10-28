/*
    Author : Sibananda Bhuyan 15-04-2020
    Description : This is a handler class for Business Strategy Object. This class extends the virtual TriggerHandler class which has all the below methods
    1. processBeforeInsert()
    2. processBeforeUpdate()
    3. processBeforeDelete()
    4. processAfterInsert()
    5. processAfterUpdate()
    6. processAfterDelete()

    These all are virtual method
    NOTE : Please use any of the above methods and override them in the below class to use them. DO NOT ADD ANY OTHER METHOD BELOW
    
*/
public with sharing class BusinessStrategyTriggerHandler extends TriggerHandler {
     
    public override void processAfterInsert(){
        BusinessStrategySharingUtility.shareBusinessStrategyWithCommunityUsers((List<Business_Strategy__c>)trigger.new);
        BusinessStrategyScoringHandler.UpdateBucketTotalScore((List<Business_Strategy__c>)trigger.new,null);
    }
    
    public override void processBeforeUpdate(){
        BusinessStrategyScoringHandler.updateScore((List<Business_Strategy__c>)trigger.new);        
    }
    
    //Creted by Vijay for the purpose of calculating the total at main bucket level.
    // Created date: 19-10-2021
    public override void processAfterUpdate(){
        BusinessStrategyScoringHandler.UpdateBucketTotalScore((List<Business_Strategy__c>)trigger.new,(Map<Id,Business_Strategy__c>)trigger.oldMap);
    }
    
    // Creted by Vijay for the purpose of calculating the total score at main bucket level
    // Created date: 19-10-2021
    public override void processAfterDelete(){
        BusinessStrategyScoringHandler.UpdateBucketTotalScore(null,(Map<Id,Business_Strategy__c>)trigger.oldMap);
    }
    public override void processBeforeDelete(){
        KpisDeleteValidator.validateBusinessStrategy((List<Business_Strategy__c>)trigger.old);        
    }
}