/*      
@Name                  OpportunityTriggerHandlerTest
@Author                KJM
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               2.0
@CreatedDate           29-07-2019
@UsedBy                
@Description           Test class for the OpportunitySharingRecalculation class
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 04.03.2021 | Updated to meet the new sharing requirements of the account redesign
*/
@isTest
public class OpportunitySharingRecalculationTest {

    /* @Description

    Test opportunity sharing recalculation

    @return void
    */
    @isTest
    static void shouldRecalculateOpportunitySharing() {
        
        TriggerHandler.skipTrigger = true;

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
        customerLocItaly.Partner_Role__c='Sold-to';
        customerLocItaly.Active__c=true;
        accsToInsert.add(customerLocItaly);

        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust); //Customer location test record
        customerLocFrance.BillingStreet = null;
        customerLocFrance.BillingPostalCode = null;
        customerLocFrance.BillingCity = null;
        customerLocFrance.BillingCountryCode = null;
        customerLocFrance.BillingCountry = 'France';
          customerLocFrance.Partner_Role__c='Sold-to';
        customerLocFrance.Active__c=true;
        accsToInsert.add(customerLocFrance);

        Account customerLocPoland = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCust); //Customer location test record
        customerLocPoland.BillingStreet = null;
        customerLocPoland.BillingPostalCode = null;
        customerLocPoland.BillingCity = null;
        customerLocPoland.BillingCountryCode = null;
        customerLocPoland.BillingCountry = 'Poland';
         customerLocPoland.Partner_Role__c='Sold-to';
        customerLocPoland.Active__c=true;
        accsToInsert.add(customerLocPoland);

        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone); //Customer location test record
        customerLocDanone.BillingStreet = null;
        customerLocDanone.BillingPostalCode = null;
        customerLocDanone.BillingCity = null;
        customerLocDanone.BillingCountryCode = null;
        customerLocDanone.BillingCountry = 'Poland';
           customerLocDanone.Partner_Role__c='Sold-to';
        customerLocDanone.Active__c=true;
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
        
        TriggerHandler.skipTrigger = false;

        List<Opportunity> oppsToInsert = new List<Opportunity>(); //Opportunities list to be created
        Opportunity oppItaly = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocItaly); //Opportunity test record
        oppsToInsert.add(oppItaly);

        Opportunity oppFrance = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocFrance); //Opportunity  test record
        oppsToInsert.add(oppFrance);

        Opportunity oppPoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCust, customerLocPoland); //Opportunity  test record
        oppsToInsert.add(oppPoland);

        Opportunity oppDanonePoland = TestUtility.createFCINewBusinessOpportunity('testOppname', commercialCustDanone, customerLocDanone); //Opportunity  test record
        oppsToInsert.add(oppDanonePoland);

        Opportunity oppItalyCurrentBusiness = TestUtility.createOpportunity('testOppname', Constants.OPPORTUNITY_RECORD_TYPE_CURRENT_BUSINESS_ID, commercialCust, customerLocItaly); //Opportunity  test record
        oppsToInsert.add(oppItalyCurrentBusiness);

        insert oppsToInsert;

        delete [SELECT Id FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND RowCause =: Constants.SHARE_ROW_CAUSE_MANUAL];

        OpportunityShare simulateWrongShareToTestShareRevoke = new OpportunityShare(
            OpportunityId = oppItaly.Id,
            OpportunityAccessLevel = Constants.SHARE_ACCESS_LEVEL_EDIT,
            RowCause = Constants.SHARE_ROW_CAUSE_MANUAL,
            UserOrGroupId = usrDanonePoland.Id
        ); //OpportunityShare test record

        insert simulateWrongShareToTestShareRevoke;

        List<OpportunityShare> oppShare = [SELECT Id, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrDanonePoland.Id]; //OpportunityShare list to check the sharing

        System.assertEquals(1, oppShare.size());
        System.assertEquals(oppItaly.Id, oppShare.get(0).OpportunityId);
        
        Test.startTest();

        Database.executeBatch(new OpportunitySharingRecalculation());

        Test.stopTest();

        oppShare = [SELECT Id, UserOrGroupId, OpportunityId FROM OpportunityShare WHERE OpportunityId IN (:oppItaly.Id, :oppFrance.Id, :oppPoland.Id, :oppDanonePoland.Id, :oppItalyCurrentBusiness.Id) AND UserOrGroupId = :usrItaly.Id];
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
}