public without sharing class ProspectActivityController {
    @AuraEnabled()
    public static List<ProspectActivityWrapper.Values> getProspectActivity(String prospectId,String campaignId,String childLeadId) {
        ProspectActivityWrapper response = GetPardortProspectActivityWithCache.prospectActivity(prospectId,campaignId,childLeadId);
        return response.nextPageToken == 'error' ? null : response.values;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProspectActivityWrapper.Values> prospectActivityFromCache(String prospectId,String campaignId,String lastActivityDate,String childLeadId) {
        ProspectActivityWrapper response = GetPardortProspectActivityWithCache.prospectActivityFromCache(prospectId,campaignId,lastActivityDate,childLeadId);
        return response != null ? response.values : new List<ProspectActivityWrapper.Values>();
    }
    
    @AuraEnabled
    public static List<ProspectActivityWrapper.Values> prospectActivityFromCacheWithoutDateCheck(String prospectId,String campaignId,String childLeadId) {
        ProspectActivityWrapper response = GetPardortProspectActivityWithCache.prospectActivityFromCacheWithoutDateCheck(prospectId,campaignId,childLeadId);
        return response != null ? response.values : new List<ProspectActivityWrapper.Values>();
    }
    
    @AuraEnabled
	public static void logError(String errorMessage, String leadId, String stackTrace, String operationName) {
        GetPardortProspectActivityWithCache.createDebugLogRecord(leadId,'',errorMessage,'',stackTrace,operationName,'INTERNAL_ERROR');
	}    
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> leadHistory(String recordId) {
        List<sObject> objHistories = new List<sObject>(); 
        if(recordId.startsWithIgnoreCase('00q')){
            String soqlQuery = 'SELECT CreatedDate, Field FROM LeadHistory WHERE LeadId  = \'' + recordId + '\' AND Field = \'documents_downloaded__c\' ORDER BY CreatedDate DESC LIMIT 1';
        	objHistories = Database.query(soqlQuery);
        }else if(recordId.startsWithIgnoreCase('003')){
            String soqlQuery = 'SELECT CreatedDate, Field FROM ContactHistory WHERE ContactId  = \'' + recordId + '\' AND Field = \'documents_downloaded__c\' ORDER BY CreatedDate DESC LIMIT 1';
        	objHistories = Database.query(soqlQuery);
        }
        return objHistories;
    }
    
    
}