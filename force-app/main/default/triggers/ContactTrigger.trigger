trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	 /* if((trigger.isbefore && trigger.isUpdate) || (trigger.isbefore && trigger.isInsert)){
        restrictDuplicateEmailContact.findDuplicate(trigger.new,Trigger.oldMap);
    }*/
    ContactTriggerHandler ConTrig = new ContactTriggerHandler();
    ConTrig.process();
}