@isTest
public class SCAFMessageControllerTest {

    static testmethod void testmet(){

        TriggerHandler.skipTrigger = true;
        Account commercialCust = TestUtility.createCommercialCustomer('H1 IMCD Holding');
        insert commercialCust;
        
        Account custLoc = TestUtility.createCustomerLocation(commercialCust);
        insert custLoc;
        
        TriggerHandler.skipTrigger = false;

        Legal_Sales_Document__c leg = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id,50000000);
        leg.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        leg.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        leg.Business_Group__c = 'FCI';
        leg.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        leg.Leading_Business_Segment__c = 'Adult Nutrition';
        leg.RecordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_With_Deviation').getRecordTypeId();
        insert leg;
        
        leg.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
        update leg;
        SCAF__c scf = new SCAF__c();
        scf.Initial_Term_of_LSD_In_Months__c = 72;
        scf.Legal_Sales_Document__c = leg.Id;
        scf.Business_Group__c = leg.Business_Group__c;
        scf.FC_Legal_Entity__c = leg.FC_Legal_Entity__c;
        scf.MessageCount__c = 0;
        insert scf;
        SCAFMessageController.getMessageCount(scf.Id);
        scf.MessageCount__c = null;
        update scf;
        SCAFMessageController.getMessageCount(scf.Id);
        scf.SCAF_Approval_Status__c = 'Draft';
        update scf;
        SCAFMessageController.getMessageCount(scf.Id);
    }
}