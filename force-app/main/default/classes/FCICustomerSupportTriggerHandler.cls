/*
    Author : Sibananda Bhuyan 12-04-2020
    Description : This is a handler class for FCI Customer Support Object. This class extends the virtual TriggerHandler class which has all the below methods
    1. processBeforeInsert()
    2. processBeforeUpdate()
    3. processBeforeDelete()
    4. processAfterInsert()
    5. processAfterUpdate()
    6. processAfterDelete()

    These are all are virtual method
    NOTE : Please use any of the above methods and override them in the below class to use them. DO NOT ADD ANY OTHER METHOD BELOW
    
*/
public with sharing class FCICustomerSupportTriggerHandler extends TriggerHandler {
     
    public override void processAfterInsert(){
        FCICustomerSupportSharingUtility.shareAllFCICustomerSupprortAndKPIsWithCommunityUsers((List<FCI_Customer_Support__c>)trigger.new);
    	FCICustomerSupportScoringHandler.UpdateBucketTotalScore((List<FCI_Customer_Support__c>)trigger.new,null);
    }
    
    public override void processBeforeUpdate(){
        FCICustomerSupportScoringHandler.updateScore((List<FCI_Customer_Support__c>)trigger.new);
    }
    
    //Creted by Vijay for the purpose of calculating the total at main bucket level.
    // Created date: 19-10-2021
    public override void processAfterUpdate(){
        FCICustomerSupportScoringHandler.UpdateBucketTotalScore((List<FCI_Customer_Support__c>)trigger.new,(Map<Id,FCI_Customer_Support__c>)trigger.oldMap);
    }
    
    // Creted by Vijay for the purpose of calculating the total score at main bucket level
    // Created date: 19-10-2021
    public override void processAfterDelete(){
        FCICustomerSupportScoringHandler.UpdateBucketTotalScore(null,(Map<Id,FCI_Customer_Support__c>)trigger.oldMap);
    }
    public override void processBeforeDelete(){
        KpisDeleteValidator.validateCustomerSupport((List<FCI_Customer_Support__c>)trigger.old);        
    }
}