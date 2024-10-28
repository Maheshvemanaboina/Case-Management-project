/* *******************************************************************************************************
 * Name               : AssessmentTriggerHandlerTest                                                     *
 * Description        : SRM - AssessmentTriggerHandlerTest unit test class                                     *
 * Created Date       : 27-07-2020                                                                       *
 * Created By         : Szymon Szczepański                                                               *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    sszcz             27-07-2020 Initial version                                               *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class AssessmentTriggerHandlerTest {


    @IsTest
    static void shouldCreateAssessmentScoringsAfterAssessmentScoringGroupSubmission() {
        Assessment__c assessment = TestUtils.newAssessment(
                new Assessment__c(
                        Dimensions__c = ConstUtils.ASSESSMENT_DIMENSIONS_ONE_DIMENSIONAL,
                        Assessment_Description__c = 'sample description',
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

        List<Account> accounts = TestUtils.newAccounts(null, 3, true);
        Supplier_Hub__c supplierHub1 = TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[0].Id), true);
        Supplier_Hub__c supplierHub2 = TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[1].Id), true);
        Supplier_Hub__c supplierHub3 = TestUtils.newSupplierHub(new Supplier_Hub__c(Supplier_Account__c = accounts[2].Id), true);


        Assessment_Scoring_Group__c assessmentScoringGroup1 = new Assessment_Scoring_Group__c(
                Assessment__c = assessment.Id,
                Supplier_Hub__c = supplierHub1.Id
        );
        insert assessmentScoringGroup1;

        Assessment_Scoring_Group__c assessmentScoringGroup2 = new Assessment_Scoring_Group__c(
                Assessment__c = assessment.Id,
                Supplier_Hub__c = supplierHub2.Id
        );
        insert assessmentScoringGroup2;

        Assessment_Scoring_Group__c assessmentScoringGroup3 = new Assessment_Scoring_Group__c(
                Assessment__c = assessment.Id,
                Supplier_Hub__c = supplierHub3.Id
        );
        insert assessmentScoringGroup3;

        Test.startTest();

        assessment.Assessment_Scoring_Group_Status__c = ConstUtils.ASSESSMENT_ASS_SCORING_GROUP_STATUS_SUBMITTED;
        update assessment;

        Test.stopTest();

        System.assertEquals(3, [SELECT ID FROM Assessment_Scoring__c WHERE Assessment__c = :assessment.Id].size());
    }
    

}