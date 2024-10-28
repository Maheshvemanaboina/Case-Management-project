/**
 * Created by KJM on 05/06/2019.
 */

public with sharing class CaseListViewButtonsController {
    @AuraEnabled
    public static List<RTOptionsWrapper> getRecordTypeList(){
        List<RTOptionsWrapper> recordTypes = new List<RTOptionsWrapper>();

        for (RecordTypeInfo recordType: Case.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (recordType.isAvailable() && recordType.Name != 'Master') {
                recordTypes.add(new RTOptionsWrapper(recordType.Name, recordType.getRecordTypeId()));
            }
        }

        return recordTypes;
    }

    @AuraEnabled
    public static UserInfoWrapper getUserInfo(){
        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId, Parent_Account__c FROM Contact WHERE Id = :u.ContactId];

        return new UserInfoWrapper(c.Id, c.Parent_Account__c, c.AccountId);
    }


    public class RTOptionsWrapper {
        @AuraEnabled public String label { get; private set; }
        @AuraEnabled public String value { get; private set; }

        public RTOptionsWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public class UserInfoWrapper {
        @AuraEnabled public String ContactId { get; private set; }
        @AuraEnabled public String AccountId { get; private set; }
        @AuraEnabled public String WorkLocationId { get; private set; }

        public UserInfoWrapper(String contactId, String accountId, String workLocationId) {
            this.ContactId = contactId;
            this.AccountId = accountId;
            this.WorkLocationId = workLocationId;
        }
    }
}