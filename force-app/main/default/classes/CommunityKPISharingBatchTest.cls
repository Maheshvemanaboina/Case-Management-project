@isTest
public class CommunityKPISharingBatchTest {
    
    @TestSetup
    static void makeData(){
        
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

            insert accShareToInsert;

            TriggerHandler.skipTrigger = false;

            /* Create Master Commercial Activity Record to hold all bucket records */
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            insert masterCommercialActivity;

            /* Create Master Sales Funnel Record to hold all bucket records */
            Sales_Funnel__c masterSalesFunnel = CommunityKPITestUtility.createSalesPerformanceMaster(customerLocItaly);
            insert masterSalesFunnel;

            /* Create Master Forecast Accuracy Record to hold all bucket records */
            Forecast_Accuracy__c masterForecastAccuracy = CommunityKPITestUtility.createForecastAccuracyMaster(customerLocItaly);
            insert masterForecastAccuracy;

            /* Create Master FCI Customer Support Record to hold all bucket records */
            FCI_Customer_Support__c masterFCICustomerSupport = CommunityKPITestUtility.createFCICustomerSupportMaster(customerLocItaly);
            insert masterFCICustomerSupport;

            /* Create Master Business Strategy Record to hold all bucket records */
            List<Business_Strategy__c> masterBusinessStrategyList = new List<Business_Strategy__c>();

            Business_Strategy__c masterBusinessStrategy = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocItaly);
            masterBusinessStrategyList.add(masterBusinessStrategy);

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

            Business_Strategy__c accountPlanBucket = CommunityKPITestUtility.createAccountPlanBucket(customerLocItaly, masterBusinessStrategy);
            allBusinessStrategyChildBucketRecords.add(accountPlanBucket);

            Business_Strategy__c highLowBucket = CommunityKPITestUtility.createHighLightsBucket(customerLocItaly, masterBusinessStrategy);
            allBusinessStrategyChildBucketRecords.add(highLowBucket);

            Business_Strategy__c competitionBucket = CommunityKPITestUtility.createCompetitionBucket(customerLocItaly, masterBusinessStrategy);
            allBusinessStrategyChildBucketRecords.add(competitionBucket);

            insert allBusinessStrategyChildBucketRecords;

            /* Create all Commercial Activity records by Distributors */

            List<Commercial_Activity__c> allCommercialActivityRecordsByDistributors = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivityItaly = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucket);
            promotionActivityItaly.OwnerId = usrItaly.Id;
            allCommercialActivityRecordsByDistributors.add(promotionActivityItaly);

            Commercial_Activity__c samplesItaly = CommunityKPITestUtility.createSamples(customerLocItaly, samplesBucket);
            samplesItaly.OwnerId = usrItaly.Id;
            allCommercialActivityRecordsByDistributors.add(samplesItaly);

            Commercial_Activity__c customerVisitsItaly = CommunityKPITestUtility.createCustomerVisit(customerLocItaly, customerVisitsBucket);
            customerVisitsItaly.OwnerId = usrItaly.Id;
            allCommercialActivityRecordsByDistributors.add(customerVisitsItaly);

            insert allCommercialActivityRecordsByDistributors;

            /* Create all Sales Funnel records by Distributors */

            List<Sales_Funnel__c> allSalesFunnelRecordsByDistributors = new List<Sales_Funnel__c>();

            Sales_Funnel__c salesFunnelItaly1 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
            salesFunnelItaly1.OwnerId = usrItaly.Id;
            allSalesFunnelRecordsByDistributors.add(salesFunnelItaly1);

            Sales_Funnel__c salesFunnelItaly2 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
            salesFunnelItaly2.OwnerId = usrItaly.Id;
            allSalesFunnelRecordsByDistributors.add(salesFunnelItaly2);

            insert allSalesFunnelRecordsByDistributors;

            /* Create all Forecast Accuracy records by Distributors */

            List<Forecast_Accuracy__c> allForecastAccuracyRecordsByDistributors = new List<Forecast_Accuracy__c>();

            Forecast_Accuracy__c localStockItaly1 = CommunityKPITestUtility.createLocalStock(customerLocItaly, localStockBucket);
            localStockItaly1.OwnerId = usrItaly.Id;
            allForecastAccuracyRecordsByDistributors.add(localStockItaly1);

            Forecast_Accuracy__c localStockItaly2 = CommunityKPITestUtility.createLocalStock(customerLocItaly, localStockBucket);
            localStockItaly2.OwnerId = usrItaly.Id;
            allForecastAccuracyRecordsByDistributors.add(localStockItaly2);

            insert allForecastAccuracyRecordsByDistributors;

            /* Create all FCI Customer Support records by Distributors */
            List<FCI_Customer_Support__c> allFCICustomerSupportRecordsByDistributors = new List<FCI_Customer_Support__c>();

            FCI_Customer_Support__c orderProcessItaly1 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
            orderProcessItaly1.OwnerId = usrItaly.Id;
            allFCICustomerSupportRecordsByDistributors.add(orderProcessItaly1);

            FCI_Customer_Support__c orderProcessItaly2 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
            orderProcessItaly2.OwnerId = usrItaly.Id;
            allFCICustomerSupportRecordsByDistributors.add(orderProcessItaly2);

            insert allFCICustomerSupportRecordsByDistributors;

            /* Create all Business Strategy records by Distributors */

            List<Business_Strategy__c> allBusinessStrategyRecordsByDistributors = new List<Business_Strategy__c>();

            Business_Strategy__c highLowLightsItaly1 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
            highLowLightsItaly1.OwnerId = usrItaly.Id;
            allBusinessStrategyRecordsByDistributors.add(highLowLightsItaly1);

            Business_Strategy__c highLowLightsItaly2 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
            highLowLightsItaly2.OwnerId = usrItaly.Id;
            allBusinessStrategyRecordsByDistributors.add(highLowLightsItaly2);

            Business_Strategy__c comeptitionItaly1 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
            comeptitionItaly1.OwnerId = usrItaly.Id;
            allBusinessStrategyRecordsByDistributors.add(comeptitionItaly1);

            Business_Strategy__c comeptitionItaly2 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
            comeptitionItaly2.OwnerId = usrItaly.Id;
            allBusinessStrategyRecordsByDistributors.add(comeptitionItaly2);

            insert allBusinessStrategyRecordsByDistributors;

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

        }

        TriggerHandler.skipTrigger = false;

    }

    @isTest
    static void shouldDeleteAllSharingAndRecreateSharing(){

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        Test.startTest();
        CommunityKPISharingBatch.initiateKPISharingBatch();
        Test.stopTest();

        System.assertEquals(7, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrItaly.Id].size());// 3 buckets & 3 records by Distributors
        // no records created by Usr France
        System.assertEquals(7, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrManager.Id].size());// Manager user sees all records

        System.assertEquals(4, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrItaly.Id].size());//1 bucket & 2 records by Distributor
        // no records created by Usr France
        System.assertEquals(4, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrManager.Id].size());// Manager user sees all records

        System.assertEquals(4, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrItaly.Id].size());//1 bucket & 2 records by Distributor
        // no records created by Usr France
        //Manager sees all records that is 3

        System.assertEquals(5, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrItaly.Id].size());//2 bucket & 2 records by Distributor
        // no records created by Usr France
        //Manager sees all records that is 4

        System.assertEquals(9, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrItaly.Id].size());//3 bucket & 4 records by Distributors & 1 from Account Plan
        // Manager also has the same record access as UsrItaly
    }
    
}