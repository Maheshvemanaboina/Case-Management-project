/*------------------------------------------------------------
Author:       Lilith Van Biesen
Company:      Waeg
Description:  Test Class for BoMViewController.

History
v1.0       2019-11-14    Lilith Van Biesen    Created class
v2.0       2021-02-11    Sibananda Bhuyan     Updated Class to change AccountId as per new Account Design for Contact & Opportunity
------------------------------------------------------------*/

@isTest
public with sharing class BoMViewControllerTest {
    
    @testSetup
    private static void setup() {
        Global_Automation_Setting__c setting = Global_Automation_Setting__c.getInstance();
        setting.Skip_Apex_Trigger__c    = true;
        setting.Skip_Process_Builder__c = true;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;
        
        CpqDisableTriggers.cpqDisableTriggers();
        
        // Create a test user //
        User testUser = DataFactoryTest.getCPQstdUser();
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
            insert testUser;
            PermissionSetAssignment[] assignments = new PermissionSetAssignment[]{};
            for ( PermissionSet permissionSet : DataFactoryTest.getCPQpermissions() ) {
                assignments.add(new PermissionSetAssignment(
                        PermissionSetId = permissionSet.Id,
                        AssigneeId      = testUser.Id
                ));
            }
            insert assignments;
        }
        
        // Create a test account //
        Account testAccount = DataFactoryTest.getAccountCommercialCustomers(1)[0];
        testAccount.OwnerId = testUser.Id;
        
        Database.insert( testAccount );

        //Sibananda - Added below to retreive customer location to associate it with Contact and Opportunity as per the new Account design

        Account testCustomerLocation = DataFactoryTest.getAccountCustomerLocations(1)[0];
        testCustomerLocation.ParentId = testAccount.Id;
        //testCustomerLocation.SAP_Number__c = '0000100655';
        //testCustomerLocation.SAP_Number_PE1__c = '0000100655';
        testCustomerLocation.Active__c=true;  
        testCustomerLocation.Partner_Role__c='Sold-to';
        Database.insert( testCustomerLocation ); 

        // Create a test contact //
        Contact testContact = DataFactoryTest.getContacts(1)[0];
        testContact.OwnerId   = testUser.Id;
        //testContact.AccountId = testAccount.Id;
        testContact.AccountId = testCustomerLocation.Id;
        Database.insert( testContact );

        // Create a test opportunity //
        Opportunity testOpportunity = DataFactoryTest.getOpportunityNewBusinesses(1)[0];
        testOpportunity.OwnerId   = testUser.Id;
        //testOpportunity.AccountId = testAccount.Id;
        testOpportunity.AccountId = testCustomerLocation.Id;
        testOpportunity.ContactId = testContact.Id;
        testOpportunity.StageName = 'Prospecting';
        testOpportunity.Reason_Won_Lost__c = '';
        Database.insert( testOpportunity );
        
        // Create test products //
        List<Product2> testProduct2List	= DataFactoryTest.getProductSKUs(2);
        
        List<RecordType> recordtypes = [SELECT Id FROM RecordType WHERE DeveloperName = :BoMViewController.PRODUCT_MATERIAL_RECORD_TYPE_DEVELOPER_NAME];
        testProduct2List[0].RecordTypeId = recordtypes[0].Id;
        
        Database.insert( testProduct2List );

        // Create a test quote with a group and line items //
        SBQQ__Quote__c testQuote = DataFactoryTest.createQuote(testOpportunity, testProduct2List);
        
        List<SBQQ__QuoteLine__c> testQuoteLines = [
            SELECT Id, SBQQ__RequiredBy__c, Product_RecordType_DeveloperName__c, SBQQ__Product__r.RecordType.DeveloperName
            FROM SBQQ__QuoteLine__c
        ];
        
        integer skuIndex = 0;
        integer materialIndex = 0;
        
        for(integer i = 0; i < testQuoteLines.size(); i++){
            testQuoteLines[i].Product_RecordType_DeveloperName__c = testQuoteLines[i].SBQQ__Product__r.RecordType.DeveloperName;
            if(testQuoteLines[i].Product_RecordType_DeveloperName__c == BoMViewController.PRODUCT_MATERIAL_RECORD_TYPE_DEVELOPER_NAME){
                materialIndex = i;
            } else {
                skuIndex = i;
            }
        }
        
        //testQuoteLines[materialIndex].SBQQ__RequiredBy__c = testQuoteLines[skuIndex].Id;
        update testQuoteLines;
        
        CpqEnableTriggers.cpqEnableTriggers();
        
        setting = Global_Automation_Setting__c.getInstance();
        setting.Skip_Apex_Trigger__c    = false;
        setting.Skip_Process_Builder__c = false;
        setting.Skip_Validation_Rule__c = false;
        upsert setting;
    }
    
    public static testMethod void testGetParentQuoteLine() {
        List<SBQQ__QuoteLine__c> testQuoteLines = [
            SELECT Id, SBQQ__RequiredBy__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__RequiredBy__c = null
        ]; 
        
        Test.startTest();
        
        //Retrieve fields from the parent Quote Line based on its Id.
        SBQQ__QuoteLine__c result = BoMViewController.getParentQuoteLine(testQuoteLines[0].Id);
        //Verify that a record was found.
        System.assertNotEquals(null, result);
        
        Test.stopTest();
    }
    
    public static testMethod void testGetChildQuoteLines() {
        List<SBQQ__QuoteLine__c> testQuoteLines = [
            SELECT Id, SBQQ__RequiredBy__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__RequiredBy__c = null
        ]; 
        
        Test.startTest();
        
        //Retrieve child Quote Line records based on the parent's Id.
        List<SBQQ__QuoteLine__c> results = BoMViewController.getChildQuoteLines(testQuoteLines[0].Id);
        
        Test.stopTest();
    }
    


}