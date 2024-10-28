trigger MeetingSummaryTrigger on Meeting_Notes__c (before insert, before update) {
	//add account to share with
    if(trigger.isBefore && trigger.isInsert){
        SRM_MeetingSummaryHandler.updateAccountToShareWith(trigger.new, new Map<id, Meeting_Notes__c>());
    }
	if(trigger.isBefore && trigger.isUpdate){
        SRM_MeetingSummaryHandler.updateAccountToShareWith(trigger.new, trigger.oldMap);
    }
}