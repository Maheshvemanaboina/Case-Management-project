public without sharing class ForecastAccuracyScoringHandler {
    
    public static void updateScore(List<Forecast_Accuracy__c> forecastAccuracyRecordList){
        
        List<Forecast_Accuracy__c> forecastAccuracyList = new List<Forecast_Accuracy__c>();
        for(Forecast_Accuracy__c childForeCast : forecastAccuracyRecordList){
            if(childForeCast.Confirmed_by_FCI_Sales_Manager__c == 'Yes' || childForeCast.Confirmed_by_FCI_Sales_Manager__c == 'No'){
                forecastAccuracyList.add(childForeCast);
            }
        }
        
        if(forecastAccuracyList.size() > 0){
            set<Id> recordtypeIdSet = new set<Id>();
        set<Id> childForecasIdSet = new set<Id>();
        for(Forecast_Accuracy__c childForeCast : forecastAccuracyList){
            recordtypeIdSet.add(childForeCast.RecordTypeId);
            childForecasIdSet.add(childForeCast.Id);
        }
        Map<Id,RecordType> recordTypeMap = new Map<Id,RecordType>([SELECT Id,Name,DeveloperName FROM RecordType WHERE Id IN : recordtypeIdSet]);
        Map<Id,List<Forecast_Accuracy__c>> parentChildMap = new Map<Id,List<Forecast_Accuracy__c>>();
        for(Forecast_Accuracy__c childForeCast : forecastAccuracyList){
            if(recordTypeMap.containskey(childForeCast.RecordTypeId) && recordTypeMap.get(childForeCast.RecordTypeId).DeveloperName == 'Local_Stock'){
                if(parentChildMap.containskey(childForeCast.Forecast_Accuracy_Local_Stock__c)){
                    parentChildMap.get(childForeCast.Forecast_Accuracy_Local_Stock__c).add(childForeCast);
                }else{
                    parentChildMap.put(childForeCast.Forecast_Accuracy_Local_Stock__c,new List<Forecast_Accuracy__c>{ childForeCast });
                }
            }
        }
        List<Forecast_Accuracy__c> existingForecastList = [SELECT Id,Forecast_Accuracy_Local_Stock__c,RecordType.DeveloperName,Confirmed_by_FCI_Sales_Manager__c FROM Forecast_Accuracy__c WHERE ID NOT IN : childForecasIdSet AND Forecast_Accuracy_Local_Stock__c IN : parentChildMap.keyset() AND RecordType.DeveloperName='Local_Stock'];
        for(Forecast_Accuracy__c childForeCast : existingForecastList){
            if(parentChildMap.containskey(childForeCast.Forecast_Accuracy_Local_Stock__c)){
                parentChildMap.get(childForeCast.Forecast_Accuracy_Local_Stock__c).add(childForeCast);
            }
        }

         Map<Id,Forecast_Accuracy__c> parentRecordMap = new Map<Id,Forecast_Accuracy__c>([SELECT Id,Score__c,Weight__c,RecordType.DeveloperName FROM Forecast_Accuracy__c WHERE ID IN : parentChildMap.keyset() AND RecordType.DeveloperName='Forecast_Accuracy_Local_Stock']);
        Integer count = 0;
        Integer maxVal = 0;
        for(Id parentId : parentChildMap.keyset()){
            count = 0;
            maxVal = 0;
            maxVal = parentChildMap.get(parentId).size();
            for(Forecast_Accuracy__c childForeCast : parentChildMap.get(parentId)){
                if(childForeCast.Confirmed_by_FCI_Sales_Manager__c == 'Yes' && childForeCast.Local_Stock_Status__c == '> One month of stock'){
                    count++;
                  
                }else if(childForeCast.Confirmed_by_FCI_Sales_Manager__c == 'Yes' && childForeCast.Local_Stock_Status__c == 'One month of stock'){
                    count=0;
                    count = maxVal - 1;
                    Break;
                }else{
                   count=0; 
                    Break;
                    
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
                    Forecast_Accuracy__c fa = new Forecast_Accuracy__c();
                    fa.Id = parentId;
                    fa.Score__c = 3;
                    fa.Weight__c = 1;
                    parentRecordMap.put(parentId,fa);
                }
            }else{
                if(count < maxVal && count > 0){
                     if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 1;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 1;
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null){
                    Forecast_Accuracy__c fa = new Forecast_Accuracy__c();
                    fa.Id = parentId;
                    fa.Score__c = 1;
                    fa.Weight__c = 1;
                    parentRecordMap.put(parentId,fa);
                }
                }else{
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).Score__c!=null){
                        parentRecordMap.get(parentId).Score__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) && parentRecordMap.get(parentId).RecordType.DeveloperName!=null && parentRecordMap.get(parentId).Weight__c!=null){
                        parentRecordMap.get(parentId).Weight__c = 0;
                    }
                    if(parentRecordMap.containskey(parentId) &&  parentRecordMap.get(parentId).Score__c == null && parentRecordMap.get(parentId).Weight__c ==null ){
                     Forecast_Accuracy__c fa = new Forecast_Accuracy__c();
                    fa.Id = parentId;
                    fa.Score__c = 0;
                    fa.Weight__c = 0;
                    parentRecordMap.put(parentId,fa);
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
        Method Name : UpdateBucketTotalScore(List<Forecast_Accuracy__c> acPlanList, Map<Id,Forecast_Accuracy__c> oldMap)

        1. calculating the total score at main bucket level.
        
        @PARAMS
            1. NAME ( acPlanList )  => TYPE ( List<Forecast_Accuracy__c> ) 	=> DESCRIPTION ( Trigger.new from ForecastAccuracyTriggerHandler )
            2. NAME ( oldMap )  	=> TYPE ( Map<Id,Forecast_Accuracy__c> ) => DESCRIPTION ( Trigger.oldmap from ForecastAccuracyTriggerHandler )
    */
    public static void UpdateBucketTotalScore(List<Forecast_Accuracy__c> acPlanList, Map<Id,Forecast_Accuracy__c> oldMap){
        set<Id> parentBusStrtgs = new set<Id>();
        if(acPlanList!=null){
            for(Forecast_Accuracy__c bst : acPlanList){
            
                if(oldMap == null || oldMap.isEmpty() ||bst.Score__c!=oldMap.get(bst.id).Score__c || bst.Weight__c!=oldMap.get(bst.id).Weight__c){
                    parentBusStrtgs.add(bst.Parent_Forecast__c);
                }
                
                if(oldMap!=null && bst.Parent_Forecast__c!=oldMap.get(bst.id).Parent_Forecast__c){
                    parentBusStrtgs.add(bst.Parent_Forecast__c);
                    parentBusStrtgs.add(oldMap.get(bst.id).Parent_Forecast__c);
                }
                
            }
            
        } else if(oldMap !=null){
            for(Forecast_Accuracy__c oBst : oldMap.values()){
                parentBusStrtgs.add(oBst.Parent_Forecast__c);
            }
        }
        
        if(!parentBusStrtgs.isEmpty()){
            //Total_FY_Score__c
            list<Forecast_Accuracy__c> updateBusList = new List<Forecast_Accuracy__c>();
            for(Forecast_Accuracy__c bus : [SELECT id,(SELECT id,Total_Score__c,Score__c,Weight__c FROM Forecasts__r) 
                                            FROM Forecast_Accuracy__c WHERE id IN:parentBusStrtgs]){
                Decimal totalScore = 0;
            	for(Forecast_Accuracy__c chBus:bus.Forecasts__r){
                    if(chBus.Score__c!=null && chBus.Weight__c!=null){
                    	totalScore = totalScore +(chBus.Score__c*chBus.Weight__c);	    
                    }
                }
                updateBusList.add(new Forecast_Accuracy__c(id=bus.id,Total_FY_Score__c = totalScore));
            }
            
        	if(updateBusList.size() > 0){
            	DAOUtilityWithoutShar.updateWithoutAccess(updateBusList);
        	}  
        }
    }
}