/* *******************************************************************************************************
 * Name               : SRM_AssessmentScorItmTrigger                                                     *
 * Description        : Trigger for Assessment object                                                    *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 21/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   21/09/2020          Initial version                      *
 ******************************************************************************************************* */
trigger SRM_AssessmentScorItmTrigger on Assessment_Scoring_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!SRM_TriggerHandler.isTriggerEnabled(ConstUtils.TRG_NAME_ASSESSMENT_SCORING_ITEM)) return;
    new SRM_AssessmentScorItmTriggerHandler().run();
}