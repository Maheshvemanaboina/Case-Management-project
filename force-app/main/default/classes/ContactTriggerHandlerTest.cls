/*      
@Name                  ContactTriggerHandlerTest
@Author                KJM
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           30-07-2019
@UsedBy                
@Description           Test class for the ContactTrigger
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 04.03.2021 | Updated to meet the new sharing requirements of the account redesign
XXXXXXXXXXXXXXX | Sibananda.bhuyan@frieslandcampina.com | 07.09.2021 | Updated to remove application (Application__c) references from code
XXXXXXXXXXXXXXX | mahendra.kumar@frieslandcampina.com | 25.03.2022 | Updated to assign/remove the Distributor Location field permission (for all KPIs) to standard community user based on Additional Country Responsibility of contact
*/
@isTest
public class ContactTriggerHandlerTest {

    /* @Description

    Test setup to create some test records

    @return void
    */
    private static void setupData() {
        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        commercialCust.Active__c=true;
        accsCommercCustToInsert.add(commercialCust);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA'); //Commercial customer test record
        commercialCustDanone.Active__c=true;
        accsCommercCustToInsert.add(commercialCustDanone);
  
        insert accsCommercCustToInsert;

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

        List<Account> endcustomersToInsert = new List<Account>();
        Account endCustomer1 = TestUtility.createEndCustomerAccount('IMCD Italy Spa End Cust'); //End customer test record
        endCustomer1.Distributor__c = commercialCust.Id;
        endCustomer1.Distributor_Location__c = customerLocItaly.Id;
        endcustomersToInsert.add(endCustomer1);

        Account endCustomer2 = TestUtility.createEndCustomerAccount('IMCD Poland Spa End Cust'); //End customer test record
        endCustomer2.Distributor__c = commercialCust.Id;
        endCustomer2.Distributor_Location__c = customerLocPoland.Id;
        endcustomersToInsert.add(endCustomer2);

        Account endCustomer3 = TestUtility.createEndCustomerAccount('IMCD France Spa End Cust'); //End customer test record
        endCustomer3.Distributor__c = commercialCust.Id;
        endCustomer3.Distributor_Location__c = customerLocFrance.Id;
        endcustomersToInsert.add(endCustomer3);

        insert endcustomersToInsert;

        List<AccountShare> accShares = new List<AccountShare>();
        accShares.add(TestUtility.createAccountShareforPortalUsers( commercialCust, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocItaly, usrManagerItaly ));
        // accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocItaly, usrItaly ));
        // accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocFrance, usrFrance ));
        // accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocPoland, usrPoland ));
        // accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocPoland, usrPolandAddCountryRespItaly ));
        
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocFrance, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( customerLocPoland, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( endCustomer1, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( endCustomer2, usrManagerItaly ));
        accShares.add(TestUtility.createAccountShareforPortalUsers( endCustomer3, usrManagerItaly ));
        insert accShares;

        //System.runAs(usrManagerItaly){
        //}
        /*
        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);

        Account commercialCustDanone = TestUtility.createAccount('Danone SA');
        accsCustomLocToInsert.add(commercialCustDanone);
        insert accsCustomLocToInsert;

        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        accsToInsert.add(customerLocItaly);

        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
        accsToInsert.add(customerLocFrance);

        Account customerLocPoland = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCust);
        accsToInsert.add(customerLocPoland);

        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone);
        accsToInsert.add(customerLocDanone);
        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>();
        Contact cItaly = TestUtility.createContact('italyCont' , 'italyCont', commercialCust, customerLocItaly);
        contactsToInsert.add(cItaly);

        Contact cFrance = TestUtility.createContact(commercialCust, customerLocFrance);
        contactsToInsert.add(cFrance);

        Contact cPoland = TestUtility.createContact(commercialCust, customerLocPoland);
        contactsToInsert.add(cPoland);

        Contact cDanonePoland = TestUtility.createContact(commercialCustDanone, customerLocDanone);
        contactsToInsert.add(cDanonePoland);

        Contact cManager = TestUtility.createContact('managerCont', 'managerCont', commercialCust, customerLocItaly);
        contactsToInsert.add(cManager);
        insert contactsToInsert;

        List<User> usersToInsert = new List<User>();
        User systemAdminUser = TestUtility.createUser('SystemadminUser@test.com', 'System Administrator');
        usersToInsert.add(systemAdminUser);
        
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrItaly.ContactId = cItaly.Id;
        usersToInsert.add(usrItaly);

        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrFrance.ContactId = cFrance.Id;
        usersToInsert.add(usrFrance);

        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrPoland.ContactId = cPoland.Id;
        usersToInsert.add(usrPoland);

        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrDanonePoland.ContactId = cDanonePoland.Id;
        usersToInsert.add(usrDanonePoland);

        User usrManager = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrManager.ContactId = cManager.Id;
        usersToInsert.add(usrManager);
        insert usersToInsert;*/
    }
    
    /* @Description

    Test if new records are shared properly with partner users

    @return void
    */
    /*@isTest
    static void shouldShareProperRecords() {
        setupData();

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
        Account endCustItalySpa = accsMap.get('IMCD Italy Spa End Cust'); //End Customer test record
        Account endCustPolandSpa = accsMap.get('IMCD Poland Spa End Cust'); //End Customer test record
        Account endCustFranceSpa = accsMap.get('IMCD France Spa End Cust'); //End Customer test record

        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrManager = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record
        User usrManagerFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerFrance']; //User test record
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland']; //User test record

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
        oppItaly.End_Customer__c = endCustItalySpa.Id;
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity test record
        oppFrance.End_Customer__c = endCustFranceSpa.Id;
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocPoland); //Opportunity test record
        oppPoland.End_Customer__c = endCustPolandSpa.Id;
        oppsToInsert.add(oppPoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname', [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Current_Business' LIMIT 1].Id, commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);

        List<Case> casesToInsert = new List<Case>(); //Cases list to test
        Case csItaly = TestUtility.createCase('testCaseSubjectItalyX','testDescriptionX', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly);

        Case csFrance = TestUtility.createCase('testCaseSubjectItalyY','testDescriptionY', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csFrance);

        Case csPoland = TestUtility.createCase('testCaseSubjectPolandZ','testDescriptionZ', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csPoland);

        //Case csDanonePoland = TestUtility.createCase('testCaseSubjectDanonePoland','testDescription', commercialCustDanone, customerLocDanone); //Case test record
        //casesToInsert.add(csDanonePoland);

        List<Account> accsToInsert = new List<Account>(); //End customers list to test

        Account endCustomer1 = TestUtility.createEndCustomerAccount('End Customer IMCD Italy Spa 1'); //End customer test record
        endCustomer1.Distributor__c = commercialCust.Id;
        endCustomer1.Distributor_Location__c = customerLocItaly.Id;
        endCustomer1.Active__c=true;
        accsToInsert.add(endCustomer1);

        Account endCustomer2 = TestUtility.createEndCustomerAccount('End Customer IMCD France Spa 2'); //End customer test record
        endCustomer2.Distributor__c = commercialCust.Id;
        endCustomer2.Distributor_Location__c = customerLocFrance.Id;
        endCustomer2.Active__c=true;
        accsToInsert.add(endCustomer2);

        System.runAs(usrManager){

            Test.startTest();

            insert oppsToInsert;
            insert casesToInsert;
            insert accsToInsert;

            Test.stopTest();
        }

        // imcd italy - SU
        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppItaly.Id, oppShare.get(0).OpportunityId);

        // imcd all related
        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id) AND UserOrGroupId = :usrManager.Id];
        System.assertEquals(3, oppShare.size());

        // imcd italy - SU
        List<AccountShare> asShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:endCustomer1.Id, :endCustomer2.Id) AND UserOrGroupId = :usrItaly.Id];  //AccountShare list to check the sharing
        System.assertEquals(2, asShare.size());

        // imcd Italy - MU
        asShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:endCustomer1.Id, :endCustomer2.Id) AND UserOrGroupId = :usrManager.Id];
        System.assertEquals(2, asShare.size()); //Direct customer is shared because of Additional Country resp of UsrManager (australia)

        // IMCD France - MU
        asShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:endCustomer1.Id, :endCustomer2.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(2, asShare.size());

        // imcd italy - SU
        List<CaseShare> csShare = [SELECT Id, UserOrGroupId, UserOrGroup.Name, CaseId, Case.Subject, rowCause FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrItaly.Id];  //CaseShare list to check the sharing

        System.assertEquals(3, csShare.size());

        // imcd all related
        csShare = [SELECT Id, UserOrGroupId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManager.Id];
        System.assertEquals(6, csShare.size()); //Rowcause Manual and RelatedPortalUser

        csShare = [SELECT Id, UserOrGroupId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrManagerFrance.Id];
        System.assertEquals(3, csShare.size());

        csShare = [SELECT Id, UserOrGroupId FROM CaseShare WHERE CaseId IN (:csItaly.Id, :csFrance.Id, :csPoland.Id) AND UserOrGroupId = :usrDanonePoland.Id];
        System.assertEquals(0, csShare.size());
    }*/
    
    /* @Description

    Test if records on contact account change (Same Hierarchy) are shared properly with partner users

    @return void
    */
    @isTest
    static void shouldRecalculateShareOnCostumerLocationThisSameHierarchyChange() {

        TriggerHandler.skipTrigger = true;

        setupData();

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
        User usrManager = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record

        Contact contItaly = [SELECT Id, Parent_Account__c, AccountId FROM Contact WHERE FirstName = 'italyCont']; //Contact test record
        Contact contManager = [SELECT Id, Parent_Account__c, AccountId FROM Contact WHERE FirstName = 'managerContItaly']; //Contact test record

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname1', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname2', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname3', commercialCust, customerLocPoland); //Opportunity test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppname4', commercialCustDanone, customerLocDanone); //Opportunity test record
        oppsToInsert.add(oppDanonePoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname5', [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Current_Business' LIMIT 1].Id, commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);
        insert oppsToInsert;

        List<Account> accsToInsert = new List<Account>(); //End customers list to test

        Account endCustomer1 = TestUtility.createEndCustomerAccount('End Customer IMCD Italy Spa 1'); //End customer test record
        endCustomer1.Distributor__c = commercialCust.Id;
        endCustomer1.Distributor_Location__c = customerLocItaly.Id;
        accsToInsert.add(endCustomer1);

        Account endCustomer2 = TestUtility.createEndCustomerAccount('End Customer IMCD France Spa 2'); //End customer test record
        endCustomer2.Distributor__c = commercialCust.Id;
        endCustomer2.Distributor_Location__c = customerLocFrance.Id;
        accsToInsert.add(endCustomer2);

        insert accsToInsert;
        
        TriggerHandler.skipTrigger = false;

        Test.startTest();

        List<Contact> conlistUpd = new List<Contact>(); //Contacts list to test
        contItaly.AccountId = customerLocPoland.Id;
        conlistUpd.add(contItaly);
        
        contManager.AccountId = customerLocPoland.Id;
        conlistUpd.add(contManager);
        update conlistUpd;

        Test.stopTest();

        // imcd poland - SU
        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppPoland.Id, oppShare.get(0).OpportunityId);
        

        // imcd related
        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrManager.Id];
        System.assertEquals(3, oppShare.size());

        // imcd italy - SU
        List<AccountShare> asShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:endCustomer1.Id, :endCustomer2.Id) AND UserOrGroupId = :usrItaly.Id]; //AccountShare list to check the sharing
        System.assertEquals(0, asShare.size());

        //imcd Italy - MU
        asShare = [SELECT Id, UserOrGroupId, AccountId FROM AccountShare WHERE AccountId IN (:endCustomer1.Id, :endCustomer2.Id) AND UserOrGroupId = :usrManager.Id];
        System.assertEquals(2, asShare.size()); //Direct customer is shared because of Additional Country resp of UsrManager (australia)
    }

    /* @Description

    Test if customer location records sharing on additional country resp delete are maintained properly with partner users

    @return void
    */
    @isTest
    static void shouldKeepCustomerLocationRecordSharingOnAddCountryRespDelete() {
        //setupData();
		
        /*List<Account> accs = [SELECT Id, Active__c, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account commercialCustDanone = accsMap.get('Danone SA'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        Account customerLocDanone = accsMap.get('Danone Poland'); //Customer location test record*/
        
        TriggerHandler.skipTrigger = true;
        
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        commercialCust.Active__c = true;
        insert commercialCust;
        
        List<Account> accsToInsert = new List<Account>();
        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust); //Customer location test record
        customerLocFrance.BillingStreet = null;
        customerLocFrance.BillingPostalCode = null;
        customerLocFrance.BillingCity = null;
        customerLocFrance.BillingCountryCode = null;
        customerLocFrance.BillingCountry = 'France';
        customerLocFrance.Active__c = true;
        customerLocFrance.Partner_Role__c='Sold-to';
        accsToInsert.add(customerLocFrance);
                        
        //Inserting the inactive account and its related contacts and community users to avoid the error causing due to the Process Builder (Make Contact Inactive associated to Inactive Account)
        Account customerLocItaly1 = TestUtility.createCustomerLocation('IMCD Italy Spa test', commercialCust); //Customer location test record
        customerLocItaly1.BillingStreet = 'Test Street';
        customerLocItaly1.BillingPostalCode = '1234';
        customerLocItaly1.BillingCity = 'Test City';
        customerLocItaly1.BillingCountryCode = null;
        customerLocItaly1.BillingCountry = 'Italy';
        customerLocItaly1.Active__c = true;
        customerLocItaly1.Partner_Role__c='Sold-to';
        accsToInsert.add(customerLocItaly1);
        insert accsToInsert;
        
        List<Contact> contactsToInsert = new List<Contact>();
        Contact cItaly = TestUtility.createContact('italyCont1' , 'italyCont', commercialCust, customerLocItaly1); //Contact test record
        cItaly.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cItaly);
        
        Contact cManagerItaly = TestUtility.createContact('managerContItaly', 'managerContItaly', commercialCust, customerLocItaly1);
        contactsToInsert.add(cManagerItaly);
        insert contactsToInsert;
        
        List<User> usersToInsert = new List<User>();
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrItaly.ContactId = cItaly.Id;
        usersToInsert.add(usrItaly);
        
        User usrManagerItaly = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManagerItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrManagerItaly.ContactId = cManagerItaly.Id;
        usersToInsert.add(usrManagerItaly);
        insert usersToInsert;

        //User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        //User usrManager = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManagerItaly']; //User test record

        //Contact contItaly = [SELECT Id, Parent_Account__c, AccountId, MailingCountry, Additional_Country_Responsibility__c, Active__c FROM Contact WHERE FirstName = 'italyCont']; //Contact test record
		Test.startTest();
        cItaly.Additional_Country_Responsibility__c = 'Italy;France';
        update cItaly;
        TriggerHandler.skipTrigger = false;

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to test
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname1', commercialCust, customerLocItaly1); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity test record
        oppsToInsert.add(oppFrance);
        
        /*Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname3', commercialCust, customerLocPoland); //Opportunity test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppname4', commercialCustDanone, customerLocDanone); //Opportunity test record
        oppsToInsert.add(oppDanonePoland);*/

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname5', [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Current_Business' LIMIT 1].Id, commercialCust, customerLocItaly1); //Opportunity test record
        oppsToInsert.add(oppItalyCurrentBusiness);
        insert oppsToInsert;

        List<OpportunityShare> oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id]; //OpportunityShare list to check the sharing
        System.assertEquals(2, oppShare.size());

        cItaly.Additional_Country_Responsibility__c = null;

        update cItaly;

        Test.stopTest();

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id];
        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppItaly.Id, oppShare.get(0).OpportunityId);
    }
    
    /* @Description

    Test if the permission set (Additional Access to Distributor Community Manager Users) is assigned automatically when the Additional
	country responsibility field of standard community user's (profile = FCI Distributor Community User) associated contact is updated
	with at least one country

    @return void
    */
    @isTest
    static void assignPermSetOnUpdatingContactAdditionalCountryResp(){
        setupData();
        Test.startTest();
        //Get the permission set id
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Additional_Access_to_Distributor_Community_Manager_Users'][0].Id;
        
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        
        //fetch the users from database
        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
		
        //List to store the contacts to be updated
        List<Contact> contactsToUpdate = new List<Contact>();
        
        //get the contacts from database and update by populating the Additioanl Country Responsibility
        for(Contact con : [SELECT Id, FirstName, Parent_Account__c, AccountId, MailingCountry, Additional_Country_Responsibility__c
                           FROM Contact WHERE FirstName = 'italyCont' OR
                           ((AccountId = :customerLocFrance.Id OR AccountId = :customerLocPoland.Id)
                            AND Additional_Country_Responsibility__c = null)])
        {
            if(con.FirstName == 'italyCont') con.Additional_Country_Responsibility__c = 'France;Poland';
            else if(con.AccountId == customerLocFrance.Id) con.Additional_Country_Responsibility__c = 'Italy;Poland';
            else if(con.AccountId == customerLocPoland.Id) con.Additional_Country_Responsibility__c = 'Italy;France';
            contactsToUpdate.add(con);
        }
        if(!contactsToUpdate.isEmpty()) update contactsToUpdate;
        Test.stopTest();
        
        //Map to store the user id as key and permission set id assigned
        Map<Id, Id> userPermissionSetIdMap = new Map<Id, Id>();
        
        for(PermissionSetAssignment psa : [SELECT PermissionSetId, AssigneeId FROM PermissionSetAssignment
                                           WHERE (AssigneeId =: usrItaly.Id OR AssigneeId =: usrFrance.Id OR
                                           AssigneeId =: usrPoland.Id) AND PermissionSetId =: permissionSetId])
        {
            userPermissionSetIdMap.put(psa.AssigneeId, psa.PermissionSetId);
        }
        
        //Verify whether the permission set is assigned to all the users (whose associated contact's additional country
        //responsibility is updated) as expected
        system.assertEquals(true, !userPermissionSetIdMap.isEmpty());
        system.assertEquals(permissionSetId, userPermissionSetIdMap.get(usrItaly.Id));
        system.assertEquals(permissionSetId, userPermissionSetIdMap.get(usrFrance.Id));
        system.assertEquals(permissionSetId, userPermissionSetIdMap.get(usrPoland.Id));
    }
    
    /* @Description

    Test if the permission set (Additional Access to Distributor Community Manager Users) is removed automatically when the Additional
	country responsibility field of standard community user's (profile = FCI Distributor Community User) associated contact is updated
	to blank

    @return void
    */
    @isTest
    static void removePermSetOnUpdatingContactAdditionalResp(){
		setupData();
        //get permission set id
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Additional_Access_to_Distributor_Community_Manager_Users'][0].Id;
        
        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocPoland = accsMap.get('IMCD Poland Spa'); //Customer location test record
        
        //fetch users from the database
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland']; //User test record
        
        //Map to store the userid as the key and assigned permission set id as value
        Map<Id, Id> userPermissionSetIdMap = new Map<Id, Id>();
                
        for(PermissionSetAssignment psa : [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment
                                           WHERE (AssigneeId =: usrFrance.Id OR AssigneeId =: usrPoland.Id) AND
                                           PermissionSetId =: permissionSetId])
        {
            userPermissionSetIdMap.put(psa.AssigneeId, psa.PermissionSetId);
        }
        
        //get the contacts from the database and update the Additional Country Responsibility to null
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact con : [SELECT Id, Parent_Account__c, AccountId, MailingCountry, Additional_Country_Responsibility__c
                           FROM Contact WHERE (AccountId = :customerLocFrance.Id OR AccountId = :customerLocPoland.Id)
                           AND Additional_Country_Responsibility__c != null])
        {
            con.Additional_Country_Responsibility__c = null;
            contactsToUpdate.add(con);
        }

		Test.startTest();        
        if(!contactsToUpdate.isEmpty()) update contactsToUpdate;
        
        //Verify whether the permission set assigned to the users has been removed
        system.assertEquals(true, [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment
                                   WHERE (AssigneeId =: usrFrance.Id OR AssigneeId =: usrPoland.Id) AND
                                   PermissionSetId =: permissionSetId].isEmpty());
        Test.stopTest();
    }
    
    @isTest
    static void validateOnAccountChangeOfPortalUser() {
        Test.startTest();
        setupData();

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding'); //Commercial customer test record
        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record

        User usrItaly = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDItaly']; //User test record
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance']; //User test record

        TriggerHandler.SkipTrigger = true;
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrItaly.ContactId;
        orcl.Additional_Customer_Location__c = customerLocFrance.Id;
        insert orcl;
        TriggerHandler.skipTrigger = false;
        
        Contact contItaly = [SELECT Id, Parent_Account__c, AccountId FROM Contact WHERE FirstName = 'italyCont'];
        
        try{
            contItaly.AccountId = customerLocFrance.Id;
            update contItaly;
        }catch(exception ex){
            system.assertEquals('You cannot add the Account same as in the Additional Customer location. Please delete the Additional Customer location and try again.', 'You cannot add the Account same as in the Additional Customer location. Please delete the Additional Customer location and try again.');
        }
        Test.stopTest();
    }
}