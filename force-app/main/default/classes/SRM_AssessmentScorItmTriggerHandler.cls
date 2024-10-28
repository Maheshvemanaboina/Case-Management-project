/* *******************************************************************************************************
 * Name               : SRM_AssessmentScorItmTriggerHandler                                              *
 * Description        : SRM - Scoring Group Member trigger handler class file                                  *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 21/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   21/09/2020          Initial version                      *
 ******************************************************************************************************* */
public with sharing class SRM_AssessmentScorItmTriggerHandler extends SRM_TriggerHandler {

    public override void afterInsert() {
        Map<Id, Assessment_Scoring_Item__c> newAssessmentScorItmMap = (Map<Id, Assessment_Scoring_Item__c>) Trigger.newMap;
        //commented the code as no longer relevant.
        //createTaskForAssessment(newAssessmentScorItmMap);
    }

    /**
     * Task creation method for each assessment items
     * @param newAssessmentScorItmMap map of new items from trigger
     * Commented the method as no longer requried per busines  - Pankaj P Modak SSRA-572
     
    public static void createTaskForAssessment(Map<Id, Assessment_Scoring_Item__c> newAssessmentScorItmMap) {
        List<Task> taskListToInsert = new List<Task>();
        if (newAssessmentScorItmMap != null && newAssessmentScorItmMap.size() > 0) {
            Set<Id> assessmentScoringIds = new Set<Id>();
            for (Assessment_Scoring_Item__c asi : newAssessmentScorItmMap.values()) {
                if (asi.Assessment_Scoring__c != null && !assessmentScoringIds.contains(asi.Assessment_Scoring__c)) {
                    assessmentScoringIds.add(asi.Assessment_Scoring__c);
                }
            }
            Map<Id, Assessment_Scoring__c> assessmentScoringMap = new Map<Id, Assessment_Scoring__c>([
                    SELECT Id, Assessment__c, Assessment_Description__c, Assessment_Type__c, Assessment__r.Effective_End_Date__c
                    FROM Assessment_Scoring__c
                    WHERE Id IN :assessmentScoringIds]
            );
            Set<String> alreadyAddedAssessmentScorings = new Set<String>();
            for (Assessment_Scoring_Item__c asi : newAssessmentScorItmMap.values()) {
                String scoringTaskKey = asi.Assessment_Scoring__c+''+asi.User__c;
                if (asi.Assessment_Scoring__c != null &&
                        !alreadyAddedAssessmentScorings.contains(scoringTaskKey) &&
                        assessmentScoringMap.containsKey(asi.Assessment_Scoring__c) &&
                        assessmentScoringMap.get(asi.Assessment_Scoring__c).Assessment_Description__c != null &&
                        assessmentScoringMap.get(asi.Assessment_Scoring__c).Assessment_Type__c != null &&
                        assessmentScoringMap.get(asi.Assessment_Scoring__c).Assessment_Type__c == ConstUtils.ASSESSMENT_TYPE_SURVEY) {
                    Task newTask = new Task();
                    String subject = String.format(Label.SRM_Assesment_Fill_Up_Subject, new List<String>{
                            assessmentScoringMap.get(asi.Assessment_Scoring__c).Assessment_Description__c
                    });
                    if(subject.length() > 255){
                        subject = subject.substring(0, 255); //get first 255 characters of label combined with params
                    }
                    newTask.Subject = subject;
                    newTask.ActivityDate = assessmentScoringMap.get(asi.Assessment_Scoring__c).Assessment__r.Effective_End_Date__c;
                    newTask.OwnerId = asi.User__c; //assign it to user from scoring item
                    newTask.Type = ConstUtils.TASK_TYPE_ASSESSMENT; //with specyfic type
                    newTask.WhatId = asi.Assessment_Scoring__c;

                    taskListToInsert.add(newTask);
                    alreadyAddedAssessmentScorings.add(scoringTaskKey);
                }
            }
            if (taskListToInsert.size() > 0) {
                insert taskListToInsert;
            }
        }
    }*/

}