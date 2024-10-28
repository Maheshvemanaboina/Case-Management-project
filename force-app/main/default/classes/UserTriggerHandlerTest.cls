/*      
@Name                  UserTriggerHandlerTest
@Author                KJM
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           29-07-2019
@UsedBy                
@Description           Test class for the UserTrigger
@Changes
UserId          | Author-Email                        | Date       | Comment
================|=====================================|============|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt    | 04.03.2021 | Updated to meet the new sharing requirements of the account redesign
XXXXXXXXXXXXXXX | mahendra.kumar@frieslandcampina.com | 25.03.2022 | Updated to assign the Distributor Location field permission (for all KPIs) to standard community user based on Additional Country Responsibility of associated contact
XXXXXXXXXXXXXXX | mahendra.kumar@frieslandcampina.com | 22.04.2022 | Updated to test assigning/removing permission set when the community user role is updated in FCI Distributor Community User records
*/
@isTest
public class UserTriggerHandlerTest {

    /* @Description

    Test setup to create some test records

    @return void
    */
    private static void setupData() {

        /* Create H1 (Commercial customers) */
        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        commercialCust.Active__c=true;
        
        accsCommercCustToInsert.add(commercialCust);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA'); //Commercial customer test record
          commercialCustDanone.Active__c=true;
        accsCommercCustToInsert.add(commercialCustDanone);
      
        insert accsCommercCustToInsert;

        /* Create customer locations (H5) to associate it to H1 and used for partner user creation */
        List<Account> accsToInsert = new List<Account>(); //Customer locations list to be created
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust); //Customer location test record
        customerLocItaly.BillingStreet = null;
        customerLocItaly.BillingPostalCode = null;
        customerLocItaly.BillingCity = null;
        customerLocItaly.BillingCountryCode = null;
        customerLocItaly.BillingCountry = 'Italy';
        customerLocItaly.Active__c=true;
        customerLocItaly.Partner_Role__c='Sold-to';
        accsToInsert.add(customerLocItaly);

        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust); //Customer location test record
        customerLocFrance.BillingStreet = null;
        customerLocFrance.BillingPostalCode = null;
        customerLocFrance.BillingCity = null;
        customerLocFrance.BillingCountryCode = null;
        customerLocFrance.BillingCountry = 'France';
        customerLocFrance.Active__c=true;
        customerLocFrance.Partner_Role__c='Sold-to';
        accsToInsert.add(customerLocFrance);

        Account customerLocPoland = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCust); //Customer location test record
        customerLocPoland.BillingStreet = null;
        customerLocPoland.BillingPostalCode = null;
        customerLocPoland.BillingCity = null;
        customerLocPoland.BillingCountryCode = null;
        customerLocPoland.BillingCountry = 'Poland';
            customerLocPoland.Active__c=true;
        customerLocPoland.Partner_Role__c='Sold-to';
        accsToInsert.add(customerLocPoland);

        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone); //Customer location test record
        customerLocDanone.BillingStreet = null;
        customerLocDanone.BillingPostalCode = null;
        customerLocDanone.BillingCity = null;
        customerLocDanone.BillingCountryCode = null;
        customerLocDanone.BillingCountry = 'Poland';
             customerLocDanone.Active__c=true;
        customerLocDanone.Partner_Role__c='Sold-to';
        accsToInsert.add(customerLocDanone);

        insert accsToInsert;

        /* Create Partner Cntacts to enable them as users */
        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created

        Contact cItaly = TestUtility.createContact('italyCont' , 'italyCont', commercialCust, customerLocItaly); //Contact test record
        cItaly.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cItaly);

        Contact cFrance = TestUtility.createContact('franceCont', 'franceCont', commercialCust, customerLocFrance); //Contact test record
        cFrance.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cFrance);

        Contact cFranceAddCountryRespItalyPoland = TestUtility.createContact('franceContAddRespItalyPoland', 'franceContAddRespItalyPoland', commercialCust, customerLocFrance); //Contact test record
        cFranceAddCountryRespItalyPoland.Additional_Country_Responsibility__c = 'Italy;Poland';
        contactsToInsert.add(cFranceAddCountryRespItalyPoland);

        Contact cPoland = TestUtility.createContact('polandCont', 'polandCont', commercialCust, customerLocPoland); //Contact test record
        cPoland.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cPoland);

        Contact cPolandAddCountryRespItaly = TestUtility.createContact('polandContAddRespItaly', 'polandContAddRespItaly', commercialCust, customerLocPoland); //Contact test record
        cPolandAddCountryRespItaly.Additional_Country_Responsibility__c = 'Italy';
        contactsToInsert.add(cPolandAddCountryRespItaly);

        Contact cDanonePoland = TestUtility.createContact('danonePolandCont', 'danonePolandCont', commercialCustDanone, customerLocDanone); //Contact test record
        cDanonePoland.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cDanonePoland);

        Contact cDanoneManager = TestUtility.createContact('danonePolandManager', 'danonePolandManager', commercialCustDanone, customerLocDanone); //Contact test record
        cDanoneManager.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cDanoneManager);

        Contact cManagerItaly = TestUtility.createContact('managerContItaly', 'managerContItaly', commercialCust, customerLocItaly); //Contact test record
        cManagerItaly.Additional_Country_Responsibility__c = 'France';
        contactsToInsert.add(cManagerItaly);

        Contact cManagerItaly2 = TestUtility.createContact('managerContItaly2', 'managerContItaly2', commercialCust, customerLocItaly); //Contact test record
        contactsToInsert.add(cManagerItaly2);

        Contact cManagerFrance = TestUtility.createContact('managerContFrance', 'managerContFrance', commercialCust, customerLocFrance); //Contact test record
        cManagerFrance.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cManagerFrance);
        insert contactsToInsert;

        User usrManagerItaly2 = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager2Italy', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly2.ContactId = cManagerItaly2.Id;
        insert usrManagerItaly2;

        /* Create End Customer Accounts */
        List<Account> endCustomers = new List<Account>(); //End customers list to be created

        Account endCustomer1 = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 1'); //End customer test record
       	endCustomer1.Distributor__c = commercialCust.Id; 
        endCustomer1.Distributor_Location__c = customerLocItaly.Id;
        endCustomer1.BillingStreet = null;
        endCustomer1.BillingPostalCode = null;
        endCustomer1.BillingCity = null;
        endCustomer1.BillingCountryCode = null;
        endCustomer1.BillingCountry = 'Italy';
        endCustomers.add(endCustomer1);
		
        
        Account endCustomer2 = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Customer 2'); //End customer test record
      	endCustomer2.Distributor__c = commercialCust.Id; 
        endCustomer2.Distributor_Location__c = customerLocItaly.Id;
        endCustomer2.BillingStreet = null;
        endCustomer2.BillingPostalCode = null;
        endCustomer2.BillingCity = null;
        endCustomer2.BillingCountryCode = null;
        endCustomer2.BillingCountry = 'Italy';
           endCustomer2.Active__c=true;
        endCustomer2.Partner_Role__c='Sold-to';
        endCustomers.add(endCustomer2);

        Account endCustomer3 = TestUtility.createEndCustomerAccount('IMCD France Spa End Customer 3'); //End customer test record
      	endCustomer3.Distributor__c = commercialCust.Id;
        endCustomer3.Distributor_Location__c = customerLocFrance.Id;
        endCustomer3.BillingStreet = null;
        endCustomer3.BillingPostalCode = null;
        endCustomer3.BillingCity = null;
        endCustomer3.BillingCountryCode = null;
        endCustomer3.BillingCountry = 'France';
              endCustomer3.Active__c=true;
        endCustomer3.Partner_Role__c='Sold-to';
        endCustomers.add(endCustomer3);

        Account endCustomer4 = TestUtility.createEndCustomerAccount('IMCD Poland Spa End Customer 4'); //End customer test record
      	endCustomer4.Distributor__c = commercialCust.Id;
        endCustomer4.Distributor_Location__c = customerLocPoland.Id;
        endCustomer4.BillingStreet = null;
        endCustomer4.BillingPostalCode = null;
        endCustomer4.BillingCity = null;
        endCustomer4.BillingCountryCode = null;
        endCustomer4.BillingCountry = 'Poland';
             endCustomer4.Active__c=true;
        endCustomer4.Partner_Role__c='Sold-to';
        endCustomers.add(endCustomer4);

        Account endCustomer5 = TestUtility.createEndCustomerAccount('Danone Poland End Customer 5'); //End customer test record
       	endCustomer5.Distributor__c =commercialCustDanone.Id;
        endCustomer5.Distributor_Location__c = customerLocDanone.Id;
        endCustomer5.BillingStreet = null;
        endCustomer5.BillingPostalCode = null;
        endCustomer5.BillingCity = null;
        endCustomer5.BillingCountryCode = null;
        endCustomer5.BillingCountry = 'Poland';
             endCustomer5.Active__c=true;
        endCustomer5.Partner_Role__c='Sold-to';
        endCustomers.add(endCustomer5);

        Account endCustomer6 = TestUtility.createEndCustomerAccount('Danone Poland End Customer 6'); //End customer test record
      	endCustomer6.Distributor__c =  commercialCustDanone.Id;
        endCustomer6.Distributor_Location__c =customerLocDanone.Id;
        endCustomer6.BillingStreet = null;
        endCustomer6.BillingPostalCode = null;
        endCustomer6.BillingCity = null;
        endCustomer6.BillingCountryCode = null;
        endCustomer6.BillingCountry = 'Poland';
             endCustomer6.Active__c=true;
        endCustomer6.Partner_Role__c='Sold-to';
        endCustomers.add(endCustomer6);

        insert endCustomers;
    }

    /* @Description

    Test if account are shared properly with partner users on user creation

    @return void
    */
    @isTest
    static void shouldCreateAccountSharingOnUserCreation(){

        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        /* Fetching End Customers */
        Account italyIMCDEndCustomer1   = accsMap.get('IMCD Italy Spa End Customer 1'); //End customer test record
        Account italyIMCDEndCustomer2   = accsMap.get('IMCD Italy Spa End Customer 2'); //End customer test record
        Account franceIMCDEndCustomer3  = accsMap.get('IMCD France Spa End Customer 3'); //End customer test record
        Account polandIMCDEndCustomer4  = accsMap.get('IMCD Poland Spa End Customer 4'); //End customer test record
        Account polandDanEndCustomer5   = accsMap.get('Danone Poland End Customer 5'); //End customer test record
        Account polandDanEndCustomer6   = accsMap.get('Danone Poland End Customer 6'); //End customer test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        Test.startTest();

        insert usersToInsert;

        Test.stopTest();

        List<AccountShare> accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrItaly.Id]; //AccountShare list to check the sharing
        System.assertEquals(3, accShares.size());

        accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(2, accShares.size());

        accShares = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(7, accShares.size());

        accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(2, accShares.size());

        accShares = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(5, accShares.size());

        accShares = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(3, accShares.size());

        accShares = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrManagerdanonePoland.Id];
        System.assertEquals(4, accShares.size());

        accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(8, accShares.size());

        accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(8, accShares.size());
    }

    /* @Description

    Test if the records are shared properly with partner users on community role change between standard user, manager user and user reactivation

    @return void
    */
    @isTest
    static void shouldRecalculateAccountSharingOnCommunityRoleChangeSUToMUAndMUToSUAndUserReactivation(){
		TriggerHandler.SkipTrigger = true;
        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id FROM Account]; //Accounts list to retrieve from the database
        for (Account acc : accs) {
            accIds.add(acc.Id);
        }

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont       = conMap.get('italyCont'); //Contact test record
        Contact italyIMCDManager    = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDCont      = conMap.get('franceCont'); //Contact test record
        
        TriggerHandler.SkipTrigger = false;

        /* Users to Insert & used for Update, SU to MU and MU to SU */
        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);

        
        insert usersToInsert;

        Test.startTest();

        List<User> usersToUpd = new List<User>(); //Users list to be updated

        usrItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_MANAGER_USER;
        usersToUpd.add(usrItaly);

        usrManagerItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_STANDARD_USER;
        usersToUpd.add(usrManagerItaly);
        
        System.runAs(usrAdmin){

            usrFrance.isActive = false;
            update usrFrance;

            usrFrance.isActive = true;
            usersToUpd.add(usrFrance);

            update usersToUpd;
        }

        Test.stopTest();

        List<AccountShare> accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrItaly.Id]; //AccountShare list to check the sharing
        System.assertEquals(8, accShares.size());

        accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(3, accShares.size());

        accShares = [SELECT Id FROM AccountShare WHERE AccountId IN: accIds AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(6, accShares.size());
    }

    /* @Description

    Test if the opportunities on user creation are shared properly with partner users 

    @return void
    */
    @isTest
    static void shouldCreateOpportunitySharingOnUserCreation() {
		TriggerHandler.SkipTrigger = true;
        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocPoland); //Opportunity test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCustDanone, customerLocDanone); //Opportunity test record
        oppsToInsert.add(oppDanonePoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname', [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Current_Business' LIMIT 1].Id, commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);
        insert oppsToInsert;
		TriggerHandler.SkipTrigger = false;
        Test.startTest();

        insert usersToInsert;
		
        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppItaly.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppFrance.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppPoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppDanonePoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, oppShare.size());
    }

    /* @Description

    Test if the opportunities on user community role change are shared properly with partner users 

    @return void
    */
    @isTest
    static void shouldRecalculateOpportunitySharingOnCommunityRoleChangeSUToMUAndMUToSUAndUserReactivation(){

        TriggerHandler.SkipTrigger = true;

        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        italyIMCDCont.Additional_Country_Responsibility__c = null;
        italyIMCDManager.Additional_Country_Responsibility__c = null;

        update new List<Contact>{italyIMCDCont, italyIMCDManager};

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);

        insert usersToInsert;

        TriggerHandler.SkipTrigger = false;

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocPoland); //Opportunity test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCustDanone, customerLocDanone); //Opportunity test record
        oppsToInsert.add(oppDanonePoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname', [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Current_Business' LIMIT 1].Id, commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);

        insert oppsToInsert;

        Test.startTest();

        List<User> usersToUpd = new List<User>(); //Users list to update

        usrItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_MANAGER_USER;
        usersToUpd.add(usrItaly);

        usrManagerItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_STANDARD_USER;
        usersToUpd.add(usrManagerItaly);
        
        System.runAs(usrAdmin){

            usrFrance.isActive = false;
            update usrFrance;

            usrFrance.isActive = true;
            usersToUpd.add(usrFrance);

            update usersToUpd;
        }

        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppFrance.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppPoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppDanonePoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppItaly.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, oppShare.size());
    }

    /* @Description

    Test if the opportunities on contact's Additional Country Responsibility change are shared properly with partner users 

    @return void
    */
    @isTest
    static void shouldRecalculateOpportunitySharingOnContactAdditionalCountryRespChange(){

        TriggerHandler.SkipTrigger = true;

        setupData();
		TriggerHandler.SkipTrigger = false;
        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        //italyIMCDCont.Additional_Country_Responsibility__c = null;
        //italyIMCDManager.Additional_Country_Responsibility__c = null;

        //update new List<Contact>{italyIMCDCont, italyIMCDManager};

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);

        insert usersToInsert;

        //TriggerHandler.SkipTrigger = false;

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocPoland); //Opportunity test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCustDanone, customerLocDanone); //Opportunity test record
        oppsToInsert.add(oppDanonePoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname', [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Current_Business' LIMIT 1].Id, commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);

        insert oppsToInsert;

        Test.startTest();
        
        System.runAs(usrAdmin){

            italyIMCDCont.Additional_Country_Responsibility__c = null;
            italyIMCDManager.Additional_Country_Responsibility__c = null;
            
            update new List<Contact>{italyIMCDCont, italyIMCDManager};
        }

        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(1, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppFrance.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppPoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppDanonePoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(3, oppShare.size());
        System.assertEquals(oppItaly.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, oppShare.size());
    }

    
    /* @Description

    Test if the cases on user creation are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldCreateCaseSharingOnUserCreation() {

        TriggerHandler.skipTrigger = true;

        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        List<Case> casesToInsert = new List<Case>(); //Cases list to test
        Case csItaly = TestUtility.createCase('testCaseSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly);

        Case csFrance = TestUtility.createCase('testCaseSubjectFrance','testDescription', commercialCust, customerLocFrance); //Case test record
        casesToInsert.add(csFrance);

        Case csPoland = TestUtility.createCase('testCaseSubjectPoland','testDescription', commercialCust, customerLocPoland); //Case test record
        casesToInsert.add(csPoland);

        User usrManagerItaly2 = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDManager2Italy%'];

        List<AccountShare> accShares = new List<AccountShare>();
        accShares.add(TestUtility.createAccountShareforPortalUsers( commercialCust, usrManagerItaly2 ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocItaly, usrManagerItaly2 ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocFrance, usrManagerItaly2 ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocPoland, usrManagerItaly2 ));
        insert accShares;

        System.runAs(usrManagerItaly2){

            insert casesToInsert;
        }

        TriggerHandler.skipTrigger = false;

        Test.startTest();

        insert usersToInsert;

        Test.stopTest();

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrItaly.Id]; //CaseShare list to check the sharing
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, csShare.size());
    }
    
    /* @Description

    Test if the cases on user community role change are shared properly with partner users 

    @return void
    */
    @isTest
    static void shouldRecalculateCaseSharingOnCommunityRoleChangeSUToMUAndMUToSUAndUserReactivation(){

        TriggerHandler.skipTrigger = true;

        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        italyIMCDCont.Additional_Country_Responsibility__c = null;
        italyIMCDManager.Additional_Country_Responsibility__c = null;

        update new List<Contact>{italyIMCDCont, italyIMCDManager};

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);

        insert usersToInsert;

        List<AccountShare> accShares = new List<AccountShare>();
        accShares.add(TestUtility.createAccountShareforPortalUsers( commercialCust, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocItaly, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocFrance, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocPoland, usrManagerItaly ));
        insert accShares;

        TriggerHandler.skipTrigger = false;

        List<Case> casesToInsert = new List<Case>(); //Cases list to test
        Case csItaly = TestUtility.createCase('testCaseSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly);

        Case csFrance = TestUtility.createCase('testCaseSubjectFrance','testDescription', commercialCust, customerLocFrance); //Case test record
        casesToInsert.add(csFrance);

        Case csPoland = TestUtility.createCase('testCaseSubjectPoland','testDescription', commercialCust, customerLocPoland); //Case test record
        casesToInsert.add(csPoland);

        System.runAs(usrManagerItaly){

            insert casesToInsert;
        }

        Test.startTest();

        List<User> usersToUpd = new List<User>(); //Users list to update

        usrItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_MANAGER_USER;
        usersToUpd.add(usrItaly);

        usrManagerItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_STANDARD_USER;
        usersToUpd.add(usrManagerItaly);
        
        System.runAs(usrAdmin){
            
            usrFrance.isActive = false;
            update usrFrance;

            usrFrance.isActive = true;
            usersToUpd.add(usrFrance);

            update usersToUpd;
        }

        Test.stopTest();

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrItaly.Id]; //CaseShare list to check the sharing
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(6, csShare.size()); //Related Portal User and Manual RowCause

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, csShare.size());
    }
    
    /* @Description

    Test if the cases on contact's Additional country responsibility change are shared properly with partner users 

    @return void
    */
    @isTest
    static void shouldRecalculateCaseSharingOnContactAdditionalCountryRespChange(){

        TriggerHandler.skipTrigger = true;

        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);

        insert usersToInsert;

        List<AccountShare> accShares = new List<AccountShare>();
        accShares.add(TestUtility.createAccountShareforPortalUsers( commercialCust, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocItaly, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocFrance, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocPoland, usrManagerItaly ));
        insert accShares;

        TriggerHandler.skipTrigger = false;

        List<Case> casesToInsert = new List<Case>(); //Cases list to test
        Case csItaly = TestUtility.createCase('testCaseSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly);

        Case csFrance = TestUtility.createCase('testCaseSubjectFrance','testDescription', commercialCust, customerLocFrance); //Case test record
        casesToInsert.add(csFrance);

        Case csPoland = TestUtility.createCase('testCaseSubjectPoland','testDescription', commercialCust, customerLocPoland); //Case test record
        casesToInsert.add(csPoland);

        System.runAs(usrManagerItaly){

            insert casesToInsert;
        }

        Test.startTest();

        List<User> usersToUpd = new List<User>(); //Users list to update
        
        System.runAs(usrAdmin){
            
            italyIMCDCont.Additional_Country_Responsibility__c = null;
            italyIMCDManager.Additional_Country_Responsibility__c = null;
            
            update new List<Contact>{italyIMCDCont, italyIMCDManager};
        }

        Test.stopTest();

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrItaly.Id]; //CaseShare list to check the sharing
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(6, csShare.size()); //Related Portal User and Manual RowCause

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, csShare.size());
    }
    
    /* @Description
     * Test if the permission set is assigned to the standard community user that is created if the associated contact has Additional
	   country responsibility.
	 * Test if the permission set is assigned to the manager user (FCI Distributor Community User) when the new user is created
	 * Test if the permission set is removed when the community user role of manager user is updated to standard user
	 * Test if the permission set is added when the community user role of standard user is updated to manager user
    @return void
    */
    @isTest
    static void testAssigningOrRemovingPermissionSet(){
        TriggerHandler.skipTrigger = true;
        Test.startTest();
        setupData();
        //Get the permission set id
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Additional_Access_to_Distributor_Community_Manager_Users'][0].Id;
        
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        
        //Get the contacts from database
        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact franceIMCDManager        = conMap.get('managerContFrance'); //Contact test record
        
        TriggerHandler.skipTrigger = false;
        
        //Create new users by associating with the above created contacts
        List<User> usersToInsert = new List<User>();
        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);
        
        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);
        
        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);
        
        //Create Admin User to update the community user role of user record
        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);
        
        List<User> usersToUpd = new List<User>(); //Users list to update
        
        //Test.startTest();
        insert usersToInsert;
        Test.stopTest();
                        
        //Map to store the user's associated contactId as key and user id as value
        Map<Id, Id> userMap = new Map<Id, Id>();
        for(User usr : usersToInsert){
            userMap.put(usr.ContactId, usr.Id);
        }
        
        //Map to store the user id as key and the permission set id assigned as value
        Map<Id, Id> userPermissionSetIdMap = new Map<Id, Id>();
        
        //get the permission set assignments and populate the map
        for(PermissionSetAssignment psa : [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment
                                           WHERE PermissionSetId =: permissionSetId AND
                                           AssigneeId IN: usersToInsert])
        {
            userPermissionSetIdMap.put(psa.AssigneeId, psa.PermissionSetId);
        }
        
        //Verify whether the permission set has been assigned to the newly created users as expected
        system.assertEquals(true, !userPermissionSetIdMap.isEmpty());
        system.assertEquals(permissionSetId, userPermissionSetIdMap.get(userMap.get(franceIMCDAddRespCont.Id)));
        system.assertEquals(permissionSetId, userPermissionSetIdMap.get(userMap.get(polandIMCDAddRespCont.Id)));
        
        //Get the user records with modified community user role
        for(User usr : [SELECT Id, ContactId, Community_User_Role__c FROM User WHERE Id =: usrManagerFrance.Id OR Id =: usrPolandAddCountryRespItaly.Id]){
            if(usr.Id == usrManagerFrance.Id){
                usr.Community_User_Role__c = 'Standard User';
                usersToUpd.add(usr);
            }else if(usr.Id == usrPolandAddCountryRespItaly.Id){
                usr.Community_User_Role__c = 'Manager User';
                usersToUpd.add(usr);
            }
        }
        
        //Update the users' community user role as System Admin
        system.runAs(usrAdmin){
            update usersToUpd;
        }
    }
    
    @isTest
    static void shouldCreateLeadSharingOnUserCreation() {
        TriggerHandler.skipTrigger = true;
        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        // Fetching Commercial Customers & Customer Locations
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);
        
        Id PARTNER_LEAD_RECORD_TYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();// Store partner lead record type Id
		
        TriggerHandler.skipTrigger = false;
        
        List<Lead> leadsToInsert = new List<Lead>(); //Opportunities list to test
        Lead leadItaly = TestUtility.createLead('testCompany', 'Test Lead Italy', customerLocItaly, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadItaly);

        Lead leadFrance = TestUtility.createLead('testCompany', 'Test Lead France', customerLocFrance, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadFrance);

        Lead leadPoland = TestUtility.createLead('testCompany', 'Test Lead Poland', customerLocPoland, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadPoland);

        Lead leadDanonePoland = TestUtility.createLead('testCompany', 'Test Lead DanonePoland', customerLocDanone, commercialCustDanone, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadDanonePoland);

        insert leadsToInsert;

        Test.startTest();

        insert usersToInsert;

        Test.stopTest();
    }
    
    /* @Description

    Test if the leads on user community role change are shared properly with partner users 

    @return void
    */
    /*@isTest
    static void shouldRecalculateLeadSharingOnCommunityRoleChangeSUToMUAndMUToSUAndUserReactivation(){

        TriggerHandler.SkipTrigger = true;

        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        // Fetching Commercial Customers & Customer Locations
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        italyIMCDCont.Additional_Country_Responsibility__c = null;
        italyIMCDManager.Additional_Country_Responsibility__c = null;

        update new List<Contact>{italyIMCDCont, italyIMCDManager};

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);

        insert usersToInsert;

        TriggerHandler.SkipTrigger = false;

        Id PARTNER_LEAD_RECORD_TYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();// Store partner lead record type Id

        List<Lead> leadsToInsert = new List<Lead>(); //Opportunities list to test
        Lead leadItaly = TestUtility.createLead('testCompany', 'Test Lead Italy', customerLocItaly, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadItaly);

        Lead leadFrance = TestUtility.createLead('testCompany', 'Test Lead France', customerLocFrance, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadFrance);

        Lead leadPoland = TestUtility.createLead('testCompany', 'Test Lead Poland', customerLocPoland, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadPoland);

        Lead leadDanonePoland = TestUtility.createLead('testCompany', 'Test Lead DanonePoland', customerLocDanone, commercialCustDanone, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadDanonePoland);

        insert leadsToInsert;

        Test.startTest();

        List<User> usersToUpd = new List<User>(); //Users list to update

        usrItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_MANAGER_USER;
        usersToUpd.add(usrItaly);

        usrManagerItaly.Community_User_Role__c = Constants.COMMUNITY_USER_ROLE_STANDARD_USER;
        usersToUpd.add(usrManagerItaly);
        
        System.runAs(usrAdmin){

            usrFrance.isActive = false;
            update usrFrance;

            usrFrance.isActive = true;
            usersToUpd.add(usrFrance);

            update usersToUpd;
        }

        Test.stopTest();

        List<LeadShare> leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(3, leadShare.size());

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(1, leadShare.size());
        System.assertEquals(leadFrance.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(4, leadShare.size());

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, leadShare.size());
        System.assertEquals(leadPoland.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, leadShare.size());

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, leadShare.size());
        System.assertEquals(leadDanonePoland.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(1, leadShare.size());
        System.assertEquals(leadItaly.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, leadShare.size());
    } */
    
    /* @Description

    Test if the leads on Contact's Additional Country Responsibility change are shared properly with partner users 

    @return void
    */
    /*@isTest
    static void shouldRecalculateLeadSharingOnContactAdditionalCountryRespChange(){

        TriggerHandler.SkipTrigger = true;

        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        //Fetching Commercial Customers & Customer Locations
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);

        User usrAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'SysAdmin', 'System Administrator'); //User record to avoid mixed DML error
        usersToInsert.add(usrAdmin);

        insert usersToInsert;

        TriggerHandler.SkipTrigger = false;

        Id PARTNER_LEAD_RECORD_TYPE_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Partner_Lead').getRecordTypeId();// Store partner lead record type Id

        List<Lead> leadsToInsert = new List<Lead>(); //Opportunities list to test
        Lead leadItaly = TestUtility.createLead('testCompany', 'Test Lead Italy', customerLocItaly, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadItaly);

        Lead leadFrance = TestUtility.createLead('testCompany', 'Test Lead France', customerLocFrance, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadFrance);

        Lead leadPoland = TestUtility.createLead('testCompany', 'Test Lead Poland', customerLocPoland, commercialCust, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadPoland);

        Lead leadDanonePoland = TestUtility.createLead('testCompany', 'Test Lead DanonePoland', customerLocDanone, commercialCustDanone, PARTNER_LEAD_RECORD_TYPE_ID); //Lead test record
        leadsToInsert.add(leadDanonePoland);

        insert leadsToInsert;

        Test.startTest();

        List<User> usersToUpd = new List<User>(); //Users list to update
        
        System.runAs(usrAdmin){

            italyIMCDCont.Additional_Country_Responsibility__c = null;
            italyIMCDManager.Additional_Country_Responsibility__c = null;
            
            update new List<Contact>{italyIMCDCont, italyIMCDManager};
        }

        Test.stopTest();

        List<LeadShare> leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(1, leadShare.size());

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(1, leadShare.size());
        System.assertEquals(leadFrance.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(4, leadShare.size());

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, leadShare.size());
        System.assertEquals(leadPoland.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, leadShare.size());

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, leadShare.size());
        System.assertEquals(leadDanonePoland.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(3, leadShare.size());
        System.assertEquals(leadItaly.Id, leadShare.get(0).LeadId);

        leadShare = [SELECT Id, UserOrGroupId, LeadId FROM LeadShare WHERE LeadId IN (:leadItaly.Id, :leadFrance.Id, :leadPoland.Id, :leadDanonePoland.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, leadShare.size());
    } */
    
    @isTest
    static void shouldCreateCommercialActivitySharingOnUserCreation(){
        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id,OwnerId,Name,ParentId FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);
        
        TriggerHandler.skipTrigger = false;

            /* Create Master Commercial Activity Record to hold all bucket records */
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            masterCommercialActivity.Name = 'Commercial Activity - 2022';
            insert masterCommercialActivity;
        
            /* Create all child bucket record for the above parent record. This is created in TestSetup because the records created by Distributors should have a parent beforehand */
            List<Commercial_Activity__c> allCommercialActivityChildBucketRecords = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivityBucket = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(promotionActivityBucket);

            Commercial_Activity__c samplesBucket = CommunityKPITestUtility.createSamplesBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(samplesBucket);

            Commercial_Activity__c customerVisitsBucket = CommunityKPITestUtility.createCustomerVisitsBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(customerVisitsBucket);

            insert allCommercialActivityChildBucketRecords;
        
        Test.startTest();

        insert usersToInsert;

        //Test.stopTest();
        User[] usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Create Master Commercial Activity Record to hold all bucket records */
        List<Commercial_Activity__c> masterCommercialActivityList = new List<Commercial_Activity__c>();

        Commercial_Activity__c masterCommercialActivityItaly = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
        masterCommercialActivityList.add(masterCommercialActivityItaly);

        Commercial_Activity__c masterCommercialActivityFrance = CommunityKPITestUtility.createCommercialActivityMaster(customerLocFrance);
        masterCommercialActivityList.add(masterCommercialActivityFrance);

        insert masterCommercialActivityList;

        /* Create all child bucket record for the above parent record */
        List<Commercial_Activity__c> allChildBucketRecords = new List<Commercial_Activity__c>();

        /* Buckets for IMCD Italy Spa */
        Commercial_Activity__c promotionActivityBucketItaly = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly, masterCommercialActivityItaly);
        allChildBucketRecords.add(promotionActivityBucketItaly);

        Commercial_Activity__c samplesBucketItaly = CommunityKPITestUtility.createSamplesBucket(customerLocItaly, masterCommercialActivityItaly);
        allChildBucketRecords.add(samplesBucketItaly);

        Commercial_Activity__c customerVisitsBucketItaly = CommunityKPITestUtility.createCustomerVisitsBucket(customerLocItaly, masterCommercialActivityItaly);
        allChildBucketRecords.add(customerVisitsBucketItaly);

        /* Buckets for IMCD France Spa */

        Commercial_Activity__c promotionActivityBucketFrance = CommunityKPITestUtility.createPromotionActivityBucket(customerLocFrance, masterCommercialActivityFrance);
        allChildBucketRecords.add(promotionActivityBucketFrance);

        Commercial_Activity__c samplesBucketFrance = CommunityKPITestUtility.createSamplesBucket(customerLocFrance, masterCommercialActivityFrance);
        allChildBucketRecords.add(samplesBucketFrance);

        Commercial_Activity__c customerVisitsBucketFrance = CommunityKPITestUtility.createCustomerVisitsBucket(customerLocFrance, masterCommercialActivityFrance);
        allChildBucketRecords.add(customerVisitsBucketFrance);

        //Test.startTest();
        insert allChildBucketRecords;
        Test.stopTest();

        System.assertEquals(4, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrItaly.Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());
        System.assertEquals(4, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrFrance.Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());
        System.assertEquals(8, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrManager[0].Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());

    }
    
    @isTest
    static void shouldCreateBusinessStrategySharingOnUserCreation(){
        setupData();

        List<Id> accIds = new List<Id>(); //Account Ids to test
        List<Account> accs = [SELECT Id,OwnerId,Name,ParentId FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
            accIds.add(acc.Id);
        }

        /* Fetching Commercial Customers & Customer Locations */
        Account commercialCust          = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone    = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly        = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance       = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland       = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone       = accsMap.get('Danone Poland'); //Customer location test record

        List<Contact> cons = [SELECT Id, LastName FROM Contact]; //Contacts list to test
        Map<String, Contact> conMap = new Map<String, Contact>(); //Auxiliar Map to separate the contacts
        for(Contact con : cons){
            conMap.put(con.LastName, con);
        }

        Contact italyIMCDCont           = conMap.get('italyCont'); //Contact test record
        Contact franceIMCDCont          = conMap.get('franceCont'); //Contact test record
        Contact franceIMCDAddRespCont   = conMap.get('franceContAddRespItalyPoland'); //Contact test record
        Contact polandIMCDCont          = conMap.get('polandCont'); //Contact test record
        Contact polandIMCDAddRespCont   = conMap.get('polandContAddRespItaly'); //Contact test record
        Contact polandDanoneCont        = conMap.get('danonePolandCont'); //Contact test record
        Contact polandDanoneManager     = conMap.get('danonePolandManager'); //Contact test record
        Contact italyIMCDManager        = conMap.get('managerContItaly'); //Contact test record
        Contact franceIMCDManager       = conMap.get('managerContFrance'); //Contact test record

        List<User> usersToInsert = new List<User>(); //Users list to test
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = italyIMCDCont.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = franceIMCDCont.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = franceIMCDAddRespCont.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = polandIMCDCont.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = polandIMCDAddRespCont.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = polandDanoneCont.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerdanonePoland = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanonePolandManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerdanonePoland.ContactId = polandDanoneManager.Id;
        usersToInsert.add(usrManagerdanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = italyIMCDManager.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = franceIMCDManager.Id;
        usersToInsert.add(usrManagerFrance);
        
        TriggerHandler.skipTrigger = false;

            /* Create Master Commercial Activity Record to hold all bucket records */
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            masterCommercialActivity.Name = 'Commercial Activity - 2022';
            insert masterCommercialActivity;
        
            /* Create all child bucket record for the above parent record. This is created in TestSetup because the records created by Distributors should have a parent beforehand */
            List<Commercial_Activity__c> allCommercialActivityChildBucketRecords = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivityBucket = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(promotionActivityBucket);

            Commercial_Activity__c samplesBucket = CommunityKPITestUtility.createSamplesBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(samplesBucket);

            Commercial_Activity__c customerVisitsBucket = CommunityKPITestUtility.createCustomerVisitsBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(customerVisitsBucket);

            insert allCommercialActivityChildBucketRecords;
        
        Test.startTest();

        insert usersToInsert;

        //Test.stopTest();
        User[] usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Create Master Commercial Activity Record to hold all bucket records */
        List<Commercial_Activity__c> masterCommercialActivityList = new List<Commercial_Activity__c>();

        Commercial_Activity__c masterCommercialActivityItaly = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
        masterCommercialActivityList.add(masterCommercialActivityItaly);

        Commercial_Activity__c masterCommercialActivityFrance = CommunityKPITestUtility.createCommercialActivityMaster(customerLocFrance);
        masterCommercialActivityList.add(masterCommercialActivityFrance);

        insert masterCommercialActivityList;

        /* Create all child bucket record for the above parent record */
        List<Commercial_Activity__c> allChildBucketRecords = new List<Commercial_Activity__c>();

        /* Buckets for IMCD Italy Spa */
        Commercial_Activity__c promotionActivityBucketItaly = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly, masterCommercialActivityItaly);
        allChildBucketRecords.add(promotionActivityBucketItaly);

        Commercial_Activity__c samplesBucketItaly = CommunityKPITestUtility.createSamplesBucket(customerLocItaly, masterCommercialActivityItaly);
        allChildBucketRecords.add(samplesBucketItaly);

        Commercial_Activity__c customerVisitsBucketItaly = CommunityKPITestUtility.createCustomerVisitsBucket(customerLocItaly, masterCommercialActivityItaly);
        allChildBucketRecords.add(customerVisitsBucketItaly);

        /* Buckets for IMCD France Spa */

        Commercial_Activity__c promotionActivityBucketFrance = CommunityKPITestUtility.createPromotionActivityBucket(customerLocFrance, masterCommercialActivityFrance);
        allChildBucketRecords.add(promotionActivityBucketFrance);

        Commercial_Activity__c samplesBucketFrance = CommunityKPITestUtility.createSamplesBucket(customerLocFrance, masterCommercialActivityFrance);
        allChildBucketRecords.add(samplesBucketFrance);

        Commercial_Activity__c customerVisitsBucketFrance = CommunityKPITestUtility.createCustomerVisitsBucket(customerLocFrance, masterCommercialActivityFrance);
        allChildBucketRecords.add(customerVisitsBucketFrance);

        //Test.startTest();
        insert allChildBucketRecords;
        Test.stopTest();

        System.assertEquals(4, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrItaly.Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());
        System.assertEquals(4, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrFrance.Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());
        System.assertEquals(8, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrManager[0].Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());

    }
}