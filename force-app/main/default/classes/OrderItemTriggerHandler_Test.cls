@isTest

public class OrderItemTriggerHandler_Test {
    
    public static testmethod void OrderItemTest(){
        
        /*account acc= new account();
        acc.name='test';
        insert acc;*/
        
        Account acc = TestUtility.createCommercialCustomer('Commercial Account');
        insert acc;
        
        Account customerL = TestUtility.createCommercialCustomer(acc.id);
        insert customerL;

        Id ProductRecordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByDeveloperName().get('BGI_Product_SKU').getRecordTypeId();
        
        Product2 pro = new Product2(Name = 'iPhone X', Family = 'Mobile',ProductCode='12345' , RecordTypeId = ProductRecordTypeId );
        Insert pro;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        Update standardPricebook;
        
        order ord = new order();
        ord.parent_account__c = acc.id;
        ord.AccountId = customerL.id;
        //ord.Sold_to_Location__c = acc.id;
        ord.EffectiveDate = date.today();  
        ord.CurrencyIsoCode ='EUR';
        ord.Pricebook2Id = standardPricebook.id;
        insert ord;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true,
            CurrencyIsoCode ='EUR'
        );
        Insert pbe;
        
        orderItem item = new orderItem();
        item.Product_Code__c = '12345';
        item.OrderId = ord.id;
        item.UnitPrice = 20;
        item.Quantity = 20;
        item.PricebookEntryId = pbe.id;
        insert item;
    }

}