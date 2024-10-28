@isTest
public without sharing class DistributorAddRelatedLocationTest {
    
    @TestSetup
    static void makeData(){
        
        TriggerHandler.skipTrigger = true;

        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'FCI' Limit 1];

        /* create Internal Users */
        List<User> internalUsersToInsert = new List<User>();
        User FCIUser1 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser1', 'System Administrator');
        FCIUser1.UserRoleId = userrole.Id;
        internalUsersToInsert.add(FCIUser1);

        User FCIUser2 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'FCIUser2', 'System Administrator');
        FCIUser2.UserRoleId = userrole.Id;
        internalUsersToInsert.add(FCIUser2);
        insert internalUsersToInsert;

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
            Contact cManager = TestUtility.createContact(commercialCust, customerLocItaly);
            contactsToInsert.add(cManager);
            insert contactsToInsert;

            List<User> usersToInsert = new List<User>();
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

            TriggerHandler.skipTrigger = false;

            /* Create Master Commercial Activity Record to hold all bucket records */
            Commercial_Activity__c masterCommercialActivity = CommunityKPITestUtility.createCommercialActivityMaster(customerLocItaly);
            masterCommercialActivity.Name = 'Commercial Activity - 2022';
            insert masterCommercialActivity;

            Other_Related_Customer_Location__c otherRelLoc = new Other_Related_Customer_Location__c(
                Distributor_Location__c = customerLocFrance.Id,
                Related_Commercial_Activity__c = masterCommercialActivity.Id
            );
            insert otherRelLoc;

        }
    }

    @isTest
    static void shouldCreateRelatedLocationProperly(){

        Commercial_Activity__c commActMaster = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Commercial Activity - 2022'];
        Account custLocItaly = [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa'];
        User usrManager = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDManager%'];

        Boolean isSuccessfullyInserted;
        System.runAs(usrManager){

            isSuccessfullyInserted = DistributorAddRelatedLocationController.createRelatedLocation('2022', 'Commercial_Activity__c', custLocItaly.Id, 'Related_Commercial_Activity__c', 'Commercial Activity');
        }        
    }

    @isTest
    static void shouldNotCreateRelatedLocationIfnoMasterExist(){

        Commercial_Activity__c commActMaster = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Commercial Activity - 2022'];
        Account custLocItaly = [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa'];
        User usrManager = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDManager%'];

        Boolean isSuccessfullyInserted;
        System.runAs(usrManager){

            isSuccessfullyInserted = DistributorAddRelatedLocationController.createRelatedLocation('2023' /* Passing wrong value, where bucket does not exist */, 'Commercial_Activity__c', custLocItaly.Id, 'Related_Commercial_Activity__c', 'Commercial Activity');
        }

        List<Other_Related_Customer_Location__c> othRel = [SELECT Id, Distributor_Location__c, Related_Commercial_Activity__c FROM Other_Related_Customer_Location__c WHERE Distributor_Location__c =: custLocItaly.Id];
        System.assert(!isSuccessfullyInserted);
        System.assertEquals(0, othRel.size(), 'No related location created');
    }

    @isTest
    static void shouldReturnExistingRelatedLocations(){

        Commercial_Activity__c commActMaster = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Commercial Activity - 2022'];
        Account custLocItaly = [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa'];
        User usrManager = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDManager%'];

        List<SObject> relatedLocationList;
        System.runAs(usrManager){

            relatedLocationList = DistributorAddRelatedLocationController.fetchExistingRelatedLocations('2022', 'Commercial_Activity__c', 'Commercial Activity', 'Related_Commercial_Activity__r');
        }

        List<Other_Related_Customer_Location__c> othRel = [SELECT Id, Distributor_Location__c, Related_Commercial_Activity__c FROM Other_Related_Customer_Location__c];
        System.assertEquals(1, othRel.size(), '1 Related exist');
    }

    @isTest
    static void shouldDeleteOtherRelatedDate(){

        Commercial_Activity__c commActMaster = [SELECT Id FROM Commercial_Activity__c WHERE Name = 'Commercial Activity - 2022'];
        Account custLocItaly = [SELECT Id FROM Account WHERE Name = 'IMCD Italy Spa'];
        User usrManager = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDManager%'];

        List<Other_Related_Customer_Location__c> othRelLoc1 = [SELECT Id, Distributor_Location__c, Related_Commercial_Activity__c FROM Other_Related_Customer_Location__c];
        System.runAs(usrManager){

            DistributorAddRelatedLocationController.deleteRecords(othRelLoc1.get(0).Id);
        }

        List<Other_Related_Customer_Location__c> othRelLoc2 = [SELECT Id, Distributor_Location__c, Related_Commercial_Activity__c FROM Other_Related_Customer_Location__c];
        System.assertEquals(0, othRelLoc2.size(), 'No related location exist as it is deleted');
    }

}