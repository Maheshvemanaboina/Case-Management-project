/* *******************************************************************************************************
 * Name               : AssessmentScoringTriggerHandler                                                  *
 * Description        : SRM - Handler class for AssessmentScoringTrigger - should hold only methods            *
 *      which filter records that match criteria and prepare data - then it should pass records to a     *
 *      service / manager class - simple functionalities / assignments can occur in this class           *
 * Created Date       : 06-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */

public without sharing class AssessmentScoringTriggerHandler extends SRM_TriggerHandler {

    public override void beforeInsert() {
        List<Assessment_Scoring__c> newAssessmentScoringList = (List<Assessment_Scoring__c>) Trigger.new;

        filterAssessmentField(newAssessmentScoringList, null);
    }

    public override void afterInsert() {
        Map<Id, Assessment_Scoring__c> newAssessmentScoringMap = (Map<Id, Assessment_Scoring__c>) Trigger.newMap;

        filterAssessmentField(newAssessmentScoringMap.values(), null);
    }


    /**
     * @author: Mateusz Wolak-Książek
     * @description: filter records that have Assessment__c lookup field in or was changed and prepare data for service class
     * @param newAssessmentScoringList
     * @param oldAssessmentScoringMap
     */
    private void filterAssessmentField(List<Assessment_Scoring__c> newAssessmentScoringList, Map<Id,Assessment_Scoring__c> oldAssessmentScoringMap) {
        List<Assessment_Scoring__c> assessmentScoringList = new List<Assessment_Scoring__c>();
        Boolean errorOccurred = false;
        //update call if oldAssessmentScoringMap is NOT NULL
        if(oldAssessmentScoringMap != NULL) {
            for(Assessment_Scoring__c newAS : newAssessmentScoringList) {
                Assessment_Scoring__c oldAS = oldAssessmentScoringMap.get(newAS.Id);
                //check if assessment field was changed and new one is not empty - then add it to Assessment Scoring List
                if(oldAS.Assessment__c != newAS.Assessment__c && newAS.Assessment__c != NULL) {
                    assessmentScoringList.add(newAS);
                }
            }
        } else { //insert call if oldAssessmentScoringMap is NULL
            for (Assessment_Scoring__c newAS : newAssessmentScoringList) {
                //check if assessment field is not null - then add it to Assessment Scoring List
                if(newAS.Assessment__c != NULL) {
                    assessmentScoringList.add(newAS);
                }
            }
        }

        //if list of assesstment records is not empty - invoke service methods depending on context
        if(!assessmentScoringList.isEmpty()) {
            // invoke service methods and action related to after trigger context
            if(Trigger.isBefore) {
                AssessmentScoringService.copyAssessmentRelatedInformation(assessmentScoringList);
            }
            // invoke service methods and actions related to after trigger context
            if(Trigger.isAfter) {
                AssessmentScoringService.createAssessmentScoringItems(assessmentScoringList);
            }
        }

    }


}