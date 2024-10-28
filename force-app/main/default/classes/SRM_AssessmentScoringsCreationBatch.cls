/* *******************************************************************************************************
 * Name               : SRM_AssessmentScoringsCreationBatch                                              *
 * Description        : SRM - Batch class - handle Assessment_Scoring__c records creation                *
 * Created Date       : 28-Oct-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       28-Oct-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public without sharing class SRM_AssessmentScoringsCreationBatch implements Database.Batchable<sObject> {

    Map<Id, Assessment__c> approvedAssessmentMap;

    public SRM_AssessmentScoringsCreationBatch(Map<Id, Assessment__c> approvedAssessmentMap) {
        this.approvedAssessmentMap = approvedAssessmentMap;
    }

    public Database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, Assessment__c, Supplier_Hub__c
                FROM Assessment_Scoring_Group__c
                WHERE Assessment__c IN :approvedAssessmentMap.keySet()
        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Assessment_Scoring_Group__c> assScoringGroupList = (List<Assessment_Scoring_Group__c>) scope;
        List<Assessment_Scoring__c> assScoringInsertList = new List<Assessment_Scoring__c>();

        Set<String> supplierHubIdSet = Utils.fetchSet(assScoringGroupList, 'Supplier_Hub__c');
        Set<String> assessmentIdSet = Utils.fetchSet(assScoringGroupList, 'Assessment__c');

        List<Assessment_Scoring__c> existingAssessmentScorings = [SELECT Assessment__c, Supplier_Account__c FROM Assessment_Scoring__c WHERE Assessment__c IN :assessmentIdSet AND Supplier_Account__c IN :supplierHubIdSet];

        for (Assessment_Scoring_Group__c assessmentScoringGroup : assScoringGroupList){
            Boolean relatedAssessmentScoringAlreadyExists = false;
            for(Assessment_Scoring__c eas : existingAssessmentScorings) {
                if(assessmentScoringGroup.Assessment__c == eas.Assessment__c && assessmentScoringGroup.Supplier_Hub__c == eas.Supplier_Account__c) {
                    relatedAssessmentScoringAlreadyExists = true;
                }
            }

            if(!relatedAssessmentScoringAlreadyExists) {
                Assessment__c thisAssessment = approvedAssessmentMap.get(assessmentScoringGroup.Assessment__c);
                assScoringInsertList.add(
                        new Assessment_Scoring__c(
                                Assessment__c = assessmentScoringGroup.Assessment__c,
                                Supplier_Account__c = assessmentScoringGroup.Supplier_Hub__c,
                                Assessment_Type__c = thisAssessment.Assessment_Type__c,
                                Dimensions__c = thisAssessment.Dimensions__c,
                                Assessment_Description__c =thisAssessment.Assessment_Description__c,
                                X_Axis_Heading__c = thisAssessment.X_Axis_Heading__c,
                                Y_Axis_Heading__c = thisAssessment.Y_Axis_Heading__c,
                                Z_Axis_Heading__c = thisAssessment.Z_Axis_Heading__c,
                                Language__c = thisAssessment.Language__c,
                                Effective_Start_Date__c = thisAssessment.Effective_Start_Date__c,
                                Effective_End_Date__c = thisAssessment.Effective_End_Date__c
                        )
                );
            }
        }

        insert assScoringInsertList;
    }


    public void finish(Database.BatchableContext BC) {}

}