@isTest
public with sharing class ApprovalSLABatchTest {

    @TestSetup
    private static void dataSetup() {
        sbaa__Approver__c approver1 = new sbaa__Approver__c();
        approver1.SLA_Value__c = 16;
        approver1.ExternalID__c = '001';
        approver1.Name = 'Approver1';
        insert approver1;

        sbaa__Approver__c approver2 = new sbaa__Approver__c();
        approver2.SLA_Value__c = 16;
        approver2.ExternalID__c = '002';
        approver2.Escalation_Approver__c = approver1.Id;
        approver2.Name = 'Approver2';
        insert approver2;

        sbaa__Approval__c approval1 = new sbaa__Approval__c();
        approval1.sbaa__Approver__c = approver2.Id;
        approval1.sbaa__ApprovalStep__c = 1;
        approval1.sbaa__RecordField__c = 'Quote__c';
        approval1.sbaa__Status__c = 'Requested';
        insert approval1;

        approval1.SLA_Start_Date__c = Datetime.now().addDays(-10);
        approval1.SLA_End_Date__c = Datetime.now().addDays(-5);
        update approval1;
    }

    @IsTest
    private static void testScenario1() {
        sbaa__Approval__c approval = [SELECT Id, sbaa__Approver__r.Name FROM sbaa__Approval__c LIMIT 1];

        System.assertEquals('Approver2', approval.sbaa__Approver__r.Name);

        Test.startTest();
        Database.executeBatch(new ApprovalSLABatch());
        Test.stopTest();

        approval = [SELECT Id, sbaa__Approver__r.Name FROM sbaa__Approval__c WHERE Id = :approval.Id LIMIT 1];

        System.assertEquals('Approver1', approval.sbaa__Approver__r.Name);
    }

    @IsTest
    private static void testScenario2() {
        Test.startTest();
        Database.executeBatch(new ApprovalSLABatch(true));
        Test.stopTest();

        DebugLog__c debug = [SELECT Comments__c FROM DebugLog__c LIMIT 1];

        System.assertEquals('Failed during updating sbaa__Approval__c records in ApprovalSLABatch', debug.Comments__c);
    }

    @IsTest
    private static void testScenario3() {
        String cron = '0 0 23 * * ? *';

        Test.startTest();
        String jobId = System.schedule('ApprovalSLAScheduleJob_Test', cron, new ApprovalSLAScheduleJob());

        CronTrigger ct = [
                SELECT Id, CronExpression
                FROM CronTrigger
                WHERE Id = :jobId ];
        Test.stopTest();

        System.assertEquals(cron, ct.CronExpression);
    }

}