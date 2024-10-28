@isTest
private class childLeadCreationControllerTest {

    @testSetup
    static void setup(){
       TriggerHandler.skipTrigger = true;

       Campaign cmp = new Campaign(); 
       cmp.Business_Segment__c = 'Adult Nutrition';
       cmp.Sub_Segment__c = 'Active Nutrition';
       cmp.Name = 'test manual cmp';
       insert cmp;  

       ID leadRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Master_Lead').getRecordTypeId(); 
       ID conRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BGI_Contact').getRecordTypeId(); 

       Lead leadRecord = new Lead(
            Company = 'IMCD Italy',
            FirstName = 'test lead 1',
            Phone = '+919876543212',
            Email = 'testchildlead@test.com',
            LastName = 'last name 1',
            Country = 'India',
            Region__c = 'APAC',
            RecordTypeId = leadRecordType
       );
       insert leadRecord;

       Child_Lead__c testChildLead = new Child_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Child Lead',
            Company__c = 'IMCD Italy',
            Email__c = 'testchildlead@test.com',
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true
        );
        insert testChildLead;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testchildlead@test.com',
            Active__c = true,
            RecordTypeId = conRecordType
        );
        insert testContact;

        TriggerHandler.skipTrigger = false;
    }

    @isTest
    static void testCheckChildLead() {
        String cmpID = [select id from campaign where Name = 'test manual cmp'].id;
        Child_Lead__c childLead = [select id,Email__c from Child_Lead__c where email__c = 'testchildlead@test.com'];
        childLead.Campaign_Name__c = cmpID;
        update childLead;
        List<Child_Lead__c> result = LeadCreationController.checkChildLead(childLead.Email__c,cmpID);
        System.assertEquals(1, result.size());
        System.assertEquals(childLead.Id, result[0].Id);
    }

    @isTest
    static void testCheckMasterLead() {
        String cmpID = [select id from campaign where Name = 'test manual cmp'].id;
        Lead masterLead = [select id,Email from lead where email = 'testchildlead@test.com'];
        List<Lead> result = LeadCreationController.checkMasterLead(masterLead.Email);
        System.assertEquals(1, result.size());
        System.assertEquals(masterLead.Id, result[0].Id);
    }

    @isTest
    static void testCheckContact() {
        contact testContact = [select id,email from contact where email = 'testchildlead@test.com' ];
        List<Contact> result = LeadCreationController.checkContact(testContact.Email);
        System.assertEquals(1, result.size());
        System.assertEquals(testContact.Id, result[0].Id);
    }

    @isTest
    static void testAfterChildLeadCreationProcess() {
        String cmpID = [select id from campaign where Name = 'test manual cmp'].id;
        Child_Lead__c testChildLead = new Child_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Child Lead',
            Company__c = 'Test Company',
            Email__c = 'testchildlead2@test.com',
            Campaign_Name__c = cmpID,
            Phone__c = '1234567890',
            Active__c = true
        );
        insert testChildLead;

        ChildLeadWrapper testWrapper = new ChildLeadWrapper();
        testWrapper.firstName = 'Test';
        testWrapper.lastName = 'Lead';          
        testWrapper.email = 'testlead2@test.com';
        testWrapper.company = 'Test Company';
        testWrapper.phone = '1234567890';
        testWrapper.campaignId= cmpID;
        boolean masterLeadCreated = LeadCreationController.afterChildLeadCreationProcess(testWrapper, testChildLead.id);
        List<Lead> result = [select id,company from lead where email = 'testchildlead2@test.com'];
        System.assertEquals(true, masterLeadCreated);
        //System.assertEquals(testChildLead.Company__c, result[0].Company);
        try{
           LeadCreationController.afterChildLeadCreationProcess(testWrapper,'inavlidId');
        }catch(AuraHandledException  ex){
             System.debug('error message'+ex.getMessage());
             System.assert(ex.getMessage().contains('Script-thrown exception'));
             return;
        }
    }

    @isTest
    static void testChildLeadlink() {
        String cmpID = [select id from campaign where Name = 'test manual cmp'].id;
        List<Child_Lead__c> childLead = [select id from Child_Lead__c where email__c = 'testchildlead@test.com'];
        List<Lead> masterLead = [select id from lead where email = 'testchildlead@test.com'];
        boolean childLeadLinked= LeadCreationController.linkChildLeadWithLead(cmpID,childLead[0].id,masterLead[0].id);
        List<campaign> campaign =  LeadCreationController.getCampaignInfo(cmpID);
        System.assertEquals(true, childLeadLinked);
        try{
           LeadCreationController.linkChildLeadWithLead('inavlidId','inavlidId','inavlidId');
        }catch(AuraHandledException  ex){
             System.debug('error message'+ex.getMessage());
             System.assert(ex.getMessage().contains('Script-thrown exception'));
             return;
        }
    }

    @isTest
    static void testChildLeadlinkWithContact() {
        String cmpID = [select id from campaign where Name = 'test manual cmp'].id;
        List<Child_Lead__c> childLead = [select id from Child_Lead__c where email__c = 'testchildlead@test.com'];
        List<contact> contact = [select id from contact where email = 'testchildlead@test.com'];
        boolean childLeadLinked= LeadCreationController.linkChildLeadWithContact(cmpID,childLead[0].id,contact[0].id,null);
        LeadCreationController.createDebugLogRecord(childLead[0].id,'Test Error','Test StackTrace','Link childlead');
        List<DebugLog__c> debuglog = [select id,RecordId__c from DebugLog__c /*where Message__c ='Test Error'*/];
        System.assertEquals(true, childLeadLinked);
        System.assertEquals(childLead[0].id, debuglog[0].RecordId__c);
         try{
           LeadCreationController.linkChildLeadWithContact('inavlidId','','','');
        }catch(AuraHandledException  ex){
             System.debug('error message'+ex.getMessage());
             System.assert(ex.getMessage().contains('Script-thrown exception'));
             return;
        }
    }
    
    @isTest
    static void testChildLeadActivation() {
        Child_Lead__c childLead = [select id from Child_Lead__c where email__c = 'testchildlead@test.com' limit 1];
		childLead.Active__c = false;
        update childLead;
        LeadCreationController.activateLeadInterestRecord(childLead.id);
        Child_Lead__c cl = [select id,Active__c from Child_Lead__c where id = :childLead.id ];
        System.assertEquals(true, cl.Active__c);
        try{
           LeadCreationController.activateLeadInterestRecord('inavlidId');
        }catch(AuraHandledException  ex){
             System.debug('error message'+ex.getMessage());
             System.assert(ex.getMessage().contains('Script-thrown exception'));
             return;
        }
    }

}