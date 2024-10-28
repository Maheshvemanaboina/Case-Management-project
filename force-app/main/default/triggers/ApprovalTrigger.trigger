trigger ApprovalTrigger on sbaa__Approval__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ApprovalTriggerHandler approvalHandler = new ApprovalTriggerHandler();
    approvalHandler.process();
}