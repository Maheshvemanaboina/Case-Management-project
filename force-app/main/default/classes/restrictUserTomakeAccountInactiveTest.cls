@isTest
public class restrictUserTomakeAccountInactiveTest {
    @testSetup static void setup() {
              
        string ProspectRT = Schema.SObjectType.account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
        
         List<Account> accts = new List<Account>();
        for(Integer i=0;i<5;i++) {
            Account a = new Account(Name='TestAccount' + i,recordTypeId=ProspectRT,active__c = true,BillingCountry='India',BillingCity='bangalore');
            accts.add(a);
        }
        insert accts;
        
         List<Opportunity> opps = new List<Opportunity>();
        for (Integer j=0;j<5;j++) {
            Account acct = accts[j];
            // For each account just inserted, add opportunities
            for (Integer k=0;k<5;k++) {
                opps.add(new Opportunity(Name=acct.Name + ' Opportunity ' + k,
                                       StageName='Prospecting',
                                       CloseDate=System.today().addMonths(1),
                                       AccountId=acct.Id));
            }
        }
        // Insert all opportunities for all accounts.
        insert opps;
    }
    
     @isTest static void testMethod1() {
                 string ProspectRT = Schema.SObjectType.account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();

         try{
             list<account> acc = [select id,active__c,RecordTypeId from account where RecordTypeId=:ProspectRT];
      map<id,account> tets = new map<id,account>();
        Account acct2 = [SELECT Id,active__c,RecordTypeId FROM Account WHERE active__c=true AND RecordTypeId=:ProspectRT LIMIT 1];
             
         acct2.active__c = false;
         update acct2;
             tets.put(acct2.id, acct2);
             restrictUserTomakeAccountInactive.showErrorMessage(acc,tets);
         }
         catch(DmlException e){
             
             system.debug('succesfully debug');
         }
    }
}