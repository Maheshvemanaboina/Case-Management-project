trigger QuoteBeforeTrigger on SBQQ__Quote__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new CPQQuoteTriggerHandler().run();
}