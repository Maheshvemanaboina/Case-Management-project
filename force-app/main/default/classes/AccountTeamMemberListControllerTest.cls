/**
 * Created by KJM on 18/04/2019.
 */

@isTest
public class AccountTeamMemberListControllerTest {

    @TestSetup
    static void setup() {

        TriggerHandler.skipTrigger = true;

        Account parentAcc = TestUtility.createCommercialCustomer();
        insert parentAcc;

        Account childAcc = TestUtility.createCustomerLocation(parentAcc);
        insert childAcc;

        Account childAcc2 = TestUtility.createCustomerLocation(parentAcc);
        childAcc2.Name = 'IMCD France Spa';
        childAcc2.BillingCountry = 'France';
        childAcc2.BillingCountryCode = 'FR';
        insert childAcc2;

        List<User> usrs = new List<User>();

        User usr1 = TestUtility.createUser('testUser1@flc.com.test.SA', 'System Administrator');
        usrs.add(usr1);

        User usr2 = TestUtility.createUser('testUser2@flc.com.test.SA', 'System Administrator');
        usrs.add(usr2);

        User usr3 = TestUtility.createUser('testUser3@flc.com.test.SA', 'System Administrator');
        usrs.add(usr3);

        User usr4 = TestUtility.createUser('testUser4@flc.com.test.SA', 'System Administrator');
        usrs.add(usr4);

        User usr5 = TestUtility.createUser('testUser5@flc.com.test.SA', 'System Administrator');
        usrs.add(usr5);

        insert usrs;

        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr1, childAcc, Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER, 'Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr2, childAcc, Constants.ACCOUNT_TEAM_ROLE_CMO, 'Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr3, childAcc, 'OFO', 'Adult Nutrition'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr4, childAcc2, Constants.ACCOUNT_TEAM_ROLE_CMO, 'Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr5, childAcc2, 'OFO', 'Adult Nutrition'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr1, childAcc, Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER, 'Adult Nutrition'));
        insert teamMembers;

        TriggerHandler.skipTrigger = false;

    }

    @isTest
    static void shouldReturnAccountTeamMembersForStandardUser() {
        CommunityUtility.communityOptionsInstance = TestUtility.getCommunityOptions();
        
        //Query for the user to set OOO
        User userOOO = [SELECT Id FROM User WHERE UserName = 'testUser2@flc.com.test.SA'];
        
        //Set OOO for the above user
        insert new OutOfOffice(
        	UserId = userOOO.Id,
            IsEnabled = true,
            StartDate = Date.today(),
            EndDate = Date.today().addDays(2),
            Message = 'ooo'
        );

        AccountTeamMemberListController.MembersTableWrapper testTable = getAccountTeamMembersForStandardUsers();
        
        System.assertEquals(6, testTable.headerValues.size(), 'Headers of the Account Team Table displayed under My FC Team Tile in the Distributor/My FrieslandCampina Tile in the customer community is not correct');

        // 2 - from Italy account team role
        System.assertEquals(2, testTable.bodyValues.size(), 'As per the test data provided, standard user should have access to '+testTable.bodyValues.size()+'account team member records.');
    }

    @isTest
    static void shouldReturnAccountTeamMembersForManagerUser() {
        CommunityUtility.communityOptionsInstance = TestUtility.getCommunityOptions();

        AccountTeamMemberListController.MembersTableWrapper testTable = getAccountTeamMembersForManagerUsers();
        
        System.assertEquals(7, testTable.headerValues.size(), 'Headers of the Account Team Table displayed under My FC Team Tile in the Distributor/My FrieslandCampina Tile in the customer community is not correct');
        
        // 2 - from Italy account team role
        // 1 - from France account team role
        System.assertEquals(3, testTable.bodyValues.size(), 'As per the test data provided, manager user should have access to '+testTable.bodyValues.size()+'account team member records.');
    }
    
    @isTest
    static void shouldReturnAccountTeamMembersForStandardUserHideContactDetails() {
        Community_Setting__mdt options = TestUtility.getCommunityOptions();
        options.Show_contact_details_on_my_FCI_team__c = false;
        CommunityUtility.communityOptionsInstance = options;
        
        AccountTeamMemberListController.MembersTableWrapper testTable = getAccountTeamMembersForStandardUsers();
        
        System.assertEquals(5, testTable.headerValues.size(), 'Headers of the Account Team Table displayed under My FC Team Tile in the Distributor/My FrieslandCampina Tile in the customer community is not correct');

        // 2 - from Italy account team role
        System.assertEquals(2, testTable.bodyValues.size(), 'As per the test data provided, standard user should have access to '+testTable.bodyValues.size()+'account team member records.');
    }
    
    @isTest
    static void shouldReturnAccountTeamMembersForManagerUserHideContactDetails() {
        Community_Setting__mdt options = TestUtility.getCommunityOptions();
        options.Show_contact_details_on_my_FCI_team__c = false;
        CommunityUtility.communityOptionsInstance = options;

        AccountTeamMemberListController.MembersTableWrapper testTable = getAccountTeamMembersForManagerUsers();
        
        System.assertEquals(6, testTable.headerValues.size(), 'Headers of the Account Team Table displayed under My FC Team Tile in the Distributor/My FrieslandCampina Tile in the customer community is not correct');
        
        // 2 - from Italy account team role
        // 1 - from France account team role
        System.assertEquals(3, testTable.bodyValues.size(), 'As per the test data provided, manager user should have access to '+testTable.bodyValues.size()+'account team member records.');
    }
    
    private static AccountTeamMemberListController.MembersTableWrapper getAccountTeamMembersForStandardUsers(){
        AccountTeamMemberListController.MembersTableWrapper testTable;

        User usr = TestUtility.createPartnerPortalUser(
        'testKrzysUser@flc.com.test.PCU',
        [SELECT Id FROM Account WHERE Name = 'IMCD Holding'],
        [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa']);
        
        TriggerHandler.skipTrigger = true;
        Contact portalUserContact = [SELECT Id, Business_Segment__c FROM Contact WHERE Id =: usr.ContactId];
        portalUserContact.Business_Segment__c = portalUserContact.Business_Segment__c +';Adult Nutrition;Industry';
        update portalUserContact;
        TriggerHandler.skipTrigger = false;

        System.runAs(usr) {
            Test.startTest();

            testTable = AccountTeamMemberListController.getTableData();

            Test.stopTest();
        }
        return testTable;
    }
    
    private static AccountTeamMemberListController.MembersTableWrapper getAccountTeamMembersForManagerUsers(){
        AccountTeamMemberListController.MembersTableWrapper testTable;
        
        User usr = TestUtility.createPartnerPortalManagerUser(
            'testKrzysUser@flc.com.test.PCU',
            [SELECT Id FROM Account WHERE Name = 'IMCD Holding'],
            [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa']);
        
        TriggerHandler.skipTrigger = true;
        Contact portalUserContact = [SELECT Id, Business_Segment__c FROM Contact WHERE Id =: usr.ContactId];
        portalUserContact.Business_Segment__c = portalUserContact.Business_Segment__c +';Adult Nutrition;Industry';
        update portalUserContact;
        TriggerHandler.skipTrigger = false;
        
        System.runAs(usr) {
            Test.startTest();
            
            testTable = AccountTeamMemberListController.getTableData();
            
            Test.stopTest();
        }
        return testTable;
    }
}