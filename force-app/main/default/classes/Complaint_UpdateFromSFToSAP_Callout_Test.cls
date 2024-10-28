@isTest
global class Complaint_UpdateFromSFToSAP_Callout_Test {
    
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
            response.setBody('{"Response": {"APIRuntimeResponse": "Success","APIRuntimeResponseDesc": "Success","Notification": {"NotificationNumber": "000200011261","NotificationErrorIndicator": "S","Tasks": [{"TaskNumber": "TEST1234"}],"Errors": [{"ErrorMessage": ""}]}}}');
            response.setStatusCode(200);
            return response;
        }
    }
    
    global Class MockHttpResponseGenratorForComplaintUpdate3 implements HttpCalloutMock{
        
        global HttpResponse respond(HttpRequest request){
            
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(500);
            return response;
        }
    }
    
    @testSetup
    private static void setup(){
        
        Test.startTest();
        Id notificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
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
        
        List<ContentVersion> insertCaseContentversion = new List<ContentVersion>();
        ContentVersion content1 = new ContentVersion();
        content1.ContentLocation = 'S';                  
        content1.PathOnClient = 'testing1.pdf';          
        content1.Title = 'testing1';      
        content1.VersionData = EncodingUtil.base64Decode('Attachment1');
        insertCaseContentversion.add(content1);
        
        ContentVersion content2 = new ContentVersion();
        content2.ContentLocation = 'S';                  
        content2.PathOnClient = 'testing2.png';          
        content2.Title = 'testing2';      
        content2.VersionData = EncodingUtil.base64Decode('Attachment2');
        insertCaseContentversion.add(content2);
        
        ContentVersion content3 = new ContentVersion();
        content3.ContentLocation = 'S';                  
        content3.PathOnClient = 'testing3.png';          
        content3.Title = 'testing3';      
        content3.VersionData = EncodingUtil.base64Decode('Attachment3');
        insertCaseContentversion.add(content3);
        
        ContentVersion content4 = new ContentVersion();
        content4.ContentLocation = 'S';                  
        content4.PathOnClient = 'testing4.png';          
        content4.Title = 'testing4';      
        content4.VersionData = EncodingUtil.base64Decode('Attachment4');
        insertCaseContentversion.add(content4);
        
        ContentVersion content5 = new ContentVersion();
        content5.ContentLocation = 'S';                  
        content5.PathOnClient = 'testing5.png';          
        content5.Title = 'testing5';      
        content5.VersionData = EncodingUtil.base64Decode('Attachment5');
        insertCaseContentversion.add(content5);
        INSERT insertCaseContentversion;     
        
        List<ContentVersion> updateContentVersion = new List<ContentVersion>();
        content4.Send_To_SAP__c = true;
        updateContentVersion.add(content4);
        content5.Send_To_SAP__c = true;
        updateContentVersion.add(content5);
        
        UPDATE updateContentVersion;
        
        List<Case> caseListToInsert = new List<Case>();
        
        Case notificationCase1 = TestUtility.createCase('CaseSubject3', 'Descrip3', commercialCust, customerLocItaly);
        notificationCase1.recordtypeid = notificationRecordTypeId;
        notificationCase1.Type = 'Logistics';
        notificationCase1.Sub_Type__c = 'CMR';
        notificationCase1.Delivery_Number__c ='0700000008' ;
        notificationCase1.ContactId =cItaly.id;
        notificationCase1.status = 'New';
        notificationCase1.Priority = 'Regular';
        caseListToInsert.add(notificationCase1);
        
        INSERT caseListToInsert;
        notificationCase1.SAP_Case_Number__c = '2000000001';
        UPDATE notificationCase1;
        
        List<Task> taskListToInsert = new List<Task>();
        Task task1 = new Task();
        task1.WhatId = caseListToInsert[0].id;
        task1.ActivityDate = system.today();
        task1.Status = 'In Progress';
        task1.Priority = 'Normal';
        task1.Description = 'TEST';
        task1.SAP_Task_Number__c = 'TEST1000';
        task1.Type = 'Evaluate/judge Investigation Results';
        taskListToInsert.add(task1);
        
        Task task2 = new Task();
        task2.WhatId = caseListToInsert[0].id;
        task2.ActivityDate = system.today();
        task2.Status = 'In Progress';
        task2.Priority = 'Normal';
        task2.Description = 'TEST';
        task2.Type = 'Additional Information from Customer';
        taskListToInsert.add(task2);
        
        INSERT taskListToInsert;
        
        List<ContentVersion> insertCaseContentversion1 = new List<ContentVersion>();
        ContentVersion content11 = new ContentVersion();
        content11.ContentLocation = 'S';                  
        content11.PathOnClient = 'testing11.pdf';          
        content11.Title = 'testing1';      
        content11.VersionData = EncodingUtil.base64Decode('Attachment1');
        insertCaseContentversion1.add(content11);
        
        ContentVersion content12 = new ContentVersion();
        content12.ContentLocation = 'S';                  
        content12.PathOnClient = 'testing12.pdf';          
        content12.Title = 'testing2';      
        content12.VersionData = EncodingUtil.base64Decode('Attachment2');
        insertCaseContentversion1.add(content12);
        
        INSERT insertCaseContentversion1;
        
        List<ContentDocumentLink> insetContentLink = new List<ContentDocumentLink>();
        for(ContentVersion contentId : [SELECT ContentDocumentId FROM ContentVersion WHERE id IN:insertCaseContentversion1]){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = caseListToInsert[0].id;
            cdl.ContentDocumentId = contentId.ContentDocumentId;
            insetContentLink.add(cdl);
        }
        INSERT insetContentLink;
        Test.stopTest();
        
    }
    
    @isTest
    private static void testComplaintUpdate(){
        List<Case> caseList = [SELECT Subject,Description,SAP_Case_Number__c FROM Case LIMIT 1];
        ComplaintUpdateFromSFToSAP.UpdatedComplaintFieldValues updateFieldValues = new ComplaintUpdateFromSFToSAP.UpdatedComplaintFieldValues();
        Complaint_UpdateFromSFToSAP_Callout.SFResponse sFResponseInstance = new Complaint_UpdateFromSFToSAP_Callout.SFResponse();
        updateFieldValues.complaintRecordTypeInSAP = 'ZA';
        updateFieldValues.complaintNotifcationNumber = caseList[0].SAP_Case_Number__c;
        updateFieldValues.complaintSubject = caseList[0].Subject;
        updateFieldValues.complaintDescription = caseList[0].Description;
        
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate1());
        sFResponseInstance = Complaint_UpdateFromSFToSAP_Callout.updateComplaintToSAP(updateFieldValues);
        system.assertEquals(true,sFResponseInstance.isSuccess);
        
        Test.startTest();
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate3());
        sFResponseInstance = Complaint_UpdateFromSFToSAP_Callout.updateComplaintToSAP(updateFieldValues);
        system.assertEquals(false, sFResponseInstance.isSuccess);
        Test.stopTest();
        
    }
    @isTest
    private static void syncTaskToSAPWhichIsCreatedInSF(){
        List<Case> caseList = [SELECT Subject,Description,SAP_Case_Number__c FROM Case LIMIT 1];
        List<Task> taskList = [SELECT WhatId,Status,Priority,Description,SAP_Task_Number__c,Type,Subject FROM Task WHERE SAP_Task_Number__c = null];
        Set<Id> contentIdList = new Set<Id>();
       Complaint_UpdateFromSFToSAP_Callout.SFResponse sfResponse1;
        
        for(ContentVersion cv :[SELECT ContentDocumentId FROM ContentVersion]){
            contentIdList.add(cv.ContentDocumentId);
        }
        
        Test.startTest();
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate1());
        sfResponse1 = Complaint_UpdateFromSFToSAP_Callout.syncComplaintTaskToSAP(taskList[0],contentIdList,true);
        system.assertEquals(true, sfResponse1.isSuccess);
        Test.stopTest();
        
    }
    @isTest
    private static void syncTaskToSAPWhichIsCreatedBySAP(){
        List<Case> caseList = [SELECT Subject,Description,SAP_Case_Number__c FROM Case LIMIT 1];
        List<Task> taskList = [SELECT WhatId,Status,Priority,Description,SAP_Task_Number__c,Type,Subject FROM Task WHERE SAP_Task_Number__c <> null];
        Complaint_UpdateFromSFToSAP_Callout.SFResponse sfResponse1;
        
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate2());
        sfResponse1 = Complaint_UpdateFromSFToSAP_Callout.syncComplaintTaskToSAP(taskList[0],new Set<id>(),true);
        system.assertEquals(true, sfResponse1.isSuccess);
        
        Test.startTest();
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate3());
        sfResponse1 = Complaint_UpdateFromSFToSAP_Callout.syncComplaintTaskToSAP(taskList[0],new Set<id>(),true);
        system.assertEquals(false, sfResponse1.isSuccess);
        Test.stopTest();
    }
    
}