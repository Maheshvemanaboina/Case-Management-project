@isTest

public class InvoiceLineItemTriggerHandler_Test {
    
    public static testmethod void invoiceItemTest(){        
        
        account acc= new account();
        acc.name='test6778';
        acc.BillingCountry = 'China';
        acc.BillingCity = 'Bangalore';
        insert acc;
        
        Id ProductRecordTypeId = Schema.SObjectType.product2.getRecordTypeInfosByDeveloperName().get('BGI_Product_SKU').getRecordTypeId();
        
        Product2 pro = new Product2(Name = 'iPhone X', Family = 'Mobile',ProductCode='12345' , RecordTypeId = ProductRecordTypeId );
        Insert pro;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        Update standardPricebook;

        order ord = new order();
        ord.AccountId = acc.id;
        ord.Sold_to_Location__c = acc.id;
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
        
        
        
        Invoice__c inv = new Invoice__c();       
        insert inv;
        
        Invoice_Line_Item__c Invitem = new Invoice_Line_Item__c();
        Invitem.Invoice__c = inv.id;
        Invitem.Sales_Order_Number__c = ord.id;
        Invitem.Sales_Order_Item_Number__c = item.id;
        insert Invitem;
        
        
    }

}