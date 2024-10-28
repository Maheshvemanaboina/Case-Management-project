@isTest
public class ChildLeadRoutingTest {
    
    @testSetup
    static void setup(){
        TriggerHandler.skipTrigger = true;
        
        set<String> recordTypeNameSet = new Set<String>();
        List<Account> childAccountList = new List<Account>();        
        User adminUser  = TestUtility.createUser(TestUtility.generateRandomUserName()+'TestLeadUser','System Administrator');
        adminUser.Business_Segment__c = 'Adult Nutrition';
        insert adminUser;
        
        system.runAS(adminUser){
            Account distributorAccount = TestUtility.createCommercialCustomer('Distributor');
            insert distributorAccount;        
            Account distributorLocation = TestUtility.createCustomerLocation('Italy Spa123', distributorAccount);
            insert distributorLocation;        
            Account commercialCust = TestUtility.createCommercialCustomer();
            insert commercialCust;        
            Account customerChildRecord1 = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCust);
            childAccountList.add(customerChildRecord1);        
            Account customerChildRecord2 = TestUtility.createEndCustomerAccount('Test End Customer');
            customerChildRecord2.Distributor__c = distributorAccount.Id;
            customerChildRecord2.Distributor_Location__c = distributorLocation.Id;
            insert customerChildRecord2;
            
            Account customerChildRecord3 = new Account();
            customerChildRecord3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Prospect').getRecordTypeId();
            customerChildRecord3.Name = 'Prospect Acc';
            customerChildRecord3.ParentId = commercialCust.Id;
            customerChildRecord3.BillingStreet = 'TestBillingStreet';
            customerChildRecord3.BillingPostalCode = '0000';
            customerChildRecord3.BillingCity = 'TestCity';
            customerChildRecord3.BillingCountry = 'Italy';
            customerChildRecord3.BillingCountryCode = 'IT';
            childAccountList.add(customerChildRecord3);        
             
                
            insert childAccountList;
            
            Contact prospectContact = TestUtility.createAgentContact('Test FN','Test LN',customerChildRecord2);
            prospectContact.Business_Segment__c = 'Industry';
            insert prospectContact;
            Contact endCustomerContact = TestUtility.createContact(distributorAccount,distributorLocation);
            endCustomerContact.Business_Segment__c = 'Industry';
            insert endCustomerContact;
    
            List<Campaign> cmpList= new List<Campaign>();
            Campaign cmp = new Campaign(); 
            cmp.Business_Segment__c = 'Adult Nutrition';
            cmp.Sub_Segment__c = 'Active Nutrition';
            cmp.Name = 'test cmp';
            cmp.StartDate = system.today();
            cmp.EndDate = system.today()+30;
            cmpList.add(cmp);        
            Campaign cmp3 = new Campaign(); 
            cmp3.Business_Segment__c = 'Early Life Nutrition & Cell Nutrition';
            cmp3.Sub_Segment__c = 'Cell Nutrition';
            cmp3.Name = 'test cmp3';
            cmp3.StartDate = system.today();
            cmp3.EndDate = system.today()+30;
            cmpList.add(cmp3);
            insert cmpList;  
            
            ID masterleadRecordType = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('BGI_Lead').getRecordTypeId(); 
            List<Lead> leadList = new List<lead>();
            Lead leadRecord = new Lead();
            leadRecord.Company = 'IMCD Italy';
            leadRecord.FirstName = 'test lead 1';
            leadRecord.Phone = '+919876543212';
            leadRecord.LastName = 'last name 1';
            leadRecord.Region__c = 'EMEA';
            leadRecord.RecordTypeId = masterleadRecordType;
            leadList.add(leadRecord);
    
            Lead leadRecord2 = new Lead();
            leadRecord2.Company = 'Test End Customer';
            leadRecord2.FirstName = 'test lead 2';
            leadRecord2.Phone = '+919876543212';
            leadRecord2.LastName = 'last name 2';
            leadRecord2.Region__c = 'APAC';
            leadRecord2.RecordTypeId = masterleadRecordType;
            leadList.add(leadRecord2);
    
            Lead leadRecord3 = new Lead();
            leadRecord3.Company = 'Prospect Acc';
            leadRecord3.FirstName = 'test lead 3';
            leadRecord3.Phone = '+919876543212';
            leadRecord3.LastName = 'last name 3';
            leadRecord3.Region__c = 'APAC';
            leadRecord3.RecordTypeId = masterleadRecordType;
            leadList.add(leadRecord3);
            insert leadList;
        }

        TriggerHandler.skipTrigger = false;               

    }
    // Testing for Leads matches with the Account of type customer location
    @isTest
    public static void checkForChildLeadsRelatedToLead(){
        Campaign campaignRecord = [SELECT Id FROM Campaign WHERE Name = 'test cmp'];   
        User pardotUser = [SELECT Id FROM User WHERE Name='Pardot User' LIMIT 1];
        Lead endCustomer = [SELECT Id FROM Lead WHERE Company = 'Test End Customer'];
        Lead customerLocation = [SELECT Id FROM Lead WHERE Company = 'IMCD Italy'];
        Lead prospect= [SELECT Id FROM Lead WHERE Company = 'Prospect Acc']; 
        Account prospectAccount = [SELECT Id,OwnerId FROM Account WHERE Name = 'Prospect Acc']; 
        Account customerAccount = [SELECT Id,OwnerId FROM Account WHERE Name = 'Test End Customer']; 
        ID childleadRecordType = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('FCI_Child_Lead').getRecordTypeId();            

        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();

        system.runAS(pardotUser){        
            Child_Lead__c leadRecord1 = new Child_Lead__c();
            leadRecord1.Company__c = 'Prospect Acc';
            leadRecord1.First_Name__c = 'test lead 1';
            leadRecord1.Phone__c = '+919876543212';
            leadRecord1.Last_Name__c = 'last name 1';
            leadRecord1.Region__c = 'EMEA';
            leadRecord1.Business_Segment__c = 'Adult Nutrition';
            leadRecord1.RecordTypeId = childleadRecordType;
            leadRecord1.OwnerId = pardotUser.Id;     
            leadRecord1.Related_Master_Lead__c = prospect.Id;
            childLeadList.add(leadRecord1);

            Child_Lead__c leadRecord2 = new Child_Lead__c();
            leadRecord2.Company__c = 'Test End Customer';
            leadRecord2.Last_Name__c = 'last name 2';
            leadRecord2.Region__c = 'EMEA';
            leadRecord2.Business_Segment__c = 'Adult Nutrition';
            leadRecord2.RecordTypeId = childleadRecordType;
            leadRecord2.OwnerId = pardotUser.Id;     
            leadRecord2.Related_Master_Lead__c = endCustomer.Id;
            childLeadList.add(leadRecord2);

            Child_Lead__c leadRecord3 = new Child_Lead__c();
            leadRecord3.Company__c = 'IMCD Italy';
            leadRecord3.Last_Name__c = 'last name 3';
            leadRecord3.Region__c = 'EMEA';
            leadRecord3.Business_Segment__c = 'Adult Nutrition';
            leadRecord3.RecordTypeId = childleadRecordType;
            leadRecord3.OwnerId = pardotUser.Id;     
            leadRecord3.Related_Master_Lead__c = customerLocation.Id;
            childLeadList.add(leadRecord3);
            
            Child_Lead__c leadRecord4 = new Child_Lead__c();
            leadRecord4.Company__c = 'Italy';
            leadRecord4.Last_Name__c = 'last name 3';
            leadRecord4.Region__c = 'EMEA';
            leadRecord4.Business_Segment__c = 'Adult Nutrition';
            leadRecord4.RecordTypeId = childleadRecordType;
            leadRecord4.OwnerId = pardotUser.Id;     
            leadRecord4.Related_Master_Lead__c = customerLocation.Id;
            childLeadList.add(leadRecord4);
            
            Child_Lead__c leadRecord5 = new Child_Lead__c();
            leadRecord5.Company__c = 'CellNew';
            leadRecord5.Last_Name__c = 'last name 8';
            leadRecord5.Region__c = 'EMEA';
            leadRecord5.Business_Segment__c = 'Early Life Nutrition & Cell Nutrition';
            leadRecord5.Sub_Segment__c = 'Cell Nutrition';
            leadRecord5.RecordTypeId = childleadRecordType;    
            leadRecord5.Related_Master_Lead__c = customerLocation.Id;
            childLeadList.add(leadRecord5);
            INSERT childLeadList;
            
            System.assertEquals([Select Id,ownerID from Child_Lead__c where Company__c ='Prospect Acc'].ownerId, prospectAccount.OwnerId, 'Owners Matched');
            System.assertEquals([Select Id,ownerID from Child_Lead__c where Company__c = 'Test End Customer'].ownerId, customerAccount.OwnerId, 'Owners Matched');
        }
               
    }

    @isTest
    public static void checkForChildLeadsRelatedToContact(){          
        User pardotUser = [SELECT Id FROM User WHERE Name='Pardot User' LIMIT 1];
        contact prospect= [SELECT Id,ownerID FROM Contact WHERE LastName = 'Test LN'];        
        Contact endCustomer= [SELECT Id,ownerID FROM Contact WHERE Parent_Account__c !=''];
        ID childleadRecordType = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('FCI_Child_Lead').getRecordTypeId();            

        List<Child_Lead__c> childLeadList = new List<Child_Lead__c>();
        Child_Lead__c leadRecord1 = new Child_Lead__c();
        leadRecord1.Company__c = 'Prospect Acc';
        leadRecord1.First_Name__c = 'test lead 1';
        leadRecord1.Phone__c = '+919876543212';
        leadRecord1.Last_Name__c = 'last name 1';
        leadRecord1.Region__c = 'EMEA';
        leadRecord1.Business_Segment__c = 'Adult Nutrition';
        leadRecord1.RecordTypeId = childleadRecordType;
        leadRecord1.OwnerId = pardotUser.Id;     
        leadRecord1.Related_Contact__c = prospect.Id;
        childLeadList.add(leadRecord1);

        Child_Lead__c leadRecord2 = new Child_Lead__c();
        leadRecord2.Company__c = 'Test End Customer';
        leadRecord2.Last_Name__c = 'last name 2';
        leadRecord2.Region__c = 'EMEA';
        leadRecord2.Business_Segment__c = 'Adult Nutrition';
        leadRecord2.RecordTypeId = childleadRecordType;
        leadRecord2.OwnerId = pardotUser.Id;     
        leadRecord2.Related_Contact__c = endCustomer.Id;
        childLeadList.add(leadRecord2);

        
        system.runAS(pardotUser){
            insert childLeadList;
        }
        System.assertEquals([Select Id,ownerID from Child_Lead__c where Company__c ='Prospect Acc'].ownerId, prospect.OwnerId, 'Owners Matched');
        System.assertEquals([Select Id,ownerID from Child_Lead__c where Company__c = 'Test End Customer'].ownerId, endCustomer.OwnerId, 'Owners Matched');
    }
 
    
	
}