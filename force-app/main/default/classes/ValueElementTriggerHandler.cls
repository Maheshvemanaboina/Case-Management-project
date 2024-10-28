/* *******************************************************************************************************
 * Name               : ValueElementTriggerHandler                                                       *
 * Description        : SRM - Handler class for ValueElementTrigger                                            *
 * Created Date       : 28-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       28-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class ValueElementTriggerHandler extends SRM_TriggerHandler {

    public override void afterInsert() {
        Map<Id, Value_Element__c> newValueElementsMap = (Map<Id, Value_Element__c>) Trigger.newMap;

        handleValueElementRecords(null, newValueElementsMap);
    }


    public override void afterUpdate() {
        Map<Id, Value_Element__c> oldValueElementsMap = (Map<Id, Value_Element__c>) Trigger.oldMap;
        Map<Id, Value_Element__c> newValueElementsMap = (Map<Id, Value_Element__c>) Trigger.newMap;

        handleValueElementRecords(oldValueElementsMap, newValueElementsMap);
    }

    public override void beforeDelete() {
        Map<Id, Value_Element__c> oldValueElementsMap = (Map<Id, Value_Element__c>)Trigger.oldMap;
        setErrorOnDeleteOperation(oldValueElementsMap);
    }


    private void handleValueElementRecords(Map<Id, Value_Element__c> oldValueElementsMap, Map<Id, Value_Element__c> newValueElementsMap) {
        Map<Id, Value_Element__c> activeValueElementMap = new Map<Id, Value_Element__c>();
        Map<Id, Value_Element__c> inactiveValueElementMap = new Map<Id, Value_Element__c>();

        if(oldValueElementsMap == null && newValueElementsMap != null) { //insert
            for(Value_Element__c newVe : newValueElementsMap.values()) {
                if(newVe.Is_Active__c && String.isNotBlank(newVe.Segment__c)) {
                    activeValueElementMap.put(newVe.Id, newVe);
                }
            }
        } else if(oldValueElementsMap != null && newValueElementsMap != null) { //update
            for(Value_Element__c oldVe : oldValueElementsMap.values()) {
                Value_Element__c newVe = newValueElementsMap.get(oldVe.Id);
                if(oldVe.Is_Active__c != newVe.Is_Active__c) {
                    if(newVe.Is_Active__c) {
                        activeValueElementMap.put(newVe.Id, newVe);
                    } else {
                        inactiveValueElementMap.put(newVe.Id, newVe);
                    }
                }
            }
        }

        if(!inactiveValueElementMap.isEmpty()) {
            //changes relating the new rating functionality
            //Database.executeBatch(new SupplierRatingsDeletionBatch(inactiveValueElementMap));
        }

        if(!activeValueElementMap.isEmpty()) {
            //changes relating the new rating functionality
            //Database.executeBatch(new SupplierRatingsCreationBatch(activeValueElementMap));
        }
    }

    private void setErrorOnDeleteOperation(Map<Id, Value_Element__c> oldValueElementsMap) {
        for(Value_Element__c ve : oldValueElementsMap.values()) {
            ve.addError(Label.SRM_CannotDeleteValueElement);
        }
    }

}