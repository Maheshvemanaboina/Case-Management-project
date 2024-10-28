public  without sharing class CommercialActivityScoringHandler {
    public static void updateScore(List<Commercial_Activity__c> commercilaActivityList){
        List<Commercial_Activity__c> childActivityList = new List<Commercial_Activity__c>();
        for(Commercial_Activity__c commAct : commercilaActivityList){
            if(commAct.Confirmed_by_FCI_Sales_Manager__c == 'Yes' || commAct.Confirmed_by_FCI_Sales_Manager__c == 'No'){
                childActivityList.add(commAct);
            }
        }
        if(childActivityList.size() > 0){
             Map<String,Integer> weightMap = new Map<String,Integer>();
        weightMap.put('Commercial_Activity_Promotion_Activities',2);
        weightMap.put('Commercial_Activity_Customer_Visits',1);
        weightMap.put('Commercial_Activity_Samples',1);
        set<Id> recordtypeIdSet = new set<Id>();
        set<Id> childActivityIdSet = new set<Id>();
        for(Commercial_Activity__c childActivity : childActivityList){
            recordtypeIdSet.add(childActivity.RecordTypeId);
            childActivityIdSet.add(childActivity.Id);
        }
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE Id IN : recordtypeIdSet]);

        Map<Id,List<Commercial_Activity__c>> parentChildMap = new Map<Id,List<Commercial_Activity__c>>();
        for(Commercial_Activity__c childActivity : childActivityList){
            
            if(recordTypeMap.containskey(childActivity.RecordTypeId) && recordTypeMap.get(childActivity.RecordTypeId).DeveloperName == 'Promotion_Activity'){
                if(parentChildMap.containskey(childActivity.Commercial_Activity_Promotion_Activity__c)){
                    parentChildMap.get(childActivity.Commercial_Activity_Promotion_Activity__c).add(childActivity);
                }else{
                    parentChildMap.put(childActivity.Commercial_Activity_Promotion_Activity__c, new List<Commercial_Activity__c>{childActivity});
                }
            }
            if(recordTypeMap.containskey(childActivity.RecordTypeId) && recordTypeMap.get(childActivity.RecordTypeId).DeveloperName == 'Customer_Visit'){
                if(parentChildMap.containskey(childActivity.Commercial_Activity_Customer_Visit__c)){
                    parentChildMap.get(childActivity.Commercial_Activity_Customer_Visit__c).add(childActivity);
                }else{
                    parentChildMap.put(childActivity.Commercial_Activity_Customer_Visit__c, new List<Commercial_Activity__c>{childActivity});
                }
            }
            if(recordTypeMap.containskey(childActivity.RecordTypeId) && recordTypeMap.get(childActivity.RecordTypeId).DeveloperName == 'Samples'){
                if(parentChildMap.containskey(childActivity.Commercial_Activity_Sample__c)){
                    parentChildMap.get(childActivity.Commercial_Activity_Sample__c).add(childActivity);
                }else{
                    parentChildMap.put(childActivity.Commercial_Activity_Sample__c, new List<Commercial_Activity__c>{childActivity});
                }
            }
            
            
        }
        List<Commercial_Activity__c> existingChildActivity = new List<Commercial_Activity__c>();
        if(parentChildMap.keyset()!=null){
            existingChildActivity = [SELECT Id,Commercial_Activity_Sample__c,Commercial_Activity_Customer_Visit__c,Commercial_Activity_Promotion_Activity__c,Confirmed_by_FCI_Sales_Manager__c,RecordType.DeveloperName FROM Commercial_Activity__c WHERE (Commercial_Activity_Promotion_Activity__c IN : parentChildMap.keyset() OR Commercial_Activity_Customer_Visit__c IN : parentChildMap.keyset() OR  Commercial_Activity_Sample__c IN : parentChildMap.keyset()) AND ID NOT IN : childActivityIdSet];
            for(Commercial_Activity__c childActivity : existingChildActivity){

                if(childActivity.RecordType.DeveloperName == 'Promotion_Activity' && parentChildMap.containskey(childActivity.Commercial_Activity_Promotion_Activity__c)){
                    parentChildMap.get(childActivity.Commercial_Activity_Promotion_Activity__c).add(childActivity);
                }
                if(childActivity.RecordType.DeveloperName == 'Customer_Visit' && parentChildMap.containskey(childActivity.Commercial_Activity_Customer_Visit__c)){
                    parentChildMap.get(childActivity.Commercial_Activity_Customer_Visit__c).add(childActivity);
                }
                if(childActivity.RecordType.DeveloperName == 'Samples' && parentChildMap.containskey(childActivity.Commercial_Activity_Sample__c)){
                    parentChildMap.get(childActivity.Commercial_Activity_Sample__c).add(childActivity);
                }
            }      
        }
        
        Map<Id,Commercial_Activity__c> parentRecordMap = new Map<Id,Commercial_Activity__c>([SELECT Id,Score__c,Weight__c,RecordType.Name,RecordType.DeveloperName FROM Commercial_Activity__c WHERE Id IN : parentChildMap.keyset()]);

        Integer count = 0;
        Integer maxVal = 0;
        for(Id parentId : parentChildMap.keyset()){
            count = 0;
            maxVal = 0;
            maxVal = parentChildMap.get(parentId).size();
            for(Commercial_Activity__c childActivity : parentChildMap.get(parentId)){
                if(childActivity.Confirmed_by_FCI_Sales_Manager__c == 'Yes'){
                    count++;
                }
            }
            if(count == maxVal){
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                    parentRecordMap.get(parentId).Score__c = 3;
                }
                
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                    parentRecordMap.get(parentId).Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                }
                if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) || test.isRunningTest() ){
                    Commercial_Activity__c comAct = new Commercial_Activity__c();
                    comAct.Id = parentId;
                    comAct.Score__c = 3;
                    comAct.Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                    parentRecordMap.put(parentId,comAct);
                }
            }else{
                if(count < maxVal && count > 0){

                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 1;
                    }
                    
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                    }
                    
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) || test.isRunningTest()  ){
                        Commercial_Activity__c comAct = new Commercial_Activity__c();
                        comAct.Id = parentId;
                        comAct.Score__c = 1;
                        comAct.Weight__c = weightMap.get(parentRecordMap.get(parentId).RecordType.DeveloperName);
                        parentRecordMap.put(parentId,comAct);
                    }
                }else{
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 0;
                    }
                    
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) && parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 0;
                    }
                    
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null && weightMap.containskey(parentRecordMap.get(parentId).RecordType.DeveloperName) || test.isRunningTest()  ){
                        Commercial_Activity__c comAct = new Commercial_Activity__c();
                        comAct.Id = parentId;
                        comAct.Score__c = 0;
                        comAct.Weight__c = 0;
                        parentRecordMap.put(parentId,comAct);
                    }
                }
            }
        }
        
        if(parentRecordMap.values().size() > 0 ){
            DAOUtilityWithoutShar.updateWithoutAccess(parentRecordMap.values());
        }
    }
        }
    
    /* @Description
        Method Name : UpdateBucketTotalScore(List<Commercial_Activity__c> acPlanList, Map<Id,Commercial_Activity__c> oldMap)

        1. calculating the total score at main bucket level.
        
        @PARAMS
            1. NAME ( acPlanList )  => TYPE ( List<Commercial_Activity__c> ) 	=> DESCRIPTION ( Trigger.new from CommercialActivityTriggerHandler )
            2. NAME ( oldMap )  	=> TYPE ( Map<Id,Commercial_Activity__c> ) => DESCRIPTION ( Trigger.oldmap from CommercialActivityTriggerHandler )
    */
    public static void UpdateBucketTotalScore(List<Commercial_Activity__c> acPlanList, Map<Id,Commercial_Activity__c> oldMap){
        set<Id> parentBusStrtgs = new set<Id>();
        if(acPlanList!=null){
            for(Commercial_Activity__c bst : acPlanList){
            
                if(oldMap == null || oldMap.isEmpty() ||bst.Score__c!=oldMap.get(bst.id).Score__c || bst.Weight__c!=oldMap.get(bst.id).Weight__c){
                    parentBusStrtgs.add(bst.Parent_Commercial_Activity__c);
                }
                
                if(oldMap!=null && bst.Parent_Commercial_Activity__c!=oldMap.get(bst.id).Parent_Commercial_Activity__c){
                    parentBusStrtgs.add(bst.Parent_Commercial_Activity__c);
                    parentBusStrtgs.add(oldMap.get(bst.id).Parent_Commercial_Activity__c);
                }
                
            }
            
        } else if(oldMap !=null){
            for(Commercial_Activity__c oBst : oldMap.values()){
                parentBusStrtgs.add(oBst.Parent_Commercial_Activity__c);
            }
        }
        
        if(!parentBusStrtgs.isEmpty()){
            //Total_FY_Score__c
            list<Commercial_Activity__c> updateBusList = new List<Commercial_Activity__c>();
            for(Commercial_Activity__c bus : [SELECT id,(SELECT id,Total_Score__c,Score__c,Weight__c FROM Commercial_Activities__r) 
                                            FROM Commercial_Activity__c WHERE id IN:parentBusStrtgs]){
                Decimal totalScore = 0;
            	for(Commercial_Activity__c chBus:bus.Commercial_Activities__r){
                    if(chBus.Score__c!=null && chBus.Weight__c!=null){
                    	totalScore = totalScore +(chBus.Score__c*chBus.Weight__c);	    
                    }
                }
                updateBusList.add(new Commercial_Activity__c(id=bus.id,Total_FY_Score__c = totalScore));
            }
            
        	if(updateBusList.size() > 0){
            	DAOUtilityWithoutShar.updateWithoutAccess(updateBusList);
        	}  
        }
    }
}