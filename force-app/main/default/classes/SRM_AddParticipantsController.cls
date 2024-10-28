public without sharing class SRM_AddParticipantsController {
    @AuraEnabled
    public static List<Meeting_Participants__c> getMeetingParticipates(String recordId, String meetingSummaryRecordId){
        List<Meeting_Participants__c> AllParticipants= [SELECT Id, User__c,User__r.Name, Meeting_Structure__c,Email__c FROM Meeting_Participants__c WHERE Meeting_Structure__c =: recordId];
        List<Participants__c> existingParticipats = [SELECT Id, User__c, Meeting_Summary__c, Email__c FROM Participants__c WHERE Meeting_Summary__c =: meetingSummaryRecordId];
        if(! existingParticipats.isEmpty() ){
            Set<Id> existingUser = new Set<Id>();
            List<Meeting_Participants__c> excludeList = new List<Meeting_Participants__c>();
            for(Participants__c obj: existingParticipats){
                existingUser.add(obj.User__c);
            }
            if(! AllParticipants.isEmpty() ){
                for(Meeting_Participants__c objMP: AllParticipants){
                    if(! existingUser.contains(objMP.User__c)){
                        excludeList.add(objMP);
                    }
                }
            }
            return excludeList;
        }else{
            return AllParticipants;
        }
    }
    @AuraEnabled
    public static String createParticipants( List<Meeting_Participants__c> records, String recordId){
        List<Participants__c> newRecords = new List<Participants__c>();
        for(Meeting_Participants__c obj: records){
            newRecords.add(createObjRecord (recordId, obj.User__c));
        }
        if(! newRecords.isEmpty()){
            try{
                insert newRecords;
                return 'Success';
            }catch(exception e){
                system.debug('erro r '+ e.getMessage());
                return e.getMessage();
            }
        }
        return 'Success';
    }
    public static Participants__c createObjRecord( String recordId, String userId){
        Participants__c obj = new Participants__c();
        obj.Meeting_Summary__c = recordId;
        obj.User__c = userId;
        return obj;
    }
}