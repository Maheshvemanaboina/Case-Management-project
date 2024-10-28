@isTest
public class MultiplePOExtensionTestClass {

    static testmethod void testmet(){
        
        insert new Global_Automation_Setting__c(SetupOwnerId=UserInfo.getOrganizationId(), Skip_Process_Builder__c=true);
        
        Test.StartTest(); 
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
        p.Case__c = csObj.Id;
        insert p;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(csObj);
        MultiplePOExtension testAccPlan = new MultiplePOExtension(sc);
        
        PageReference pageRef = Page.MultiplePOVFPage;
        pageRef.getParameters().put('id', String.valueOf(csObj.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.currTourType='1';
        
        testAccPlan.AddPO();
        pageRef.getParameters().put('passNum', String.valueOf(1));
        testAccPlan.pnewlist.add(new purchase_order__c(PO_Number__c='123456'));
        testAccPlan.DeletePO();
        testAccPlan.AddPO();
        testAccPlan.doSave();
        Test.StopTest();
    }
}