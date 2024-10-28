@isTest
public class InactiveEmailNotificationOnProductTest
{
    
    @isTest static void myTest()
    {  
        
        
        Id stExam = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('BGI Opportunity').getRecordTypeId(); 
        Id ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        
        Account a2 = new Account(Name ='icrm testing acc',BillingCity='Banglore',BillingCountry='India', RecordTypeId = ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID);
        a2.Active__c=true;
        a2.Partner_Role__c='Sold-to';
        insert a2;
        
    Integer index;
    String stg,operatComp,markSeg;    
    List<String> pckValues = new List<String>();    
    pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.StageName);
    index = pckValues.indexOf('Prospecting/Universe');
    stg = index !=-1 ? pckValues[index] : pckValues[0];
    pckValues.clear();
    pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.Opportunity_Operating_Company__c);
    index = pckValues.indexOf('Kievit');
    operatComp = index !=-1 ? pckValues[index] : pckValues[0] ;
    pckValues.clear();
    pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Opportunity.Opportunity_Market_Segment__c);
    index =pckValues.indexOf('Beverages');
    markSeg = index !=-1 ? pckValues[index] : pckValues[0];    
        
        
        opportunity oppr = new opportunity(Name='testing DIE 4/6/2018' , RecordtypeId= stExam, Ownerid = userinfo.getuserid() ,AccountId= a2.Id,StageName = stg, /*'Prospecting/Universe'*/CloseDate= System.today(),Opportunity_Operating_Company__c= operatComp /*'Kievit'*/,Opportunity_Market_Segment__c= markSeg  /*'Beverages'*/);
        insert oppr;
        
        oppr =[SELECT id,Name,StageName,CloseDate,Owner.name,Owner.Email,RecordtypeId,AccountId,Opportunity_Operating_Company__c,Opportunity_Market_Segment__c FROM Opportunity WHERE id=:oppr.Id];
        System.assertEquals(oppr.StageName ,'Prospecting/Universe');
        
        Id stExam1 = Schema.SObjectType.product2.getRecordTypeInfosByName().get('Competitor Product').getRecordTypeId();
        
        Product2 pro2 = new Product2(Name='BXCD', isActive=True , RecordtypeId= stExam1);
        insert pro2;
        
        PricebookEntry pbe2 =new PricebookEntry(unitprice=0.01,Product2Id=pro2.Id,Pricebook2Id=Test.getStandardPricebookId(),
                                                isActive=true,UseStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem OPplineitem2 = new OpportunityLineItem (Quantity=2, OpportunityId=oppr.Id,UnitPrice=0.01,PriceBookEntryId=pbe2.Id,product2id=pro2.id);
        
        insert OPplineitem2;
        
        pro2.isActive=false;
        update pro2;
    }
    
    
}