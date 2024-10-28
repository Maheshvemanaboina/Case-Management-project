public Without sharing class OrderDataUpdate {

    public static void updateOrderOnBeforeInsert(List<Order> newOrderList){

        set<string> sapEmployeeNumberSet = new set<string>();
        map<string,id> userIdMap = new map<string,id>();
       /* set<id> h5Customer = new set<id>();
        map<id,id> h1CustomerMap = new map<id,id>();*/
      
        
        for(order obj : newOrderList){
            if(obj.Order_Owner__c!=NULL)
                sapEmployeeNumberSet.add(obj.Order_Owner__c);

           /* if(obj.Sold_to_Location__c !=NULL)
                h5Customer.add(obj.Sold_to_Location__c);     */       
        }
        if(sapEmployeeNumberSet.size()>0){
            for(user uObj : [SELECT id,SAP_Employee_Id__c FROM user WHERE SAP_Employee_Id__c IN : sapEmployeeNumberSet]){
                userIdMap.put(uObj.SAP_Employee_Id__c,uObj.id);    
            }
        }
        
      /*  if(h5Customer.size()>0){            
            for(Account accObj : [SELECT id,ParentId FROM Account WHERE id IN : h5Customer]){
                if(accObj.ParentId!=NULL)
                h1CustomerMap.put(accObj.id,accObj.ParentId);    
            }            
        }*/
        
      
        Pricebook2 priceBookObj = new Pricebook2();        
        
        priceBookObj = [select id from Pricebook2 where isstandard=true and isactive = true LIMIT 1];        
        
        for(order obj : newOrderList){
            obj.Status ='Draft';
            obj.SAP_Order_Status__c = 'In Progress';
            obj.Pricebook2Id = priceBookObj.id;
            if(obj.Order_Owner__c!=NULL && !userIdMap.isEmpty() && userIdMap.containskey(obj.Order_Owner__c) && userIdMap.get(obj.Order_Owner__c)!=NULL){
                obj.OwnerId = userIdMap.get(obj.Order_Owner__c);    
            }
            
          
           /* if(obj.Sold_to_Location__c!=NULL && !h1CustomerMap.isEmpty() && h1CustomerMap.containsKey(obj.Sold_to_Location__c) && h1CustomerMap.get(obj.Sold_to_Location__c)!=NULL){
                
                obj.AccountId = h1CustomerMap.get(obj.Sold_to_Location__c);
            }*/
        }
        
        //update order start date
        updateOrderStartDate(newOrderList);
      
    }

    public static void updateOrderOnBeforeUpdate(List<Order> newOrderList, Map<Id,Order> oldOrderMap){

        set<string> sapEmployeeNumberSet = new set<string>();
        map<string,id> userIdMap = new map<string,id>();
        list<order> updateStartDateOrderList = new list<order>();
      
        for(order obj : newOrderList){
            
            if(obj.Order_Owner__c!=oldOrderMap.get(obj.id).Order_Owner__c){
                if(obj.Order_Owner__c!=NULL)
                    sapEmployeeNumberSet.add(obj.Order_Owner__c); 
            } 
            
            //*****check whether start date is already updated. otherwise call the method and update*****by Rekha
            if(obj.Start_Date_Updated__c || obj.EffectiveDate==oldOrderMap.get(obj.id).EffectiveDate){
                obj.EffectiveDate = oldOrderMap.get(obj.id).EffectiveDate;      // stamp existing date itself if already date is updated
            }
            else{
                updateStartDateOrderList.add(obj);    
            }
            
        }
        
        if(sapEmployeeNumberSet.size()>0){
            for(user uObj : [SELECT id,SAP_Employee_Id__c FROM user WHERE SAP_Employee_Id__c IN : sapEmployeeNumberSet]){
                userIdMap.put(uObj.SAP_Employee_Id__c,uObj.id);    
            }
        } 
        
        for(order obj : newOrderList){
            if(obj.Order_Owner__c!=NULL && !userIdMap.isEmpty() && userIdMap.containskey(obj.Order_Owner__c) && userIdMap.get(obj.Order_Owner__c)!=NULL){
                obj.OwnerId = userIdMap.get(obj.Order_Owner__c);    
            }     
        } 
        
        //update order start date
        if(updateStartDateOrderList.size()>0)
        updateOrderStartDate(updateStartDateOrderList);
     

    }
    
    
    //****************Update order start date with contract date---by Rekha*********************/
    public static void updateOrderStartDate(List<Order> newOrderList){
        
        Map<Id,Contract> contractids = new Map<Id,Contract>();
        for(order obj : newOrderList){
            if(obj.ContractId!=NULL)
            contractids.put(obj.ContractId,null);  
        }
                
        if(contractids.size()>0){
             contractids.putAll([SELECT Id,StartDate,EndDate FROM Contract WHERE Id IN :contractids.keySet()]);
        }
              
        for(order obj : newOrderList){
            if(!contractids.isEmpty() && contractids.containskey(obj.ContractId) && contractids.get(obj.ContractId)!=null){
                if(obj.EffectiveDate < contractids.get(obj.ContractId).StartDate){
                    obj.EffectiveDate = contractids.get(obj.ContractId).StartDate;   //If the Order Created Date is earlier than the contract's start date. Then, we need update Order Created Date as Contract Start Date
                    obj.Start_Date_Updated__c = true;
                }
            
                if(obj.EffectiveDate > contractids.get(obj.ContractId).EndDate){
                    obj.EffectiveDate = contractids.get(obj.ContractId).EndDate;    //If the Order Created Date is later than its contract's end date. Then we need to update Order Created Date as Contract End Date
                    obj.Start_Date_Updated__c = true;
                }    
            }
        }  
    }
}