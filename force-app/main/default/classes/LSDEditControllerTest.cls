/******************************************************************************************************************************************************************
* Class Name    : LSDEditControllerTest
* Modified Date : 05/05/2024
* User Story    : 143421-[Imp] As a Developer, I should be able to see all the impacted components are updated with the picklist value changes on the LSD object
* Description   : Replaced the correct picklist values for Business_Group__c,Leading_Business_Segment__c,FC_Legal_Entity__c of LSD object.
********************************************************************************************************************************************************************/
@isTest
public class LSDEditControllerTest {

    @testSetup
    static void setup(){
        Account commercialCustomer = TestUtility.createCommercialCustomer();
        insert commercialCustomer;
        Account customerLocation = TestUtility.createCustomerLocation(commercialCustomer);
        insert customerLocation;
        Legal_Sales_Document__c lsd = new Legal_Sales_Document__c();
        lsd.Parent_Account__c =    commercialCustomer.Id;
        lsd.Account_Name__c = customerLocation.Id;
        lsd.Business_Group__c = 'MEPA';//143421
        lsd.RecordTypeId = Schema.getGlobalDescribe().get('Legal_Sales_Document__c').getDescribe().getRecordTypeInfosByDeveloperName().get('LSD_Record_Type').getRecordTypeId();
        lsd.Leading_Business_Segment__c = 'Rest of Sub Saharan Africa';//143421
        lsd.FC_Legal_Entity__c = 'FrieslandCampina Saudi Arabia Limited';//143421
        lsd.Deviations_from_RFC_LSD_Template__c = 'Without Deviations';
        lsd.Status_of_LSD__c = 'No LSD';
        insert lsd;
        
        lsd.Status_of_LSD__c = 'LSD in Place';
        lsd.LSD_StartEffective_Date__c = system.today();
        lsd.Initial_Term_of_LSD_In_Months__c = 12;
        lsd.Termination_Notice_Period_In_Months__c = 1;
        update lsd;
        
        Group gp            = new Group();
        gp.Name             = 'Legal Team New';
        gp.DeveloperName    = 'Legal_Team_New';
        gp.Type             = 'Regular';
        insert gp;
        
        User usr = TestUtility.createUser('abc@kvpcorp.com', 'B2B Sales Platform User');
        insert usr;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
      GroupMember grpMem = new GroupMember();
        grpMem.UserOrGroupId = usr.Id;
        grpMem.GroupId = gp.Id;
        insert grpMem;
}
     
      }
    
     @isTest
    public static void checkForLegalUserTest(){
        User usr = [SELECT Id,Name FROM User WHERE UserName = 'abc@kvpcorp.com'];
        Test.startTest();
        Boolean result = LSDEditController.checkForLegalUser(usr.Id);
        system.assertEquals(false,result);
        Test.stopTest();
    }
    
     @isTest
    public static void handleEditActionTest(){
        Legal_Sales_Document__c lsd = [SELECT Id FROM Legal_Sales_Document__c LIMIT 1];
        lsd.RecordTypeId = Schema.getGlobalDescribe().get('Legal_Sales_Document__c').getDescribe().getRecordTypeInfosByDeveloperName().get('LSD_Lock_Without_Deviation').getRecordTypeId();
        update lsd;
        Test.startTest();
        Boolean result = LSDEditController.handleEditAction(lsd.Id);
         system.assertEquals(true,result);
        Test.stopTest();
    }
}