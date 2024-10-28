trigger LSDTrigger on Legal_Sales_Document__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    LSDTriggerHandler lsdTrigHandler = new LSDTriggerHandler();
    lsdTrigHandler.process();
}