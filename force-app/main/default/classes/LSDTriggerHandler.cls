public with sharing class LSDTriggerHandler extends TriggerHandler {
    
    
    public override void processBeforeUpdate(){
        LSDHandler.validateAutoExtension((List<Legal_Sales_Document__c>)Trigger.new, (Map<Id,Legal_Sales_Document__c>)Trigger.OldMap);
    }
}