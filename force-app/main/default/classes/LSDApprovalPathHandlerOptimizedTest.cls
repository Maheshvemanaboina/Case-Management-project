@IsTest
public class LSDApprovalPathHandlerOptimizedTest {

    @IsTest
    public static void testGetApprovalDataApproved() {
        // Skip triggers during setup
        TriggerHandler.skipTrigger = true;

        // Create and insert a commercial customer account
        Account commercialCust = TestUtility.createCommercialCustomer('H1 IMCD Holding');
        insert commercialCust;

        // Create and insert a customer location for the commercial customer
        Account custLoc = TestUtility.createCustomerLocation(commercialCust);
        insert custLoc;

        // Create and insert legal sales documents
        Legal_Sales_Document__c legalSales = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id, 10000000);
        legalSales.RecordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_With_Deviation').getRecordTypeId();
        insert legalSales;

        legalSales.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
        update legalSales;

        Legal_Sales_Document__c legalSales1 = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id, 11000000);
        legalSales1.RecordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_With_Deviation').getRecordTypeId();
        insert legalSales1;

        Legal_Sales_Document__c legalSales2 = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id, 12000000);
        insert legalSales2;

        // Create and insert approval matrix
        LSD_Approval_Matrix__c approvalMatrix = new LSD_Approval_Matrix__c(
            Business_Group__c = 'Asia',
            Leading_Business_Segment__c = 'Philippines',
            FC_Legal_Entity__c = 'Alaska Milk Corporation'
        );
        insert approvalMatrix;

        // Create and insert a legal user
        User legalUser = new User(
            FirstName = 'Legal',
            LastName = 'User',
            Email = 'legaluser@example.com',
            Username = 'legaluser@example.com',
            Alias = 'luser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'][0].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert legalUser;

        // Create and insert SCAF record
        SCAF__c scafRecord = TestUtility.getSCAFInstance(legalSales.Id);
        scafRecord.Approval_Levels_Required__c = 1;
        scafRecord.Legal__c = legalUser.Id;
        scafRecord.Business_Group__c = approvalMatrix.Business_Group__c;
        scafRecord.Leading_Business_Segment__c = approvalMatrix.Leading_Business_Segment__c;
        scafRecord.FC_Legal_Entity__c = 'Dutch Lady Milk Industries Berhad';
        scafRecord.is_scaf_already_approved__c = true;
        scafRecord.Non_Summit_OpCo__c = true;
        scafRecord.RecordTypeId = Schema.SObjectType.SCAF__c.getRecordTypeInfosByDeveloperName().get('Submission_of_approval_request_SCAF').getRecordTypeId();
        insert scafRecord;

        scafRecord.FC_Legal_Entity__c = approvalMatrix.FC_Legal_Entity__c;
        update scafRecord;

        // Resume triggers
        TriggerHandler.skipTrigger = false;

        // Invoke the method to test
        LegalSalesApprovalPathHandlerOptimized.getApprovalPathData(scafRecord.Id);

        // Create and insert an approval request
        User user1 = [SELECT Id FROM User WHERE profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(scafRecord.Id);
        req1.setSubmitterId(user1.Id);
        Approval.process(req1);

        // Approve the request
        ProcessInstanceWorkitem pItem = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :scafRecord.Id LIMIT 1];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request for SCAF');
        req.setAction('Approve');
        req.setWorkitemId(pItem.Id);
        Approval.process(req);

        // Update the SCAF record with different approval levels
        Test.startTest();
        scafRecord.Approval_Levels_Required__c = 6;
        scafRecord.Finance_Director__c = legalUser.Id;
        scafRecord.Managing_Director__c = legalUser.Id;
        scafRecord.Business_Group_Finance_Director__c = legalUser.Id;
        scafRecord.Business_Group_President__c = legalUser.Id;
        scafRecord.Company_Secretary__c = legalUser.Id;
        update scafRecord;

        LegalSalesApprovalPathHandlerOptimized.getApprovalPathData(scafRecord.Id);

        SCAF__c scafRecord1 = new SCAF__c(Approval_Levels_Required__c = 1, Id = scafRecord.Id);
        update scafRecord1;
        LegalSalesApprovalPathHandlerOptimized.getApprovalPathData(scafRecord1.Id);

        SCAF__c scafRecord3 = new SCAF__c(Approval_Levels_Required__c = 3, Id = scafRecord1.Id);
        update scafRecord3;
        LegalSalesApprovalPathHandlerOptimized.getApprovalPathData(scafRecord3.Id);

        SCAF__c scafRecord5 = new SCAF__c(Approval_Levels_Required__c = 5, Id = scafRecord3.Id);
        update scafRecord5;
        LegalSalesApprovalPathHandlerOptimized.getApprovalPathData(scafRecord5.Id);

        SCAF__c scafRecordRejectedAndUpdatedScaf = new SCAF__c(Approval_Levels_Required__c = 5, Id = scafRecord3.Id);
        scafRecordRejectedAndUpdatedScaf.RejectedAndUpdatedScaf__c = true;
        update scafRecordRejectedAndUpdatedScaf;
        LegalSalesApprovalPathHandlerOptimized.getApprovalPathData(scafRecordRejectedAndUpdatedScaf.Id);

        Test.stopTest();
    }
}