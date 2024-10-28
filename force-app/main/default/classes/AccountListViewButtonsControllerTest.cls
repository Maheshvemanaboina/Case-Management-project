/**
 * Created by KJM on 18/04/2019.
 */

@isTest
public class AccountListViewButtonsControllerTest {

    @isTest
    static void shouldReturnProperRecordTypes() {
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser@flc.com.test.PCU', null);

        List<AccountListViewButtonsController.RTOptionsWrapper> optionWrappers;
        System.runAs(usr) {
            Test.startTest();

            optionWrappers = AccountListViewButtonsController.getRecordTypeList();

            Test.stopTest();
        }

        System.assertEquals(1, optionWrappers.size());
        System.assertEquals('End Customer', optionWrappers.get(0).label);
    }

    @isTest
    static void shouldReturnProperUserInfo() {
        User usr = TestUtility.createPartnerPortalUser('testKrzysUser@flc.com.test.PCU', null);

        AccountListViewButtonsController.UserInfoWrapper userInfor;
        System.runAs(usr) {
            Test.startTest();

            userInfor = AccountListViewButtonsController.getUserInfo();

            Test.stopTest();
        }
		
        System.assertEquals('QSR EU', userInfor.businessSegment);
    }
    
 
}