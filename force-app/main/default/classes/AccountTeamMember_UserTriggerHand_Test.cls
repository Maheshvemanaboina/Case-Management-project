/******************************
* Written By : Mahendra
* Purpose : Test Class
* Classes Covered : AccountTeamMember_UserTriggerHandler
* ****************************/

@isTest
public class AccountTeamMember_UserTriggerHand_Test {
    
    @testSetup
    static void setupTestData(){
        //Create H1 Account
        Account parentAcc = TestUtility.createCommercialCustomer();
        parentAcc.Name = 'Test Commercial Cust';
        insert parentAcc;

        //Create H5 Account
        Account childAcc = TestUtility.createCustomerLocation(parentAcc);
        childAcc.Name = 'Test Cust Loc';
        childAcc.SAP_Number__c = '0000105505';
        childAcc.Partner_Role__c = 'Sold-to';
        insert childAcc;
        
        //Create Sales Area for H5 Account
        Sales_area__c s1 = new sales_area__c();
        s1.Active__c = true;
        s1.Customer_Name__c = childAcc.id;
        s1.Customer_Group_4__c = 'B06 Distributor';
        s1.External_Key__c = '0000105505-5953-01-10';
        s1.Business_Segment__c = 'Adult Nutrition';
        insert s1;
        
        //Create list of users (to assign in partner roles)
        List<User> usersList = new List<User>();
        User usr1 = TestUtility.createUser('testUser1@flc.com.test.SA', 'Standard CPQ User Profile');
        usr1.LastName = 'SM User 1';
        usr1.SAP_Employee_Id__c = '00100124';
        usr1.Friesland_Campina_Role__c ='Sales Manager';
        usr1.Business_Segment__c='Adult Nutrition';
        usersList.add(usr1);
        
        User usr2 = TestUtility.createUser('testUser2@flc.com.test.SA', 'New FCl Lightning Users');
        usr2.LastName = 'SM User 2';
        usr2.SAP_Employee_Id__c = '00101232';
        usr2.Friesland_Campina_Role__c ='Sales Manager';
        usr2.Business_Segment__c='Adult Nutrition';
        usersList.add(usr2);
        
        User usr3 = TestUtility.createUser('testUser3@flc.com.test.SA', 'Standard CPQ User Profile');
        usr3.LastName = 'SM User 3';
        usr3.Friesland_Campina_Role__c ='Sales Manager';
        usr3.Business_Segment__c='Adult Nutrition';
        usersList.add(usr3);
        
        User adminUser = TestUtility.createUser('testUser4@flc.com.test.SA', 'System Administrator');
        adminUser.LastName = 'Admin User';
        adminUser.Friesland_Campina_Role__c ='Sales Manager';
        adminUser.Business_Segment__c='Adult Nutrition';
        usersList.add(adminUser);
        insert usersList;
        
    }
    
    public static testmethod void makeData() {
        Test.startTest();
        Account childAcc = [SELECT Id FROM Account WHERE SAP_Number__c = '0000105505'];
        Sales_Area__c s1 = [SELECT Id, Active__c FROM Sales_Area__c WHERE External_Key__c = '0000105505-5953-01-10'];
        
        List<String> usersLastNameList = new List<String>{'SM User 1', 'SM User 2', 'SM User 3', 'Admin User'};
        Map<String, User> userMap = new Map<String, User>();
        for(User usr : [SELECT Id, LastName, UserName, SAP_Employee_Id__c FROM User WHERE LastName IN: usersLastNameList])
        {
            userMap.put(usr.LastName, usr);
        }
        
        List<Partner_Role__c> partnerRoleList = new List<Partner_Role__c>();
        // add partner to create account team member
        Partner_Role__c pr1 = new Partner_Role__c();
        pr1.Name='SM PR';
        pr1.External_Key__c='0000105505-5953-01-10-PE-00100124';
        pr1.Source_Account__c=childAcc.id;
        pr1.SAP_Employee_Id__c='00100124';
        pr1.active__c = true;
        pr1.Relation_Name__c = 'Sales Manager';
        pr1.Sales_Area__c = s1.Id;
        pr1.Salesforce_User__c = userMap.get(usersLastNameList[0]).Id;
        partnerRoleList.add(pr1);
        
        Partner_Role__c pr2 = new Partner_Role__c();
        pr2.Name='CMO PR';
        pr2.External_Key__c='0000105505-5953-01-10-PE-00101232';
        pr2.Source_Account__c=childAcc.id;
        pr2.SAP_Employee_Id__c='00101232';
        pr2.active__c = true;
        pr2.Relation_Name__c = 'Sales Assistant';
        pr2.Sales_Area__c = s1.Id;
        pr2.Salesforce_User__c = userMap.get(usersLastNameList[1]).Id;
        partnerRoleList.add(pr2);
        
        Partner_Role__c pr3 = new Partner_Role__c();
        pr3.Name='OFO PR';
        pr3.External_Key__c='0000105505-5953-01-10-PE-00101643';
        pr3.Source_Account__c=childAcc.id;
        pr3.SAP_Employee_Id__c='00101643';
        pr3.active__c = false;
        pr3.Relation_Name__c = 'Person Responsible';
        pr3.Sales_Area__c = s1.Id;
        partnerRoleList.add(pr3);
        
        List<Account_Team__c> accountTeamList = new List<Account_Team__c>();
        Account_Team__c accTeamMember1 = new Account_Team__c();
        accTeamMember1.Source_Account__c = childAcc.Id;
        accTeamMember1.Business_Segment__c = 'Adult Nutrition';
        accTeamMember1.Primary__c = true;
        accTeamMember1.Team_Member__c = userMap.get(usersLastNameList[0]).Id;
        accTeamMember1.Team_Role__c = 'Sales Manager';
        accTeamMember1.Account_Access__c = 'Edit';
        accTeamMember1.Contact_Access__c = 'Edit';
        accTeamMember1.Opportunity_Access__c = 'Edit';
        accTeamMember1.Case_Access__c = 'Edit';
        accountTeamList.add(accTeamMember1);
        
        Account_Team__c accTeamMember2 = new Account_Team__c();
        accTeamMember2.Source_Account__c = childAcc.Id;
        accTeamMember2.Business_Segment__c = 'Adult Nutrition';
        accTeamMember2.Primary__c = true;
        accTeamMember2.Team_Member__c = userMap.get(usersLastNameList[2]).Id;
        accTeamMember2.Team_Role__c = 'CMO';
        accTeamMember2.Account_Access__c = 'Edit';
        accTeamMember2.Contact_Access__c = 'Edit';
        accTeamMember2.Opportunity_Access__c = 'Edit';
        accTeamMember2.Case_Access__c = 'Edit';
        accountTeamList.add(accTeamMember2);
        
        TriggerHandler.SkipTrigger = true;
        insert partnerRoleList;
        insert accountTeamList;
        TriggerHandler.SkipTrigger = false;
        
        system.runAs(userMap.get(usersLastNameList[3])){
            User usr3 = userMap.get(usersLastNameList[2]);
            usr3.SAP_Employee_Id__c = '00101643';
            update usr3;
            
            User usr1 = userMap.get(usersLastNameList[0]);
            usr1.isActive = false;
            update usr1;
        }
        
        List<Account_Team__c> accountTeams = [SELECT Id, Team_Role__c, Team_Member__r.SAP_Employee_Id__c
                                   FROM Account_Team__c
                                   WHERE Source_Account__c =: childAcc.Id];
        
        system.assertEquals(!accountTeams.isEmpty(), true);
        Test.stopTest();
        
    }    
}