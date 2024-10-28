@isTest
public class ChildLeadSharingUtilityTest {
    
    @testSetup
    static void setup() {
        TriggerHandler.skipTrigger = true;
        
        List<Account> accsCustomLocToInsert = new List<Account>();
        Account commercialCust = TestUtility.createAccount('IMCD Holding');
        accsCustomLocToInsert.add(commercialCust);
        
        Account commercialCustDanone = TestUtility.createAccount('Danone SA');
        accsCustomLocToInsert.add(commercialCustDanone);
        insert accsCustomLocToInsert;
        
        List<Account> accsToInsert = new List<Account>();
        Account customerLocItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
        accsToInsert.add(customerLocItaly);
        
        Account customerLocFrance = TestUtility.createCustomerLocation('IMCD France Spa', commercialCust);
        accsToInsert.add(customerLocFrance);
        
        Account customerLocPoland = TestUtility.createCustomerLocation('IMCD Poland Spa', commercialCust);
        accsToInsert.add(customerLocPoland);
        
        Account customerLocDanone = TestUtility.createCustomerLocation('Danone Poland', commercialCustDanone);
        accsToInsert.add(customerLocDanone);
        insert accsToInsert;
        
        List<Contact> contactsToInsert = new List<Contact>();
        Contact cItaly = TestUtility.createContact(commercialCust, customerLocItaly);
        contactsToInsert.add(cItaly);
        
        Contact cFrance = TestUtility.createContact(commercialCust, customerLocFrance);
        contactsToInsert.add(cFrance);
        
        Contact cPoland = TestUtility.createContact(commercialCust, customerLocPoland);
        contactsToInsert.add(cPoland);
        
        Contact cDanonePoland = TestUtility.createContact(commercialCustDanone, customerLocDanone);
        contactsToInsert.add(cDanonePoland);
        
        Contact cManager = TestUtility.createContact(commercialCust, customerLocFrance);
        contactsToInsert.add(cManager);
        insert contactsToInsert;
        
        List<User> usersToInsert = new List<User>();
        User usrItaly = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrItaly.ContactId = cItaly.Id;
        usersToInsert.add(usrItaly);
        
        User usrFrance = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDFrance', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrFrance.ContactId = cFrance.Id;
        usersToInsert.add(usrFrance);
        
        User usrPoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDPoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrPoland.ContactId = cPoland.Id;
        usersToInsert.add(usrPoland);
        
        User usrDanonePoland = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestDanonePoland', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrDanonePoland.ContactId = cDanonePoland.Id;
        usersToInsert.add(usrDanonePoland);
        
        User usrManager = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE);
        usrManager.ContactId = cManager.Id;
        usersToInsert.add(usrManager);
        
        User usrSysAdmin = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestusrSysAdmin', 'System Administrator');
        usersToInsert.add(usrSysAdmin);
        insert usersToInsert;
        
        final Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Master_Lead').getrecordTypeId();
        final Id partnerLeadRecordTypeId = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('Partner_Child_Lead').getrecordTypeId();
        
        Campaign cmp = new Campaign(); 
        cmp.Business_Segment__c = 'Adult Nutrition';
        cmp.Sub_Segment__c = 'Active Nutrition';
        cmp.Name = 'Test AN Campaign 2023';
        insert cmp;

        List<Lead> leadToInsert = new List<Lead>();
        
        Lead leItaly = TestUtility.createLead('testCompanyItly','testLastNameItaly',customerLocItaly,commercialCust,recordTypeId);
        leItaly.Distributor_Location__c = null;
        leItaly.Distributor__c = null;
        leadToInsert.add(leItaly);

        Lead leFrance = TestUtility.createLead('testCompanyFrance','testLastNameFrance',customerLocFrance,commercialCust,recordTypeId);
        leFrance.Distributor_Location__c = null;
        leFrance.Distributor__c = null;
        leadToInsert.add(leFrance);
        
        Lead lePoland = TestUtility.createLead('testCompanyPoland','testLastNamePolande',customerLocPoland,commercialCust,recordTypeId);
        lePoland.Distributor_Location__c = null;
        lePoland.Distributor__c = null;
        leadToInsert.add(lePoland);
        
        Lead leDanone = TestUtility.createLead('testCompanyDanone','testLastNameDanone',customerLocDanone,commercialCustDanone,recordTypeId);
        leDanone.Distributor_Location__c = null;
        leDanone.Distributor__c = null;
        leadToInsert.add(leDanone);
        insert leadToInsert;
        
        List<Child_Lead__c> childLeadsToInsert = new List<Child_Lead__c>();
        
        Child_Lead__c childLeadItaly = new Child_Lead__c(
            Name = 'LI - '+leadToInsert[0].FirstName+ ' ' +leadToInsert[0].LastName+' - '+cmp.Name,
            First_Name__c = leadToInsert[0].FirstName,
            Last_Name__c = leadToInsert[0].LastName,
            Company__c = leadToInsert[0].Company,
            Email__c = leadToInsert[0].FirstName,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            /*Distributor_Account_Name__c = customerLocItaly.Id,
            Distributor_Parent_Account__c = commercialCust.Id,*/
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = leadToInsert[0].Id
        );
        childLeadsToInsert.add(childLeadItaly);
        
        Child_Lead__c childLeadFrance = new Child_Lead__c(
            Name = 'LI - '+leadToInsert[1].FirstName+ ' ' +leadToInsert[1].LastName+' - '+cmp.Name,
            First_Name__c = leadToInsert[1].FirstName,
            Last_Name__c = leadToInsert[1].LastName,
            Company__c = leadToInsert[1].Company,
            Email__c = leadToInsert[1].FirstName,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            /*Distributor_Account_Name__c = customerLocFrance.Id,
            Distributor_Parent_Account__c = commercialCust.Id,*/
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = leadToInsert[1].Id
        );
        childLeadsToInsert.add(childLeadFrance);
        
        Child_Lead__c childLeadPoland = new Child_Lead__c(
            Name = 'LI - '+leadToInsert[2].FirstName+ ' ' +leadToInsert[2].LastName+' - '+cmp.Name,
            First_Name__c = leadToInsert[2].FirstName,
            Last_Name__c = leadToInsert[2].LastName,
            Company__c = leadToInsert[2].Company,
            Email__c = leadToInsert[2].FirstName,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            /*Distributor_Account_Name__c = customerLocPoland.Id,
            Distributor_Parent_Account__c = commercialCust.Id,*/
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = leadToInsert[2].Id
        );
        childLeadsToInsert.add(childLeadPoland);
        
        Child_Lead__c childLeadDanone = new Child_Lead__c(
            Name = 'LI - '+leadToInsert[3].FirstName+ ' ' +leadToInsert[3].LastName+' - '+cmp.Name,
            First_Name__c = leadToInsert[3].FirstName,
            Last_Name__c = leadToInsert[3].LastName,
            Company__c = leadToInsert[3].Company,
            Email__c = leadToInsert[3].FirstName,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            /*Distributor_Account_Name__c = customerLocDanone.Id,
            Distributor_Parent_Account__c = commercialCust.Id,*/
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = leadToInsert[3].Id
        );
        childLeadsToInsert.add(childLeadDanone);
        
        insert childLeadsToInsert;
        
        TriggerHandler.skipTrigger = false;
    }
    
    @isTest
    static void shouldChangeLeadShareOnDistributorChange() {
        
        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }
        
        Account commercialCust = accsMap.get('IMCD Holding');
        Account commercialCustDanone = accsMap.get('Danone SA');
        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');
        Account customerLocPoland = accsMap.get('IMCD Poland Spa');
        Account customerLocDanone = accsMap.get('Danone Poland');
        
        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly'];
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance'];
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland'];
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland'];
        User usrManager = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManager'];

        Child_Lead__c childLeadFrance = [SELECT Id,Distributor_Account_Name__c FROM Child_Lead__c WHERE Last_Name__c like '%testLastNameFrance%'];
        Child_Lead__c childLeadPoland = [SELECT Id,Distributor_Account_Name__c, Distributor_Parent_Account__c FROM Child_Lead__c WHERE Last_Name__c like '%testLastNamePolande%'];
        
        Test.startTest();
        
        childLeadFrance.Distributor_Account_Name__c = customerLocItaly.Id;
        update childLeadFrance;
        
        Test.stopTest();
        
        List<Child_Lead__Share> childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadFrance.Id) AND UserOrGroupId = :usrItaly.Id AND RowCause = 'Standard_User__c'];
        System.assertEquals(1, childLeadShare.size());
        
        childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadFrance.Id) AND RowCause = 'Standard_User__c'];
        System.assertEquals(1, childLeadShare.size());
        
        childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN ( :childLeadFrance.Id) AND UserOrGroupId IN (:usrFrance.Id,:usrPoland.Id,:usrDanonePoland.Id)];
        System.assertEquals(0, childLeadShare.size());
        
    }
    @isTest
    static void shouldNotChangeLeadShareOnOwnerChange() {
        
        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }
        
        Account commercialCust = accsMap.get('IMCD Holding');
        Account commercialCustDanone = accsMap.get('Danone SA');
        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');
        Account customerLocPoland = accsMap.get('IMCD Poland Spa');
        Account customerLocDanone = accsMap.get('Danone Poland');
        
        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly' AND Contact.AccountId =: customerLocItaly.Id];
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance'];
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland'];
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland'];
        User usrManager = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManager'];
        User usrSysAdmin = [SELECT Id FROM User WHERE Username LIKE '%TestusrSysAdmin'];
        
        Child_Lead__c childLeadFrance = [SELECT Id,Distributor_Account_Name__c,Distributor_Parent_Account__c, OwnerId FROM Child_Lead__c WHERE Last_Name__c like '%testLastNameFrance%'];
        
        Child_Lead__c childLeadPoland = [SELECT Id,Distributor_Account_Name__c,Distributor_Parent_Account__c, OwnerId FROM Child_Lead__c WHERE Last_Name__c like '%testLastNamePolande%'];
        
        Child_Lead__c childLeadItaly = [SELECT Id,Distributor_Account_Name__c,Distributor_Parent_Account__c, OwnerId FROM Child_Lead__c WHERE Last_Name__c like '%testLastNameItaly%'];
        
        Test.startTest();
        
        childLeadItaly.OwnerId = usrSysAdmin.Id ;
        update childLeadItaly;
        
        List<Child_Lead__Share>  childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadItaly.Id) AND UserOrGroupId = :usrItaly.Id AND RowCause = 'Standard_User__c'];
        System.assertEquals(0, childLeadShare.size());
        
        childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadItaly.Id) AND UserOrGroupId = :usrManager.Id AND RowCause = 'Manager_User__c'];
        System.assertEquals(0, childLeadShare.size());
        
        childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadItaly.Id) AND UserOrGroupId IN (:usrFrance.Id,:usrPoland.Id) AND RowCause = 'Standard_User__c'];
        System.assertEquals(0, childLeadShare.size());
        Test.stopTest();
        
    }
    
    @isTest
    static void shouldNotChangeLeadShareOnLeadInsert() {
        
        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }
        
        Account commercialCust = accsMap.get('IMCD Holding');
        Account commercialCustDanone = accsMap.get('Danone SA');
        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');
        Account customerLocPoland = accsMap.get('IMCD Poland Spa');
        Account customerLocDanone = accsMap.get('Danone Poland');
        
        User usrItaly = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDItaly'];
        User usrFrance = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDFrance'];
        User usrPoland = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDPoland'];
        User usrDanonePoland = [SELECT Id FROM User WHERE Username LIKE '%TestDanonePoland'];
        User usrManager = [SELECT Id FROM User WHERE Username LIKE '%TestIMCDManager'];
        User usrSysAdmin = [SELECT Id FROM User WHERE Username LIKE '%TestusrSysAdmin'];
        
        Campaign cmp = [SELECT Id, Name FROM Campaign WHERE Name = 'Test AN Campaign 2023'];
        
        Lead leItaly = [SELECT Id,FirstName, LastName, Company, Email FROM Lead WHERE LastName like '%testLastNameItaly%'];
        Lead leFrance = [SELECT Id,FirstName, LastName, Company, Email FROM Lead WHERE LastName like '%testLastNameFrance%'];
        Lead lePoland = [SELECT Id,FirstName, LastName, Company, Email FROM Lead WHERE LastName like '%testLastNamePolande%'];
        Lead leDanone = [SELECT Id,FirstName, LastName, Company, Email FROM Lead WHERE LastName like '%testLastNameDanone%'];
        
       Id partnerLeadRecordTypeId = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('Partner_Child_Lead').getrecordTypeId();
        
        List<Child_Lead__c> childLeadsToInsert = new List<Child_Lead__c>();
        
        Child_Lead__c childLeadItaly = new Child_Lead__c(
            Name = 'LI - '+leItaly.FirstName+ ' ' +leItaly.LastName+' - '+cmp.Name,
            First_Name__c = leItaly.FirstName,
            Last_Name__c = leItaly.LastName,
            Company__c = leItaly.Company,
            Email__c = leItaly.Email,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            Distributor_Account_Name__c = customerLocItaly.Id,
            Distributor_Parent_Account__c = commercialCust.Id,
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = leItaly.Id
        );
        childLeadsToInsert.add(childLeadItaly);
        
        Child_Lead__c childLeadFrance = new Child_Lead__c(
            Name = 'LI - '+leFrance.FirstName+ ' ' +leFrance.LastName+' - '+cmp.Name,
            First_Name__c = leFrance.FirstName,
            Last_Name__c = leFrance.LastName,
            Company__c = leFrance.Company,
            Email__c = leFrance.Email,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            Distributor_Account_Name__c = customerLocFrance.Id,
            Distributor_Parent_Account__c = commercialCust.Id,
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = leFrance.Id
        );
        childLeadsToInsert.add(childLeadFrance);
        
        Child_Lead__c childLeadPoland = new Child_Lead__c(
            Name = 'LI - '+lePoland.FirstName+ ' ' +lePoland.LastName+' - '+cmp.Name,
            First_Name__c = lePoland.FirstName,
            Last_Name__c = lePoland.LastName,
            Company__c = lePoland.Company,
            Email__c = lePoland.Email,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            Distributor_Account_Name__c = customerLocPoland.Id,
            Distributor_Parent_Account__c = commercialCust.Id,
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = lePoland.Id
        );
        childLeadsToInsert.add(childLeadPoland);
        
        Child_Lead__c childLeadDanone = new Child_Lead__c(
            Name = 'LI - '+leDanone.FirstName+ ' ' +leDanone.LastName+' - '+cmp.Name,
            First_Name__c = leDanone.FirstName,
            Last_Name__c = leDanone.LastName,
            Company__c = leDanone.Company,
            Email__c = leDanone.Email,
            Campaign_Name__c = cmp.id,
            Phone__c = '1234567890',
            Active__c = true,
            Distributor_Account_Name__c = customerLocDanone.Id,
            Distributor_Parent_Account__c = commercialCust.Id,
            recordTypeId = partnerLeadRecordTypeId,
            Related_Master_Lead__c = leDanone.Id
        );
        childLeadsToInsert.add(childLeadDanone);

        Test.startTest();
        
        insert childLeadsToInsert;
        
        Test.stopTest();
        
        List<Child_Lead__Share>  childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadItaly.Id, :childLeadFrance.Id, :childLeadPoland.Id, :childLeadDanone.Id) AND UserOrGroupId = :usrItaly.Id AND RowCause = 'Standard_User__c'];
        System.assertEquals(1, childLeadShare.size());
        
        childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadItaly.Id, :childLeadFrance.Id, :childLeadPoland.Id, :childLeadDanone.Id) AND UserOrGroupId = :usrFrance.Id AND RowCause = 'Standard_User__c'];
        System.assertEquals(1, childLeadShare.size());
        
        childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadItaly.Id, :childLeadFrance.Id, :childLeadPoland.Id, :childLeadDanone.Id) AND UserOrGroupId = :usrPoland.Id AND RowCause = 'Standard_User__c'];
        System.assertEquals(1, childLeadShare.size());
        
        childLeadShare = [SELECT Id, UserOrGroupId FROM Child_Lead__Share WHERE ParentId IN (:childLeadItaly.Id, :childLeadFrance.Id, :childLeadPoland.Id, :childLeadDanone.Id) AND UserOrGroupId = :usrDanonePoland.Id AND RowCause = 'Standard_User__c'];
        System.assertEquals(1, childLeadShare.size());
    }
}