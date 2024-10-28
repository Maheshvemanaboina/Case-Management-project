/**
 * Created by Michal Kwika on 25.10.2019.
 * 
 * History
 * 2021-02-12    Sibananda Bhuyan     Updated Class to change AccountId as per new Account Design for Contact & Opportunity
 */
@isTest
public with sharing class QuoteLineActionHandlerTest {
    @testSetup
    private static void testSetup(){
        TriggerHandler.skipTrigger = True;
        Global_Automation_Setting__c setting = Global_Automation_Setting__c.getInstance();
        setting.Skip_Apex_Trigger__c    = true;
        setting.Skip_Process_Builder__c = true;
        setting.Skip_Validation_Rule__c = true;
        upsert setting;

        // Create a sample user //
        User sampleUser = DataFactoryTest.getCPQstdUser();
        System.runAs( new User(Id = UserInfo.getUserId()) ) {
            insert sampleUser;
            PermissionSetAssignment[] assignments = new PermissionSetAssignment[]{};
            for ( PermissionSet permissionSet : DataFactoryTest.getCPQpermissions() ) {
                assignments.add(new PermissionSetAssignment(
                        PermissionSetId = permissionSet.Id,
                        AssigneeId      = sampleUser.Id
                ));
            }
            insert assignments;
        }

        // Create a sample product //
        Product2 sampleProduct = DataFactoryTest.getProductSKUs( 1 )[ 0 ];
        sampleProduct.Product_Code__c = '000000000000094500';
        sampleProduct.RecordTypeId = DataFactoryTest.getRecordTypeByDeveloperName( Schema.SObjectType.Product2 ).get( DataFactoryTest.PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId();
        Database.insert( sampleProduct );

        // Create a sample account //
        Account sampleAccount = DataFactoryTest.getAccountCommercialCustomers( 1 )[ 0 ];
        sampleAccount.OwnerId       = sampleUser.Id;
        sampleAccount.SAP_Number__c = '0000100655';
        sampleAccount.Active__c=true;
        Database.insert( sampleAccount );

        //Sibananda - Added below to retreive customer location to associate it with Contact and Opportunity as per the new Account design

        Account testCustomerLocation = DataFactoryTest.getAccountCustomerLocations(1)[0];
        testCustomerLocation.ParentId = sampleAccount.Id;
        testCustomerLocation.Active__c=true;
        testCustomerLocation.Partner_Role__c='Sold-to';
        Database.insert( testCustomerLocation );

        // Create a sample contact //
        Contact sampleContact = DataFactoryTest.getContacts( 1 )[ 0 ];
        sampleContact.OwnerId   = sampleUser.Id;
        //sampleContact.AccountId = sampleAccount.Id;
        sampleContact.AccountId = testCustomerLocation.Id;
        sampleContact.Active__c=true;
        Database.insert( sampleContact );

        // Create a sample opportunity //
        Opportunity sampleOpportunity = DataFactoryTest.getOpportunityNewBusinesses( 1 )[ 0 ];
        sampleOpportunity.OwnerId   = sampleUser.Id;
        //sampleOpportunity.AccountId = sampleAccount.Id;
        sampleOpportunity.AccountId = testCustomerLocation.Id;
        sampleOpportunity.ContactId = sampleContact.Id;
        sampleOpportunity.StageName = 'Prospecting';
        sampleOpportunity.Reason_Won_Lost__c = '';
        Database.insert( sampleOpportunity );

        // create a CMO user
        List<User> usersToInsert = new List<User>();
        User usr = new User (
                ProfileID = [Select Id From Profile Where Name = 'Standard CPQ User Profile'].id,
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                FirstName = 'first',
                LastName = 'last',
                Username = TestUtility.generateRandomUserName() + 'TestIMCDPoland',
                Country = 'Italy',
                Alias = 't1',
                Email = 'no@email.com',
                IsActive = true,
                Friesland_Campina_Role__c = 'CMO'
        );
        usersToInsert.add(usr);
        insert usersToInsert;

        // Create a sample quote with a group and line items //
        SBQQ__Quote__c quote = DataFactoryTest.createQuote( sampleOpportunity, new Product2[]{sampleProduct} );
        quote.CMO__c = usr.Id;
        quote.Payment_Terms__c = 'Z012';
        quote.SBQQ__Status__c = 'Sent to customer';
        //quote.Reason_Opportunity_Won_Loss__c = 'Strong Relationship';

        SBQQ__QuoteLineGroup__c firstLineGroup = [select Id, Name, SBQQ__Quote__c, Mode_of_Transport__c, IncoTerms__c, IncoTermsDestination__c, SBQQ__StartDate__c, SBQQ__EndDate__c from SBQQ__QuoteLineGroup__c where Name='Group 1'];
        firstLineGroup.Mode_of_Transport__c    = 'Sea';
        firstLineGroup.IncoTerms__c            = 'CIP';
        firstLineGroup.IncoTermsDestination__c = 'Amsterdam Schiphol';
        firstLineGroup.SBQQ__StartDate__c      = System.today().addMonths(2);
        firstLineGroup.SBQQ__EndDate__c        = System.today().addMonths(3);
        firstLineGroup.Ship_To_Customer__c     = testCustomerLocation.Id;
        update firstLineGroup;

        update quote;
        //insert Partner Role Ship To in DB (sample) and Agent Role
        DataFactoryTest.insertPartnerRole(sampleAccount.Id, sampleAccount.Id, CPQUtility.SHIP_TO);
        DataFactoryTest.insertPartnerRole(sampleAccount.Id, sampleAccount.Id, CPQUtility.AGENT);

        // Create a custom setting to enable automation log processing and triggers //
        insert new Global_Automation_Setting__c( Skip_Apex_Trigger__c = false );
        TriggerHandler.skipTrigger = false;
    }

    @isTest
    private static void checkRecordTypeNameField(){
        List<SBQQ__QuoteLine__c> sampleLines=  [SELECT  Name, Product_RecordType_DeveloperName__c  FROM SBQQ__QuoteLine__c LIMIT 1];

        System.assertEquals(null, sampleLines.get(0).Product_RecordType_DeveloperName__c);

        Test.startTest();
        List<String> lRecordStrings  = new List<String>{sampleLines.get(0).Id};
        QuoteLineActionHandler.updateRTInformationOnQuoteLine(lRecordStrings);
        Test.stopTest();

        List<SBQQ__QuoteLine__c> linesAfterUpdateOfRT=  [SELECT  Name, Product_RecordType_DeveloperName__c  FROM SBQQ__QuoteLine__c LIMIT 1];
        System.assertNotEquals(null, linesAfterUpdateOfRT.get(0).Product_RecordType_DeveloperName__c);
    }
}