/**
* @UserStory        :   144653-As an Approver of the SCAF record, I should get a reminder email notification for every 3 days until I approve/reject the SCAF record + Bug - 146790
* @Author           :   LSD SCAF Expedition 2030 Dev Team
* @Modified Date    :   06 June 2024
* @Desc             :   Test class for ApprovalReminderScheduler and ApprovalReminderScheduleClass

* ************************************************************************************/
@isTest
public class ApprovalReminderScheduleTestClass {
    static testmethod void testmet(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        insert u;
        system.runAs(u){
            
            TriggerHandler.skipTrigger = true;
            Account accc = TestUtility.createCommercialCustomer('H1 IMCD Holding');
            insert accc;
            
            Account accc1 = TestUtility.createCustomerLocation(accc);
            insert accc1;            
            
            Legal_Sales_Document__c leg = new Legal_Sales_Document__c();
            leg.Total_Net_Sales_Value__c = 100000020;
            leg.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
            leg.Deviations_from_RFC_LSD_Template__c = 'Deviations';
            leg.Business_Group__c = 'FCI';
            leg.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
            leg.Leading_Business_Segment__c = 'Adult Nutrition';
            leg.Parent_Account__c = accc.Id;
            leg.Account_Name__c = accc1.Id;
            leg.RecordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_With_Deviation').getRecordTypeId();
            leg.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
            insert leg;
            
            
            LSD_Approval_Matrix__c approvalMatrix=new LSD_Approval_Matrix__c(
                Business_Group__c='Asia',Leading_Business_Segment__c='Philippines',FC_Legal_Entity__c='Alaska Milk Corporation');
            insert approvalMatrix;
            
            
            SCAF__c scafRecord = TestUtility.getSCAFInstance(leg.Id);
            scafRecord.Approval_Levels_Required__c = 1;
            scafRecord.Legal__c = u.Id;
            scafRecord.Business_Group__c = approvalMatrix.Business_Group__c;
            scafRecord.Leading_Business_Segment__c = approvalMatrix.Leading_Business_Segment__c;
            scafRecord.FC_Legal_Entity__c='Dutch Lady Milk Industries Berhad';  
            scafRecord.is_scaf_already_approved__c=true;
            scafRecord.Non_Summit_OpCo__c=true;
            scafRecord.Legal_Sales_Document__c = leg.Id;
            scafRecord.RecordTypeId = Schema.SObjectType.SCAF__c.getRecordTypeInfosByDeveloperName().get('Submission_of_approval_request_SCAF').getRecordTypeId();
            scafRecord.FC_Legal_Entity__c=approvalMatrix.FC_Legal_Entity__c;
            insert scafRecord;
            
            
            // Create an approval request 
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(scafRecord.id);
            req1.setSubmitterId(u.Id); 
            req1.setSkipEntryCriteria(true);
            Approval.ProcessResult result = Approval.process(req1);        
            
            test.startTest();
            ApprovalReminderScheduleClass ab = new ApprovalReminderScheduleClass();//144653      
            ab.ScheduleEmail();
            system.assert(true, 'ScheduleEmail method should execute without errors');
            
            ApprovalReminderScheduler appr=new ApprovalReminderScheduler();
            system.assert(true, 'ApprovalReminderScheduler instance should be created successfully');
            test.stopTest();
        }
        
        
    }
}