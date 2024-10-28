/**
@Name           	- ChildLeadInvocableMethodsTest
@Author         	- Mahendra Kumar | Email - mahendra.kumar@frieslandcampina.com
@Version        	- 1.0
@CreatedDate    	- 08-05-2023
@Apex Class Covered	- AppendFieldValues, AppendTextOrTextAreaFieldValues, GenerateTimeStamp, MergeLeads, CompareMultiPickistValues

UserId              | Author-Email                        | Date       | Comment
====================|=====================================|============|==============
0058E000009TanLQAS  | mahendra.kumar@frieslandcampina.com | 08-05-2023 | Created class
--------------------|-------------------------------------|------------|--------------
* @description Test class to cover the code for these apex classes - AppendFieldValues, AppendTextOrTextAreaFieldValues, GenerateTimeStamp, MergeLeads, CompareMultiPickistValues
*/
@isTest
public class ChildLeadInvocableMethodsTest{
    
    /** 
     * @description Test Data Setup
     */
    @testSetup
    static void setupTestData(){
        TriggerHandler.skipTrigger = true;
        
        ID leadRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Master_Lead').getRecordTypeId(); 
        ID conRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('BGI_Contact').getRecordTypeId();
        ID accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        
        // Create a Campaign object
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            Business_Segment__c = 'Adult Nutrition',
            Sub_Segment__c = 'Active Nutrition',
            Calculate_Message__c = true,
            Documents_Downloaded__c = 'Yoghurt Drink concept card;OSS Concept Card;Breakfast Drink concept card',
            Sample_Requested__c = 'Deminal® 90;Vivinal® MFGM;Nutri Whey™ Hydro',
            Trending_Applications_2021__c = 'Beverages;Confectionary;Chocolate'
        );
        insert c;
        
        Account acc = new Account(
        	Name = 'Test acc',
            RecordTypeId = accRecordType
        );
        insert acc;

        // Create a Master Lead object
        Lead masterLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'testlead@testlead.com',
            Message__c = 'Test Lead Message',
            RecordTypeId = leadRecordType,
            Documents_Downloaded__c = 'Yoghurt Drink concept card',
            Sample_Requested__c = 'Deminal® 90',
            Trending_Applications_2021__c = 'Beverages'
        );
        insert masterLead;

        // Create a Contact object
        Contact contact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@testcontact.com',
            Message__c = 'Test Contact Message',
            RecordTypeId = conRecordType,
            AccountId = acc.Id,
            Documents_Downloaded__c = 'Breakfast Drink concept card',
            Sample_Requested__c = 'Nutri Whey™ Hydro',
            Trending_Applications_2021__c = 'Confectionary'
        );
        insert contact;        
        
        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();

        // Create a Child Lead object
        Child_Lead__c childLead1 = new Child_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Child Lead 1',
            Company__c = 'Test Company',
            Email__c = 'testlead@testlead.com',
            Campaign_Name__c = c.Id,
            Related_Master_Lead__c = masterLead.Id,
            Documents_Downloaded__c = 'Yoghurt Drink concept card',
            Sample_Requested__c = 'Deminal® 90',
            Trending_Applications_2021__c = 'Beverages'
        );
        childLeadList.add(childLead1);
        
        Child_Lead__c childLead2 = new Child_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Child Lead 2',
            Company__c = 'Test Company',
            Email__c = 'testcontact@testcontact.com',
            Campaign_Name__c = c.Id,
            Related_Contact__c = contact.Id,
            Documents_Downloaded__c = 'Breakfast Drink concept card',
            Sample_Requested__c = 'Nutri Whey™ Hydro',
            Trending_Applications_2021__c = 'Confectionary'
        );
        childLeadList.add(childLead2);
        
        Child_Lead__c childLead3 = new Child_Lead__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Child Lead 3',
            Company__c = 'Test Company',
            Email__c = 'testlead@testlead.com',
            Campaign_Name__c = c.Id,
            Related_Master_Lead__c = masterLead.Id,
            Message__c = 'Test Message'
        );
        childLeadList.add(childLead3);
        
        insert childLeadList;
        
        List<Lead> leadsList = new List<Lead>();
        Lead lead1 = new Lead(
        	FirstName = 'ABC Test',
            LastName = 'Master Lead 1',
            Company = 'EZ',
            Email = 'abctest.lead1@ez.com',
            RecordTypeId = leadRecordType,
            Active__c = true
        );
        leadsList.add(lead1);
        
        Lead lead2 = new Lead(
        	FirstName = 'ABC Test',
            LastName = 'Duplicate Lead 2',
            Company = 'EZ',
            Email = 'abctest.lead1@ez.com',
            RecordTypeId = leadRecordType,
            Active__c = true,
            Message__c = 'Message Lead'
        );
        leadsList.add(lead2);
        
        insert leadsList;
        
		TriggerHandler.skipTrigger = false;
    }

    /** 
     * @description To test the Apex Class - AppendFieldValues
     */
    @isTest
    static void testConcatenateFieldValues() {
        
        Lead masterLead = [SELECT Id, FirstName, LastName, Email, Company, Message__c FROM Lead WHERE Email = 'testlead@testlead.com'];
        Contact contact = [SELECT Id, FirstName, LastName, Email, AccountId, Message__c FROM Contact WHERE Email = 'testcontact@testcontact.com'];
        Campaign c = [SELECT Id, Name, Calculate_Message__c FROM Campaign WHERE Name = 'Test Campaign'];
        
        List<Child_Lead__c> childLeadList = [SELECT Id, Name, Email__c, Message__c, Is_Existing_Contact_Lead__c, Related_Master_Lead__c, Related_Contact__c FROM Child_Lead__c WHERE Related_Master_Lead__c=:masterLead.Id OR Related_Contact__c=:contact.Id];
        
        Child_Lead__c childLead1 = childLeadList[0];
        Child_Lead__c childLead2 = childLeadList[1];
        Child_Lead__c childLead3 = childLeadList[2];
        
        // Create a Request object
      	List<AppendFieldValues.Request> requests = new List<AppendFieldValues.Request>();
        AppendFieldValues.Request request1 = new AppendFieldValues.Request();
        request1.campaignRecord = c;
        request1.masterLeadRecord = masterLead;
        request1.childLeadRecord = childLead1;
        requests.add(request1);
        
        AppendFieldValues.Request request2 = new AppendFieldValues.Request();
        request2.campaignRecord = c;
        request2.contactRecord = contact;
        request2.childLeadRecord = childLead2;
        requests.add(request2);
        
        AppendFieldValues.Request request3 = new AppendFieldValues.Request();
        request3.campaignRecord = c;
        request3.contactRecord = contact;
        request3.childLeadRecord = childLead3;
        requests.add(request3);

        // Call the concatenateFieldValues method
        List<AppendFieldValues.Response> responses = AppendFieldValues.concatenateFieldValues(requests);
        
        // Verify that the Child Lead object has been updated correctly
        System.assertEquals(responses[0].childLead.Message__c != null, true);
        System.assertEquals(responses[1].childLead.Message__c != null, true);
        System.assertEquals(responses[2].childLead.Message__c != null, true);

        // Verify that the Response object has been created correctly
        System.assertEquals(childLead1.Id, responses[0].childLead.Id);
        System.assertEquals(childLead2.Id, responses[1].childLead.Id);
        System.assertEquals(childLead3.Id, responses[2].childLead.Id);        
    }
    
    /** 
     * @description To test the Apex Class - AppendTextOrTextAreaFieldValues
     */
    @isTest
    static void concatenatedValueTest(){
        Lead masterLead = [SELECT Id, FirstName, LastName, Email, Company, Message__c FROM Lead WHERE Email = 'testlead@testlead.com'];
        Contact contact = [SELECT Id, FirstName, LastName, Email, AccountId, Message__c FROM Contact WHERE Email = 'testcontact@testcontact.com'];
        Campaign c = [SELECT Id, Name, Calculate_Message__c FROM Campaign WHERE Name = 'Test Campaign'];
        
        List<Child_Lead__c> childLeadList = [SELECT Id, Name, Email__c, Message__c, Is_Existing_Contact_Lead__c, Related_Master_Lead__c, Related_Contact__c FROM Child_Lead__c WHERE Related_Master_Lead__c=:masterLead.Id OR Related_Contact__c=:contact.Id];
        
        Child_Lead__c childLead1 = childLeadList[0];
        Child_Lead__c childLead2 = childLeadList[1];
        Child_Lead__c childLead3 = childLeadList[2];
        
        // Create a Request object
      	List<AppendTextOrTextAreaFieldValues.Request> requests = new List<AppendTextOrTextAreaFieldValues.Request>();
        AppendTextOrTextAreaFieldValues.Request request1 = new AppendTextOrTextAreaFieldValues.Request();
        request1.isCalculationRequired = c.Calculate_Message__c;
        request1.sourceField = masterLead.Message__c;
        request1.targetField = childLead1.Message__c;
        requests.add(request1);
        
        AppendTextOrTextAreaFieldValues.Request request2 = new AppendTextOrTextAreaFieldValues.Request();
        request2.isCalculationRequired = c.Calculate_Message__c;
        request2.sourceField = contact.Message__c;
        request2.targetField = childLead2.Message__c;
        requests.add(request2);
        
        AppendTextOrTextAreaFieldValues.Request request3 = new AppendTextOrTextAreaFieldValues.Request();
        request3.isCalculationRequired = c.Calculate_Message__c;
        request3.sourceField = contact.Message__c;
        request3.targetField = childLead3.Message__c;
        requests.add(request3);

        // Call the concatenateFieldValues method
        List<AppendTextOrTextAreaFieldValues.Response> responses = AppendTextOrTextAreaFieldValues.concatenateFieldValues(requests);
        
        // Verify that the Child Lead object has been updated correctly
        System.assertEquals(responses[0].concatenatedValue != null && responses[0].concatenatedValue != request1.targetField, true);
        System.assertEquals(responses[1].concatenatedValue != null && responses[1].concatenatedValue != request2.targetField, true);
        System.assertEquals(responses[2].concatenatedValue != null && responses[2].concatenatedValue != request3.targetField, true);
    }
    
    /** 
     * @description To test the Apex Class - GenerateTimeStamp
     */
    @isTest
    static void generateTimeStampTest(){
        String inputTimeStamp;
        List<GenerateTimeStamp.Request> requests = new List<GenerateTimeStamp.Request>();
        GenerateTimeStamp.Request request = new GenerateTimeStamp.Request();
        request.timeStamp = inputTimeStamp;
        requests.add(request);
        
        List<GenerateTimeStamp.Response> responses = GenerateTimeStamp.getTimeStamp(requests);
        system.assertEquals(responses[0].timeStamp != null, true);        
    }
    
    /** 
     * @description To test the Apex Class - MergeLeads - Positive Test
     */
    @isTest
    static void mergeLeadsSuccessTest(){
        Lead masterLead;
        Lead duplicateLead;
        for(Lead ld : [SELECT Id, Active__c, FirstName, LastName, Email, Message__c FROM Lead WHERE LastName = 'Master Lead 1' OR LastName = 'Duplicate Lead 2']){
            if(ld.LastName == 'Master Lead 1'){
                masterLead = ld;
            }else if(ld.LastName == 'Duplicate Lead 2'){
                duplicateLead = ld;
            }
        }
        
        List<MergeLeads.Request> requests = new List<MergeLeads.Request>();
        MergeLeads.Request request = new MergeLeads.Request();
        request.masterRecord = masterLead;
        request.duplicateRecord = duplicateLead;
        requests.add(request);
        
        List<MergeLeads.Response> responses = MergeLeads.mergeLeadRecords(requests);
        system.assertEquals(responses[0].mergedSuccessfully, true);
        system.assertEquals(responses[0].mergeError, 'Leads has been merged successfully.');
    }
    
    /** 
     * @description To test the Apex Class - MergeLeads - Negative Test
     */
     @isTest
    static void mergeLeadsFailedTest(){
        Lead masterLead;
        Lead duplicateLead;
        for(Lead ld : [SELECT Id, Name, Active__c, FirstName, LastName, Email, Message__c FROM Lead WHERE LastName = 'Master Lead 1' OR LastName = 'Duplicate Lead 2']){
            if(ld.LastName == 'Master Lead 1'){
                masterLead = ld;
            }else if(ld.LastName == 'Duplicate Lead 2'){
                duplicateLead = ld;
            }
        }
        
        List<MergeLeads.Request> requests = new List<MergeLeads.Request>();
        MergeLeads.Request request = new MergeLeads.Request();
        request.masterRecord = masterLead;
        request.duplicateRecord = duplicateLead;
        requests.add(request);
        
        List<MergeLeads.Response> responses = MergeLeads.mergeLeadRecords(requests);
        system.assertEquals(responses[0].mergedSuccessfully, false);
    }
    
    /** 
     * @description To test the Apex Class - CompareMultiPickistValues
     */
    @isTest
    static void compareMultiPicklistValuesTest(){
        Campaign camp = [SELECT Id, Name, Documents_Downloaded__c, Sample_Requested__c, Trending_Applications_2021__c FROM Campaign 
                         WHERE Name = 'Test Campaign'];
        
        Lead leadRec = [SELECT Id, Name, Documents_Downloaded__c, Sample_Requested__c, Trending_Applications_2021__c FROM Lead
                       WHERE Name = 'Test Lead'];
        
        Contact conRec = [SELECT Id, Name, Documents_Downloaded__c, Sample_Requested__c, Trending_Applications_2021__c FROM Contact 
                          WHERE Name = 'Test Contact'];
        
        Child_Lead__c childLead1;
        Child_Lead__c childLead2;
        for(Child_Lead__c childLead : [SELECT Id, Name, Last_Name__c, Documents_Downloaded__c, Sample_Requested__c, Trending_Applications_2021__c FROM Child_Lead__c 
                                       WHERE Last_Name__c = 'Child Lead 1' OR Last_Name__c = 'Child Lead 2'])
        {
            if(childLead.Last_Name__c == 'Child Lead 1'){
                childLead1 = childLead;
            }else if(childLead.Last_Name__c == 'Child Lead 2'){
                childLead2 = childLead;
            }
        }
        
        List<CompareMultiPickistValues.Request> requests = new List<CompareMultiPickistValues.Request>();
        CompareMultiPickistValues.Request req1 = new CompareMultiPickistValues.Request();
        req1.picklistA = camp.Documents_Downloaded__c;
        req1.picklistB = leadRec.Documents_Downloaded__c;
        requests.add(req1);
        
        CompareMultiPickistValues.Request req2 = new CompareMultiPickistValues.Request();
        req2.picklistA = camp.Sample_Requested__c;
        req2.picklistB = leadRec.Sample_Requested__c;
        requests.add(req2);
        
        CompareMultiPickistValues.Request req3 = new CompareMultiPickistValues.Request();
        req3.picklistA = camp.Trending_Applications_2021__c;
        req3.picklistB = leadRec.Trending_Applications_2021__c;
        requests.add(req3);
        
        CompareMultiPickistValues.Request req4 = new CompareMultiPickistValues.Request();
        req4.picklistA = camp.Documents_Downloaded__c;
        req4.picklistB = conRec.Documents_Downloaded__c;
        requests.add(req4);
        
        CompareMultiPickistValues.Request req5 = new CompareMultiPickistValues.Request();
        req5.picklistA = camp.Sample_Requested__c;
        req5.picklistB = conRec.Sample_Requested__c;
        requests.add(req5);
        
        CompareMultiPickistValues.Request req6 = new CompareMultiPickistValues.Request();
        req6.picklistA = camp.Trending_Applications_2021__c;
        req6.picklistB = conRec.Trending_Applications_2021__c;
        requests.add(req6);
        
        List<CompareMultiPickistValues.Response> responses = CompareMultiPickistValues.execute(requests);
        system.assertEquals(childLead1.Documents_Downloaded__c, responses[0].commonValues);
        system.assertEquals(childLead1.Sample_Requested__c, responses[1].commonValues);
        system.assertEquals(childLead1.Trending_Applications_2021__c, responses[2].commonValues);
        system.assertEquals(childLead2.Documents_Downloaded__c, responses[3].commonValues);
        system.assertEquals(childLead2.Sample_Requested__c, responses[4].commonValues);
        system.assertEquals(childLead2.Trending_Applications_2021__c, responses[5].commonValues);
        
    }
}