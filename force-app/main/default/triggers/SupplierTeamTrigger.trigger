/* *******************************************************************************************************
 * Name               : SupplierTeamTrigger                                                              *
 * Description        : Trigger for Suplier_Team__c object                                               *
 * Created Date       : 06-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
trigger SupplierTeamTrigger on Supplier_Team__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SUPPLIER_TEAM)) return;

    new SupplierTeamTriggerHandler().run();
}