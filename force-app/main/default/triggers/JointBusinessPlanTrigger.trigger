trigger JointBusinessPlanTrigger on Joint_Business_Plan__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_JOINT_BUSINESS_PLAN)) return;

    new JointBusinessPlanTriggerHandler().run();
}