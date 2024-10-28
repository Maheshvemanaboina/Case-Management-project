public  without sharing class AccountPlanScoringHandler {

    public static void updateScore(List<Field_of_Play__c> accountPlanRecordList,Map<Id,Field_of_Play__c> oldAccountPlanMap){
        set<id> busStgSet = new set<id>();
        map<id,Field_of_Play__c> newMap = new Map<id,Field_of_Play__c>();
        
        for(Field_of_Play__c acPlan : accountPlanRecordList){
            if(acPlan.Confirmed_by_FCI_Sales_Manager__c != oldAccountPlanMap.get(acPlan.Id).Confirmed_by_FCI_Sales_Manager__c
               &&(acPlan.Confirmed_by_FCI_Sales_Manager__c == 'Yes' || acPlan.Confirmed_by_FCI_Sales_Manager__c == 'No')){                   
                   newMap.put(acPlan.id,acPlan);
                   busStgSet.add(acPlan.Distributor_Business_Strategy__c);
            }
        }
        
        if(!busStgSet.isEmpty()){
            
			list<Business_Strategy__c> updBusStgs = new list<Business_Strategy__c>();
            Id accRecTypeId = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Business_Strategy_Account_Plan').getRecordTypeId(); 
        	list<Business_Strategy__c> busStagList = [SELECT id,Fiscal_Year_FY__c,Distributor_Account_Name__c,RecordTypeId,
                                                      (SELECT id,Confirmed_by_FCI_Sales_Manager__c FROM Field_of_Play_Account_Plan__r) 
                                                      FROM Business_Strategy__c WHERE id In:busStgSet AND recordtypeId =: accRecTypeId AND Fiscal_Year_FY__c != null];
        
            map<id,map<string,integer>> parentBusMap =  new map<id,map<string,integer>>();
            set<string> fsYearset = new set<string>();
            
            for(Business_Strategy__c bStg : busStagList){
                
                map<string,integer> tempMap = ( parentBusMap.get(bStg.Distributor_Account_Name__c)!=null) ? parentBusMap.get(bStg.Distributor_Account_Name__c):new map<string,integer>();
                String fsYear = string.valueOf(integer.valueOF(bStg.Fiscal_Year_FY__c)-1);
                fsYearset.add(fsYear);
                integer acPlansSize =  bStg.Field_of_Play_Account_Plan__r.size();
                integer count = 0;
                for(Field_of_Play__c chAcPlan : bStg.Field_of_Play_Account_Plan__r){
                    chAcPlan = (newMap.get(chAcPlan.id)!=null) ? newMap.get(chAcPlan.id) : chAcPlan;                    
                    if(chAcPlan.Confirmed_by_FCI_Sales_Manager__c == 'Yes') {
                        count++;
                    }
                }
                
                if(count == acPlansSize){
                    tempMap.put(fsYear,3);
                } else if(count>0 && count<acPlansSize) {
                    tempMap.put(fsYear,1);
                } else {
                    tempMap.put(fsYear,0);
                }
                parentBusMap.put(bStg.Distributor_Account_Name__c,tempMap);
            }
            
            if(!parentBusMap.isempty()){
            	
            
                for(Business_Strategy__c bStg : [SELECT id,Fiscal_Year_FY__c,Distributor_Account_Name__c FROM Business_Strategy__c 
                                                 WHERE Distributor_Account_Name__c IN: parentBusMap.keySet() AND recordtypeId =: accRecTypeId AND Fiscal_Year_FY__c IN: fsYearset]){
                          
                	if(parentBusMap.get(bStg.Distributor_Account_Name__c) != null && 
                       parentBusMap.get(bStg.Distributor_Account_Name__c).get(bStg.Fiscal_Year_FY__c) != null){
                           
                           Business_Strategy__c busg = new Business_Strategy__c();
                               busg.Id = Bstg.id;
                               busg.Score__c = parentBusMap.get(bStg.Distributor_Account_Name__c).get(bStg.Fiscal_Year_FY__c);
                               busg.Weight__c = 2;
                           updBusStgs.add(busg);                        
                    }                    
                }    
            }
            
            if(!updBusStgs.isEmpty()){
                DAOUtilityWithoutShar.updateWithoutAccess(updBusStgs);
            }
            
            
        }
    	
    }
   
}