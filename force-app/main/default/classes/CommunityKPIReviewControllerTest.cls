@isTest
public class CommunityKPIReviewControllerTest {
    
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

            Account endCustomerAcc = TestUtility.createEndCustomerAccount('Test Competitor');
            /* change end customer record type to competitor */
            endCustomerAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId();
            accsToInsert.add(endCustomerAcc);

            insert accsToInsert;

            /* Create Contacts under H5, these contacts will be Distributors */
            List<Contact> contactsToInsert = new List<Contact>();
            Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cItaly);

            insert contactsToInsert;

            List<User> usersToInsert = new List<User>();
            User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrItaly.ContactId = cItaly.Id;
            usrItaly.Business_Segment__c='Adult Nutrition';
            usersToInsert.add(usrItaly);

            insert usersToInsert;

            /* Create Master Commercial Activity Record to hold all bucket records */
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            insert masterCommercialActivity;

            Business_Strategy__c masterBusinessStrategy = CommunityKPITestUtility.createBusinessStrategyMaster(customerLocItaly);
            insert masterBusinessStrategy;

            /* Create all child bucket record for the above parent record. This is created in TestSetup because the records created by Distributors should have a parent beforehand */
            List<Commercial_Activity__c> allCommercialActivityChildBucketRecords = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivityBucket = CommunityKPITestUtility.createPromotionActivityBucket(customerLocItaly, masterCommercialActivity);
            promotionActivityBucket.Business_Segment__c='Adult Nutrition';
            allCommercialActivityChildBucketRecords.add(promotionActivityBucket);

            insert allCommercialActivityChildBucketRecords;

            List<Business_Strategy__c> allBusinessStrategyChildBucketRecords = new List<Business_Strategy__c>();

            Business_Strategy__c CompetitionBucket = CommunityKPITestUtility.createCompetitionBucket(customerLocItaly, masterBusinessStrategy);
            CompetitionBucket.Business_Segment__c='Adult Nutrition';
            allBusinessStrategyChildBucketRecords.add(CompetitionBucket);

            insert allBusinessStrategyChildBucketRecords;
            
            /* Create all records created by Distributors */
            List<Commercial_Activity__c> allRecordsByDistributors = new List<Commercial_Activity__c>();

            Commercial_Activity__c promotionActivity1 = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucket);
            promotionActivity1.Business_Segment__c='Adult Nutrition';
            allRecordsByDistributors.add(promotionActivity1);

            Commercial_Activity__c promotionActivity2 = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucket);
            promotionActivity2.Business_Segment__c='Adult Nutrition';
            allRecordsByDistributors.add(promotionActivity2);

            /* Create Competitions Records by Distributors */
            List<Business_Strategy__c> competitionRecordsByDistributors = new List<Business_Strategy__c>();

            Business_Strategy__c competition1 = CommunityKPITestUtility.createCompetitions(customerLocItaly, CompetitionBucket, endCustomerAcc);
            competition1.Business_Segment__c='Adult Nutrition';
            competitionRecordsByDistributors.add(competition1);

            Business_Strategy__c competition2 = CommunityKPITestUtility.createCompetitions(customerLocItaly, CompetitionBucket, endCustomerAcc);
            competition2.Business_Segment__c='Adult Nutrition';
            competitionRecordsByDistributors.add(competition2);

            insert allRecordsByDistributors;
            insert competitionRecordsByDistributors;
            
            Account_Team__c act = TestUtility.createAccountTeamMember_Custom(FCIUser1, customerLocItaly,'Sales Manager', 'Adult Nutrition');
            act.Primary__c = true;
            insert act;

        }
    }

    @isTest
    static void shouldreturnCorrectData(){

        User FCIUser = [SELECT Id,Name FROM User WHERE userName LIKE '%FCIUser1%'];
        
        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];

        CommunityKPIReviewController.CommunityKPIReviewTableWrapper KPITableWrapper;

        Test.startTest();
        System.runAs(FCIUser){
            KPITableWrapper = CommunityKPIReviewController.getTableData(promotionActivityBucketItaly.Id);
        }
        Test.stopTest();

        /*List<Map<String,String>> bodyVal = new List<Map<String,String>>();
        bodyVal.add(new Map<String,String>{'Promotion_Activity_Date__c' => String.valueOf(Date.today())});
        bodyVal.add(new Map<String,String>{'Promotion_Activity_Type__c' => 'Advertisement'});
        bodyVal.add(new Map<String,String>{'Comments__c' => 'Test'});*/

        System.assertEquals(KPITableWrapper.CommunityKPIType, 'Promotion Activities');
        System.assertEquals(KPITableWrapper.headerValues, 'Activity Name,Promotion Activity Date,Promotion Activity Type,Comments,Reason'.split(','));
        System.assertEquals(KPITableWrapper.listOfKeys, 'Name,Promotion_Activity_Date__c,Promotion_Activity_Type__c,Comments__c,Approval_Rejection_Reason__c'.split(','));
        System.assertEquals(KPITableWrapper.SMComments, null);
        //System.assertEquals(KPITableWrapper.bodyValue, bodyVal);
    }

    @isTest
    static void shouldUpdateRecordsAfterSMApprovalYes(){

        User FCIUser = [SELECT Id,Name FROM User WHERE userName LIKE '%FCIUser1%'];
        
        Map<Id,CommunityKPIReviewController.KpiUpdateWrapper> kpiWrapperMap = new Map<Id,CommunityKPIReviewController.KpiUpdateWrapper>();
        List<String> relatedRecordIds = new List<String>();
        for(Commercial_Activity__c eachComAct : [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID]){

            //relatedRecordIds.add(eachComAct.Id);
            CommunityKPIReviewController.KpiUpdateWrapper kpiWrapper = new CommunityKPIReviewController.KpiUpdateWrapper();
            kpiWrapper.kpiComments = 'Test - '+eachComAct.Id;
            kpiWrapper.kpiConfirmedBySM = true;
            kpiWrapperMap.put(eachComAct.Id, kpiWrapper);
        }

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];

        Test.startTest();
        System.runAs(FCIUser){
            //CommunityKPIReviewController.updateRecords(relatedRecordIds, promotionActivityBucketItaly.Id, 'Approved');
            CommunityKPIReviewController.updateRecords(promotionActivityBucketItaly.Id, kpiWrapperMap);
        }
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'Yes'].size());
        System.assertEquals('Yes', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Confirmed_by_FCI_Sales_Manager__c);
        //System.assertEquals('Approved', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Approval_Rejection_Reason__c);
        System.assertEquals(2, [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Id IN: kpiWrapperMap.keySet() AND Confirmed_by_FCI_Sales_Manager__c = 'Yes'].size());
    }
    
    @isTest
    static void shouldUpdateRecordsAfterSMApprovalYes2(){

        User FCIUser = [SELECT Id,Name FROM User WHERE userName LIKE '%FCIUser1%'];

        Map<Id,CommunityKPIReviewController.KpiUpdateWrapper> kpiWrapperMap = new Map<Id,CommunityKPIReviewController.KpiUpdateWrapper>();
		
        List<String> relatedRecordIds = new List<String>();
        for(Commercial_Activity__c eachComAct : [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID]){

            relatedRecordIds.add(eachComAct.Id);
            CommunityKPIReviewController.KpiUpdateWrapper kpiWrapper = new CommunityKPIReviewController.KpiUpdateWrapper();
            kpiWrapper.kpiComments = 'Test - '+eachComAct.Id;
            kpiWrapper.kpiConfirmedBySM = true;
            kpiWrapperMap.put(eachComAct.Id, kpiWrapper);
        }
        Commercial_Activity__c tempComAct = new Commercial_Activity__c(id=relatedRecordIds[0],Business_Segment__c='');
        update tempComAct;
        

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];

        Test.startTest();
        System.runAs(FCIUser){
            try{
                //CommunityKPIReviewController.updateRecords(relatedRecordIds, promotionActivityBucketItaly.Id, 'Approved');
                CommunityKPIReviewController.updateRecords(promotionActivityBucketItaly.Id, kpiWrapperMap);
            }catch(Exception excp){
                
            }
            
        }
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'Yes'].size());
        System.assertEquals(null, [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Confirmed_by_FCI_Sales_Manager__c);
        System.assertEquals(null, [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Approval_Rejection_Reason__c);
    }
    
    
    

    @isTest
    static void shouldUpdateRecordsAfterSMApprovalNo(){

        User FCIUser = [SELECT Id,Name FROM User WHERE userName LIKE '%FCIUser1%'];
        
        Account commercialCustomer = [SELECT Id, Name FROM Account WHERE Name = 'IMCD Holding' AND OwnerId =: FCIUser.Id];
        Account customerLocItaly = [SELECT Id, ParentId, Name FROM Account WHERE Name = 'IMCD Italy Spa'
                                    AND ParentId =: commercialCustomer.Id AND OwnerId =: FCIUser.Id];
        
        Map<Id,CommunityKPIReviewController.KpiUpdateWrapper> kpiWrapperMap = new Map<Id,CommunityKPIReviewController.KpiUpdateWrapper>();

        List<String> relatedRecordIds = new List<String>();
        for(Commercial_Activity__c eachComAct : [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID]){

            relatedRecordIds.add(eachComAct.Id);
            CommunityKPIReviewController.KpiUpdateWrapper kpiWrapper = new CommunityKPIReviewController.KpiUpdateWrapper();
            kpiWrapper.kpiComments = 'Test - '+eachComAct.Id;
            kpiWrapper.kpiConfirmedBySM = false;
            kpiWrapperMap.put(eachComAct.Id, kpiWrapper);
        }

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];

        Test.startTest();
        System.runAs(FCIUser){
            Commercial_Activity__c promotionActivity1 = CommunityKPITestUtility.createPromotionActivity(customerLocItaly, promotionActivityBucketItaly);
            promotionActivity1.Business_Segment__c='Adult Nutrition';
            insert promotionActivity1;
            //CommunityKPIReviewController.updateRecords(relatedRecordIds, promotionActivityBucketItaly.Id, 'Rejected');
            CommunityKPIReviewController.updateRecords(promotionActivityBucketItaly.Id, kpiWrapperMap);
        }
        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'No'].size());
        System.assertEquals('No', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Confirmed_by_FCI_Sales_Manager__c);
        //System.assertEquals('Rejected', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Approval_Rejection_Reason__c);
    }

    @isTest
    static void shouldUpdateRecordsAfterSMPartialApproval(){
        
        TriggerHandler.skipTrigger =  true;

        User FCIUser = [SELECT Id,Name FROM User WHERE userName LIKE '%FCIUser1%'];

        Map<Id,CommunityKPIReviewController.KpiUpdateWrapper> kpiWrapperMap = new Map<Id,CommunityKPIReviewController.KpiUpdateWrapper>();
        
        List<String> relatedRecordIds = new List<String>();
        Commercial_Activity__c firstComAct = [SELECT Id, Confirmed_by_FCI_Sales_Manager__c FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID][0];
        firstComAct.Confirmed_by_FCI_Sales_Manager__c = 'Yes';
        update firstComAct;

        Commercial_Activity__c secondComAct = [SELECT Id, Confirmed_by_FCI_Sales_Manager__c FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID][1];
        secondComAct.Confirmed_by_FCI_Sales_Manager__c = 'No';
        update secondComAct;
        /*relatedRecordIds.add(firstComAct.Id);
        relatedRecordIds.add(secondComAct.Id);*/
        
        CommunityKPIReviewController.KpiUpdateWrapper kpiWrapper1 = new CommunityKPIReviewController.KpiUpdateWrapper();
        kpiWrapper1.kpiComments = 'Rejected';
        kpiWrapper1.kpiConfirmedBySM = false;
        kpiWrapperMap.put(firstComAct.Id, kpiWrapper1);  
        
        CommunityKPIReviewController.KpiUpdateWrapper kpiWrapper2 = new CommunityKPIReviewController.KpiUpdateWrapper();
        kpiWrapper2.kpiComments = 'Approved';
        kpiWrapper2.kpiConfirmedBySM = true;
        kpiWrapperMap.put(secondComAct.Id, kpiWrapper2);      

        //Fetch all Bucket Data
        Commercial_Activity__c promotionActivityBucketItaly = [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'];
		
        TriggerHandler.skipTrigger =  false;
        
        Test.startTest();
        System.runAs(FCIUser){
            
            //CommunityKPIReviewController.updateRecords(relatedRecordIds, promotionActivityBucketItaly.Id, 'Not Apporved All');
            CommunityKPIReviewController.updateRecords(promotionActivityBucketItaly.Id, kpiWrapperMap);
        }
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'Yes'].size());
        System.assertEquals(1, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'No'].size());
        System.assertEquals('Yes', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Confirmed_by_FCI_Sales_Manager__c);
        //System.assertEquals('Not Apporved All', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Approval_Rejection_Reason__c);
    }

    @isTest
    static void shouldDisplayValuesUsingLookupOperator(){

        User FCIUser = [SELECT Id,Name FROM User WHERE userName LIKE '%FCIUser1%'];

        List<String> relatedRecordIds = new List<String>();
        for(Business_Strategy__c eachBizSegment : [SELECT Id FROM Business_Strategy__c WHERE RecordTypeId =:CommunityKPISharingConstants.COMPETITION_RECORD_TYPE_ID]){

            relatedRecordIds.add(eachBizSegment.Id);
        }

        //Fetch all Bucket Data
        Business_Strategy__c competitionBucket = [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Business_Strategy__c WHERE Name = 'Competitions Bucket'];

        Test.startTest();
        System.runAs(FCIUser){
            
            CommunityKPIReviewController.getTableData(competitionBucket.Id);
        }
        Test.stopTest();

        //System.assertEquals(1, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'Yes'].size());
        //System.assertEquals(1, [SELECT Id FROM Commercial_Activity__c WHERE RecordTypeId =:CommunityKPISharingConstants.PROMOTION_ACTIVITY_RECORD_TYPE_ID AND Confirmed_by_FCI_Sales_Manager__c = 'No'].size());
        //System.assertEquals('No', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Confirmed_by_FCI_Sales_Manager__c);
        //System.assertEquals('Not Apporved All', [SELECT Id,Confirmed_by_FCI_Sales_Manager__c,Approval_Rejection_Reason__c FROM Commercial_Activity__c WHERE Name = 'Promotion Activity Bucket'].Approval_Rejection_Reason__c);
    }
    
}