/*      
@Name                  OpportunityTriggerHandlerTest
@Author                KJM
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           29-07-2019
@UsedBy                
@Description           Test class for the OpportunityTrigger
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 04.03.2021 | Updated to meet the new sharing requirements of the account redesign
*/
@isTest
public class OpportunityTriggerHandlerTest {

    /* @Description

    Test setup to create some test records

    @return void
    */
    @testSetup
    static void setup() {
        
        List<Account> accsCustomLocToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        commercialCust.Active__c=true;
        accsCustomLocToInsert.add(commercialCust);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA'); //Commercial customer test record
         commercialCustDanone.Active__c=true;
        accsCustomLocToInsert.add(commercialCustDanone);
        insert accsCustomLocToInsert;

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

        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created

        Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly); //Contact test record
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

        Contact cManagerItaly = TestUtility.createContact(commercialCust, customerLocItaly); //Contact test record
        contactsToInsert.add(cManagerItaly);

        Contact cManagerFrance = TestUtility.createContact(commercialCust, customerLocFrance); //Contact test record
        contactsToInsert.add(cManagerFrance);
        insert contactsToInsert;

        List<User> usersToInsert = new List<User>(); //Users list to be created
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrItaly.ContactId = cItaly.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrFrance.ContactId = cFrance.Id;
        usersToInsert.add(usrFrance);

        User usrFranceAddCountryRespItalyPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFranceAddCountryRespItalyPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrFranceAddCountryRespItalyPoland.ContactId = cFranceAddCountryRespItalyPoland.Id;
        usersToInsert.add(usrFranceAddCountryRespItalyPoland);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrPoland.ContactId = cPoland.Id;
        usersToInsert.add(usrPoland);

        User usrPolandAddCountryRespItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPolandAddCountryRespItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrPolandAddCountryRespItaly.ContactId = cPolandAddCountryRespItaly.Id;
        usersToInsert.add(usrPolandAddCountryRespItaly);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrDanonePoland.ContactId = cDanonePoland.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrManagerItaly.ContactId = cManagerItaly.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrManagerFrance.ContactId = cManagerFrance.Id;
        usersToInsert.add(usrManagerFrance);
        insert usersToInsert;

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to be created
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppnameUpdateTests', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppnameUpdateTests', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppnameUpdateTests', commercialCust, customerLocPoland); //Opportunity test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppnameUpdateTests', commercialCustDanone, customerLocDanone); //Opportunity test record
        oppsToInsert.add(oppDanonePoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppnameUpdateTests', Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID, commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);

        Test.startTest();

        insert oppsToInsert;

        Test.stopTest();
    }

    /* @Description

    Test if new opportunities are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldShareNewOpportunity() {

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record      
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocPoland); //Opportunity test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCustDanone, customerLocDanone); //Opportunity test record
        oppsToInsert.add(oppDanonePoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname', Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID, commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);

        Test.startTest();

        insert oppsToInsert;

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

    Test if opportunities on account change are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldChangeOpportunityShareOnAccountChange() {

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        Map<Id, Opportunity> accountIdOppsMap = new Map<Id, Opportunity>(); //Auxiliar Map to separate opportunities from each customer location

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record       
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record

        Opportunity oppItalyCurrentBusiness = new Opportunity(); //Opportunity test record
        
        for(Opportunity opp : [SELECT Id, RecordTypeId, AccountId FROM Opportunity WHERE Name = 'testOppnameUpdateTests']){
            if(opp.RecordTypeId != Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID){
                accountIdOppsMap.put(opp.AccountId, opp);
            } else {
                oppItalyCurrentBusiness = opp;
            }
        }

        Opportunity oppItaly = accountIdOppsMap.get(customerLocItaly.Id); //Opportunity test record
        Opportunity oppFrance = accountIdOppsMap.get(customerLocFrance.Id); //Opportunity test record
        Opportunity oppPoland = accountIdOppsMap.get(customerLocPoland.Id); //Opportunity test record
        Opportunity oppDanonePoland = accountIdOppsMap.get(customerLocDanone.Id); //Opportunity test record

        Test.startTest();

        oppFrance.AccountId = customerLocItaly.Id;
        update oppFrance;

        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppPoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppDanonePoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, oppShare.size());
    }

    /* @Description

    Test if opportunities on record type change are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldChangeOpportunityShareOnRecordTypeChange() {

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        Map<Id, Opportunity> accountIdOppsMap = new Map<Id, Opportunity>(); //Auxiliar Map to separate opportunities from each customer location

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record     
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record

        Id currenBusinessRT = Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID; //Record type Id for opportunity testing
        Id partnerOppRT = Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID; //Record type Id for opportunity testing
        
        Opportunity oppItalyCurrentBusiness = new Opportunity(); //Opportunity test record
        
        for(Opportunity opp : [SELECT Id, RecordTypeId, AccountId FROM Opportunity WHERE Name = 'testOppnameUpdateTests']){
            if(opp.RecordTypeId != currenBusinessRT){
                accountIdOppsMap.put(opp.AccountId, opp);
            } else {
                oppItalyCurrentBusiness = opp;
            }
        }

        Opportunity oppItaly = accountIdOppsMap.get(customerLocItaly.Id); //Opportunity test record
        Opportunity oppFrance = accountIdOppsMap.get(customerLocFrance.Id); //Opportunity test record
        Opportunity oppPoland = accountIdOppsMap.get(customerLocPoland.Id); //Opportunity test record
        Opportunity oppDanonePoland = accountIdOppsMap.get(customerLocDanone.Id); //Opportunity test record

        Test.startTest();

        List<Opportunity> opps = new List<Opportunity>(); //Opportunities list to be updated
        oppFrance.RecordTypeId = currenBusinessRT;
         oppFrance.StageName='Price & Quote - Passive';
        opps.add(oppFrance);

        oppItalyCurrentBusiness.RecordTypeId = partnerOppRT;
        oppItalyCurrentBusiness.StageName='Price & Quote - Passive';
        opps.add(oppItalyCurrentBusiness);
        update opps;

        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppPoland.Id, oppShare.get(0).OpportunityId);
        
        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppDanonePoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(3, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, oppShare.size());
    }

    /* @Description

    Test if share records are deleted after opportunities be deleted

    @return void
    */
    @isTest
    static void shouldRemoveOpportunityShareAfterDeleteOpportunity() {

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        Map<Id, Opportunity> accountIdOppsMap = new Map<Id, Opportunity>(); //Auxiliar Map to separate opportunities from each customer location

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record      
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record

        Opportunity oppItalyCurrentBusiness = new Opportunity(); //Opportunity test record
        
        for(Opportunity opp : [SELECT Id, RecordTypeId, AccountId FROM Opportunity WHERE Name = 'testOppnameUpdateTests']){
            if(opp.RecordTypeId != Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID){
                accountIdOppsMap.put(opp.AccountId, opp);
            } else {
                oppItalyCurrentBusiness = opp;
            }
        }

        Opportunity oppItaly = accountIdOppsMap.get(customerLocItaly.Id); //Opportunity test record
        Opportunity oppFrance = accountIdOppsMap.get(customerLocFrance.Id); //Opportunity test record
        Opportunity oppPoland = accountIdOppsMap.get(customerLocPoland.Id); //Opportunity test record
        Opportunity oppDanonePoland = accountIdOppsMap.get(customerLocDanone.Id); //Opportunity test record

        Test.startTest();

        delete oppFrance;

        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppItaly.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppPoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppDanonePoland.Id, oppShare.get(0).OpportunityId);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(2, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(2, oppShare.size());
    }

    /* @Description

    Test if a new opportunity is only shared to active manager users

    @return void
    */
    @isTest
    static void shouldChangeOpportunityShareOnlyToManagers() {

        Account commercialCust = [SELECT Id, Name FROM Account WHERE Name =: 'IMCD Holding' LIMIT 1];  //Commercial customer test record
        Account customerLocPoland  = [SELECT Id, Name FROM Account WHERE Name =: 'IMCD Poland Spa' LIMIT 1];  //Commercial customer test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record        
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record
        User anotherSysAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND Id !=: UserInfo.getUserId() LIMIT 1]; //User test record

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocPoland); //Opportunity test record

        usrItaly.isActive = false;
        usrFrance.isActive = false;
        usrFranceAddCountryRespItalyPoland.isActive = false;
        usrPoland.isActive = false;
        usrPolandAddCountryRespItaly.isActive = false;

        System.runAs(anotherSysAdmin){
            update new List<User>{usrItaly, usrFrance, usrFranceAddCountryRespItalyPoland, usrPoland, usrPolandAddCountryRespItaly};
        }

        Test.startTest();

        insert oppPoland;

        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(1, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppPoland.Id AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(1, oppShare.size());
    }

    /* @Description

    Test if a new opportunity is shared only to active users with additional country responsability

    @return void
    */
    @isTest
    static void shouldChangeOpportunityShareOnlyToAdditionalCountryResp() {

        Account commercialCust = [SELECT Id, Name FROM Account WHERE Name =: 'IMCD Holding' LIMIT 1]; //Commercial customer test record
        Account customerLocItaly  = [SELECT Id, Name FROM Account WHERE Name =: 'IMCD Italy Spa' LIMIT 1]; //Customer location test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record      
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record
        User anotherSysAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND Id !=: UserInfo.getUserId() LIMIT 1]; //User test record

        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record

        usrItaly.isActive = false;
        usrFrance.isActive = false;        
        usrPoland.isActive = false;
        usrManagerItaly.isActive = false;
        usrManagerFrance.isActive = false;

        System.runAs(anotherSysAdmin){
            update new List<User>{usrItaly, usrFrance, usrPoland, usrManagerItaly, usrManagerFrance};
        }

        Test.startTest();

        insert oppItaly;

        Test.stopTest();

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(1, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(1, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(0, oppShare.size());

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId =: oppItaly.Id AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(0, oppShare.size());
    }

    /* @Description

    Test if share records are maintained on owner change

    @return void
    */
    @isTest
    static void shouldKeepOpportunityShareOnOwnerChange() {

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        Map<Id, Opportunity> accountIdOppsMap = new Map<Id, Opportunity>(); //Auxiliar Map to separate opportunities from each customer location

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record       
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record
        User anotherSysAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND Id !=: UserInfo.getUserId() LIMIT 1]; //User test record

        Opportunity oppItalyCurrentBusiness = new Opportunity(); //Opportunity test record
        
        for(Opportunity opp : [SELECT Id, RecordTypeId, AccountId FROM Opportunity WHERE Name = 'testOppnameUpdateTests']){
            if(opp.RecordTypeId != Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID){
                accountIdOppsMap.put(opp.AccountId, opp);
            } else {
                oppItalyCurrentBusiness = opp;
            }
        }

        Opportunity oppItaly = accountIdOppsMap.get(customerLocItaly.Id); //Opportunity test record
        Opportunity oppFrance = accountIdOppsMap.get(customerLocFrance.Id); //Opportunity test record
        Opportunity oppPoland = accountIdOppsMap.get(customerLocPoland.Id); //Opportunity test record
        Opportunity oppDanonePoland = accountIdOppsMap.get(customerLocDanone.Id); //Opportunity test record

        Test.startTest();

        oppItaly.OwnerId = anotherSysAdmin.Id;
        update oppItaly;

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
    
    @isTest
    static void shareOpportunityOnCreatingAddCustLocation(){
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record        

        User usrItaly = [SELECT Id, ContactID FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);
        
        TriggerHandler.SkipTrigger = false;
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrItaly.ContactId;
        orcl.Additional_Customer_Location__c = customerLocFrance.Id;
        
        Test.startTest();
		insert oppsToInsert;
		insert orcl;
        Test.stopTest();
        
        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(2, oppShare.size());
        List<Id> opptiesShared = new List<Id>{oppItaly.Id, oppFrance.Id};
            opptiesShared.sort();
        List<Id> opptiesToBeShared = new List<Id>{oppShare.get(0).OpportunityId, oppShare.get(1).OpportunityId};
            opptiesToBeShared.sort();
        System.assertEquals(opptiesShared, opptiesToBeShared);

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppFrance.Id, oppShare.get(0).OpportunityId);
        //Test.stopTest();
    }
    
    @isTest
    static void testOpportunityClone(){
        TriggerHandler.SkipTrigger = true;
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }
        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record        
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
		oppItaly.RecordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FCI New Business Opportunity').getRecordTypeId();
        insert oppItaly;
        TriggerHandler.SkipTrigger = false;
        Test.startTest();
        Opportunity op2 = oppItaly.clone(false);
        op2.name = 'cloned opportunity';
		insert op2 ;
        Test.stopTest();
        System.assertEquals(true,op2.isClone());
    }
}