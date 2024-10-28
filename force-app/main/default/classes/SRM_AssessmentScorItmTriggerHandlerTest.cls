/* *******************************************************************************************************
 * Name               : SRM_AssessmentScorItmTriggerHandlerTest                                          *
 * Description        : SRM - Unit test class                                                                  *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 22/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   22/09/2020          Initial version                      *
 ******************************************************************************************************* */
@IsTest
private class SRM_AssessmentScorItmTriggerHandlerTest {
    @IsTest
    static void testTaskCreationBehavior() {
        Assessment__c assessment = TestUtils.newAssessment(new Assessment__c(
                Assessment_Type__c=ConstUtils.ASSESSMENT_TYPE_SURVEY,
                Status__c=ConstUtils.ASSESSMENT_STATUS_READY,
                Effective_End_Date__c=Date.newInstance(2020, 6, 15),
                Assessment_Description__c = 'Assessment unit test descr.'
        ), true);
        Assessment_Scoring__c assessmentScoring = TestUtils.newAssessmentScoring(new Assessment_Scoring__c(Assessment__c=assessment.Id), true);
        Test.startTest();
        List<Assessment_Scoring_Item__c> assessmentScoringItems = TestUtils.newAssessmentScoringItems(new Assessment_Scoring_Item__c(Assessment_Scoring__c = assessmentScoring.Id, User__c=UserInfo.getUserId()), 1, true);
        assessmentScoringItems[0].Score__c= '0';
        update assessmentScoringItems[0];
        database.executeBatch(new BatchDeleteAssesementScoreItems());
        Test.stopTest();
    }
}