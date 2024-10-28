trigger ValueElementTrigger on Value_Element__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_VALUE_ELEMENT)) return;

    new ValueElementTriggerHandler().run();

}