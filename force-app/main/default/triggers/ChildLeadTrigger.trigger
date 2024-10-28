trigger ChildLeadTrigger on Child_Lead__c (after insert, before insert, after update) {
    ChildLeadTriggerHandler leadTrg = new ChildLeadTriggerHandler();
    leadTrg.process();
}