/* *******************************************************************************************************
 * Name               : SupplierKpiTrigger                                                               *
 * Description        : Trigger for Supplier KPI object                                                  *
 * Created Date       : 14-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       14-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
trigger SupplierKpiTrigger on Supplier_KPI__c (before insert, before update, before delete, after insert, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SUPPLIER_KPI)) return;

    new SupplierKpiTriggerHandler().run();
}