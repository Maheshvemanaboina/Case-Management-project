/* *******************************************************************************************************
 * Name               : AssessmentScoringItemsControllerTest                                             *
 * Description        : SRM - Test class for AssessmentScoringItemsController                                  *
 * Created Date       : 09-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       09-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class AssessmentScoringItemsControllerTest {

    @IsTest
    static void shouldGetAssessmentScoringItems() {
        Assessment_Scoring__c assessmentScoring = TestUtils.newAssessmentScoring(null, true);
        List<Assessment_Scoring_Item__c> assessmentScoringItems = TestUtils.newAssessmentScoringItems(new Assessment_Scoring_Item__c(Assessment_Scoring__c = assessmentScoring.Id), 5, true);
        Map<Id, Assessment_Scoring_Item__c> assessmentScoringItemMap = new Map<Id, Assessment_Scoring_Item__c>(assessmentScoringItems);

        Test.startTest();

        List<AssessmentScoringItemsController.AssessmentScoringItemWrapper> assessmentScoringItemWrappers = AssessmentScoringItemsController.getAssessmentScoringItems(assessmentScoring.Id);

        Test.stopTest();

        System.assertEquals(assessmentScoringItems.size(), assessmentScoringItemWrappers.size());
        System.assert(assessmentScoringItemMap.containsKey(assessmentScoringItemWrappers[0].id));
    }


    @IsTest
    static void shouldSaveAssessmentScoringItems() {
        Assessment_Scoring__c assessmentScoring = TestUtils.newAssessmentScoring(null, true);
        List<Assessment_Scoring_Item__c> assessmentScoringItems = TestUtils.newAssessmentScoringItems(new Assessment_Scoring_Item__c(Assessment_Scoring__c = assessmentScoring.Id), 5, true);
        List<AssessmentScoringItemsController.AssessmentScoringItemWrapper> assessmentScoringItemWrappers = new List<AssessmentScoringItemsController.AssessmentScoringItemWrapper>();

        for(Integer i = 0; i < assessmentScoringItems.size(); i++) {
            AssessmentScoringItemsController.AssessmentScoringItemWrapper assessmentScoringItemWrapper = new AssessmentScoringItemsController.AssessmentScoringItemWrapper();
            assessmentScoringItemWrapper.id = assessmentScoringItems[i].Id;
            assessmentScoringItemWrapper.currentAnswerScore = String.valueOf(i+1);
            assessmentScoringItemWrappers.add(assessmentScoringItemWrapper);
        }

        Test.startTest();

        String savedAssessmentScoringItemRecords = AssessmentScoringItemsController.saveAssessmentScoringItems(assessmentScoringItemWrappers);

        Test.stopTest();

        System.assert(String.isNotBlank(savedAssessmentScoringItemRecords));

        List<Assessment_Scoring_Item__c> asi = (List<Assessment_Scoring_Item__c>)JSON.deserialize(savedAssessmentScoringItemRecords, List<Assessment_Scoring_Item__c>.class);

        System.assertEquals(assessmentScoringItemWrappers.size(), asi.size());

    }

}