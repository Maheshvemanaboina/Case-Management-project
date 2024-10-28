/******************************************************************************************************************************************************************
* Class Name    : LSDFileUploadPopUpControllerTest
* Modified Date : 05/05/2024
* User Story    : 143421-[Imp] As a Developer, I should be able to see all the impacted components are updated with the picklist value changes on the LSD object
* Description   : Replaced the correct picklist values for Business_Group__c,Leading_Business_Segment__c,FC_Legal_Entity__c of LSD object.
********************************************************************************************************************************************************************
* @Author       : LSD SCAF Expedition 2030 Dev Team
* Modified Date : 27/05/2024
* User Story    : 143335-As a SM/Sales Support Officer, when a LSD SCAF record is not satisfying any of the Approval criteria, I should see a display message that Approval is not needed
* Description   : Added method to cover getapprovalLevelsRequired 
******************************************************************************************************************************/
@isTest
public class LSDFileUploadPopUpControllerTest {

    @testSetup
    static void dataSetup(){
        Account acc = TestUtility.createCommercialCustomer();
        insert acc;
        
        Legal_Sales_Document__c agentLSD = new Legal_Sales_Document__c();
        agentLSD.Account_Name__c = acc.Id;
        agentLSD.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
        agentLSD.Business_Group__c = 'Europe';//143421
        agentLSD.FC_Legal_Entity__c = 'FrieslandCampina Belgium N.V.';//143421
        agentLSD.Leading_Business_Segment__c = 'Belgium';//143421
        agentLSD.LSD_StartEffective_Date__c = system.today();
        agentLSD.Initial_Term_of_LSD_In_Months__c = 12;
        agentLSD.Termination_Notice_Period_In_Months__c = 1;
        agentLSD.Commission_of_Net_Sales__c = 10;
        agentLSD.Bank_Account_Details__c = 'test bank details';
        insert agentLSD;         
        
        Account commercialCust = TestUtility.createCommercialCustomer('H1 IMCD Holding');
        insert commercialCust;
        
        Account custLoc = TestUtility.createCustomerLocation(commercialCust);       
        insert custLoc;
        
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
        scf.Non_Summit_OpCo__c=true;
        insert scf;
        
    }
    
    @isTest
    public static void testLSDData(){
        Legal_Sales_Document__c lsd = [SELECT Id FROM Legal_Sales_Document__c LIMIT 1];
        Integer fileCount = LSDFileUploadPopUpController.getFileDetailsForLSD(lsd.Id);
        system.assertEquals(0, fileCount);
    }
    
    @isTest
    public static void testScafData(){
        SCAF__c scaf = [SELECT Id FROM SCAF__c LIMIT 1];
        Integer fileCount = LSDFileUploadPopUpController.getFileDetailsForScaf(scaf.Id);
        system.assertEquals(0, fileCount);
    }
    
    @isTest
    public static void negativeTestLSDData(){
        try{
            LSDFileUploadPopUpController.getFileDetailsForLSD('');
        }catch(exception ex){
            system.assertEquals(true, String.isNotBlank(ex.getMessage()));
        }
    }
    
    /*US-143335 - Method to get coverage for getapprovalLevelsRequired */
    @isTest
    public static void testScafDataForapprovalLevel(){
        SCAF__c scaf = [SELECT Id FROM SCAF__c LIMIT 1];
        Decimal approvalLevel = LSDFileUploadPopUpController.getapprovalLevelsRequired(scaf.Id);
        system.assertEquals(0, approvalLevel);
    }
}