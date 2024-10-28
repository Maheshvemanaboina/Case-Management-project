@isTest
public class CloneMarketMapOpportunities_TEST {
   

    @testSetup static void setup() {

        BGI_Salesforce_Settings__c cs= new BGI_Salesforce_Settings__c();
        cs.No_Of_Opportunities_Per_Batch__c=10;
        cs.Default_Task_Owner__c=userinfo.getuserid().substring(0, 15);
        cs.Financial_Year__c=Date.newInstance(date.today().year(),12,31);
        cs.Batch_Status_Email_Recipients__c='xyz@test.com,abc@test.com';
        cs.Batch_Job_Failue_Message__c='test123';
        cs.Batch_Job_Success_Message__c='Failure';
        cs.Email_Subject__c='subject';
        cs.Sender_Display_Name__c='displayname';
        cs.Prototype_Price_Book_Id__c='123457895625555';
        insert cs;
        
        Account objAccount = new Account();
        objAccount.Name='Test-Account';
        objAccount.BillingStreet = 'TestBillingStreet';
        objAccount.BillingPostalCode = '0000';
        objAccount.BillingCity = 'TestCity';
        objAccount.BillingCountry = 'Italy';
        objAccount.BillingCountryCode = 'IT';
        //objAccount.RecordTypeId = Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID;
        objAccount.Active__c=true;
        insert objAccount;
        //fetch picklist values.
        //
        Integer index;
        String country,stg;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.Country_for_Export_Rules__c);
        index = pckValues.indexOf('Japan');
        country = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.StageName);
        index = pckValues.indexOf('Market Map Only');
        stg = index !=-1 ? pckValues[index] : pckValues[0];   
        
       
        Opportunity objOpporunity = new Opportunity();
        objOpporunity.Name='Test-Opportunity';
        objOpporunity.accountId=objAccount.Id;
        objOpporunity.Country_for_Export_Rules__c=country ;  //'Japan';
        objOpporunity.stagename=  stg ; //'Market Map Only';
        objOpporunity.CloseDate=Date.today();
        objOpporunity.Estimated_time_of_arrival__c=Date.today();
        objOpporunity.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('BGI_opportunity').getRecordTypeId();
        insert objOpporunity;
       
        
        
        
        // Get standard price book ID.
        // This is available irrespective of the state of SeeAllData.
        Id pricebookId = Test.getStandardPricebookId();
        
       
        Id recordtypeId =Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get('Product SKU').getRecordTypeId();


        
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
            Family = 'Hardware',recordtypeid=RecordTypeId);
        insert prod;
        
     
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
            
            
            
        
        
        OpportunityLineItem items= new OpportunityLineItem();
        items.OpportunityId=objOpporunity.id;
        items.PricebookEntryId=standardPrice.Id;
        items.Quantity=2;
        items.UnitPrice=25;
        insert items;
         
    }
    
    static testMethod  void testBatchPositive() {
        Test.StartTest();
        Database.executeBatch(new CloneMarketMapOpportunities_BATCH () , 10) ;
        Test.stopTest();
         
    }
    
     static testMethod  void testBatchNegative() {
        Test.StartTest();
        BGI_Salesforce_Settings__c  cs = BGI_Salesforce_Settings__c.getOrgDefaults();
        delete cs;
        Database.executeBatch(new CloneMarketMapOpportunities_BATCH () , 10) ;
        Test.stopTest();
    }
    
    static testMethod  void testSched() {
        Test.StartTest();
        String jobId = System.schedule('testScheduledApex','0 0 22 31 12 ? *', new CloneMarketMapOpportunities_SCHED());
        Test.stopTest();
    }
    

   

}