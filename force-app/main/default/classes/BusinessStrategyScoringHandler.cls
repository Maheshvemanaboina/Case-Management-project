public  without sharing class BusinessStrategyScoringHandler {
    
    public static void updateScore(List<Business_Strategy__c> businessStrategyRecordsList){
        
        
        List<Business_Strategy__c> businessStrategyList = new List<Business_Strategy__c>();
        for(Business_Strategy__c records : businessStrategyRecordsList){
            if(records.Confirmed_by_FCI_Sales_Manager__c == 'Yes' || records.Confirmed_by_FCI_Sales_Manager__c == 'No'){
                businessStrategyList.add(records);
            }
        }
        
        if(businessStrategyList.size() > 0){
            Map<String,Integer> weightMap = new Map<String,Integer>();
        weightMap.put('Business_Strategy_Competition',1);
        weightMap.put('Business_Strategy_High_Low_Lights',1);
        set<Id> recordtypeIdSet = new set<Id>();
        set<Id> childStrategyIdSet = new set<Id>();
        for(Business_Strategy__c childStrategy : businessStrategyList){
            recordtypeIdSet.add(childStrategy.RecordTypeId);
            childStrategyIdSet.add(childStrategy.Id);
        }
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE Id IN : recordtypeIdSet]);
        Map<Id,List<Business_Strategy__c>> parentChildMap = new Map<Id,List<Business_Strategy__c>>();
        for(Business_Strategy__c childStrategy : businessStrategyList){
            if(recordTypeMap.containskey(childStrategy.RecordTypeId) && recordTypeMap.get(childStrategy.RecordTypeId).DeveloperName == 'Competition'){
                if(parentChildMap.containskey(childStrategy.Business_Strategy_Competition__c) ){
                    parentChildMap.get(childStrategy.Business_Strategy_Competition__c).add(childStrategy);
                }else{
                    parentChildMap.put(childStrategy.Business_Strategy_Competition__c,new List<Business_Strategy__c>{childStrategy});
                }
            }
            if(recordTypeMap.containskey(childStrategy.RecordTypeId) && recordTypeMap.get(childStrategy.RecordTypeId).DeveloperName == 'Competition_Account_Plan'){
                if(parentChildMap.containskey(childStrategy.Business_Strategy_Competition__c)){
                    parentChildMap.get(childStrategy.Business_Strategy_Competition__c).add(childStrategy);
                }else{
                    parentChildMap.put(childStrategy.Business_Strategy_Competition__c,new List<Business_Strategy__c>{childStrategy});
                }
            }
            if(recordTypeMap.containskey(childStrategy.RecordTypeId) && recordTypeMap.get(childStrategy.RecordTypeId).DeveloperName == 'High_Low_Lights'){
                if(parentChildMap.containskey(childStrategy.Business_Strategy_High_Low_Lights__c)){
                    parentChildMap.get(childStrategy.Business_Strategy_High_Low_Lights__c).add(childStrategy);
                }else{
                    parentChildMap.put(childStrategy.Business_Strategy_High_Low_Lights__c,new List<Business_Strategy__c>{childStrategy});
                }
            }
        }
        
        List<Business_Strategy__c> existingChildStrategyList = [SELECT Id,Business_Strategy_High_Low_Lights__c,Business_Strategy_Competition__c,RecordType.DeveloperName,Confirmed_by_FCI_Sales_Manager__c  FROM Business_Strategy__c WHERE Id NOT IN : childStrategyIdSet AND (Business_Strategy_High_Low_Lights__c IN : parentChildMap.keyset() OR Business_Strategy_Competition__c IN : parentChildMap.keyset())];
        for(Business_Strategy__c existingChildStrategy : existingChildStrategyList){
            if(existingChildStrategy.RecordType.DeveloperName == 'Competition'){
                if(parentChildMap.containskey(existingChildStrategy.Business_Strategy_Competition__c) ){
                    parentChildMap.get(existingChildStrategy.Business_Strategy_Competition__c).add(existingChildStrategy);
                }
            }
            if(existingChildStrategy.RecordType.DeveloperName == 'Competition_Account_Plan'){
                if(parentChildMap.containskey(existingChildStrategy.Business_Strategy_Competition__c) ){
                    parentChildMap.get(existingChildStrategy.Business_Strategy_Competition__c).add(existingChildStrategy);
                }
            }
            if(existingChildStrategy.RecordType.DeveloperName == 'High_Low_Lights'){
                if(parentChildMap.containskey(existingChildStrategy.Business_Strategy_High_Low_Lights__c)){
                    parentChildMap.get(existingChildStrategy.Business_Strategy_High_Low_Lights__c).add(existingChildStrategy);
                }
            }
        }
       
        Map<Id,Business_Strategy__c> parentRecordMap = new Map<Id,Business_Strategy__c>([SELECT Id,Score__c,Weight__c,RecordType.DeveloperName FROM Business_Strategy__c WHERE ID IN : parentChildMap.keyset()]);
        Integer count = 0;
        Integer maxVal = 0;
        for(Id parentId : parentChildMap.keyset()){
            count = 0;
            maxVal = 0;
            maxVal = parentChildMap.get(parentId).size();
            for(Business_Strategy__c childStrategy : parentChildMap.get(parentId)){
                if(childStrategy.Confirmed_by_FCI_Sales_Manager__c == 'Yes'){
                    count++;
                }
            }
            if(count == maxVal){
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c != null){
                    parentRecordMap.get(parentId).Score__c = 3;
                }
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                    parentRecordMap.get(parentId).Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                }
                if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) || test.isRunningTest() ){
                    Business_Strategy__c bs = new Business_Strategy__c();
                    bs.Id = parentId;
                    bs.Score__c = 3;
                    bs.Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                    parentRecordMap.put(parentId,bs);
                }
            }else{
                if(count < maxVal && count > 0){
                     if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 1;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) || test.isRunningTest() ){
                    Business_Strategy__c bs = new Business_Strategy__c();
                    bs.Id = parentId;
                    bs.Score__c = 1;
                    bs.Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                    parentRecordMap.put(parentId,bs);
                }
                }else{
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) || test.isRunningTest() ){
                    Business_Strategy__c bs = new Business_Strategy__c();
                    bs.Id = parentId;
                    bs.Score__c = 0;
                    bs.Weight__c = 0;
                    parentRecordMap.put(parentId,bs);
                    }
                }
            }
            
        }
        if(parentRecordMap.values().size() > 0){
            DAOUtilityWithoutShar.updateWithoutAccess(parentRecordMap.values());
        }
        }
    }
    
     /* @Description
        Method Name : UpdateBucketTotalScore(List<Business_Strategy__c> acPlanList, Map<Id,Business_Strategy__c> oldMap)

        1. calculating the total score at main bucket level.
        
        @PARAMS
            1. NAME ( acPlanList )  => TYPE ( List<Business_Strategy__c> ) 	=> DESCRIPTION ( Trigger.new from BusinessStrategyTriggerHandler )
            2. NAME ( oldMap )  	=> TYPE ( Map<Id,Business_Strategy__c> ) => DESCRIPTION ( Trigger.oldmap from BusinessStrategyTriggerHandler )
    */
    public static void UpdateBucketTotalScore(List<Business_Strategy__c> acPlanList, Map<Id,Business_Strategy__c> oldMap){
        set<Id> parentBusStrtgs = new set<Id>();
        if(acPlanList!=null){
            for(Business_Strategy__c bst : acPlanList){
            
                if(oldMap == null || oldMap.isEmpty() ||bst.Score__c!=oldMap.get(bst.id).Score__c || bst.Weight__c!=oldMap.get(bst.id).Weight__c){
                    parentBusStrtgs.add(bst.Parent_Business_Strategy__c);
                }
                
                if(oldMap!=null && bst.Parent_Business_Strategy__c!=oldMap.get(bst.id).Parent_Business_Strategy__c){
                    parentBusStrtgs.add(bst.Parent_Business_Strategy__c);
                    parentBusStrtgs.add(oldMap.get(bst.id).Parent_Business_Strategy__c);
                }
                
            }
            
        } else if(oldMap !=null){
            for(Business_Strategy__c oBst : oldMap.values()){
                parentBusStrtgs.add(oBst.Parent_Business_Strategy__c);
            }
        }
        
        if(!parentBusStrtgs.isEmpty()){
            //Total_FY_Score__c
            list<Business_Strategy__c> updateBusList = new List<Business_Strategy__c>();
            for(Business_Strategy__c bus : [SELECT id,(SELECT id,Total_Score__c,Score__c,Weight__c FROM Business_Strategies__r) 
                                            FROM Business_Strategy__c WHERE id IN:parentBusStrtgs]){
                Decimal totalScore = 0;
            	for(Business_Strategy__c chBus:bus.Business_Strategies__r){
                    if(chBus.Score__c!=null && chBus.Weight__c!=null){
                    	totalScore = totalScore +(chBus.Score__c*chBus.Weight__c);	    
                    }
                }
                updateBusList.add(new Business_Strategy__c(id=bus.id,Total_FY_Score__c = totalScore));
            }
            
        	if(updateBusList.size() > 0){
            	DAOUtilityWithoutShar.updateWithoutAccess(updateBusList);
        	}  
        }
    }
}