/**
 * Created by mateuszwolak on 06/07/2020.
 */

trigger AssessmentScoringTrigger on Assessment_Scoring__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_ASSESSMENT_SCORING)) return;

    new AssessmentScoringTriggerHandler().run();
}