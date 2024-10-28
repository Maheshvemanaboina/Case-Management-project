@isTest
public with sharing class ApprovalTriggerHandlerTest {

    @TestSetup
    private static void dataSetup() {
        Account accobj = TestUtility.createAccount('FCI Test 1');
        insert accobj; 
        Account accobj2 = TestUtility.createAccount('Test 2');
        accobj2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId();
        insert accobj2; 
        
        Opportunity opp = TestUtility.createOpportunity('testOppname', Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID, accobj, accobj2);
        opp.Name = 'Clone Test Opp';
        opp.OwnerId = UserInfo.getUserId();
        opp.CloseDate = System.today();
        insert opp;
        System.assertEquals(System.today(),opp.CloseDate);
        // Create a test product //
        List<Product2> testProducts = DataFactoryTest.getProductSKUs(2);

        Database.insert(testProducts);

        Pricebook2 priceBookObj = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
        );
        Database.update(priceBookObj);

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 prod : testProducts) {
            pricebookEntries.add(new PricebookEntry(UnitPrice = 0.01, Product2Id = prod.Id, Pricebook2Id = priceBookObj.Id,
                    IsActive = true, UseStandardPrice = false));
        }
        Database.insert(pricebookEntries);

        Sales_Area__c salesArea = new Sales_Area__c(
                Sales_Organization__c = '5953',
                Customer_Name__c = opp.AccountId,
                Active__c        = true
        );
        Database.insert(salesArea);
        List<SBQQ__Quote__c> testQuotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
                OwnerId                 = opp.OwnerId,
                SBQQ__Account__c        = opp.AccountId,
                SBQQ__Opportunity2__c   = opp.Id,
                SBQQ__PricebookId__c    = priceBookObj.Id,
                SBQQ__Primary__c        = true,
                SBQQ__PrimaryContact__c = opp.ContactId,
                Sales_Area__c           = salesArea.Id,
                EffectiveDate__c        = System.today(),
                SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
                SBQQ__StartDate__c      = System.today().addMonths( 2 ),
                SBQQ__EndDate__c        = System.today().addMonths( 3 )
        );
        testQuotes.add(testQuote);
        // SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c(
        //         OwnerId                 = opp.OwnerId,
        //         SBQQ__Account__c        = opp.AccountId,
        //         SBQQ__Opportunity2__c   = opp.Id,
        //         SBQQ__PricebookId__c    = priceBookObj.Id,
        //         SBQQ__PrimaryContact__c = opp.ContactId,
        //         Sales_Area__c           = salesArea.Id,
        //         EffectiveDate__c        = System.today(),
        //         SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
        //         SBQQ__StartDate__c      = System.today().addMonths( 2 ),
        //         SBQQ__EndDate__c        = System.today().addMonths( 3 )
        // );
        // testQuotes.add(testQuote2);
        Database.insert(testQuotes);

        sbaa__Approver__c approver = new sbaa__Approver__c();
        approver.SLA_Value__c = 16;
        approver.ExternalID__c = '001';
        insert approver;

        sbaa__ApprovalRule__c approvalRule = new sbaa__ApprovalRule__c();
        approvalRule.Name = 'ApprovalRule1';
        approvalRule.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        approvalRule.ExternalID__c = 'EXTID001';
        insert approvalRule;
        
        sbaa__ApprovalRule__c approvalRule2 = new sbaa__ApprovalRule__c();
        approvalRule2.Name = 'ApprovalRule2';
        approvalRule2.sbaa__TargetObject__c = 'SBQQ__Quote__c';
        approvalRule2.ExternalID__c = 'EXTID002';
        insert approvalRule2;
    }

    @IsTest
    private static void testScenario1() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Help Desk Support  Hours'];
        sbaa__Approval__c approval = new sbaa__Approval__c();
        approval.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
        approval.sbaa__ApprovalStep__c = 1;
        approval.sbaa__RecordField__c = 'Quote__c';
        insert approval;

        sbaa__Approval__c approvalAfterUpdate = [SELECT SLA_Start_Date__c, SLA_End_Date__c FROM sbaa__Approval__c LIMIT 1];

        System.assertEquals(Datetime.now(), approvalAfterUpdate.SLA_Start_Date__c);
        System.assertEquals(BusinessHours.add(bh.Id, Datetime.now(), 16 * 3600000), approvalAfterUpdate.SLA_End_Date__c);
    }

    @IsTest
    private static void testInsertingDuplicatedApprovals() {
        sbaa__ApprovalRule__c approvalRule = [select Id from sbaa__ApprovalRule__c where ExternalID__c = 'EXTID001'];
        SBQQ__Quote__c quoteRecord = [SELECT Id FROM SBQQ__Quote__c limit 1];
        List<sbaa__Approval__c> approvalsToInsert = new List<sbaa__Approval__c>();
        sbaa__Approval__c approval1 = new sbaa__Approval__c();
        approval1.Quote__c = quoteRecord.Id;
        approval1.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
        approval1.sbaa__ApprovalStep__c = 1;
        approval1.sbaa__RecordField__c = 'Quote__c';
        approval1.sbaa__Rule__c = approvalRule.Id;
        approvalsToInsert.add(approval1);
        sbaa__Approval__c approval2 = new sbaa__Approval__c();
        approval2.Quote__c = quoteRecord.Id;
        approval2.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
        approval2.sbaa__ApprovalStep__c = 1;
        approval2.sbaa__RecordField__c = 'Quote__c';
        approval2.sbaa__Rule__c = approvalRule.Id;
        approvalsToInsert.add(approval2);

        Boolean exceptionHappened = false;
        Test.startTest();
        try {
            insert approvalsToInsert;
        }
        catch(Exception ex) {
            if (ex.getMessage().contains('Inserting duplicated approval record: same Approver and Rule')){
                exceptionHappened = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, exceptionHappened);
    }


    @IsTest
    private static void testInsertingNonDuplicatedApprovals() {
        sbaa__ApprovalRule__c approvalRule = [select Id from sbaa__ApprovalRule__c where ExternalID__c = 'EXTID001'];
        sbaa__ApprovalRule__c approvalRule2 = [select Id from sbaa__ApprovalRule__c where ExternalID__c = 'EXTID002'];
        SBQQ__Quote__c quoteRecord = [SELECT Id FROM SBQQ__Quote__c limit 1];
        List<sbaa__Approval__c> approvalsToInsert = new List<sbaa__Approval__c>();
        sbaa__Approval__c approval1 = new sbaa__Approval__c();
        approval1.Quote__c = quoteRecord.Id;
        approval1.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
        approval1.sbaa__ApprovalStep__c = 1;
        approval1.sbaa__RecordField__c = 'Quote__c';
        approval1.sbaa__Rule__c = approvalRule.Id;
        approvalsToInsert.add(approval1);
        sbaa__Approval__c approval2 = new sbaa__Approval__c();
        approval2.Quote__c = quoteRecord.Id;
        approval2.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
        approval2.sbaa__ApprovalStep__c = 1;
        approval2.sbaa__RecordField__c = 'Quote__c';
        approval2.sbaa__Rule__c = approvalRule2.Id;
        approvalsToInsert.add(approval2);

        Boolean exceptionHappened = false;
        Test.startTest();
        try {
            insert approvalsToInsert;
        }
        catch(Exception ex) {
            if (ex.getMessage().contains('Inserting duplicated approval record: same Approver and Rule')){
                exceptionHappened = true;
            }
        }
        Test.stopTest();
        System.assertEquals(false, exceptionHappened);
    }


    @IsTest
    private static void testInsertingDuplicatedApprovalsAfterAnother() {
        sbaa__ApprovalRule__c approvalRule = [select Id from sbaa__ApprovalRule__c where ExternalID__c = 'EXTID001'];
        SBQQ__Quote__c quoteRecord = [SELECT Id FROM SBQQ__Quote__c limit 1];
        List<sbaa__Approval__c> approvalsToInsert = new List<sbaa__Approval__c>();
        sbaa__Approval__c approval1 = new sbaa__Approval__c();
        approval1.Quote__c = quoteRecord.Id;
        approval1.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
        approval1.sbaa__ApprovalStep__c = 1;
        approval1.sbaa__RecordField__c = 'Quote__c';
        approval1.sbaa__Rule__c = approvalRule.Id;
        insert approval1;

        Boolean exceptionHappened = false;
        Test.startTest();
        try {
            sbaa__Approval__c approval2 = new sbaa__Approval__c();
            approval2.Quote__c = quoteRecord.Id;
            approval2.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
            approval2.sbaa__ApprovalStep__c = 1;
            approval2.sbaa__RecordField__c = 'Quote__c';
            approval2.sbaa__Rule__c = approvalRule.Id;
            insert approval2;
        }
        catch(Exception ex) {
            if (ex.getMessage().contains('Inserting duplicated approval record: same Approver and Rule')){
                exceptionHappened = true;
            }
        }
        Test.stopTest();
        System.assertEquals(true, exceptionHappened);
    }


    @IsTest
    private static void testInsertingNonDuplicatedApprovalsAfterAnother() {
        sbaa__ApprovalRule__c approvalRule = [select Id from sbaa__ApprovalRule__c where ExternalID__c = 'EXTID001'];
        sbaa__ApprovalRule__c approvalRule2 = [select Id from sbaa__ApprovalRule__c where ExternalID__c = 'EXTID002'];
        SBQQ__Quote__c quoteRecord = [SELECT Id FROM SBQQ__Quote__c limit 1];
        List<sbaa__Approval__c> approvalsToInsert = new List<sbaa__Approval__c>();
        sbaa__Approval__c approval1 = new sbaa__Approval__c();
        approval1.Quote__c = quoteRecord.Id;
        approval1.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
        approval1.sbaa__ApprovalStep__c = 1;
        approval1.sbaa__RecordField__c = 'Quote__c';
        approval1.sbaa__Rule__c = approvalRule.Id;
        insert approval1;

        Boolean exceptionHappened = false;
        Test.startTest();
        try {
            sbaa__Approval__c approval2 = new sbaa__Approval__c();
            approval2.Quote__c = quoteRecord.Id;
            approval2.sbaa__Approver__c = [SELECT Id FROM sbaa__Approver__c LIMIT 1].Id;
            approval2.sbaa__ApprovalStep__c = 1;
            approval2.sbaa__RecordField__c = 'Quote__c';
            approval2.sbaa__Rule__c = approvalRule2.Id;
            insert approval2;
        }
        catch(Exception ex) {
            if (ex.getMessage().contains('Inserting duplicated approval record: same Approver and Rule')){
                exceptionHappened = true;
            }
        }
        Test.stopTest();
        System.assertEquals(false, exceptionHappened);
    }
}