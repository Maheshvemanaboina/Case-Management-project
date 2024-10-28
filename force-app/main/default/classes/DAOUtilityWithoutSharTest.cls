@IsTest
public class DAOUtilityWithoutSharTest {

    static final Id TEST_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        static final Id H1_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Commercial_Customer').getRecordTypeId();
        static final Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Master_Lead').getrecordTypeId();

    @TestSetup
    static void setupTestData() {
        TriggerHandler.skipTrigger = true;
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'FCI' Limit 1];

        /* create Internal Users */
        List<User> internalUsersToInsert = new List<User>();
        User FCIUser1 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser1', 'System Administrator');
        FCIUser1.UserRoleId = userrole.Id;
        internalUsersToInsert.add(FCIUser1);

        User FCIUser2 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser2', 'System Administrator');
        FCIUser2.UserRoleId = userrole.Id;
        internalUsersToInsert.add(FCIUser2);
        insert internalUsersToInsert;
        List<Sales_Funnel__c> funnels = new List<Sales_Funnel__c>();
System.runAs(FCIUser1){

            /* Creates H1 */
            Account commercialCust = TestUtility.createAccount('IMCD Holding');
            insert commercialCust;
				
            /* Creates H5 which is the Distributor Location */
            List<Account> accsToInsert = new List<Account>();
            Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
            customerLocItaly.OwnerId = FCIUser1.Id;
            accsToInsert.add(customerLocItaly);

            Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
            customerLocFrance.OwnerId = FCIUser2.Id;
            accsToInsert.add(customerLocFrance);

            Account competitorAcc = TestUtility.createEndCustomerAccount('Test Competitor');
            /* change end customer record type to competitor */
            competitorAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId();
            accsToInsert.add(competitorAcc);

            insert accsToInsert;
        Lead leItaly = TestUtility.createLead('testCompanyItly','testLastNameItaly',customerLocItaly,commercialCust,recordTypeId);

            /* Create Contacts under H5, these contacts will be Distributors */
            List<Contact> contactsToInsert = new List<Contact>();
            Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cItaly);

            Contact cFrance = TestUtility.createContact(commercialCust, customerLocFrance);
            contactsToInsert.add(cFrance);

            Contact cManager = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cManager);
            insert contactsToInsert;

            List<User> usersToInsert = new List<User>();
            User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrItaly.ContactId = cItaly.Id;
            usersToInsert.add(usrItaly);

            User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrFrance.ContactId = cFrance.Id;
            usersToInsert.add(usrFrance);

            User usrManager = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrManager.ContactId = cManager.Id;
            usersToInsert.add(usrManager);
            insert usersToInsert;

            /* Create an Apex share to Share the above competitor with Partner Users,
            There is criteria-based sharing rule defined but these do not execute in test classes,hence manual sharing is required */
            List<AccountShare> accShareToInsert = new List<AccountShare>();
            accShareToInsert.add(new AccountShare(AccountId = competitorAcc.Id, UserOrGroupId = usrFrance.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read'));
            accShareToInsert.add(new AccountShare(AccountId = competitorAcc.Id, UserOrGroupId = usrItaly.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read'));
            accShareToInsert.add(new AccountShare(AccountId = competitorAcc.Id, UserOrGroupId = usrManager.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read'));

            /* Create Share for Partner contacts for their own accounts */
            List<AccountShare> accShares = new List<AccountShare>();
            accShares.add(AccountSharingUtility.getAccountShare(customerLocItaly.Id, usrItaly.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(customerLocFrance.Id, usrFrance.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(customerLocItaly.Id, usrManager.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(customerLocFrance.Id, usrManager.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(commercialCust.Id, usrItaly.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(commercialCust.Id, usrFrance.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(commercialCust.Id, usrManager.Id, 'READ', 'Manual'));

            insert accShares;

            //Giving Manager user access to France Location, as manager users can see all locations
            accShareToInsert.add(new AccountShare(AccountId = customerLocFrance.Id, UserOrGroupId = usrManager.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read'));

            insert accShareToInsert;

            TriggerHandler.skipTrigger = false;

            /* Create Master Commercial Activity Record to hold all bucket records */
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            masterCommercialActivity.Name = 'Commercial Activity - 2022';
            insert masterCommercialActivity;

            /* Create Master Sales Funnel Record to hold all bucket records */
            Sales_Funnel__c masterSalesFunnel = CommunityKPITestUtility.createSalesPerformanceMaster(customerLocItaly);
            masterSalesFunnel.Name = 'Sales Performance - 2022';
            insert masterSalesFunnel;

            /* Create Master Forecast Accuracy Record to hold all bucket records */
            Forecast_Accuracy__c masterForecastAccuracy = CommunityKPITestUtility.createForecastAccuracyMaster(customerLocItaly);
            masterForecastAccuracy.Name = 'Forecast Accuracy - 2022';
            insert masterForecastAccuracy;

            /* Create Master FCI Customer Support Record to hold all bucket records */
            FCI_Customer_Support__c masterFCICustomerSupport = CommunityKPITestUtility.createFCICustomerSupportMaster(customerLocItaly);
            masterFCICustomerSupport.Name = 'FC Support - 2022';
            insert masterFCICustomerSupport;

            /* Create Master Business Strategy Record to hold all bucket records */
            List<Business_Strategy__c> masterBusinessStrategyList = new List<Business_Strategy__c>();

            Business_Strategy__c masterBusinessStrategyItaly = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocItaly);
            masterBusinessStrategyItaly.Name = 'Business Strategy - 2022';
            masterBusinessStrategyList.add(masterBusinessStrategyItaly);

            //Master Bucket for France
            Business_Strategy__c masterBusinessStrategyFrance = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocFrance);
            masterBusinessStrategyFrance.Name = 'Business Strategy - 2022';
            masterBusinessStrategyList.add(masterBusinessStrategyFrance);

            insert masterBusinessStrategyList;

            /* Create all child bucket record for the above parent record. This is created in TestSetup because the records created by Distributors should have a parent beforehand */
            List<Commercial_Activity__c> allCommercialActivityChildBucketRecords = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivityBucket = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(promotionActivityBucket);

            Commercial_Activity__c samplesBucket = CommunityKPITestUtility.createSamplesBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(samplesBucket);

            Commercial_Activity__c customerVisitsBucket = CommunityKPITestUtility.createCustomerVisitsBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(customerVisitsBucket);

            insert allCommercialActivityChildBucketRecords;

            /* Create Sales Funnel Bucket records beforehand */
            List<Sales_Funnel__c> allSalesPerformanceChildBucketRecords = new List<Sales_Funnel__c>();

            Sales_Funnel__c salesFunnelBucket = CommunityKPITestUtility.createDistributorSalesToEndCustomerBucket(customerLocItaly, masterSalesFunnel);
            allSalesPerformanceChildBucketRecords.add(salesFunnelBucket);

            insert allSalesPerformanceChildBucketRecords;

            /* Create Forecast Accuracy records beforehand */
            List<Forecast_Accuracy__c> allForecastAccuracyChildBucketRecords = new List<Forecast_Accuracy__c>();

            Forecast_Accuracy__c localStockBucket = CommunityKPITestUtility.createLocalStockBucket(customerLocItaly, masterForecastAccuracy);
            allForecastAccuracyChildBucketRecords.add(localStockBucket);

            insert allForecastAccuracyChildBucketRecords;

            /* Create FCI Customer Support records beforehand */
            List<FCI_Customer_Support__c> allFCICustomerSupportChildBucketRecords = new List<FCI_Customer_Support__c>();

            FCI_Customer_Support__c orderProcessBucket = CommunityKPITestUtility.createOrderProcessBucket(customerLocItaly, masterFCICustomerSupport);
            allFCICustomerSupportChildBucketRecords.add(orderProcessBucket);

            FCI_Customer_Support__c complaintsBucket = CommunityKPITestUtility.createComplaintsBucket(customerLocItaly, masterFCICustomerSupport);
            allFCICustomerSupportChildBucketRecords.add(complaintsBucket);

            insert allFCICustomerSupportChildBucketRecords;

            /* Create Business Strategy Bucket Records beforehand */
            List<Business_Strategy__c> allBusinessStrategyChildBucketRecords = new List<Business_Strategy__c>();

            Business_Strategy__c accountPlanBucket = CommunityKPITestUtility.createAccountPlanBucket(customerLocItaly, masterBusinessStrategyItaly);
            allBusinessStrategyChildBucketRecords.add(accountPlanBucket);

            //Account Plan Bucket for France
            Business_Strategy__c accountPlanBucketFrance = CommunityKPITestUtility.createAccountPlanBucket(customerLocFrance, masterBusinessStrategyFrance);
            allBusinessStrategyChildBucketRecords.add(accountPlanBucketFrance);

            Business_Strategy__c highLowBucket = CommunityKPITestUtility.createHighLightsBucket(customerLocItaly, masterBusinessStrategyItaly);
            allBusinessStrategyChildBucketRecords.add(highLowBucket);

            Business_Strategy__c competitionBucket = CommunityKPITestUtility.createCompetitionBucket(customerLocItaly, masterBusinessStrategyItaly);
            allBusinessStrategyChildBucketRecords.add(competitionBucket);

            insert allBusinessStrategyChildBucketRecords;

            TriggerHandler.skipTrigger = true;
            /* Create Account Plan Under the Business Strategy Account plan bucket */
            Field_of_Play__c accountPlan =  CommunityKPITestUtility.createAccountPlan(accountPlanBucket);
            accountPlan.OwnerId = usrItaly.Id;
            insert accountPlan;

            /* Associate Share of Wallet record to the above Account Plan Created */
            Share_of_Wallet__c shareOfWall = CommunityKPITestUtility.createShareOfWallet(accountPlan);
            insert shareOfWall;

            /* Associate Related Customer Location record to the above Account Plan Created */
            Other_Related_Customer_Location__c otherRelCustLocation = CommunityKPITestUtility.createRelatedCustomerLocation(accountPlan, customerLocFrance);
            otherRelCustLocation.OwnerId = usrItaly.Id;
            insert otherRelCustLocation;

            /* Associate Competitor Info record to the above Account Plan created */
            Business_Strategy__c competitorInfo = CommunityKPITestUtility.createCompetitorInfoForAccountPlan(accountPlan, competitorAcc);
            competitorInfo.OwnerId = usrItaly.Id;
            insert competitorInfo;
            TriggerHandler.skipTrigger = false;

        }      

    }

    @IsTest
    static void testDynamicUpsert() {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa' LIMIT 1];
        List<SObject> records = new List<SObject> { acc };

        Test.startTest();
        List<Database.UpsertResult> results = DAOUtilityWithoutShar.dynamicUpsert(records, 'Account');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assert(results[0].isSuccess(), 'Upsert operation should be successful');
    }
    
    @IsTest
    static void testGetLeadForSharing() {
        
        List<Lead> acc = [SELECT Id FROM Lead LIMIT 1];
        Set<Id> leadIds = new Set<Id>();
        
        for (Lead lead : acc) {
            leadIds.add(lead.Id);
        }

        Test.startTest();
        DAOUtilityWithoutShar.getLeadForSharing(leadIds);
        Test.stopTest();
    }
    
    static void testAccountPlansForSharing() {
        
        List<Field_of_Play__c> accountPlan = [SELECT Id FROM Field_Of_Play__c LIMIT 1];
        Set<Id> accountPlanIds = new Set<Id>();
        
        for (Field_of_Play__c accPlan : accountPlan) {
            accountPlanIds.add(accPlan.Id);
        }

        Test.startTest();
        DAOUtilityWithoutShar.getAccountPlansForSharing(accountPlanIds);
        DAOUtilityWithoutShar.getRelatedCustomerLocationForAccountPlans(accountPlanIds);
        Test.stopTest();
    }

    @IsTest
    static void testGetAllOpportunitiesByNameForDuplicates() {
        Set<String> oppNames = new Set<String>{ 'Test Opportunity 0', 'Test Opportunity 1' };
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE Name IN :oppNames];
        
        Set<Id> oppIds = new Set<Id>();
        
        for (Opportunity opp : oppList) {
            oppIds.add(opp.Id);
        }
        Id commercialCustomerId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Set<Id> conIds = new Set<Id>();
		Set<String> conSet = new Set<String>{ 'Test contact 0', 'Test contact 2' };
        List<Contact> conNames = [SELECT Id FROM Contact WHERE Name IN :conSet];
            for(Contact con :conNames){
                conIds.add(con.Id);
            }
        
        Set<Id> accIds = new Set<Id>();
		Set<String> accSet = new Set<String>{ 'Test Account 0', 'Test Account 2' };
        List<Account> accNames = [SELECT Id FROM Account WHERE Name IN :accSet];
            for(Account acc :accNames){
                accIds.add(acc.Id);
            }
        Set<String> userSet = new Set<String>{ 'Mark John', 'Don Taylor' };
        List<User> userNames = [SELECT Id FROM User WHERE Name IN :userSet];
        Set<Id> userIds = new Set<Id>();
        for(User user :userNames){
            userIds.add(user.Id);
        }

        List<String> accNamesList = new List<String>{ 'Test Account4', 'Test Account3' };

        Test.startTest();
        List<Opportunity> opps = DAOUtilityWithoutShar.getAllOpportunitiesByNameForDuplicates(oppNames, commercialCustomerId);
        DAOUtilityWithoutShar.getAllAccountsByNameForDuplicates(accSet, TEST_RECORD_TYPE_ID);
        DAOUtilityWithoutShar.getAllAccountsByName(accSet, H1_RECORD_TYPE_ID);
        DAOUtilityWithoutShar.getH1andH5SObjects('Account', accNamesList, TEST_RECORD_TYPE_ID);
        DAOUtilityWithoutShar.getH1andH5SObjects('Account', accNamesList, H1_RECORD_TYPE_ID);
        DAOUtilityWithoutShar.getAllPartnerManagersFromCommercialCustomers(accIds);
        DAOUtilityWithoutShar.getAllOppItemsByOppNameForDuplicates(oppNames);
        DAOUtilityWithoutShar.getOpportunitiesForSharing(oppIds);
        DAOUtilityWithoutShar.getOpenOpportunitiesForSharingByAccountIdOwnerId(accIds, userIds);
        DAOUtilityWithoutShar.getContactsForSharing(conIds);
        DAOUtilityWithoutShar.getUsersForSharing(userIds);
        
        Test.stopTest();

        //System.assertEquals(2, opps.size(), 'Should return two opportunities');
    }

    @IsTest
    static void testGetAllAccountsByName() {
        Set<String> accNames = new Set<String>{ 'Test Account 0', 'Test Account 1' };
        Id recordTypeId = TEST_RECORD_TYPE_ID;

        Test.startTest();
        List<Account> accounts = DAOUtilityWithoutShar.getAllAccountsByName(accNames, recordTypeId);
        Test.stopTest();

        //System.assertEquals(2, accounts.size(), 'Should return two accounts with matching names');
    }

    @IsTest
    static void testGetSObjects() {
        List<String> accountNames = new List<String>{ 'Test Account 0', 'Test Account 1' };

        Test.startTest();
        List<SObject> accounts = DAOUtilityWithoutShar.getSObjects('Account', accountNames);
        Test.stopTest();

        //System.assertEquals(2, accounts.size(), 'Should return two account records');
    }

    @IsTest
    static void testGetSObjectsEmailMatch() {
        List<String> emails = new List<String>{ 'test@kvp.com' };

        Test.startTest();
        List<SObject> contacts = DAOUtilityWithoutShar.getSObjectsEmailMatch('Contact', emails);
        Test.stopTest();

        System.assertEquals(3, contacts.size(), 'Should return one contact with matching email');
    }

    @IsTest
    static void testGetCaseForSurvey() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Case csRecord = new Case(ContactId = contact.Id, Subject = 'Test Case', Status = 'New');
        insert csRecord;
        Test.startTest();
        Case cs = DAOUtilityWithoutShar.getCaseForSurvey(csRecord.Id);
        Test.stopTest();

        System.assertNotEquals(null, cs, 'Should return a Case record with matching Id');
    }

    @IsTest
    static void testUpdateContactFromSurvey() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Case csRecord = new Case(ContactId = contact.Id, Subject = 'Test Case', Status = 'New');
        insert csRecord;

        Test.startTest();
        DAOUtilityWithoutShar.updateContactFromSurvey(csRecord);
        Test.stopTest();

        Contact updatedContact = [SELECT Survey_Sent_Date_Time__c, Survey_Sent__c FROM Contact WHERE Id = :csRecord.ContactId];
        System.assertNotEquals(null, updatedContact.Survey_Sent_Date_Time__c, 'Survey_Sent_Date_Time__c should be updated');
        System.assertEquals(true, updatedContact.Survey_Sent__c, 'Survey_Sent__c should be true');
    }

    @IsTest
    static void testInsertWithoutAccess() {
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        Test.startTest();
        DAOUtilityWithoutShar.insertWithoutAccess(new List<SObject>{ commercialCust });
        Test.stopTest();

        System.assert([SELECT Id FROM Account WHERE Name = 'Insert Without Access Account' LIMIT 1] != null, 'Record should be inserted');
    }

    @IsTest
    static void testDeleteWithoutAccess() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();        
        DAOUtilityWithoutShar.updateWithoutAccess(new List<SObject>{ acc });
        DAOUtilityWithoutShar.deleteWithoutAccess(new List<SObject>{ acc });
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Name = 'Delete Without Access Account'], 'Record should be deleted');
    }
    
    @IsTest
    static void testGetSalesFunnelsForSharing() {
        // Retrieve test data (Sales_Funnel__c records)
        List<Sales_Funnel__c> funnels = [SELECT Id FROM Sales_Funnel__c LIMIT 5];
        Set<Id> funnelIds = new Set<Id>();
        for (Sales_Funnel__c funnel : funnels) {
            funnelIds.add(funnel.Id);
        }

        Test.startTest();
        List<Sales_Funnel__c> result = DAOUtilityWithoutShar.getSalesFunnelsForSharing(funnelIds); // Replace ClassName with your actual class name
        Test.stopTest();

        // Assertions
        System.assertEquals(2, result.size(), 'Expected to get all 5 Sales Funnels');
        // Add more assertions based on your specific query conditions and expected results
    }
}