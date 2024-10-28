/* *******************************************************************************************************
 * Name               : AssessmentScoringServiceTest                                                     *
 * Description        : SRM - Test class for AssessmentScoringService                                          *
 * Created Date       : 07-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       07-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */

@IsTest
private class AssessmentScoringServiceTest {
    @IsTest
    static void shouldCopyInformationFromAssessmentToAssessmentScoring() {
        //given
        Assessment__c assessment = TestUtils.newAssessment(
                new Assessment__c(
                        Dimensions__c = ConstUtils.ASSESSMENT_DIMENSIONS_ONE_DIMENSIONAL,
                        Assessment_Description__c = 'sample description',
                        Effective_Start_Date__c = Date.today().addDays(-7),
                        Effective_End_Date__c = Date.today().addDays(7),
                        Assessment_Type__c = ConstUtils.ASSESSMENT_TYPE_CUSTOM,
                        X_Axis_Heading__c = 'Question',
                        Y_Axis_Heading__c = 'Rating',
                        Z_Axis_Heading__c = 'Importance'
                ),
                true
        );

        Test.startTest();

        Assessment_Scoring__c assessmentScoring = TestUtils.newAssessmentScoring(new Assessment_Scoring__c(Assessment__c = assessment.Id), true);

        Test.stopTest();

        assessmentScoring = [SELECT Dimensions__c, Assessment_Description__c, Effective_Start_Date__c, Effective_End_Date__c, Assessment_Type__c, X_Axis_Heading__c, Y_Axis_Heading__c, Z_Axis_Heading__c FROM Assessment_Scoring__c WHERE Id = :assessmentScoring.Id];

        System.assertEquals(assessment.Dimensions__c, assessmentScoring.Dimensions__c);
        System.assertEquals(assessment.Assessment_Description__c, assessmentScoring.Assessment_Description__c);
        System.assertEquals(assessment.Effective_Start_Date__c, assessmentScoring.Effective_Start_Date__c);
        System.assertEquals(assessment.Effective_End_Date__c, assessmentScoring.Effective_End_Date__c);
        System.assertEquals(assessment.Assessment_Type__c, assessmentScoring.Assessment_Type__c);
        System.assertEquals(assessment.X_Axis_Heading__c, assessmentScoring.X_Axis_Heading__c);
        System.assertEquals(assessment.Y_Axis_Heading__c, assessmentScoring.Y_Axis_Heading__c);
        System.assertEquals(assessment.Z_Axis_Heading__c, assessmentScoring.Z_Axis_Heading__c);

    }


    @IsTest
    static void shouldCreateAssessmentScoringItems() {
        //given
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);

        Assessment__c assessment = TestUtils.newAssessment(
                new Assessment__c(
                        Dimensions__c = ConstUtils.ASSESSMENT_DIMENSIONS_ONE_DIMENSIONAL,
                        Assessment_Description__c = 'sample description',
                        Effective_Start_Date__c = Date.today().addDays(-7),
                        Effective_End_Date__c = Date.today().addDays(7),
                        Assessment_Type__c = ConstUtils.ASSESSMENT_TYPE_SURVEY,
                        X_Axis_Heading__c = 'Question',
                        Y_Axis_Heading__c = 'Rating',
                        Z_Axis_Heading__c = 'Importance'
                ),
                true
        );

        Question__c question = TestUtils.newQuestion(null, true);

        Assessment_Question__c aq = TestUtils.newAssessmentQuestion(new Assessment_Question__c(Assessment__c = assessment.Id, Question__c = question.Id), true);


        Assessment_Scoring_Group__c asg1 = new Assessment_Scoring_Group__c(Assessment__c = assessment.Id, Supplier_Hub__c = supplierHub.Id);
        Assessment_Scoring_Group__c asg2 = new Assessment_Scoring_Group__c(Assessment__c = assessment.Id, Supplier_Hub__c = supplierHub.Id);
        insert new List<Assessment_Scoring_Group__c> { asg1, asg2 };

        Scoring_Group_Member__c sgm = new Scoring_Group_Member__c(Assessment_Scoring_Group__c = asg2.Id, User__c = UserInfo.getUserId());
        insert sgm;

        Test.startTest();

        Assessment_Scoring__c assessmentScoring = TestUtils.newAssessmentScoring(new Assessment_Scoring__c(Assessment__c = assessment.Id, Supplier_Account__c = supplierHub.Id), true);

        Test.stopTest();

        Assessment_Scoring_Item__c newASI = [SELECT Score_1_Percent__c, Score_2_Percent__c, Score_3_Percent__c, Score_4_Percent__c, Score_5_Percent__c FROM Assessment_Scoring_Item__c WHERE Assessment_Scoring__c = :assessmentScoring.Id];

        System.assertEquals(question.Score_1_Percent__c, newASI.Score_1_Percent__c);
        System.assertEquals(question.Score_2_Percent__c, newASI.Score_2_Percent__c);
        System.assertEquals(question.Score_3_Percent__c, newASI.Score_3_Percent__c);
        System.assertEquals(question.Score_4_Percent__c, newASI.Score_4_Percent__c);
        System.assertEquals(question.Score_5_Percent__c, newASI.Score_5_Percent__c);

    }
}