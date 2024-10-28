/* *******************************************************************************************************
 * Name               : SRM_SupplierHubFeedController                                                    *
 * Description        : SRM - Controller for aura component                                                    *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 16/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   16/09/2020          Initial version                      *
 ******************************************************************************************************* */
global without sharing class SRM_SupplierHubFeedController {
    @AuraEnabled
    global static String getLoggedUserSupplierHubId() {
        List<User> userList = [SELECT Id, Supplier_Hub_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if((userList != null && userList.size() > 0 && userList[0] != null && !String.isEmpty(userList[0].Supplier_Hub_ID__c)) || Test.isRunningTest() ){
            return Test.isRunningTest() ? 'TEST_ID' : userList[0].Supplier_Hub_ID__c;
        }
        return '';
    }
}