/**       
@Name           	- BulkUploadChildLeadsTest
@Author         	- Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        	- 1.0
@CreatedDate    	- 27-04-2023
@Apex Class Covered	- BulkUploadChildLeads, BulkUploadChildLeadsHelper

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 27-04-2023 | Created class
--------------------|-------------------------------------|------------|--------------

* @description Test class to cover the code for these apex classes - BulkUploadChildLeads, BulkUploadChildLeadsHelper
*/
@isTest
public class BulkUploadChildLeadsTest {
    
    /** 
     * @description Test Data Setup
     */
    @testSetup
    static void setup(){
        TriggerHandler.skipTrigger = true;
        
        ID leadRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Master_Lead').getRecordTypeId();
        ID conRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BGI_Contact').getRecordTypeId();
        ID campFCIRecordType = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('FCI_Campaign').getRecordTypeId();
        ID campFCPRecordType = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('FCP_Campaign').getRecordTypeId();
        
        List<Campaign> campaignList = new List<Campaign>();
        Campaign camp1 = new Campaign(); 
        camp1.Business_Segment__c = 'Adult Nutrition';
        camp1.Sub_Segment__c = 'Active Nutrition';
        camp1.Name = 'Test AN Manual Campaign';
        camp1.RecordTypeId = campFCIRecordType;
        campaignList.add(camp1);
        
        Campaign camp2 = new Campaign(); 
        camp2.Business_Segment__c = 'Early Life Nutrition & Cell Nutrition';
        camp2.Sub_Segment__c = 'Cell Nutrition';
        camp2.Name = 'Test ELN Manual Campaign';
        camp2.RecordTypeId = campFCIRecordType;
        campaignList.add(camp2);
        
        Campaign camp3 = new Campaign(); 
        camp3.Business_Segment__c = 'Industry';
        camp3.Sub_Segment__c = 'Beverages';
        camp3.Name = 'Test F&B Manual Campaign';
        camp3.RecordTypeId = campFCPRecordType;
        campaignList.add(camp3);
        
        insert campaignList;
        
        List<Lead> leadList = new List<Lead>();
        
        Lead leadRecord1 = new Lead(
            Active__c = true,
            Company = 'IMCD Italy',
            FirstName = 'test lead 1',
            Phone = '+919876543212',
            Email = 'testchildlead@test.com',
            LastName = 'last name 1',
            Country = 'India',
            Region__c = 'APAC',
            RecordTypeId = leadRecordType
        );
        leadList.add(leadRecord1);
        
        Lead leadRecord2 = new Lead(
            Active__c = true,
            Company = 'ABC',
            FirstName = 'test lead 2',
            Phone = '+919876543210',
            Email = 'testabc@test.com',
            LastName = 'last name 2',
            Country = 'India',
            Region__c = 'APAC',
            RecordTypeId = leadRecordType
        );
        leadList.add(leadRecord2);
        
        Lead leadRecord3 = new Lead(
            Active__c = true,
            Company = 'ABC',
            FirstName = 'test lead 3',
            Phone = '+919876543210',
            Email = 'testabc@test.com',
            LastName = 'last name 3',
            Country = 'India',
            Region__c = 'APAC',
            RecordTypeId = leadRecordType
        );
        leadList.add(leadRecord3);
        
        Lead leadRecord4 = new Lead(
            Active__c = true,
            Company = 'XYZ',
            FirstName = 'test lead 4',
            Phone = '+919876543211',
            Email = 'testxyz@test.com',
            LastName = 'last name 4',
            Country = 'India',
            Region__c = 'APAC',
            RecordTypeId = leadRecordType
        );
        leadList.add(leadRecord4);
        
        insert leadList;
        
        List<Contact> contactList = new List<Contact>();
        Contact testContact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact 1',
            Email = 'testcon1@test.com',
            Active__c = true,
            RecordTypeId = conRecordType
        );
        contactList.add(testContact1);
        
        Contact testContact2 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact 2',
            Email = 'testabccon@test.com',
            Active__c = true,
            RecordTypeId = conRecordType
        );
        contactList.add(testContact2);
        
        Contact testContact3 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact 3',
            Email = 'testabccon@test.com',
            Active__c = true,
            RecordTypeId = conRecordType
        );
        contactList.add(testContact3);
        
        Contact testContact4 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact 4',
            Email = 'testxyz@test.com',
            Active__c = true,
            RecordTypeId = conRecordType
        );
        contactList.add(testContact4);
        
        insert contactList;
        
        List<Child_Lead__c> newChildLeads = new List<Child_Lead__c>();
        Child_Lead__c testChildLead = new Child_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Child Lead',
            Company__c = 'IMCD Italy',
            Email__c = 'testchildlead@test.com',
            Campaign_Name__c = campaignList[0].id,
            Phone__c = '1234567890',
            Active__c = true
        );
        newChildLeads.add(testChildLead);
        
        Child_Lead__c testChildLead2 = new Child_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Child Lead',
            Company__c = 'IMCD Italy',
            Email__c = 'testcon1@test.com',
            Campaign_Name__c = campaignList[0].id,
            Phone__c = '1234567890',
            Active__c = true
        );
        newChildLeads.add(testChildLead2);
        insert newChildLeads;
        
        TriggerHandler.skipTrigger = false;
    }
    
        
    
    /** 
     * @description Test Scenario - Duplicate Child Lead Validation
     */
    @isTest
    static void duplicateChildLeadValidationTest(){
        Campaign anManualCampaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test AN Manual Campaign'];
        Child_Lead__c existingChildLead = [SELECT Id, Name, Email__c, Campaign_Name__c, Lead_Status__c FROM Child_Lead__c WHERE Email__c = 'testchildlead@test.com'];
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c newChildLead1 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 1',
            Last_Name__c = 'Test Child Lead LN 1',
            Email__c = 'testchildlead@test.com',
            Campaign_Name__c = anManualCampaign.Id,
            Company__c = 'IMCD Italy'
        );
        childLeadList.add(newChildLead1);
        
        Child_Lead__c newChildLead2 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 2',
            Last_Name__c = 'Test Child Lead LN 2',
            Email__c = 'testchildlead@test.com',
            Campaign_Name__c = anManualCampaign.Id,
            Company__c = 'IMCD Italy'
        );
        childLeadList.add(newChildLead2);
        
        Child_Lead__c newChildLead3 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 3',
            Last_Name__c = 'Test Child Lead LN 3',
            Email__c = 'testchildlead@test.com',
            Campaign_Name__c = anManualCampaign.Id,
            Company__c = 'IMCD Italy'
        );
        childLeadList.add(newChildLead3);
        
        Test.startTest();
		Database.SaveResult[] results = Database.insert(childLeadList, false); // false = allow partial failure, no exception
    	System.assertNotEquals(true, results[0].isSuccess(),'Duplicate Child Lead Error');
        System.assertNotEquals(true, results[1].isSuccess(),'Duplicate Child Lead Error');
        System.assertNotEquals(true, results[2].isSuccess(),'Duplicate Child Lead Error');
        Test.stopTest();
    }
    
    /** 
     * @description Test Scenario - Child Lead Company required Validation
     */
    @isTest
    static void childLeadCompanyValidationTest(){
        Campaign anManualCampaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test AN Manual Campaign'];
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c newChildLead1 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 1',
            Last_Name__c = 'Test Child Lead LN 1',
            Email__c = 'newtestcl@test.com',
            Campaign_Name__c = anManualCampaign.Id
        );
        childLeadList.add(newChildLead1);
        
        Child_Lead__c newChildLead2 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 2',
            Last_Name__c = 'Test Child Lead LN 2',
            Email__c = 'newtestcl@test.com',
            Campaign_Name__c = anManualCampaign.Id
        );
        childLeadList.add(newChildLead2);
        
        Child_Lead__c newChildLead3 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 3',
            Last_Name__c = 'Test Child Lead LN 3',
            Email__c = 'newtestcl@test.com',
            Campaign_Name__c = anManualCampaign.Id
        );
        childLeadList.add(newChildLead3);
        
        Test.startTest();
		Database.SaveResult[] results = Database.insert(childLeadList, false); // false = allow partial failure, no exception
    	System.assertNotEquals(true, results[0].isSuccess(),'Company should not be blank');
        System.assertNotEquals(true, results[1].isSuccess(),'Company should not be blank');
        System.assertNotEquals(true, results[2].isSuccess(),'Company should not be blank');
        Test.stopTest();
    }
    
    /** 
     * @description Test Scenario - Multiple Leads found with the same Email
     */
    @isTest
    static void multipleLeadsFoundValidationTest(){
        Campaign elnManualCampaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test ELN Manual Campaign'];
        List<Lead> existingLeads = [SELECT Id, Name, Email FROM Lead WHERE Email = 'testabc@test.com'];
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c newChildLead1 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 1',
            Last_Name__c = 'Test Child Lead LN 1',
            Email__c = 'testabc@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead1);
        
        Child_Lead__c newChildLead2 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 2',
            Last_Name__c = 'Test Child Lead LN 2',
            Email__c = 'testabc@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead2);
        
        Child_Lead__c newChildLead3 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 3',
            Last_Name__c = 'Test Child Lead LN 3',
            Email__c = 'testabc@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead3);
        
        Test.startTest();
		Database.SaveResult[] results = Database.insert(childLeadList, false); // false = allow partial failure, no exception
    	System.assertNotEquals(true, results[0].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        System.assertNotEquals(true, results[1].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        System.assertNotEquals(true, results[2].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        Test.stopTest();
    }
    
    /** 
     * @description Test Scenario - Multiple Contacts found with the same email
     */
    @isTest
    static void multipleContactsFoundValidationTest(){
        Campaign elnManualCampaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test ELN Manual Campaign'];
        List<Contact> existingContacts = [SELECT Id, Name, Email FROM Contact WHERE Email = 'testabccon@test.com'];
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c newChildLead1 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 1',
            Last_Name__c = 'Test Child Lead LN 1',
            Email__c = 'testabccon@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead1);
        
        Child_Lead__c newChildLead2 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 2',
            Last_Name__c = 'Test Child Lead LN 2',
            Email__c = 'testabccon@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead2);
        
        Child_Lead__c newChildLead3 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 3',
            Last_Name__c = 'Test Child Lead LN 3',
            Email__c = 'testabccon@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead3);
        
        Test.startTest();
		Database.SaveResult[] results = Database.insert(childLeadList, false); // false = allow partial failure, no exception
    	System.assertNotEquals(true, results[0].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        System.assertNotEquals(true, results[1].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        System.assertNotEquals(true, results[2].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        Test.stopTest();
    }
    
    /** 
     * @description Test Scenario - Both the Lead and Contact exists with the same email
     */
    @isTest
    static void bothLeadAndContactFoundValidationTest(){
        Campaign elnManualCampaign = [SELECT Id, Name FROM Campaign WHERE Name = 'Test ELN Manual Campaign'];
        List<Lead> existingLeads = [SELECT Id, Name, Email FROM Lead WHERE Email = 'testxyz@test.com'];
        List<Contact> existingContacts = [SELECT Id, Name, Email FROM Contact WHERE Email = 'testxyz@test.com'];
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c newChildLead1 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 1',
            Last_Name__c = 'Test Child Lead LN 1',
            Email__c = 'testxyz@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead1);
        
        Child_Lead__c newChildLead2 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 2',
            Last_Name__c = 'Test Child Lead LN 2',
            Email__c = 'testxyz@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead2);
        
        Child_Lead__c newChildLead3 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 3',
            Last_Name__c = 'Test Child Lead LN 3',
            Email__c = 'testxyz@test.com',
            Campaign_Name__c = elnManualCampaign.Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead3);
        
        Test.startTest();
		Database.SaveResult[] results = Database.insert(childLeadList, false); // false = allow partial failure, no exception
    	System.assertNotEquals(true, results[0].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        System.assertNotEquals(true, results[1].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        System.assertNotEquals(true, results[2].isSuccess(),'Child Lead cannot be created. Multiple leads exist with the same email.');
        Test.stopTest();
    }
    
    /** 
     * @description Test Scenario - Child Lead with new Email address
     */
    @isTest
    static void newChildLeadCreationTest(){
        List<Campaign> campaignsList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test ELN Manual Campaign' OR Name = 'Test AN Manual Campaign' OR
                                       Name = 'Test F&B Manual Campaign' ORDER BY Name];
        List<Lead> existingLeads = [SELECT Id, Name, Email FROM Lead WHERE Email LIKE '%test%'];
        List<Contact> existingContacts = [SELECT Id, Name, Email FROM Contact WHERE Email LIKE '%test%'];
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c newChildLead1 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 1',
            Last_Name__c = 'Test Child Lead LN 1',
            Email__c = 'newtestxyz@test.com',
            Campaign_Name__c = campaignsList[1].Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead1);
        
        Child_Lead__c newChildLead2 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 2',
            Last_Name__c = 'Test Child Lead LN 2',
            Email__c = 'newtestabc@test.com',
            Campaign_Name__c = campaignsList[0].Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead2);
        
        Child_Lead__c newChildLead3 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 3',
            Last_Name__c = 'Test Child Lead LN 3',
            Email__c = 'newtestcom@test.com',
            Campaign_Name__c = campaignsList[2].Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead3);
        
        Test.startTest();
		Database.SaveResult[] results = Database.insert(childLeadList, false); // false = allow partial failure, no exception
        Test.stopTest();
        
        List<Child_Lead__c> childLeadsList = [SELECT Id, Name, First_Name__c, Last_Name__c, Related_Master_Lead__c, Related_Contact__c 
                                             FROM Child_Lead__c WHERE Email__c IN ('newtestxyz@test.com', 'newtestabc@test.com', 'newtestcom@test.com')
                                             ORDER BY Last_Name__c];
        
        System.assertEquals(true, results[0].isSuccess());
        System.assertEquals(true, results[1].isSuccess());
        System.assertEquals(true, results[2].isSuccess());
        System.assertEquals(true, childLeadsList[0].Related_Master_Lead__c != null);
        System.assertEquals(true, childLeadsList[1].Related_Master_Lead__c != null);
        System.assertEquals(true, childLeadsList[2].Related_Master_Lead__c != null);
    }
    
    /** 
     * @description Test Scenario - Existing Lead participated in new Campaign
     */
    @isTest
    static void existingLeadNewCampaignTest(){
        List<Campaign> campaignsList = [SELECT Id, Name FROM Campaign WHERE Name = 'Test ELN Manual Campaign' OR Name = 'Test AN Manual Campaign' OR
                                       Name = 'Test F&B Manual Campaign' ORDER BY Name];
        List<Lead> existingLeads = [SELECT Id, Name, Email FROM Lead WHERE Email LIKE '%test%'];
        List<Contact> existingContacts = [SELECT Id, Name, Email FROM Contact WHERE Email LIKE '%test%'];
        List<Child_Lead__c> existingChildLeads = [SELECT Id, Name, Related_Master_Lead__c, Related_Contact__c FROM Child_Lead__c
                                                 WHERE Related_Master_Lead__c IN: existingLeads OR Related_Contact__c IN: existingContacts];
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c newChildLead1 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 1',
            Last_Name__c = 'Test Child Lead LN 1',
            Email__c = 'testchildlead@test.com',
            Campaign_Name__c = campaignsList[1].Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead1);
        
        Child_Lead__c newChildLead2 = new Child_Lead__c(
        	First_Name__c = 'Test Child Lead FN 2',
            Last_Name__c = 'Test Child Lead LN 2',
            Email__c = 'testcon1@test.com',
            Campaign_Name__c = campaignsList[1].Id,
            Company__c = 'ABC Test Comp'
        );
        childLeadList.add(newChildLead2);
        
        Test.startTest();
		Database.SaveResult[] results = Database.insert(childLeadList, false); // false = allow partial failure, no exception
        Test.stopTest();
        
        List<Child_Lead__c> childLeadsList = [SELECT Id, Name, First_Name__c, Last_Name__c, Related_Master_Lead__c, Related_Contact__c 
                                             FROM Child_Lead__c WHERE Email__c IN ('testchildlead@test.com', 'testcon1@test.com')
                                             ORDER BY Last_Name__c];
        
        System.assertEquals(true, results[0].isSuccess());
        System.assertEquals(true, results[1].isSuccess());
    }
    
    /** 
    * @description Test Scenario - Batch class - Reactivating inactive lead
    */
    @isTest
    static void reactivationChildLeadTest(){
      Child_Lead__c existingChildLead = [SELECT Id, Name, Email__c, Campaign_Name__c, Lead_Status__c FROM Child_Lead__c WHERE Email__c = 'testcon1@test.com'];
      existingChildLead.active__c = false;
      update existingChildLead;
          
      List<Child_Lead__c> childLeads = [select id,Last_Name__c,active__c,Campaign_Name__c from Child_Lead__c];  
      List<String> childleadIds = new List<String>();
      for (Child_Lead__c lead : childLeads) {
         childleadIds.add(lead.Id);
      }
      Test.startTest();
              
      ActivateLeadInterest batchInstance = new ActivateLeadInterest(childleadIds, 'test@example.com');
      ID JobId = Database.executeBatch(batchInstance);
        
      Test.stopTest();
      
      Child_Lead__c cl = [select Id,Active__c from Child_Lead__c where email__c = 'testcon1@test.com'];
      system.assertEquals(true, cl.Active__c);
    } 

}