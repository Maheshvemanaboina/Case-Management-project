public with sharing class ApprovalSLABatch implements Database.Batchable<sObject> {

    private Boolean testDMLError = false;

    public ApprovalSLABatch() {}

    public ApprovalSLABatch(Boolean testDMLError) {
        this.testDMLError = testDMLError;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        Datetime now = Datetime.now();

        return Database.getQueryLocator([
                SELECT
                        Id, sbaa__Status__c, SLA_Start_Date__c, SLA_End_Date__c, sbaa__RecordField__c,
                        sbaa__Approver__c, sbaa__AssignedTo__c, sbaa__Approver__r.Escalation_Approver__c,
                        sbaa__Approver__r.Escalation_Approver__r.sbaa__User__c, sbaa__Rule__c,
                        sbaa__Rule__r.sbaa__RequestTemplate__r.sbaa__TemplateId__c,
                        sbaa__ApprovalStep__c, Quote__c, sbaa__Actions__c, sbaa__ApprovalChain__c, sbaa__ApprovalTemplateId__c,
                        sbaa__Archived__c, sbaa__RecallTemplateId__c, sbaa__RejectionTemplateId__c, sbaa__RequestTemplateId__c,
                        sbaa__RequireExplicitApproval__c, sbaa__Unanimous__c, sbaa__Approver__r.Escalation_Approver__r.SLA_Value__c
                FROM
                        sbaa__Approval__c
                WHERE
                        SLA_End_Date__c <= :now
                        AND sbaa__Approver__r.Escalation_Approver__c != NULL
                        AND  sbaa__Status__c = 'Requested' 
        ]);
    }

    public void execute(Database.BatchableContext bc, List<sbaa__Approval__c> scope) {
        List<Messaging.SendEmailResult> sendEmailResults = new List<Messaging.SendEmailResult>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        EmailServicesAddress emailServicesAddress = [SELECT DeveloperName, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName = 'approval_services'];
        String emailAddress = emailServicesAddress.DeveloperName + '@' + emailServicesAddress.EmailDomainName;

        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Help Desk Support  Hours'];
        
        for (sbaa__Approval__c approval : scope) {


            approval.sbaa__Approver__c = approval.sbaa__Approver__r.Escalation_Approver__c;
            approval.sbaa__AssignedTo__c = approval.sbaa__Approver__r.Escalation_Approver__r.sbaa__User__c;
            approval.SLA_End_Date__c = BusinessHours.add(bh.Id, Datetime.now(), (Integer) (approval.sbaa__Approver__r.Escalation_Approver__r.SLA_Value__c) * 3600000);
            approval.Was_escalated__c = true;

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.setTemplateId(approval.sbaa__Rule__r.sbaa__RequestTemplate__r.sbaa__TemplateId__c);
            message.setTargetObjectId(approval.sbaa__AssignedTo__c);
            message.setReplyTo(emailAddress);
            message.setSenderDisplayName('Salesforce Request');
            message.setWhatId(approval.Id);
            message.setSaveAsActivity(false);
            emailMessages.add(message);

            if (testDMLError) {
                approval.sbaa__RecordField__c = null;
            }
        }

        try {
            update scope;
            sendEmailResults = Messaging.sendEmail(emailMessages);
        } catch (Exception ex) {
            String comment = 'Failed during updating sbaa__Approval__c records in ApprovalSLABatch';
            Utilities.generateDebugLogsForErrorHandling(ex, scope, comment);
        }

    }

    public void finish(Database.BatchableContext bc) {}

}