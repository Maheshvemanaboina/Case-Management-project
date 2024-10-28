/* *******************************************************************************************************
 * Name               : AssessmentControlerTest                                                          *
 * Description        : SRM - AssessmentControler unit test class                                              *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 14/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   14/09/2020          Initial version                      *
 ******************************************************************************************************* */
@IsTest
private class AssessmentControlerTest {
    private static final String ASSESSMENT_DESCRIPTION = 'assessmentToClone';

    @IsTest
    static void testCloneWithQuestions() {
        List<Question__c> questionList = TestUtils.newQuestions(null, 2, true);

        Assessment__c assessment = TestUtils.newAssessment(
                new Assessment__c(
                        Dimensions__c = ConstUtils.ASSESSMENT_DIMENSIONS_ONE_DIMENSIONAL,
                        Assessment_Description__c = ASSESSMENT_DESCRIPTION,
                        Effective_Start_Date__c = Date.today().addDays(-7),
                        Effective_End_Date__c = Date.today().addDays(7),
                        Assessment_Type__c = ConstUtils.ASSESSMENT_TYPE_CUSTOM,
                        X_Axis_Heading__c = 'Question',
                        Y_Axis_Heading__c = 'Rating',
                        Z_Axis_Heading__c = 'Importance',
                        Assessment_Scoring_Group_Status__c = 'Draft'
                ),
                true
        );

        System.assertEquals(true, assessment.Id != null);

        List<Assessment_Question__c> asqueList = new List <Assessment_Question__c>();

        for (Question__c que : questionList) {
            asqueList.add(TestUtils.newAssessmentQuestion(new Assessment_Question__c(Assessment__c = assessment.Id, Question__c = que.Id), false));
        }

        insert asqueList;
        for(Assessment_Question__c asque : asqueList){
            System.assertEquals(true, assessment.Id != null);
        }

        Assessment__c clonedAssessment;
        Test.startTest();
            clonedAssessment = AssessmentControler.cloneAssessment(assessment.Id);
        Test.stopTest();

        System.assertEquals(true, clonedAssessment.Id != null);
        System.assertEquals(2, [SELECT Id FROM Assessment_Question__c WHERE Assessment__c = :clonedAssessment.Id].size());

    }

    @IsTest
    static void shouldRetrieveQuestions() {
        String text = 'randomText';
        Question__c question = TestUtils.newQuestion(new Question__c(Detailed_Question__c = text), true);
        Assessment_Question__c assessmentQuestion = TestUtils.newAssessmentQuestion(new Assessment_Question__c(Question__c = question.Id),true);
        Id assessmentId = assessmentQuestion.Assessment__c;
        Exception ex;
        Test.startTest();

        List<Question__c> questions = AssessmentControler.retrieveQuestions(assessmentId);
        try {
            List<Question__c> questions2 = AssessmentControler.retrieveQuestionsByKey(text, assessmentId);
        } catch(Exception e) {
            ex = e;
        }

        Test.stopTest();

        System.assert(questions.isEmpty());
        System.assert(ex != NULL);
    }

    @IsTest
    static void shouldInsertAssessmentQuestions() {
        String text = 'randomText';
        Question__c question = TestUtils.newQuestion(new Question__c(Detailed_Question__c = text), true);
        Assessment_Question__c assessmentQuestion = TestUtils.newAssessmentQuestion(new Assessment_Question__c(Question__c = question.Id),true);
        Id assessmentId = assessmentQuestion.Assessment__c;
        Exception ex;

        Test.startTest();


        AssessmentControler.insertAssessmentQuestions(new List<Assessment_Question__c> { assessmentQuestion },  assessmentId);

        Test.stopTest();

    }


    @IsTest
    static void shouldCheckStatuses() {

            String text = 'randomText';
        Question__c question = TestUtils.newQuestion(new Question__c(Detailed_Question__c = text), true);
        Assessment__c assessment = TestUtils.newAssessment(new Assessment__c(Status__c = ConstUtils.ASSESSMENT_STATUS_READY, Assessment_Scoring_Group_Status__c = 'Submitted'), true);
        Assessment_Question__c assessmentQuestion = TestUtils.newAssessmentQuestion(new Assessment_Question__c(Question__c = question.Id, Assessment__c = assessment.Id),true);

        Test.startTest();


        Boolean isReady = AssessmentControler.checkStatus(assessment.Id);
        Boolean isSubmitted = AssessmentControler.checkScoringGroupStatus(assessment.Id);

        Test.stopTest();

        System.assert(isReady);
        System.assert(isSubmitted);

    }

    @IsTest
    static void shouldRetrieveSuppliersByKeys() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_KEY), true);
        Assessment__c assessment = TestUtils.newAssessment(new Assessment__c(Status__c = ConstUtils.ASSESSMENT_STATUS_READY, Assessment_Scoring_Group_Status__c = 'Submitted'), true);
        List<Assessment_Scoring_Group__c> assessmentScoringGroups = new List<Assessment_Scoring_Group__c> {
          new Assessment_Scoring_Group__c(Assessment__c = assessment.Id)
        };
        insert assessmentScoringGroups;

        supplierHub = [SELECT Supplier_Name__c, Segment__c, Category_Name__c, Primary_Country__c FROM Supplier_Hub__c WHERE Id = :supplierHub.Id];


        Test.startTest();

        List<Supplier_Hub__c> supplierHubs = AssessmentControler.retrieveSuppliersByKeys(supplierHub.Supplier_Name__c, supplierHub.Segment__c, supplierHub.Category_Name__c, supplierHub.Primary_Country__c, assessment.Id);

        Test.stopTest();

        System.assert(supplierHubs.isEmpty());
    }
    @IsTest
    static void cleanUpOneTimeBatchTest() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(new Supplier_Hub__c(Segment__c = ConstUtils.SUPPLIER_HUB_SEGMENT_KEY), true);
        Assessment__c assessment = TestUtils.newAssessment(new Assessment__c(Status__c = ConstUtils.ASSESSMENT_STATUS_READY, Assessment_Scoring_Group_Status__c = 'Submitted'), true);
        List<Assessment_Scoring_Group__c> assessmentScoringGroups = new List<Assessment_Scoring_Group__c> {
          new Assessment_Scoring_Group__c(Assessment__c = assessment.Id)
        };
        insert assessmentScoringGroups;
        Scoring_Group_Member__c sgm = new Scoring_Group_Member__c(Assessment_Scoring_Group__c = assessmentScoringGroups[0].Id, User__c = UserInfo.getUserId());
        insert sgm;
        test.startTest();
        database.executeBatch(new BatchDeleteScoringGroupMembers());
        test.stopTest();
    }
    @isTest 
    static void cleanScoaringItems(){
        Assessment_Scoring__c assessmentScoring = TestUtils.newAssessmentScoring(null, true);
        List<Assessment_Scoring_Item__c> assessmentScoringItems = TestUtils.newAssessmentScoringItems(new Assessment_Scoring_Item__c(Assessment_Scoring__c = assessmentScoring.Id), 5, true);
        assessmentScoringItems[0].Score__c= '0';
        update assessmentScoringItems[0];
        Test.startTest();
        database.executeBatch(new BatchDeleteAssesementScoreItems());
        Test.stopTest();
    }
}