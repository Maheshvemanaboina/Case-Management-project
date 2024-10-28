/**
 * Created by KJM on 29/07/2019.
 */

@isTest
public class AccountSharingRecalculationTest {

    @TestSetup
    static void setupData(){
        
        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCustIMCD = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCustIMCD);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA');
        accsCustomLocToInsert.add(commercialCustDanone);

        insert accsCustomLocToInsert;

        List<Account> accsToInsert = new List<Account>();
        Account customerLocIMCDItaly                = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCustIMCD);
        customerLocIMCDItaly.BillingCountry         = 'Italy';
        customerLocIMCDItaly.BillingCountryCode     = 'IT';
        accsToInsert.add(customerLocIMCDItaly);

        Account customerLocIMCDFrance               = TestUtility.createCustomerLocation('IMCD France Spa', commercialCustIMCD);
        customerLocIMCDFrance.BillingCountry        = 'Australia';
        customerLocIMCDFrance.BillingCountryCode    = 'AU';
        accsToInsert.add(customerLocIMCDFrance);

        Account customerLocIMCDPoland               = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCustIMCD);
        customerLocIMCDPoland.BillingCountry        = 'Poland';
        customerLocIMCDPoland.BillingCountryCode    = 'PL';
        accsToInsert.add(customerLocIMCDPoland);

        Account customerLocDanone                   = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone);
        customerLocDanone.BillingCountry            = 'Poland';
        customerLocDanone.BillingCountryCode        = 'PL';
        accsToInsert.add(customerLocDanone);
        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>();

        Contact cItalySU            = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly);
        contactsToInsert.add(cItalySU);

        Contact cFranceSU           = TestUtility.createContact(commercialCustIMCD, customerLocIMCDFrance);
        contactsToInsert.add(cFranceSU);

        Contact cPolandSU           = TestUtility.createContact(commercialCustIMCD, customerLocIMCDPoland);
        contactsToInsert.add(cPolandSU);

        Contact cDanonePolandSubSU  = TestUtility.createContact(commercialCustDanone, customerLocDanone);
        contactsToInsert.add(cDanonePolandSubSU);

        Contact cIMCDMU             = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly);
        contactsToInsert.add(cIMCDMU);

        Contact cDanonePolandMU     = TestUtility.createContact(commercialCustDanone, customerLocDanone);
        contactsToInsert.add(cDanonePolandMU);

        Contact cDanonePolandAppMU  = TestUtility.createContact(commercialCustDanone, customerLocDanone);
        contactsToInsert.add(cDanonePolandAppMU);

        Contact cDanonePolandAppSU  = TestUtility.createContact(commercialCustDanone, customerLocDanone);
        contactsToInsert.add(cDanonePolandAppSU);

        insert contactsToInsert;

        List<User> usersToInsert = new List<User>();
        User usrIMCDItalySU         = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrIMCDItalySU.ContactId    = cItalySU.Id;
        usersToInsert.add(usrIMCDItalySU);

        User usrIMCDFranceSU        = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceGG', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrIMCDFranceSU.ContactId   = cFranceSU.Id;
        usersToInsert.add(usrIMCDFranceSU);

        User usrIMCDPolandSU        = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrIMCDPolandSU.ContactId   = cPolandSU.Id;
        usersToInsert.add(usrIMCDPolandSU);

        User usrDanonePolandSubSU   = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrDanonePolandSubSU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT;
        usrDanonePolandSubSU.ContactId = cDanonePolandSubSU.Id;
        usersToInsert.add(usrDanonePolandSubSU);

        User usrIMCDMU              = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrIMCDMU.ContactId         = cIMCDMU.Id;
        usersToInsert.add(usrIMCDMU);

        User usrDanonePolandSubMU   = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrDanonePolandSubMU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT;
        usrDanonePolandSubMU.ContactId = cDanonePolandMU.Id;
        usersToInsert.add(usrDanonePolandSubMU);

        User usrDanonePolandAppMU   = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneAppManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrDanonePolandAppMU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION;
        usrDanonePolandAppMU.ContactId = cDanonePolandAppMU.Id;
        usersToInsert.add(usrDanonePolandAppMU);

        User usrDanonePolandAppSU   = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanoneAppStandard', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrDanonePolandAppSU.Community_Account_Role__c = Constants.USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION;
        usrDanonePolandAppSU.ContactId = cDanonePolandAppSU.Id;
        usersToInsert.add(usrDanonePolandAppSU);

        insert usersToInsert;

        TriggerHandler.skipTrigger = true;

        List<Account> accsToCalculateInsert = new List<Account>();

        /* Inserting FCI End Customers */

        Account endCustomer1                    = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 1');
        endCustomer1.Distributor__c             = commercialCustIMCD.Id;
        endCustomer1.Distributor_Location__c    = customerLocIMCDItaly.Id;
        accsToCalculateInsert.add(endCustomer1);

        Account endCustomer2                    = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 2');
        endCustomer2.Distributor__c             = commercialCustIMCD.Id;
        endCustomer2.Distributor_Location__c    = customerLocIMCDItaly.Id;
        accsToCalculateInsert.add(endCustomer2);

        Account endCustomer3                    = TestUtility.createEndCustomerAccount('IMCD France Spa End Customer 3');
        endCustomer3.Distributor__c             = commercialCustIMCD.Id;
        endCustomer3.Distributor_Location__c    = customerLocIMCDFrance.Id;
        accsToCalculateInsert.add(endCustomer3);

        Account endCustomer4                    = TestUtility.createEndCustomerAccount('IMCD Poland Spa End Customer 4');
        endCustomer4.Distributor__c             = commercialCustIMCD.Id;
        endCustomer4.Distributor_Location__c    = customerLocIMCDPoland.Id;
        accsToCalculateInsert.add(endCustomer4);

        Account endCustomer5                    = TestUtility.createEndCustomerAccount('Danone Poland End Customer 5');
        endCustomer5.Distributor__c             = commercialCustDanone.Id;
        endCustomer5.Distributor_Location__c    = customerLocDanone.Id;
        accsToCalculateInsert.add(endCustomer5);

        Account endCustomer6                    = TestUtility.createEndCustomerAccount('Danone Poland End Customer 6');
        endCustomer6.Distributor__c             = commercialCustDanone.Id;
        endCustomer6.Distributor_Location__c    = customerLocDanone.Id;
        accsToCalculateInsert.add(endCustomer6);

        /* Inserting FCI Direct Customers */

        Account FCIDirectItaly              = TestUtility.createCustomerLocation('FCI Direct Italy', commercialCustDanone);
        FCIDirectItaly.BillingCountry       = 'Italy';
        FCIDirectItaly.BillingCountryCode   = 'IT';
        FCIDirectItaly.Type                 = 'Direct Customer';
        FCIDirectItaly.Partner_Role__c      = 'Sold-to';
        FCIDirectItaly.Sub_Segment__c       = 'Beverages';
        FCIDirectItaly.Application__c       = 'DMV: Bakery';
        accsToCalculateInsert.add(FCIDirectItaly);

        Account FCIDirectAus                = TestUtility.createCustomerLocation('FCI Direct Australia', commercialCustIMCD);
        FCIDirectAus.BillingCountry         = 'Australia';
        FCIDirectAus.BillingCountryCode     = 'AU';
        FCIDirectAus.Type                   = 'Direct Customer';
        FCIDirectAus.Partner_Role__c        = 'Sold-to';
        FCIDirectAus.Sub_Segment__c         = 'Beverages';
        FCIDirectAus.Application__c         = 'Other';
        accsToCalculateInsert.add(FCIDirectAus);

        Account FCIDirectIndia              = TestUtility.createCustomerLocation('FCI Direct India', commercialCustDanone);
        FCIDirectIndia.BillingCountry       = 'India';
        FCIDirectIndia.BillingCountryCode   = 'IN';
        FCIDirectIndia.Type                 = 'Direct Customer';
        FCIDirectIndia.Partner_Role__c      = 'Sold-to';
        FCIDirectIndia.Sub_Segment__c       = 'Beverages';
        FCIDirectIndia.Application__c       = 'DMV: Bakery';
        accsToCalculateInsert.add(FCIDirectIndia);

        insert accsToCalculateInsert;

        TriggerHandler.skipTrigger = false;
    }

    @isTest
    static void shouldRecalculateAccountSharing() {
        
        List<String> commercialCustomerNames = new List<String>{'%IMCD Holding%','%Danone SA%'};
        List<Account> commercialCustomers = [SELECT Id FROM Account WHERE Name LIKE :commercialCustomerNames];

        List<String> customerLocNames = new List<String>{'%IMCD Italy Spa%','%IMCD France Spa%','%IMCD Poland Spa%','%Danone Poland%'};
        List<Account> customerLocs = [SELECT Id,Name FROM Account WHERE Name LIKE :customerLocNames];
        
        List<String> userNames = new List<String>{'%TestIMCDItaly%','%TestIMCDFranceGG%','%TestIMCDPoland%','%TestDanonePoland%','%TestIMCDManager%','%TestDanoneManager%'};
        List<User> users = [SELECT Id,UserName FROM User WHERE UserName LIKE :userNames];

        List<String> endCustomerNames = new List<String>{'%IMCD Italy Spa End Customer 1%','%IMCD Italy Spa End Customer 2%', '%IMCD France Spa End Customer 3%', '%IMCD Poland Spa End Customer 4%','%Danone Poland End Customer 5%','%Danone Poland End Customer 6%'};
        List<Account> endCustomers = [SELECT Id, Distributor_Location__c FROM Account WHERE Name LIKE :endCustomerNames];

        
        List<String> directCustomersNames = new List<String>{'%FCI Direct Italy%','%FCI Direct Australia%', '%FCI Direct India%'};
        List<Account> directCustomers = [SELECT Id FROM Account WHERE Name LIKE :directCustomersNames];

        Set<Id> allAccountIds = new Set<Id>();
        allAccountIds.addAll((new Map<Id,SObject>(customerLocs)).keySet());
        allAccountIds.addAll((new Map<Id,SObject>(endCustomers)).keySet());
        allAccountIds.addAll((new Map<Id,SObject>(directCustomers)).keySet());

        Test.startTest();

        Database.executeBatch(new AccountSharingRecalculation());

        Test.stopTest();

        /* Create Share for Partner contacts for their own accounts as it is not shared automatically in Test class */
        List<AccountShare> accShares = new List<AccountShare>();
        accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(0).Id, users.get(0).Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(1).Id, users.get(1).Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(2).Id, users.get(2).Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(3).Id, users.get(3).Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(0).Id, users.get(4).Id, 'READ', 'Manual'));
        accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(3).Id, users.get(5).Id, 'READ', 'Manual'));
        //accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(3).Id, usrDanonePolandAppMU.Id, 'READ', 'Manual'));
        //accShares.add(AccountSharingUtility.getAccountShare(customerLocs.get(3).Id, usrDanonePolandAppSU.Id, 'READ', 'Manual'));

        insert accShares;

        List<AccountShare> accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: allAccountIds AND UserOrGroupId = :users.get(0).Id];
        System.assertEquals(4, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: allAccountIds AND UserOrGroupId = :users.get(1).Id];
        System.assertEquals(3, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: allAccountIds AND UserOrGroupId = :users.get(2).Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: allAccountIds AND UserOrGroupId = :users.get(3).Id];
        System.assertEquals(3, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: allAccountIds AND UserOrGroupId = :users.get(4).Id];
        System.assertEquals(9, accShare.size());

        accShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN: allAccountIds AND UserOrGroupId = :users.get(5).Id];
        System.assertEquals(5, accShare.size());

        // csShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id, :commercialCust.Id, :commercialCustDanone.Id) AND UserOrGroupId = :usrFrance.Id];
        // System.assertEquals(1, csShare.size());
        // System.assertEquals(customerLocFrance.Id, csShare.get(0).AccountId);

        // csShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id, :commercialCust.Id, :commercialCustDanone.Id) AND UserOrGroupId = :usrPoland.Id];
        // System.assertEquals(1, csShare.size());
        // System.assertEquals(customerLocPoland.Id, csShare.get(0).AccountId);

        // csShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id, :commercialCust.Id, :commercialCustDanone.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        // System.assertEquals(1, csShare.size());
        // System.assertEquals(customerLocDanone.Id, csShare.get(0).AccountId);

        // csShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id, :commercialCust.Id, :commercialCustDanone.Id) AND UserOrGroupId = :usrManager.Id];
        // System.assertEquals(3, csShare.size());
    }
}