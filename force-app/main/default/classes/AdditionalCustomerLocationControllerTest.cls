@isTest
public class AdditionalCustomerLocationControllerTest {
    @TestSetup
    static void testData(){
        //TriggerHandler.skipTrigger = true;
        
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'FCI' Limit 1];
        
        /* create Internal Users */
        List<User> internalUsersToInsert = new List<User>();
        User FCIUser1 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser1', 'System Administrator');
        FCIUser1.UserRoleId = userrole.Id;
        internalUsersToInsert.add(FCIUser1);
        
        System.runAs(FCIUser1){
            
            /* Creates H1 */
            Account commercialCust = TestUtility.createAccount('IMCD Holding');
            insert commercialCust;
            
            /* Creates H5 which is the Distributor Location */
            List<Account> accsToInsert = new List<Account>();
            Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
            customerLocItaly.OwnerId = FCIUser1.Id;
            accsToInsert.add(customerLocItaly);
            
            Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
            customerLocFrance.OwnerId = FCIUser1.Id;
            accsToInsert.add(customerLocFrance);
            
            insert accsToInsert;
            
            /* Create Contacts under H5, these contacts will be Distributors */
            List<Contact> contactsToInsert = new List<Contact>();
            Contact cItalyStd = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cItalyStd);
            
            Contact cManager = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cManager);
            insert contactsToInsert;
            
            List<User> usersToInsert = new List<User>();
            User usrItalyStandard = TestUtility.createUser('testItalyStdUsr@fci.com', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrItalyStandard.ContactId = cItalyStd.Id;
            usersToInsert.add(usrItalyStandard);
            
            User usrManager = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
            usrManager.ContactId = cManager.Id;
            usersToInsert.add(usrManager);
            
            insert usersToInsert;
            
            /* Create Share for Partner contacts for their own accounts */
            List<AccountShare> accShares = new List<AccountShare>();
            accShares.add(AccountSharingUtility.getAccountShare(customerLocItaly.Id, usrManager.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(commercialCust.Id, usrManager.Id, 'READ', 'Manual'));
            accShares.add(AccountSharingUtility.getAccountShare(customerLocFrance.Id, usrManager.Id, 'READ', 'Manual'));
            
            insert accShares;
            
            //TriggerHandler.skipTrigger = false;
        }
        
    }
    
    @isTest
    static void createAdditionalCustomerLocationTest(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'IMCD France Spa'];
        Contact con = [SELECT Id FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE UserName = 'testItalyStdUsr@fci.com')];
        
        Other_Related_Customer_Location__c orcl = new Other_Related_Customer_Location__c();
        orcl.Related_Contact__c = con.Id;
        orcl.Additional_Customer_Location__c = acc.Id;
        
        Test.startTest();
        AdditionalCustomerLocationController.isContactEnabledAsPartner(con.Id);
        AdditionalCustomerLocationController.insertOrUpdateAdditionalCustomerLocation(orcl);
        AdditionalCustomerLocationController.getAllAdditionalCustomerLocations(con.Id);
        
        //Query for the Additional Customer location that needs to be deleted
        Other_Related_Customer_Location__c custLoc = [SELECT Id,Related_Contact__c,Additional_Customer_Location__c
                                                   FROM Other_Related_Customer_Location__c
                                                   WHERE Related_Contact__c=:con.Id AND
                                                   Additional_Customer_Location__c=:acc.Id AND
                                                   RecordTypeId =: KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID];
        AdditionalCustomerLocationController.deleteSelectedAdditionalCustomerLocation(custLoc.Id);
        Test.stopTest();
    }
}