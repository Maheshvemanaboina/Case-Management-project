/*********************************************
 * Written By : Rekha
 * Purpose : To update Order & Order product delivery status to 'Not Relevant for Delivery' when Invoice is created without delivery
 * ******************************************/
public without sharing class InvoiceLineItemTriggerHandler {   


    public static void afterInsertHandler(list<Invoice_Line_Item__c> newList){
    
        //variable declaration
        set<id> orderIdSet = new set<id>();
        set<id> orderProductIdSet = new set<id>();  
        
        // loop new list of Invoice Line Items and check for Delivery Lines     
        for(Invoice_Line_Item__c item : newList){        
            
            if( item.Delivery_Line_Item__c==NULL){
                
                if(item.Sales_Order_Number__c!=NULL)
                orderIdSet.add(item.Sales_Order_Number__c);
                
                if(item.Sales_Order_Item_Number__c!=NULL)
                orderProductIdSet.add(item.Sales_Order_Item_Number__c);
                
                
            }
        }
        
        //call method
        if(orderIdSet.size()>0)
            updateOrderAndOrderProductDeliveryStatus(orderIdSet , orderProductIdSet);       
    
    }
   
    // This method updates Delivery Status on Order & OrderProduct to 'Not Relevant for Delivery'
    public static void updateOrderAndOrderProductDeliveryStatus(set<id> orderIdSet, set<id> orderProductIdSet){
    
        //variable declaration
        List<order> orderToUpdate;
        List<order> orderToQuery = new list<order>();
        List<orderitem> orderProductToUpdate;
        List<orderitem> orderProductToQuery = new list<orderitem>();
        
        // query orders to update
        orderToQuery = [SELECT id,Delivery_Status__c FROM order WHERE id IN : orderIdSet];
        
        // loop all the queried orders & change the order delivery status
        orderToUpdate = new list<order>();
        for(order each : orderToQuery){
            each.Not_Relevant_for_Delivery__c = true;
            each.Delivery_Status__c = 'Not Relevant for Delivery';
            orderToUpdate.add(each);
        }
        
        // query order products to update
        if(orderProductIdSet.size()>0){
            orderProductToQuery = [SELECT id,Delivery_Status__c FROM OrderItem WHERE id IN : orderProductIdSet];
            
            // loop all the queried order items & change the delivery status
            orderProductToUpdate= new list<orderitem>();
            for(orderitem each : orderProductToQuery){           
                each.Delivery_Status__c = 'Not Relevant for Delivery';
                orderProductToUpdate.add(each);
            }
        }
       
       
        //Update order list
        if(orderToUpdate.size()>0)
            update orderToUpdate;
            
        //update orderitem list
        if(orderProductToUpdate.size()>0)
            update orderProductToUpdate;    
        
        
    }
    
}