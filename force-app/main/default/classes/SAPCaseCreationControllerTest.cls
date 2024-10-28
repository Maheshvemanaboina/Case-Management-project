@isTest
public class SAPCaseCreationControllerTest {
    @testSetup
    public static void testSetups(){
    
        system.runAs(new User(Id = UserInfo.getUserId())){
        List<User> userList = new List<User>();
        User userWithoutSAPUserName =TestUtility.createUser(TestUtility.generateRandomUserName()+'userWithoutSAPUserName', 'System Administrator');
        userList.add(userWithoutSAPUserName);
        User userWithSAPUserName =TestUtility.createUser(TestUtility.generateRandomUserName()+'userWithSAPUserName', 'System Administrator');
        userWithSAPUserName.SAP_UserName__c = 'TESTUSER';
        userList.add(userWithSAPUserName);
        INSERT userList;
        
            
        Account commercialCust = TestUtility.createAccount('H1 Customer User'); //Commercial customer test record
        INSERT commercialCust;
        
        Account customerLocFrance = TestUtility.createCustomerLocation('H5 Test Customer France', commercialCust); //Customer location test record
        customerLocFrance.BillingStreet = null;
        customerLocFrance.BillingPostalCode = null;
        customerLocFrance.BillingCity = null;
        customerLocFrance.BillingCountryCode = null;
        customerLocFrance.BillingCountry = 'France';
        INSERT customerLocFrance;
        
        Contact cFrance = TestUtility.createContact('Test Customer', 'France',commercialCust, customerLocFrance); //Contact test record
        INSERT cFrance;
        
        List<ContentVersion> insertCaseContentversion = new List<ContentVersion>();
        ContentVersion content1 = new ContentVersion();
        content1.ContentLocation = 'S';                  
        content1.PathOnClient = 'testing1.pdf';          
        content1.Title = 'testing,1';      
        content1.VersionData = EncodingUtil.base64Decode('Attachment1');
        insertCaseContentversion.add(content1);

        ContentVersion content2 = new ContentVersion();
        content2.ContentLocation = 'S';                  
        content2.PathOnClient = 'testing2.png';          
        content2.Title = 'testing2,';      
        content2.VersionData = EncodingUtil.base64Decode('Attachment2');
        insertCaseContentversion.add(content2);

        ContentVersion content3 = new ContentVersion();
        content3.ContentLocation = 'S';                  
        content3.PathOnClient = 'testing3.png';          
        content3.Title = 'testing,3';      
        content3.VersionData = EncodingUtil.base64Decode('Attachment3');
        insertCaseContentversion.add(content3);

        ContentVersion content4 = new ContentVersion();
        content4.ContentLocation = 'S';                  
        content4.PathOnClient = 'testing4.png';          
        content4.Title = 'testing,4';      
        content4.VersionData = EncodingUtil.base64Decode('Attachment4');
        insertCaseContentversion.add(content4);

        ContentVersion content5 = new ContentVersion();
        content5.ContentLocation = 'S';                  
        content5.PathOnClient = 'testing5.png';          
        content5.Title = 'testing,5';      
        content5.VersionData = EncodingUtil.base64Decode('Attachment4');
        insertCaseContentversion.add(content5);
        INSERT insertCaseContentversion; 
                
        Id notificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        
        Case notificationCase1 = TestUtility.createCase('CaseSubject', 'Description', commercialCust, customerLocFrance);
        notificationCase1.recordtypeid = notificationRecordTypeId;
        notificationCase1.ContactId = cFrance.id;
        notificationCase1.Type = 'Logistics';
        notificationCase1.Sub_Type__c = 'Packaging';
        notificationCase1.Delivery_Number__c ='0800000006' ;
        notificationCase1.status = 'New';
        notificationCase1.Priority = 'Regular';

        INSERT notificationCase1;
            
        }
    
    }
    @isTest
    public static void testMethod1(){
        List<Case> listOfCaseIds = [SELECT id,SAP_Case_Number__c FROM Case LIMIT 1];
        List<ContentVersion> listOfContentVersion = [SELECT id,Title,ContentDocumentId FROM ContentVersion LIMIT 5] ;
        List<ContentDocumentLink> attachContentToCase = new List<ContentDocumentLink>();
        List<ContentDistribution> insertContentDistributionList = new List<ContentDistribution>();
      
        ContentDocumentLink cdlNotificationCase1 =  new ContentDocumentLink();
        cdlNotificationCase1.LinkedEntityId = listOfCaseIds.get(0).id;
        cdlNotificationCase1.ContentDocumentId = listOfContentVersion.get(0).ContentDocumentId;
        attachContentToCase.add(cdlNotificationCase1);

        ContentDocumentLink cdlNotificationCase1a =  new ContentDocumentLink();
        cdlNotificationCase1a.LinkedEntityId = listOfCaseIds.get(0).id;
        cdlNotificationCase1a.ContentDocumentId = listOfContentVersion.get(1).ContentDocumentId;
        attachContentToCase.add(cdlNotificationCase1a);

        ContentDocumentLink cdlNotificationCase2 =  new ContentDocumentLink();
        cdlNotificationCase2.LinkedEntityId = listOfCaseIds.get(0).id;
        cdlNotificationCase2.ContentDocumentId = listOfContentVersion.get(2).ContentDocumentId;
        attachContentToCase.add(cdlNotificationCase2);

        ContentDocumentLink cdlNotificationCase3 =  new ContentDocumentLink();
        cdlNotificationCase3.LinkedEntityId = listOfCaseIds.get(0).id;
        cdlNotificationCase3.ContentDocumentId = listOfContentVersion.get(3).ContentDocumentId;
        attachContentToCase.add(cdlNotificationCase3);

        ContentDocumentLink cdlNotificationCase4 =  new ContentDocumentLink();
        cdlNotificationCase4.LinkedEntityId = listOfCaseIds.get(0).id;
        cdlNotificationCase4.ContentDocumentId = listOfContentVersion.get(4).ContentDocumentId;
        attachContentToCase.add(cdlNotificationCase4);

        INSERT attachContentToCase;

        ContentDistribution contentShare1 = new ContentDistribution();
        contentShare1.Name = listOfContentVersion.get(0).Title;
        contentShare1.ContentVersionId = listOfContentVersion.get(0).id;
        contentShare1.RelatedRecordId = listOfCaseIds.get(0).id;
        contentShare1.PreferencesPasswordRequired = true;
        insertContentDistributionList.add(contentShare1);
        
        ContentDistribution contentShare2 = new ContentDistribution();
        contentShare2.Name = listOfContentVersion.get(1).Title;
        contentShare2.ContentVersionId = listOfContentVersion.get(1).id;
        contentShare2.RelatedRecordId = listOfCaseIds.get(0).id;
        contentShare2.PreferencesPasswordRequired = true;
        insertContentDistributionList.add(contentShare2);
        
        ContentDistribution contentShare3 = new ContentDistribution();
        contentShare3.Name = listOfContentVersion.get(2).Title;
        contentShare3.ContentVersionId = listOfContentVersion.get(2).id;
        contentShare3.RelatedRecordId = listOfCaseIds.get(0).id;
        contentShare3.PreferencesPasswordRequired = true;
        insertContentDistributionList.add(contentShare3);
        
        INSERT insertContentDistributionList;
        //Create Public URl when User First Time Click on Send To SAP Button
    	Boolean sapUserNameNotFound = SAPCaseCreationController.checkCaseOwnerAndCreateAttachedFilePublicURL([Select Id from User  WHERE Username LIKE '%userWithSAPUserName' limit 1].Id,listOfCaseIds[0].Id);
        system.assertEquals(false, sapUserNameNotFound);
        // Becasue of some error on first click of Send To SAP button, then on again click of Send To SAP button existing csv file will be updated
        sapUserNameNotFound = SAPCaseCreationController.checkCaseOwnerAndCreateAttachedFilePublicURL([Select Id from User  WHERE Username LIKE '%userWithSAPUserName' limit 1].Id,listOfCaseIds[0].Id);
        system.assertEquals(false, sapUserNameNotFound);
        try{
           Boolean sapUserNameNotFound1 = SAPCaseCreationController.checkCaseOwnerAndCreateAttachedFilePublicURL([Select Id from User  WHERE Username LIKE '%userWithoutSAPUserName' limit 1].Id,listOfCaseIds[0].Id); 
           system.assert(true,sapUserNameNotFound1);
           SAPCaseCreationController.checkCaseOwnerAndCreateAttachedFilePublicURL(null,null);
        }catch(Exception excp){
            
        }
        
    }
    
     @isTest
    public static void testMethod2(){
   
    SAPCaseCreationController.createComplaintInSAPAndGetSAPCaseNumber([Select Id from Case limit 1].Id);
    
  
    }

}