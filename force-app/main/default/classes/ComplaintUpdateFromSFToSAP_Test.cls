@isTest
global class ComplaintUpdateFromSFToSAP_Test {

     global Class MockHttpResponseGenratorForComplaintUpdate1 implements HttpCalloutMock{

        global HttpResponse respond(HttpRequest request){

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Response": {"APIRuntimeResponse": "Success","APIRuntimeResponseDesc": "Success","Notification": {"NotificationNumber": "000200011260","NotificationErrorIndicator": "S","Tasks": [{"TaskNumber": ""}],"Errors": [{"ErrorMessage": ""}]}}}');
            response.setStatusCode(200);
            return response;
        }
    }
    global Class MockHttpResponseGenratorForComplaintUpdate2 implements HttpCalloutMock{

        global HttpResponse respond(HttpRequest request){

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(500);
            return response;
        }
    }
    
    @testSetup
    Private static void setup() {
    
        
        Id notificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        
        User apiUser = TestUtility.createUser(TestUtility.generateRandomUserName()+'APIUser@test.com', 'BGI Integration');
        INSERT apiUser;
        
        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('H1 Customer User'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCust);

        INSERT accsCommercCustToInsert;

        List<Account> accsToInsert = new List<Account>(); //Customer locations list to be created
        Account customerLocItaly = TestUtility.createCustomerLocation('H5 Test Customer Italy', commercialCust); //Customer location test record
        accsToInsert.add(customerLocItaly);

        Account customerLocFrance = TestUtility.createCustomerLocation('H5 Test Customer France', commercialCust); //Customer location test record
        accsToInsert.add(customerLocFrance);
        
        INSERT accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created

        Contact cItaly = TestUtility.createContact('Test Customer', 'Italy',commercialCust, customerLocItaly); //Contact test record
        contactsToInsert.add(cItaly);

        Contact cFrance = TestUtility.createContact('Test Customer', 'France',commercialCust, customerLocFrance); //Contact test record
        contactsToInsert.add(cFrance);
        INSERT contactsToInsert;
        
        List<Case> caseListToInsert = new List<Case>();
        Case notificationCase1 = TestUtility.createCase('CaseSubject3', 'Descrip3', commercialCust, customerLocItaly);
        notificationCase1.recordtypeid = notificationRecordTypeId;
        notificationCase1.Type = 'Logistics';
        notificationCase1.Sub_Type__c = 'CMR';
        notificationCase1.Delivery_Number__c ='0700000008' ;
        notificationCase1.ContactId =cItaly.id;
        notificationCase1.status = 'New';
        notificationCase1.Priority = 'Regular';
        notificationCase1.SAP_Case_Number__c = '2000000001';
        notificationCase1.SAP_Case_Status__c = 'All Tasks Completed';
        notificationCase1.Case_Closer_Reason__c = 'Initial';
        notificationCase1.Notification_Origin__c = 'Internal Origin';
        caseListToInsert.add(notificationCase1);
        
        Case notificationCase2 = TestUtility.createCase('CaseSubject3', 'Descrip3', commercialCust, customerLocFrance);
        notificationCase2.recordtypeid = notificationRecordTypeId;
        notificationCase2.Type = 'Logistics';
        notificationCase2.Sub_Type__c = 'CMR';
        notificationCase2.Delivery_Number__c ='0700000009' ;
        notificationCase2.ContactId =cFrance.id;
        notificationCase2.status = 'New';
        notificationCase2.Priority = 'Regular';
        notificationCase2.SAP_Case_Number__c = '2000000002';
        notificationCase2.Department_Responsible__c = '50000002';
        notificationCase2.Case_Closer_Reason__c = 'Initial';
        notificationCase2.Notification_Origin__c = 'Internal Origin';
       // notificationCase2.SAP_Case_Status__c = 'Notification Completed';
        caseListToInsert.add(notificationCase2);
        
        Case notificationCase3 = TestUtility.createCase('CaseSubject3', 'Descrip3', commercialCust, customerLocFrance);
        notificationCase3.recordtypeid = notificationRecordTypeId;
        notificationCase3.Type = 'Logistics';
        notificationCase3.Sub_Type__c = 'CMR';
        notificationCase3.Delivery_Number__c ='0700000010' ;
        notificationCase3.ContactId =cFrance.id;
        notificationCase3.status = 'New';
        notificationCase3.Priority = 'Regular';
        notificationCase3.SAP_Case_Number__c = '2000000003';
        notificationCase3.Case_Closer_Reason__c = 'Initial';
        notificationCase3.Notification_Origin__c = 'Internal Origin';
        caseListToInsert.add(notificationCase3);
        
        INSERT caseListToInsert;
       
        PriceBook2 pricebook = new PriceBook2(
            Name = 'Prototype',
            IsActive = true
        );
        INSERT pricebook;
        INSERT new BGI_Salesforce_Settings__c(
            No_Of_Opportunities_Per_Batch__c = 10,
            Default_Task_Owner__c            = UserInfo.getUserId().subString(0, 15),
            Financial_Year__c                = Date.newInstance( Date.today().year(), 12, 31 ),
            Batch_Status_Email_Recipients__c = 'xyz@test.com,abc@test.com',
            Batch_Job_Failue_Message__c      = 'test123',
            Batch_Job_Success_Message__c     = 'Failure',
            Email_Subject__c                 = 'subject',
            Sender_Display_Name__c           = 'displayname',
            Prototype_Price_Book_Id__c       = pricebook.Id,
            API_User_ID__c = apiUser.id
        );
    }
    
   @istest
    private static void testComplaintUpdate(){
        
        List<Case> notofcationCaseList = [SELECT  id,Type,Sub_Type__c,Priority,Subject,Ownerid,Complaint_Quantity__c,SAP_Case_Number__c,
                     					  Case_Closer_Reason__c,Description,LastModifiedByid FROM Case];
        id currentUserId = Userinfo.getUserId();
        User systemAdminOtherThenCurrentUser = [SELECT id FROM User WHERE id<>:currentUserId AND Profile.Name ='System Administrator' LIMIT 1];
        String getAPIUserId =  BGI_Salesforce_Settings__c.getOrgDefaults().API_User_ID__c;
        User getAPIUser = [SELECT id FROM User WHERE id=:getAPIUserId];
        
        notofcationCaseList[0].Type = 'Sales';
        notofcationCaseList[0].Sub_Type__c = 'Invoice';
        notofcationCaseList[0].Priority = 'High';
        notofcationCaseList[0].Comments__c = 'TEST';
        notofcationCaseList[0].Subject = 'Test';
        notofcationCaseList[0].Complaint_Quantity__c = 500;
        notofcationCaseList[0].Status = 'Closed';
        notofcationCaseList[0].SAP_Case_Number__c = '2000000001';
        notofcationCaseList[0].SAP_Case_Status__c = 'All Tasks Completed';
        notofcationCaseList[0].Case_Closer_Reason__c = 'Initial';
        notofcationCaseList[0].Notification_Origin__c = 'Internal Origin';
        UPDATE notofcationCaseList[0];
        
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate1() );
        
       System.runAs(getAPIUser){
            notofcationCaseList[2].SAP_Case_Number__c = '2000000003';       
            notofcationCaseList[2].Type = 'Sales';
            notofcationCaseList[2].Sub_Type__c = 'Invoice';
            notofcationCaseList[2].Priority = 'High';
            notofcationCaseList[2].Comments__c = 'TEST';
            notofcationCaseList[2].Subject = 'Test';
            notofcationCaseList[2].Complaint_Quantity__c = 500;
            notofcationCaseList[2].Department_Responsible__c = '50000005';
            
            Test.startTest();
             UPDATE notofcationCaseList[2];
             Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate1() );
            Test.stopTest();
        }
        
    }
    @istest
    private static void testComplaintUpdateIfFlowIsInactive(){  
        
        List<Case> notofcationCaseList = [SELECT  id,Type,Sub_Type__c,Priority,Subject,Ownerid,Complaint_Quantity__c,SAP_Case_Number__c,
                     					  Case_Closer_Reason__c,Description,LastModifiedByid FROM Case];
        String getAPIUserId =  BGI_Salesforce_Settings__c.getOrgDefaults().API_User_ID__c;
        User getAPIUser = [SELECT id FROM User WHERE id=:getAPIUserId];
         
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate2() );
        ComplaintUpdateFromSFToSAP.fetchComplaintDetails(new List<Case>{notofcationCaseList.get(0)});
        
        System.runAs(getAPIUser){
            Test.startTest();
             Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate1() );
             ComplaintUpdateFromSFToSAP.fetchComplaintDetails(new List<Case>{notofcationCaseList.get(1),notofcationCaseList.get(2)});
            Test.stopTest();
        }
        
    }
}