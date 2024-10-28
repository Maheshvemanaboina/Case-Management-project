/*       
@Name           - CommunityBreadCrumbsControllerTest
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 23-10-2020

@Description    - Test class for CommunityBreadCrumbsController class

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 23-10-2020    | Created Class
*/
@isTest
public with sharing class CommunityBreadCrumbsControllerTest {
    
    public final static String BREADCRUMB_RECORD_TYPE   = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('BreadCrumb').getRecordTypeId();
    public final static String COMM_NAMED_PAGE_TYPE     = 'comm__namedPage';
    public final static String STANDARD_OBJ_PAGE_TYPE   = 'standard__objectPage';
    public final static String STANDARD_REC_PAGE_TYPE   = 'standard__recordPage';

    @TestSetup
    static void makeData(){
        
        TriggerHandler.skipTrigger = true;

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'FCI' Limit 1];

        User systemAdminUser = TestUtility.createUser('SystemadminUser@test.com', 'System Administrator');
        systemAdminUser.UserRoleId = userrole.Id;
        insert systemAdminUser;

        System.runAs(systemAdminUser){
            List<Account> accsCustomLocToInsert = new List<Account>();
            Account commercialCust = TestUtility.createAccount('IMCD Holding');
            accsCustomLocToInsert.add(commercialCust);

            insert accsCustomLocToInsert;

            List<Account> accsToInsert = new List<Account>();
            Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
            customerLocItaly.OwnerId = systemAdminUser.Id;
            accsToInsert.add(customerLocItaly);

            insert accsToInsert;

            List<Contact> contactsToInsert = new List<Contact>();
            Contact cItaly = TestUtility.createContact('italyCont' , 'italyCont', commercialCust, customerLocItaly);
            contactsToInsert.add(cItaly);

            Contact cIMCDItaly = TestUtility.createContact('italyContIMCD' , 'italyContIMCD', commercialCust, customerLocItaly);
            contactsToInsert.add(cIMCDItaly);

            insert contactsToInsert;

            List<User> usersToInsert = new List<User>();
            
            User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrItaly.ContactId = cItaly.Id;
            usersToInsert.add(usrItaly);

            User usrIMCDItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestusrIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrIMCDItaly.ContactId = cIMCDItaly.Id;
            usersToInsert.add(usrIMCDItaly);

            insert usersToInsert;

            Tile__c homePageTile = TestUtility.createTile('Home');
            homePageTile.RecordTypeId = BREADCRUMB_RECORD_TYPE;
            homePageTile.Community_Name__c = 'FCI Distributor Community';
            homePageTile.Navigation_Page_Type__c = COMM_NAMED_PAGE_TYPE;
            homePageTile.Object_Api_Name_Page_Api_Name__c = 'Home';

            insert homePageTile;

            Business_Strategy__c masterBusinessStrategy = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocItaly);
            
            insert masterBusinessStrategy;

            List<Business_Strategy__c> businessStratList = new List<Business_Strategy__c>();

            Business_Strategy__c accountPlanBucket = CommunityKPITestUtility.createAccountPlanBucket(customerLocItaly, masterBusinessStrategy);
            businessStratList.add(accountPlanBucket);

            Business_Strategy__c accountPlanBucket2 = CommunityKPITestUtility.createAccountPlanBucket(customerLocItaly, masterBusinessStrategy);
            accountPlanBucket2.Name = 'Account Plan Bucket 2';
            accountPlanBucket2.Fiscal_Year_FY__c = '2023';
            accountPlanBucket2.FY_Start_Date__c = Date.newInstance(2023, 1, 1);
            accountPlanBucket2.FY_End_Date__c = Date.newInstance(2023, 12, 31);
            businessStratList.add(accountPlanBucket2);

            insert businessStratList;

        }
        TriggerHandler.skipTrigger = false;
    }

    @isTest
    static void commNamedPageTest(){

        User usrItaly       = [SELECT Id FROM User where username LIKE '%TestIMCDItaly%'];
        Tile__c homeTile    = [SELECT Id, User_traversal_Info__c,UI_Name__c, Object_Api_Name_Page_Api_Name__c, Navigation_Page_Type__c FROM Tile__c where Name = 'Home'];

        Tile__c myPerformanceTile = TestUtility.createTile('My Performance');
        myPerformanceTile.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        myPerformanceTile.Community_Name__c = 'FCI Distributor Community';
        myPerformanceTile.Navigation_Page_Type__c = COMM_NAMED_PAGE_TYPE;
        myPerformanceTile.Object_Api_Name_Page_Api_Name__c = 'My_Performance__c';
        myPerformanceTile.Design_attribute_name__c = 'My Performance';
        myPerformanceTile.Parent_Tile__c = homeTile.Id;

        insert myPerformanceTile;

        List<CommunityBreadCrumbsController.BreadCrumbWrapper> breadCrumbWrapper;
        Test.startTest();

        System.runAs(usrItaly){

            breadCrumbWrapper = CommunityBreadCrumbsController.getBreadCrumbs(null, myPerformanceTile.Design_attribute_name__c, 'FCI Distributor Community');
        }
        Test.stopTest();

        System.assertEquals(breadCrumbWrapper.size(), 2);

        System.assertEquals(breadCrumbWrapper[0].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + homeTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[0].UIName, homeTile.UI_Name__c);
        System.assert(String.isBlank(homeTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[1].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + myPerformanceTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[1].UIName, myPerformanceTile.UI_Name__c);
        System.assert(String.isBlank(myPerformanceTile.User_traversal_Info__c));
    }

    @isTest
    static void standardObjectPageTest(){

        User usrItaly       = [SELECT Id FROM User where username LIKE '%TestIMCDItaly%'];
        Tile__c homeTile    = [SELECT Id, User_traversal_Info__c, UI_Name__c, Object_Api_Name_Page_Api_Name__c, Navigation_Page_Type__c FROM Tile__c where Name = 'Home'];

        List<Tile__c> tilelist = new List<Tile__c>();

        Tile__c myPerformanceTile = TestUtility.createTile('My Performance');
        myPerformanceTile.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        myPerformanceTile.Community_Name__c = 'FCI Distributor Community';
        myPerformanceTile.Navigation_Page_Type__c = COMM_NAMED_PAGE_TYPE;
        myPerformanceTile.Object_Api_Name_Page_Api_Name__c = 'My_Performance__c';
        myPerformanceTile.Design_attribute_name__c = 'My Performance';
        myPerformanceTile.Parent_Tile__c = homeTile.Id;
        
        insert myPerformanceTile;

        Tile__c businessStrategyList = TestUtility.createTile('My Business Strategy');
        businessStrategyList.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        businessStrategyList.Community_Name__c = 'FCI Distributor Community';
        businessStrategyList.Navigation_Page_Type__c = STANDARD_OBJ_PAGE_TYPE;
        businessStrategyList.Object_Api_Name_Page_Api_Name__c = 'Business_Strategy__c';
        businessStrategyList.Design_attribute_name__c = 'My Business Strategy';
        businessStrategyList.Parent_Tile__c = myPerformanceTile.Id;

        insert businessStrategyList;

        List<CommunityBreadCrumbsController.BreadCrumbWrapper> breadCrumbWrapper;
        Test.startTest();

        System.runAs(usrItaly){

            breadCrumbWrapper = CommunityBreadCrumbsController.getBreadCrumbs(null, businessStrategyList.Design_attribute_name__c, 'FCI Distributor Community');
        }
        Test.stopTest();

        System.assertEquals(breadCrumbWrapper.size(), 3);

        System.assertEquals(breadCrumbWrapper[0].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + homeTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[0].UIName, homeTile.UI_Name__c);
        System.assert(String.isBlank(homeTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[1].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + myPerformanceTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[1].UIName, myPerformanceTile.UI_Name__c);
        System.assert(String.isBlank(myPerformanceTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[2].pageInfo, STANDARD_OBJ_PAGE_TYPE + '-' + businessStrategyList.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[2].UIName, businessStrategyList.UI_Name__c);
        System.assert(String.isBlank(businessStrategyList.User_traversal_Info__c));
    }

    @isTest
    static void standardRecordPageTest(){

        User usrItaly                       = [SELECT Id FROM User where username LIKE '%TestIMCDItaly%'];
        Tile__c homeTile                    = [SELECT Id, User_traversal_Info__c, UI_Name__c, Object_Api_Name_Page_Api_Name__c, Navigation_Page_Type__c FROM Tile__c where Name = 'Home'];
        Business_Strategy__c accplanBucket  = [SELECT Id, Name FROM Business_Strategy__c WHERE Name = 'Account Plan Bucket'];
        List<Tile__c> tilelist = new List<Tile__c>();

        Tile__c myPerformanceTile = TestUtility.createTile('My Performance');
        myPerformanceTile.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        myPerformanceTile.Community_Name__c = 'FCI Distributor Community';
        myPerformanceTile.Navigation_Page_Type__c = COMM_NAMED_PAGE_TYPE;
        myPerformanceTile.Object_Api_Name_Page_Api_Name__c = 'My_Performance__c';
        myPerformanceTile.Design_attribute_name__c = 'My Performance';
        myPerformanceTile.Parent_Tile__c = homeTile.Id;
        
        insert myPerformanceTile;

        Tile__c businessStrategyList = TestUtility.createTile('My Business Strategy');
        businessStrategyList.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        businessStrategyList.Community_Name__c = 'FCI Distributor Community';
        businessStrategyList.Navigation_Page_Type__c = STANDARD_OBJ_PAGE_TYPE;
        businessStrategyList.Object_Api_Name_Page_Api_Name__c = 'Business_Strategy__c';
        businessStrategyList.Design_attribute_name__c = 'My Business Strategy';
        businessStrategyList.Parent_Tile__c = myPerformanceTile.Id;

        insert businessStrategyList;

        Tile__c businessStrategyBucket = TestUtility.createTile('Business Strategy Bucket');
        businessStrategyBucket.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        businessStrategyBucket.Community_Name__c = 'FCI Distributor Community';
        businessStrategyBucket.Navigation_Page_Type__c = STANDARD_REC_PAGE_TYPE;
        businessStrategyBucket.Object_Api_Name_Page_Api_Name__c = 'Business_Strategy__c';
        businessStrategyBucket.Design_attribute_name__c = 'Business Strategy Bucket';
        businessStrategyBucket.Parent_Tile__c = businessStrategyList.Id;
        businessStrategyBucket.Has_RecordId__c = true;

        insert businessStrategyBucket;

        List<CommunityBreadCrumbsController.BreadCrumbWrapper> breadCrumbWrapper;
        Test.startTest();

        System.runAs(usrItaly){

            breadCrumbWrapper = CommunityBreadCrumbsController.getBreadCrumbs(accplanBucket.Id, businessStrategyBucket.Design_attribute_name__c, 'FCI Distributor Community');
        }
        Test.stopTest();

        System.assertEquals(breadCrumbWrapper.size(), 4);

        System.assertEquals(breadCrumbWrapper[0].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + homeTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[0].UIName, homeTile.UI_Name__c);
        System.assert(String.isBlank(homeTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[1].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + myPerformanceTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[1].UIName, myPerformanceTile.UI_Name__c);
        System.assert(String.isBlank(myPerformanceTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[2].pageInfo, STANDARD_OBJ_PAGE_TYPE + '-' + businessStrategyList.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[2].UIName, businessStrategyList.UI_Name__c);
        System.assert(String.isBlank(businessStrategyList.User_traversal_Info__c));

        Tile__c busiessStrategyBucketTile = [SELECT Id, User_traversal_Info__c FROM Tile__c WHERE Name = 'Business Strategy Bucket'];
        System.assertEquals(breadCrumbWrapper[3].pageInfo, STANDARD_REC_PAGE_TYPE + '-' + businessStrategyBucket.Object_Api_Name_Page_Api_Name__c + '-' + accplanBucket.Id);
        System.assertEquals(breadCrumbWrapper[3].UIName, accplanBucket.Name);
        System.assert(String.isNotBlank(busiessStrategyBucketTile.User_traversal_Info__c));
        System.assert(busiessStrategyBucketTile.User_traversal_Info__c.contains(usrItaly.Id + ' | ' + accplanBucket.Id + ' | ' + accplanBucket.Name));
    }

    @isTest
    static void standardRecordPageAdditionOfUserTest(){

        User usrItaly                       = [SELECT Id FROM User where username LIKE '%TestIMCDItaly%'];
        User usrIMCDItaly                   = [SELECT Id FROM User where username LIKE '%TestusrIMCDItaly%'];
        Tile__c homeTile                    = [SELECT Id, User_traversal_Info__c, UI_Name__c, Object_Api_Name_Page_Api_Name__c, Navigation_Page_Type__c FROM Tile__c where Name = 'Home'];
        Business_Strategy__c accplanBucket  = [SELECT Id, Name FROM Business_Strategy__c WHERE Name = 'Account Plan Bucket'];
        List<Tile__c> tilelist = new List<Tile__c>();

        Tile__c myPerformanceTile = TestUtility.createTile('My Performance');
        myPerformanceTile.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        myPerformanceTile.Community_Name__c = 'FCI Distributor Community';
        myPerformanceTile.Navigation_Page_Type__c = COMM_NAMED_PAGE_TYPE;
        myPerformanceTile.Object_Api_Name_Page_Api_Name__c = 'My_Performance__c';
        myPerformanceTile.Design_attribute_name__c = 'My Performance';
        myPerformanceTile.Parent_Tile__c = homeTile.Id;
        
        insert myPerformanceTile;

        Tile__c businessStrategyList = TestUtility.createTile('My Business Strategy');
        businessStrategyList.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        businessStrategyList.Community_Name__c = 'FCI Distributor Community';
        businessStrategyList.Navigation_Page_Type__c = STANDARD_OBJ_PAGE_TYPE;
        businessStrategyList.Object_Api_Name_Page_Api_Name__c = 'Business_Strategy__c';
        businessStrategyList.Design_attribute_name__c = 'My Business Strategy';
        businessStrategyList.Parent_Tile__c = myPerformanceTile.Id;

        insert businessStrategyList;

        Tile__c businessStrategyBucket = TestUtility.createTile('Business Strategy Bucket');
        businessStrategyBucket.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        businessStrategyBucket.Community_Name__c = 'FCI Distributor Community';
        businessStrategyBucket.Navigation_Page_Type__c = STANDARD_REC_PAGE_TYPE;
        businessStrategyBucket.Object_Api_Name_Page_Api_Name__c = 'Business_Strategy__c';
        businessStrategyBucket.Design_attribute_name__c = 'Business Strategy Bucket';
        businessStrategyBucket.Parent_Tile__c = businessStrategyList.Id;
        businessStrategyBucket.Has_RecordId__c = true;

        insert businessStrategyBucket;

        List<CommunityBreadCrumbsController.BreadCrumbWrapper> breadCrumbWrapper;
        Test.startTest();

        System.runAs(usrIMCDItaly){

            CommunityBreadCrumbsController.getBreadCrumbs(accplanBucket.Id, businessStrategyBucket.Design_attribute_name__c, 'FCI Distributor Community');
        }
        System.runAs(usrItaly){

            breadCrumbWrapper = CommunityBreadCrumbsController.getBreadCrumbs(accplanBucket.Id, businessStrategyBucket.Design_attribute_name__c, 'FCI Distributor Community');
        }
        Test.stopTest();

        System.assertEquals(breadCrumbWrapper.size(), 4);

        System.assertEquals(breadCrumbWrapper[0].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + homeTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[0].UIName, homeTile.UI_Name__c);
        System.assert(String.isBlank(homeTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[1].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + myPerformanceTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[1].UIName, myPerformanceTile.UI_Name__c);
        System.assert(String.isBlank(myPerformanceTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[2].pageInfo, STANDARD_OBJ_PAGE_TYPE + '-' + businessStrategyList.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[2].UIName, businessStrategyList.UI_Name__c);
        System.assert(String.isBlank(businessStrategyList.User_traversal_Info__c));

        Tile__c busiessStrategyBucketTile = [SELECT Id, Name, User_traversal_Info__c FROM Tile__c WHERE Name = 'Business Strategy Bucket'];
        System.assertEquals(breadCrumbWrapper[3].pageInfo, STANDARD_REC_PAGE_TYPE + '-' + businessStrategyBucket.Object_Api_Name_Page_Api_Name__c + '-' + accplanBucket.Id);
        System.assertEquals(breadCrumbWrapper[3].UIName, accplanBucket.Name);
        System.assert(String.isNotBlank(busiessStrategyBucketTile.User_traversal_Info__c));
        System.assert(busiessStrategyBucketTile.User_traversal_Info__c.contains(usrItaly.Id + ' | ' + accplanBucket.Id + ' | ' + accplanBucket.Name));
        System.assert(busiessStrategyBucketTile.User_traversal_Info__c.contains(usrIMCDItaly.Id + ' | ' + accplanBucket.Id + ' | ' + accplanBucket.Name));
    }

    @isTest
    static void standardRecordPageChangeOfIdForExistingUserTest(){

        User usrItaly                       = [SELECT Id FROM User where username LIKE '%TestIMCDItaly%'];

        Tile__c homeTile                    = [SELECT Id, User_traversal_Info__c, UI_Name__c, Object_Api_Name_Page_Api_Name__c, Navigation_Page_Type__c FROM Tile__c where Name = 'Home'];
        Business_Strategy__c accplanBucket  = [SELECT Id, Name FROM Business_Strategy__c WHERE Name = 'Account Plan Bucket'];
        Business_Strategy__c accplanBucket2 = [SELECT Id, Name FROM Business_Strategy__c WHERE Name = 'Account Plan Bucket 2'];
        List<Tile__c> tilelist = new List<Tile__c>();

        Tile__c myPerformanceTile = TestUtility.createTile('My Performance');
        myPerformanceTile.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        myPerformanceTile.Community_Name__c = 'FCI Distributor Community';
        myPerformanceTile.Navigation_Page_Type__c = COMM_NAMED_PAGE_TYPE;
        myPerformanceTile.Object_Api_Name_Page_Api_Name__c = 'My_Performance__c';
        myPerformanceTile.Design_attribute_name__c = 'My Performance';
        myPerformanceTile.Parent_Tile__c = homeTile.Id;
        
        insert myPerformanceTile;

        Tile__c businessStrategyList = TestUtility.createTile('My Business Strategy');
        businessStrategyList.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        businessStrategyList.Community_Name__c = 'FCI Distributor Community';
        businessStrategyList.Navigation_Page_Type__c = STANDARD_OBJ_PAGE_TYPE;
        businessStrategyList.Object_Api_Name_Page_Api_Name__c = 'Business_Strategy__c';
        businessStrategyList.Design_attribute_name__c = 'My Business Strategy';
        businessStrategyList.Parent_Tile__c = myPerformanceTile.Id;

        insert businessStrategyList;

        Tile__c businessStrategyBucket = TestUtility.createTile('Business Strategy Bucket');
        businessStrategyBucket.RecordTypeId = BREADCRUMB_RECORD_TYPE;
        businessStrategyBucket.Community_Name__c = 'FCI Distributor Community';
        businessStrategyBucket.Navigation_Page_Type__c = STANDARD_REC_PAGE_TYPE;
        businessStrategyBucket.Object_Api_Name_Page_Api_Name__c = 'Business_Strategy__c';
        businessStrategyBucket.Design_attribute_name__c = 'Business Strategy Bucket';
        businessStrategyBucket.Parent_Tile__c = businessStrategyList.Id;
        businessStrategyBucket.Has_RecordId__c = true;

        insert businessStrategyBucket;

        List<CommunityBreadCrumbsController.BreadCrumbWrapper> breadCrumbWrapper;

        System.runAs(usrItaly){

            CommunityBreadCrumbsController.getBreadCrumbs(accplanBucket.Id, businessStrategyBucket.Design_attribute_name__c, 'FCI Distributor Community');
        }

        Tile__c busiessStrategyBuckTile = [SELECT Id, Name, User_traversal_Info__c FROM Tile__c WHERE Name = 'Business Strategy Bucket'];
        System.assert(busiessStrategyBuckTile.User_traversal_Info__c.contains(usrItaly.Id + ' | ' + accplanBucket.Id + ' | ' + accplanBucket.Name));

        Test.startTest();
        System.runAs(usrItaly){

            breadCrumbWrapper = CommunityBreadCrumbsController.getBreadCrumbs(accplanBucket2.Id, businessStrategyBucket.Design_attribute_name__c, 'FCI Distributor Community');
        }
        Test.stopTest();

        System.assertEquals(breadCrumbWrapper.size(), 4);

        System.assertEquals(breadCrumbWrapper[0].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + homeTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[0].UIName, homeTile.UI_Name__c);
        System.assert(String.isBlank(homeTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[1].pageInfo, COMM_NAMED_PAGE_TYPE + '-' + myPerformanceTile.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[1].UIName, myPerformanceTile.UI_Name__c);
        System.assert(String.isBlank(myPerformanceTile.User_traversal_Info__c));

        System.assertEquals(breadCrumbWrapper[2].pageInfo, STANDARD_OBJ_PAGE_TYPE + '-' + businessStrategyList.Object_Api_Name_Page_Api_Name__c + '-');
        System.assertEquals(breadCrumbWrapper[2].UIName, businessStrategyList.UI_Name__c);
        System.assert(String.isBlank(businessStrategyList.User_traversal_Info__c));

        Tile__c busiessStrategyBucketTile = [SELECT Id, Name, User_traversal_Info__c FROM Tile__c WHERE Name = 'Business Strategy Bucket'];
        System.assertEquals(breadCrumbWrapper[3].pageInfo, STANDARD_REC_PAGE_TYPE + '-' + businessStrategyBucket.Object_Api_Name_Page_Api_Name__c + '-' + accplanBucket2.Id);
        System.assertEquals(breadCrumbWrapper[3].UIName, accplanBucket2.Name);
        System.assert(String.isNotBlank(busiessStrategyBucketTile.User_traversal_Info__c));
        System.assert(busiessStrategyBucketTile.User_traversal_Info__c.contains(usrItaly.Id + ' | ' + accplanBucket2.Id + ' | ' + accplanBucket2.Name));
    }
}