public with sharing class ProcessInstanceWorkitemController {
    @AuraEnabled(cacheable=true)
    public static string getProcessInstanceWorkitem(String recordId) {
        ProcessInstanceWorkitem piwList =  [Select id, ProcessInstanceId from ProcessInstanceWorkitem Where id =: recordID Limit 1];
        ProcessInstance pi =  [Select id, TargetObjectId from ProcessInstance Where id =: piwList.ProcessInstanceId Limit 1]; 
        return pi.TargetObjectId;
    }
}