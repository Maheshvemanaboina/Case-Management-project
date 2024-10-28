@isTest
public class purchaseOrderHandlerTest {

    static testmethod void testmeth(){
        insert new Global_Automation_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Skip_Process_Builder__c=true);
        
        Id CaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Request').getRecordTypeId();
        Case csObj = new Case();
        csObj.Status='New';
        csObj.RecordTypeId = CaseRecTypeId;
        csObj.Type = 'Order Change';
        csObj.Sub_Type__c = 'Delay in delivery date';
        csObj.Subject = 'helloTest';
        csObj.Description = 'Hello Description';
        insert csObj;
        Purchase_Order__c p = new Purchase_Order__c();
        p.PO_Number__c='1234';
        p.Status__c='New';
        p.Case__c = csObj.Id;
        insert p;
        Purchase_Order__c p1 = new Purchase_Order__c();
        p1.PO_Number__c='1234';
        p1.Status__c='New';
        p1.Case__c = csObj.Id;
        insert p1;
        Test.startTest();
        List<Purchase_Order__c> polist = new List<Purchase_Order__c>();
        p.Status__c='Closed';
        p1.Status__c='Declined';
        polist.add(p);
        polist.add(p1);
        update polist;
        Test.stopTest();
    }
}