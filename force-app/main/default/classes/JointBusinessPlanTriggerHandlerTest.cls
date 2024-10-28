/* *******************************************************************************************************
 * Name               : JointBusinessPlanTriggerHandlerTest                                              *
 * Description        : SRM - Test class for JointBusinessPlanTriggerHandler.cls                               *
 * Created Date       : 20-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       20-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
@IsTest
private class JointBusinessPlanTriggerHandlerTest {

    @isTest
    static void shouldCreateShareRecords() {
		Supplier_Category__c category = new Supplier_Category__c(Name = 'AEROSOLS & VALVES', IsActive__c =true);
        insert category;
        Joint_Business_Plan__c jointBusinessPlan = TestUtils.newJointBusinessPlan(null, false);
        jointBusinessPlan.Category_Subgroup__c= category.Id;
        insert jointBusinessPlan;
        
        Test.startTest();

        jointBusinessPlan.Allow_Status_Field_Update__c = true;
        jointBusinessPlan.Status__c = ConstUtils.JOINT_BUSINESS_PLAN_STATUS_APPROVED;
        update jointBusinessPlan;

        Test.stopTest();
    }

}