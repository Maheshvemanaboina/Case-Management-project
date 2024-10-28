/*
    Author : Sibananda Bhuyan 15-04-2020
    Description : This is a handler class for Account Plan Object. This class extends the virtual TriggerHandler class which has all the below methods
    1. processBeforeInsert()
    2. processBeforeUpdate()
    3. processBeforeDelete()
    4. processAfterInsert()
    5. processAfterUpdate()
    6. processAfterDelete()

    These all are virtual method
    NOTE : Please use any of the above methods and override them in the below class to use them. DO NOT ADD ANY OTHER METHOD BELOW
    
*/

public with sharing class AccountPlanTriggerHandler extends TriggerHandler {
     
    public override void processAfterInsert(){
        AccountPlanSharingUtility.shareAccountPlanWithCommunityUsers((List<Field_of_Play__c>)trigger.new);
    }
    
    public override void processBeforeUpdate(){
        AccountPlanScoringHandler.updateScore((List<Field_of_Play__c>)trigger.new,(Map<Id,Field_of_Play__c>)trigger.oldMap);
    }
}