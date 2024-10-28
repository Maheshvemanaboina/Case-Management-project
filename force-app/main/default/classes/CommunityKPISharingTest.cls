@isTest
public without sharing class CommunityKPISharingTest {
    
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

    @isTest
    static void shareCommercialActivityBucketRecords(){

        //Commercial_Activity__c masterCommercialAct = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Master Commercial Activity'];
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        Map<Id, Contact> customerLocContactMap = new Map<Id, Contact>();
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId =:customerLocItaly.Id
                           OR AccountId =:customerLocFrance.Id])
        {
            customerLocContactMap.put(con.AccountId, con);
        }
        
        Contact conItaly = customerLocContactMap.get(customerLocItaly.Id);
        Contact conFrance = customerLocContactMap.get(customerLocFrance.Id);
        
        User usrItaly = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

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
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrItaly.ContactId;
        orcl.Additional_Customer_Location__c = customerLocFrance.Id;
        
        Test.startTest();
        insert allChildBucketRecords;
        insert orcl;
        Test.stopTest();

        System.assertEquals(8, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrItaly.Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());
        System.assertEquals(4, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrFrance.Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());
        System.assertEquals(8, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrManager.Id AND (ParentId IN:masterCommercialActivityList OR ParentId IN:allChildBucketRecords)].size());
    }

    @isTest
    static void shareCommercialActivitiesRecordCreatedByDistributors(){

        List<Id> distirecordTypeIds = new List<Id>{KPIConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID,
                                                    KPIConstants.CUSTOMER_VISIT_RECORD_TYPE_ID,
                                                    KPIConstants.SAMPLE_RECORD_TYPE_ID};
        //Commercial_Activity__c masterCommercialAct = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Master Commercial Activity'];
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];
        Account commercialCust = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Holding'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];
        Commercial_Activity__c samplesBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Samples Bucket'];
        Commercial_Activity__c customerVisitsBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Customer Visit Bucket'];

        /* Create all records by Distributors */

        List<Commercial_Activity__c> allRecordsByDistributors = new List<Commercial_Activity__c>();

        Commercial_Activity__c promotionActivityItaly = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucketItaly);
        allRecordsByDistributors.add(promotionActivityItaly);

        Commercial_Activity__c samplesItaly = CommunityKPITestUtility.createSamples(customerLocItaly, samplesBucketItaly);
        allRecordsByDistributors.add(samplesItaly);

        Commercial_Activity__c customerVisitsItaly = CommunityKPITestUtility.createCustomerVisit(customerLocItaly, customerVisitsBucketItaly);
        allRecordsByDistributors.add(customerVisitsItaly);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrFrance.ContactId;
        orcl.Additional_Customer_Location__c = customerLocItaly.Id;

        Test.startTest();
        System.runAs(usrItaly){
            insert allRecordsByDistributors;
        }
        insert orcl;
        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(3, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(3, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
    }

    @isTest
    static void shareSalesPerformanceBucketRecords(){

        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        User usrItaly = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Create Master Commercial Activity Record to hold all bucket records */
        List<Sales_Funnel__c> masterSalesFunnelList = new List<Sales_Funnel__c>();

        Sales_Funnel__c masterSalesFunnelItaly = CommunityKPITestUtility.createSalesPerformanceMaster(customerLocItaly);
        masterSalesFunnelList.add(masterSalesFunnelItaly);

        Sales_Funnel__c masterSalesFunnelFrance = CommunityKPITestUtility.createSalesPerformanceMaster(customerLocFrance);
        masterSalesFunnelList.add(masterSalesFunnelFrance);

        insert masterSalesFunnelList;

        /* Create all child bucket record for the above parent record */
        List<Sales_Funnel__c> allChildBucketRecords = new List<Sales_Funnel__c>();

        /* Buckets for IMCD Italy Spa */
        Sales_Funnel__c distiSalesToEndCustomerItaly1 = CommunityKPITestUtility.createDistributorSalesToEndCustomerBucket(customerLocItaly, masterSalesFunnelItaly);
        allChildBucketRecords.add(distiSalesToEndCustomerItaly1);

        Sales_Funnel__c distiSalesToEndCustomerItaly2 = CommunityKPITestUtility.createDistributorSalesToEndCustomerBucket(customerLocItaly, masterSalesFunnelItaly);
        allChildBucketRecords.add(distiSalesToEndCustomerItaly2);

        /* Buckets for IMCD France Spa */

        Sales_Funnel__c distiSalesToEndCustomerFrance1 = CommunityKPITestUtility.createDistributorSalesToEndCustomerBucket(customerLocFrance, masterSalesFunnelFrance);
        allChildBucketRecords.add(distiSalesToEndCustomerFrance1);

        Sales_Funnel__c distiSalesToEndCustomerFrance2 = CommunityKPITestUtility.createDistributorSalesToEndCustomerBucket(customerLocFrance, masterSalesFunnelFrance);
        allChildBucketRecords.add(distiSalesToEndCustomerFrance2);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrItaly.ContactId;
        orcl.Additional_Customer_Location__c = customerLocFrance.Id;

        Test.startTest();
        insert allChildBucketRecords;
        insert orcl;
        Test.stopTest();

        System.assertEquals(6, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrItaly.Id AND (ParentId IN: masterSalesFunnelList OR ParentId IN: allChildBucketRecords) ].size());
        System.assertEquals(3, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrFrance.Id AND (ParentId IN: masterSalesFunnelList OR ParentId IN: allChildBucketRecords)].size());
        System.assertEquals(6, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrManager.Id AND (ParentId IN: masterSalesFunnelList OR ParentId IN: allChildBucketRecords)].size());
    }

    @isTest
    static void shareSalesPerformanceRecordCreatedByDistributors(){

        List<Id> distirecordTypeIds = new List<Id>{KPIConstants.DISTI_SALES_TO_END_CUSTOMER_RECORD_TYPE_ID};
        //Commercial_Activity__c masterCommercialAct = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Master Commercial Activity'];
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Sales_Funnel__c salesFunnelBucket = [SELECT Id FROM Sales_Funnel__c WHERE Name = 'Distributor Sales To End Customer Bucket'];

        /* Create all records by Distributors */

        List<Sales_Funnel__c> allRecordsByDistributors = new List<Sales_Funnel__c>();

        Sales_Funnel__c salesFunnelItaly1 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allRecordsByDistributors.add(salesFunnelItaly1);

        Sales_Funnel__c salesFunnelItaly2 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allRecordsByDistributors.add(salesFunnelItaly2);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrFrance.ContactId;
        orcl.Additional_Customer_Location__c = customerLocItaly.Id;

        Test.startTest();
        System.runAs(usrItaly){
            insert allRecordsByDistributors;
        }
        insert orcl;
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(2, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(2, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
    }

    @isTest
    static void shareForecastAccuracyBucketRecords(){

        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        User usrItaly = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Create Master Forecast Accuracy Record to hold all bucket records */
        List<Forecast_Accuracy__c> masterForecastAccuracyList = new List<Forecast_Accuracy__c>();

        Forecast_Accuracy__c masterForecastAccuracyItaly = CommunityKPITestUtility.createForecastAccuracyMaster(customerLocItaly);
        masterForecastAccuracyList.add(masterForecastAccuracyItaly);

        Forecast_Accuracy__c masterForecastAccuracyFrance = CommunityKPITestUtility.createForecastAccuracyMaster(customerLocFrance);
        masterForecastAccuracyList.add(masterForecastAccuracyFrance);

        insert masterForecastAccuracyList;

        /* Create all child bucket record for the above parent record */
        List<Forecast_Accuracy__c> allChildBucketRecords = new List<Forecast_Accuracy__c>();

        /* Buckets for IMCD Italy Spa */
        Forecast_Accuracy__c localStockItaly1 = CommunityKPITestUtility.createLocalStockBucket(customerLocItaly, masterForecastAccuracyItaly);
        allChildBucketRecords.add(localStockItaly1);

        Forecast_Accuracy__c localStockItaly2 = CommunityKPITestUtility.createLocalStockBucket(customerLocItaly, masterForecastAccuracyItaly);
        allChildBucketRecords.add(localStockItaly2);

        /* Buckets for IMCD France Spa */

        Forecast_Accuracy__c localStockFrance1 = CommunityKPITestUtility.createLocalStockBucket(customerLocFrance, masterForecastAccuracyFrance);
        allChildBucketRecords.add(localStockFrance1);

        Forecast_Accuracy__c localStockFrance2 = CommunityKPITestUtility.createLocalStockBucket(customerLocFrance, masterForecastAccuracyFrance);
        allChildBucketRecords.add(localStockFrance2);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrItaly.ContactId;
        orcl.Additional_Customer_Location__c = customerLocFrance.Id;

        Test.startTest();
        insert allChildBucketRecords;
        insert orcl;
        Test.stopTest();

        System.assertEquals(6, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrItaly.Id AND (ParentId IN: masterForecastAccuracyList OR ParentId IN:allChildBucketRecords) ].size());
        System.assertEquals(3, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrFrance.Id AND (ParentId IN: masterForecastAccuracyList OR ParentId IN:allChildBucketRecords)].size());
        System.assertEquals(6, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrManager.Id AND (ParentId IN: masterForecastAccuracyList OR ParentId IN:allChildBucketRecords)].size());
    }

    @isTest
    static void shareForecastAccuracyRecordCreatedByDistributors(){

        List<Id> distirecordTypeIds = new List<Id>{KPIConstants.LOCAL_STOCK_RECORD_TYPE_ID};
        //Commercial_Activity__c masterCommercialAct = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Master Commercial Activity'];
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Forecast_Accuracy__c forecastAccuracyBucket = [SELECT Id FROM Forecast_Accuracy__c WHERE Name = 'Local Stock Bucket'];

        /* Create all records by Distributors */

        List<Forecast_Accuracy__c> allRecordsByDistributors = new List<Forecast_Accuracy__c>();

        Forecast_Accuracy__c localStockItaly1 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allRecordsByDistributors.add(localStockItaly1);

        Forecast_Accuracy__c localStockItaly2 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allRecordsByDistributors.add(localStockItaly2);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrFrance.ContactId;
        orcl.Additional_Customer_Location__c = customerLocItaly.Id;

        Test.startTest();
        System.runAs(usrItaly){
            insert allRecordsByDistributors;
        }
        insert orcl;
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
    }

    @isTest
    static void shareFCICustomerSupportBucketRecords(){

        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        User usrItaly = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Create Master Forecast Accuracy Record to hold all bucket records */
        List<FCI_Customer_Support__c> masterFCICustomerSupportList = new List<FCI_Customer_Support__c>();

        FCI_Customer_Support__c masterFCICustomerSupportItaly = CommunityKPITestUtility.createFCICustomerSupportMaster(customerLocItaly);
        masterFCICustomerSupportList.add(masterFCICustomerSupportItaly);

        FCI_Customer_Support__c masterFCICustomerSupportFrance = CommunityKPITestUtility.createFCICustomerSupportMaster(customerLocFrance);
        masterFCICustomerSupportList.add(masterFCICustomerSupportFrance);

        insert masterFCICustomerSupportList;

        /* Create all child bucket record for the above parent record */
        List<FCI_Customer_Support__c> allChildBucketRecords = new List<FCI_Customer_Support__c>();

        /* Buckets for IMCD Italy Spa */
        FCI_Customer_Support__c orderProcessItaly1 = CommunityKPITestUtility.createOrderProcessBucket(customerLocItaly, masterFCICustomerSupportItaly);
        allChildBucketRecords.add(orderProcessItaly1);

        FCI_Customer_Support__c complaintsItaly1 = CommunityKPITestUtility.createComplaintsBucket(customerLocItaly, masterFCICustomerSupportItaly);
        allChildBucketRecords.add(complaintsItaly1);

        /* Buckets for IMCD France Spa */

        FCI_Customer_Support__c orderProcessFrance1 = CommunityKPITestUtility.createOrderProcessBucket(customerLocFrance, masterFCICustomerSupportFrance);
        allChildBucketRecords.add(orderProcessFrance1);

        FCI_Customer_Support__c complaintsFrance1 = CommunityKPITestUtility.createComplaintsBucket(customerLocFrance, masterFCICustomerSupportFrance);
        allChildBucketRecords.add(complaintsFrance1);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrItaly.ContactId;
        orcl.Additional_Customer_Location__c = customerLocFrance.Id;

        Test.startTest();
        insert allChildBucketRecords;
        insert orcl;
        Test.stopTest();

        System.assertEquals(6, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrItaly.Id AND (ParentId IN: masterFCICustomerSupportList OR ParentId IN: allChildBucketRecords) ].size());
        System.assertEquals(3, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrFrance.Id AND (ParentId IN: masterFCICustomerSupportList OR ParentId IN: allChildBucketRecords)].size());
        System.assertEquals(6, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrManager.Id AND (ParentId IN: masterFCICustomerSupportList OR ParentId IN: allChildBucketRecords)].size());

        System.assertEquals(3, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID].size());
        System.assertEquals(3, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_ORDER_PROCESS_RECORD_TYPE_ID].size());

        System.assertEquals(3, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID].size());
        System.assertEquals(3, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_COMPLAINTS_RECORD_TYPE_ID].size());
    }

    @isTest
    static void shareFCICustomerSupportRecordCreatedByDistributors(){

        List<Id> distirecordTypeIds = new List<Id>{KPIConstants.ORDER_PROCESS_RECORD_TYPE_ID};
        
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        FCI_Customer_Support__c orderProcessBucket = [SELECT Id FROM FCI_Customer_Support__c WHERE Name = 'Order Process Bucket'];

        /* Create all records by Distributors */

        List<FCI_Customer_Support__c> allRecordsByDistributors = new List<FCI_Customer_Support__c>();

        FCI_Customer_Support__c orderProcessItaly1 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allRecordsByDistributors.add(orderProcessItaly1);

        FCI_Customer_Support__c orderProcessItaly2 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allRecordsByDistributors.add(orderProcessItaly2);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrFrance.ContactId;
        orcl.Additional_Customer_Location__c = customerLocItaly.Id;

        Test.startTest();
        System.runAs(usrItaly){
            insert allRecordsByDistributors;
        }
        insert orcl;
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(2, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(2, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
    }

    @isTest
    static void shareBusinessStrategyBucketRecords(){

        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];

        User usrItaly = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Create Master Forecast Accuracy Record to hold all bucket records */
        List<Business_Strategy__c> masterBusinessStrategyList = new List<Business_Strategy__c>();

        Business_Strategy__c masterBusinessStrategyItaly = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocItaly);
        masterBusinessStrategyList.add(masterBusinessStrategyItaly);

        Business_Strategy__c masterBusinessStrategyFrance = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocFrance);
        masterBusinessStrategyList.add(masterBusinessStrategyFrance);

        insert masterBusinessStrategyList;

        /* Create all child bucket record for the above parent record */
        List<Business_Strategy__c> allChildBucketRecords = new List<Business_Strategy__c>();

        /* Buckets for IMCD Italy Spa */
        Business_Strategy__c accountPlanBucketItaly = CommunityKPITestUtility.createAccountPlanBucket(customerLocItaly, masterBusinessStrategyItaly);
        allChildBucketRecords.add(accountPlanBucketItaly);

        Business_Strategy__c highLowBucketItaly = CommunityKPITestUtility.createHighLightsBucket(customerLocItaly, masterBusinessStrategyItaly);
        allChildBucketRecords.add(highLowBucketItaly);

        Business_Strategy__c competitionBucketItaly = CommunityKPITestUtility.createCompetitionBucket(customerLocItaly, masterBusinessStrategyItaly);
        allChildBucketRecords.add(competitionBucketItaly);

        /* Buckets for IMCD France Spa */

        Business_Strategy__c accountPlanBucketFrance = CommunityKPITestUtility.createAccountPlanBucket(customerLocFrance, masterBusinessStrategyFrance);
        allChildBucketRecords.add(accountPlanBucketFrance);

        Business_Strategy__c highLowBucketFrance = CommunityKPITestUtility.createHighLightsBucket(customerLocFrance, masterBusinessStrategyFrance);
        allChildBucketRecords.add(highLowBucketFrance);

        Business_Strategy__c competitionBucketFrance = CommunityKPITestUtility.createCompetitionBucket(customerLocFrance, masterBusinessStrategyFrance);
        allChildBucketRecords.add(competitionBucketFrance);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrItaly.ContactId;
        orcl.Additional_Customer_Location__c = customerLocFrance.Id;

        Test.startTest();
        insert allChildBucketRecords;
        insert orcl;
        Test.stopTest();
        
        //This is one more because in TestSetup, Business Strategy is created without Any Trigger Execution and the owner is assigned as UsrItaly (extra record is Competitor Info Record) or else the value would have been 6
        System.assertEquals(8, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrItaly.Id AND (ParentId IN: masterBusinessStrategyList OR ParentId IN: allChildBucketRecords)].size());

        System.assertEquals(4, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id AND (ParentId IN: masterBusinessStrategyList OR ParentId IN: allChildBucketRecords)].size());
        System.assertEquals(8, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrManager.Id AND (ParentId IN: masterBusinessStrategyList OR ParentId IN: allChildBucketRecords)].size());

        System.assertEquals(4, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID].size());
        System.assertEquals(4, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID].size());

        System.assertEquals(3, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID].size());
        System.assertEquals(3, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_HIGH_LOW_LIGHTS_RECORD_TYPE_ID].size());

        System.assertEquals(3, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID].size());
        System.assertEquals(3, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_COMPETITION_RECORD_TYPE_ID].size());
    }

    @isTest
    static void shareBusinessStrategyRecordCreatedByDistributors(){

        List<Id> distirecordTypeIds = new List<Id>{KPIConstants.HIGH_LOW_LIGHT_RECORD_TYPE_ID,
                                                    KPIConstants.COMPETITION_RECORD_TYPE_ID};
        
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];
        Account competitorAcc = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'Test Competitor'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Business_Strategy__c accountPlanBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Account Plan Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];
        Business_Strategy__c HighLowBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'High Lights Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];
        Business_Strategy__c competitionBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Competitions Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];

        /* Create all records by Distributors */

        List<Business_Strategy__c> allRecordsByDistributors = new List<Business_Strategy__c>();

        Business_Strategy__c highLowLightsItaly1 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allRecordsByDistributors.add(highLowLightsItaly1);

        Business_Strategy__c highLowLightsItaly2 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allRecordsByDistributors.add(highLowLightsItaly2);

        Business_Strategy__c comeptitionItaly1 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allRecordsByDistributors.add(comeptitionItaly1);

        Business_Strategy__c comeptitionItaly2 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allRecordsByDistributors.add(comeptitionItaly2);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrFrance.ContactId;
        orcl.Additional_Customer_Location__c = customerLocItaly.Id;

        Test.startTest();
        System.runAs(usrItaly){
            insert allRecordsByDistributors;
        }
        insert orcl;
        Test.stopTest();

        System.assertEquals(4, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(4, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(4, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
    }

    @isTest
    static void shouldShareAccountPlanRecordsCreatedByDistributors(){

        List<Id> distirecordTypeIds = new List<Id>{KPIConstants.DISTRIBUTOR_ACCOUNT_PLAN};
        
        Account customerLocItaly = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];
        Account competitorAcc = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'Test Competitor'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id, Contact.AccountId, Contact.Parent_Account__c FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Business_Strategy__c accountPlanBucket = [SELECT Id, Distributor_Account_Name__c, Distributor_Parent_Account__c FROM Business_Strategy__c WHERE Name = 'Account Plan Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];
        Field_of_Play__c accountPlan =  CommunityKPITestUtility.createAccountPlan(accountPlanBucket);
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        orcl.Related_Contact__c = usrFrance.ContactId;
        orcl.Additional_Customer_Location__c = customerLocItaly.Id;
        
        Test.startTest();
        System.runAs(usrItaly){
            insert accountPlan;
        }
        insert orcl;
        Test.StopTest();

        System.assertEquals(2, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrItaly.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        System.assertEquals(2, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrFrance.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
        //This is one because in TestSetup, Account Plan created without Any Trigger Execution

        System.assertEquals(1, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrManager.Id AND Parent.RecordTypeId IN: distirecordTypeIds].size());
    }

    @isTest
    static void shouldShareAccountPlanAndRelatedRecordsOnRelatedCustomerLocationCreate(){

        List<Id> distirecordTypeIds = new List<Id>{KPIConstants.DISTRIBUTOR_ACCOUNT_PLAN};
        
        Account customerLocItaly = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];
        Account competitorAcc = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'Test Competitor'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Share CustomerLocationFrance with Distributors in Test Class */
        List<AccountShare> customerLocFranceShare = new List<AccountShare>();
        customerLocFranceShare.add((new AccountShare(AccountId = customerLocFrance.Id, UserOrGroupId = usrItaly.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read')));
        customerLocFranceShare.add((new AccountShare(AccountId = customerLocFrance.Id, UserOrGroupId = usrManager.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read')));
        insert customerLocFranceShare;

        Field_of_Play__c accountPlan = [SELECT Id FROM Field_Of_Play__c LIMIT 1];
        Other_Related_Customer_Location__c otherRelCustLocation = CommunityKPITestUtility.createRelatedCustomerLocation(accountPlan, customerLocFrance);

        System.assertEquals(0, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrFrance.Id].size());

        Test.startTest();
        System.runAs(usrItaly){

            insert otherRelCustLocation;
        }
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrFrance.Id].size());//1 Actual Account Plan Record 
        System.assertEquals(3, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrItaly.Id].size());//1 Actual Account Plan Record and 2 Shared Account Plans (Because Shared Account plans is shared from Sharing Rule)
    }

    @isTest
    static void shouldDeleteSharingOnRelatedCustomerLocationDelete(){

        Account customerLocItaly = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'IMCD France Spa'];
        Account competitorAcc = [SELECT Id,Name,OwnerId FROM Account WHERE Name = 'Test Competitor'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        /* Share CustomerLocationFrance with Distributors in Test Class */
        /*List<AccountShare> customerLocFranceShare = new List<AccountShare>();
        customerLocFranceShare.add((new AccountShare(AccountId = customerLocFrance.Id, UserOrGroupId = usrItaly.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read')));
        customerLocFranceShare.add((new AccountShare(AccountId = customerLocFrance.Id, UserOrGroupId = usrManager.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read')));
        customerLocFranceShare.add((new AccountShare(AccountId = customerLocFrance.Id, UserOrGroupId = usrFrance.Id, RowCause = 'Manual', AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read')));
        insert customerLocFranceShare;*/

        Field_of_Play__c accountPlan = [SELECT Id FROM Field_Of_Play__c LIMIT 1];
        Business_Strategy__c competitorInfo = [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.COMPETITION_ACCOUNT_PLAN_RECORD_TYPE_ID];
        Other_Related_Customer_Location__c otherRelCustLocation = [SELECT Id FROM Other_Related_Customer_Location__c];

        /* SHare Records have to be created manually because in TestData the entire account plan is created without Triggers enabled */

        List<Field_of_Play__share> accountPlanShares = new List<Field_of_Play__share>();
        accountPlanShares.add(new Field_of_Play__share(ParentId = accountPlan.Id, UserOrGroupId = usrManager.Id, RowCause = 'Manager_User__c', AccessLevel = 'Read'));
        accountPlanShares.add(new Field_of_Play__share(ParentId = accountPlan.Id, UserOrGroupId = usrFrance.Id, RowCause = 'Standard_User__c', AccessLevel = 'Read')); 
        insert accountPlanShares;

        List<Business_Strategy__Share> competitorShares = new List<Business_Strategy__Share>();
        competitorShares.add(new Business_Strategy__Share(ParentId = competitorInfo.Id, UserOrGroupId = usrManager.Id, RowCause = 'Manager_User__c', AccessLevel = 'Read'));
        competitorShares.add(new Business_Strategy__Share(ParentId = competitorInfo.Id, UserOrGroupId = usrFrance.Id, RowCause = 'Standard_User__c', AccessLevel = 'Read')); 
        insert competitorShares;

        Test.startTest();
        System.runAs(usrItaly){

            delete otherRelCustLocation;
        }
        Test.stopTest();

        /* Assert Statement to be written after implementing delete logic for Shared Account Plan */
        //System.assertEquals(0, [SELECT Id FROM Business_Strategy__Share WHERE Parent.RecordTypeId =:KPIConstants.COMPETITION_ACCOUNT_PLAN_RECORD_TYPE_ID AND UserOrGroupId =: usrFrance.Id].size());
        //System.assertEquals(0, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrFrance.Id].size());//1 Actual Account Plan Record and another Shared Account Plan Record
        //System.assertEquals(2, [SELECT Id FROM Field_of_Play__Share WHERE UserOrGroupId =: usrItaly.Id].size());//1 Actual Account Plan Record and another Shared Account Plan Record

    }

    /*@isTest
    static void shouldDeleteAllSharing(){

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        Test.startTest();
        CommercialActivitySharingUtility.deleteCommercialActivitySharing([SELECT Id FROM Commercial_Activity__c], UserUtility.getAllPartnerCommunityUsers());
        SalesFunnelSharingUtility.deleteSalesFunnelSharing([SELECT Id FROM Sales_Funnel__c], UserUtility.getAllPartnerCommunityUsers());
        ForecastAccuracySharingUtility.deleteForecastAccuracySharing([SELECT Id FROM Forecast_Accuracy__c], UserUtility.getAllPartnerCommunityUsers());
        FCICustomerSupportSharingUtility.deleteFCICustomerSupportSharing([SELECT Id FROM FCI_Customer_Support__c], UserUtility.getAllPartnerCommunityUsers());
        BusinessStrategySharingUtility.deleteBusinessStrategySharing([SELECT Id FROM Business_Strategy__c], UserUtility.getAllPartnerCommunityUsers());
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId IN (:usrItaly.Id , :usrFrance.Id, :usrManager.Id)].size());
        System.assertEquals(0, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId IN (:usrItaly.Id , :usrFrance.Id, :usrManager.Id)].size());
        System.assertEquals(0, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId IN (:usrItaly.Id , :usrFrance.Id, :usrManager.Id)].size());
        System.assertEquals(0, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId IN (:usrItaly.Id , :usrFrance.Id, :usrManager.Id)].size());
        System.assertEquals(1, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId IN (:usrItaly.Id)].size());
        System.assertEquals(0, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId IN (:usrFrance.Id, :usrManager.Id)].size());
    }*/

    @isTest
    static void shareKPIDistiCreatedRecordsWithOtherRelatedCustomers(){

        //Commercial_Activity__c masterCommercialAct = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Master Commercial Activity'];
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];
        Account competitorAcc = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'Test Competitor'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];
        Commercial_Activity__c samplesBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Samples Bucket'];
        Commercial_Activity__c customerVisitsBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Customer Visit Bucket'];

        Sales_Funnel__c salesFunnelBucket = [SELECT Id FROM Sales_Funnel__c WHERE Name = 'Distributor Sales To End Customer Bucket'];
        Forecast_Accuracy__c forecastAccuracyBucket = [SELECT Id FROM Forecast_Accuracy__c WHERE Name = 'Local Stock Bucket'];
        
        Business_Strategy__c HighLowBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'High Lights Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];
        Business_Strategy__c competitionBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Competitions Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];

        FCI_Customer_Support__c orderProcessBucket = [SELECT Id FROM FCI_Customer_Support__c WHERE Name = 'Order Process Bucket'];

        //Fetch all Master bucket data
        
        Commercial_Activity__c commercialActivityMaster = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Commercial Activity - 2022'];
        Sales_Funnel__c salesFunnelMaster = [SELECT Id FROM Sales_Funnel__c WHERE Name = 'Sales Performance - 2022'];
        Forecast_Accuracy__c forecastAccuracyMaster = [SELECT Id FROM Forecast_Accuracy__c WHERE Name = 'Forecast Accuracy - 2022'];
        Business_Strategy__c businessStrategyMaster = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Business Strategy - 2022' AND Distributor_Account__c =: customerLocItaly.Id];
        FCI_Customer_Support__c fciCustSupportMaster = [SELECT Id FROM FCI_Customer_Support__c WHERE Name = 'FC Support - 2022'];

        /* Create all records by Distributors */
        
        TriggerHandler.skipTrigger = true;

        //Insert commercial Activity records created by distributors
        List<Commercial_Activity__c> allCommercialActRecordsByDistributors = new List<Commercial_Activity__c>();

        Commercial_Activity__c promotionActivityItaly = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucketItaly);
        allCommercialActRecordsByDistributors.add(promotionActivityItaly);

        Commercial_Activity__c samplesItaly = CommunityKPITestUtility.createSamples(customerLocItaly, samplesBucketItaly);
        allCommercialActRecordsByDistributors.add(samplesItaly);

        Commercial_Activity__c customerVisitsItaly = CommunityKPITestUtility.createCustomerVisit(customerLocItaly, customerVisitsBucketItaly);
        allCommercialActRecordsByDistributors.add(customerVisitsItaly);

        insert allCommercialActRecordsByDistributors;


        //Insert Sales Performance records created by distributors
        List<Sales_Funnel__c> allSalesFunnelRecordsByDistributors = new List<Sales_Funnel__c>();

        Sales_Funnel__c salesFunnelItaly1 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allSalesFunnelRecordsByDistributors.add(salesFunnelItaly1);

        Sales_Funnel__c salesFunnelItaly2 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allSalesFunnelRecordsByDistributors.add(salesFunnelItaly2);

        insert allSalesFunnelRecordsByDistributors;

        //Insert Forecast Accuracy records created by distributors

        List<Forecast_Accuracy__c> allForecastAcRecordsByDistributors = new List<Forecast_Accuracy__c>();

        Forecast_Accuracy__c localStockItaly1 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allForecastAcRecordsByDistributors.add(localStockItaly1);

        Forecast_Accuracy__c localStockItaly2 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allForecastAcRecordsByDistributors.add(localStockItaly2);

        insert allForecastAcRecordsByDistributors;

        //Insert Business Strategy records created by distributors

        List<Business_Strategy__c> allBusinessStratRecordsByDistributors = new List<Business_Strategy__c>();

        Business_Strategy__c highLowLightsItaly1 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allBusinessStratRecordsByDistributors.add(highLowLightsItaly1);

        Business_Strategy__c highLowLightsItaly2 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allBusinessStratRecordsByDistributors.add(highLowLightsItaly2);

        Business_Strategy__c comeptitionItaly1 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allBusinessStratRecordsByDistributors.add(comeptitionItaly1);

        Business_Strategy__c comeptitionItaly2 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allBusinessStratRecordsByDistributors.add(comeptitionItaly2);

        insert allBusinessStratRecordsByDistributors;

        /* Insert all FCI Customer Support records created by Distributors */

        List<FCI_Customer_Support__c> allFCICustSupportRecordsByDistributors = new List<FCI_Customer_Support__c>();

        FCI_Customer_Support__c orderProcessItaly1 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allFCICustSupportRecordsByDistributors.add(orderProcessItaly1);

        FCI_Customer_Support__c orderProcessItaly2 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allFCICustSupportRecordsByDistributors.add(orderProcessItaly2);

        insert allFCICustSupportRecordsByDistributors;

        TriggerHandler.skipTrigger = false;
       
        List<Other_Related_Customer_Location__c> otherRelLocs = new List<Other_Related_Customer_Location__c>();

        //Share Commercial Activity Records creation Other Related Location records

        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Commercial_Activity__c = commercialActivityMaster.Id,Distributor_Location__c = customerLocFrance.Id));
        
        //Share Commercial Activity Records creation Other Related Location records

        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Sales_Performance__c = salesFunnelMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        //Share Forecast Accuracy Records creation Other Related Location records

        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Forecast_Accuracy__c = forecastAccuracyMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        //Share Business Strategy Records creation Other Related Location records

        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Business_Strategy__c = businessStrategyMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        //Share FCI Customer Support Records creation Other Related Location records

        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_FCI_Customer_Support__c = fciCustSupportMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        
        System.runAs(usrManager){
            Test.startTest();
            insert otherRelLocs;
            Test.stopTest();
        }
		
        System.assertEquals(7, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(4, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(4, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(5, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrFrance.Id].size()); //Complaints bucket shared from TestSetup
        System.assertEquals(10, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        
    }

    @isTest
    static void deleteKPISharingWithOtherRelatedCustomersDelete(){

        //Commercial_Activity__c masterCommercialAct = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Master Commercial Activity'];
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];
        Account competitorAcc = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'Test Competitor'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];
        Commercial_Activity__c samplesBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Samples Bucket'];
        Commercial_Activity__c customerVisitsBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Customer Visit Bucket'];

        Sales_Funnel__c salesFunnelBucket = [SELECT Id FROM Sales_Funnel__c WHERE Name = 'Distributor Sales To End Customer Bucket'];
        Forecast_Accuracy__c forecastAccuracyBucket = [SELECT Id FROM Forecast_Accuracy__c WHERE Name = 'Local Stock Bucket'];
        Business_Strategy__c HighLowBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'High Lights Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];
        Business_Strategy__c competitionBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Competitions Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];

        FCI_Customer_Support__c orderProcessBucket = [SELECT Id FROM FCI_Customer_Support__c WHERE Name = 'Order Process Bucket'];

        //Fetch all Master bucket data
        
        Commercial_Activity__c commercialActivityMaster = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Commercial Activity - 2022'];
        Sales_Funnel__c salesFunnelMaster = [SELECT Id FROM Sales_Funnel__c WHERE Name = 'Sales Performance - 2022'];
        Forecast_Accuracy__c forecastAccuracyMaster = [SELECT Id FROM Forecast_Accuracy__c WHERE Name = 'Forecast Accuracy - 2022'];
        Business_Strategy__c businessStrategyMaster = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Business Strategy - 2022' AND Distributor_Account__c =: customerLocItaly.Id];
        FCI_Customer_Support__c fciCustSupportMaster = [SELECT Id FROM FCI_Customer_Support__c WHERE Name = 'FC Support - 2022'];

        /* Create all records by Distributors */
        
        TriggerHandler.skipTrigger = true;

        //Insert commercial Activity records created by distributors
        List<Commercial_Activity__c> allCommercialActRecordsByDistributors = new List<Commercial_Activity__c>();

        Commercial_Activity__c promotionActivityItaly = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucketItaly);
        allCommercialActRecordsByDistributors.add(promotionActivityItaly);

        Commercial_Activity__c samplesItaly = CommunityKPITestUtility.createSamples(customerLocItaly, samplesBucketItaly);
        allCommercialActRecordsByDistributors.add(samplesItaly);

        Commercial_Activity__c customerVisitsItaly = CommunityKPITestUtility.createCustomerVisit(customerLocItaly, customerVisitsBucketItaly);
        allCommercialActRecordsByDistributors.add(customerVisitsItaly);

        insert allCommercialActRecordsByDistributors;

        //Insert Sales Performance records created by distributors
        List<Sales_Funnel__c> allSalesFunnelRecordsByDistributors = new List<Sales_Funnel__c>();

        Sales_Funnel__c salesFunnelItaly1 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allSalesFunnelRecordsByDistributors.add(salesFunnelItaly1);

        Sales_Funnel__c salesFunnelItaly2 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allSalesFunnelRecordsByDistributors.add(salesFunnelItaly2);

        insert allSalesFunnelRecordsByDistributors;

        //Insert Forecast Accuracy records created by distributors

        List<Forecast_Accuracy__c> allForecastAcRecordsByDistributors = new List<Forecast_Accuracy__c>();

        Forecast_Accuracy__c localStockItaly1 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allForecastAcRecordsByDistributors.add(localStockItaly1);

        Forecast_Accuracy__c localStockItaly2 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allForecastAcRecordsByDistributors.add(localStockItaly2);

        insert allForecastAcRecordsByDistributors;

        //Insert Business Strategy records created by distributors

        List<Business_Strategy__c> allBusinessStratRecordsByDistributors = new List<Business_Strategy__c>();

        Business_Strategy__c highLowLightsItaly1 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allBusinessStratRecordsByDistributors.add(highLowLightsItaly1);

        Business_Strategy__c highLowLightsItaly2 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allBusinessStratRecordsByDistributors.add(highLowLightsItaly2);

        Business_Strategy__c comeptitionItaly1 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allBusinessStratRecordsByDistributors.add(comeptitionItaly1);

        Business_Strategy__c comeptitionItaly2 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allBusinessStratRecordsByDistributors.add(comeptitionItaly2);

        insert allBusinessStratRecordsByDistributors;

        /* Insert all FCI Customer Support records created by Distributors */

        List<FCI_Customer_Support__c> allFCICustSupportRecordsByDistributors = new List<FCI_Customer_Support__c>();

        FCI_Customer_Support__c orderProcessItaly1 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allFCICustSupportRecordsByDistributors.add(orderProcessItaly1);

        FCI_Customer_Support__c orderProcessItaly2 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allFCICustSupportRecordsByDistributors.add(orderProcessItaly2);

        insert allFCICustSupportRecordsByDistributors;

        TriggerHandler.skipTrigger = false;
        
        List<Other_Related_Customer_Location__c> otherRelLocs = new List<Other_Related_Customer_Location__c>();

        //Share Commercial Activity Records creation Other Related Location records

        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Commercial_Activity__c = commercialActivityMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        //Share Sales performance Records creation Other Related Location records
        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Sales_Performance__c = salesFunnelMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        //Share Forecast Accuracy Records creation Other Related Location records
        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Forecast_Accuracy__c = forecastAccuracyMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        //Share Business Strategy Records creation Other Related Location records
        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_Business_Strategy__c = businessStrategyMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        //Share FCI Customer Support Records creation Other Related Location records
        otherRelLocs.add(new Other_Related_Customer_Location__c(Related_FCI_Customer_Support__c = fciCustSupportMaster.Id,Distributor_Location__c = customerLocFrance.Id));

        System.runAs(usrManager){
            insert otherRelLocs;
        }

        System.runAs(usrManager){

            Test.startTest();
            delete otherRelLocs;
            Test.stopTest();
        }

        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrFrance.Id].size());
    }
    
    @isTest
    static void shareKPIRecordsOnCreatingAdditionalCustLocations(){

        //Commercial_Activity__c masterCommercialAct = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Master Commercial Activity'];
        Account customerLocItaly = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD Italy Spa'];
        Account customerLocFrance = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'IMCD France Spa'];
        Account competitorAcc = [SELECT Id, Name, OwnerId, ParentId FROM Account WHERE Name = 'Test Competitor'];

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User usrFrance = [SELECT Id, ContactId FROM User WHERE userName LIKE '%TestIMCDFrance%'];
        User usrManager = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDManager%'];

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];
        Commercial_Activity__c samplesBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Samples Bucket'];
        Commercial_Activity__c customerVisitsBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Customer Visit Bucket'];

        Sales_Funnel__c salesFunnelBucket = [SELECT Id FROM Sales_Funnel__c WHERE Name = 'Distributor Sales To End Customer Bucket'];
        Forecast_Accuracy__c forecastAccuracyBucket = [SELECT Id FROM Forecast_Accuracy__c WHERE Name = 'Local Stock Bucket'];
        
        Business_Strategy__c HighLowBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'High Lights Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];
        Business_Strategy__c competitionBucket = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Competitions Bucket' AND Parent_Business_Strategy__r.Distributor_Account__c =: customerLocItaly.Id];

        FCI_Customer_Support__c orderProcessBucket = [SELECT Id FROM FCI_Customer_Support__c WHERE Name = 'Order Process Bucket'];

        //Fetch all Master bucket data
        
        Commercial_Activity__c commercialActivityMaster = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Commercial Activity - 2022'];
        Sales_Funnel__c salesFunnelMaster = [SELECT Id FROM Sales_Funnel__c WHERE Name = 'Sales Performance - 2022'];
        Forecast_Accuracy__c forecastAccuracyMaster = [SELECT Id FROM Forecast_Accuracy__c WHERE Name = 'Forecast Accuracy - 2022'];
        Business_Strategy__c businessStrategyMaster = [SELECT Id FROM Business_Strategy__c WHERE Name = 'Business Strategy - 2022' AND Distributor_Account__c =: customerLocItaly.Id];
        FCI_Customer_Support__c fciCustSupportMaster = [SELECT Id FROM FCI_Customer_Support__c WHERE Name = 'FC Support - 2022'];

        /* Create all records by Distributors */
        
        TriggerHandler.skipTrigger = true;

        //Insert commercial Activity records created by distributors
        List<Commercial_Activity__c> allCommercialActRecordsByDistributors = new List<Commercial_Activity__c>();

        Commercial_Activity__c promotionActivityItaly = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucketItaly);
        allCommercialActRecordsByDistributors.add(promotionActivityItaly);

        Commercial_Activity__c samplesItaly = CommunityKPITestUtility.createSamples(customerLocItaly, samplesBucketItaly);
        allCommercialActRecordsByDistributors.add(samplesItaly);

        Commercial_Activity__c customerVisitsItaly = CommunityKPITestUtility.createCustomerVisit(customerLocItaly, customerVisitsBucketItaly);
        allCommercialActRecordsByDistributors.add(customerVisitsItaly);

        insert allCommercialActRecordsByDistributors;


        //Insert Sales Performance records created by distributors
        List<Sales_Funnel__c> allSalesFunnelRecordsByDistributors = new List<Sales_Funnel__c>();

        Sales_Funnel__c salesFunnelItaly1 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allSalesFunnelRecordsByDistributors.add(salesFunnelItaly1);

        Sales_Funnel__c salesFunnelItaly2 = CommunityKPITestUtility.createDistributorSalesToEndCustomer(customerLocItaly, salesFunnelBucket);
        allSalesFunnelRecordsByDistributors.add(salesFunnelItaly2);

        insert allSalesFunnelRecordsByDistributors;

        //Insert Forecast Accuracy records created by distributors

        List<Forecast_Accuracy__c> allForecastAcRecordsByDistributors = new List<Forecast_Accuracy__c>();

        Forecast_Accuracy__c localStockItaly1 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allForecastAcRecordsByDistributors.add(localStockItaly1);

        Forecast_Accuracy__c localStockItaly2 = CommunityKPITestUtility.createLocalStock(customerLocItaly, forecastAccuracyBucket);
        allForecastAcRecordsByDistributors.add(localStockItaly2);

        insert allForecastAcRecordsByDistributors;

        //Insert Business Strategy records created by distributors

        List<Business_Strategy__c> allBusinessStratRecordsByDistributors = new List<Business_Strategy__c>();

        Business_Strategy__c highLowLightsItaly1 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allBusinessStratRecordsByDistributors.add(highLowLightsItaly1);

        Business_Strategy__c highLowLightsItaly2 = CommunityKPITestUtility.createHighLowLights(customerLocItaly, HighLowBucket);
        allBusinessStratRecordsByDistributors.add(highLowLightsItaly2);

        Business_Strategy__c comeptitionItaly1 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allBusinessStratRecordsByDistributors.add(comeptitionItaly1);

        Business_Strategy__c comeptitionItaly2 = CommunityKPITestUtility.createCompetitions(customerLocItaly, competitionBucket, competitorAcc);
        allBusinessStratRecordsByDistributors.add(comeptitionItaly2);

        insert allBusinessStratRecordsByDistributors;

        /* Insert all FCI Customer Support records created by Distributors */

        List<FCI_Customer_Support__c> allFCICustSupportRecordsByDistributors = new List<FCI_Customer_Support__c>();

        FCI_Customer_Support__c orderProcessItaly1 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allFCICustSupportRecordsByDistributors.add(orderProcessItaly1);

        FCI_Customer_Support__c orderProcessItaly2 = CommunityKPITestUtility.createOrderProcess(customerLocItaly, orderProcessBucket);
        allFCICustSupportRecordsByDistributors.add(orderProcessItaly2);

        insert allFCICustSupportRecordsByDistributors;

        TriggerHandler.skipTrigger = false;
       
        List<Other_Related_Customer_Location__c> otherRelLocs = new List<Other_Related_Customer_Location__c>();

        //Share KPI Records creation of Additional Customer Location records

        otherRelLocs.add(new Other_Related_Customer_Location__c(RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID, Related_Contact__c = usrFrance.ContactId,Additional_Customer_Location__c = customerLocItaly.Id));
        
        //System.runAs(usrManager){
            Test.startTest();
            insert otherRelLocs;
            Test.stopTest();
        //}
		
        System.assertEquals(7, [SELECT Id FROM Commercial_Activity__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(4, [SELECT Id FROM Sales_Funnel__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(4, [SELECT Id FROM Forecast_Accuracy__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        System.assertEquals(5, [SELECT Id FROM FCI_Customer_Support__Share WHERE UserOrGroupId =: usrFrance.Id].size()); //Complaints bucket shared from TestSetup
        System.assertEquals(10, [SELECT Id FROM Business_Strategy__Share WHERE UserOrGroupId =: usrFrance.Id].size());
        
    }

    
}