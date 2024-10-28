/* *******************************************************************************************************
 * Name               : SupplierLocationTriggerHandler                                                   *
 * Description        : SRM - Trigger handler for Supplier Location object                                     *
 * Created Date       : 03-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       03-Aug-2020 Initial version                                              *
 *   1.1 -    Mateusz W-K       10-Aug-2020 Delete supplier rating on location deletion added            *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SupplierLocationTriggerHandler extends SRM_TriggerHandler {

    public override void beforeInsert(){
        List<Supplier_Location__c> newSupplierLocationList = ( List<Supplier_Location__c>) Trigger.new;
        avoidDuplicateLocaitonPerSupplier(newSupplierLocationList, null);
    }
    public override void afterInsert() {
        Map<Id, Supplier_Location__c> newSupplierLocationMap = (Map<Id, Supplier_Location__c>) Trigger.newMap;

        createSupplierRatingsForLocations(null, newSupplierLocationMap);
    }

    public override void beforeUpdate(){
        List<Supplier_Location__c> newSupplierLocationList = ( List<Supplier_Location__c>) Trigger.new;
        Map<Id, Supplier_Location__c> oldSupplierLocationMap = (Map<Id, Supplier_Location__c>) Trigger.oldMap;
        avoidDuplicateLocaitonPerSupplier(newSupplierLocationList, oldSupplierLocationMap);    }

    public override void afterUpdate() {
        Map<Id, Supplier_Location__c> oldSupplierLocationMap = (Map<Id, Supplier_Location__c>) Trigger.oldMap;
        Map<Id, Supplier_Location__c> newSupplierLocationMap = (Map<Id, Supplier_Location__c>) Trigger.newMap;

        createSupplierRatingsForLocations(oldSupplierLocationMap, newSupplierLocationMap);
    }

    /**
     * @description: for each location attach supplier ratings that have same segment set as on supplier hub record
     * @param oldSupplierLocationMap
     * @param newSupplierLocationMap
     */
    private void createSupplierRatingsForLocations(Map<Id, Supplier_Location__c> oldSupplierLocationMap, Map<Id, Supplier_Location__c> newSupplierLocationMap) {
        List<Supplier_Location__c> supplierLocationWithSupplierHubList = new List<Supplier_Location__c>();

        if(oldSupplierLocationMap == null && newSupplierLocationMap != null) { //insert
            for(Supplier_Location__c newSl : newSupplierLocationMap.values()) {
                if(String.isNotBlank(newSl.Supplier_Hub__c) && String.isNotBlank(newSl.Location__c)) {
                    supplierLocationWithSupplierHubList.add(newSl);
                }
            }

        } else if(oldSupplierLocationMap != null && newSupplierLocationMap != null) { //update
            for(Supplier_Location__c oldSl : oldSupplierLocationMap.values()) {
                Supplier_Location__c newSl = newSupplierLocationMap.get(oldSl.Id);
                if(oldSl.Supplier_Hub__c != newSl.Supplier_Hub__c || oldSl.Location__c != newSl.Location__c) {
                    if(String.isNotBlank(newSl.Supplier_Hub__c) && String.isNotBlank(newSl.Location__c)) {
                        supplierLocationWithSupplierHubList.add(newSl);
                    }
                }
            }
        }
		
        if(!supplierLocationWithSupplierHubList.isEmpty()) {
            // commenting the code as a part of New rating stratagy no to create ratings on supplier locaiton insert or udpate.
            //Database.executeBatch(new SupplierRatingsCreationBatch(supplierLocationWithSupplierHubList, SupplierRatingsCreationBatch.Type.SUPPLIER_LOCATION_CONTEX), 1);
        }

    }
    //method identifying duplicate Locaitons
    public static void avoidDuplicateLocaitonPerSupplier(List<Supplier_Location__c> newSuppliers,Map<Id, Supplier_Location__c> oldMap){
        Set<Id> supplierIds = new Set<Id>();
        Map<Id,List<Supplier_Location__c>> relatedLocations = new Map<Id,List<Supplier_Location__c>>();
        Map<Id, Supplier_Location__c> locationMap = new Map<Id, Supplier_Location__c>();
        for(Supplier_Location__c obj: newSuppliers){
            if(trigger.isBefore && trigger.isInsert){
                supplierIds.add(obj.Supplier_Hub__c);
            }
            if(trigger.isBefore && trigger.isUpdate){
                Supplier_Location__c oldLocation = oldMap.get(obj.Id);
                if(oldLocation.Business_Group__c != obj.Business_Group__c && obj.Business_Group__c != null){
                    supplierIds.add(obj.Supplier_Hub__c);
                }
            }
        }
        if(! supplierIds.isEmpty()){
             relatedLocations = getAssoicatedLocaitons(supplierIds);
        }
        if(! relatedLocations.isEmpty()){
            validate(relatedLocations, newSuppliers);
        }
    }
    private static Map<Id,List<Supplier_Location__c>> getAssoicatedLocaitons(Set<Id> supplierIds){
        Map<Id,List<Supplier_Location__c>> supplierVsLocations = new Map<Id,List<Supplier_Location__c>>();
        for(Supplier_Location__c obj: [SELECT Id, Location__c, Supplier_Hub__c,Supplier_Hub__r.Supplier_Name__c,Business_Group__c FROM Supplier_Location__c WHERE Supplier_Hub__c IN: supplierIds AND Location__c != NULL]){
            if(supplierVsLocations.get(obj.Supplier_Hub__c) != null){
               supplierVsLocations.get(obj.Supplier_Hub__c).add(obj);
            }else{
                supplierVsLocations.put(obj.Supplier_Hub__c, new List<Supplier_Location__c> { obj });
            }            
        }return supplierVsLocations;
    }
    public static void validate(Map<Id,List<Supplier_Location__c>> supplierVsLocations, List<Supplier_Location__c> newSuppliers){
        for(Supplier_Location__c obj: newSuppliers){
            if(supplierVsLocations.get(obj.Supplier_Hub__c) != null){
                List<Supplier_Location__c> exisitngLocations = supplierVsLocations.get(obj.Supplier_Hub__c);
                if(! exisitngLocations.isEmpty()){
                    for(Supplier_Location__c objLocation: exisitngLocations){
                        if(obj.Location__c == objLocation.Location__c && obj.Business_Group__c == objLocation.Business_Group__c){
                             obj.addError('Location already exist for Supplier');
                        }
                    }
                }
            }
        }
    }
    
   
}