/******************************************************************************************************************************************************************
* Class Name    : LSDHandlerTest
* Modified Date : 05/05/2024
* User Story    : 143421-[Imp] As a Developer, I should be able to see all the impacted components are updated with the picklist value changes on the LSD object
* Description   : Replaced the correct picklist values for Leading_Business_Segment__c,FC_Legal_Entity__c of LSD object.
********************************************************************************************************************************************************************/
@isTest
public class LSDHandlerTest {
    @testSetup
    static void dataSetup(){
        
        List<Account> accList = new List<Account>();
        
        Account commercialCust = TestUtility.createCommercialCustomer('H1 IMCD Holding');
        insert commercialCust;
        
        Account custLoc = TestUtility.createCustomerLocation(commercialCust);
        accList.add(custLoc);
        
        Account custLoc2 = TestUtility.createCustomerLocation(commercialCust);
        custLoc2.Name = 'test cust loc 2';
        accList.add(custLoc2);
        
        insert accList;
        
        Legal_Sales_Document__c legalSales = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id,11000000);
        legalSales.Deviations_from_RFC_LSD_Template__c = 'Without Deviations';
        insert legalSales;
        
        legalSales.LSD_Auto_Extension__c = 'Yes';
        legalSales.LSD_StartEffective_Date__c = system.today();
        legalSales.Initial_Term_of_LSD_In_Months__c = 12;
        legalSales.Termination_Notice_Period_In_Months__c = 1;
        legalSales.Status_of_LSD__c = 'LSD in Place';
        update legalSales;
        
        Id relatedLSDRecType = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('Related_LSD_With_Deviation').getRecordTypeId();
        Legal_Sales_Document__c relatedLSD = new Legal_Sales_Document__c();
        relatedLSD.RecordTypeId = relatedLSDRecType;
        relatedLSD.LSD_Child_Extension__c = legalSales.Id;
        relatedLSD.Status_of_LSD__c = 'No LSD';
        relatedLSD.Type_of_Related_LSD__c = 'Extension of Term Existing LSD';
        insert relatedLSD;
        
    }
    
    @isTest
    static void validateRelatedLSDChangeValidation(){
        
        Account custLoc2 = [SELECT Id,Name FROM Account WHERE Name='test cust loc 2' LIMIT 1];
        
        Id relatedLSDRecType = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('Related_LSD_With_Deviation').getRecordTypeId();
        Legal_Sales_Document__c relatedLSD = [SELECT Id,RecordTypeId,LSD_Child_Extension__c,Status_of_LSD__c,Type_of_Related_LSD__c,Account_Name__c,Business_Group__c,Other_Business_Segment__c,Deviations_from_RFC_LSD_Template__c,FC_Legal_Entity__c,Leading_Business_Segment__c FROM Legal_Sales_Document__c WHERE RecordTypeId =: relatedLSDRecType LIMIT 1];
        relatedLSD.Account_Name__c = custLoc2.Id;
        relatedLSD.Other_Business_Segment__c = 'BeLux';
        relatedLSD.Deviations_from_RFC_LSD_Template__c = 'Deviations';
        relatedLSD.FC_Legal_Entity__c = 'Alaska Milk Corporation';//143421
        relatedLSD.Leading_Business_Segment__c = 'Rest of Sub Saharan Africa';//143421
        
        Test.startTest();
        String exceptionMessage;
        try{
            update relatedLSD;
        }catch(Exception ex){
            exceptionMessage =ex.getMessage();
        }
        Test.stopTest();
        
        system.assert(exceptionMessage != null,true);
    }
}