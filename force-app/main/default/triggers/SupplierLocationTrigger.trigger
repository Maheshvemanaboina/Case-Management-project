trigger SupplierLocationTrigger on Supplier_Location__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SUPPLIER_LOCATION)) return;

    new SupplierLocationTriggerHandler().run();
}