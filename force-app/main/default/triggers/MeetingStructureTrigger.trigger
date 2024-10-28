trigger MeetingStructureTrigger on Meeting_Structure__c (before insert, before update) {
    //add account to share with
    if(trigger.isBefore && trigger.isInsert){
        SRM_MeetingStructureHandler.updateAccountToShareWith(trigger.new, new Map<id, Meeting_Structure__c>());
    }
	if(trigger.isBefore && trigger.isUpdate){
        SRM_MeetingStructureHandler.updateAccountToShareWith(trigger.new, trigger.oldMap);
    }

}