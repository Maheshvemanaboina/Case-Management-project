/*      
@Name                  AccountTriggerHandlerTest
@Author                KJM
@ModifiedBy            Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version               1.1
@CreatedDate           29-07-2019
@UsedBy                
@Description           Test class for the AccountTrigger
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
*/
@isTest
public class AccountTriggerHandlerTest {

    /* @Description

    Test setup to create some test records

    @return void
    */
    @TestSetup
    static void setupData(){
        
        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCustIMCD = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCustIMCD);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCustDanone);

        Account commercialCustAzelis = TestUtility.createAccount('H1 Azelis'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCustAzelis);

        insert accsCommercCustToInsert;

        List<Account> accsToInsert = new List<Account>(); //Customer locations list to be created
        Account customerLocIMCDItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCustIMCD); //Customer location test record
        accsToInsert.add(customerLocIMCDItaly);

        Account customerLocIMCDFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCustIMCD); //Customer location test record
        customerLocIMCDFrance.BillingCountry = 'Australia';
        customerLocIMCDFrance.BillingCountryCode = 'AU';
        accsToInsert.add(customerLocIMCDFrance);

        Account customerLocIMCDPoland = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCustIMCD); //Customer location test record
        accsToInsert.add(customerLocIMCDPoland);

        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone); //Customer location test record
        customerLocDanone.BillingCountry = 'Poland';
        customerLocDanone.BillingCountryCode = 'PL';
        accsToInsert.add(customerLocDanone);
        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created
        Contact cItalySU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly); //Contact test record
        contactsToInsert.add(cItalySU);

        Contact cFranceSU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDFrance); //Contact test record
        cFranceSU.Additional_Country_Responsibility__c = 'Italy';
        contactsToInsert.add(cFranceSU);

        Contact cPolandSU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDPoland); //Contact test record
        contactsToInsert.add(cPolandSU);

        Contact cDanonePolandSubSU = TestUtility.createContact(commercialCustDanone, customerLocDanone); //Contact test record
        contactsToInsert.add(cDanonePolandSubSU);

        Contact cIMCDMU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly); //Contact test record
        contactsToInsert.add(cIMCDMU);

        Contact cDanonePolandMU = TestUtility.createContact(commercialCustDanone, customerLocDanone); //Contact test record
        contactsToInsert.add(cDanonePolandMU);

        Contact cDanonePolandAppMU = TestUtility.createContact(commercialCustDanone, customerLocDanone); //Contact test record
        contactsToInsert.add(cDanonePolandAppMU);

        Contact cDanonePolandAppSU = TestUtility.createContact(commercialCustDanone, customerLocDanone); //Contact test record
        contactsToInsert.add(cDanonePolandAppSU);

        insert contactsToInsert;

        List<User> usersToInsert = new List<User>(); //Users list to be created
        User usrIMCDItalySU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDItalySU.ContactId = cItalySU.Id;
        usersToInsert.add(usrIMCDItalySU);

        User usrIMCDFranceSU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceGG', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDFranceSU.ContactId = cFranceSU.Id;
        usersToInsert.add(usrIMCDFranceSU);

        User usrIMCDPolandSU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDPolandSU.ContactId = cPolandSU.Id;
        usersToInsert.add(usrIMCDPolandSU);

        User usrDanonePolandSubSU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrDanonePolandSubSU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT;
        usrDanonePolandSubSU.ContactId = cDanonePolandSubSU.Id;
        usersToInsert.add(usrDanonePolandSubSU);

        User usrIMCDMU = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDMU.ContactId = cIMCDMU.Id;
        usersToInsert.add(usrIMCDMU);

        User usrDanonePolandSubMU = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrDanonePolandSubMU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT;
        usrDanonePolandSubMU.ContactId = cDanonePolandMU.Id;
        usersToInsert.add(usrDanonePolandSubMU);

        User usrDanonePolandAppMU = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneAppManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrDanonePolandAppMU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION;
        usrDanonePolandAppMU.ContactId = cDanonePolandAppMU.Id;
        usersToInsert.add(usrDanonePolandAppMU);

        User usrDanonePolandAppSU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanoneAppStandard', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrDanonePolandAppSU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION;
        usrDanonePolandAppSU.ContactId = cDanonePolandAppSU.Id;
        usersToInsert.add(usrDanonePolandAppSU);

        insert usersToInsert;

        /* Create Share for Partner contacts for their own accounts */
        List<AccountShare> accShares = new List<AccountShare>(); //AccountShare list to be created
        accShares.add(AccountSharingUtility.getAccountShare(customerLocIMCDItaly.Id, usrIMCDItalySU.Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocIMCDFrance.Id, usrIMCDFranceSU.Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocIMCDPoland.Id, usrIMCDPolandSU.Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocDanone.Id, usrDanonePolandSubSU.Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocIMCDItaly.Id, usrIMCDMU.Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocDanone.Id, usrDanonePolandSubMU.Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocDanone.Id, usrDanonePolandAppMU.Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocDanone.Id, usrDanonePolandAppSU.Id, 'READ', 'Manual'));

        insert accShares;

        TriggerHandler.skipTrigger = true;

        List<Account> endCustomers = new List<Account>(); //End customers list to be created

        Account endCustomer1 = TestUtility.createEndCustomerAccount('End Customer IMCD Italy Spa UPD 1'); //End customer test record
        endCustomer1.Distributor__c = commercialCustIMCD.Id;
        endCustomer1.Distributor_Location__c = customerLocIMCDItaly.Id;
        endCustomers.add(endCustomer1);

        Account endCustomer2 = TestUtility.createEndCustomerAccount('End Customer IMCD Italy Spa UPD 2'); //End customer test record
        endCustomer2.Distributor__c = commercialCustIMCD.Id;
        endCustomer2.Distributor_Location__c = customerLocIMCDItaly.Id;
        endCustomers.add(endCustomer2);

        insert endCustomers;

        TriggerHandler.skipTrigger = false;
    }

    /* @Description

    Test if new accounts are shared properly with partner manager users

    @return void
    */
    @isTest
    static void shouldShareNewAccountToMU() {

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%'}; //Commercial customer names list to retrieve those accounts
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames]; //Commercial customers list to retrieve from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //Customer location names list to retrieve those accounts
        List<Account> customerLocs = [SELECT Id FROM Account WHERE Name LIKE :customerLocNames]; //Customer locations list to retrieve from the database
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%'}; //User names list to retrieve those users
        List<User> users = [SELECT Id FROM User WHERE UserName LIKE :userNames]; //Users list to retrieve from the database

        Test.startTest();

        Account customerLocNetherlands = TestUtility.createCustomerLocation('IMCD Netherlands Spa', commercialCustomers.get(0)); //Customer location test record
        insert customerLocNetherlands;

        Test.stopTest();

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocNetherlands.Id) AND UserOrGroupId = :users.get(0).Id]; //AccountShare list to check the sharing
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocNetherlands.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(5, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocNetherlands.Id) AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocNetherlands.Id) AND UserOrGroupId = :users.get(3).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocNetherlands.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(5, accShare.size());
    }

    /* @Description

    Test if updated account on type, partner role, billing country and billing country code change is shared properly with partner users

    @return void
    */
    @isTest
    static void shouldShareNewFCIDirectAccountToBusinessSegmentSUMU() {

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%', '%H1 Azelis%'}; //Commercial customer names list to retrieve those accounts
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames]; //Commercial customers list to retrieve from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //Customer location names list to retrieve those accounts
        List<Account> customerLocs = [SELECT Id FROM Account WHERE Name LIKE :customerLocNames]; //Customer locations list to retrieve from the database
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%'}; //User names list to retrieve those users
        List<User> users = [SELECT Id FROM User WHERE UserName LIKE :userNames]; //Users list to retrieve from the database

        Test.startTest();

        Account customerLocAustralia = TestUtility.createCustomerLocation('Azelis Australia Spa', commercialCustomers.get(2)); //Customer location test record
        customerLocAustralia.Type = 'Direct Customer';
        customerLocAustralia.Partner_Role__c = 'Sold-to';
        customerLocAustralia.BillingCountry = 'Australia';
        customerLocAustralia.BillingCountryCode = 'AU';
        insert customerLocAustralia;

        Test.stopTest();

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocAustralia.Id) AND UserOrGroupId = :users.get(0).Id]; //AccountShare list to check the sharing
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocAustralia.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(5, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocAustralia.Id) AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocAustralia.Id) AND UserOrGroupId = :users.get(3).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :customerLocAustralia.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(5, accShare.size());
    }

    /* @Description

    Test if updated account on type, partner role, billing country, billing country code and sub-segment change is shared properly with partner users

    @return void
    */
    @isTest
    static void shouldShareNewFCIDirectAccountToSubSegmentSUMU() {

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%', '%H1 Azelis%'}; //Commercial customer names list to retrieve those accounts
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames]; //Commercial customers list to retrieve from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //Customer location names list to retrieve those accounts
        List<Account> customerLocs = [SELECT Id FROM Account WHERE Name LIKE :customerLocNames]; //Customer locations list to retrieve from the database
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%','%TestDanoneManager%'}; //User names list to retrieve those users
        List<User> users = [SELECT Id FROM User WHERE UserName LIKE :userNames]; //Users list to retrieve from the database

        Test.startTest();

        Account customerLocAzelisPoland = TestUtility.createCustomerLocation('Azelis Poland Spa', commercialCustomers.get(2)); //Customer location test record
        customerLocAzelisPoland.Type = 'Direct Customer';
        customerLocAzelisPoland.Partner_Role__c = 'Sold-to';
        customerLocAzelisPoland.BillingCountry = 'Poland';
        customerLocAzelisPoland.BillingCountryCode = 'PL';
        customerLocAzelisPoland.Sub_Segment__c = 'Beverages';
        insert customerLocAzelisPoland;

        Test.stopTest();

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(0).Id]; //AccountShare list to check the sharing
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(4, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(3).Id];
        System.assertEquals(3, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(4, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(5).Id];
        System.assertEquals(3, accShare.size());
    }

    /* @Description

    Test if updated account on type, partner role, billing country, billing country code, sub-segment and application change is shared properly with partner users

    @return void
    */
    /*@isTest
    static void shouldShareNewFCIDirectAccountToApplicationSUMU() {

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%', '%H1 Azelis%'}; //Commercial customer names list to retrieve those accounts
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames]; //Commercial customers list to retrieve from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //Customer location names list to retrieve those accounts
        List<Account> customerLocs = [SELECT Id FROM Account WHERE Name LIKE :customerLocNames]; //Customer locations list to retrieve from the database
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%','%TestDanoneManager%', '%TestDanoneAppManager%', '%TestDanoneAppStandard%'}; //User names list to retrieve those users
        List<User> users = [SELECT Id FROM User WHERE UserName LIKE :userNames]; //Users list to retrieve from the database

        Test.startTest();

        Account customerLocAzelisPoland = TestUtility.createCustomerLocation('Azelis Poland Spa', commercialCustomers.get(2)); //Customer location test record
        customerLocAzelisPoland.Type = 'Direct Customer';
        customerLocAzelisPoland.Partner_Role__c = 'Sold-to';
        customerLocAzelisPoland.BillingCountry = 'Poland';
        customerLocAzelisPoland.BillingCountryCode = 'PL';
        customerLocAzelisPoland.Sub_Segment__c = 'Beverages';
        customerLocAzelisPoland.Application__c = 'DMV: Bakery';
        insert customerLocAzelisPoland;

        Test.stopTest();

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(0).Id]; //AccountShare list to check the sharing
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(4, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(3).Id];
        Set<Id> accIds = new Set<Id>();
        for(AccountShare aSh : accShare){
            accIds.add(aSh.AccountId);
        }
        for(Account acc : [SELECT Id, Name FROM Account WHERE Id IN: accIds]){
            System.debug(' acc Name '+acc.Name);
        }
        System.assertEquals(3, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(4, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(5).Id];
        System.assertEquals(3, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(6).Id];
        System.assertEquals(3, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocs.get(0).Id, :customerLocs.get(1).Id, :customerLocs.get(2).Id, :customerLocs.get(3).Id, :commercialCustomers.get(0).Id, :commercialCustomers.get(1).Id, :commercialCustomers.get(2).Id, :customerLocAzelisPoland.Id) AND UserOrGroupId = :users.get(7).Id];
        System.assertEquals(3, accShare.size());
    }*/

    /* @Description

    Test if new end customers are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldShareNewEndCustomersSUMUAndAdditionalCountryCheck() {

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%', '%H1 Azelis%'}; //Commercial customer names list to retrieve those accounts
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames]; //Commercial customers list to retrieve from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //Customer location names list to retrieve those accounts
        List<Account> customerLocs = [SELECT Id,Name FROM Account WHERE Name LIKE :customerLocNames]; //Customer locations list to retrieve from the database
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%','%TestDanoneManager%'}; //User names list to retrieve those users
        List<User> users = [SELECT Id,UserName FROM User WHERE UserName LIKE :userNames]; //Users list to retrieve from the database

        Test.startTest();

        List<Account> endCustomers = new List<Account>(); //End customers list to test

        Account endCustomer1 = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 1 '); //Customer location test record
        endCustomer1.Distributor__c = commercialCustomers.get(0).Id;
        endCustomer1.Distributor_Location__c = customerLocs.get(0).Id;
        endCustomers.add(endCustomer1);

        Account endCustomer2 = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 2 '); //Customer location test record
        endCustomer2.Distributor__c = commercialCustomers.get(0).Id;
        endCustomer2.Distributor_Location__c = customerLocs.get(0).Id;
        endCustomers.add(endCustomer2);

        Account endCustomer3 = TestUtility.createEndCustomerAccount('IMCD France Spa End Customer 3 '); //Customer location test record
        endCustomer3.Distributor__c = commercialCustomers.get(0).Id;
        endCustomer3.Distributor_Location__c = customerLocs.get(1).Id;
        endCustomers.add(endCustomer3);

        Account endCustomer4 = TestUtility.createEndCustomerAccount('IMCD Poland Spa End Customer 4 '); //Customer location test record
        endCustomer4.Distributor__c = commercialCustomers.get(0).Id;
        endCustomer4.Distributor_Location__c = customerLocs.get(2).Id;
        endCustomers.add(endCustomer4);

        Account endCustomer5 = TestUtility.createEndCustomerAccount('Danone Poland End Customer 5 '+TestUtility.generateRandomString(6)); //Customer location test record
        endCustomer5.Distributor__c = commercialCustomers.get(1).Id;
        endCustomer5.Distributor_Location__c = customerLocs.get(3).Id;
        endCustomers.add(endCustomer5);

        Account endCustomer6 = TestUtility.createEndCustomerAccount('Danone Poland End Customer 6'); //Customer location test record
        endCustomer6.Distributor__c = commercialCustomers.get(1).Id;
        endCustomer6.Distributor_Location__c = customerLocs.get(3).Id;
        endCustomers.add(endCustomer6);

        insert endCustomers;

        Test.stopTest();

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(0).Id]; //AccountShare list to check the sharing
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(4, accShare.size()); // extra 3 coming from additional country responsibility = Italy

        List<AccountShare> accShare1 = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(1, accShare1.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(3).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(4, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(5).Id];
        System.assertEquals(2, accShare.size());
    }

    /* @Description

    Test if updated end customers are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldShareEndCustomersOnUpdate() {

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%', '%H1 Azelis%'}; //Commercial customer names list to retrieve those accounts
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames]; //Commercial customers list to retrieve from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //Customer location names list to retrieve those accounts
        List<Account> customerLocs = [SELECT Id,Name FROM Account WHERE Name LIKE :customerLocNames]; //Customer locations list to retrieve from the database
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%','%TestDanoneManager%'}; //User names list to retrieve those users
        List<User> users = [SELECT Id,UserName FROM User WHERE UserName LIKE :userNames]; //Users list to retrieve from the database

        List<String> endCustomerNames = new List<String>{'%End Customer IMCD Italy Spa UPD 1%','%End Customer IMCD Italy Spa UPD 2%'}; //End customer names list to retrieve those accounts
        List<Account> endCustomers = [SELECT Id, Distributor_Location__c FROM Account WHERE Name LIKE :endCustomerNames]; //End customers list to retrieve from the database

        Test.startTest();     

        endCustomers.get(0).Distributor_Location__c = customerLocs.get(1).Id; //Changed to IMCD France Spa
        endCustomers.get(1).Distributor_Location__c = customerLocs.get(2).Id; //Changed to IMCD Poland Spa

        update endCustomers;

        Test.stopTest();

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(0).Id]; //AccountShare list to check the sharing
        System.assertEquals(0, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(2, accShare.size()); // 1 coming from additional country responsibility = Italy

        List<AccountShare> accShare1 = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(1, accShare1.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(3).Id];
        System.assertEquals(0, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(5).Id];
        System.assertEquals(0, accShare.size());
    }

    /* @Description

    Test if updated end customers have their sharing revoked for partner users properly

    @return void
    */
    @isTest
    static void shouldRevokeAllEndCustomerAccessOnUpdate() {

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%', '%H1 Azelis%'}; //Commercial customer names list to retrieve those accounts
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames]; //Commercial customers list to retrieve from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //Customer location names list to retrieve those accounts
        List<Account> customerLocs = [SELECT Id,Name FROM Account WHERE Name LIKE :customerLocNames]; //Customer locations list to retrieve from the database
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%','%TestDanoneManager%'}; //User names list to retrieve those users
        List<User> users = [SELECT Id,UserName FROM User WHERE UserName LIKE :userNames]; //Users list to retrieve from the database

        List<String> endCustomerNames = new List<String>{'%End Customer IMCD Italy Spa UPD 1%','%End Customer IMCD Italy Spa UPD 2%'}; //End customer names list to retrieve those accounts
        List<Account> endCustomers = [SELECT Id, RecordTypeId FROM Account WHERE Name LIKE :endCustomerNames]; //End customers list to retrieve from the database

        Test.startTest();     

        endCustomers.get(0).RecordTypeId = Constants.ACCOUNT_RECORD_TYPE_PROSPECT_ID;
        endCustomers.get(1).RecordTypeId = Constants.ACCOUNT_RECORD_TYPE_PROSPECT_ID;

        update endCustomers;

        Test.stopTest();

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(0).Id]; //AccountShare list to check the sharing
        System.assertEquals(0, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(0, accShare.size()); // 1 coming from additional country responsibility = Italy

        List<AccountShare> accShare1 = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(0, accShare1.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(3).Id];
        System.assertEquals(0, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(0, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: endCustomers AND UserOrGroupId = :users.get(5).Id];
        System.assertEquals(0, accShare.size());
    }
    
    /* @Description

    Test if the opportunities sharing are maintained on account update

    @return void
    */
   /* @isTest
    static void shouldKeepOpportunitySharingOnAccountUpdate(){

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%'}; //String list of Commercial Customers names
        List<Account> commercialCustomers = [SELECT Id, Name FROM Account WHERE Name LIKE :commercialCustomerNames];  //Accounts list to retrieve Commercial customers from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //String list of Customer Locations names
        List<Account> customerLocs = [SELECT Id, Name FROM Account WHERE Name LIKE :customerLocNames];  //Accounts list to retrieve Customer Locations from the database

        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%'};  //String list of partner users names
        List<User> users = [SELECT Id, Contact.Account.Name FROM User WHERE UserName LIKE :userNames];  //Users list to retrieve partner users from the database

        Contact cPolandAddCountryRespItaly = TestUtility.createContact(commercialCustomers.get(0),  customerLocs.get(2)); //Contact test record
        cPolandAddCountryRespItaly.Additional_Country_Responsibility__c = 'Italy';
        insert cPolandAddCountryRespItaly;

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrPolandAddCountryRespItaly.ContactId = cPolandAddCountryRespItaly.Id;

        User sysAdmin = TestUtility.createUser('TestSysAdmin@fci.test.com', 'System Administrator'); //User to avoid mixed DML error
        sysAdmin.UserRoleId = UserInfo.getUserRoleId();

        System.runAs(TestUtility.createUser('TestSysAdmin2@fci.test.com', 'System Administrator')){
            insert new List<User>{sysAdmin, usrPolandAddCountryRespItaly};
        }        

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCustomers.get(0), customerLocs.get(0)); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppItaly2 = TestUtility.createFCINewBusinessOpportunity('testOppname2', commercialCustomers.get(0), customerLocs.get(0)); //Opportunity test record
        oppsToInsert.add(oppItaly2);

        insert oppsToInsert;

        update new Opportunity(Id = oppItaly2.Id, OwnerId = sysAdmin.Id);

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :users.get(0).Id]; //OpportunityShare list to check the sharing
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, oppShare.size());

        Test.startTest();

        customerLocs.get(0).OwnerId = sysAdmin.Id;

        update customerLocs.get(0);

        Test.stopTest();

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :users.get(0).Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppItaly2.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, oppShare.size());
    }*/
 
    /* @Description

    Test if the cases sharing are maintained on account update

    @return void
    */
    @isTest
    static void shouldKeepCaseSharingOnAccountUpdate(){
		Test.startTest();
        
        TriggerHandler.skipTrigger = true;

        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%'}; //String list of Commercial Customers names
        List<Account> commercialCustomers = [SELECT Id, Name FROM Account WHERE Name LIKE :commercialCustomerNames];  //Accounts list to retrieve Commercial customers from the database

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'}; //String list of Customer Locations names
        List<Account> customerLocs = [SELECT Id, Name FROM Account WHERE Name LIKE :customerLocNames];  //Accounts list to retrieve Customer Locations from the database

        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%'};  //String list of partner users names
        List<User> users = [SELECT Id, Contact.Account.Name FROM User WHERE UserName LIKE :userNames];  //Users list to retrieve partner users from the database

        Contact cPolandAddCountryRespItaly = TestUtility.createContact(commercialCustomers.get(0),  customerLocs.get(2)); //Contact test record
        cPolandAddCountryRespItaly.Additional_Country_Responsibility__c = 'Italy';
        insert cPolandAddCountryRespItaly;

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrPolandAddCountryRespItaly.ContactId = cPolandAddCountryRespItaly.Id;

        User sysAdmin = TestUtility.createUser('TestSysAdmin@fci.test.com', 'System Administrator'); //User to avoid mixed DML error
        sysAdmin.UserRoleId = UserInfo.getUserRoleId();

        System.runAs(TestUtility.createUser('TestSysAdmin2@fci.test.com', 'System Administrator')){
            insert new List<User>{sysAdmin, usrPolandAddCountryRespItaly};
        }       

        List<Case> casesToInsert = new List<Case>(); //Cases list to test
        Case csItaly = TestUtility.createCase('testCase','testDescription',  commercialCustomers.get(0), customerLocs.get(0)); //Case test record
        casesToInsert.add(csItaly);

        // Case csItaly2 = TestUtility.createCase('testCase2','testDescription',  commercialCustomers.get(0), customerLocs.get(0)); //Case test record
        // casesToInsert.add(csItaly2);

        System.runAs(users.get(4)){

            insert casesToInsert;
        }        

        update new Case(Id = csItaly.Id, OwnerId = sysAdmin.Id);
        
        TriggerHandler.skipTrigger = false;

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :users.get(0).Id]; //CaseShare list to check the sharing
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(1, csShare.size()); //RelatedPortal user and "Manual" share

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id]; 
        System.assertEquals(0, csShare.size());

        
        
        customerLocs.get(0).OwnerId = sysAdmin.Id;

        update customerLocs.get(0);

        Test.stopTest();

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :users.get(0).Id];
        System.assertEquals(1, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(1, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(2, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(1, csShare.size());
    }
    
    @isTest
    static void shouldLogErrorWhenInactiveUserIsUpdatedAsEndCustomerOwner(){
    	
        TriggerHandler.skipTrigger = true;
        //Create the Commercial Customer account
        Account parentAcc1 = TestUtility.createCommercialCustomer('H1 Account Test');
        insert parentAcc1;
             //Create the  CustomerLocation account
        Account childAcc1 = TestUtility.createCustomerLocation('H5 Account Test',parentAcc1);
        childAcc1.Name = 'IMCD Blah Blah';
        insert childAcc1;
        
        List<User> usrs = new List<User>();
        //Create the users and add Business segment to users
        User usr1 = TestUtility.createUser('testUser1@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Industry';
        usrs.add(usr1);
        
        User usr2 = TestUtility.createUser('testUser2@flc.com.test.SA', 'System Administrator');
        usr2.Business_Segment__c='Cheese';
        usrs.add(usr2);
        insert usrs;
        
        User h5ownerUser = TestUtility.createUser('testUser222@flc.com.test.SA', 'System Administrator');
        h5ownerUser.Business_Segment__c='';
        h5ownerUser.isactive=false;
        insert h5ownerUser;  
        
        childAcc1.OwnerId = usrs[0].id;
        update childAcc1;
        
        
        //update h5ownerUser;
        
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        //teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr1, childAcc1, Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER, ''));
        teamMembers.add(TestUtility.createAccountTeamMember_Custom(usr2, childAcc1, Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER, ''));
        
        insert teamMembers;
        UpdateAccountOwner.logError('', '', '', '', '', '', '', '', '', '', '');
       // UpdateAccountOwnerQueue.logError('', '', '', '', '', '', '', '', '', '', '');
        
        List<Account> endCustomers = new List<Account>(); //End customers list to test

        Account endCustomer1 = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 1 ');
        endCustomer1.Distributor__c = parentAcc1.Id;
        endCustomer1.Distributor_Location__c = childAcc1.Id;
        endCustomer1.business_segment__c='Cheese';
        endCustomers.add(endCustomer1);
        insert endCustomer1;
        
        endCustomer1.Business_Segment__c='Milkpowder';
        update endCustomer1;
      
        TriggerHandler.skipTrigger = false;

    }

	@isTest
    static void shouldUpdateEndCustomerOwnerWithBusinessSegment(){
        TriggerHandler.skipTrigger = true;
        //Create the Commercial Customer account
        Account parentAcc1 = TestUtility.createCommercialCustomer('H1 Account Test');
        insert parentAcc1;
             //Create the  CustomerLocation account
        Account childAcc1 = TestUtility.createCustomerLocation('H5 Account Test',parentAcc1);
        childAcc1.Name = 'IMCD Blah Blah';
        insert childAcc1;
        
        List<User> usrs = new List<User>();
        //Create the users and add Business segment to users
        User usr1 = TestUtility.createUser('testUser1@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Industry';
        usrs.add(usr1);
        
        User usr2 = TestUtility.createUser('testUser2@flc.com.test.SA', 'System Administrator');
        usr1.Business_Segment__c='Cheese';
        usrs.add(usr2);
        insert usrs;
        
        User h5ownerUser = TestUtility.createUser('testUser222@flc.com.test.SA', 'System Administrator');
        h5ownerUser.FirstName = 'SAP PO';
        h5ownerUser.LastName = 'User';
        h5ownerUser.Business_Segment__c='Cheese';
        insert h5ownerUser;  
        
        childAcc1.OwnerId = usrs[0].id;
        update childAcc1;
        
        
        //update h5ownerUser;
        
        List<Account_Team__c> teamMembers = new List<Account_Team__c>();
        Account_Team__c teamMember1 = TestUtility.createAccountTeamMember_Custom(usr1, childAcc1, Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER, 'Cheese');
        teamMember1.Primary__c = true;
        teamMembers.add(teamMember1);
        
        Account_Team__c teamMember2 = TestUtility.createAccountTeamMember_Custom(usr2, childAcc1, Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER, 'Milkpowder');
        teamMember2.Primary__c = true;
        teamMembers.add(teamMember2);
        
        insert teamMembers;
        UpdateAccountOwner.logError('', '', '', '', '', '', '', '', '', '', '');
       // UpdateAccountOwnerQueue.logError('', '', '', '', '', '', '', '', '', '', '');
        TriggerHandler.skipTrigger = false;
        List<Account> endCustomers = new List<Account>(); //End customers list to test

        Account endCustomer1 = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 1 ');
        endCustomer1.Distributor__c = parentAcc1.Id;
        endCustomer1.Distributor_Location__c = childAcc1.Id;
        endCustomer1.business_segment__c='Cheese';
        endCustomers.add(endCustomer1);
        Test.startTest();
        insert endCustomer1;
        system.assertEquals(usr1.Id, [SELECT OwnerId FROM Account WHERE Id=:endCustomer1.Id].OwnerId);
        endCustomer1.Business_Segment__c='Milkpowder';
        update endCustomer1;
        Test.stopTest();
    }    
}