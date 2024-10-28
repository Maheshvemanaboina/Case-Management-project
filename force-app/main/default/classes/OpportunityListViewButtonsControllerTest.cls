/**
 * Created by KJM on 18/04/2019.
 */

@isTest
public class OpportunityListViewButtonsControllerTest {

    @isTest
    static void shouldReturnProperRecordTypes() {
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser@flc.com.test.PCU', null);

        List<OpportunityListViewButtonsController.RTOptionsWrapper> optionWrappers;
        System.runAs(usr) {
            Test.startTest();

            optionWrappers = OpportunityListViewButtonsController.getRecordTypeList();
            OpportunityListViewButtonsController.getUserInfo();

            Test.stopTest();
        }

        System.assertEquals(1, optionWrappers.size());
        System.assertEquals('Partner Opportunity', optionWrappers.get(0).label);
    }
}