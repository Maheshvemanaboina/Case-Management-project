public with sharing class ApprovalTriggerHandler extends TriggerHandler {

    public override void processBeforeInsert() {
        ApprovalTriggerHandlerHelper.populateSLAfield((List<sbaa__Approval__c>) Trigger.new);
        // NEWC-2409 - avoid duplicate approval records
        ApprovalTriggerHandlerHelper.validateApprovalRecord((List<sbaa__Approval__c>) Trigger.new);
    }
}