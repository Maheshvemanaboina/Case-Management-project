/* *******************************************************************************************************
 * Name               : SupplierProjectTrigger                                                           *
 * Description        : Trigger for Supplier_Project__c object                                           *
 * Created Date       : 27-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       27-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
trigger SupplierProjectTrigger on Supplier_Project__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SUPPLIER_PROJECT)) return;

    new SupplierProjectTriggerHandler().run();
}