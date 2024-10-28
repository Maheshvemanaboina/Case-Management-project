/****************************************************************************************       
@Name          : BatchClassToInActiveUser_Test
@Author        : Mohammad Rafi + mohammad.rafi@frieslandcampina.com
@CreatedDate   : 23-06-2021
@UsedBy        : BatchClassToInActiveUser
@Description   : Test Class for  BatchClassToInActiveUser
@Modified By   : Praneeth Krishna
@Modified Date : 12-09-2022
******************************************************************************************/
@isTest
private class BatchClassToInActiveUser_Test {
    @testSetup
    static void setupData(){
        TriggerHandler.skipTrigger = true;

        Account parentAcc = TestUtility.createCommercialCustomer();
        insert parentAcc;

        Account childAcc = TestUtility.createCustomerLocation(parentAcc);
        childAcc.Name = 'IMCD Blah Blah';
        insert childAcc;
        
        Account childAcc2 = TestUtility.createCustomerLocation(parentAcc);
        childAcc2.Name = 'IMCD France Spa';
        childAcc2.BillingCountry = 'France';
        childAcc2.BillingCountryCode = 'FR';
        insert childAcc2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User();
        u.Alias = 'fries'; 
        u.Email='testFrieslRavi@frieslandcapina.com'; 
        u.EmailEncodingKey='UTF-8';
        u.LastName='Test user'; 
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = p.Id;
        u.isActive = true;
        u.TimeZoneSidKey='America/Los_Angeles'; 
        u.UserName='ravitestFriesl@rieslandcapina.com';
        insert u;
        
        User u1 = new User();
        u1.Alias = 'fries1'; 
        u1.Email='testFrieslRavi1@frieslandcapina.com'; 
        u1.EmailEncodingKey='UTF-8';
        u1.LastName='Test user'; 
        u1.LanguageLocaleKey='en_US';
        u1.LocaleSidKey='en_US';
        u1.ProfileId = p.Id;
        u1.isActive = true;
        u1.TimeZoneSidKey='America/Los_Angeles'; 
        u1.UserName='ravitestFriesl1@rieslandcapina.com';
        u1.Reporting_Key_User_Name__c = u.id;
        insert u1;
        
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();   
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(u, childAcc, 'CMO','Adult Nutrition'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(u1, childAcc, 'Sales Manager','Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(u, childAcc2, 'Commercial Director','Adult Nutrition'));        
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(u1, childAcc2, 'OFO','Adult Nutrition'));
        insert teamMembers;
        
        Partner_Role__c pr = new Partner_Role__c();
        pr.Name='Test1';
        pr.Relation_Name__c ='Sales Manager';
        pr.External_Key__c='0001234-1234-01-10-0012346';
        pr.Source_Account__c=childAcc.id;
        pr.SAP_Employee_Id__c='0012346';
        pr.active__c = true;
        pr.Salesforce_User__c = u.id;
        insert pr; 
        
        Partner_Role__c pr2 = new Partner_Role__c();
        pr2.Name='Test1';
        pr2.Relation_Name__c ='Sales Manager';
        pr2.External_Key__c='0001234-1234-01-10-0012345';
        pr2.Source_Account__c=childAcc.id;
        pr2.SAP_Employee_Id__c='0012345';
        pr2.active__c = true;
        pr2.Salesforce_User__c = u1.id;
        insert pr2; 

        TriggerHandler.skipTrigger = false;
        
        
    }
    
    static testmethod void test() {      
        Test.startTest();       		       
        BatchClassToInActiveUser BatchSch = new BatchClassToInActiveUser();
        String croneExp = '0 0 12 1/1 * ? *'; 
        system.schedule('This batch will be execute at 12 pm', croneExp, BatchSch); 
        Test.stopTest();
    }       
}