/*      
@Name                  CaseTriggerHandlerTest
@Author                KJM
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           29-07-2019
@UsedBy                
@Description           Test class for the CaseTrigger
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 04.03.2021 | Updated to meet the new sharing requirements of the account redesign
*/
@isTest
public class CaseTriggerHandlerTest {

    /* @Description

    Test setup to create some test records

    @return void
    */
    @testSetup
    static void setup() {
        
        insert new Record_Type_Id__c(
            Helpdesk_Case__c = DataFactoryTest.getRecordTypeByDeveloperName( Schema.SObjectType.Case ).get( 'Helpdesk_Case' ).getRecordTypeId()
        );

        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
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

        Account customerLocDanoneBledina = TestUtility.createCustomerLocation('Danone Bledina', commercialCustDanone); //Customer location test record
        customerLocDanoneBledina.BillingStreet = null;
        customerLocDanoneBledina.BillingPostalCode = null;
        customerLocDanoneBledina.BillingCity = null;
        customerLocDanoneBledina.BillingCountryCode = null;
        customerLocDanoneBledina.BillingCountry = 'Poland';
        accsToInsert.add(customerLocDanoneBledina);

        Account customerLocDanoneNutrition = TestUtility.createCustomerLocation('Nutricia Infant Nutrition Ltd', commercialCustDanone); //Customer location test record
        customerLocDanoneNutrition.BillingStreet = null;
        customerLocDanoneNutrition.BillingPostalCode = null;
        customerLocDanoneNutrition.BillingCity = null;
        customerLocDanoneNutrition.BillingCountryCode = null;
        customerLocDanoneNutrition.BillingCountry = 'Poland';
        accsToInsert.add(customerLocDanoneNutrition);
        
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

        Contact cDanoneBledina = TestUtility.createContact('Danone','Bledina',commercialCustDanone, customerLocDanoneBledina); //Contact test record
        contactsToInsert.add(cDanoneBledina);

        Contact cDanoneNutrition = TestUtility.createContact('Danone','Nutrition',commercialCustDanone, customerLocDanoneNutrition); //Contact test record
        contactsToInsert.add(cDanoneNutrition);
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

        User usrDanoneBledina = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneBledina', Constants.TEST_FCI_CUSTOMER_PROFILE); //Customer User test record
        usrDanoneBledina.ContactId = cDanoneBledina.Id;
        usersToInsert.add(usrDanoneBledina);

        User usrDanoneNutrtion = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestDanoneNutrtion', Constants.TEST_FCI_CUSTOMER_PROFILE); //Customer User test record
        usrDanoneNutrtion.ContactId = cDanoneNutrition.Id;
        usersToInsert.add(usrDanoneNutrtion);
        
        insert usersToInsert;       

        List<Case> casesToInsert = new List<Case>();  //Cases list to be created
        Case csItaly = TestUtility.createCase('testCaseUpdateTestsSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly);

        Case csFrance = TestUtility.createCase('testCaseUpdateTestsSubjectFrance','testDescription', commercialCust, customerLocFrance); //Case test record
        casesToInsert.add(csFrance);

        Case csPoland = TestUtility.createCase('testCaseUpdateTestsSubjectPoland','testDescription', commercialCust, customerLocPoland); //Case test record
        casesToInsert.add(csPoland);

        Case csDanonePoland = TestUtility.createCase('testCaseUpdateTestsSubjectDanonePoland','testDescription', commercialCustDanone, customerLocDanone); //Case test record
        casesToInsert.add(csDanonePoland);

        Case csItalyUsrItaly = TestUtility.createCase('userItalytestUpdateCase','testDescription', commercialCust, customerLocItaly); //Case test record

        Test.startTest();

        insert casesToInsert;

        Test.stopTest();

        System.runAs(usrItaly){
            
            insert csItalyUsrItaly;
        }
        

    }

    /* @Description

    Test if new cases are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldShareNewCaseUsrItaly() {
        Test.startTest();
        
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

        Id helpdeskRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Helpdesk Case').getRecordTypeId();

        List<Case> casesToInsert = new List<Case>(); //Cases list to test

        Case csItaly = TestUtility.createCase('testCaseSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case record to test
        csItaly.RecordTypeId  = helpdeskRecordTypeId;
        

        System.runAs(usrItaly){

            
            insert csItaly;

            
        }       

        List<CaseShare> csShare = [SELECT Id, Case.Account.Name, rowCause, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrItaly.Id]; //CaseShare list to check the sharing

        System.assertEquals(2, csShare.size()); //One for RowCause = 'Manual' & one for RowCause = 'RelatedPortalUser' (as the user is added as contact)

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(1, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(1, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(1, csShare.size());
        
        Test.stopTest();
    }

    /* @Description

    Test if new cases created by internal user is not shared with partner users

    @return void
    */
    @isTest
    static void donotshouldShareNewInternalCase() {
        Test.startTest();
        
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

        Id helpdeskRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Helpdesk Case').getRecordTypeId();

        List<Case> casesToInsert = new List<Case>(); //Cases list to test

        Case csItaly = TestUtility.createCase('testCaseSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case record to test
        csItaly.RecordTypeId  = helpdeskRecordTypeId;
        

        
        
        insert csItaly;

         

        List<CaseShare> csShare = [SELECT Id, Case.Account.Name, rowCause, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrItaly.Id]; //CaseShare list to check the sharing

        System.assertEquals(0, csShare.size()); //One for RowCause = 'Manual' & one for RowCause = 'RelatedPortalUser' (as the user is added as contact)

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(0, csShare.size());
        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(0, csShare.size());
        
        Test.stopTest();   
    }

    /* @Description

    Test if cases on account change for internal case are not shared properly with partner users

    @return void
    */
    @isTest
    static void shouldNotShareInternalCaseOnAccountChange() {
		
         Test.startTest();
        
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        Map<Id, Case> accountIdCasesMap = new Map<Id, Case>(); //Auxiliar Map to separate cases from each customer location

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
        
        for(Case cs : [SELECT Id, AccountId FROM Case WHERE Subject LIKE 'testCaseUpdateTests%']){
            accountIdCasesMap.put(cs.AccountId, cs);
        }

        Case csItaly = accountIdCasesMap.get(customerLocItaly.Id); //Case test record
        Case csFrance = accountIdCasesMap.get(customerLocFrance.Id); //Case test record
        Case csPoland = accountIdCasesMap.get(customerLocPoland.Id); //Case test record
        Case csDanonePoland = accountIdCasesMap.get(customerLocDanone.Id); //Case test record

       

        csFrance.AccountId = customerLocItaly.Id;
        update csFrance;

        

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrItaly.Id]; //CaseShare list to check the sharing
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id, :csDanonePoland.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(0, csShare.size());
        
        Test.stopTest();
    }

    /* @Description

    Test if a new case is only shared to active manager users

    @return void
    */
    @isTest
    static void shouldChangeCaseShareOnlyToManagers() {
		Test.startTest();
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

        Case csPoland = TestUtility.createCase('testCaseUpdateTestsSubjectPoland','testDescription', commercialCust, customerLocPoland); //Case test record

        usrItaly.isActive = false;
        usrFrance.isActive = false;
        usrFranceAddCountryRespItalyPoland.isActive = false;
        usrPoland.isActive = false;
        usrPolandAddCountryRespItaly.isActive = false;

        System.runAs(anotherSysAdmin){
            update new List<User>{usrItaly, usrFrance, usrFranceAddCountryRespItalyPoland, usrPoland, usrPolandAddCountryRespItaly};
        }

        System.runAs(usrManagerItaly){         
            insert csPoland;            
        }

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrItaly.Id];  //CaseShare list to check the sharing
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(2, csShare.size()); // additional one coming for RowCause "RelatedPortalUser"

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csPoland.Id AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(1, csShare.size());
        
        Test.stopTest();
    }

    /* @Description

    Test if a new case is shared only to active users with additional country responsability

    @return void
    */
    @isTest
    static void shouldChangeCaseShareOnlyToAdditionalCountryResp() {
        
        Test.startTest();

        Account commercialCust = [SELECT Id, Name FROM Account WHERE Name =: 'IMCD Holding' LIMIT 1]; //Commercial customer test record
        Account customerLocItaly  = [SELECT Id, Name FROM Account WHERE Name =: 'IMCD Italy Spa' LIMIT 1]; //Commercial customer test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record     
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record
        User anotherSysAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND Id !=: UserInfo.getUserId() LIMIT 1]; //User test record

        Case csItaly = TestUtility.createCase('testCaseUpdateTestsSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case test record

        usrItaly.isActive = false;
        usrFrance.isActive = false;        
        usrPoland.isActive = false;
        //usrManagerItaly.isActive = false;
        usrManagerFrance.isActive = false;

        System.runAs(anotherSysAdmin){
            update new List<User>{usrItaly, usrFrance, usrPoland, /*usrManagerItaly,*/ usrManagerFrance};
        }

        System.runAs(usrManagerItaly){         
            insert csItaly;            
        }

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrItaly.Id];  //CaseShare list to check the sharing
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(1, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(1, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(2, csShare.size()); //RowCause "RelatedPortalUser" adds another caseShare

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId =: csItaly.Id AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(0, csShare.size());
        
        Test.stopTest();
    }

    /* @Description

    Test if share records are maintained on owner change

    @return void
    */
    @isTest
    static void shouldKeepCaseShareOnOwnerChange() {
		TriggerHandler.skipTrigger = True;
        Test.startTest();
        
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
        User anotherSysAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true AND Id !=: UserInfo.getUserId() LIMIT 1]; //User test record

        Case csUserItalyCreated = [SELECT Id, AccountId FROM Case WHERE Subject LIKE 'userItalytestUpdateCase%'];

        

        csUserItalyCreated.OwnerId = anotherSysAdmin.Id;
        update csUserItalyCreated;

        

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrItaly.Id];  //CaseShare list to check the sharing
        System.assertEquals(1, csShare.size()); // one for rowcause = 'RelatedPortaluser'

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csUserItalyCreated.Id AND UserOrGroupId = :usrManagerFrance.Id];
        
        Test.stopTest();
        System.assertEquals(0, csShare.size());
        TriggerHandler.skipTrigger = false;
    }

    /* @Description

    Test if share records are maintained on owner change

    @return void
    */
    @isTest
    static void testBusinessSegmentAndOwnerUpdate(){
         
        Test.startTest();
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        List<Contact> conList = [SELECT ID,Name,FirstName,LastName FROM Contact];
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        Map<String, Contact> conMap = new Map<String, Contact>();
        Id notificationRecordTypeId = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Danone_Complaint' LIMIT 1].Id;
        User currentUser = [SELECT id FROM user WHERE id=:userinfo.getUserId()];
        Pricebook2 priceBookObj = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );       
        UPDATE priceBookObj;
        
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }
        for(Contact con:conList){
            conMap.put(con.FirstName+con.LastName,con);
        }

        User usrBledina = [SELECT Id,ProfileId FROM User WHERE Username LIKE '%TestDanoneBledina' LIMIT 1]; //User test record
        User usrNutrtion = [SELECT Id FROM User WHERE Username LIKE '%TestDanoneNutrtion' LIMIT 1]; //User test record 
        
        List<User> usersToInsert = new List<User>();
        User SysAdmin1 = TestUtility.createUser('SystemadminUser1@test.com', 'System Administrator');
        SysAdmin1.Business_Segment__c = 'Industry';
        usersToInsert.add(SysAdmin1);
        
        User SysAdmin2 = TestUtility.createUser('SystemadminUser2@test.com', 'System Administrator');
        SysAdmin2.Business_Segment__c = 'Industry';
        usersToInsert.add(SysAdmin2);
        
        User SysAdmin3 = TestUtility.createUser('SystemadminUser3@test.com', 'System Administrator');
        SysAdmin3.Business_Segment__c = 'Industry';
        usersToInsert.add(SysAdmin3);
        
        User SysAdmin4 = TestUtility.createUser('SystemadminUser4@test.com', 'System Administrator');
        SysAdmin4.Business_Segment__c = 'Industry';
        usersToInsert.add(SysAdmin4);
        INSERT usersToInsert;

        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerDanoneBledina = accsMap.get('Danone Bledina'); //Customer location test record
        Account customerDanoneNutrition = accsMap.get('Nutricia Infant Nutrition Ltd'); //Customer location test record

        List<Contract> contractList = new List<Contract>();
        Contract bledinaContract = TestUtility.createContract(commercialCustDanone, customerDanoneBledina);
        contractList.add(bledinaContract);

        Contract ntritionContract = TestUtility.createContract(commercialCustDanone, customerDanoneNutrition);
        contractList.add(ntritionContract);
        INSERT contractList;

        List<Order> orderList = new List<Order>();
        Order bledinaOrder = TestUtility.createOrder(commercialCustDanone, customerDanoneBledina);
        bledinaOrder.Business_Segment__c = 'Industry';
        bledinaOrder.EffectiveDate = System.today(); 
        orderList.add(bledinaOrder);

        Order bledinaOrder1 = TestUtility.createOrder(commercialCustDanone, customerDanoneBledina);
        bledinaOrder1.Business_Segment__c = 'Industry';
        bledinaOrder1.EffectiveDate = System.today(); 
        orderList.add(bledinaOrder1);

        Order nutrtionOrder1 = TestUtility.createOrder(commercialCustDanone, customerDanoneNutrition);
        nutrtionOrder1.Business_Segment__c = 'Industry';
        nutrtionOrder1.EffectiveDate = System.today(); 
        orderList.add(nutrtionOrder1);

        Order nutrtionOrder2 = TestUtility.createOrder(commercialCustDanone, customerDanoneNutrition);
        nutrtionOrder2.Business_Segment__c = 'Industry';
        nutrtionOrder2.EffectiveDate = System.today(); 
        orderList.add(nutrtionOrder2);
        INSERT orderList;

        List<Delivery__c> deliveryList = new List<Delivery__c>();
        Delivery__c bledinaDelivery1 = TestUtility.createDelivery(customerDanoneBledina);
        bledinaDelivery1.SAP_Delivery_Number__c='0800000001';
        deliveryList.add(bledinaDelivery1);

        Delivery__c bledinaDelivery2 = TestUtility.createDelivery(customerDanoneBledina);
        bledinaDelivery2.SAP_Delivery_Number__c='0800000002';
        deliveryList.add(bledinaDelivery2);

        Delivery__c nutritionDelivery1 = TestUtility.createDelivery(customerDanoneNutrition);
        nutritionDelivery1.SAP_Delivery_Number__c='0800000003';
        deliveryList.add(nutritionDelivery1);

        Delivery__c nutritionDelivery2 = TestUtility.createDelivery(customerDanoneNutrition);
        nutritionDelivery2.SAP_Delivery_Number__c='0800000004';
        deliveryList.add(nutritionDelivery2);

        Delivery__c nutritionDelivery3 = TestUtility.createDelivery(customerDanoneNutrition);
        nutritionDelivery3.SAP_Delivery_Number__c='0800000005';
        deliveryList.add(nutritionDelivery3);
        INSERT deliveryList;

        List<Delivery_Line_Item__c> deliveryLineItemList = new List<Delivery_Line_Item__c>();
        Delivery_Line_Item__c bledinaDelivery1DLI = new Delivery_Line_Item__c();
        bledinaDelivery1DLI.Delivery__c = bledinaDelivery1.id;
        bledinaDelivery1DLI.Sales_Order_number__c = bledinaOrder.id;
        deliveryLineItemList.add(bledinaDelivery1DLI);

        Delivery_Line_Item__c bledinaDelivery2DLI = new Delivery_Line_Item__c();
        bledinaDelivery2DLI.Delivery__c = bledinaDelivery2.id;
        bledinaDelivery2DLI.Sales_Order_number__c = bledinaOrder1.id;
        deliveryLineItemList.add(bledinaDelivery2DLI);

        Delivery_Line_Item__c nutrtionDelivery1DLI = new Delivery_Line_Item__c();
        nutrtionDelivery1DLI.Delivery__c = nutritionDelivery1.id;
        nutrtionDelivery1DLI.Sales_Order_number__c = nutrtionOrder1.id;
        deliveryLineItemList.add(nutrtionDelivery1DLI);

        Delivery_Line_Item__c nutrtionDelivery2DLI = new Delivery_Line_Item__c();
        nutrtionDelivery2DLI.Delivery__c = nutritionDelivery2.id;
        nutrtionDelivery2DLI.Sales_Order_number__c = nutrtionOrder2.id;
        deliveryLineItemList.add(nutrtionDelivery2DLI);

        Delivery_Line_Item__c nutrtionDelivery3DLI = new Delivery_Line_Item__c();
        nutrtionDelivery3DLI.Delivery__c = nutritionDelivery3.id;
        nutrtionDelivery3DLI.Sales_Order_number__c = nutrtionOrder2.id;
        deliveryLineItemList.add(nutrtionDelivery3DLI);

        INSERT deliveryLineItemList;


        List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>();

        AccountTeamMember accTeamBledina1 = TestUtility.createAccountTeamMember(SysAdmin1,customerDanoneBledina,'CMO');
        accTeamBledina1.Business_Segment__c = 'Industry';
        accTeamBledina1.primary__c = true;
        accountTeamList.add(accTeamBledina1);

        AccountTeamMember accTeamBledina2 = TestUtility.createAccountTeamMember(SysAdmin2,customerDanoneBledina,'CMO');
        accTeamBledina2.primary__c = true;
        accTeamBledina2.Business_Segment__c = 'Industry';
        accountTeamList.add(accTeamBledina2);
        
        AccountTeamMember accTeamNutrtion1 = TestUtility.createAccountTeamMember(SysAdmin3,customerDanoneNutrition,'CMO');
        accTeamNutrtion1.primary__c = true;
        accTeamNutrtion1.Business_Segment__c = 'Industry';
        accountTeamList.add(accTeamNutrtion1);

        AccountTeamMember accTeamNutrtion2 = TestUtility.createAccountTeamMember(SysAdmin4,customerDanoneNutrition,Constants.ACCOUNT_TEAM_ROLE_SALES_MANAGER);
        accTeamNutrtion2.primary__c = false;
        accountTeamList.add(accTeamNutrtion2);

        TriggerHandler.skipTrigger = true;
        INSERT accountTeamList;
        TriggerHandler.skipTrigger = false;
        
        List<Global_Automation_Setting__c>  globalSettingList = new List<Global_Automation_Setting__c>();
        Global_Automation_Setting__c globalSetting1 = new Global_Automation_Setting__c();
        globalSetting1.Name = 'FCICustomer';
        globalSetting1.SetupOwnerId =  usrBledina.ProfileId;
        globalSetting1.Skip_Apex_Trigger__c	= false;
        globalSetting1.Skip_Process_Builder__c = false;
        globalSetting1.Skip_Validation_Rule__c = false;
        globalSettingList.add(globalSetting1);
        Global_Automation_Setting__c globalSetting2 = new Global_Automation_Setting__c();
        globalSetting2.Name = 'SystemAdmin';
        globalSetting2.SetupOwnerId =  SysAdmin1.ProfileId;
        globalSetting2.Skip_Apex_Trigger__c	= false;
        globalSetting2.Skip_Process_Builder__c = false;
        globalSetting2.Skip_Validation_Rule__c = true;
        globalSettingList.add(globalSetting2);
        
        INSERT globalSettingList;
        
        
       
        System.runAs(usrBledina){
            QueueSObject QueueID = [Select id,Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE SobjectType = 'case' AND Queue.Type ='Queue' AND Queue.Name = 'Notification Queue' Limit 1];
            List<Case> danoneBledinaCaseList = new List<Case>();
            Case notificationCase1 = TestUtility.createCase('CaseSubject1', 'Descrip1', commercialCustDanone, customerDanoneBledina);
            notificationCase1.recordtypeid = notificationRecordTypeId;
            notificationCase1.Type = 'Logistics';
            notificationCase1.Delivery_Number__c ='800000001' ;
            notificationCase1.ContactId = conMap.get('DanoneBledina').id;
            notificationCase1.status = 'New';
            notificationCase1.Priority = 'Regular';
            danoneBledinaCaseList.add(notificationCase1);

            Case notificationCase2 = TestUtility.createCase('CaseSubject2', 'Descrip2', commercialCustDanone, customerDanoneBledina);
            notificationCase2.recordtypeid = notificationRecordTypeId;
            notificationCase2.Type = 'Sales';
            notificationCase2.Delivery_Number__c ='800000002' ;
            notificationCase2.ContactId = conMap.get('DanoneBledina').id;
            notificationCase2.status = 'New';
            notificationCase2.Priority = 'Regular';
            danoneBledinaCaseList.add(notificationCase2);

            Case notificationCase3 = TestUtility.createCase('CaseSubject3', 'Descrip3', commercialCustDanone, customerDanoneBledina);
            notificationCase3.recordtypeid = notificationRecordTypeId;
            notificationCase3.Type = 'Logistics';
            notificationCase3.Delivery_Number__c ='0700000002' ;
            notificationCase3.ContactId = conMap.get('DanoneBledina').id;
            notificationCase3.status = 'New';
            notificationCase3.Priority = 'Regular';
            danoneBledinaCaseList.add(notificationCase3);

            Case notificationCase4 = TestUtility.createCase('CaseSubject4', 'Descrip4', commercialCustDanone, customerDanoneBledina);
            notificationCase4.recordtypeid = notificationRecordTypeId;
            notificationCase4.Type = 'Logistics';
            notificationCase4.Delivery_Number__c ='0800000003' ;
            notificationCase4.ContactId = conMap.get('DanoneBledina').id;
            notificationCase4.status = 'New';
            notificationCase4.Priority = 'Regular';
            danoneBledinaCaseList.add(notificationCase4);
            
            Case notificationCase5 = TestUtility.createCase('CaseSubject5', 'Descrip5', commercialCustDanone, customerDanoneBledina);
            notificationCase5.recordtypeid = notificationRecordTypeId;
            notificationCase5.Type = 'Logistics';
            notificationCase5.Delivery_Number__c ='0800000005' ;
            notificationCase5.ContactId = conMap.get('DanoneBledina').id;
            notificationCase5.status = 'New';
            notificationCase5.Priority = 'Regular';
            danoneBledinaCaseList.add(notificationCase5);
            INSERT danoneBledinaCaseList;

            Case checknotificationCase1 = [SELECT id,Business_Segment__c,OwnerId FROM Case WHERE id=:notificationCase1.id];
            System.assertEquals('Industry', checknotificationCase1.Business_Segment__c);
            //System.assertEquals(SysAdmin1.id , checknotificationCase1.Ownerid);

            /*Case checknotificationCase2 = [SELECT id,Business_Segment__c,Ownerid FROM Case WHERE id=:notificationCase2.id];
            System.assertEquals('Industry', checknotificationCase2.Business_Segment__c);
            System.assertEquals(SysAdmin2.id , checknotificationCase2.OwnerId);

            Case checknotificationCase3 = [SELECT id,Business_Segment__c,Ownerid FROM Case WHERE id=:notificationCase3.id];
            System.assertEquals(null, checknotificationCase3.Business_Segment__c);
            System.assertEquals(QueueID.Queue.id, checknotificationCase3.Ownerid);

            Case checknotificationCase4 = [SELECT id,Business_Segment__c,Ownerid FROM Case WHERE id=:notificationCase4.id];
            System.assertEquals(null, checknotificationCase4.Business_Segment__c);
            System.assertEquals(QueueID.Queue.id, checknotificationCase4.Ownerid);

            Case checknotificationCase5 = [SELECT id,Business_Segment__c,Ownerid FROM Case WHERE id=:notificationCase5.id];
            System.assertEquals(null, checknotificationCase5.Business_Segment__c);
            System.assertEquals(QueueID.Queue.id, checknotificationCase5.Ownerid);*/
        }

       

        System.runAs(SysAdmin1){
            List<Case> danoneCMOCaseList = new List<Case>();
            Case cmoNotificationCase1 = TestUtility.createCase('CaseSubject1', 'Descrip1', commercialCustDanone, customerDanoneBledina);
            cmoNotificationCase1.recordtypeid = notificationRecordTypeId;
            cmoNotificationCase1.Type = 'Logistics';
            cmoNotificationCase1.Delivery_Number__c ='800000001' ;
            cmoNotificationCase1.ContactId = conMap.get('DanoneBledina').id;
            cmoNotificationCase1.status = 'New';
            cmoNotificationCase1.Priority = 'Regular';
            danoneCMOCaseList.add(cmoNotificationCase1);

            Case cmoNotificationCase2 = TestUtility.createCase('CaseSubject2', 'Descrip2', commercialCustDanone, customerDanoneBledina);
            cmoNotificationCase2.recordtypeid = notificationRecordTypeId;
            cmoNotificationCase2.Type = 'Logistics';
            cmoNotificationCase2.Delivery_Number__c ='0800000002' ;
            cmoNotificationCase2.ContactId = conMap.get('DanoneBledina').id;
            cmoNotificationCase2.status = 'New';
            cmoNotificationCase2.Priority = 'Regular';
            danoneCMOCaseList.add(cmoNotificationCase2);

            Case cmoNotificationCase3 = TestUtility.createCase('CaseSubject3', 'Descrip3', commercialCustDanone, customerDanoneBledina);
            cmoNotificationCase3.recordtypeid = notificationRecordTypeId;
            cmoNotificationCase3.Type = 'Logistics';
            cmoNotificationCase3.Delivery_Number__c ='0700000002' ;
            cmoNotificationCase3.ContactId = conMap.get('DanoneBledina').id;
            cmoNotificationCase3.status = 'New';
            cmoNotificationCase3.Priority = 'Regular';
            danoneCMOCaseList.add(cmoNotificationCase3);

            Case cmoNotificationCase4 = TestUtility.createCase('CaseSubject4', 'Descrip4', commercialCustDanone, customerDanoneNutrition);
            cmoNotificationCase4.recordtypeid = notificationRecordTypeId;
            cmoNotificationCase4.Type = 'Logistics';
            cmoNotificationCase4.Delivery_Number__c ='0800000003' ;
            cmoNotificationCase4.ContactId = conMap.get('DanoneNutrition').id;
            cmoNotificationCase4.status = 'New';
            cmoNotificationCase4.Priority = 'Regular';
            danoneCMOCaseList.add(cmoNotificationCase4);
            
            Case cmoNotificationCase5 = TestUtility.createCase('CaseSubject5', 'Descrip5', commercialCustDanone, customerDanoneNutrition);
            cmoNotificationCase5.recordtypeid = notificationRecordTypeId;
            cmoNotificationCase5.Type = 'Logistics';
            cmoNotificationCase5.Delivery_Number__c ='0800000004' ;
            cmoNotificationCase5.ContactId = conMap.get('DanoneNutrition').id;
            cmoNotificationCase5.status = 'New';
            cmoNotificationCase5.Priority = 'Regular';
            danoneCMOCaseList.add(cmoNotificationCase5);
            INSERT danoneCMOCaseList;

            Case checkCMONotificationCase1 = [SELECT Business_Segment__c,OwnerId FROM Case WHERE id=:cmoNotificationCase1.id];
            System.assertEquals('Industry', checkCMONotificationCase1.Business_Segment__c);
            System.assertEquals(SysAdmin1.id, checkCMONotificationCase1.OwnerId);

            /*Case checkCMONotificationCase2 = [SELECT Business_Segment__c,OwnerId FROM Case WHERE id=:cmoNotificationCase2.id];
            System.assertEquals('Industry', checkCMONotificationCase2.Business_Segment__c);
            System.assertEquals(SysAdmin1.id, checkCMONotificationCase2.OwnerId);

            Case checkCMONotificationCase3= [SELECT Business_Segment__c,OwnerId FROM Case WHERE id=:cmoNotificationCase3.id];
            System.assertEquals(null, checkCMONotificationCase3.Business_Segment__c);
            System.assertEquals(SysAdmin1.id, checkCMONotificationCase3.OwnerId);

            Case checkCMONotificationCase4= [SELECT Business_Segment__c,OwnerId FROM Case WHERE id=:cmoNotificationCase4.id];
            System.assertEquals('Industry', checkCMONotificationCase4.Business_Segment__c);
            System.assertEquals(SysAdmin1.id, checkCMONotificationCase4.OwnerId);

            Case checkCMONotificationCase5= [SELECT Business_Segment__c,OwnerId FROM Case WHERE id=:cmoNotificationCase5.id];
            System.assertEquals('Industry', checkCMONotificationCase5.Business_Segment__c);
            System.assertEquals(SysAdmin1.id, checkCMONotificationCase5.OwnerId);*/
        }
        

        Test.stopTest();    
    }
    
   @isTest
    public static void testComplaintQuantityValidation(){
        
        Test.startTest();
        
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        List<Contact> conList = [SELECT ID,Name,FirstName,LastName FROM Contact];
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        Map<String, Contact> conMap = new Map<String, Contact>();
        Id notificationRecordTypeId = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Danone_Complaint' LIMIT 1].Id;
        Pricebook2 priceBookObj = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );       
        UPDATE priceBookObj;
        
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }
        for(Contact con:conList){
            conMap.put(con.FirstName+con.LastName,con);
        }


        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerDanoneBledina = accsMap.get('Danone Bledina'); //Customer location test record
        Account customerDanoneNutrition = accsMap.get('Nutricia Infant Nutrition Ltd'); //Customer location test record

        List<Contract> contractList = new List<Contract>();
        Contract bledinaContract = TestUtility.createContract(commercialCustDanone, customerDanoneBledina);
        contractList.add(bledinaContract);

        Contract ntritionContract = TestUtility.createContract(commercialCustDanone, customerDanoneNutrition);
        contractList.add(ntritionContract);
        INSERT contractList;

        List<Order> orderList = new List<Order>();
        Order bledinaOrder = TestUtility.createOrder(commercialCustDanone, customerDanoneBledina);
        bledinaOrder.Business_Segment__c = 'Industry';
        bledinaOrder.EffectiveDate = System.today(); 
        orderList.add(bledinaOrder);

        Order nutrtionOrder = TestUtility.createOrder(commercialCustDanone, customerDanoneNutrition);
        nutrtionOrder.Business_Segment__c = 'Industry';
        nutrtionOrder.EffectiveDate = System.today(); 
        orderList.add(nutrtionOrder);

        INSERT orderList;

        List<Delivery__c> deliveryList = new List<Delivery__c>();
        Delivery__c bledinaDelivery = TestUtility.createDelivery(customerDanoneBledina);
        bledinaDelivery.SAP_Delivery_Number__c='0800000001';
        deliveryList.add(bledinaDelivery);

        Delivery__c nutritionDelivery = TestUtility.createDelivery(customerDanoneBledina);
        nutritionDelivery.SAP_Delivery_Number__c='0800000002';
        deliveryList.add(nutritionDelivery);
        
        INSERT deliveryList;

        List<Delivery_Line_Item__c> deliveryLineItemList = new List<Delivery_Line_Item__c>();
        Delivery_Line_Item__c bledinaDelivery1DLI = new Delivery_Line_Item__c();
        bledinaDelivery1DLI.SAP_Delivery_Item_Number__c = bledinaDelivery.SAP_Delivery_Number__c + '000010900001';
        bledinaDelivery1DLI.Delivery__c = bledinaDelivery.id;
        bledinaDelivery1DLI.Sales_Order_number__c = bledinaOrder.id;
        bledinaDelivery1DLI.Order_Delivered_Quantity__c = 100;
        bledinaDelivery1DLI.UOM_for_Item_Quantity__c = 'KG';
        deliveryLineItemList.add(bledinaDelivery1DLI);

        Delivery_Line_Item__c bledinaDelivery2DLI = new Delivery_Line_Item__c();
        bledinaDelivery2DLI.SAP_Delivery_Item_Number__c = bledinaDelivery.SAP_Delivery_Number__c + '000010900002';
        bledinaDelivery2DLI.Delivery__c = bledinaDelivery.id;
        bledinaDelivery2DLI.Sales_Order_number__c = bledinaOrder.id;
        bledinaDelivery2DLI.Order_Delivered_Quantity__c = 110;
        bledinaDelivery2DLI.UOM_for_Item_Quantity__c = 'KG';
        deliveryLineItemList.add(bledinaDelivery2DLI);

        Delivery_Line_Item__c bledinaDelivery3DLI = new Delivery_Line_Item__c();
        bledinaDelivery3DLI.SAP_Delivery_Item_Number__c = bledinaDelivery.SAP_Delivery_Number__c + '000020';
        bledinaDelivery3DLI.Delivery__c = bledinaDelivery.id;
        bledinaDelivery3DLI.Sales_Order_number__c = bledinaOrder.id;
        bledinaDelivery3DLI.Order_Delivered_Quantity__c = 90;
        bledinaDelivery3DLI.UOM_for_Item_Quantity__c = 'KG';
        deliveryLineItemList.add(bledinaDelivery3DLI);
        
        Delivery_Line_Item__c nutrtionDelivery1DLI = new Delivery_Line_Item__c();
        nutrtionDelivery1DLI.SAP_Delivery_Item_Number__c = nutritionDelivery.SAP_Delivery_Number__c +'000100';
        nutrtionDelivery1DLI.Delivery__c = nutritionDelivery.id;
        nutrtionDelivery1DLI.Sales_Order_number__c = nutrtionOrder.id;
        nutrtionDelivery1DLI.Order_Delivered_Quantity__c = 1000;
        nutrtionDelivery1DLI.UOM_for_Item_Quantity__c = 'KG';
        deliveryLineItemList.add(nutrtionDelivery1DLI);
        
        Delivery_Line_Item__c nutrtionDelivery2DLI = new Delivery_Line_Item__c();
        nutrtionDelivery2DLI.SAP_Delivery_Item_Number__c = nutritionDelivery.SAP_Delivery_Number__c +'000101';
        nutrtionDelivery2DLI.Delivery__c = nutritionDelivery.id;
        nutrtionDelivery2DLI.Sales_Order_number__c = nutrtionOrder.id;
        nutrtionDelivery2DLI.Order_Delivered_Quantity__c = 1010;
        nutrtionDelivery2DLI.UOM_for_Item_Quantity__c = 'KG';
        deliveryLineItemList.add(nutrtionDelivery2DLI);

        INSERT deliveryLineItemList;
        
        List<Case> danoneBledinaCaseList = new List<Case>();
        
        Case notificationCase1 = TestUtility.createCase('CaseSubject1', 'Descrip1', commercialCustDanone, customerDanoneBledina);
        notificationCase1.recordtypeid = notificationRecordTypeId;
        notificationCase1.Type = 'Logistics';
        notificationCase1.Delivery_Number__c = '800000001' ;
        notificationCase1.Delivery_Line_Item__c = '900001';
        notificationCase1.ContactId = conMap.get('DanoneBledina').id;
        notificationCase1.status = 'New';
        notificationCase1.Priority = 'Regular';
        danoneBledinaCaseList.add(notificationCase1);
        
        Case notificationCase2 = TestUtility.createCase('CaseSubject1', 'Descrip1', commercialCustDanone, customerDanoneBledina);
        notificationCase2.recordtypeid = notificationRecordTypeId;
        notificationCase2.Type = 'Logistics';
        notificationCase2.Delivery_Number__c = '800000001' ;
        notificationCase2.Delivery_Line_Item__c = '900002';
        notificationCase2.ContactId = conMap.get('DanoneBledina').id;
        notificationCase2.status = 'New';
        notificationCase2.Priority = 'Regular';
        danoneBledinaCaseList.add(notificationCase2); 
        
        Case notificationCase3 = TestUtility.createCase('CaseSubject1', 'Descrip1', commercialCustDanone, customerDanoneBledina);
        notificationCase3.recordtypeid = notificationRecordTypeId;
        notificationCase3.Type = 'Logistics';
        notificationCase3.Delivery_Number__c = '0800000002' ;
        notificationCase3.Delivery_Line_Item__c = '000100';
        notificationCase3.ContactId = conMap.get('DanoneBledina').id;
        notificationCase3.status = 'New';
        notificationCase3.Priority = 'Regular';
        notificationCase3.Complaint_Quantity__c = 800;
        danoneBledinaCaseList.add(notificationCase3);
        
        INSERT danoneBledinaCaseList;
        
		
        Case checkNotificationCase1 = [SELECT Complaint_Quantity__c,Unit_of_Measure__c FROM Case WHERE id=:notificationCase1.id];
        System.assertEquals(bledinaDelivery1DLI.Order_Delivered_Quantity__c, checkNotificationCase1.Complaint_Quantity__c);
        System.assertEquals(bledinaDelivery1DLI.UOM_for_Item_Quantity__c,checkNotificationCase1.Unit_of_Measure__c );
        
        Case checkNotificationCase2 = [SELECT Complaint_Quantity__c,Unit_of_Measure__c FROM Case WHERE id=:notificationCase2.id];
        System.assertEquals(bledinaDelivery2DLI.Order_Delivered_Quantity__c, checkNotificationCase2.Complaint_Quantity__c);
        System.assertEquals(bledinaDelivery2DLI.UOM_for_Item_Quantity__c,checkNotificationCase2.Unit_of_Measure__c );
        
        Case checkNotificationCase3 = [SELECT Complaint_Quantity__c,Unit_of_Measure__c FROM Case WHERE id=:notificationCase3.id];
        System.assertEquals(true, checkNotificationCase3.Complaint_Quantity__c < nutrtionDelivery1DLI.Order_Delivered_Quantity__c);
        System.assertEquals(nutrtionDelivery1DLI.UOM_for_Item_Quantity__c,checkNotificationCase3.Unit_of_Measure__c );
         
        try{
            notificationCase1.Delivery_Line_Item__c = '000020';
            UPDATE notificationCase1;
        }Catch(Exception exp){
            System.assertEquals(true, exp.getMessage().contains('Please enter complaint quantity less then Order Quantity'));
        }
                    
        try{
            notificationCase2.Delivery_Line_Item__c = '000020';
            notificationCase2.Complaint_Quantity__c = 190;
            UPDATE notificationCase2;
        }Catch(Exception exp){
            System.assertEquals(true, exp.getMessage().contains('Please enter complaint quantity less then Order Quantity'));
        }    
        
        
        Test.stopTest();
        
    } 
    
     @isTest
    static void shouldShareCaseOnCreatingAndDeletingAdditonalCustLocation() {
        Test.startTest();
        
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        //Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        //Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        //Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        /*User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record       
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record*/

        Id helpdeskRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Helpdesk Case').getRecordTypeId();

        List<Case> casesToInsert = new List<Case>(); //Cases list to test

        Case csItaly = TestUtility.createCase('testCaseSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case record to test
        csItaly.RecordTypeId  = helpdeskRecordTypeId;
        

        System.runAs(usrItaly){

            
            insert csItaly;

            
        }       

        List<CaseShare> csShare = [SELECT Id, Case.Account.Name, rowCause, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrItaly.Id]; //CaseShare list to check the sharing

        System.assertEquals(2, csShare.size()); //One for RowCause = 'Manual' & one for RowCause = 'RelatedPortalUser' (as the user is added as contact)

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId = :csItaly.Id AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(0, csShare.size());
        
        Test.stopTest();
    }
    
}