/*       
@Name                  AccountTeamMemberValidationsTest
@Author                Sharan Mulimani + Sharan.Mulimani@frieslandcampina.com
@ModifiedBy            Shoba Thummala + shoba.thummala@frieslandcampina.com
@Version               1.0
@CreatedDate           -----
@UsedBy                AccountTeamMemberValidations
@Description           Class to perform validations on insertion and updation of AccountTeamMember 
@Changes
UserId           | Author-Email                         | Date                | Comment
================ |======================================|=====================|=========
Shoba Thummala  | shoba.thummala@frieslandcampina.com   | February 11, 2021   | Test class for AccountTeamMemberValidationsTest
Shweta          | shweta.basavaraj@frieslandcampina.com | August 03, 2022     | Updating test class for new custom object Account Team
*/
@isTest
public with sharing class AccountTeamMemberValidationsTest {
    /* @Description:create the test data 
@param NAME:void
@return TYPE:void 
*/ 
    @TestSetup
    static void makeData(){
        TriggerHandler.skipTrigger = true;
        //Create the Commercial Customer account
        Account parentAcc = TestUtility.createCommercialCustomer();
        insert parentAcc;
        //Create the  CustomerLocation account
        Account childAcc = TestUtility.createCustomerLocation(parentAcc);
        childAcc.Name = 'IMCD Blah Blah';
        insert childAcc;
        
        Account childAcc2 = TestUtility.createCustomerLocation(parentAcc);
        childAcc2.Name = 'IMCD France Spa';
        childAcc2.BillingCountry = 'France';
        childAcc2.BillingCountryCode = 'FR';
        insert childAcc2;
        
        List<User> usrs = new List<User>();
        //Create the users and add Business segment to users
        User usr1 = TestUtility.createUser('testUser1@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Industry';
        usrs.add(usr1);
        
        User usr2 = TestUtility.createUser('testUser2@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Cheese';
        usrs.add(usr2);
        
        User usr3 = TestUtility.createUser('testUser3@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Cheese';
        usrs.add(usr3);
        
        User usr4 = TestUtility.createUser('testUser4@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Industry';
        usrs.add(usr4);
        
        User usr5 = TestUtility.createUser('testUser5@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Industry';
        usrs.add(usr5);
        
        User usr6 = TestUtility.createUser('testUser6@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Milkpowder';
        usrs.add(usr6);
        
        User usr7 = TestUtility.createUser('testUser7@flc.com.test.SA', 'System Administrator');
        usr7.Business_Segment__c='Industry';
        usrs.add(usr7);
        
        
        insert usrs;
        
        //Add the above created users as teammembers to the customerLocation accounts
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr1, childAcc, 'CMO','Adult Nutrition'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr2, childAcc, 'Sales Manager','Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr3, childAcc, 'OFO','Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr4, childAcc2, 'Commercial Director','Adult Nutrition'));        
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr5, childAcc2, 'OFO','Adult Nutrition'));
        insert teamMembers;
        
        TriggerHandler.skipTrigger = false;
    }
    
    /**
     * @Description:Tests if updating an isolated account team as primary for a role and business segment of another primary account team results in error
    **/ 
    @isTest
    static void shouldthrowPrimaryValidationErrorOnUpdate(){
        
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        
        
        Account_Team__c atm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c atm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        
        Boolean exceptionHappened =  false;
        Boolean expectedExceptionThrown =  false;

        Test.startTest();
        atm1.Primary__c = true;
        update atm1;
        RecursionHandler.isAccountTeamMemberAfterUpdateRecursive = false;
        try{
            atm2.Team_Role__c = 'OFO';//to be primary and duplicated with primary one atm1
            atm2.Business_Segment__c = 'Industry';//to be primary and duplicated with primary one atm1
            atm2.Primary__c = true;
            
            //The trigger gets fired on updation of account 
            update atm2;
        }
        catch(Exception e){
            exceptionHappened = true;
            expectedExceptionThrown =  e.getMessage().contains(AccountTeamMemberValidations.ACC_TEAM_PRIMARY_VALIDATION_ERROR) ? true : false;
        }
        System.debug('user Name 2 --> '+atm2.Team_Member__r.UserName);
        Test.stopTest();
        Assert.areEqual(true, exceptionHappened, 'exception happened assertion');
        Assert.areEqual(true, expectedExceptionThrown, 'Team Member with same Role and Business segment cannot be Primary assertion');
    }

    /**
     * @Description:Tests if updating account teams simultaneously as primary for the same role and business segment results in error
    **/
    @isTest
    static void testPrimaryUpdateInBulkErrors(){
        
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        
        
        Account_Team__c atm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c atm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        
        Boolean exceptionHappened =  false;
        Boolean expectedExceptionThrown =  false;

        Test.startTest();
        List<Account_Team__c> accTeamsToUpdate = new List<Account_Team__c>();
        atm1.Primary__c = true;
        accTeamsToUpdate.add(atm1);

        atm2.Team_Role__c = 'OFO';//to be primary and duplicated with primary one atm1
        atm2.Business_Segment__c = 'Industry';//to be primary and duplicated with primary one atm1
        atm2.Primary__c = true;
        accTeamsToUpdate.add(atm2);
        try{
            update accTeamsToUpdate;
        }
        catch(Exception e){
            exceptionHappened = true;
            expectedExceptionThrown =  e.getMessage().contains(AccountTeamMemberValidations.ACC_TEAM_PRIMARY_VALIDATION_ERROR) ? true : false;
        }
        System.debug('user Name 2 --> '+atm2.Team_Member__r.UserName);
        Test.stopTest();
        Assert.areEqual(true, exceptionHappened, 'exception happened assertion');
        Assert.areEqual(true, expectedExceptionThrown, 'Team Member with same Role and Business segment cannot be Primary assertion');
    }

    /**
     * @Description:Tests if updating account teams simultaneously as primary for distinct role and business segment works successfully
    **/
    @isTest
    static void testPrimaryUpdateInBulk(){
        
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        
        
        Account_Team__c atm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c atm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        
        Boolean exceptionHappened =  false;

        Test.startTest();
        List<Account_Team__c> accTeamsToUpdate = new List<Account_Team__c>();
        atm1.Primary__c = true;
        accTeamsToUpdate.add(atm1);

        atm2.Primary__c = true;
        accTeamsToUpdate.add(atm2);
        try{
            update accTeamsToUpdate;
        }
        catch(Exception e){
            exceptionHappened = true;
        }
        System.debug('user Name 2 --> '+atm2.Team_Member__r.UserName);
        Test.stopTest();
        Assert.areEqual(false, exceptionHappened, 'exception happened assertion');
        Account_Team__c updatedAtm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c updatedAtm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        Assert.areEqual(true, updatedAtm1.Primary__c, 'atm1 is primary assertion');
        Assert.areEqual(true, updatedAtm2.Primary__c, 'atm2 is primary assertion');
    }

    /**
     * @Description:Tests if updating account teams simultaneously as primary/remove primary for distinct role and business segment works successfully
    **/
    @isTest
    static void testRemovePrimaryUpdateInBulk(){
        
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        
        
        Account_Team__c atm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c atm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        
        atm1.Primary__c = true;
        update atm1;
        RecursionHandler.isAccountTeamMemberAfterUpdateRecursive = false;

        Boolean exceptionHappened =  false;

        Test.startTest();
        List<Account_Team__c> accTeamsToUpdate = new List<Account_Team__c>();
        atm1.Primary__c = false;
        accTeamsToUpdate.add(atm1);

        atm2.Primary__c = true;
        accTeamsToUpdate.add(atm2);
        try{
            update accTeamsToUpdate;
        }
        catch(Exception e){
            exceptionHappened = true;
        }
        System.debug('user Name 2 --> '+atm2.Team_Member__r.UserName);
        Test.stopTest();
        Assert.areEqual(false, exceptionHappened, 'exception happened assertion');
        Account_Team__c updatedAtm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c updatedAtm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        Assert.areEqual(false, updatedAtm1.Primary__c, 'atm1 is primary assertion');
        Assert.areEqual(true, updatedAtm2.Primary__c, 'atm2 is primary assertion');
    }
    
    /**
     * @Description:Tests if updating an isolated account team as primary for a distinct role and business segment of another primary account team works successfully
    **/ 
    @isTest
    static void updateAccountTeamsPrimarySuccess(){
        
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        
        
        Account_Team__c atm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c atm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        
        Boolean exceptionHappened =  false;
        Boolean expectedExceptionThrown =  false;

        Test.startTest();
        atm1.Primary__c = true;
        update atm1;
        RecursionHandler.isAccountTeamMemberAfterUpdateRecursive = false;
        try{
            atm2.Primary__c = true;
            
            //The trigger gets fired on updation of account 
            update atm2;
        }
        catch(Exception e){
            exceptionHappened = true;
        }
        System.debug('user Name 2 --> '+atm2.Team_Member__r.UserName);
        Test.stopTest();
        Assert.areEqual(false, exceptionHappened, 'exception happened assertion');
        Account_Team__c updatedAtm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c updatedAtm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'CMO' and Source_Account__r.Id =: acc.Id];
        Assert.areEqual(true, updatedAtm1.Primary__c, 'atm1 is primary assertion');
        Assert.areEqual(true, updatedAtm2.Primary__c, 'atm2 is primary assertion');
    }

    /**
     * @Description:Tests if updating account teams simultaneously as primary for the same role and business segment but different source accounts updates successfully
    **/
    @isTest
    static void testPrimaryUpdateDifferentSourceAccountsInBulk(){
        
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        Account acc2 = [SELECT Id 
                        FROM Account
                        WHERE Name = 'IMCD France Spa' LIMIT 1];
        
        
        Account_Team__c atm1Acc1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c atm2Acc2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc2.Id];
        
        Boolean exceptionHappened =  false;
        Boolean expectedExceptionThrown =  false;

        Test.startTest();
        List<Account_Team__c> accTeamsToUpdate = new List<Account_Team__c>();
        atm1Acc1.Primary__c = true;
        accTeamsToUpdate.add(atm1Acc1);

        atm2Acc2.Business_Segment__c = 'Industry';//to be duplicated with primary one atm1Acc1
        atm2Acc2.Primary__c = true;
        accTeamsToUpdate.add(atm2Acc2);
        try{
            update accTeamsToUpdate;
        }
        catch(Exception e){
            exceptionHappened = true;
        }
        Test.stopTest();
        Assert.areEqual(false, exceptionHappened, 'exception happened assertion');
        Account_Team__c updatedAtm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc.Id];
        Account_Team__c updatedAtm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'OFO' and Source_Account__r.Id =: acc2.Id];
        Assert.areEqual(true, updatedAtm1.Primary__c, 'atm1 is primary assertion');
        Assert.areEqual(true, updatedAtm2.Primary__c, 'atm2 is primary assertion');
    }
    
    /**
     * @Description:Tests if inserting account teams simultaneously as primary for the same role and business segment and source account results in error
    **/
    @isTest
    static void shouldthrowPrimaryValidationErrorOnInsert(){
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        List<User> usrlist = [SELECT Id,UserName
                              FROM User
                              WHERE UserName IN (: 'testUser4@flc.com.test.SA',:'testUser5@flc.com.test.SA')];
        Test.startTest();
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c atm1 = TestUtility.createAccountTeamMember_Custom(usrlist[0], acc,'CMO','Adult Nutrition');
        atm1.Primary__c = true;
        teamMembers.add(atm1);
        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(usrlist[1], acc, 'CMO','Adult Nutrition');
        atm2.Primary__c = true;
        teamMembers.add(atm2);
        Boolean expectedExceptionThrown =  false;
        try{
            //The trigger gets fired on insert of accounts 
            insert teamMembers;
        }
        catch(Exception e){
            expectedExceptionThrown =  e.getMessage().contains(AccountTeamMemberValidations.ACC_TEAM_PRIMARY_VALIDATION_ERROR) ? true : false;
        }
        Test.stopTest();
        Assert.areEqual(true, expectedExceptionThrown, 'Team Member with same Role and Business segment cannot be Primary assertion');
        
    }
    
    /**
     * @Description:Tests if inserting account teams simultaneously as primary for the same role and business segment but different source account inserts successfully
    **/
    @isTest
    static void insertPrimaryDifferentSourceAccountsValidation(){
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        Account acc2 = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD France Spa' LIMIT 1];
        List<User> usrlist = [SELECT Id,UserName
                              FROM User
                              WHERE UserName IN (: 'testUser4@flc.com.test.SA',:'testUser5@flc.com.test.SA')];
        Test.startTest();
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c atm1 = TestUtility.createAccountTeamMember_Custom(usrlist[0], acc,'CMO','Adult Nutrition');
        atm1.Primary__c = true;
        teamMembers.add(atm1);
        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(usrlist[1], acc2, 'CMO','Adult Nutrition');
        atm2.Primary__c = true;
        teamMembers.add(atm2);
        Boolean expectedHappened =  false;
        try{
            //The trigger gets fired on insert of accounts 
            insert teamMembers;
        }
        catch(Exception e){
            expectedHappened =  true;
        }
        Test.stopTest();
        Assert.areEqual(false, expectedHappened, 'exception happened assertion');
        Account_Team__c updatedAtm1 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id,Team_Role__c,Business_Segment__c from Account_Team__c where Id =: atm1.Id];
        Account_Team__c updatedAtm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Id =: atm2.Id];
        Assert.areEqual(true, updatedAtm1.Primary__c, 'atm1 is primary assertion');
        Assert.areEqual(true, updatedAtm2.Primary__c, 'atm2 is primary assertion');
    }
    
    /**
     * @Description:Tests if inserting account teams multiple as primary for the same role and business segment and source account results in error
    **/
    @isTest
    static void insertPrimaryDistinctOperationsValidationError(){
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        List<User> usrlist = [SELECT Id,UserName
                              FROM User
                              WHERE UserName IN (: 'testUser4@flc.com.test.SA',:'testUser5@flc.com.test.SA')];
        Test.startTest();
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c atm1 = TestUtility.createAccountTeamMember_Custom(usrlist[0], acc,'CMO','Adult Nutrition');
        atm1.Primary__c = true;
        insert atm1;

        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(usrlist[1], acc, 'CMO','Adult Nutrition');
        atm2.Primary__c = true;
        Boolean expectedExceptionThrown =  false;
        try{
            //The trigger gets fired on insert of accounts 
            insert atm2;
        }
        catch(Exception e){
            expectedExceptionThrown =  e.getMessage().contains(AccountTeamMemberValidations.ACC_TEAM_PRIMARY_VALIDATION_ERROR) ? true : false;
        }
        Test.stopTest();
        Assert.areEqual(true, expectedExceptionThrown, 'Team Member with same Role and Business segment cannot be Primary assertion');
        
    }
    
    @isTest
    static void shouldthrowValidationErrorOnDelete(){
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        List<User> usrlist = [SELECT Id,UserName
                              FROM User
                              WHERE UserName IN (: 'testUser4@flc.com.test.SA',:'testUser5@flc.com.test.SA')];
        
        
        Test.startTest();
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c atm1 = TestUtility.createAccountTeamMember_Custom(usrlist[0], acc, 'Commercial Director','Adult Nutrition');
        teamMembers.add(atm1);
        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(usrlist[1], acc, 'Commercial Controller','Adult Nutrition');
        teamMembers.add(atm2);
        
        try{
            //The trigger gets fired on insert of accounts 
            insert atm1;
            insert atm2;
            
            delete atm2;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('You are not allowed to delete the member') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true, 'You are not allowed to delete the member');
        }
        Test.stopTest();
        
    }
    
    /**
     * @Description:Tests if deleting a Sales Manager account team results in error
    **/
    @isTest
    static void testValidationErrorDeleteMember(){   
        User usr = [SELECT Id,UserName FROM User WHERE UserName = 'testUser7@flc.com.test.SA'];
        User usr2 = [SELECT Id,UserName FROM User WHERE UserName = 'testUser2@flc.com.test.SA'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'IMCD Blah Blah' LIMIT 1];  
        Account_Team__c atm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c = 'Sales Manager' and Source_Account__r.Id =: acc.Id];   
        
        Sales_area__c s1 = new sales_area__c();
        s1.Active__c = true;
        s1.Customer_Name__c = acc.id;
        s1.Customer_Group_4__c = 'B06 Distributor';
        s1.External_Key__c = '0000105505-5953-01-10';
        s1.Business_Segment__c = 'Industry';
        insert s1;

        Partner_Role__c pr1 = new Partner_Role__c();
        pr1.Name='SM PR';
        pr1.External_Key__c='0000105505-5953-01-10-PE-00100124';
        pr1.Source_Account__c=acc.id;
        pr1.SAP_Employee_Id__c='00100124';
        pr1.active__c = true;
        pr1.Relation_Name__c = 'Sales Manager';
        pr1.Sales_Area__c = s1.Id;
        pr1.Salesforce_User__c = usr2.Id;
        insert pr1;

        Test.startTest();
        String exceptionMessage = '';
        try {
            delete atm2;
        }
        catch (Exception ex) {
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(true, exceptionMessage.contains(AccountTeamMemberValidations.ACC_TEAM_CANNOT_DELETE_MEMBER), 'cannot delete member assertion');
    }
    
    //Test method to test the primary sales manager recalculation on deleting existing primary sales manager    
    @isTest
    static void shouldRecalculatePrimarySMOnDeletionOfExistingPrimarySM(){
        Account acc = [SELECT Id 
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        List<User> usrlist = [SELECT Id,UserName
                              FROM User
                              WHERE UserName IN (: 'testUser4@flc.com.test.SA',:'testUser5@flc.com.test.SA')];
        
        
        Test.startTest();
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c atm1 = TestUtility.createAccountTeamMember_Custom(usrlist[0], acc, 'Sales Manager','Adult Nutrition');
        atm1.Primary__c = true;
        teamMembers.add(atm1);
        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(usrlist[1], acc, 'Sales Manager','Adult Nutrition');
        teamMembers.add(atm2);
        insert teamMembers;
        delete atm1;
        Test.stopTest();
        system.assertEquals(true, [SELECT Primary__c FROM Account_Team__c WHERE Team_Member__c=:usrlist[1].Id AND Team_Role__c = 'Sales Manager' AND Business_Segment__c = 'Adult Nutrition' AND Source_Account__c =: acc.Id].Primary__c);
        
    }
    
    //Test method to test whether the deleted account teams got restored or not on changing the customer location owner    
    @isTest
    static void shouldRetainAccountTeamOnChangingCustomerLocationOwner(){
        Account acc = [SELECT Id, OwnerId
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        List<User> usrlist = [SELECT Id,UserName
                              FROM User
                              WHERE UserName IN (: 'testUser4@flc.com.test.SA',:'testUser5@flc.com.test.SA',:'testUser1@flc.com.test.SA',:'testUser2@flc.com.test.SA',:'testUser3@flc.com.test.SA')];
        List<String> usernames = new List<String>();
        for (User usr : usrlist) {
            usernames.add(usr.UserName.toLowerCase());
        }
        User usrSM = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestSalesManager', 'New Fcl Lightning Users');
        insert usrSM;
        usernames.add(usrSM.UserName.toLowerCase());
        
        User adminUser = [SELECT Id FROM User WHERE UserName = 'testUser1@flc.com.test.SA'];
        
        Test.startTest();
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c atm1 = TestUtility.createAccountTeamMember_Custom(usrlist[0], acc, 'Sales Manager','Adult Nutrition');
        atm1.Primary__c = true;
        teamMembers.add(atm1);
        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(usrlist[1], acc, 'Sales Manager','Adult Nutrition');
        teamMembers.add(atm2);
        
        system.runAs(adminUser){
            insert teamMembers;
            
            acc.OwnerId = usrSM.Id;
            update acc;
        }
        
        Test.stopTest();
        
        List<Account_Team__c> customAccountTeamList = [SELECT Id,Team_Member__r.UserName FROM Account_Team__c WHERE Source_Account__c =: acc.Id];
        for (Account_Team__c accTeam : customAccountTeamList) {
            Assert.areEqual(true, usernames.contains(accTeam.Team_Member__r.UserName), 'account team username belongs to source account assertion');
        }
        
    }
    
    @isTest
    public static void testRecalculationOfEndCustomerOwnerWhenPrimarySMIsDeleted(){
        Account acc = [SELECT Id, ParentId, OwnerId
                       FROM Account
                       WHERE Name = 'IMCD Blah Blah' LIMIT 1];
        List<User> usrlist = [SELECT Id,UserName
                              FROM User
                              WHERE UserName IN (: 'testUser4@flc.com.test.SA',:'testUser5@flc.com.test.SA')];  
        Test.startTest();
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c atm1 = TestUtility.createAccountTeamMember_Custom(usrlist[0], acc, 'Sales Manager','Adult Nutrition');
        atm1.Primary__c = true;
        teamMembers.add(atm1);
        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(usrlist[1], acc, 'Sales Manager','Adult Nutrition');
        teamMembers.add(atm2);
        insert teamMembers;
        
        Account endCust = TestUtility.createEndCustomerAccount('Test End Customer');
        endCust.Distributor_Location__c = acc.Id;
        endCust.Distributor__c = acc.ParentId;
        endCust.Business_Segment__c = 'Adult Nutrition';
        insert endCust;
        
        delete atm1;
        Test.stopTest();
        Account_Team__c updatedAtm2 = [SELECT Id,Team_Member__r.UserName,Primary__c FROM Account_Team__c WHERE Id =: atm2.Id];
        Assert.areEqual(true, updatedAtm2.Primary__c, 'account team atm2 set as primary assertion');
        Account updatedEndCust = [SELECT Id,Owner.UserName FROM Account WHERE Id =: endCust.Id];
        Assert.areEqual(usrlist[1].UserName, updatedEndCust.Owner.UserName, 'account endCust owner updated assertion');
    }

    /**
     * @Description:Tests if a custom account team member is generated after inserting a partner role
    **/
    @isTest
    public static void testInsertPartnerRoleGeneratesAccountTeamMember() {
        User usr = [SELECT Id,UserName FROM User WHERE UserName = 'testUser7@flc.com.test.SA'];
        User usr2 = [SELECT Id,UserName FROM User WHERE UserName = 'testUser2@flc.com.test.SA'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'IMCD Blah Blah' LIMIT 1];  
        
        Sales_area__c s1 = new sales_area__c();
        s1.Active__c = true;
        s1.Customer_Name__c = acc.id;
        s1.Customer_Group_4__c = 'B06 Distributor';
        s1.External_Key__c = '0000105505-5953-01-10';
        s1.Business_Segment__c = 'Adult Nutrition';
        insert s1;

        Test.startTest();
        Partner_Role__c pr1 = new Partner_Role__c();
        pr1.Name='SM PR';
        pr1.External_Key__c='0000105505-5953-01-10-PE-00100124';
        pr1.Source_Account__c=acc.id;
        pr1.SAP_Employee_Id__c='00100124';
        pr1.active__c = true;
        pr1.Relation_Name__c = 'Sales Manager';
        pr1.Sales_Area__c = s1.Id;
        pr1.Salesforce_User__c = usr2.Id;
        insert pr1;
        Test.stopTest();
        Account_Team__c atm2 = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id, Business_Segment__c from Account_Team__c where Team_Role__c='Sales Manager' AND Business_Segment__c = 'Adult Nutrition' and Source_Account__r.Id =: acc.Id]; 
        Assert.areEqual('Adult Nutrition', atm2.Business_Segment__c, 'account team sales manager adult nutrition assertion');
    }

    /**
     * @Description:Tests if duplicated partner roles results in error
    **/
    @isTest
    public static void testInsertDuplicatedPartnerRoles() {
        User usr = [SELECT Id,UserName FROM User WHERE UserName = 'testUser7@flc.com.test.SA'];
        User usr2 = [SELECT Id,UserName FROM User WHERE UserName = 'testUser2@flc.com.test.SA'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'IMCD Blah Blah' LIMIT 1];  
        
        Sales_area__c s1 = new sales_area__c();
        s1.Active__c = true;
        s1.Customer_Name__c = acc.id;
        s1.Customer_Group_4__c = 'B06 Distributor';
        s1.External_Key__c = '0000105505-5953-01-10';
        s1.Business_Segment__c = 'Adult Nutrition';
        insert s1;

        Test.startTest();
        Partner_Role__c pr1 = new Partner_Role__c();
        pr1.Name='SM PR';
        pr1.External_Key__c='0000105505-5953-01-10-PE-00100124';
        pr1.Source_Account__c=acc.id;
        pr1.SAP_Employee_Id__c='00100124';
        pr1.active__c = true;
        pr1.Relation_Name__c = 'Sales Manager';
        pr1.Sales_Area__c = s1.Id;
        pr1.Salesforce_User__c = usr2.Id;
        insert pr1;
        
        Partner_Role__c pr2 = new Partner_Role__c();
        pr2.Name='SM PR';
        pr2.External_Key__c='0000105505-5953-01-10-PE-00100125';
        pr2.Source_Account__c=acc.id;
        pr2.SAP_Employee_Id__c='00100124';
        pr2.active__c = true;
        pr2.Relation_Name__c = 'Sales Manager';
        pr2.Sales_Area__c = s1.Id;
        pr2.Salesforce_User__c = usr2.Id;
        insert pr2;
        Test.stopTest();
        // the second partner role didn't result in an account team because of duplicated error (it is supressed under CreateAccountTeamMember, but being inserted on DebugLog__c)
        List<Account_Team__c> atms = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c='Sales Manager' AND Business_Segment__c = 'Adult Nutrition' and Source_Account__r.Id =: acc.Id]; 
        Assert.areEqual(1, atms.size(), 'account team sales manager qty assertion');
        DebugLog__c errs = [Select id, Message__c from DebugLog__c];
        Assert.areEqual(true, errs.Message__c.contains(AccountTeamMemberValidations.ACC_TEAM_UNIQUE_VALIDATION_ERROR), 'debug log message duplicated account team assertion');
    }

    /**
     * @Description:Tests if duplicated partner roles results in error
    **/
    @isTest
    public static void testInsertDuplicatedPartnerRolesInBulk() {
        User usr = [SELECT Id,UserName FROM User WHERE UserName = 'testUser7@flc.com.test.SA'];
        User usr2 = [SELECT Id,UserName FROM User WHERE UserName = 'testUser2@flc.com.test.SA'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'IMCD Blah Blah' LIMIT 1];  
        
        Sales_area__c s1 = new sales_area__c();
        s1.Active__c = true;
        s1.Customer_Name__c = acc.id;
        s1.Customer_Group_4__c = 'B06 Distributor';
        s1.External_Key__c = '0000105505-5953-01-10';
        s1.Business_Segment__c = 'Adult Nutrition';
        insert s1;

        Test.startTest();
        List<Partner_Role__c> toInsert = new List<Partner_Role__c>();
        Partner_Role__c pr1 = new Partner_Role__c();
        pr1.Name='SM PR';
        pr1.External_Key__c='0000105505-5953-01-10-PE-00100124';
        pr1.Source_Account__c=acc.id;
        pr1.SAP_Employee_Id__c='00100124';
        pr1.active__c = true;
        pr1.Relation_Name__c = 'Sales Manager';
        pr1.Sales_Area__c = s1.Id;
        pr1.Salesforce_User__c = usr2.Id;
        toInsert.add(pr1);
        
        Partner_Role__c pr2 = new Partner_Role__c();
        pr2.Name='SM PR';
        pr2.External_Key__c='0000105505-5953-01-10-PE-00100125';
        pr2.Source_Account__c=acc.id;
        pr2.SAP_Employee_Id__c='00100124';
        pr2.active__c = true;
        pr2.Relation_Name__c = 'Sales Manager';
        pr2.Sales_Area__c = s1.Id;
        pr2.Salesforce_User__c = usr2.Id;
        toInsert.add(pr2);
        insert toInsert;
        Test.stopTest();
        // the second partner role didn't result in an account team because of duplicated error (it is supressed under CreateAccountTeamMember, but being inserted on DebugLog__c)
        List<Account_Team__c> atms = [SELECT Id,Primary__c,Team_Member__r.UserName,Source_Account__r.Id from Account_Team__c where Team_Role__c='Sales Manager' AND Business_Segment__c = 'Adult Nutrition' and Source_Account__r.Id =: acc.Id]; 
        Assert.areEqual(1, atms.size(), 'account team sales manager qty assertion');
        DebugLog__c errs = [Select id, Message__c from DebugLog__c];
        Assert.areEqual(true, errs.Message__c.contains(AccountTeamMemberValidations.ACC_TEAM_UNIQUE_VALIDATION_ERROR), 'debug log message duplicated account team assertion');
    }
    
    /**
     * @Description:Tests if inserting an account team that is duplicated for the same team member, role, business segment and source account results in error
    **/
    @isTest
    public static void testDuplicatedCombinationTeamMemberSegmentRole() {
        User existingUser = [Select Id from User where Username='testUser5@flc.com.test.SA'];
        Account sourceAccount = [Select Id from Account where Name='IMCD France Spa'];
        Test.startTest();     
        Account_Team__c atm2 = TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'OFO','Adult Nutrition');
        String exceptionMessage = '';
        try {
            insert atm2;
        }
        catch(Exception ex) {
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(true, exceptionMessage.contains(AccountTeamMemberValidations.ACC_TEAM_UNIQUE_VALIDATION_ERROR), 'exception message is duplicate error message assertion');
    }
    
    /**
     * @Description:Tests if inserting account teams simultaneously that are duplicated for the same team member, role, business segment and source account results in error
    **/
    @isTest
    public static void testDuplicatedOnInsertCombinationTeamMemberSegmentRole() {
        User existingUser = [Select Id from User where Username='testUser5@flc.com.test.SA'];
        Account sourceAccount = [Select Id from Account where Name='IMCD France Spa'];
        Test.startTest();     
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'OFO','Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'Sales Manager','Adult Nutrition'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'Sales Manager','Adult Nutrition'));
        String exceptionMessage = '';
        try {
            insert teamMembers;
        }
        catch(Exception ex) {
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(true, exceptionMessage.contains(AccountTeamMemberValidations.ACC_TEAM_UNIQUE_VALIDATION_ERROR), 'exception message is duplicate error message assertion');
    }
    
    /**
     * @Description:Tests if inserting account teams simultaneously that are not duplicated is success
    **/
    @isTest
    public static void testNoDuplicatesOnInsertCombinationTeamMemberSegmentRole() {
        User existingUser = [Select Id from User where Username='testUser5@flc.com.test.SA'];
        Account sourceAccount = [Select Id from Account where Name='IMCD France Spa'];
        Test.startTest();     
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'OFO','Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'Sales Manager','Adult Nutrition'));
        String exceptionMessage = '';
        try {
            insert teamMembers;
        }
        catch(Exception ex) {
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.areEqual('', exceptionMessage, 'exception message is empty assertion');
    }
    
    /**
     * @Description:Tests if inserting account teams then update 1 of them to be duplicated by team role and business segment results in error
    **/
    @isTest
    public static void testDuplicatesOnUpdateCombinationTeamMemberSegmentRole() {
        User existingUser5 = [Select Id from User where Username='testUser5@flc.com.test.SA'];
        Account sourceAccount = [Select Id from Account where Name='IMCD France Spa'];
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser5, sourceAccount, 'OFO','Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser5, sourceAccount, 'Sales Manager','Adult Nutrition'));
        insert teamMembers;
        Test.startTest();     
        String exceptionMessage = '';
        try {
            teamMembers[1].Team_Role__c = 'OFO';// duplicated for Adult Nutrition on test setup for user 5
            update teamMembers[1];
        }
        catch(Exception ex) {
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(true, exceptionMessage.contains(AccountTeamMemberValidations.ACC_TEAM_UNIQUE_VALIDATION_ERROR), 'exception message is duplicate error message assertion');
    }
    
    
    /**
     * @Description:Tests if inserting account teams simultaneously that are duplicated for the same team member, role, business segment but different source account is success
    **/
    @isTest
    public static void testDuplicatedOnInsertCombinationTeamMemberSegmentRoleDifferentAccounts() {
        User existingUser = [Select Id from User where Username='testUser5@flc.com.test.SA'];
        Account sourceAccount = [Select Id from Account where Name='IMCD France Spa'];
        Account sourceAccount2 = [Select Id from Account where Name='IMCD Blah Blah'];
        Test.startTest();     
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'OFO','Industry'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount, 'Sales Manager','Adult Nutrition'));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(existingUser, sourceAccount2, 'Sales Manager','Adult Nutrition'));
        String exceptionMessage = '';
        try {
            insert teamMembers;
        }
        catch(Exception ex) {
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.areEqual('', exceptionMessage, 'exception message is empty assertion');
    }
}