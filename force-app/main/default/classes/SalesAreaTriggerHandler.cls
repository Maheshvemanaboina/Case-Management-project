/***************************************************
 * Written By :Rekha
 * Purpose : To have sales area count and Customer group 4 count on H5 customer 
 * *************************************************
 * 11-Dec-2020: AS: Class commented cause the logic is no longer required.
 ***************************************************/

public class SalesAreaTriggerHandler extends TriggerHandler{
    /*
    public static void afterInsertHandler(list<Sales_Area__c> newList){
        
        set<id> h5IdSet = new set<id>(); 
        set<id> h5IdSet2 = new set<id>();
        
        for(Sales_Area__c sa : newList){
            if(sa.Customer_Name__c!=NULL)    
                h5IdSet.add(sa.Customer_Name__c);
            
            if(sa.Customer_Group_4__c!=NULL && sa.Customer_Name__c!=NULL)
                h5IdSet2.add(sa.Customer_Name__c);
        }
        
        if(h5IdSet.size()>0)
            updateCount(h5IdSet);   
        
        if(h5IdSet2.size()>0)
            updateB06Count(h5IdSet2);
     
    }
    
    public static void afterUpdateHanlder(list<Sales_Area__c> newList, map<id,Sales_Area__c> oldMap){
    
        set<id> h5IdSet = new set<id>(); 
        set<id> h5IdSet2 = new set<id>();
        set<id> h5IdSet3 = new set<id>();
        
        for(Sales_Area__c sa : newList){
            if(sa.Customer_Name__c!=oldMap.get(sa.id).Customer_Name__c){
                if(sa.Customer_Name__c!=NULL)
                    h5IdSet.add(sa.Customer_Name__c);  
                if(oldMap.get(sa.id).Customer_Name__c!=NULL)
                    h5IdSet.add(oldMap.get(sa.id).Customer_Name__c);
            }
            
            if(sa.Customer_Group_4__c!=oldMap.get(sa.id).Customer_Group_4__c && sa.Customer_Name__c!=NULL){
                h5IdSet2.add(sa.Customer_Name__c);    
            }
            
            if(sa.Active__c!=oldMap.get(sa.id).Active__c && sa.Customer_Name__c!=NULL){
                h5IdSet3.add(sa.Customer_Name__c);    
            }
        }
        
        if(h5IdSet.size()>0)
            updateCount(h5IdSet);
        
        if(h5IdSet2.size()>0){
            updateCount(h5IdSet2);
            updateB06Count(h5IdSet2);
            updateOtherCount(h5IdSet2);
        }
        
        if(h5IdSet3.size()>0){
            updateCount(h5IdSet3);
            updateB06Count(h5IdSet3);
            updateOtherCount(h5IdSet3);
        }    
        
    }
    
    public static void afterDeleteHandler(list<Sales_Area__c> oldList){
        
        set<id> h5IdSet = new set<id>();
        set<id> h5IdSet2 = new set<id>();
        
        for(Sales_Area__c sa : oldList){
            if(sa.Customer_Name__c!=NULL)    
                h5IdSet.add(sa.Customer_Name__c);
            
            if(sa.Customer_Group_4__c!=NULL && sa.Customer_Name__c!=NULL)
                h5IdSet2.add(sa.Customer_Name__c);
        } 
        
        if(h5IdSet.size()>0)
            updateCount(h5IdSet); 
        
        if(h5IdSet2.size()>0)
            updateB06Count(h5IdSet2);
    }
    
    public static void updateCount(set<id> h5CustomerId){
        
        list<account> h5ListToupdate = new list<account>();
        map<id,integer> countMap = new map<id,integer>();
        
        for(id i : h5CustomerId){
            countMap.put(i,0);
        }
        
        for(AggregateResult ag :[SELECT Customer_Name__c h5,count(id) cnt FROM Sales_Area__c WHERE Customer_Name__c IN : h5CustomerId and Active__c=true group by Customer_Name__c]){
            
             if(countMap.containskey((id)ag.get('h5')))
                countMap.put((id)ag.get('h5'),(integer)ag.get('cnt'));   
        }
        
        for(account obj : [SELECT id,Total_Sales_Area__c FROM account WHERE id IN : countMap.keyset()]){
            obj.Total_Sales_Area__c =  countMap.get(obj.id);
            h5ListToupdate.add(obj);
        }
        
        if(h5ListToupdate!=NULL)
            update h5ListToupdate;
    }
    
    public static void updateB06Count(set<id> h5CustomerId){
        
        list<account> h5ListToupdate = new list<account>();
        map<id,integer> countMap = new map<id,integer>();
        
        for(id i : h5CustomerId){
            countMap.put(i,0);
        }
        
        for(AggregateResult ag :[SELECT Customer_Name__c h5,count(id) cnt FROM Sales_Area__c WHERE Customer_Name__c IN : h5CustomerId and Customer_Group_4__c='B06 Distributor' and Active__c=true group by Customer_Name__c]){
            
             if(countMap.containskey((id)ag.get('h5')))
                countMap.put((id)ag.get('h5'),(integer)ag.get('cnt'));   
        }
        
        for(account obj : [SELECT id,Total_B06_Sales_Area__c FROM account WHERE id IN : countMap.keyset()]){
            obj.Total_B06_Sales_Area__c =  countMap.get(obj.id);
            h5ListToupdate.add(obj);
        }
        
        if(h5ListToupdate!=NULL)
            update h5ListToupdate;    
    }
    
     public static void updateOtherCount(set<id> h5CustomerId){
        
        list<account> h5ListToupdate = new list<account>();
        map<id,integer> countMap = new map<id,integer>();
        
        for(id i : h5CustomerId){
            countMap.put(i,0);
        }
        
        for(AggregateResult ag :[SELECT Customer_Name__c h5,count(id) cnt FROM Sales_Area__c WHERE Customer_Name__c IN : h5CustomerId and Customer_Group_4__c!='' and Customer_Group_4__c!=NULL and Customer_Group_4__c!='B06 Distributor' and Active__c=true group by Customer_Name__c]){
            
             if(countMap.containskey((id)ag.get('h5')))
                countMap.put((id)ag.get('h5'),(integer)ag.get('cnt'));   
        }
        
        for(account obj : [SELECT id,Total_Other_Sales_Area__c FROM account WHERE id IN : countMap.keyset()]){
            obj.Total_Other_Sales_Area__c =  countMap.get(obj.id);
            h5ListToupdate.add(obj);
        }
        
        if(h5ListToupdate!=NULL)
            update h5ListToupdate;    
    }
*/
    public override void processAfterUpdate(){
        UpdateAccountTeamsBusinessSegment.updateAccTeamsBusinessSegmentOfRelatedPartnerRoles((Map<Id,Sales_Area__c>) trigger.newMap, (Map<Id,Sales_Area__c>) trigger.oldMap);
    }
}