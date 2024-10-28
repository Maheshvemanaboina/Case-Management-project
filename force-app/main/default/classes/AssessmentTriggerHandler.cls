/**
 * Created by sszcz on 24.07.2020.
 */

public with sharing class AssessmentTriggerHandler extends SRM_TriggerHandler {

    public override void afterUpdate() {
        List<Assessment__c> newAssessmentList = (List<Assessment__c>) Trigger.new;
        Map<Id, Assessment__c> oldAssessmentMap = (Map<Id, Assessment__c>) Trigger.oldMap;

        createAssessmentScoringRecords(newAssessmentList, oldAssessmentMap);
    }

    public static void createAssessmentScoringRecords(List<Assessment__c> newAssessmentList, Map<Id, Assessment__c> oldAssessmentMap) {
        List<Assessment__c> approvedAssessmentList = new List<Assessment__c>();

        for (Assessment__c newAssessment : newAssessmentList){
            Assessment__c oldAssessment = oldAssessmentMap.get(newAssessment.Id);

            if (newAssessment.Assessment_Scoring_Group_Status__c == ConstUtils.ASSESSMENT_ASS_SCORING_GROUP_STATUS_SUBMITTED &&
                    oldAssessment.Assessment_Scoring_Group_Status__c != ConstUtils.ASSESSMENT_ASS_SCORING_GROUP_STATUS_SUBMITTED){
                approvedAssessmentList.add(newAssessment);
            }
        }

        if (!approvedAssessmentList.isEmpty()){
            Database.executeBatch(new SRM_AssessmentScoringsCreationBatch(new Map<Id, Assessment__c>(approvedAssessmentList)), 5);
        }
    }

}