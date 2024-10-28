/* *******************************************************************************************************
 * Name               : RelatedListControllerTest                                                        *
 * Description        : SRM - Test class for RelatedListController.cls                                         *
 * Created Date       : 07-09-2020                                                                       *
 * Created By         : Szymon Szczepański                                                               *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    sszcz       07-09-2020 Initial version                                                     *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class RelatedListControllerTest {
    @IsTest
    static void shouldFetchRecords() {
        Account acc = TestUtils.newAccount(new Account(Name = 'Test Supplier'), false);
        insert acc;

        Supplier_Hub__c supplierHub = new Supplier_Hub__c(Segment__c = 'Strategic', Supplier_Account__c = acc.Id, Primary_Country__c = 'Ireland');
        insert supplierHub;

        Assessment__c assessment = new Assessment__c(Assessment_Type__c = 'Custom');
        insert assessment;

        Assessment_Scoring_Group__c asg1 = new Assessment_Scoring_Group__c(Assessment__c = assessment.Id, Supplier_Hub__c = supplierHub.Id);
        insert asg1;

        RelatedListController.RelatedListWrapper wrapper = RelatedListController.fetchRecords(assessment.id);

        List < SObject > objects = wrapper.listRecords;
        Assessment_Scoring_Group__c newAssessmentScoringGroup = (Assessment_Scoring_Group__c)objects[0];

        System.debug(newAssessmentScoringGroup);

        System.assertEquals(1, wrapper.recordCount);
        System.assertEquals('Strategic', newAssessmentScoringGroup.Supplier_Segment__c);
        System.assertEquals(0, newAssessmentScoringGroup.Scoring_Members_Count__c);
        System.assertEquals('Test Supplier', newAssessmentScoringGroup.Supplier_Name__c);
        System.assertEquals('Ireland', newAssessmentScoringGroup.Supplier_Country__c);
    }
}