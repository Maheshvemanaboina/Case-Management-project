/**
 * Created by KJM on 29/07/2019.
 */
/*      
@Name                  CaseTriggerHandlerTest
@Author                KJM
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           29-07-2019
@UsedBy                
@Description           Test class for the CaseSharingRecalculation class
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 04.03.2021 | Updated to meet the new sharing requirements of the account redesign
*/
@isTest
public class CaseSharingRecalculationTest {

    /* @Description

    Test setup to create some test records

    @return void
    */
    @testSetup
    static void setup() {
    
        List<Account> accsCommercialCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        accsCommercialCustToInsert.add(commercialCust);
        insert accsCommercialCustToInsert;

        List<Account> accsToInsert = new List<Account>();  //Customer locations list to be created
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

        Contact cManagerItaly = TestUtility.createContact(commercialCust, customerLocItaly); //Contact test record
        contactsToInsert.add(cManagerItaly);

        Contact cManagerFrance = TestUtility.createContact(commercialCust, customerLocFrance); //Contact test record
        contactsToInsert.add(cManagerFrance);
        insert contactsToInsert;

        List<User> usersToInsert = new List<User>();
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

        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerItaly.ContactId = cManagerItaly.Id;
        usersToInsert.add(usrManagerItaly);

        User usrManagerFrance = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //User test record
        usrManagerFrance.ContactId = cManagerFrance.Id;
        usersToInsert.add(usrManagerFrance);
        insert usersToInsert;
    }
    /* @Description

    Test case sharing recalculation

    @return void
    */
    @isTest
    static void shouldRecalculateCaseSharing() {
        
         Test.startTest();

        //TriggerHandler.skipTrigger = true;

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record

        List<Case> casesToInsert = new List<Case>();  //Cases list to be created
        Case csItaly = TestUtility.createCase('testCaseSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly);

        Case csItaly1 = TestUtility.createCase('testCaseSubjectFranceItaly','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly1);

        Case csItaly2 = TestUtility.createCase('testCaseSubjectPoland','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly2);

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrFranceAddCountryRespItalyPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFranceAddCountryRespItalyPoland']; //User test record       
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        User usrPolandAddCountryRespItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPolandAddCountryRespItaly']; //User test record
        User usrManagerItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record

        System.runAs(usrItaly){

            insert casesToInsert;
        }

        //TriggerHandler.skipTrigger = false;

        delete [SELECT Id FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND RowCause =: Constants.SHARE_ROW_CAUSE_MANUAL]; //Case test record

        CaseShare simulateWrongShareToTestShareRevoke = new CaseShare(
            CaseId = csItaly.Id,
            CaseAccessLevel = Constants.SHARE_ACCESS_LEVEL_EDIT,
            RowCause = Constants.SHARE_ROW_CAUSE_MANUAL,
            UserOrGroupId = usrFrance.Id
        ); //CaseShare test record

        insert simulateWrongShareToTestShareRevoke;
        
       

        Database.executeBatch(new CaseSharingRecalculation());

        

        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND UserOrGroupId = :usrItaly.Id];
        System.assertEquals(6, csShare.size()); //Owner and Sharing

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND UserOrGroupId = :usrFrance.Id];
        System.assertEquals(1, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND UserOrGroupId = :usrFranceAddCountryRespItalyPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND UserOrGroupId = :usrPoland.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND UserOrGroupId = :usrPolandAddCountryRespItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND UserOrGroupId = :usrManagerItaly.Id];
        System.assertEquals(0, csShare.size());

        csShare = [SELECT Id, UserOrGroupId, CaseId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csItaly1.Id, :csItaly2.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(0, csShare.size());
        
        Test.stopTest();


    }
}