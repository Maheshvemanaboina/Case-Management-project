/*
    Author : Sibananda Bhuyan 15-04-2020
    Description : This is a handler class for Other Related Customer Location Object. This class extends the virtual TriggerHandler class which has all the below methods
    1. processBeforeInsert()
    2. processBeforeUpdate()
    3. processBeforeDelete()
    4. processAfterInsert()
    5. processAfterUpdate()
    6. processAfterDelete()

    These all are virtual method
    NOTE : Please use any of the above methods and override them in the below class to use them. DO NOT ADD ANY OTHER METHOD BELOW
    
*/
public with sharing class RelatedCustomerLocationsTriggerHandler extends TriggerHandler {
     
    public override void processAfterInsert(){

        RelatedCustomerLocationSharingUtility.shareKPIsOnRelatedCustLocCreate((List<Other_Related_Customer_Location__c>)trigger.new);
        //AccountPlanSharingUtility.shareAccountPlanWithRelatedCustomerLocations((List<Other_Related_Customer_Location__c>)trigger.new);
        // RelatedCustomerLocationSharingUtility.shareAccountPlanWithRelatedCustomerLocations((List<Other_Related_Customer_Location__c>)trigger.new);
    	RelatedCustomerLocationSharingUtility.shareAccountsOnRelatedCustLocCreate((List<Other_Related_Customer_Location__c>)trigger.new);
        RelatedCustomerLocationSharingUtility.assignOrRemovePermissionSet((List<Other_Related_Customer_Location__c>)trigger.new);
    }

    public override void processBeforeDelete(){

        RelatedCustomerLocationSharingUtility.deleteKPISharingOnRelCustLocDelete((List<Other_Related_Customer_Location__c>)trigger.Old);
        //RelatedCustomerLocationSharingUtility.recalculateAccountSharingOnRelatedCustLocUpdateOrDelete((List<Other_Related_Customer_Location__c>)trigger.Old);
    }
    
    public override void processAfterDelete(){
        RelatedCustomerLocationSharingUtility.recalculateAccountSharingOnRelatedCustLocUpdateOrDelete((List<Other_Related_Customer_Location__c>)trigger.Old);
        RelatedCustomerLocationSharingUtility.assignOrRemovePermissionSet((List<Other_Related_Customer_Location__c>)trigger.old);
    }

}