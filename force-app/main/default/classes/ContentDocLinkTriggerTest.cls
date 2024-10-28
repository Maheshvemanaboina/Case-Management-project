/**
 * Created by KJM on 16/08/2019.
 */

@isTest
public with sharing class ContentDocLinkTriggerTest {

@testSetup
static void setup() {


        Id notificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCust);
    
    	User apiUser = TestUtility.createUser(TestUtility.generateRandomUserName()+'APIUser@test.com', 'BGI Integration');
        INSERT apiUser;

        Account commercialCustDanone = TestUtility.createAccount('Danone SA'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCustDanone);
        insert accsCommercCustToInsert;

        List<Account> accsToInsert = new List<Account>(); //Customer locations list to be created
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust); //Customer location test record
        accsToInsert.add(customerLocItaly);

        Account customerLocDanoneBledina = TestUtility.createCustomerLocation('Danone Bledina', commercialCustDanone); //Customer location test record
        accsToInsert.add(customerLocDanoneBledina);
        
        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created

        Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly); //Contact test record
        cItaly.Additional_Country_Responsibility__c = null;
        contactsToInsert.add(cItaly);

        Contact cDanoneBledina = TestUtility.createContact('Danone','Bledina',commercialCustDanone, customerLocDanoneBledina); //Contact test record
        contactsToInsert.add(cDanoneBledina);
      
        insert contactsToInsert;

        List<ContentVersion> fileList = new List<ContentVersion>();
    	ContentVersion contentVersion1 = new ContentVersion(
                Title = 'Test1',
                PathOnClient = 'Test1.jpg',
                VersionData = Blob.valueOf('Test1 Content')
        );
        fileList.add(contentVersion1);
        ContentVersion contentVersion2 = new ContentVersion(
                Title = 'Test2',
                PathOnClient = 'Test2.pdf',
                VersionData = Blob.valueOf('Test2 Content')
        );
        fileList.add(contentVersion2);
    	
        insert fileList;

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
    
        List<Case> casesToInsert = new List<Case>();  //Cases list to be created
        Case csItaly = TestUtility.createCase('testCaseUpdateTestsSubjectItaly','testDescription', commercialCust, customerLocItaly); //Case test record
        casesToInsert.add(csItaly);

		Case notifcationRequest = TestUtility.createCase('TEST','TEST', commercialCustDanone, customerLocDanoneBledina); //Notification Case test record
        notifcationRequest.recordtypeid = notificationRecordTypeId;
        notifcationRequest.Type = 'Logistics';
        notifcationRequest.Delivery_Number__c ='0700000002' ;
        notifcationRequest.ContactId = cDanoneBledina.id;
        notifcationRequest.status = 'New';
        notifcationRequest.Priority = 'Regular';
        casesToInsert.add(notifcationRequest);      

        Test.startTest();

        insert casesToInsert;

        Test.stopTest();
        
 }

    @isTest
    static void shouldSetVisibilityToAllOnInsert() {

        Account acc = TestUtility.createAccount('testAcc123');
        insert acc;

        ContentVersion contentVersion = new ContentVersion(
                Title = 'Test',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        System.assertEquals('AllUsers', [SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :cdl.Id].Visibility);
    }
    @isTest
    static void setcontentVisiblityForCaseFilesOtherThenComplaintFiles(){
        
        List<Case> caseList = [SELECT id,RecordType.DeveloperName FROM Case WHERE RecordType.DeveloperName<> 'Danone_Complaint'];
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion];
        
               
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = caseList[0].id;
        cdl1.ContentDocumentId = contentVersionList[0].ContentDocumentId;
        cdlList.add(cdl1);
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = caseList[0].id;
        cdl2.ContentDocumentId = contentVersionList[1].ContentDocumentId;
        cdlList.add(cdl2);
        
        Test.startTest();
        INSERT cdlList;
    	system.assertEquals('AllUsers',[SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :cdlList[0].id].Visibility );
        system.assertEquals('AllUsers', [SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :cdlList[1].Id].Visibility);
        Test.stopTest();
        
    }
    
     @isTest
    static void setcontentVisiblityForComplaintFiles(){
        
        List<Case> caseList = [SELECT id,RecordType.DeveloperName FROM Case WHERE RecordType.DeveloperName = 'Danone_Complaint'];
        String getAPIUserId =  BGI_Salesforce_Settings__c.getOrgDefaults().API_User_ID__c;
        List<User> getAPIUser = [SELECT id FROM User WHERE id=:getAPIUserId];
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion];
        
        system.runAs(getAPIUser[0]){
            ContentDocumentLink cdl1 = New ContentDocumentLink();
            cdl1.LinkedEntityId = caseList[0].id;
            cdl1.ContentDocumentId = contentVersionList[0].ContentDocumentId;
            cdlList.add(cdl1);
            
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = caseList[0].id;
            cdl2.ContentDocumentId = contentVersionList[1].ContentDocumentId;
            cdlList.add(cdl2);
        
            INSERT cdlList;
            system.assertEquals('AllUsers',[SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :cdlList[0].Id].Visibility );
            system.assertEquals('AllUsers',[SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :cdlList[1].Id].Visibility );
            
            ContentVersion contentVersion3 = new ContentVersion(
                Title = 'IR',
                PathOnClient = 'IR.pdf',
                VersionData = Blob.valueOf('IR')
        	);
        	INSERT contentVersion3;		
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title='IR'];
            
         	ContentDocumentLink cdl3 = New ContentDocumentLink();
            cdl3.LinkedEntityId = caseList[0].id;
            cdl3.ContentDocumentId = documents[0].id;
            cdl3.Visibility = 'InternalUsers';
            INSERT cdl3;
            system.assertEquals('InternalUsers',[SELECT Id, Visibility FROM ContentDocumentLink WHERE Id = :cdl3.Id].Visibility );
        }
        
        
    }
}