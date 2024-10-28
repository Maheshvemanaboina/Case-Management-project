@isTest
public class SCAFHandlerTest {
    
    @testSetup
    static void dataSetup(){
        List<Account> accList = new List<Account>();
        
        Account commercialCust = TestUtility.createCommercialCustomer('H1 IMCD Holding');
        commercialCust.Active__c=true;
        insert commercialCust;
        
        Account custLoc = TestUtility.createCustomerLocation(commercialCust);
        custLoc.Active__c=true;
        custLoc.Partner_Role__c='Sold-to';
        accList.add(custLoc);
        
        Account custLoc2 = TestUtility.createCustomerLocation(commercialCust);
        custLoc2.Name = 'test cust loc 2';
         custLoc2.Active__c=true;
        custLoc2.Partner_Role__c='Sold-to';
        accList.add(custLoc2);
        
        insert accList;
        
        Legal_Sales_Document__c legalSales = TestUtility.getLegalInstance(commercialCust.Id, custLoc.Id,11000000);
        legalSales.LSD_Auto_Extension__c = 'No';
        
        insert legalSales;
		legalSales.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
        update legalSales;
        
        SCAF__c scf = new SCAF__c();
        scf.Legal_Sales_Document__c = legalSales.Id;
        scf.LSD_StartEffective_Date__c = system.today();
        scf.Initial_Term_of_LSD_In_Months__c = 12;
        scf.Termination_Notice_Period_In_Months__c = 1;
        scf.Standard_Liability__c = 'No';
        scf.Aggregate_Liability_Cap_Amount_EUR__c = 34567;
        scf.Liability_Cap_Per_Year_EUR__c = 34567;
        scf.Direct_Damages_Capped__c = 'No cap at direct damages';
        scf.Indirect_Damages_ExcludedCapped__c = 'Yes, Excluded';
        scf.Penalties_or_Other_Financial_Exposure__c = 'No';
        scf.Indemnity__c = 'No';
        scf.Standard_Warranties__c = 'Yes';
        scf.Standard_Order_Process__c = 'Yes';
        scf.Standard_Termination__c = 'Yes';
        scf.Standard_Governing_Law__c = 'Yes';
        insert scf;
        
        scf.SCAF_Approval_Status__c = 'Approved';
        update scf;
        
        legalSales.LSD_Auto_Extension__c = 'Yes';
      	legalSales.Status_of_LSD__c = 'LSD in Place';
        legalSales.SCAF_Approval_Status__c = 'Approved';
        update legalSales;
        
        Id relatedLSDRecType = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('Related_LSD_With_Deviation').getRecordTypeId();
        Legal_Sales_Document__c relatedLSD = new Legal_Sales_Document__c();
        relatedLSD.RecordTypeId = relatedLSDRecType;
        relatedLSD.LSD_Child_Extension__c = legalSales.Id;
        relatedLSD.Status_of_LSD__c = 'No LSD';
        relatedLSD.Type_of_Related_LSD__c = 'Extension of Term Existing LSD';
        //relatedLSD.LSD_StartEffective_Date__c = system.today();
        //relatedLSD.Initial_Term_of_LSD_In_Months__c = 12;
        //relatedLSD.Termination_Notice_Period_In_Months__c  = 1;
        insert relatedLSD;
    }
    
    @isTest
    static void validateSCAFChangeValidation(){
        Legal_Sales_Document__c relatedLSD = [SELECT Id FROM Legal_Sales_Document__c WHERE Type_of_Related_LSD__c = 'Extension of Term Existing LSD' LIMIT 1];
        // Scaf for related LSD will be created automatically by the flow, the below scaf is the scaf for related LSD
        SCAF__c scf = [SELECT Id,Standard_Liability__c,Aggregate_Liability_Cap_Amount_EUR__c,Liability_Cap_Per_Year_EUR__c,Direct_Damages_Capped__c,Indirect_Damages_ExcludedCapped__c,Penalties_or_Other_Financial_Exposure__c,Indemnity__c,Standard_Warranties__c,Standard_Order_Process__c,Standard_Termination__c,Standard_Governing_Law__c FROM SCAF__c WHERE Legal_Sales_Document__c =: relatedLSD.Id];
        scf.Standard_Liability__c = 'Yes';
        scf.Aggregate_Liability_Cap_Amount_EUR__c = 35567;
        scf.Liability_Cap_Per_Year_EUR__c = 34667;
        scf.Direct_Damages_Capped__c = 'Yes, capped at < EUR 2mio';
        scf.Indirect_Damages_ExcludedCapped__c = 'Capped at < 1mio';
        scf.Penalties_or_Other_Financial_Exposure__c = 'Yes';
        scf.Indemnity__c = 'Yes';
        scf.Standard_Warranties__c = 'No';
        scf.Standard_Order_Process__c = 'No';
        scf.Standard_Termination__c = 'No';
        scf.Standard_Governing_Law__c = 'No';
        Test.startTest();
        String exceptionMessage;
        try{
            update scf;
        }catch(Exception ex){
            exceptionMessage =ex.getMessage();
        }
        Test.stopTest();
        system.assert(exceptionMessage != null,true);
    }
}