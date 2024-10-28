/* *******************************************************************************************************
 * Name               : SRM_FeedItemTriggerHandler                                                       *
 * Description        : SRM - Trigger handler for Feed Item                                                    *
 * Created By         : WAEG Pawel Kaca                                                                  *
 * Created Date       : 07/09/2020                                                                       *
 * ----------------------------------------------------------------------------------------------------- *
 * VERSION    AUTHOR                            DATE                                                     *
 *  1.0   -   WAEG Pawel Kaca                   07/09/2020          Initial version                      *
 ******************************************************************************************************* */
public with sharing class SRM_FeedItemTriggerHandler extends SRM_TriggerHandler {

    public override void beforeInsert() {
        List<FeedItem> newFeedItemList = (List<FeedItem>) Trigger.new;
        replaceAccountIdWithSupplierHub(newFeedItemList);

    }
    /*
    Reassigning FeedItems from account (which is available on community) to Supplier Hub Id connected to Account
     */
    private static void replaceAccountIdWithSupplierHub(List<FeedItem> feedItemList) {
        if (feedItemList != null && feedItemList.size() > 0) {
            List<Id> accountIds = new List<Id>();
            List<Id> createdByIds = new List<Id>();
            for (FeedItem fi : feedItemList) {
                if(fi.CreatedById != null){
                    createdByIds.add(fi.CreatedById);
                }
            }
            if(Trigger.isInsert || Test.isRunningTest()){
                createdByIds.add(UserInfo.getUserId());
            }

            Map<Id, User> mapUserIdToUser = new Map<Id, User>([
                SELECT Id, Supplier_Hub_ID__c FROM User WHERE Id IN :createdByIds AND
                Supplier_Hub_ID__c != null AND
                (Profile.Name = :ConstUtils.PROFILE_NAME_SRM_PARTNER_COMMUNITY_USER OR Profile.Name = : ConstUtils.PROFILE_NAME_SRM_PARTNER_COMMUNITY_LOGIN_USER)
            ]);
			system.debug('######### '+ mapUserIdToUser);
            for (FeedItem fi : feedItemList) {
                if (fi.ParentId != null) {
                    String parentId = (String) fi.ParentId;
                    //Use CreatedById field or UserInfo.getUserId (only for insert and test context)
                    String createdById = (Trigger.isInsert || Test.isRunningTest()) ? UserInfo.getUserId() : fi.CreatedById;
                    //pick only FeedItems connected to AccountId which starts with 001 and only for users (CreatedById) with Supplier Hub Id filled up
                    if (parentId.startsWith('001') && mapUserIdToUser.containsKey(createdById)) {
                        accountIds.add(fi.ParentId);
                    }
                }
            }

            List<FeedItem> toInsert = new List<FeedItem>();
            for (Supplier_Hub__c sh : [SELECT Id, Supplier_Account__c FROM Supplier_Hub__c WHERE Supplier_Account__c IN :accountIds]) {
                for (FeedItem fi : feedItemList) {
                    if (fi.ParentId != null && sh.Supplier_Account__c != null && fi.ParentId == sh.Supplier_Account__c) {
                        fi.ParentId = sh.Id;
                        toInsert.add(fi);
                    }
                }
            }
        }
    }
}