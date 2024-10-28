/* *******************************************************************************************************
 * Name               : SupplierRatingsCreationBatch                                                     *
 * Description        : SRM - Batch class - handle supplier_rating__c records creation                         *
 * Created Date       : 28-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       28-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class SupplierRatingsCreationBatch implements Database.Batchable<sObject> {

    public enum Type { VALUE_ELEMENT_CONTEXT, SUPPLIER_LOCATION_CONTEX }
    public Type type;


    Map<String, List<Value_Element__c>> segment2ValueElementsMap;
    List<Supplier_Location__c> supplierLocationList;

    public SupplierRatingsCreationBatch(Map<Id, Value_Element__c> valueElementMap) {
        segment2ValueElementsMap = new Map<String, List<Value_Element__c>>();
        for(Value_Element__c ve :valueElementMap.values()) {
            if(segment2ValueElementsMap.containsKey(ve.Segment__c)) {
                segment2ValueElementsMap.get(ve.Segment__c).add(ve);
            } else {
                segment2ValueElementsMap.put(ve.Segment__c, new List<Value_Element__c> { ve });
            }
        }
        this.type = SupplierRatingsCreationBatch.Type.VALUE_ELEMENT_CONTEXT;
    }

    public SupplierRatingsCreationBatch(List<Supplier_Location__c> supplierLocationList, Type type) {
        this.supplierLocationList = supplierLocationList;
        this.type = type;
    }

    public Database.querylocator start(Database.BatchableContext BC) {
        if(this.type == SupplierRatingsCreationBatch.Type.VALUE_ELEMENT_CONTEXT) {
            return Database.getQueryLocator([
                    SELECT Supplier_Hub__c, Supplier_Hub__r.Segment__c, Supplier_Hub__r.Supplier_Rating_Header__c, Location__c,Location__r.Is_Active__c,Supplier_Hub__r.SQM_Scope__c,Business_Group__c
                    FROM Supplier_Location__c
                    WHERE Supplier_Hub__r.Segment__c IN :segment2ValueElementsMap.keySet()
                    ORDER BY Supplier_Hub__c
            ]);
        } else if(this.type == SupplierRatingsCreationBatch.Type.SUPPLIER_LOCATION_CONTEX) {
            return Database.getQueryLocator([
                    SELECT Supplier_Hub__c, Supplier_Hub__r.Segment__c, Supplier_Hub__r.Supplier_Rating_Header__c, Location__c,Location__r.Is_Active__c, Supplier_Hub__r.SQM_Scope__c, Business_Group__c
                    FROM Supplier_Location__c
                    WHERE Id IN :supplierLocationList AND
                    Supplier_Hub__r.Segment__c <> NULL
            ]);
        }
        //return random query locator when other type not specified
        return Database.getQueryLocator([SELECT Id FROM User WHERE Id =: Userinfo.getUserId()]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(this.type == SupplierRatingsCreationBatch.Type.VALUE_ELEMENT_CONTEXT) {
            onValueElementContext(scope);
        } else if(this.type == SupplierRatingsCreationBatch.Type.SUPPLIER_LOCATION_CONTEX) {
            onSupplierLocationContext(scope);
        }
    }

    public void finish(Database.BatchableContext BC) {}

    public void onValueElementContext(List<sObject> scope) {
        List<Supplier_Location__c> supplierLocationList = (List<Supplier_Location__c>)scope;
        List<Supplier_Rating__c> supplierRatingInsertList = new List<Supplier_Rating__c>();

        supplierLocationList = preValidateRecords(supplierLocationList);
        Map<Id, List<Supplier_Rating__c>> currentSupplierRatings = getSupplierIdToCurrentSupplierRatings(supplierLocationList);

        for(Supplier_Location__c sl : supplierLocationList) {
            for(Value_Element__c ve : segment2ValueElementsMap.get(sl.Supplier_Hub__r.Segment__c)) {
                Boolean doesNotContain = true;
                if(currentSupplierRatings.containsKey(sl.Supplier_Hub__c)) {
                    for(Supplier_Rating__c currSr : currentSupplierRatings.get(sl.Supplier_Hub__c)) {
                        if(currSr.Value_Element__c == ve.Id && currSr.Location__c == sl.Location__c && currSr.SRM_Business_Group__c == sl.Business_Group__c) {
                            doesNotContain = false;
                        }
                    }
                }
                if(doesNotContain) {
                    if(sl.Supplier_Hub__r.Segment__c != 'Transactional' &&  sl.Location__r.Is_Active__c ){
                        supplierRatingInsertList.add(new Supplier_Rating__c(SRM_Business_Group__c = sl.Business_Group__c, Value_Element__c = ve.Id, Supplier_Rating_Header__c = sl.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = sl.Supplier_Hub__c, Location__c = sl.Location__c, FC_Location__c= sl.Id));
                        
                    }else if(sl.Supplier_Hub__r.Segment__c == 'Transactional' && sl.Supplier_Hub__r.SQM_Scope__c &&  sl.Location__r.Is_Active__c){
                        supplierRatingInsertList.add(new Supplier_Rating__c(SRM_Business_Group__c = sl.Business_Group__c, Value_Element__c = ve.Id, Supplier_Rating_Header__c = sl.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = sl.Supplier_Hub__c, Location__c = sl.Location__c, FC_Location__c= sl.Id));
                        
                    }
                }
            }
        }
        Database.insert(supplierRatingInsertList, false);
    }

    public void onSupplierLocationContext(List<sObject> scope) {
        List<Supplier_Location__c> supplierLocationList = (List<Supplier_Location__c>)scope;
        List<Supplier_Rating__c> supplierRatingInsertList = new List<Supplier_Rating__c>();

        supplierLocationList = preValidateRecords(supplierLocationList);
        Map<Id, List<Supplier_Rating__c>> currentSupplierRatings = getSupplierIdToCurrentSupplierRatings(supplierLocationList);
        
        
        Map<String, List<Value_Element__c>> segment2ValueElementsMap = ValueElementService.getSegmentToValueElementsMap();
        List<Supplier_Rating__c> supplierRatingList = new List<Supplier_Rating__c>();
		system.debug('supplierRatingList '+supplierRatingList);
        if(segment2ValueElementsMap != null && !segment2ValueElementsMap.isEmpty()) {
            for (Supplier_Location__c sl : (List<Supplier_Location__c>)scope) {
                if (String.isNotBlank(sl.Supplier_Hub__r.Segment__c) && segment2ValueElementsMap.containsKey(sl.Supplier_Hub__r.Segment__c)) {
                    for (Value_Element__c ve : segment2ValueElementsMap.get(sl.Supplier_Hub__r.Segment__c)) {
                        Boolean doesNotContain = true;
                        system.debug('already exist '+ currentSupplierRatings.containsKey(sl.Supplier_Hub__c));
                        if(currentSupplierRatings.containsKey(sl.Supplier_Hub__c)) {
                            for(Supplier_Rating__c currSr : currentSupplierRatings.get(sl.Supplier_Hub__c)) {
                                if(currSr.Value_Element__c == ve.Id && currSr.Location__c == sl.Location__c && currSr.SRM_Business_Group__c == sl.Business_Group__c) {
                                    doesNotContain = false;
                                }
                            }
                        }
                        SYSTEM.debug('doesNotContain '+doesNotContain);
                        if(doesNotContain) {
                            if(sl.Supplier_Hub__r.Segment__c != 'Transactional' &&  sl.Location__r.Is_Active__c ){
                                supplierRatingList.add(new Supplier_Rating__c(SRM_Business_Group__c = sl.Business_Group__c, Value_Element__c = ve.Id, Supplier_Rating_Header__c = sl.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = sl.Supplier_Hub__c, Location__c = sl.Location__c, FC_Location__c= sl.Id));
                                
                            }else if(sl.Supplier_Hub__r.Segment__c == 'Transactional' && sl.Supplier_Hub__r.SQM_Scope__c &&  sl.Location__r.Is_Active__c){
                                supplierRatingList.add(new Supplier_Rating__c(SRM_Business_Group__c = sl.Business_Group__c, Value_Element__c = ve.Id, Supplier_Rating_Header__c = sl.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = sl.Supplier_Hub__c, Location__c = sl.Location__c, FC_Location__c= sl.Id));
                                
                            }
                        }
                    }
                }
            }
			system.debug('supplierRatingList '+supplierRatingList);
           
            if(!supplierRatingList.isEmpty()) {
                //Database.insert(supplierRatingList, false);
                try{
                    insert supplierRatingList;
                }catch(exception e){
                    system.debug('exception '+ e.getMessage());
                }
            }
        }
    }

    /**
     * @description: check if supplier_rating_header__c field is not blank and create new record if it is
     * @param supplierHubList
     */
    public List<Supplier_Location__c> preValidateRecords(List<Supplier_Location__c> supplierLocations) {
        List<Supplier_Rating_Header__c> supplierRatingHeaderInsertList = new List<Supplier_Rating_Header__c>();
        Set<String> supplierHubIds = Utils.fetchSet(supplierLocations, 'Supplier_Hub__c');

        for(Supplier_Hub__c sh : [SELECT Supplier_Rating_Header__c FROM Supplier_Hub__c WHERE Id IN: supplierHubIds]) {
            if(String.isBlank(sh.Supplier_Rating_Header__c)) {
                supplierRatingHeaderInsertList.add(new Supplier_Rating_Header__c(Supplier_Hub__c = sh.Id));
            }
        }
        if(!supplierRatingHeaderInsertList.isEmpty()) {
            SupplierRatingHeaderService.createSupplierRatingHeaders(supplierRatingHeaderInsertList);
            //retrieve records with updated header lookup field
            supplierLocations = [
                    SELECT Supplier_Hub__r.Segment__c, Supplier_Hub__r.Supplier_Rating_Header__c, Location__c, Location__r.Is_Active__c
                    FROM Supplier_Location__c
                    WHERE Id IN: supplierLocations
            ];
        }

        return supplierLocations;
    }

    public Map<Id, List<Supplier_Rating__c>> getSupplierIdToCurrentSupplierRatings(List<Supplier_Location__c> supplierLocationList) {
        Set<String> locationIds = Utils.fetchSet(supplierLocationList, 'Location__c');
        Set<String> supplierHubIds = Utils.fetchSet(supplierLocationList, 'Supplier_Hub__c');
        Map<Id, List<Supplier_Rating__c>> supplierIdToCurrentSupplierRatings = new Map<Id, List<Supplier_Rating__c>>();

        for(Supplier_Rating__c sr : [
                SELECT Supplier_Hub__c, Location__c, Value_Element__c,SRM_Business_Group__c
                FROM Supplier_Rating__c
                WHERE Supplier_Hub__c IN: supplierHubIds
                AND Location__c IN: locationIds
        ]) {
            if(supplierIdToCurrentSupplierRatings.containsKey(sr.Supplier_Hub__c)) {
                supplierIdToCurrentSupplierRatings.get(sr.Supplier_Hub__c).add(sr);
            } else {
                supplierIdToCurrentSupplierRatings.put(sr.Supplier_Hub__c, new List<Supplier_Rating__c> { sr });
            }
        }

        return supplierIdToCurrentSupplierRatings;
    }


}