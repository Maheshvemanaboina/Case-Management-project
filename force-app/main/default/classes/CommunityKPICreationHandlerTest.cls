@isTest
public class CommunityKPICreationHandlerTest {
    
    @TestSetup
    static void makeData(){
        
        TriggerHandler.skipTrigger = true;

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'FCI' Limit 1];

        /* create Internal Users */
        List<User> internalUsersToInsert = new List<User>();
        User FCIUser1 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser1', 'System Administrator');
        FCIUser1.UserRoleId = userrole.Id;
        internalUsersToInsert.add(FCIUser1);

        insert internalUsersToInsert;

        System.runAs(FCIUser1){

            /* Creates H1 */
            List<Account> commercialAccsToInsert = new List<Account>();

            Account commercialCustIMCD = TestUtility.createAccount('H1 IMCD Holding');
            commercialAccsToInsert.add(commercialCustIMCD);

            Account commercialCustKUK = TestUtility.createAccount('H1 KUK');
            commercialAccsToInsert.add(commercialCustKUK);
            insert commercialAccsToInsert;

            /* Creates H5 which is the Distributor Location */
            List<Account> accsToInsert = new List<Account>();
            Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCustIMCD);
            customerLocItaly.OwnerId = FCIUser1.Id;
            accsToInsert.add(customerLocItaly);

            Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCustIMCD);
            customerLocFrance.OwnerId = FCIUser1.Id;
            accsToInsert.add(customerLocFrance);

            Account customerLocKUK = TestUtility.createCustomerLocation('Kuk Baltics', commercialCustKUK);
            customerLocKUK.OwnerId = FCIUser1.Id;
            accsToInsert.add(customerLocKUK);

            insert accsToInsert;

            /* Create Contacts under H5, these contacts will be Distributors */
            List<Contact> contactsToInsert = new List<Contact>();
            Contact cItaly = TestUtility.createContact(commercialCustIMCD, customerLocItaly);
            contactsToInsert.add(cItaly);

            Contact cFrance = TestUtility.createContact(commercialCustIMCD, customerLocFrance);
            contactsToInsert.add(cFrance);

            Contact cKUK = TestUtility.createContact(commercialCustKUK, customerLocKUK);
            contactsToInsert.add(cKUK);

            insert contactsToInsert;

            /* Distributor User To Insert */
            List<User> usersToInsert = new List<User>();
            User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrItaly.ContactId = cItaly.Id;
            usersToInsert.add(usrItaly);

            User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrFrance.ContactId = cFrance.Id;
            usersToInsert.add(usrFrance);

            User usrKUK = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestKUK', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrKUK.ContactId = cKUK.Id;
            usersToInsert.add(usrKUK);

            insert usersToInsert;
        
            //Create Master Commercial Activity Record to not create existing Master Commercial Activity record 
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            masterCommercialActivity.Name = 'Commercial Activity - 2022 - 1st Half Year';
            insert masterCommercialActivity;

            Commercial_Activity__c promotionActivityBucket = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly,masterCommercialActivity);
            promotionActivityBucket.Name = 'Promotion Activity - 2022 - 1st Half Year';
            insert promotionActivityBucket;

        }

        TriggerHandler.skipTrigger = false;

    }

    @isTest
    static void shouldCreateKPIRecordsOnlyFiscalYear(){

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocKUK = accsMap.get('Kuk Baltics'); //Customer location test record

        User adminFC = [SELECT Id FROM User WHERE Username LIKE '%FCIUser1%' LIMIT 1];

        System.runAs(adminFC){

            Test.startTest();
            CommunityKPICreationHandler.createKPIRecords('2023');
            Test.stopTest();
        }

        System.assertEquals(3, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());

        System.assertEquals(18, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(6, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(12, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(12, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(15, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
    }


    @isTest
    static void shouldCreateKPIRecordsFiscalYearAndDistiLocations(){

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocKUK = accsMap.get('Kuk Baltics'); //Customer location test record

        User adminFC = [SELECT Id FROM User WHERE Username LIKE '%FCIUser1%' LIMIT 1];

        System.runAs(adminFC){

            Test.startTest();
            CommunityKPICreationHandler.createKPIRecords('2023', new Set<Id>{customerLocFrance.Id, customerLocKUK.Id});
            Test.stopTest();
        }

        System.assertEquals(2, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());

        System.assertEquals(12, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(4, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(8, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(8, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(10, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
    }

    @isTest
    static void shouldCreateKPIRecordsFiscalYearAndPeriod(){

        User adminFC = [SELECT Id FROM User WHERE Username LIKE '%FCIUser1%' LIMIT 1];

        System.runAs(adminFC){

            Test.startTest();
            CommunityKPICreationHandler.createKPIRecords('2023', '1st Half Year');
            Test.stopTest();
        }

        System.assertEquals(3, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());

        System.assertEquals(9, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(6, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(6, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(9, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
    }

    @isTest
    static void shouldCreateKPIRecordsFiscalYearAndPeriodAndDistiLoc(){

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocKUK = accsMap.get('Kuk Baltics'); //Customer location test record

        User adminFC = [SELECT Id FROM User WHERE Username LIKE '%FCIUser1%' LIMIT 1];

        System.runAs(adminFC){

            Test.startTest();
            CommunityKPICreationHandler.createKPIRecords('2023', '1st Half Year', new Set<Id>{customerLocFrance.Id, customerLocKUK.Id});
            Test.stopTest();
        }

        System.assertEquals(2, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());

        System.assertEquals(6, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(4, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(4, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(6, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
    }

    @isTest
    static void shouldCreateAccountKPIRecordsFiscalYear(){

        User adminFC = [SELECT Id FROM User WHERE Username LIKE '%FCIUser1%' LIMIT 1];

        System.runAs(adminFC){

            Test.startTest();
            CommunityKPICreationHandler.createAccountPlanKPIRecords('2023');
            Test.stopTest();
        }

        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());

        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(3, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
    }

    @isTest
    static void shouldCreateAccountKPIRecordsFiscalYearAndDistiLoc(){

        List<Account> accs = [SELECT Id, Name FROM Account]; //Accounts list to retrieve from the database
        Map<String, Account> accsMap = new Map<String, Account>(); //Auxiliar Map to separate the accounts

        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa'); //Customer location test record
        Account customerLocFrance = accsMap.get('IMCD France Spa'); //Customer location test record
        Account customerLocKUK = accsMap.get('Kuk Baltics'); //Customer location test record

        User adminFC = [SELECT Id FROM User WHERE Username LIKE '%FCIUser1%' LIMIT 1];

        System.runAs(adminFC){

            Test.startTest();
            CommunityKPICreationHandler.createAccountPlanKPIRecords('2023', new Set<Id>{customerLocFrance.Id, customerLocKUK.Id});
            Test.stopTest();
        }

        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());

        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(0, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND (NOT NAME LIKE '%2022%')].size());
    }

    /*
    @isTest
    static void shouldCreateMasterandBucketRecords(){

        Test.startTest();
        CommunityKPICreationHandler.createKPIRecords('2022','1st Half Year');
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID].size());

        System.assertEquals(6, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(4, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(4, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(6, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND RecordTypeId !=: KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID].size());
    }

    @isTest
    static void shouldCreateMasterAndBucketAccountPlanRecords(){

        Test.startTest();
        CommunityKPICreationHandler.createAccountPlanKPIRecords('2022','1st Half Year');
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID].size());
    }

    @isTest
    static void shouldCreateMasterAndBucketForSpecificDistis(){

        Account accItaly = [SELECT Id FROM Account WHERE Name like '%IMCD Italy Spa%' LIMIT 1];
        User usrFrance = [SELECT Id FROM User WHERE Username Like '%TestIMCDFrance%' LIMIT 1];

        Test.startTest();
        CommunityKPICreationHandler.createKPIRecords('2022', '1st Half Year', new Set<Id>{accItaly.Id});
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID].size());

        for(Commercial_Activity__c eachComAct : [SELECT Id, Name, Distributor_Account_Name__r.Name, Distributor_Parent_Account__r.Name  FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID]){

            System.debug(' each com 1 '+eachComAct.Name);
            System.debug(' each com 2 '+eachComAct.Distributor_Account_Name__r.Name);
            System.debug(' each com 3 '+eachComAct.Distributor_Parent_Account__r.Name);
        }
        System.assertEquals(3, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId !=: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(1, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId !=: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId !=: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(2, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId !=: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID].size());
        System.assertEquals(3, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId !=: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND RecordTypeId !=: KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID].size());

        // Records should not be created for France User
        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.COMMERCIAL_ACTIVITY_MASTER_RECORD_TYPE_ID AND Distributor_Account__c =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM Forecast_Accuracy__c WHERE RecordTypeId =: KPIConstants.FORECAST_MASTER_RECORD_TYPE_ID AND Distributor_Account__c =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM Sales_Funnel__c WHERE RecordTypeId =: KPIConstants.SALES_FUNNEL_MASTER_RECORD_TYPE_ID AND Distributor_Account__c =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM FCI_Customer_Support__c WHERE RecordTypeId =: KPIConstants.FCI_CUSTOMER_SUPPORT_MASTER_RECORD_TYPE_ID AND Distributor_Account__c =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.BUSINESS_STRATEGY_MASTER_RECORD_TYPE_ID AND Distributor_Account__c =: usrFrance.Id].size());
        System.assertEquals(0, [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =: KPIConstants.HIGH_LOW_COMPETITION_MASTER_RECORD_TYPE_ID AND Distributor_Account__c =: usrFrance.Id].size());
    }

    */
    
}