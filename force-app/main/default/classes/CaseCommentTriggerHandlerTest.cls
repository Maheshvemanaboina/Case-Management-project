@isTest 
public  class CaseCommentTriggerHandlerTest {
    @testSetup
    public static void setup(){
        List<Account> commercialAccountList = new List<Account>();
        List<Account> customerLocationAccountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        List<Product2> productList = new List<Product2>();
        
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        commercialAccountList.add(commercialCust);
        INSERT commercialAccountList;
        
        Pricebook2 priceBookObj = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );       
        UPDATE priceBookObj;
        
        Product2 pro1 = new Product2();
        pro1.Name = 'Product1';
        pro1.IsActive =true;
        pro1.Product_Code__c = 'SAPPRODUCTcode1';
        pro1.ProductCode ='PRODUCTcode1';
        productList.add(pro1);
        
        INSERT productList;
        
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        customerLocItaly.SAP_Number_PE1__c = '00000001';
        customerLocItaly.SAP_Number__c = '00000001';
        customerLocationAccountList.add(customerLocItaly);
        INSERT customerLocationAccountList;
        
        Contact cItaly = TestUtility.createContact('italyCont' , 'italyCont', commercialCust, customerLocItaly);
        contactList.add(cItaly);
        INSERT contactList;
        
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_CUSTOMER_PROFILE);
        usrItaly.ContactId = cItaly.Id;
        userList.add(usrItaly);
        
        User systemAdminUser = TestUtility.createUser('systemadminuser@test.com', 'System Administrator');
        userList.add(systemAdminUser);
        
        INSERT userList;
        
    }
    @isTest
    public static void testCaseSatusUpdateForCommunityUser(){
        
        Id notificationCaseRecordTypeId = schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Danone_Complaint').getRecordTypeId();
        List<Account> queryAccount = [SELECT id,Name FROM Account];
        List<Contact> queryContact = [SELECT id FROM Contact];
        Map<String, Id> accsMap = new Map<String, Id>();
        List<Product2> productList = [SELECT id FROM Product2];
        List<Global_Automation_Setting__c> globalSettingList =  new List<Global_Automation_Setting__c>();
        User communityUser = [SELECT id,ProfileId,Username,ISPortalEnabled  FROM User WHERE Username LIKE '%TestIMCDItaly' LIMIT 1];
        User systemadminUser = [SELECT id,ProfileId,Username,ISPortalEnabled  FROM User WHERE Username='systemadminuser@test.com' LIMIT 1]; 
        for (Account acc : queryAccount) {
            accsMap.put(acc.Name, acc.id);
        }
        
        Global_Automation_Setting__c globalSetting1 = new Global_Automation_Setting__c();
        globalSetting1.Name = 'FCICustomer';
        globalSetting1.SetupOwnerId =  communityUser.ProfileId;
        globalSetting1.Skip_Apex_Trigger__c	= false;
        globalSetting1.Skip_Process_Builder__c = false;
        globalSetting1.Skip_Validation_Rule__c = false;
        globalSettingList.add(globalSetting1);
        Global_Automation_Setting__c globalSetting2 = new Global_Automation_Setting__c();
        globalSetting2.Name = 'SystemAdmin';
        globalSetting2.SetupOwnerId =  systemadminUser.ProfileId;
        globalSetting2.Skip_Apex_Trigger__c	= false;
        globalSetting2.Skip_Process_Builder__c = false;
        globalSetting2.Skip_Validation_Rule__c = true;
        globalSettingList.add(globalSetting2);
        
        INSERT globalSettingList; 
        
        Case notificationCase; 
        
        TEST.startTest();
        System.runAs(systemadminUser){
            notificationCase = new Case ();
            notificationCase.Subject = 'TEST';
            notificationCase.Description = 'TEST';
            notificationCase.Comments__c= 'TEST';
            notificationCase.Accountid = accsMap.get('IMCD Italy Spa');
            notificationCase.Parent_Account__c = accsMap.get('IMCD Holding');
            notificationCase.contactId = queryContact.get(0).id;
            notificationCase.Delivery_Number__c = '0100000001';
            notificationCase.Batch_Number__c = 'TEST';
            notificationCase.Product__c  = productList.get(0).id;
            notificationCase.Type = 'Quality Make';
            notificationCase.Status ='New';
            notificationCase.recordTypeId = notificationCaseRecordTypeId;
            notificationCase.Priority = 'Regular';
            notificationCase.SLA_Picklist__c = 'Within SLA';
            INSERT notificationCase;
            System.assertEquals('Assigned', [SELECT id,Status FROM Case WHERE id=:notificationCase.id][0].Status);
        }

        
            notificationCase.Sub_Type__c = 'Food Safety';
            UPDATE notificationCase;
            
            CaseComment comment2 = new CaseComment();
            comment2.CommentBody = 'TEST';
            comment2.IsPublished = true;
            comment2.ParentId = notificationCase.id;
            INSERT comment2;
            //System.assertEquals('Awaiting Customer Response', [SELECT id,Status FROM Case WHERE id=:notificationCase.id][0].Status);

        System.runAs(communityUser){
            
            CaseComment comment3 = new CaseComment();
            comment3.CommentBody = 'TEST';
            comment3.IsPublished = true;
            comment3.ParentId = notificationCase.id;
            INSERT comment3;
            System.assertEquals('Awaiting Customer Response', [SELECT id,Status FROM Case WHERE id=:notificationCase.id][0].Status);
        }
        
            notificationCase.Status = 'Closed';
            UPDATE notificationCase;
            System.assertEquals('Closed', [SELECT id,Status FROM Case WHERE id=:notificationCase.id][0].Status);
       
        System.runAs(communityUser){
            CaseComment comment4 =new CaseComment();
            comment4.CommentBody = 'TEST';
            comment4.IsPublished = true;
            comment4.ParentId = notificationCase.id;
            INSERT comment4;
            System.assertEquals('Reopened', [SELECT id,Status FROM Case WHERE id=:notificationCase.id][0].Status);
        }
        
        
        
        TEST.stopTest();
        
    }
    
}