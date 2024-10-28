/* *******************************************************************************************************
 * Name               : SupplierContractTrigger                                                          *
 * Description        : Trigger for Supplier_Contract__c object                                          *
 * Created Date       : 06-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
trigger SupplierContractTrigger on Supplier_Contract__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_SUPPLIER_CONTRACT)) return;

    new SupplierContractTriggerHandler().run();
}