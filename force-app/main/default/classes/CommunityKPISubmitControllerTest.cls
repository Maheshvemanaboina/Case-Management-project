@isTest
public class CommunityKPISubmitControllerTest {
    
    @TestSetup
    static void makeData(){

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'FCI' Limit 1];

        /* create Internal Users */
        List<User> internalUsersToInsert = new List<User>();
        User FCIUser1 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser1', 'System Administrator');
        FCIUser1.UserRoleId = userrole.Id;
        FCIUser1.Business_Segment__c='Adult Nutrition';
        internalUsersToInsert.add(FCIUser1);

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

            insert accsToInsert;

            /* Create Contacts under H5, these contacts will be Distributors */
            List<Contact> contactsToInsert = new List<Contact>();
            Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cItaly);

            insert contactsToInsert;

            List<User> usersToInsert = new List<User>();
            User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrItaly.ContactId = cItaly.Id;
            usersToInsert.add(usrItaly);

            insert usersToInsert;

            /* Create Master Commercial Activity Record to hold all bucket records */
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            insert masterCommercialActivity;

            /* Create all child bucket record for the above parent record. This is created in TestSetup because the records created by Distributors should have a parent beforehand */
            List<Commercial_Activity__c> allCommercialActivityChildBucketRecords = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivityBucket = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly, masterCommercialActivity);
            allCommercialActivityChildBucketRecords.add(promotionActivityBucket);

            insert allCommercialActivityChildBucketRecords;
            
            /* Create all records created by Distributors */
            List<Commercial_Activity__c> allRecordsByDistributors = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivity1 = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucket);
            promotionActivity1.Business_Segment__c='Adult Nutrition';
            allRecordsByDistributors.add(promotionActivity1);

            Commercial_Activity__c promotionActivity2 = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucket);
            promotionActivity2.Business_Segment__c='Adult Nutrition';
            allRecordsByDistributors.add(promotionActivity2);

            insert allRecordsByDistributors;
        }
    }

    @isTest
    static void shouldGetProperKPIInformation(){

        User usrItaly = [SELECT Id FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        
        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];
        CommunityKPISubmitController.CommunitySubmitWrapper promActWrapper;

        Test.startTest();
        System.runAs(usrItaly){
            promActWrapper = CommunityKPISubmitController.getKPIInformation(promotionActivityBucketItaly.Id);
        }
        Test.stopTest();

        System.assertEquals(true, promActWrapper.isPartner);
        System.assertEquals('Commercial Activity', promActWrapper.SObjectName);       
        System.assertEquals('Promotion Activities', promActWrapper.KPIType);        
        System.assertEquals(false, promActWrapper.disbleYesButton);
        System.assertEquals(null, promActWrapper.ConfirmedOrNot);
    }

    @isTest
    static void shouldSaveAndUpdateProperKPIInformation(){

        User usrItaly = [SELECT Id,ProfileId FROM User WHERE userName LIKE '%TestIMCDItaly%'];
        User FCIUser1 = [SELECT Id,Name FROM User WHERE userName LIKE '%FCIUser1%'];

        /* Create Custom Setting Data */
        Global_Automation_Setting__c globalSetting = new Global_Automation_Setting__c();
        globalSetting.Name = 'FCI Distributor User Setting';
        globalSetting.Skip_Apex_Trigger__c = false;
        globalSetting.Skip_Process_Builder__c = false;
        globalSetting.Skip_Validation_Rule__c = true;
        globalSetting.SetupOwnerId = usrItaly.ProfileId;
        insert globalSetting;

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id,Confirmed_by_FCI_Sales_Manager__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];
        String customerLocOwnerName;
        
        Test.startTest();
        System.runAs(usrItaly){
            customerLocOwnerName = CommunityKPISubmitController.handleSaveForSubmission(promotionActivityBucketItaly.Id);
        }
        Test.stopTest();

        System.assertEquals(FCIUser1.Name, customerLocOwnerName);
        System.assertEquals('Pending', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Confirmed_by_FCI_Sales_Manager__c);
        System.assertEquals(2, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =: KPIConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'Pending'].size());
    }
    
}