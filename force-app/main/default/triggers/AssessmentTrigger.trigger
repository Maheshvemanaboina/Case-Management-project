/**
 * Created by sszcz on 24.07.2020.
 */

trigger AssessmentTrigger on Assessment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_ASSESSMENT)) return;

    new AssessmentTriggerHandler().run();
}