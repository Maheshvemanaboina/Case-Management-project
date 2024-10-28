public with sharing class CreateCaseEmployeeCommunityController {
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getCaseRecordTypes(){
        List<RecordType> caseRecordTypes = new List<RecordType>();
        caseRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName IN ('Helpdesk_Case', 'QA_SALES') AND SObjectType = 'Case'];
        system.debug('caseRecordTypes = '+caseRecordTypes);
        if(!caseRecordTypes.isEmpty()){
            return caseRecordTypes;
        }
        return caseRecordTypes;
    }
}