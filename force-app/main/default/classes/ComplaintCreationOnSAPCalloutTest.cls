/*
@Author     : Rohit Kumar
@CreatedDate:  16-06-2021
@UsedBy     : ComplaintCreationOnSAPCallout 
@Description: This class will use for perform unit testing of Apex class - ComplaintCreationOnSAPCallout.
              
@History
  16-06-2021   Rohit Kumar : Created
*/

@isTest
global class ComplaintCreationOnSAPCalloutTest {

    global Class MockHttpResponseGenratorForComplaint1 implements HttpCalloutMock{

        global HttpResponse respond(HttpRequest request){

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"Response":[{"ErrorOrMessage":"SAP Case Created"},{"ErrorOrMessage":"Notification 200010584 saved"}],"NotifNr":"200010584","ErrorIndicator":"S"}');
            return response;
        }
    }

    global Class MockHttpResponseGenratorForComplaint2 implements HttpCalloutMock{

        global HttpResponse respond(HttpRequest request){

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(500);
            response.setStatus('Internal Server Error');
            return response;
        }
    }
    
    global Class MockHttpResponseGenratorForComplaint3 implements HttpCalloutMock{

        global HttpResponse respond(HttpRequest request){

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody('{"Response":[{"ErrorOrMessage":"Delivery Number Is Invalid"}],"NotifNr":"","ErrorIndicator":"F"}');
            return response;
        }
    }

     @testSetup
    Private static void setup() {

        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCust = TestUtility.createAccount('H1 Customer User'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCust);

        Account commercialCustDanone = TestUtility.createAccount('H1 Test Danone SA'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCustDanone);
        INSERT accsCommercCustToInsert;

        List<Account> accsToInsert = new List<Account>(); //Customer locations list to be created
        Account customerLocItaly = TestUtility.createCustomerLocation('H5 Test Customer Italy', commercialCust); //Customer location test record
        customerLocItaly.BillingStreet = null;
        customerLocItaly.BillingPostalCode = null;
        customerLocItaly.BillingCity = null;
        customerLocItaly.BillingCountryCode = null;
        customerLocItaly.BillingCountry = 'Italy';
        accsToInsert.add(customerLocItaly);

        Account customerLocFrance = TestUtility.createCustomerLocation('H5 Test Customer France', commercialCust); //Customer location test record
        customerLocFrance.BillingStreet = null;
        customerLocFrance.BillingPostalCode = null;
        customerLocFrance.BillingCity = null;
        customerLocFrance.BillingCountryCode = null;
        customerLocFrance.BillingCountry = 'France';
        accsToInsert.add(customerLocFrance);

        Account customerLocDanoneBledina = TestUtility.createCustomerLocation('H5 Test Danone Bledina', commercialCustDanone); //Customer location test record
        customerLocDanoneBledina.BillingStreet = null;
        customerLocDanoneBledina.BillingPostalCode = null;
        customerLocDanoneBledina.BillingCity = null;
        customerLocDanoneBledina.BillingCountryCode = null;
        customerLocDanoneBledina.BillingCountry = 'Poland';
        accsToInsert.add(customerLocDanoneBledina);

        Account customerLocDanoneNutrition = TestUtility.createCustomerLocation('H5 Test Nutricia Infant Nutrition Ltd', commercialCustDanone); //Customer location test record
        customerLocDanoneNutrition.BillingStreet = null;
        customerLocDanoneNutrition.BillingPostalCode = null;
        customerLocDanoneNutrition.BillingCity = null;
        customerLocDanoneNutrition.BillingCountryCode = null;
        customerLocDanoneNutrition.BillingCountry = 'France';
        accsToInsert.add(customerLocDanoneNutrition);
        
        INSERT accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created

        Contact cItaly = TestUtility.createContact('Test Customer', 'Italy',commercialCust, customerLocItaly); //Contact test record
        contactsToInsert.add(cItaly);

        Contact cFrance = TestUtility.createContact('Test Customer', 'France',commercialCust, customerLocFrance); //Contact test record
        contactsToInsert.add(cFrance);

        Contact cDanoneBledina = TestUtility.createContact('Test Danone','Bledina',commercialCustDanone, customerLocDanoneBledina); //Contact test record
        contactsToInsert.add(cDanoneBledina);

        Contact cDanoneNutrition = TestUtility.createContact('Test Danone','Nutrition',commercialCustDanone, customerLocDanoneNutrition); //Contact test record
        contactsToInsert.add(cDanoneNutrition);
        INSERT contactsToInsert;

        Product2 testProduct = TestUtility.createProduct('TestProduct');
        INSERT testProduct;
        
        Id notificationRecordTypeId = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Danone_Complaint' LIMIT 1].Id;
        List<Case> caseListToInsert = new List<Case>();
        
        Case notificationCase1 = TestUtility.createCase('CaseSubject1', 'Descrip1', commercialCustDanone, customerLocDanoneBledina);
        notificationCase1.recordtypeid = notificationRecordTypeId;
        notificationCase1.Type = 'Logistics';
        notificationCase1.Sub_Type__c = 'Packaging';
        notificationCase1.Delivery_Number__c ='0800000006' ;
        notificationCase1.ContactId = cDanoneBledina.id;
        notificationCase1.status = 'New';
        notificationCase1.Priority = 'Regular';
        caseListToInsert.add(notificationCase1);

        Case notificationCase2 = TestUtility.createCase('CaseSubject2', 'Descrip2', commercialCustDanone, customerLocDanoneNutrition);
        notificationCase2.recordtypeid = notificationRecordTypeId;
        notificationCase2.Type = 'Sales';
        notificationCase2.Sub_Type__c = 'Invoice';
        notificationCase2.Delivery_Number__c ='0800000007' ;
        notificationCase2.ContactId = cDanoneNutrition.id;
        notificationCase2.status = 'New';
        notificationCase2.Priority = 'Regular';
        caseListToInsert.add(notificationCase2);

        Case notificationCase3 = TestUtility.createCase('CaseSubject3', 'Descrip3', commercialCust, customerLocItaly);
        notificationCase3.recordtypeid = notificationRecordTypeId;
        notificationCase3.Type = 'Logistics';
        notificationCase3.Sub_Type__c = 'CMR';
        notificationCase3.Delivery_Number__c ='0700000008' ;
        notificationCase3.ContactId =cItaly.id;
        notificationCase3.status = 'New';
        notificationCase3.Priority = 'Regular';
        caseListToInsert.add(notificationCase3);

        Case notificationCase4 = TestUtility.createCase('CaseSubject4', 'Descrip4', commercialCust, customerLocFrance);
        notificationCase4.recordtypeid = notificationRecordTypeId;
        notificationCase4.Type = 'Quality Make';
        notificationCase4.Sub_Type__c = 'Appearance';
        notificationCase4.Delivery_Number__c ='0800000009' ;
        notificationCase4.ContactId = cFrance.id;
        notificationCase4.status = 'New';
        notificationCase4.Priority = 'Regular';
        notificationCase4.Product__c = testProduct.id;
        notificationCase4.Batch_Number__c = 'BAT001';
        caseListToInsert.add(notificationCase4);
        
        Case notificationCase5 = TestUtility.createCase('CaseSubject5', 'Descrip5', commercialCust, customerLocFrance);
        notificationCase5.recordtypeid = notificationRecordTypeId;
        notificationCase5.Type = 'Logistics';
        notificationCase5.Sub_Type__c = 'Labels';
        notificationCase5.Delivery_Number__c ='0800000010' ;
        notificationCase5.ContactId = cFrance.id;
        notificationCase5.status = 'New';
        notificationCase5.Priority = 'Regular';
        caseListToInsert.add(notificationCase5);

        INSERT caseListToInsert;
        
        List<ContentVersion> insertCaseContentversion = new List<ContentVersion>();
        ContentVersion content1 = new ContentVersion();
        content1.ContentLocation = 'S';                  
        content1.PathOnClient = 'SF_CPI_SAP_'+caseListToInsert[0].CaseNumber+'.csv';//'testing1.pdf';          
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
        content5.VersionData = EncodingUtil.base64Decode('Attachment4');
        insertCaseContentversion.add(content5);
        INSERT insertCaseContentversion;  
        

    }

    @isTest
    Private static void testCreationOfComplaintOnSAP(){

        List<Case> listOfCaseIds = [SELECT id,SAP_Case_Number__c FROM Case LIMIT 5];
        List<ContentVersion> listOfContentVersion = [SELECT id,ContentDocumentId FROM ContentVersion LIMIT 5] ;
        List<ContentDocumentLink> attachContentToCase = new List<ContentDocumentLink>();
      

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

        ContentDocumentLink cdlNotificationCase5 =  new ContentDocumentLink();
        cdlNotificationCase5.LinkedEntityId = listOfCaseIds.get(1).id;
        cdlNotificationCase5.ContentDocumentId = listOfContentVersion.get(4).ContentDocumentId;
        attachContentToCase.add(cdlNotificationCase5);

         INSERT attachContentToCase;

         ComplaintCreationOnSAPCallout.SetResponseFromSAPForComponent getResponse;
		 SAPCaseCreationController.createAttachedFilePublicURL(listOfCaseIds.get(0).Id, null);
        Test.startTest();
		 
         Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaint1() );
         getResponse = ComplaintCreationOnSAPCallout.createComplaintOnSAPAndGetSAPCaseNumber(new Set<id>{listOfCaseIds.get(0).Id,listOfCaseIds.get(1).Id});
         system.assertEquals('SUCCESS',getResponse.Status); 
         system.assertEquals('200010584',getResponse.NotificationNumber); 
         system.assertEquals('200010584',[SELECT SAP_Case_Number__c FROM Case WHERE id=:listOfCaseIds.get(0).Id].SAP_Case_Number__c); 
        Test.stopTest();
    }
    
     @isTest
    Private static void testErrorInCreationOfComplaintOnSAP1(){
        
        List<Case> getCaseRecords = [SELECT id FROM Case LIMIT 5];

         ComplaintCreationOnSAPCallout.SetResponseFromSAPForComponent getResponse;
         getResponse = ComplaintCreationOnSAPCallout.createComplaintOnSAPAndGetSAPCaseNumber(new Set<id>{getCaseRecords.get(1).id,getCaseRecords.get(2).id,getCaseRecords.get(3).id});
         system.assertEquals('INTERNAL_ERROR',getResponse.Status); 

        Test.startTest();

         Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaint2() );
         getResponse = ComplaintCreationOnSAPCallout.createComplaintOnSAPAndGetSAPCaseNumber(new Set<id>{getCaseRecords.get(4).id});
         system.assertEquals('INTEGRATION_ERROR',getResponse.Status); 
         system.assertEquals('Internal Server Error',getResponse.ErrorMessage); 

        Test.stopTest();
    }
      @isTest
    Private static void testErrorInCreationOfComplaintOnSAP2(){
        
        List<Case> getCaseRecords = [SELECT id FROM Case LIMIT 5];
        ComplaintCreationOnSAPCallout.SetResponseFromSAPForComponent getResponse;
        Test.startTest();

         Test.setMock(HttpCallOutMock.class,new MockHttpResponseGenratorForComplaint3() );
         getResponse = ComplaintCreationOnSAPCallout.createComplaintOnSAPAndGetSAPCaseNumber(new Set<id>{getCaseRecords.get(0).id});
         system.assertEquals('FAILED',getResponse.Status); 
         system.assertEquals('Delivery Number Is Invalid',getResponse.ErrorMessage); 

        Test.stopTest();
    }
}