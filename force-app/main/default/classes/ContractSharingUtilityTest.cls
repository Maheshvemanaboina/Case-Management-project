/*      
@Name                  ContractSharingUtilityTest
@Author                Carlo Volpi-carlo.volpi@kcsit.pt
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               1.0
@CreatedDate           04-03-2021
@UsedBy                
@Description           Test class for the ContractSharingUtility class
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
*/
@isTest
public class ContractSharingUtilityTest {

    /*
    /* @Description

    Test setup to create some test records

    @return void
    * /
    @testSetup
    static void setupData() {

        List<Account> accsCommercCustToInsert = new List<Account>();  //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCust);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCustDanone);
        insert accsCommercCustToInsert;

        List<Account> accsToInsert = new List<Account>(); //Customer locations list to be created
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust); //Customer location test record
        customerLocItaly.BillingStreet = null;
        customerLocItaly.BillingPostalCode = null;
        customerLocItaly.BillingCity = null;
        customerLocItaly.BillingCountryCode = null;
        customerLocItaly.BillingCountry = 'Italy';
        accsToInsert.add(customerLocItaly);

        Account customerLocItalyRoma = TestUtility.createCustomerLocation('IMCD Italy - Roma Spa', commercialCust); //Customer location test record
        customerLocItalyRoma.BillingStreet = null;
        customerLocItalyRoma.BillingPostalCode = null;
        customerLocItalyRoma.BillingCity = null;
        customerLocItalyRoma.BillingCountryCode = null;
        customerLocItalyRoma.BillingCountry = 'Italy';
        accsToInsert.add(customerLocItalyRoma);

        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust); //Customer location test record
        customerLocFrance.BillingStreet = null;
        customerLocFrance.BillingPostalCode = null;
        customerLocFrance.BillingCity = null;
        customerLocFrance.BillingCountryCode = null;
        customerLocFrance.BillingCountry = 'France';
        accsToInsert.add(customerLocFrance);

        Account customerLocPoland = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCust); //Customer location test record
        customerLocPoland.BillingStreet = null;
        customerLocPoland.BillingPostalCode = null;
        customerLocPoland.BillingCity = null;
        customerLocPoland.BillingCountryCode = null;
        customerLocPoland.BillingCountry = 'Poland';
        accsToInsert.add(customerLocPoland);

        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone); //Customer location test record
        customerLocDanone.BillingStreet = null;
        customerLocDanone.BillingPostalCode = null;
        customerLocDanone.BillingCity = null;
        customerLocDanone.BillingCountryCode = null;
        customerLocDanone.BillingCountry = 'Poland';
        accsToInsert.add(customerLocDanone);
        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created

        Contact cItaly = TestUtility.createContact('italyCont' , 'italyCont', commercialCust, customerLocItaly); //Contact test record
        cItaly.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cItaly);

        Contact cFrance = TestUtility.createContact(commercialCust, customerLocFrance); //Contact test record
        cFrance.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cFrance);

        Contact cFranceAddCountryRespItalyPoland = TestUtility.createContact(commercialCust, customerLocFrance); //Contact test record
        cFranceAddCountryRespItalyPoland.Additional_Country_Responsibility__c = 'Italy;Poland';
        contactsToInsert.add(cFranceAddCountryRespItalyPoland);

        Contact cPoland = TestUtility.createContact(commercialCust, customerLocPoland); //Contact test record
        cPoland.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cPoland);

        Contact cPolandAddCountryRespItaly = TestUtility.createContact(commercialCust, customerLocPoland); //Contact test record
        cPolandAddCountryRespItaly.Additional_Country_Responsibility__c = 'Italy';
        contactsToInsert.add(cPolandAddCountryRespItaly);

        Contact cDanonePoland = TestUtility.createContact(commercialCustDanone, customerLocDanone); //Contact test record
        cDanonePoland.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cDanonePoland);

        Contact cManagerItaly = TestUtility.createContact('managerContItaly', 'managerContItaly', commercialCust, customerLocItaly); //Contact test record
        contactsToInsert.add(cManagerItaly);

        Contact cManagerFrance = TestUtility.createContact(commercialCust, customerLocFrance); //Contact test record
        contactsToInsert.add(cManagerFrance);
        insert contactsToInsert;

        List<User> usersToInsert = new List<User>(); //Users list to be created
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrItaly.ContactId = cItaly.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFrance.ContactId = cFrance.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrFranceAddCountryRespItalyPoland.ContactId = cFranceAddCountryRespItalyPoland.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPoland.ContactId = cPoland.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrPolandAddCountryRespItaly.ContactId = cPolandAddCountryRespItaly.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrDanonePoland.ContactId = cDanonePoland.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = cManagerItaly.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = cManagerFrance.Id;
        usersToInsert.add(usrManagerFrance);
        insert usersToInsert;
    }*/

    /* @Description

    To get code coverage from ContractSharingUtility commented class

    @return void
    */
    @isTest
    static void testContractSharingUtilityObjectInstance(){
        new ContractSharingUtility();
    }

    /*
    /* @Description

    Test if accounts are shared properly on contact update

    @return void
    * /
    @isTest
    static void shouldCreateProperAccountShareCustomerLocationsForUsers(){

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocItalyRoma = accsMap.get('IMCD Italy - Roma Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrFrance = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrPoland = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record

        List<AccountShare> accShare = [SELECT Id FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrFrance.Id]; //AccountShare list to check the sharing
        System.assertEquals(0, accShare.size());

        accShare = [SELECT Id FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, accShare.size());

        Contact con = new Contact(Id = usrFrance.ContactId, Additional_Country_Responsibility__c = 'Italy'); //Contact test record
        Contact con2 = new Contact(Id = usrPoland.ContactId, Additional_Country_Responsibility__c = 'Italy;France'); //Contact test record
        

        Test.startTest();

        update new List<Contact>{con, con2};

        Test.stopTest();

        accShare = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(2, accShare.size());

        accShare = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(3, accShare.size());
    }

    /* @Description

    Test if account sharing is revoked on Additional Country Responsability delete/change

    @return void
    * /
    @isTest
    static void shouldRevokeProperAccountShareCustomerLocationsForUsers(){

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocItalyRoma = accsMap.get('IMCD Italy - Roma Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrFranceAddCountryRespItalyPoland = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record

        List<Contact> conList = new List<Contact>(); //Contacts list to be updated

        Contact conFranceAddCountryRespItalyPoland = new Contact(Id = usrFranceAddCountryRespItalyPoland.ContactId, Additional_Country_Responsibility__c = null); //Contact test record
        conList.add(conFranceAddCountryRespItalyPoland);

        Contact conPolandAddCountryRespItaly = new Contact(Id = usrPolandAddCountryRespItaly.ContactId, Additional_Country_Responsibility__c = null); //Contact test record
        conList.add(conPolandAddCountryRespItaly);

        update conList;

        conFranceAddCountryRespItalyPoland.Additional_Country_Responsibility__c = 'Italy;Poland';
        conPolandAddCountryRespItaly.Additional_Country_Responsibility__c = 'Italy';

        update conList;

        List<AccountShare> accShare = [SELECT Id FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id]; //AccountShare list to check the sharing
        System.assertEquals(3, accShare.size());

        accShare = [SELECT Id FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, accShare.size());
        

        Test.startTest();

        conFranceAddCountryRespItalyPoland.Additional_Country_Responsibility__c = 'Poland';
        conPolandAddCountryRespItaly.Additional_Country_Responsibility__c = null;
        update conList;

        Test.stopTest();

        accShare = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(1, accShare.size());

        accShare = [SELECT Id, AccountId FROM AccountShare WHERE AccountId IN (:customerLocItaly.Id, :customerLocItalyRoma.Id, :customerLocFrance.Id, :customerLocPoland.Id, :customerLocDanone.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(0, accShare.size());
    }*/
}