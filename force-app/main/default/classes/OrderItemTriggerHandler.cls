/****************************
 * Written by : Rekha
 * Purpose : To add pricebookentry to Order items whenever orderitems are created from SAP
 * (Pricebookentry is mandatory to create order items in salesforce) 
 * *************************/

public Without sharing class OrderItemTriggerHandler {
    
    public static void beforeInsertHandler(list<orderItem> newList){
        
        id orderId,priceBookId;     
        set<id> orderSet = new set<id>();
       // set<id> productSet = new set<id>();   
        set<string> productCodeSet = new set<string>();
        list<order> orderListToUpdate = new list<order>();
        map<id,PricebookEntry> priceBookEntryMap = new map<id,PricebookEntry>();
        //map<id,string> currencyMap = new map<id,string>();
        map<string,id> productIdMap = new map<string,id>();        
                     
        for(orderItem obj : newList){
            //if(obj.Product2Id!=NULL)
                //productSet.add(obj.Product2Id);
            if(obj.Product_Code__c!=NULL)
                productCodeSet.add(obj.Product_Code__c);                
            orderId = obj.OrderId;
            //orderSet.add(obj.orderId);
           
        }
        
       
        order orderObj = [SELECT id,CurrencyIsoCode,SAP_Sales_Order_Number__c FROM order WHERE id = : orderId ]; 
        //for(order ord : [SELECT id,CurrencyIsoCode FROM order WHERE id IN : orderSet]){
            //currencyMap.put(ord.id,ord.CurrencyIsoCode);    
        //}
        //
      
        
        if(productCodeSet.size()>0){            
            for(PricebookEntry pbe :[SELECT Name, Id, Product2Id, IsActive, UnitPrice,pricebook2id,CurrencyIsoCode FROM PricebookEntry where ProductCode IN :productCodeSet and Pricebook2.IsStandard=true and CurrencyIsoCode =:orderObj.CurrencyIsoCode]){
                priceBookEntryMap.put(pbe.id,pbe);
                priceBookId = pbe.Pricebook2Id;
            } 
            for(product2 each : [select id,Product_Code__c from product2 where productCode IN : productCodeSet]){
                productIdMap.put(each.Product_Code__c,each.id);    
            }            
        }
        
       /*** for(order ord : [SELECT id,CurrencyIsoCode FROM order WHERE id IN : orderSet]){            
            for(PricebookEntry pbe : priceBookEntryMap.values()){
                if(ord.CurrencyIsoCode == pbe.CurrencyIsoCode) 
                    ord.Pricebook2Id = pbe.Pricebook2Id;
                
                orderListToUpdate.add(ord);
            }            
        }
        
        if(orderListToUpdate.size()>0)
            update orderListToUpdate;****/
   
        //orderObj.Pricebook2Id = priceBookId;        
        //update orderObj;
        
        if(priceBookEntryMap.size()>0){
            for(orderItem each : newList){
                each.Product2Id = productIdMap.get(each.Product_Code__c);
                //string currencyCode = currencyMap.get(each.orderId);
                for(PricebookEntry pbe : priceBookEntryMap.values()){
                    if(each.Product2Id == pbe.Product2Id && orderObj.CurrencyIsoCode==pbe.CurrencyIsoCode){
                        each.PricebookEntryId = pbe.id;    
                    }    
                }            
            }
        }
        
    
    }
    
    public static void afterInsertHandler(list<orderItem> newList){
        updateConfirmedDeliveryDate(newlist[0].orderId,newList);    
    }
    
    public static void afterUpdateHandler(list<orderItem> newList, map<id,orderItem> oldMap){
        
        list<orderItem> itemList = new list<orderItem>();
        
        for(orderItem item : newList){
            if(item.Confirmed_Delivery_Date__c != oldmap.get(item.id).Confirmed_Delivery_Date__c && item.Confirmed_Delivery_Date__c!=NULL) 
                itemList.add(item);    
        }
        
        if(itemList.size()>0)
        updateConfirmedDeliveryDate(itemList[0].orderId,newList);    
        
        
    }
    
    
    // to Get confirm delivery date and update it on header level
    // If there are more line items to 1 then the latest confirmed delivery date should be showing in the order header.
    public static void updateConfirmedDeliveryDate(id orderId, list<orderItem> itemList){
    
        date confirmDeliveryDate;       
       
        if(itemList.size()==1){
            confirmDeliveryDate = itemList[0].Confirmed_Delivery_Date__c;   
        }
        else{
            confirmDeliveryDate = itemList[0].Confirmed_Delivery_Date__c;
            for(orderItem obj : itemList){
                if(obj.Confirmed_Delivery_Date__c>confirmDeliveryDate)
                    confirmDeliveryDate = obj.Confirmed_Delivery_Date__c;
            }
        }
        
        order orderObj = [SELECT id,CurrencyIsoCode,SAP_Sales_Order_Number__c FROM order WHERE id = : orderId];
        orderObj.Confirmed_Delivery_Date__c = confirmDeliveryDate;
        update orderObj;
        
    }
    
    
  

}