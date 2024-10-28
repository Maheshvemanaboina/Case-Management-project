/**
 * FcpTop20KeyAccountsControllerTest class is created to cover all test class scenarios of FcpTop20KeyAccountsController class.
 * Created By :   Charan K.
 * Crated Date :  20/09/2024.
 */@IsTest
public class FcpTop20KeyAccountsControllerTest {
    @testSetup
    static void setupTestData() {
        Account parentAccount = new Account( Name = 'Parent Account', BillingCity = 'San Francisco', BillingCountry = 'United States of America', SAP_Number__c = '12345' );
        insert parentAccount;
        // Create Account records
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                FCP_Top_20_KA__c = true,
                BillingCity = 'San Francisco',
                BillingCountry = 'United States of America',
                SAP_Number__c = '12345'+ i,
                ParentId = parentAccount.Id
            );
            accounts.add(acc);
        }
        insert accounts;
        
        // Create related data
        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opportunities = new List<Opportunity>();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        List<Visit_Report__c> visitReports = new List<Visit_Report__c>();
        List<Field_of_Play__c> accountPlans = new List<Field_of_Play__c>();
        List<Case> cases = new List<Case>();
        List<Task> tasks = new List<Task>();
        List<Call_Notes__c> callNotes = new List<Call_Notes__c>();
        
        insert contacts;
        insert opportunities;
        insert quotes;
        insert visitReports;
        insert accountPlans;
        insert cases;
        insert tasks;
        insert callNotes;
        
        Account testAccount = new Account(Name = 'Test Account File', BillingCity = 'San Francisco',BillingCountry = 'United States of America');
        insert testAccount;
       ContentVersion testContentVersion = new ContentVersion(
            Title = 'Top 20 Key Accounts Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test Data'),
            FirstPublishLocationId = testAccount.Id,
            ContentLocation = 'S'
        );
        insert testContentVersion;
        //ContentDocument testContentDocument = [SELECT Id FROM ContentDocument WHERE Id = :testContentVersion.ContentDocumentId LIMIT 1];
    }
    
    @isTest
    static void testGetTop20KeyAccounts() {
        Test.startTest();
        List<FcpTop20KeyAccountsController.AccountWrapper> result = FcpTop20KeyAccountsController.getTop20KeyAccounts();
        Test.stopTest();
    }

    @isTest
    static void testRelatedDataMethods() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        String accountId = accounts[0].Id;
        
        Test.startTest();
        List<Contact> contacts = FcpTop20KeyAccountsController.getContactsByAccountId(accountId);

        List<Opportunity> opportunities = FcpTop20KeyAccountsController.getOpportunitiesByAccountId(accountId);

        List<SBQQ__Quote__c> quotes = FcpTop20KeyAccountsController.getQuotesByAccountId(accountId);

        List<Visit_Report__c> preVisitReports = FcpTop20KeyAccountsController.getPreVisitReportsByAccountId(accountId);
        
        List<Visit_Report__c> finalVisitReports = FcpTop20KeyAccountsController.getFinalVisitReportsByAccountId(accountId);
        
        List<Contract> contracts = FcpTop20KeyAccountsController.getContractsByAccountId(accountId);
 
        List<Account> accountPlans = FcpTop20KeyAccountsController.getAccountPlansByAccountId(accountId);

        List<Case> cases = FcpTop20KeyAccountsController.getCasesByAccountId(accountId);

        List<Task> tasks = FcpTop20KeyAccountsController.getTasksByAccountId(accountId);

        List<Call_Notes__c> callNotes = FcpTop20KeyAccountsController.getCallNotesByAccountId(accountId);

        List<Task> activities = FcpTop20KeyAccountsController.getActivitiesByAccountId(accountId);
        
        Test.stopTest();
    }
    
    @isTest
    static void testSaveFile() {
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test Data'));
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id contentVersionId = FcpTop20KeyAccountsController.saveFile(
            'TestFile.pdf',
            base64Data,
            'application/pdf',
            testAccount.Id
        );

        ContentVersion resultContentVersion = [SELECT Id, Title, FirstPublishLocationId FROM ContentVersion WHERE Id = :contentVersionId LIMIT 1];
    }

    @isTest
    static void testGetFiles() {
        List<ContentVersion> contentVersions = FcpTop20KeyAccountsController.getFiles();

    }
    @isTest
    static void testDeleteFile() {
        ContentDocument testContentDocument = [SELECT Id FROM ContentDocument LIMIT 1];
        FcpTop20KeyAccountsController.deleteFile(testContentDocument.Id);
        List<ContentDocument> deletedContentDocuments = [SELECT Id FROM ContentDocument WHERE Id = :testContentDocument.Id];
        System.assertEquals(0, deletedContentDocuments.size());
    }
}