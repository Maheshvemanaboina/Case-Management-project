public without sharing class FCICustomerSupportScoringHandler {
    
    public static void updateScore(List<FCI_Customer_Support__c> fciCustomerSupportRecordList){
        List<FCI_Customer_Support__c> fciCustomerSupportList = new List<FCI_Customer_Support__c>();
        for(FCI_Customer_Support__c childSupportRec : fciCustomerSupportRecordList){
            if(childSupportRec.Confirmed_by_FCI_Sales_Manager__c == 'Yes' || childSupportRec.Confirmed_by_FCI_Sales_Manager__c == 'No'){
                fciCustomerSupportList.add(childSupportRec);
            }
        }
        if(fciCustomerSupportList.size() > 0){
            set<Id> recordtypeIdSet = new set<Id>();
        set<Id> childForecasIdSet = new set<Id>();
        for(FCI_Customer_Support__c childSupportRec : fciCustomerSupportList){
            recordtypeIdSet.add(childSupportRec.RecordTypeId);
            childForecasIdSet.add(childSupportRec.Id);
        }
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE Id IN : recordtypeIdSet]);
        Map<Id,List<FCI_Customer_Support__c>> parentChildMap = new Map<Id,List<FCI_Customer_Support__c>>();
        for(FCI_Customer_Support__c childSupportRec : fciCustomerSupportList){
            if(recordTypeMap.containskey(childSupportRec.RecordTypeId) && recordTypeMap.get(childSupportRec.RecordTypeId).DeveloperName == 'Order_Process'){
                if(parentChildMap.containskey(childSupportRec.FCI_Customer_Support_Order_Process__c)){
                    parentChildMap.get(childSupportRec.FCI_Customer_Support_Order_Process__c).add(childSupportRec);
                }else{
                    parentChildMap.put(childSupportRec.FCI_Customer_Support_Order_Process__c,new List<FCI_Customer_Support__c>{ childSupportRec });
                }
            }
        }
        List<FCI_Customer_Support__c> existingfciCustomerSupportList = [SELECT Id,FCI_Customer_Support_Order_Process__c,RecordType.DeveloperName,Confirmed_by_FCI_Sales_Manager__c,Order_policy_adherence__c FROM FCI_Customer_Support__c WHERE ID NOT IN : childForecasIdSet AND FCI_Customer_Support_Order_Process__c IN : parentChildMap.keyset() AND RecordType.DeveloperName='Order_Process'];
        for(FCI_Customer_Support__c childSupportRec : existingfciCustomerSupportList){
            if(parentChildMap.containskey(childSupportRec.FCI_Customer_Support_Order_Process__c)){
                parentChildMap.get(childSupportRec.FCI_Customer_Support_Order_Process__c).add(childSupportRec);
            }
        }
        Map<Id,FCI_Customer_Support__c> parentRecordMap = new Map<Id,FCI_Customer_Support__c>([SELECT Id,Score__c,Weight__c,RecordType.DeveloperName FROM FCI_Customer_Support__c WHERE ID IN : parentChildMap.keyset() AND RecordType.DeveloperName='FCI_Customer_Support_Order_Process']);
        Integer count = 0;
        Integer count2 = 0;
        Integer maxVal = 0;
        for(Id parentId : parentChildMap.keyset()){
            count = 0;
            maxVal = 0;
            maxVal = parentChildMap.get(parentId).size();
            for(FCI_Customer_Support__c childSupportRec : parentChildMap.get(parentId)){
                if(childSupportRec.Confirmed_by_FCI_Sales_Manager__c == 'Yes' && childSupportRec.Order_policy_adherence__c == '>90% orders in line with order policy'){
                    count++;
                }else if(childSupportRec.Confirmed_by_FCI_Sales_Manager__c == 'Yes' && childSupportRec.Order_policy_adherence__c == '>80 & <90% orders in line with order policy'){
                    count2++;
                }
            }
            if(count == maxVal){
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c != null){
                    parentRecordMap.get(parentId).Score__c = 3;
                }
                if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Weight__c!=null){
                    parentRecordMap.get(parentId).Weight__c =1;
                }
                if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null  ){
                    FCI_Customer_Support__c fciSupp = new FCI_Customer_Support__c();
                    fciSupp.Id = parentId;
                    fciSupp.Score__c = 3;
                    fciSupp.Weight__c = 1;
                    parentRecordMap.put(parentId,fciSupp);
                }
            }else{
                if((count < maxVal && count > 0) || count2 > 0){
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 1;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 1;
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null){
                        FCI_Customer_Support__c fciSupp = new FCI_Customer_Support__c();
                        fciSupp.Id = parentId;
                        fciSupp.Score__c = 1;
                        fciSupp.Weight__c = 1;
                        parentRecordMap.put(parentId,fciSupp);
                    }
                }else{
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null ){
                        FCI_Customer_Support__c fciSupp = new FCI_Customer_Support__c();
                        fciSupp.Id = parentId;
                        fciSupp.Score__c = 0;
                        fciSupp.Weight__c = 1;
                        parentRecordMap.put(parentId,fciSupp);
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
        Method Name : UpdateBucketTotalScore(List<FCI_Customer_Support__c> acPlanList, Map<Id,FCI_Customer_Support__c> oldMap)

        1. calculating the total score at main bucket level.
        
        @PARAMS
            1. NAME ( acPlanList )  => TYPE ( List<FCI_Customer_Support__c> ) 	=> DESCRIPTION ( Trigger.new from FCICustomerSupportTriggerHandler )
            2. NAME ( oldMap )  	=> TYPE ( Map<Id,FCI_Customer_Support__c> ) => DESCRIPTION ( Trigger.oldmap from FCICustomerSupportTriggerHandler )
    */
    public static void UpdateBucketTotalScore(List<FCI_Customer_Support__c> acPlanList, Map<Id,FCI_Customer_Support__c> oldMap){
        set<Id> parentBusStrtgs = new set<Id>();
        if(acPlanList!=null){
            for(FCI_Customer_Support__c bst : acPlanList){
            
                if(oldMap == null || oldMap.isEmpty() ||bst.Score__c!=oldMap.get(bst.id).Score__c || bst.Weight__c!=oldMap.get(bst.id).Weight__c){
                    parentBusStrtgs.add(bst.Parent_FCI_Customer_Support__c);
                }
                
                if(oldMap!=null && bst.Parent_FCI_Customer_Support__c!=oldMap.get(bst.id).Parent_FCI_Customer_Support__c){
                    parentBusStrtgs.add(bst.Parent_FCI_Customer_Support__c);
                    parentBusStrtgs.add(oldMap.get(bst.id).Parent_FCI_Customer_Support__c);
                }
                
            }
            
        } else if(oldMap !=null){
            for(FCI_Customer_Support__c oBst : oldMap.values()){
                parentBusStrtgs.add(oBst.Parent_FCI_Customer_Support__c);
            }
        }
        
        if(!parentBusStrtgs.isEmpty()){
            //Total_FY_Score__c
            list<FCI_Customer_Support__c> updateBusList = new List<FCI_Customer_Support__c>();
            for(FCI_Customer_Support__c bus : [SELECT id,(SELECT id,Total_Score__c,Score__c,Weight__c FROM FCI_Customer_Supports__r) 
                                            FROM FCI_Customer_Support__c WHERE id IN:parentBusStrtgs]){
                Decimal totalScore = 0;
            	for(FCI_Customer_Support__c chBus:bus.FCI_Customer_Supports__r){
                    if(chBus.Score__c!=null && chBus.Weight__c!=null){
                    	totalScore = totalScore +(chBus.Score__c*chBus.Weight__c);	    
                    }
                }
                updateBusList.add(new FCI_Customer_Support__c(id=bus.id,Total_FY_Score__c = totalScore));
            }
            
        	if(updateBusList.size() > 0){
            	DAOUtilityWithoutShar.updateWithoutAccess(updateBusList);
        	}  
        }
    }
}