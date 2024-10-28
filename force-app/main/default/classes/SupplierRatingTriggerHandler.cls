/* *******************************************************************************************************
* Name               : SupplierRatingTriggerHandler                                                     *
* Description        : SRM - Trigger handler class for Supplier Rating record                                 *
* Created Date       : 24-Jul-2020                                                                      *
* Created By         : Mateusz Wolak-Książek                                                            *
* -----------------------------------------------------------------------------------------------       *
* VERSION    AUTHOR            DATE                                                                     *
*   1.0 -    Mateusz W-K       24-Jul-2020 Initial version                                              *
*                                                                                                       *
*                                                                                                       *
******************************************************************************************************* */
public without sharing class SupplierRatingTriggerHandler extends SRM_TriggerHandler {
    public override void beforeInsert(){
        List<Supplier_Rating__c> newList = (List<Supplier_Rating__c>) Trigger.new;
        //This code commented now. Should be enabled once test data is fixed.
        //SupplierRatingTriggerHelper.popuateUniqueKey(newList);
    }
    public override void beforeUpdate(){
        List<Supplier_Rating__c> newList = (List<Supplier_Rating__c>) Trigger.new;
        Map<Id, Supplier_Rating__c> newSupplierRatingMap = (Map<Id, Supplier_Rating__c>) Trigger.newMap;
         Map<Id, Supplier_Rating__c> oldSupplierRatingMap = (Map<Id, Supplier_Rating__c>) Trigger.oldMap;
        //SupplierRatingTriggerHelper.updateLastRatedTimestamp(newList, oldSupplierRatingMap);
        SupplierRatingTriggerHelper.markToCreateFollowUpTask(newSupplierRatingMap,oldSupplierRatingMap);
        //This code commented now. Should be enabled once test data is fixed.
        //SupplierRatingTriggerHelper.popuateUniqueKey(newList);
        
    }
    public override void afterUpdate() {
        Map<Id, Supplier_Rating__c> newSupplierRatingMap = (Map<Id, Supplier_Rating__c>) Trigger.newMap;
        Map<Id, Supplier_Rating__c> oldSupplierRatingMap = (Map<Id, Supplier_Rating__c>) Trigger.oldMap;       
        SupplierRatingTriggerHelper.createSupplierRatingHistoryRecords(oldSupplierRatingMap, newSupplierRatingMap);
    }
    
    public override void afterDelete() {
        Map<Id, Supplier_Rating__c> oldSupplierRatingMap = (Map<Id, Supplier_Rating__c>) Trigger.oldMap;        
        SupplierRatingTriggerHelper.createSupplierRatingHistoryRecords(oldSupplierRatingMap, null);
    }    
    
}