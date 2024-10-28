@isTest
private class AccountTeamMembersBatchTest {
    @testSetup
    public static void populateMockData() {
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
        usr1.Business_Segment__c = 'Adult Nutrition';
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

        List<AccountTeamMember> teamMembers = new List<AccountTeamMember>();
        teamMembers.add(new AccountTeamMember(UserId=usr1.Id, AccountId=childAcc.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read', OpportunityAccessLevel='Read', TeamMemberRole='Sales Manager', Business_Segment__c='', Primary__c=true));
        teamMembers.add(new AccountTeamMember(UserId=usr2.Id, AccountId=childAcc.Id, AccountAccessLevel='Read', CaseAccessLevel='Read', ContactAccessLevel='Read', OpportunityAccessLevel='Read', TeamMemberRole='CMO', Business_Segment__c='Adult Nutrition', Primary__c=true));
        insert teamMembers;
    }

    @isTest
    public static void testAccountTeamMembersBatch() {
        Boolean exceptionHappened = false; 
        Test.startTest();
        try {
            AccountTeamMembersBatch accTeamMembersBatch = new AccountTeamMembersBatch();
            Database.executeBatch(accTeamMembersBatch);
        }
        catch (Exception ex) {
            exceptionHappened = true;
            throw ex;
        }
        Test.stopTest();
        Assert.areEqual(false, exceptionHappened, 'no exception happened on account team members batch job');
    }
}