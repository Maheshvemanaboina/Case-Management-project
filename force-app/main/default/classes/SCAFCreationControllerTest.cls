@isTest
public class SCAFCreationControllerTest {

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

        SCAFCreationController.SCAFCeation(leg.Id);
        leg.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
        update leg;
        SCAFCreationController.SCAFCeation(leg.Id);
        leg.Status_of_LSD__c = 'LSD Under Negotiation';
        update leg;
        leg.Deviations_from_RFC_LSD_Template__c = 'Without Deviations';
        update leg;
        
        SCAFCreationController.SCAFCeation(leg.Id);
        leg.LSD_StartEffective_Date__c = Date.today();
        leg.Initial_Term_of_LSD_In_Months__c = 12;
        leg.Termination_Notice_Period_In_Months__c = 10;
        leg.Status_of_LSD__c = 'LSD in Place';
        update leg;
        SCAFCreationController.SCAFCeation(leg.Id);
        leg.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        leg.SCAF_Approval_Status__c = 'Approved';
        update leg;
        SCAFCreationController.SCAFCeation(leg.Id);
        //leg.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
        //update leg;
        SCAF__c scf = new SCAF__c();
        scf.SCAF_Approval_Status__c = 'Draft';
        scf.Business_Group__c = leg.Business_Group__c;
        scf.FC_Legal_Entity__c = leg.FC_Legal_Entity__c;
        scf.Legal_Sales_Document__c = leg.Id;
        insert scf;
        //Legal_Sales_Document__c legS = [Select id,(select id,SCAF_Approval_Status__c,Legal_Sales_Document__c from SCAF__r) from Legal_Sales_Document__c where id=:leg.Id];
        //System.debug('legS SCAF__r '+legS.SCAF__r[0].Legal_Sales_Document__c);
        //

        Legal_Sales_Document__c leg1 = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id,1000000);
        leg1.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        leg1.Deviations_from_RFC_LSD_Template__c = 'Without Deviations';
        leg1.Business_Group__c = 'FCI';
        leg1.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        leg1.Leading_Business_Segment__c = 'Adult Nutrition';
        insert leg1;

        leg1.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
        leg1.LSD_StartEffective_Date__c = system.today();
        leg1.Initial_Term_of_LSD_In_Months__c = 12;
        leg1.Termination_Notice_Period_In_Months__c = 10;
        leg1.RecordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_With_Deviation').getRecordTypeId();
        update leg1;
        
        SCAFCreationController.SCAFCeation(leg1.Id);
        
        
        
    }
    @isTest
    public static void drafSCAF(){
          TriggerHandler.skipTrigger = true;
        Account commercialCust = TestUtility.createCommercialCustomer('H1 IMCD Holding');
        insert commercialCust;
        
        Account custLoc = TestUtility.createCustomerLocation(commercialCust);
        insert custLoc;
        
        TriggerHandler.skipTrigger = false;
        Test.startTest();
        Legal_Sales_Document__c leg2 = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id,1000000);
		leg2.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
        leg2.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';

        leg2.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        leg2.Business_Group__c = 'FCI';
        leg2.SCAF_Approval_Status__c = 'Approved';
		leg2.FC_Legal_Entity__c = 'FrieslandCampina Nederland B.V.';
        leg2.Leading_Business_Segment__c = 'Adult Nutrition';
        insert leg2;
        
        SCAF__c scf1 = new SCAF__c();
        scf1.SCAF_Approval_Status__c = 'Draft';
        scf1.Business_Group__c = leg2.Business_Group__c;
        scf1.FC_Legal_Entity__c = leg2.FC_Legal_Entity__c;
        scf1.Legal_Sales_Document__c = leg2.Id;
        insert scf1;
        SCAFCreationController.SCAFCeation(leg2.Id);
        Test.stopTest();
    }
}