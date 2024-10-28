public class CreateLSDRecords {
    public static void legalSalesDocument(){
        Account acList = [select Id, Name from Account where Name = 'H5 Test Account'];
         List<Legal_Sales_Document__c> lsdocList = new List<Legal_Sales_Document__c>();
        for(integer i = 0; i <100; i++){
            Legal_Sales_Document__c lsdoc = new Legal_Sales_Document__c();
            lsDoc.Total_Net_Sales_Value__c = 10000000;
            lsDoc.Account_Name__c = acList.Id;
            lsDoc.Auto_Extension__c = false;
            lsDoc.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
            lsDoc.Type_of_LSD__c = 'RFC T&Cs (Incl MPC Conditions)';
            lsDoc.Business_Group__c = 'Trading';
            lsDoc.Leading_Business_Segment__c = 'Cheese';
            lsDoc.Deviations_from_RFC_LSD_Template__c = 'Without Deviations';
            lsDoc.LSD_StartEffective_Date__c = system.today();
            lsDoc.Initial_Term_of_LSD_In_Months__c = 13;
            lsDoc.Termination_Notice_Period_In_Months__c = 13; 
            lsDocList.add(lsDoc);
        }
        if(!lsDocList.isEmpty()){
            insert lsDocList;
        }
        
        system.debug('insert ==> '+ lsDocList);
    }
}