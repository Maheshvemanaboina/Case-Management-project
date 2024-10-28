global without sharing class BatchAddMissingRatingRecords implements Database.Batchable<sObject> {
    global  Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Segment__c, Supplier_Rating_Header__c FROM Supplier_Hub__c WHERE Segment__c != NULL');
    }
    global void execute(Database.BatchableContext bc, List<Supplier_Hub__c> records){
        SYSTEM.debug('SCOPE '+ records.size());
        Map<Id, Supplier_Hub__c> supplierMap = new Map<Id, Supplier_Hub__c>(records);
        Map<String, List<Supplier_Location__c>> supplierVsLocationMap = getRelatedLocations(supplierMap.keySet());
        Map<String, List<Supplier_Rating__c>> supplierVsRatingMap = getRelatedRatings(supplierMap.keySet());
        Map<String, List<Value_Element__c>> segment2ValueElementsMap = ValueElementService.getSegmentToValueElementsMap();
        List<Supplier_Rating__c> supplierRatingList = new List<Supplier_Rating__c>();
        for(Supplier_Hub__c obj: records){
            if(supplierVsLocationMap.get(obj.Id) != NULL){
                //here we are itering on all active fc locations associated with supplier
                for(Supplier_Location__c objSL: supplierVsLocationMap.get(obj.Id)){
                    //here we are getting all the active ratings associated with fc location in loop.
                    List<Supplier_Rating__c> relatedRatings = supplierVsRatingMap.get(obj.Id);
                    List<Supplier_Rating__c> matchedRatingRecords = new List<Supplier_Rating__c>();
                    if(segment2ValueElementsMap != null && !segment2ValueElementsMap.isEmpty()) {
                        if (String.isNotBlank(objSL.Supplier_Hub__r.Segment__c) && segment2ValueElementsMap.containsKey(objSL.Supplier_Hub__r.Segment__c)) {
                            for (Value_Element__c ve : segment2ValueElementsMap.get(objSL.Supplier_Hub__r.Segment__c)) {
                                 Boolean doesNotContain = true;
                                if(supplierVsRatingMap.containsKey(objSL.Supplier_Hub__c)) {
                                    for(Supplier_Rating__c currSr : supplierVsRatingMap.get(objSL.Supplier_Hub__c)) {
                                        if(currSr.SRM_Business_Group__c != null){
                                            if(currSr.Value_Element__c == ve.Id && currSr.Location__c == objSL.Location__c && currSr.SRM_Business_Group__c == objSL.Business_Group__c) {
                                                doesNotContain = false;
                                            }else{
                                                if(currSr.Value_Element__c == ve.Id && currSr.Location__c == objSL.Location__c ) {
                                                    doesNotContain = false;
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                                system.debug('doesNotContain '+ doesNotContain);
                                if(doesNotContain) {
                                    if(ve.Segment__c != 'Transactional' &&  objSL.Location__r.is_Active__c ){
                                        supplierRatingList.add(new Supplier_Rating__c(SRM_Business_Group__c = objSL.Business_Group__c,Value_Element__c = ve.Id, Supplier_Rating_Header__c = objSL.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = objSL.Supplier_Hub__c, Location__c = objSL.Location__c,FC_Location__c= objSL.Id));
                                        
                                    }else if(ve.Segment__c == 'Transactional' && objSL.Supplier_Hub__r.SQM_Scope__c &&  objSL.Location__r.is_Active__c){
                                        supplierRatingList.add(new Supplier_Rating__c(SRM_Business_Group__c = objSL.Business_Group__c,Value_Element__c = ve.Id, Supplier_Rating_Header__c = objSL.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = objSL.Supplier_Hub__c, Location__c = objSL.Location__c,FC_Location__c= objSL.Id));
                                        
                                    }
                                }
                            }
                            
                        }
                        
                    }
                }
            }
        }
        if(!supplierRatingList.isEmpty()) {
            system.debug('supplierRatingList '+ supplierRatingList);
            Database.insert(supplierRatingList, false);
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    private static Map<String, List<Supplier_Location__c>> getRelatedLocations(Set<Id> supplierIds){
        Map<String, List<Supplier_Location__c>> supplierVsLocationMap = new Map<String, List<Supplier_Location__c>>();
        for(Supplier_Location__c obj: [SELECT Id, Location__c, Location__r.is_Active__c,Supplier_Hub__c,Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__r.SQM_Scope__c, Supplier_Hub__r.Segment__c,Business_Group__c FROM Supplier_Location__c WHERE Supplier_Hub__c IN: supplierIds AND Location__c != NULL AND Is_Active__c = TRUE AND Business_Group__c != NULL]){
            if(supplierVsLocationMap.containsKey(obj.Supplier_Hub__c)) {
                supplierVsLocationMap.get(obj.Supplier_Hub__c).add(obj);
            } else {
                supplierVsLocationMap.put(obj.Supplier_Hub__c, new List<Supplier_Location__c> { obj });
            }
        }
        return supplierVsLocationMap;
    }
    private static Map<String, List<Supplier_Rating__c>> getRelatedRatings(Set<Id> supplierIds){
        Map<String, List<Supplier_Rating__c>> supplierVsRatingMap = new Map<String, List<Supplier_Rating__c>>();
        for(Supplier_Rating__c obj: [SELECT Id, Supplier_Hub__c, Value_Element__c,Supplier_Rating_Header__c,Location__c,SRM_Business_Group__c FROM Supplier_Rating__c WHERE Supplier_Hub__c IN: supplierIds AND Rating_Is_Active__c = TRUE]){
            if(supplierVsRatingMap.containsKey(obj.Supplier_Hub__c)) {
                supplierVsRatingMap.get(obj.Supplier_Hub__c).add(obj);
            } else {
                supplierVsRatingMap.put(obj.Supplier_Hub__c, new List<Supplier_Rating__c> { obj });
            }
        }
        return supplierVsRatingMap;
    }    
}