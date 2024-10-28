trigger LSDProductGroupTrigger on LSD_Product__c (before insert,before update,after insert,after update,after delete) {

    if(trigger.isbefore && trigger.isInsert){
        LSDProductGroupHandler.addLookupOnLSDProductGroupBeforeInsert(trigger.New);
    }
    if(trigger.isBefore && trigger.isUpdate){
        LSDProductGroupHandler.addLookupOnLSDProductGroupBeforeUpdate(trigger.oldMap, trigger.newMap);
    }
}