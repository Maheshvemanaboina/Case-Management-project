@isTest
global class ComplaintUpdateFromSFToSAPControllerTest {
    
   
    global Class MockHttpResponseGenratorForComplaintUpdate1 implements HttpCalloutMock{

        global HttpResponse respond(HttpRequest request){

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Response": {"APIRuntimeResponse": "Success","APIRuntimeResponseDesc": "Success","Notification": {"NotificationNumber": "000200011262","NotificationErrorIndicator": "S","Tasks": [{"TaskNumber": "TEST1234"}],"Errors": [{"ErrorMessage": ""}]}}}');
            response.setStatusCode(200);
            return response;
        }
    }
     global Class MockHttpResponseGenratorForComplaintUpdate2 implements HttpCalloutMock{

        global HttpResponse respond(HttpRequest request){

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(' {"Response": {"APIRuntimeResponse": "Success","APIRuntimeResponseDesc": "Success","Notification": {"NotificationNumber": "000200011262","NotificationErrorIndicator": "S","Tasks": [{"TaskNumber": ""}],"Errors": [{"ErrorMessage": ""}]}}}');
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
        
        Id notificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('H1 Customer User'); //Commercial customer test record
        User apiUser = TestUtility.createUser(TestUtility.generateRandomUserName()+'APIUser@test.com', 'BGI Integration');
        INSERT apiUser;
        
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
        
        //Update required becasue of the validation present on Update Interface(NOT_PRESENT_IN_SAP)
        notificationCase1.SAP_Case_Number__c = 'TESTSAPNO1';
        UPDATE notificationCase1;
        
        system.runAs(apiUser){
            Test.startTest();
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
    @isTest
    private static void getContentListTest(){
        
        Id complaintTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('FCI_Complaints').getRecordTypeId();
        ComplaintUpdateFromSFToSAPController.ContentAndLinkedObjectDetails contentObjectDetails = new ComplaintUpdateFromSFToSAPController.ContentAndLinkedObjectDetails();
        List<ContentVersion> contentList = [SELECT ContentDocumentId FROM ContentVersion LIMIT 5];
        List<Case> caseList = [SELECT id FROM Case LIMIT 1];
        
        List<ContentDocumentLink> contentLinkList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl1Notification1 = new ContentDocumentLink();
        cdl1Notification1.LinkedEntityId = caseList[0].id;
        cdl1Notification1.ContentDocumentId = contentList[0].ContentDocumentId;
        contentLinkList.add(cdl1Notification1);
        
        ContentDocumentLink cdl2Notification1 = new ContentDocumentLink();
        cdl2Notification1.LinkedEntityId = caseList[0].id;
        cdl2Notification1.ContentDocumentId = contentList[1].ContentDocumentId;
        contentLinkList.add(cdl2Notification1);
        
        ContentDocumentLink cdl3Notification1 = new ContentDocumentLink();
        cdl3Notification1.LinkedEntityId = caseList[0].id;
        cdl3Notification1.ContentDocumentId = contentList[2].ContentDocumentId;
        contentLinkList.add(cdl3Notification1);
        
        ContentDocumentLink cdl4Notification1 = new ContentDocumentLink();
        cdl4Notification1.LinkedEntityId = caseList[0].id;
        cdl4Notification1.ContentDocumentId = contentList[3].ContentDocumentId;
        contentLinkList.add(cdl4Notification1);
        
        ContentDocumentLink cdl5Notification1 = new ContentDocumentLink();
        cdl5Notification1.LinkedEntityId = caseList[0].id;
        cdl5Notification1.ContentDocumentId = contentList[4].ContentDocumentId;
        contentLinkList.add(cdl5Notification1);
        INSERT contentLinkList;
        
        Task task1 = new Task();
        task1.WhatId = caseList[0].id;
        task1.ActivityDate = system.today();
        task1.Status = 'In Progress';
        task1.Priority = 'Normal';
        task1.Type = 'Test';
        INSERT task1;
        
        String taskType = ComplaintUpdateFromSFToSAPController.getTaskType(task1.id);
        system.assertEquals(task1.Type, taskType);
        
        contentObjectDetails = ComplaintUpdateFromSFToSAPController.getRelatedContentVesrion(task1.id);
        system.assertEquals('Case',contentObjectDetails.objectLabel);
        system.assertEquals(3,contentObjectDetails.contentNotSendedToSAPList.size());
        system.assertEquals(2, contentObjectDetails.contentSendedToSAPList.size());
    }
    @IsTest
    private static void testContentSizeSetToNearestUnit(){
        
        String contentSizeWithUnitKB = ComplaintUpdateFromSFToSAPController.convertContentSizeToItsNearestUnit(1500);
        System.assertEquals('1.5KB', contentSizeWithUnitKB);
        String contentSizeWithUnitMB = ComplaintUpdateFromSFToSAPController.convertContentSizeToItsNearestUnit(1500000);
        System.assertEquals('1.4MB', contentSizeWithUnitMB);
        String contentSizeWithUnitGB = ComplaintUpdateFromSFToSAPController.convertContentSizeToItsNearestUnit(1500000000);
        System.assertEquals('1.4GB', contentSizeWithUnitGB);
        String contentSizeWithUnitDash = ComplaintUpdateFromSFToSAPController.convertContentSizeToItsNearestUnit(0);
        System.assertEquals('-', contentSizeWithUnitDash);
    }
    @isTest
    private static void addCaseRelatedFileToTask(){
        
        Id complaintTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('FCI_Complaints').getRecordTypeId();
        List<id> contentDocumentIdList = new List<id>();
        ComplaintUpdateFromSFToSAPController.FileStatus fileLinkingStatus = new ComplaintUpdateFromSFToSAPController.FileStatus();
        List<ComplaintUpdateFromSFToSAPController.ContentDetails> taskContentList = new List<ComplaintUpdateFromSFToSAPController.ContentDetails>();
        List<ContentVersion> contentList = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocument.LatestPublishedVersion.Createdby.Name <> 'API User' LIMIT 5];
        List<Case> caseList = [SELECT id FROM Case LIMIT 1];   
        List<Task> taskList = new List<Task>();
        
        Task task1 = new Task();
        task1.WhatId = caseList[0].id;
        task1.ActivityDate = system.today();
        task1.Type = 'Additional Information from Customer';
        task1.Status = 'In Progress';
        task1.Priority = 'Normal';
        taskList.add(task1);
        
        Task task2 = new Task();
        task2.WhatId = caseList[0].id;
        task2.ActivityDate = system.today();
        task2.Type = 'Additional Information from Customer';
        task2.Status = 'In Progress';
        task2.Priority = 'Normal';
        taskList.add(task2);
        INSERT taskList;
        
        fileLinkingStatus = ComplaintUpdateFromSFToSAPController.attachExistingContentToTask(task1.id, contentDocumentIdList);
        system.assertEquals('No File Selected', fileLinkingStatus.errorOrMessage );
        
        ContentDocumentLink cdl1Notification1 = new ContentDocumentLink();
        cdl1Notification1.LinkedEntityId = task1.id;
        cdl1Notification1.ContentDocumentId = contentList[0].ContentDocumentId;
        INSERT cdl1Notification1;
        
        contentDocumentIdList.add(contentList[0].ContentDocumentId);
        contentDocumentIdList.add(contentList[1].ContentDocumentId);
        fileLinkingStatus = ComplaintUpdateFromSFToSAPController.attachExistingContentToTask(task1.id, contentDocumentIdList);
        system.assertEquals(true, fileLinkingStatus.errorOrMessage.contains('Files Added To the Task') );
        
        contentDocumentIdList.clear();
        contentDocumentIdList.add(contentList[2].ContentDocumentId);
        contentDocumentIdList.add(contentList[3].ContentDocumentId);
        contentDocumentIdList.add(contentList[4].ContentDocumentId);
        fileLinkingStatus = ComplaintUpdateFromSFToSAPController.attachExistingContentToTask(task1.id, contentDocumentIdList);
        system.assertEquals(true, fileLinkingStatus.errorOrMessage.contains('Files Added To the Task') );
        
        contentDocumentIdList.add(contentList[0].ContentDocumentId);
        contentDocumentIdList.add(contentList[1].ContentDocumentId);
        fileLinkingStatus = ComplaintUpdateFromSFToSAPController.attachExistingContentToTask(task1.id, contentDocumentIdList);
        system.assertEquals('All Selected Files Are Already Attached To The Task', fileLinkingStatus.errorOrMessage);
        
        taskContentList = ComplaintUpdateFromSFToSAPController.fetchTaskRelatedFiles(task1.id);
        system.assertEquals(5, taskContentList.size());
        taskContentList = ComplaintUpdateFromSFToSAPController.fetchTaskRelatedFiles(task2.id);
        system.assertEquals(0, taskContentList.size());
        ComplaintUpdateFromSFToSAPController.unlinkSpecifiedContentFromTask(null,null);
        String unlinktask1 = ComplaintUpdateFromSFToSAPController.unlinkSpecifiedContentFromTask(task1.id,contentList[2].ContentDocumentId);
        system.assertEquals('SUCCESS', unlinktask1);
        String unlinktask2 = ComplaintUpdateFromSFToSAPController.unlinkSpecifiedContentFromTask(task2.id,contentList[2].ContentDocumentId);
        system.assertEquals('SUCCESS', unlinktask2);
    }
    
    @isTest
    private static void testInvestigationReportSharing(){
        Id complaintTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('FCI_Complaints').getRecordTypeId();
        List<User> getAPIUserId = [SELECT id FROM User WHERE Profile.Name='BGI Integration' AND Name='API User' LIMIT 1];
        List<Case> caseList = [SELECT id,SAP_Case_Number__C FROM Case LIMIT 1];
        List<Task> taskList = new List<Task>();
        List<ContentDocumentLink> insertContentLink = new List<ContentDocumentLink>();
        List<ContentVersion> insertContentForAPIUser = new List<ContentVersion>();
        Complaint_UpdateFromSFToSAP_Callout.SFResponse sFResponseInstance = new Complaint_UpdateFromSFToSAP_Callout.SFResponse();
        
        System.runAs(getAPIUserId[0]){
       
        ContentVersion contentforAPI1 = new ContentVersion();
        contentforAPI1.ContentLocation = 'S';                  
        contentforAPI1.PathOnClient = 'IR_API_User1.pdf';          
        contentforAPI1.Title = 'IR_API_User1';      
        contentforAPI1.VersionData = EncodingUtil.base64Decode('IR1xyz');
        insertContentForAPIUser.add(contentforAPI1);
        
        ContentVersion contentforAPI2 = new ContentVersion();
        contentforAPI2.ContentLocation = 'S';                  
        contentforAPI2.PathOnClient = 'IR_API_User2.pdf';          
        contentforAPI2.Title = 'IR_API_User2';      
        contentforAPI2.VersionData = EncodingUtil.base64Decode('IR2xyz');
        insertContentForAPIUser.add(contentforAPI2);
        
        ContentVersion contentforAPI3 = new ContentVersion();
        contentforAPI3.ContentLocation = 'S';                  
        contentforAPI3.PathOnClient = 'IR_API_User3.png';          
        contentforAPI3.Title = 'IR_API_User3';      
        contentforAPI3.VersionData = EncodingUtil.base64Decode('IR3xyz');
        insertContentForAPIUser.add(contentforAPI3);
       
         INSERT insertContentForAPIUser;   
        }  
        
        List<ContentVersion>  contentList = [SELECT ContentDocumentId,Title FROM ContentVersion WHERE id IN:insertContentForAPIUser];
        
        Task task1 = new Task();
        task1.WhatId = caseList[0].id;
        task1.ActivityDate = system.today();
        task1.Status = 'In Progress';
        task1.Priority = 'Normal';
        task1.Description = 'TEST';
        task1.Type = 'Evaluate/judge Investigation Results';
        INSERT task1;
        
        ContentDocumentLink cdl1Notification1 = new ContentDocumentLink();
        cdl1Notification1.LinkedEntityId = caseList[0].id;
        cdl1Notification1.ContentDocumentId = contentList[0].ContentDocumentId;
        insertContentLink.add(cdl1Notification1);
        
        ContentDocumentLink cdl1Notification2 = new ContentDocumentLink();
        cdl1Notification2.LinkedEntityId = caseList[0].id;
        cdl1Notification2.ContentDocumentId = contentList[1].ContentDocumentId;
        insertContentLink.add(cdl1Notification2);
        
        ContentDocumentLink cdl1Notification3 = new ContentDocumentLink();
        cdl1Notification3.LinkedEntityId = caseList[0].id;
        cdl1Notification3.ContentDocumentId = contentList[2].ContentDocumentId;
        insertContentLink.add(cdl1Notification3);
        
        //To cover exception part
        ComplaintUpdateFromSFToSAPController.createAttachedFilePublicURL(caseList[0].id,null,task1.Type);
        INSERT insertContentLink;
        Test.startTest();
            Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate1() );
            sFResponseInstance = ComplaintUpdateFromSFToSAPController.synchTaskDetailsToSAP(task1.id,'TEST1',task1.Type,'Accept');
        	system.assertEquals(true, sFResponseInstance.isSuccess);
        Test.stopTest();
    }
    @isTest
    private static void testSynchTaskDetailsToSAP(){
        Id complaintTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('FCI_Complaints').getRecordTypeId();
        List<ContentVersion> contentList = [SELECT ContentDocumentId,title FROM ContentVersion LIMIT 1];
        List<Case> caseList = [SELECT id FROM Case LIMIT 1];
        List<Task> taskList = new List<Task>();
        Complaint_UpdateFromSFToSAP_Callout.SFResponse sFResponseInstance = new Complaint_UpdateFromSFToSAP_Callout.SFResponse();
        
        Task task1 = new Task();
        task1.WhatId = caseList[0].id;
        task1.ActivityDate = system.today();
        task1.Status = 'In Progress';
        task1.Priority = 'Normal';
        task1.Description = 'TEST';
        task1.Type = 'Ask for Additional Information';
        taskList.add(task1);
        
        Task task2 = new Task();
        task2.WhatId = caseList[0].id;
        task2.ActivityDate = system.today();
        task2.Status = 'In Progress';
        task2.Priority = 'Normal';
        task2.Description = 'TEST';
        task2.Type = 'Additional Information from Customer';
        taskList.add(task2);
        
        INSERT taskList;

        sFResponseInstance = ComplaintUpdateFromSFToSAPController.synchTaskDetailsToSAP(caseList[0].id, 'TEST', task1.Type, null);
        
        ContentDocumentLink cdl1Notification1 = new ContentDocumentLink();
        cdl1Notification1.LinkedEntityId = task1.id;
        cdl1Notification1.ContentDocumentId = contentList[0].ContentDocumentId;
        INSERT cdl1Notification1;
        //Create CSV file for complaint update from SF to SAP, which contains list of Public URL of selected files
        ComplaintUpdateFromSFToSAPController.createAttachedFilePublicURL(caseList[0].id,task1.id,task1.Type);
        
        Test.startTest();
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate2() );
        sFResponseInstance = ComplaintUpdateFromSFToSAPController.synchTaskDetailsToSAP(task1.id, 'TEST', task1.Type, null);
        system.assertEquals(true, sFResponseInstance.isSuccess);
        
        Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaintUpdate3() );
        sFResponseInstance = ComplaintUpdateFromSFToSAPController.synchTaskDetailsToSAP(task1.id, 'TEST', task1.Type, null);
        system.assertEquals(false, sFResponseInstance.isSuccess);        
        Test.stopTest();
        
        
    }
}