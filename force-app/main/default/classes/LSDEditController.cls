/*
   Class - LSDEditController
   Description - To check access for Legal users and also to change the record type and status of LSD
   Author - Sheshadri
 */
public without sharing class LSDEditController {

    // This method is used by the LSD Edit Button LWC component
    @AuraEnabled
    public static Boolean checkForLegalUser(String userId){
        Boolean result = false;
        if(userId!= null && userId!= ''){
            String grpName = 'Legal_Team';
            if(test.isRunningTest()){
                grpName = 'Legal_Team_New';
            }
            List<Group> grpList = [SELECT Id, Name, DeveloperName FROM Group WHERE DeveloperName ='Legal_Team'];
            User usrRec = [SELECT Id,Profile.Name FROM User WHERE Id =: userId];
        if(grpList!= null && grpList.size() > 0){
            Id legakGrpId = grpList[0].Id;
            List<GroupMember> grpMemberList = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId=:legakGrpId];
            set<Id> userIdSet = new set<Id>();
            for(GroupMember grpMem : grpMemberList){
                userIdSet.add(grpMem.UserOrGroupId);
            }
            if(userIdSet.contains(userId) || usrRec.Profile.Name == 'System Administrator'){
                result = true;
            }
        }
        }
        return result;
    }
    
     // This method is used by the LSD Edit Button LWC component
    @AuraEnabled
    public static boolean handleEditAction(String recordId){
        Boolean result = false;
        if(recordId != null && recordId != ''){
            Legal_Sales_Document__c lsdRec = [SELECT Id,RecordTypeId,Status_of_LSD__c,ByPassProcessValidation__c FROM Legal_Sales_Document__c WHERE Id=:recordId];
            Id recTypeIdWihoutDeviationLocked = Schema.getGlobalDescribe().get('Legal_Sales_Document__c').getDescribe().getRecordTypeInfosByDeveloperName().get('LSD_Lock_Without_Deviation').getRecordTypeId();
            Id recTypeIdWithoutDeviation = Schema.getGlobalDescribe().get('Legal_Sales_Document__c').getDescribe().getRecordTypeInfosByDeveloperName().get('LSD_Extension').getRecordTypeId();
            if(lsdRec.Status_of_LSD__c == 'LSD in Place' && lsdRec.RecordTypeId == recTypeIdWihoutDeviationLocked){
                lsdRec.Status_of_LSD__c = 'LSD Agreed with Customer and Pending Formalization';
                lsdRec.ByPassProcessValidation__c = true;
                lsdRec.RecordTypeId = recTypeIdWithoutDeviation;
                update lsdRec;
                result = true;
            }
        }
        return result;
    }
}