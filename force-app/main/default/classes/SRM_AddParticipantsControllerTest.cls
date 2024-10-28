@isTest
private class SRM_AddParticipantsControllerTest {
	@testSetup static void setup() {
        // Create records to test
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        
        Meeting_Structure__c obj = new Meeting_Structure__c();
        obj.Supplier_Hub_Number__c = supplierHub.Id;
        obj.Frequency_of_the_Meeting__c = 'Weekly';
        obj.Name= 'Weekly Meeting';
        obj.Type__c = 'External';
        insert obj;
        
        Meeting_Notes__c objNotes = new Meeting_Notes__c();
        objNotes.Meeting_Date__c= date.today();
        objNotes.Meeting_Structure__c = obj.id;
        objNotes.Meeting_Type__c = 'Relationship building';
        objNotes.Name = 'Test meeting note - Created via Meeting Notes';
        objNotes.Supplier_Hub_Number__c= supplierHub.Id;
        objNotes.Type__c= 'External';
        insert objNotes;
    }
    @isTest static void testMethod1() {
        system.debug('count '+[SELECT count() from Supplier_Hub__c]);
        Meeting_Notes__c objNote= [SELECT Id, Type__c FROM Meeting_Notes__c limit 1];
        Meeting_Structure__c objStructure = [select id from Meeting_Structure__c limit 1];
        SRM_AddParticipantsController.getMeetingParticipates(objStructure.Id, objStructure.Id);
    }
    @isTest static void udpateMeetingNotes() {
        Meeting_Notes__c objNote= [SELECT Id, Type__c FROM Meeting_Notes__c limit 1];
        objNote.Type__c= 'Internal';
        update objNote;
    }
    @isTest static void udpateMeetingStructure() {
        Meeting_Structure__c objNote= [SELECT Id, Type__c FROM Meeting_Structure__c limit 1];
        objNote.Type__c= 'Internal';
        update objNote;
    }
    
    @isTest static void getMeetingStructureParticipants() {
        system.debug('count '+[SELECT count() from Supplier_Hub__c]);
        Meeting_Notes__c objNote= [SELECT Id, Type__c FROM Meeting_Notes__c limit 1];
        Meeting_Structure__c objStructure = [select id from Meeting_Structure__c limit 1];
        
        Meeting_Participants__c strucureParticipant = new Meeting_Participants__c();
        strucureParticipant.User__c= userinfo.getUserId();
        strucureParticipant.Meeting_Structure__c= objStructure.Id;
        strucureParticipant.Type__c= 'External';
        insert strucureParticipant;
        
        
        Participants__c objSummaryParticipant = new Participants__c();
        objSummaryParticipant.User__c= userinfo.getUserId();
        objSummaryParticipant.Type__c= 'Internal';
        objSummaryParticipant.Meeting_Summary__c= objNote.Id;
        insert objSummaryParticipant;
        
        SRM_AddParticipantsController.getMeetingParticipates(objStructure.Id, objNote.Id);
    }
    
    @isTest static void cretaeparticipants() {
        system.debug('count '+[SELECT count() from Supplier_Hub__c]);
        Meeting_Notes__c objNote= [SELECT Id, Type__c FROM Meeting_Notes__c limit 1];
        Meeting_Structure__c objStructure = [select id from Meeting_Structure__c limit 1];
        
        Meeting_Participants__c strucureParticipant = new Meeting_Participants__c();
        strucureParticipant.User__c= userinfo.getUserId();
        strucureParticipant.Meeting_Structure__c= objStructure.Id;
        strucureParticipant.Type__c= 'External';
        insert strucureParticipant;
        List<Meeting_Participants__c> objList = new List<Meeting_Participants__c>();
        objList.add(strucureParticipant);
        SRM_AddParticipantsController.createParticipants(objList, objNote.id);
    }
}