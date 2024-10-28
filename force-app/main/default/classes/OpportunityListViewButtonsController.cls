/**
 * Created by KJM on 17/04/2019.
 */

public with sharing class OpportunityListViewButtonsController {

    @AuraEnabled
    public static List<RTOptionsWrapper> getRecordTypeList(){
        List<RTOptionsWrapper> recordTypes = new List<RTOptionsWrapper>();

        for (RecordTypeInfo recordType: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (recordType.isAvailable() && recordType.Name != 'Master') {
                recordTypes.add(new RTOptionsWrapper(recordType.Name, recordType.getRecordTypeId()));
            }
        }

        return recordTypes;
    }
    @AuraEnabled
    public static UserInfoWrapper getUserInfo(){
        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, Business_Segment__c FROM Contact WHERE Id = :u.ContactId];
        
        return new UserInfoWrapper(c.Business_Segment__c);
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
        @AuraEnabled public String businessSegment { get; private set; }

        public UserInfoWrapper(String businessSegment) {
            this.businessSegment = businessSegment;
        }
    }
}