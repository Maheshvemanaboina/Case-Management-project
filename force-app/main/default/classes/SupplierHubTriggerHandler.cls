/* *******************************************************************************************************
 * Name               : SupplierHubTriggerHandler                                                        *
 * Description        : SRM - Handler class for SupplierHubTrigger - should hold only methods which filter     *
 *      records that match criteria and prepare data - then it should pass records to a                  *
 *      service / manager class - simple functionalities / assignments can occur in this class           *
 * Created Date       : 06-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SupplierHubTriggerHandler extends SRM_TriggerHandler {


    public override void beforeInsert() {
        List<Supplier_Hub__c> newSupplierHubList = (List<Supplier_Hub__c>) Trigger.new;

        checkIfAccountHasSupplierHubRelationship(null, newSupplierHubList);
        populateSearchableField(newSupplierHubList);
        populateParent(newSupplierHubList, null);
    }

    public override void afterInsert() {
        Map<Id, Supplier_Hub__c> newSupplierHubMap = (Map<Id, Supplier_Hub__c>) Trigger.newMap;

        handleSupplierRatingRecords(null, newSupplierHubMap);
    }

    public override void beforeUpdate() {
        Map<Id, Supplier_Hub__c> newSupplierHubMap = (Map<Id, Supplier_Hub__c>) Trigger.newMap;
        Map<Id, Supplier_Hub__c> oldSupplierHubMap = (Map<Id, Supplier_Hub__c>) Trigger.oldMap;

        checkIfAccountHasSupplierHubRelationship(oldSupplierHubMap, newSupplierHubMap.values());
        populateSearchableField(newSupplierHubMap.values());
        populateParent(newSupplierHubMap.values(), oldSupplierHubMap);
    }

    public override void afterUpdate() {
        Map<Id, Supplier_Hub__c> oldSupplierHubMap = (Map<Id, Supplier_Hub__c>) Trigger.oldMap;
        Map<Id, Supplier_Hub__c> newSupplierHubMap = (Map<Id, Supplier_Hub__c>) Trigger.newMap;

        handleSupplierRatingRecords(oldSupplierHubMap, newSupplierHubMap);
    }






    //TODO: MWK - if that method should stay here I believe it should be refactored
    //method author: dawidlebieda
    public static void checkIfAccountHasSupplierHubRelationship(Map<Id, Supplier_Hub__c> oldMap, List<Supplier_Hub__c> supplierHubs) {
        List<Id> accIds = new List<Id>();
        for (Supplier_Hub__c supplierHub : supplierHubs) {
//            Supplier_Hub__c oldSupplierHub = oldMap.get(supplierHub.Id);
//            if(supplierHub.Supplier_Account__c != oldSupplierHub.Supplier_Account__c){
//                supplierHub.addError('The Account already has a Supplier Hub link');
//            }
            if (supplierHub.Supplier_Account__c != null) {
                accIds.add(supplierHub.Supplier_Account__c);
            }
        }
        List<Account> accounts = [SELECT Id, Supplier_Hub_ID__c FROM Account WHERE Id = :accIds];
        List<Supplier_Hub__c> supplierHubsWithAccIds = [SELECT Supplier_Account__c FROM Supplier_Hub__c WHERE Supplier_Account__c = :accIds];

        for (Supplier_Hub__c supplierHub : supplierHubs) {
            if (supplierHub.Supplier_Account__c == null) {
                continue;
            }
            for (Account account : accounts) {
                //first error check - Account already has a Supplier Hub Id
                if (account.Id == supplierHub.Supplier_Account__c && (account.Supplier_Hub_ID__c != null && account.Supplier_Hub_ID__c != supplierHub.Id)) {
                    supplierHub.addError('The Account already has a Supplier Hub link1');
                    break;
                }
            }

            //check two
            integer occurrences = 0;
            for (Supplier_Hub__c supplierHub2 : supplierHubsWithAccIds) {
                System.debug('for: ' + occurrences);
                if (supplierHub.Supplier_Account__c == supplierHub2.Supplier_Account__c) {
                    occurrences++;
                }
                if (occurrences > 1) {
                    supplierHub.addError('The Account already has a Supplier Hub link2');
                    break;
                }
            }

        }
    }

    /**
     * @description: handle all supplier rating operations - create supplier_rating_header__c on insert, delete supplier_rating__c records on update call and create new ones related to specified segment
     * @param oldSupplierHubMap - Map of Supplier_Hub__c record (old)
     * @param newSupplierHubMap - Map of Supplier_Hub__c record (new - changed)
     */
    private void handleSupplierRatingRecords(Map<Id, Supplier_Hub__c> oldSupplierHubMap, Map<Id, Supplier_Hub__c> newSupplierHubMap) {
        List<Id> supplierRatingHeaderIds2DeleteSupplierRatings = new List<Id>();
        Map<String, List<Supplier_Rating_Header__c>> segment2SupplierRatingHeadersMap = new Map<String, List<Supplier_Rating_Header__c>>();
        List<Supplier_Rating_Header__c> supplierRatingHeadersToInsert = new List<Supplier_Rating_Header__c>();

        Map<Id, Supplier_Hub__c> supplierHubMapToCreateSupplierRatings = new Map<Id, Supplier_Hub__c>();

        if(oldSupplierHubMap == null && newSupplierHubMap != null) { //insert call
            for(Supplier_Hub__c newSh : newSupplierHubMap.values()) {
                Supplier_Rating_Header__c supplierRatingHeader = new Supplier_Rating_Header__c(Supplier_Hub__c = newSh.Id);
                //no matter what - on record insert create Supplier_Rating_Header__c record
                supplierRatingHeadersToInsert.add(supplierRatingHeader);
            }
        } else if(oldSupplierHubMap != null && newSupplierHubMap != null) { //update call
            for(Supplier_Hub__c oldSh : oldSupplierHubMap.values()) {
                Supplier_Hub__c newSh = newSupplierHubMap.get(oldSh.Id);

                //segment was changed so need to remove old rating records and create connect a new ones
                if(oldSh.Segment__c != newSh.Segment__c && String.isNotBlank(newSh.Segment__c)) {
                    Supplier_Rating_Header__c supplierRatingHeader;
                    //check if supplier rating header already exists (validation)
                    if(newSh.Supplier_Rating_Header__c != null) {
                        supplierRatingHeader = new Supplier_Rating_Header__c(Id = newSh.Supplier_Rating_Header__c, Supplier_Hub__c = newSh.Id);
                    } else {
                        supplierRatingHeader = new Supplier_Rating_Header__c(Supplier_Hub__c = newSh.Id);
                        supplierRatingHeadersToInsert.add(supplierRatingHeader);
                    }

                    supplierHubMapToCreateSupplierRatings.put(newSh.Id,newSh);
                }
            }
        }

		//Commenting the code as a part of SSRA-1024
        /*if(!supplierHubMapToCreateSupplierRatings.isEmpty()) {
            deleteSupplierRatingsOnSegmentChange(supplierHubMapToCreateSupplierRatings);
        }*/

        if(!supplierRatingHeadersToInsert.isEmpty()) {
            // commeting as no longer required due to new rating approach
            //SupplierRatingHeaderService.createSupplierRatingHeaders(supplierRatingHeadersToInsert);
        }

        if(!supplierHubMapToCreateSupplierRatings.isEmpty()) {
            // commeting as no longer required due to new rating approach
            //createSupplierRatings(supplierHubMapToCreateSupplierRatings);
        }
    }

    /**
     * @param supplierHubMapToCreateSupplierRatings
     
    private void createSupplierRatings(Map<Id, Supplier_Hub__c> supplierHubMapToCreateSupplierRatings) {
        Map<String, List<Value_Element__c>> segment2ValueElementsMap = ValueElementService.getSegmentToValueElementsMap();
        List<Supplier_Rating__c> supplierRatingList = new List<Supplier_Rating__c>();
		//here we query FC Locations associated with Supplier where fc locaiton is active true and the location should be active.
        for(Supplier_Location__c sl :[
                SELECT Supplier_Hub__c, Supplier_Hub__r.Segment__c, Supplier_Hub__r.Supplier_Rating_Header__c, Location__c,Location__r.Is_Active__c,Business_Group__c,Supplier_Hub__r.SQM_Scope__c
                FROM Supplier_Location__c
                WHERE Supplier_Hub__c IN :supplierHubMapToCreateSupplierRatings.keySet() AND Location__r.Is_Active__c = TRUE and Is_Active__c = TRUE
        ]) {
            if (String.isNotBlank(sl.Supplier_Hub__r.Segment__c) && segment2ValueElementsMap.containsKey(sl.Supplier_Hub__r.Segment__c) && segment2ValueElementsMap.get(sl.Supplier_Hub__r.Segment__c) != null) {
                for (Value_Element__c ve : segment2ValueElementsMap.get(sl.Supplier_Hub__r.Segment__c)) {
                    if(sl.Supplier_Hub__r.Segment__c != 'Transactional' &&  sl.Location__r.Is_Active__c && sl.Business_Group__c != null ){
						supplierRatingList.add(new Supplier_Rating__c(SRM_Business_Group__c = sl.Business_Group__c, Value_Element__c = ve.Id, Supplier_Rating_Header__c = sl.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = sl.Supplier_Hub__c, Location__c = sl.Location__c,FC_Location__c= sl.Id));
                    }else if(sl.Supplier_Hub__r.Segment__c == 'Transactional' && sl.Supplier_Hub__r.SQM_Scope__c &&  sl.Location__r.Is_Active__c && sl.Business_Group__c != null){
						supplierRatingList.add(new Supplier_Rating__c(SRM_Business_Group__c = sl.Business_Group__c, Value_Element__c = ve.Id, Supplier_Rating_Header__c = sl.Supplier_Hub__r.Supplier_Rating_Header__c, Supplier_Hub__c = sl.Supplier_Hub__c, Location__c = sl.Location__c, FC_Location__c= sl.Id));

                    }
                }
            }
        }

        if(!supplierRatingList.isEmpty()) {
            try{
                insert supplierRatingList;
            }catch(exception e){
                system.debug('error while crating rating on segmet chagne '+ e.getMessage());
            }
            
        }
    }
*/
    /*private void deleteSupplierRatingsOnSegmentChange(Map<Id, Supplier_Hub__c> supplierHubMapToCreateSupplierRatings) {
        delete [SELECT Id FROM Supplier_Rating__c WHERE Supplier_Hub__c IN: supplierHubMapToCreateSupplierRatings.keySet()];
    }*/

    private static void populateSearchableField(List<Supplier_Hub__c> newSupplierHubList)
    {
        List<Id> accountIds = new List<Id>();
        if(newSupplierHubList != null  && newSupplierHubList.size() > 0){
            for(Supplier_Hub__c sh: newSupplierHubList){
                if(sh.Supplier_Account__c != null){
                    accountIds.add(sh.Supplier_Account__c);
                }
            }
            for(Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accountIds]){
                for(Supplier_Hub__c sh: newSupplierHubList){
                    if(acc.Name != null && sh.Supplier_Account__c != null && acc.Id != null && acc.Id == sh.Supplier_Account__c ){
                            sh.Account_Name_Searchable__c = acc.Name;
                    }
                }
            }
        }
    }
    //populate the parent supplier for the hierarchy component.
    public static void populateParent(List<Supplier_Hub__c> newList, Map<Id, Supplier_Hub__c> oldList){
        for(Supplier_Hub__c obj: newList){
            //before isnert trigger.
            if(trigger.isBefore && trigger.isInsert){
                if(obj.Parent_Supplier__c != NULL && obj.Inactive__c == false){
                    obj.Parent_Supplier_Active__c = obj.Parent_Supplier__c;
                }
            }
            if(trigger.isBefore && trigger.isUpdate){
                if(obj.Parent_Supplier__c != oldList.get(obj.Id).Parent_Supplier__c && obj.Inactive__c == false){
                    obj.Parent_Supplier_Active__c = obj.Parent_Supplier__c;
                }
            }
        }
    }
}