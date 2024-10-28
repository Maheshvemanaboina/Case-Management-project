trigger SCAFTrigger on SCAF__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    SCAFTriggerHandler scafTrigHandler = new SCAFTriggerHandler();
    scafTrigHandler.process();
}