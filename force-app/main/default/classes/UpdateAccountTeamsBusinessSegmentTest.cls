/******************************
* Written By : Mahendra
* Purpose : Test Class
* Classes Covered : UpdateAccountTeamsBusinessSegment
* ****************************/

@isTest
public class UpdateAccountTeamsBusinessSegmentTest {
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
        
        //Create list of users
        List<User> usersList = new List<User>();
        User usr1 = TestUtility.createUser('testUser1@flc.com.test.SA', 'Standard CPQ User Profile');
        usr1.SAP_Employee_Id__c = '00100124';
        usr1.Friesland_Campina_Role__c ='Sales Manager';
        usr1.Business_Segment__c='Adult Nutrition';
        usersList.add(usr1);
        
        User usr2 = TestUtility.createUser('testUser2@flc.com.test.SA', 'New FCl Lightning Users');
        usr2.SAP_Employee_Id__c = '00101232';
        usr2.Friesland_Campina_Role__c ='Sales Manager';
        usr2.Business_Segment__c='Adult Nutrition';
        usersList.add(usr2);
        
        User usr3 = TestUtility.createUser('testUser3@flc.com.test.SA', 'Standard CPQ User Profile');
        usr3.SAP_Employee_Id__c = '00101643';
        usr3.Friesland_Campina_Role__c ='Sales Manager';
        usr3.Business_Segment__c='Adult Nutrition';
        usersList.add(usr3);
        insert usersList;
    }
    
    @isTest
    static void updateSalesAreaBusinessSegment(){
        Test.startTest();
        Account customerLocation = [SELECT Id FROM Account WHERE SAP_Number__c = '0000105505'];
        Sales_Area__c salesArea = [SELECT Id, Active__c, Business_Segment__c FROM Sales_Area__c WHERE External_Key__c = '0000105505-5953-01-10'];
        
        User smUser = [SELECT Id FROM User WHERE SAP_Employee_Id__c = '00100124' AND UserName = 'testUser1@flc.com.test.SA'];
        User cmoUser = [SELECT Id FROM User WHERE SAP_Employee_Id__c = '00101232' AND UserName = 'testUser2@flc.com.test.SA'];
        User ofoUser = [SELECT Id FROM User WHERE SAP_Employee_Id__c = '00101643' AND UserName = 'testUser3@flc.com.test.SA'];
        
        List<Partner_Role__c> partnerRoleList = new List<Partner_Role__c>();
        // add partner to create account team member
        Partner_Role__c pr1 = new Partner_Role__c();
        pr1.Name='SM PR';
        pr1.External_Key__c='0000105505-5953-01-10-PE-00100124';
        pr1.Source_Account__c=customerLocation.id;
        pr1.SAP_Employee_Id__c='00100124';
        pr1.active__c = true;
        pr1.Relation_Name__c = 'Sales Manager';
        pr1.Sales_Area__c = salesArea.Id;
        pr1.Salesforce_User__c = smUser.Id;
        partnerRoleList.add(pr1);
        
        Partner_Role__c pr2 = new Partner_Role__c();
        pr2.Name='CMO PR';
        pr2.External_Key__c='0000105505-5953-01-10-PE-00101232';
        pr2.Source_Account__c=customerLocation.id;
        pr2.SAP_Employee_Id__c='00101232';
        pr2.active__c = true;
        pr2.Relation_Name__c = 'Sales Assistant';
        pr2.Sales_Area__c = salesArea.Id;
        pr2.Salesforce_User__c = cmoUser.Id;
        partnerRoleList.add(pr2);
        
        Partner_Role__c pr3 = new Partner_Role__c();
        pr3.Name='OFO PR';
        pr3.External_Key__c='0000105505-5953-01-10-PE-00101643';
        pr3.Source_Account__c=customerLocation.id;
        pr3.SAP_Employee_Id__c='00101643';
        pr3.active__c = false;
        pr3.Relation_Name__c = 'Person Responsible';
        pr3.Sales_Area__c = salesArea.Id;
        partnerRoleList.add(pr3);
        
        List<Account_Team__c> accountTeamList = new List<Account_Team__c>();
        Account_Team__c accTeamMember1 = new Account_Team__c();
        accTeamMember1.Source_Account__c = customerLocation.Id;
        accTeamMember1.Business_Segment__c = 'Adult Nutrition';
        accTeamMember1.Primary__c = true;
        accTeamMember1.Team_Member__c = smUser.Id;
        accTeamMember1.Team_Role__c = 'Sales Manager';
        accTeamMember1.Account_Access__c = 'Edit';
        accTeamMember1.Contact_Access__c = 'Edit';
        accTeamMember1.Opportunity_Access__c = 'Edit';
        accTeamMember1.Case_Access__c = 'Edit';
        accountTeamList.add(accTeamMember1);
        
        Account_Team__c accTeamMember2 = new Account_Team__c();
        accTeamMember2.Source_Account__c = customerLocation.Id;
        accTeamMember2.Business_Segment__c = 'Adult Nutrition';
        accTeamMember2.Primary__c = true;
        accTeamMember2.Team_Member__c = cmoUser.Id;
        accTeamMember2.Team_Role__c = 'CMO';
        accTeamMember2.Account_Access__c = 'Edit';
        accTeamMember2.Contact_Access__c = 'Edit';
        accTeamMember2.Opportunity_Access__c = 'Edit';
        accTeamMember2.Case_Access__c = 'Edit';
        accountTeamList.add(accTeamMember2);
        
        Account_Team__c accTeamMember3 = new Account_Team__c();
        accTeamMember3.Source_Account__c = customerLocation.Id;
        accTeamMember3.Business_Segment__c = 'Adult Nutrition';
        accTeamMember3.Primary__c = true;
        accTeamMember3.Team_Member__c = ofoUser.Id;
        accTeamMember3.Team_Role__c = 'OFO';
        accTeamMember3.Account_Access__c = 'Read';
        accTeamMember3.Contact_Access__c = 'Read';
        accTeamMember3.Opportunity_Access__c = 'Read';
        accTeamMember3.Case_Access__c = 'None';
        accountTeamList.add(accTeamMember3);
        
        TriggerHandler.SkipTrigger = true;
        insert partnerRoleList;
        insert accountTeamList;
        TriggerHandler.SkipTrigger = false;
        
        //update sales area's business segment
        salesArea.Business_Segment__c = 'Industry';
        update salesArea;
        
        List<Account_Team__c> accountTeams = [SELECT Business_Segment__c FROM Account_Team__c WHERE Source_Account__c =: customerLocation.Id AND Business_Segment__c = 'Industry'];
        system.assertEquals(true, !accountTeams.isEmpty());
        
        DebugLogUtility.DebugLogWrapper debugWrapObj = new DebugLogUtility.DebugLogWrapper(
        	'Account Team',
            'Account_Team__c',
        	'UpdateAccountTeamsBusinessSegment',
        	'Apex Class',
        	'updateAccTeamsBusinessSegmentOfRelatedPartnerRoles',
        	'Error'
        );
        
        DebugLogUtility.logError('', '', '', debugWrapObj);
        Test.stopTest();
    }
}