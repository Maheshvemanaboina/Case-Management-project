/**
 * Created by dawidlebieda on 27/05/2020.
 */

trigger SupplierHubTrigger on Supplier_Hub__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SUPPLIER_HUB)) return;

    new SupplierHubTriggerHandler().run();

}