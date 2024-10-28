/* *******************************************************************************************************
 * Name               : AssessmentScoringsControllerTest                                                 *
 * Description        : SRM - Test class for AssessmentScoringsController                                      *
 * Created Date       : 09-Jul-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       09-Jul-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class AssessmentScoringsControllerTest {

    private static String SAMPLE_STRING = 'SampleXyz';

    @IsTest
    static void shouldGetTotalRecordsCount() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        List<Assessment_Scoring__c> assessmentScorings = TestUtils.newAssessmentScorings(new Assessment_Scoring__c(Supplier_Account__c = supplierHub.Id), 5, true);

        //at insert Assessment_Description__c field is copied from parents, so update it after insert to assert value
        for(Assessment_Scoring__c assessmentScoring : assessmentScorings) {
            assessmentScoring.Assessment_Description__c = SAMPLE_STRING;
        }

        update assessmentScorings;

        Test.startTest();

        Integer totalCount = AssessmentScoringsController.getTotalRecordsCount(supplierHub.Id, 'ample');

        Test.stopTest();

        System.assertEquals(assessmentScorings.size(), totalCount);
    }

    @isTest
    static void shouldGetAssessmentScorings() {
        Supplier_Hub__c supplierHub = TestUtils.newSupplierHub(null, true);
        List<Assessment_Scoring__c> assessmentScorings = TestUtils.newAssessmentScorings(new Assessment_Scoring__c(Supplier_Account__c = supplierHub.Id), 5, true);

        //at insert Assessment_Description__c field is copied from parents, so update it after insert to assert value
        for(Assessment_Scoring__c assessmentScoring : assessmentScorings) {
            assessmentScoring.Assessment_Description__c = SAMPLE_STRING;
        }

        update assessmentScorings;

        Test.startTest();

        List<Assessment_Scoring__c> assessmentScoringsFromController = AssessmentScoringsController.getAssessmentScorings(supplierHub.Id, 'ample', 50, 0, 'CreatedDate', 'DESC');

        Test.stopTest();

        System.assertEquals(assessmentScorings.size(), assessmentScoringsFromController.size());
        System.assertEquals(assessmentScorings[0].Assessment_Description__c, assessmentScoringsFromController[0].Assessment_Description__c);

    }

}