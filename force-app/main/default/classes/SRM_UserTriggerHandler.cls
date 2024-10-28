/* *******************************************************************************************************
 * Name               : SRM_UserTriggerHandler                                                           *
 * Description        : SRM - Trigger handler for User object                                                  *
 * Created Date       : 24-Aug-2020                                                                      *
 * Created By         : Mateusz Wolak-Książek                                                            *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    Mateusz W-K       24-Aug-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public with sharing class SRM_UserTriggerHandler extends  SRM_TriggerHandler {

    public override void afterInsert() {
        Map<Id, User> newUserMap = (Map<Id, User>)Trigger.newMap;

        createShareRecordsForSupplierUser(newUserMap);
    }

    /**
     * @description: if there are inserted community user with specified profile id invoke future method
     * @param newUserMap
     */
    private void createShareRecordsForSupplierUser(Map<Id, User> newUserMap) {
        Set<Id> communityUserIdSet = new Set<Id>();

        for(User newUser : newUserMap.values()) {
            if(String.isNotBlank(newUser.ContactId) && newUser.ProfileId == Utils.getProfileId(ConstUtils.PROFILE_NAME_SRM_CUSTOMER_COMMUNITY_PLUS)) {
                communityUserIdSet.add(newUser.Id);
            }
        }

        if(!communityUserIdSet.isEmpty()) {
            createShareRecordsFuture(communityUserIdSet);
        }

    }

    /**
      * @description: create joint business plan share records for new community users (joint business plan should be approved to be shared)
      * @param communityUserIdSet
     */
    @Future
    private static void createShareRecordsFuture(Set<Id> communityUserIdSet) {
        Map<Id, List<User>> accountId2UsersMap = new Map<Id, List<User>>();
        //create map with account id as key, and values as list of related users
        for(User u : [SELECT Contact.AccountId FROM User WHERE Id IN :communityUserIdSet AND Contact.AccountId != NULL]) {
            if(accountId2UsersMap.containsKey(u.Contact.AccountId)) {
                accountId2UsersMap.get(u.Contact.AccountId).add(u);
            } else {
                accountId2UsersMap.put(u.Contact.AccountId, new List<User> { u });
            }
        }

        if(!accountId2UsersMap.isEmpty()) {
            List<Joint_Business_Plan__Share> jointBusinessPlanShareList = new List<Joint_Business_Plan__Share>();
            List<Supplier_Project__Share> supplierProjectShareList = new List<Supplier_Project__Share>();

            //for each business plan with approved status find users with related supplier hubs - then create share record
            for(Joint_Business_Plan__c jointBusinessPlan : [SELECT Supplier_Hub__r.Supplier_Account__c FROM Joint_Business_Plan__c WHERE Supplier_Hub__r.Supplier_Account__c IN :accountId2UsersMap.keySet() AND Status__c = :ConstUtils.JOINT_BUSINESS_PLAN_STATUS_APPROVED]) {
                if(accountId2UsersMap.containsKey(jointBusinessPlan.Supplier_Hub__r.Supplier_Account__c)) {
                    for(User u : accountId2UsersMap.get(jointBusinessPlan.Supplier_Hub__r.Supplier_Account__c)) {
                        jointBusinessPlanShareList.add(
                                new Joint_Business_Plan__Share(
                                        ParentId = jointBusinessPlan.Id,
                                        UserOrGroupId = u.Id,
                                        AccessLevel = ConstUtils.SHARE_OBJECT_ACCESS_LEVEL_READ,
                                        RowCause = ConstUtils.SHARE_OBJECT_ROW_CAUSE_MANUAL
                                )
                        );
                    }
                }
            }

            //for each business plan with approved status find users with related supplier hubs - then create share record
            for(Supplier_Project__c supplierProject : [SELECT Supplier__r.Supplier_Account__c FROM Supplier_Project__c WHERE Supplier__r.Supplier_Account__c IN :accountId2UsersMap.keySet() AND Type__c = :ConstUtils.SUPPLIER_PROJECT_TYPE_EXTERNAL]) {
                if(accountId2UsersMap.containsKey(supplierProject.Supplier__r.Supplier_Account__c)) {
                    for(User u : accountId2UsersMap.get(supplierProject.Supplier__r.Supplier_Account__c)) {
                        supplierProjectShareList.add(
                                new Supplier_Project__Share(
                                        ParentId = supplierProject.Id,
                                        UserOrGroupId = u.Id,
                                        AccessLevel = ConstUtils.SHARE_OBJECT_ACCESS_LEVEL_READ,
                                        RowCause = ConstUtils.SHARE_OBJECT_ROW_CAUSE_MANUAL
                                )
                        );
                    }
                }
            }

            insert jointBusinessPlanShareList;
            insert supplierProjectShareList;
        }
    }

}