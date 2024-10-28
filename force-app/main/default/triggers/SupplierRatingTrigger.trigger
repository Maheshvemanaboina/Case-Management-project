/**
 * Created by mateuszwolak on 24/07/2020.
 */
trigger SupplierRatingTrigger on Supplier_Rating__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SUPPLIER_RATING)) return;

    new SupplierRatingTriggerHandler().run();
}