public with sharing class SCAFTriggerHandler extends TriggerHandler {
    
    public override void processBeforeUpdate(){
        SCAFHandler.validateAutoExtension((List<SCAF__c>)Trigger.new, (Map<Id,SCAF__c>)Trigger.OldMap);
    }
}