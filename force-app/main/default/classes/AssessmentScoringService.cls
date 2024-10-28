/* *******************************************************************************************************
 * Name               : AssessmentScoringService                                                         *
 * Description        : SRM - Service class used to hold methods doing operations on Assessment_Scoring__c     *
 *      records                                                                                          *
 * Created Date       : 06-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       06-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */

public with sharing class AssessmentScoringService {

    /**
     * @description: copy related Assessment__c information to Assessment_Scoring__c record
     * @param assessmentScoringsList - assessment scoring List
     */
    public static void copyAssessmentRelatedInformation(List<Assessment_Scoring__c> assessmentScoringsList) {
        // Build a map of Assesstment_scoring__c records keyed by Assestment__c Id
        Map<Id, List<Assessment_Scoring__c>> assessmentId2AssessmentScoringsMap = new Map<Id, List<Assessment_Scoring__c>>();
        for (Assessment_Scoring__c assessmentScoring : assessmentScoringsList) {
            if (assessmentId2AssessmentScoringsMap.containsKey(assessmentScoring.Assessment__c)) {
                assessmentId2AssessmentScoringsMap.get(assessmentScoring.Assessment__c).add(assessmentScoring);
            } else {
                assessmentId2AssessmentScoringsMap.put(assessmentScoring.Assessment__c, new List<Assessment_Scoring__c>{
                        assessmentScoring
                });
            }
        }

        // Retrieve Assessment records that are connected to Assessment Scoring records using assessmentToAssessmentScoringsMap
        for (Assessment__c assessment : [
                SELECT Id, Dimensions__c, Assessment_Description__c, Effective_Start_Date__c, Effective_End_Date__c, Assessment_Type__c,
                        X_Axis_Heading__c, Y_Axis_Heading__c, Z_Axis_Heading__c
                FROM Assessment__c
                WHERE Id IN :assessmentId2AssessmentScoringsMap.keySet()
        ]) {
            // Iterate through the Assessment Scorings and copy information from related Assessment record
            for (Assessment_Scoring__c assessmentScoring : assessmentId2AssessmentScoringsMap.get(assessment.Id)) {
                assessmentScoring.Assessment_Description__c = assessment.Assessment_Description__c;
                assessmentScoring.Assessment_Type__c = assessment.Assessment_Type__c;
                assessmentScoring.Dimensions__c = assessment.Dimensions__c;
                assessmentScoring.X_Axis_Heading__c = assessment.X_Axis_Heading__c;
                assessmentScoring.Y_Axis_Heading__c = assessment.Y_Axis_Heading__c;
                assessmentScoring.Z_Axis_Heading__c = assessment.Z_Axis_Heading__c;
                assessmentScoring.Effective_Start_Date__c = assessment.Effective_Start_Date__c;
                assessmentScoring.Effective_End_Date__c = assessment.Effective_End_Date__c;
            }
        }
    }

    private static Assessment_Scoring_Item__c prepareAssessmentScoringItem(Assessment_Scoring__c assessmentScoring, Assessment_Question__c assessmentQuestion, Question__c question, Scoring_Group_Member__c scoringGroupMember){
        Assessment_Scoring_Item__c newAssessmentScoringItem = new Assessment_Scoring_Item__c();
        newAssessmentScoringItem.Assessment_Scoring__c = assessmentScoring.Id;
        newAssessmentScoringItem.Category__c = question.Category__c;
        newAssessmentScoringItem.Detailed_Question__c = question.Detailed_Question__c;
        newAssessmentScoringItem.Mandatory_Question__c = question.Mandatory_Question__c;
        newAssessmentScoringItem.Question_Summary__c = question.Question_Summary__c;
        newAssessmentScoringItem.Relative_Weight__c = assessmentQuestion.Relative_Weight__c;
        newAssessmentScoringItem.Score_Choice_1__c = question.Score_1_Help__c;
        newAssessmentScoringItem.Score_Choice_2__c = question.Score_2_Help__c;
        newAssessmentScoringItem.Score_Choice_3__c = question.Score_3_Help__c;
        newAssessmentScoringItem.Score_Choice_4__c = question.Score_4_Help__c;
        newAssessmentScoringItem.Score_Choice_5__c = question.Score_5_Help__c;
        newAssessmentScoringItem.Score_1_Used__c = question.Score_1_Used__c;
        newAssessmentScoringItem.Score_2_Used__c = question.Score_2_Used__c;
        newAssessmentScoringItem.Score_3_Used__c = question.Score_3_Used__c;
        newAssessmentScoringItem.Score_4_Used__c = question.Score_4_Used__c;
        newAssessmentScoringItem.Score_5_Used__c = question.Score_5_Used__c;
        newAssessmentScoringItem.Score_1_Percent__c = question.Score_1_Percent__c;
        newAssessmentScoringItem.Score_2_Percent__c = question.Score_2_Percent__c;
        newAssessmentScoringItem.Score_3_Percent__c = question.Score_3_Percent__c;
        newAssessmentScoringItem.Score_4_Percent__c = question.Score_4_Percent__c;
        newAssessmentScoringItem.Score_5_Percent__c = question.Score_5_Percent__c;
        newAssessmentScoringItem.Sequence__c = assessmentQuestion.Sequence__c;
        newAssessmentScoringItem.Dimension__c = assessmentQuestion.Dimension__c;
        newAssessmentScoringItem.Score__c = '0';
        if(scoringGroupMember != null && scoringGroupMember != null){
            newAssessmentScoringItem.User__c = scoringGroupMember.User__c;
        }
        return newAssessmentScoringItem;
    }

    /**
     * @description: create assessment scoring items using questions records related to specified assessment record
     * @param assessmentScoringsList - assessment scoring list
     */
    /* TODO:
     5. Trap any errors and show against the appropriate Assessment Scoring record (handle batches correctly)
     6. Consider a retry mechanism for when creation failures occur (an after/before Update trigger)
     7. Rename the trigger to something within development standards
     8. For each new Assessment Scoring, create new incrementing Sequence numbers for each child record (start at 10, increment by 10) */
    public static void createAssessmentScoringItems(List<Assessment_Scoring__c> assessmentScoringList) {
        // Build a Set of Assestment Ids
        Set<Id> setAids = new Set<Id>();
        Set<Id> supplierHubIds = new Set<Id>();
        for (Assessment_Scoring__c assessmentScoring : assessmentScoringList) {
            if (!setAids.contains(assessmentScoring.Assessment__c)) {
                setAids.add(assessmentScoring.Assessment__c);
            }
            if (!supplierHubIds.contains(assessmentScoring.Supplier_Account__c)) {
                supplierHubIds.add(assessmentScoring.Supplier_Account__c);
            }
        }

        Map<Id, Assessment__c> assessmentId2TypeMap = new Map<Id, Assessment__c>([
                SELECT Id, Assessment_Type__c
                FROM Assessment__c
                WHERE Id IN :setAids
        ]);

        Boolean atLeastOneTypeSurveyExist = false;
        for(Assessment__c assessment : assessmentId2TypeMap.values()){
            if(assessment.Assessment_Type__c == ConstUtils.ASSESSMENT_TYPE_SURVEY){
                atLeastOneTypeSurveyExist = true;
            }
        }

        // Retrieve all Assessment Question records in sequence for the relevant Assessment
        List<Assessment_Question__c> assessmentQuestionList = [
                SELECT Id, Sequence__c, Dimension__c, Question__c, Relative_Weight__c, Assessment__c
                FROM Assessment_Question__c
                WHERE Assessment__c IN :setAids
                ORDER BY Sequence__c, Name
        ];

        // Build a Set of Question IDs
        Set<Id> setQ = new Set<Id>();
        for (Assessment_Question__c assessmentQuestion : assessmentQuestionList) {
            if (!setQ.contains(assessmentQuestion.Question__c)) {
                setQ.add(assessmentQuestion.Question__c);
            }
        }

        // Retrieve all Questions from the Set of Question IDs into a Map keyed by Id
        Map<Id, Question__c> questionId2QuestionMap = new Map<Id, Question__c>([
                SELECT Id, Category__c, Detailed_Question__c, Question_Summary__c, Mandatory_Question__c, Language__c
                        , Score_1_Help__c, Score_2_Help__c, Score_3_Help__c, Score_4_Help__c, Score_5_Help__c
                        , Score_1_Used__c, Score_2_Used__c, Score_3_Used__c, Score_4_Used__c, Score_5_Used__c
                        , Score_1_Percent__c, Score_2_Percent__c, Score_3_Percent__c, Score_4_Percent__c, Score_5_Percent__c
                        , Status__c
                FROM Question__c
                WHERE Id IN :setQ
        ]);
        List<Scoring_Group_Member__c> scoringGroupMemberList = new List<Scoring_Group_Member__c>();
        if(atLeastOneTypeSurveyExist){
            scoringGroupMemberList = [
                SELECT Id, User__c, Assessment__c, Assessment_Scoring_Group__r.Assessment__c, Assessment_Scoring_Group__r.Supplier_Hub__c
                FROM Scoring_Group_Member__c
                WHERE Assessment_Scoring_Group__r.Assessment__c IN :setAids AND
                Assessment_Scoring_Group__r.Supplier_Hub__c IN :supplierHubIds
            ];
        }

        // Iterate through the Assessment Questions and create an Assessment Scoring Item record for each
        List<Assessment_Scoring_Item__c> assessmentScoringItemList = new List<Assessment_Scoring_Item__c>();
        for (Assessment_Scoring__c assessmentScoring : assessmentScoringList) {
            for (Assessment_Question__c assessmentQuestion : assessmentQuestionList) {
                if (assessmentScoring.Assessment__c == assessmentQuestion.Assessment__c) {
                    if (assessmentId2TypeMap.containsKey(assessmentScoring.Assessment__c) && assessmentId2TypeMap.get(assessmentScoring.Assessment__c).Assessment_Type__c == ConstUtils.ASSESSMENT_TYPE_SURVEY) {
                        //Assessment Type = Survey

                        for(Scoring_Group_Member__c sgm : scoringGroupMemberList) {
                            if (assessmentScoring.Assessment__c == sgm.Assessment_Scoring_Group__r.Assessment__c && assessmentScoring.Supplier_Account__c == sgm.Assessment_Scoring_Group__r.Supplier_Hub__c) {
                                Assessment_Scoring_Item__c newAssessmentScoringItem = prepareAssessmentScoringItem(assessmentScoring, assessmentQuestion, questionId2QuestionMap.get(assessmentQuestion.Question__c), sgm);
                                assessmentScoringItemList.add(newAssessmentScoringItem);
                            }
                        }
                    } else {
                        //Assessment Type Not Survey
                        Assessment_Scoring_Item__c newAssessmentScoringItem = prepareAssessmentScoringItem(assessmentScoring, assessmentQuestion, questionId2QuestionMap.get(assessmentQuestion.Question__c), null);
                        assessmentScoringItemList.add(newAssessmentScoringItem);
                    }
                }
            }
        }

        if(assessmentScoringItemList != null && assessmentScoringItemList.size() > 0) {
            // Finally, insert all of the new Assessment Scoring Item records
            insert assessmentScoringItemList;
        }
    }
}