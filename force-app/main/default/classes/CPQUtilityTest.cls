/*------------------------------------------------------------
Author:       Lilith Van Biesen
Company:      Waeg
Description:  Tests the class CPQUtility

History
2019-12-04    Lilith Van Biesen    Created test class
2021-02-11    Sibananda Bhuyan     Updated Class to change AccountId as per new Account Design
------------------------------------------------------------*/
@isTest
private class CPQUtilityTest {

    // TEST SETUP //

    /*------------------------------------------------------------
    Author:       Lilith Van Biesen
    Company:      Waeg
    Description:  Sets up sample data to be used for testing

    History:
    2019-12-04    Lilith Van Biesen    Created method
    ------------------------------------------------------------*/
    @testSetup
    private static void testSetup() {
        // Disable all automations //
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
        
        // Create test accounts //
        List<Account> testAccounts = DataFactoryTest.getAccountCommercialCustomers(2);
        testAccounts[0].OwnerId = testAccounts[1].OwnerId = testUser.Id;
        Database.insert( testAccounts );
        
        // Create a test partner role //
        DataFactoryTest.insertPartnerRole(testAccounts[0].Id, testAccounts[1].Id, 'Sold To');
        
        //Sibananda - Added below to retreive customer location to associate it with Contact and Opportunity as per the new Account design

        List<Account> testCustomerLocations = DataFactoryTest.getAccountCustomerLocations(1);
        testCustomerLocations[0].ParentId = testAccounts[0].Id;
        testCustomerLocations[0].active__c =true;
      	testCustomerLocations[0].partner_role__c ='Sold-to';
        Database.insert( testCustomerLocations ); 

         // Create a test contact //
        Contact testContact = DataFactoryTest.getContacts(1)[0];
        testContact.OwnerId   = testUser.Id;
        //testContact.AccountId = testAccounts[0].Id;
        testContact.AccountId = testCustomerLocations[0].Id;
        Database.insert( testContact );

        // Create a test opportunity //
        Opportunity testOpportunity = DataFactoryTest.getOpportunityNewBusinesses(1)[0];
        testOpportunity.OwnerId   = testUser.Id;
        //testOpportunity.AccountId = testAccounts[0].Id;
        testOpportunity.AccountId = testCustomerLocations[0].Id;
        testOpportunity.ContactId = testContact.Id;
        testOpportunity.StageName='Prospecting';
        testOpportunity.Reason_Won_Lost__c='';
        Database.insert( testOpportunity );
        
        // Create a test product //
        Product2 testProduct = DataFactoryTest.getProductSKUs(1)[0];
        
        Database.insert( testProduct);

        // Create a test quote with a group and line items //
        SBQQ__Quote__c testQuote = DataFactoryTest.createQuote(testOpportunity, new Product2[]{testProduct});
        
        // Re-enable some automations //
        setting.Skip_Apex_Trigger__c    = false;
        setting.Skip_Process_Builder__c = false;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;
        CpqEnableTriggers.cpqEnableTriggers();
    }
    
    public static testMethod void testGetMapPartnerRolesByRelationNameIds() {
        
        Test.startTest();
        //Retrieve partner roles with this relation name
        Map<Id, Partner_Role__c> results = CPQUtility.getMapPartnerRolesByRelationNameIds('Sold To');
        
        //Verify that a record was found.
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
    
    public static testMethod void testGetMapPartnerRolesByRelationNameAndSourceIds() {
        List<Partner_Role__c> partnerRoles = [SELECT Source_Account__c FROM Partner_Role__c];
        Set<Id> accountSet = new Set<Id>{partnerRoles[0].Source_Account__c};
        
        Test.startTest();
        //Retrieve partner roles with this relation name and source account
        Map<Id, Partner_Role__c> results = CPQUtility.getMapPartnerRolesByRelationNameAndSourceIds(accountSet, 'Sold To');
        
        //Verify that a record was found.
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
    
    public static testMethod void testGetSetOfAllSoldTosForQuoteLineGroups() {
        //public static Set<Id> getSetOfAllSoldTosForQuoteLineGroups(List<SBQQ__QuoteLineGroup__c> listQuoteLineGroups){
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = [SELECT Id, SBQQ__Account__c FROM SBQQ__QuoteLineGroup__c];
        
        Test.startTest();
        //Create a set of accounts from these quote line groups
        Set<Id> results = CPQUtility.getSetOfAllSoldTosForQuoteLineGroups(quoteLineGroups);
        
        //Verify that a record was found.
        System.assertEquals(1, results.size());
        
        Test.stopTest();
    }
}