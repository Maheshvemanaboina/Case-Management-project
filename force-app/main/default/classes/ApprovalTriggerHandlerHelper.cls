public with sharing class ApprovalTriggerHandlerHelper {

    public static void populateSLAfield(List<sbaa__Approval__c> approvalsNew) {

        Map<Id, Id> approvalToApproverMap = new Map<Id, Id>();
        Map<Id, sbaa__Approver__c> approverMap;
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Help Desk Support  Hours'];

        for (sbaa__Approval__c appr : approvalsNew) {
            approvalToApproverMap.put(appr.Id, appr.sbaa__Approver__c);
        }

        Set<Id> approverIds = new Set<Id>(approvalToApproverMap.values());

        approverMap = new Map<Id, sbaa__Approver__c>([SELECT Id, SLA_Value__c FROM sbaa__Approver__c WHERE Id IN :approverIds]);

        for (sbaa__Approval__c appr : approvalsNew) {
            if (approvalToApproverMap.get(appr.Id) != null && approverMap.get(approvalToApproverMap.get(appr.Id)).SLA_Value__c != null) {
                appr.SLA_Start_Date__c = Datetime.now();
                appr.SLA_End_Date__c = BusinessHours.add(bh.Id, Datetime.now(), (Integer) approverMap.get(approvalToApproverMap.get(appr.Id)).SLA_Value__c * 3600000);
            }
        }
    }

    public static void validateApprovalRecord(List<sbaa__Approval__c> approvalsNew) {
        Set<Id> approvalQuoteIds = new Set<Id>();
        Map<String,String> approvalConditionsQuoteIdMap = new Map<String,String>();
        // validate the inserting list - can contain duplicates
        for (sbaa__Approval__c approvalRecord : approvalsNew) {
            String approvalConditionsKey = approvalRecord.Quote__c + '|' + approvalRecord.sbaa__Approver__c + '|' + approvalRecord.sbaa__Rule__c;
            String quoteId = approvalConditionsQuoteIdMap.get(approvalConditionsKey);
            if (String.isNotBlank(quoteId)) {
                approvalRecord.addError('Inserting duplicated approval record: same Approver and Rule');
            }
            else {
                approvalConditionsQuoteIdMap.put(approvalConditionsKey, approvalRecord.Quote__c);
            }
            approvalQuoteIds.add(approvalRecord.Quote__c);
        }
        // validate existing records for duplicated approvals
        Map<String,List<sbaa__Approval__c>> approvalConditionsPendingApprovalsMap = new Map<String,List<sbaa__Approval__c>>();
        List<sbaa__Approval__c> existingPendingApprovals = [SELECT Id, Quote__c, sbaa__Approver__c, sbaa__Rule__c, sbaa__Status__c FROM sbaa__Approval__c WHERE Quote__c IN :approvalQuoteIds and (sbaa__Status__c='Assigned' or sbaa__Status__c='Requested')];
        if (existingPendingApprovals != null && existingPendingApprovals.size() > 0) {
            for (sbaa__Approval__c existingPendingApproval : existingPendingApprovals) {
                String approvalConditionsKey = existingPendingApproval.Quote__c + '|' + existingPendingApproval.sbaa__Approver__c + '|' + existingPendingApproval.sbaa__Rule__c;
                List<sbaa__Approval__c> quotePendingApprovals = approvalConditionsPendingApprovalsMap.get(approvalConditionsKey);
                if (quotePendingApprovals != null) {
                    quotePendingApprovals.add(existingPendingApproval);
                }
                else {
                    approvalConditionsPendingApprovalsMap.put(approvalConditionsKey, new List<sbaa__Approval__c>{existingPendingApproval});
                }
            }
        }
        for (sbaa__Approval__c insertingApproval : approvalsNew) {
            String approvalConditionsKey = insertingApproval.Quote__c + '|' + insertingApproval.sbaa__Approver__c + '|' + insertingApproval.sbaa__Rule__c;
            List<sbaa__Approval__c> quotePendingApprovals = approvalConditionsPendingApprovalsMap.get(approvalConditionsKey);
            if (quotePendingApprovals != null && quotePendingApprovals.size() > 0) {
                insertingApproval.addError('Inserting duplicated approval record: same Approver and Rule');
            }
        }
    }
}