@isTest

public class OrderTriggerHandler_Test {
    
    public static testmethod void orderTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing112233test', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='Testing112233test@testorg.com');
        
        insert u;
        u.SAP_Employee_Id__c = '12345';
        update u;
        
        Account acc = TestUtility.createCommercialCustomer('Commercial Account');
        insert acc;
        
        Account customerL = TestUtility.createCommercialCustomer(acc.id);
        insert customerL;
        
        contract contr= new contract();
        contr.SAP_Contract_Number__c='1231232';
        contr.parent_account__c = acc.id;
        contr.AccountId = customerL.id;
        contr.StartDate=Date.newInstance(2020, 1, 8);
        contr.EndDate=Date.newInstance(2020, 1, 9);
        insert contr;
        
        
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        order ord = new order();
        ord.parent_account__c = acc.id;
        ord.AccountId = customerL.id;
        ord.ContractId = contr.id;
        //ord.Sold_to_Location__c = acc.id;
        ord.EffectiveDate = date.today();
        ord.Order_Owner__c='12345';   
        ord.Pricebook2Id = standardPricebook.id;
        insert ord;
        
         order ord1 = new order();
        ord1.parent_account__c = acc.id;
        ord1.AccountId = customerL.id;
        ord1.ContractId = contr.id;
        //ord.Sold_to_Location__c = acc.id;
        ord1.EffectiveDate = Date.newInstance(2019, 1, 8);
        ord1.Order_Owner__c='12345';   
        ord1.Pricebook2Id = standardPricebook.id;
        insert ord1;
        
       // update ord;
    }
    
}