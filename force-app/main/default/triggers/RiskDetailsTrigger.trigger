trigger RiskDetailsTrigger on Risk__c (before insert, before update, after insert) {
	if(trigger.isBefore && trigger.isInsert){
        SRM_RiskDetailTriggerHandler.updateAccountToShareWith(trigger.new, new Map<id, Risk__c>());
       
    }
	if(trigger.isBefore && trigger.isUpdate){
        SRM_RiskDetailTriggerHandler.updateAccountToShareWith(trigger.new, trigger.oldMap);
        SRM_RiskDetailTriggerHandler.updateClosedTimeStamp(trigger.new, trigger.oldMap);
        
    }
    if(trigger.isAfter && trigger.isInsert){
         SRM_RiskDetailTriggerHandler.sendEmailsToSupplierTeamMembers(trigger.new);
    }
}