/*       
@Name                  BatchToUpdateAccountNameOnLSD_Test
@Author                Rekha
@Version               1
@CreatedDate           25-08-2021
@UsedBy                
@Description           Test class for BatchToUpdateAccountNameOnLSD
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
*/
/******************************************************************************************************************************************************************
* Class Name    : BatchToUpdateAccountNameOnLSD_Test
* Modified Date : 05/05/2024
* User Story    : 143421-[Imp] As a Developer, I should be able to see all the impacted components are updated with the picklist value changes on the LSD object
* Description   : Replaced the correct picklist values for Business_Group__c,Leading_Business_Segment__c,FC_Legal_Entity__c of LSD object.
********************************************************************************************************************************************************************/
@isTest
public class BatchToUpdateAccountNameOnLSD_Test {
    
    public static testmethod void makeData() {  
        
        Account acc = TestUtility.createAgentAccount('Test Account');
        acc.SAP_Number__c ='123456';
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Legal_Sales_Document__c.getRecordTypeInfosByDeveloperName().get('LSD_Agent').getRecordTypeId();
        
        Legal_Sales_Document__c lsd = new Legal_Sales_Document__c();
        lsd.Status_of_LSD__c = 'LSD in Place';
        lsd.SAP_Number__c ='123456';
        lsd.SCAF_Approval_Status__c ='Approved';
        lsd.Business_Group__c = 'MEPA';//143421
        lsd.FC_Legal_Entity__c='FrieslandCampina Saudi Arabia Limited';//143421
        lsd.Leading_Business_Segment__c ='Rest of Sub Saharan Africa';//143421
        lsd.Deviations_from_RFC_LSD_Template__c ='Without Deviations';
        lsd.LSD_StartEffective_Date__c = date.today();
        lsd.Termination_Notice_Period_In_Months__c = 2;
        lsd.Initial_Term_of_LSD_In_Months__c= 2;
        lsd.RecordTypeId = recordTypeId;
        insert lsd;
        
        BatchToUpdateAccountNameOnLSD.logError('', '','','', '', '', '', '', '', '', '', '');
        
        BatchToUpdateAccountNameOnLSD executeBatchToUpdate = new BatchToUpdateAccountNameOnLSD(); 
        database.executebatch(executeBatchToUpdate);
        
    }
    
    public static testmethod void makeData2(){
        test.startTest();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test Schedule BatchToUpdateAccountNameOnLSD', sch,new BatchToUpdateAccountNameOnLSD());
        test.stopTest();
        
    }

}