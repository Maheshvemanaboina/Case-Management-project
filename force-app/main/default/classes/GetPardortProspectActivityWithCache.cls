/*
@Author      : Praneeth Krishna NR
@CreatedDate : 17-03-2023
@UsedBy      : ProspectActivityController (Called by Lightning Component)
@Description : This class is used to fetch prospect activites from pardot using pardot api's. 
               Further prospect activity will be filtered based on campaign
               Activites related to form and form handler will be passed on to the lightning component 
*/

public without sharing  class GetPardortProspectActivityWithCache {
    public static Cache.OrgPartition orgPart = Cache.Org.getPartition('local.pardotProspectActivity');
    public final static Integer CACHE_EXPIRATION_SECONDS =  Integer.valueOf(System.Label.CacheExpirationTime.trim()); 
    public final static List<String> ACTIVITY_TYPES = new List<String>{'Form', 'Form Handler'};  
    
    public class SessionId {
        public string sessionId;
    }
    
    @AuraEnabled
    public static string getUserSessionId() {
        SessionId sessionJson = new SessionId();
        if(!Test.isRunningTest()){
            sessionJson = (SessionId)JSON.deserialize(Page.SessionPage.getContent().toString(), SessionId.class);
        }
        return sessionJson.sessionId;
    }    

        
    @AuraEnabled
    public static ProspectActivityWrapper prospectActivity(String prospectId,String campaignId,String childLeadId){
        String sessionId = getUserSessionId();
        PardotSettings__c settings = PardotSettings__c.getInstance();
        ProspectActivityWrapper result = new ProspectActivityWrapper();  
        ProspectActivityWrapper paw = new ProspectActivityWrapper();      
        String cacheKey = 'pardotActivity' + prospectId;
        String operationName = 'Fetch document downloaded using pardot api call';
        String authorizationHeader = 'Bearer '+ sessionId;
        String reqFields = '?fields=Id,campaignId,details,prospectId,typeName,updatedAt,campaign.salesforceId';
        String response = null;
        String endPoint = settings.PardotURL__c.trim() + reqFields + '&prospectId=' + prospectId + '&orderby=updatedAt';
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        req.setHeader('Pardot-Business-Unit-Id', settings.PardotBUID__c.trim());
        req.setHeader('Authorization', authorizationHeader);        
        paw.values = new List<ProspectActivityWrapper.Values>();
        Boolean done = false;        
        while (!done) {
            try {
                res = http.send(req);
                response = res.getBody(); 
                ProspectActivityWrapper tmpWrapper = new ProspectActivityWrapper().jsonToObject(response);
                paw.values.addAll(tmpWrapper.values);
                paw.createdDate = DateTime.now();
                if (tmpWrapper.nextPageToken != null) {
                    req.setEndpoint(settings.PardotURL__c.trim() + reqFields + '&nextPageToken=' + tmpWrapper.nextPageToken);
                } else {
                    done = true;
                }
            } catch(exception ex){
                String logId = createDebugLogRecord(childLeadId,res.getBody(),ex.getMessage(),endPoint,ex.getStackTraceString(),operationName,'CALLOUT_ERROR');
                done = true;
                paw.nextPageToken = 'error';
                return paw;            
            }
        }
        paw.values = filterFormsAndFormHandlers(paw,orgPart,cacheKey,childLeadId);
        if(paw.values.size() > 0 ){
            orgPart.put(cacheKey, paw, CACHE_EXPIRATION_SECONDS);
        }       
        paw.values = filterByCampaign(paw,campaignId,childLeadId);
        String logId = createDebugLogRecord(childLeadId,'','','','',operationName,'CALLOUT_SUCCESS');
        return paw;
    }
    
   @AuraEnabled
    public static ProspectActivityWrapper prospectActivityFromCache(String prospectId,String campaignId,String lastActivityDate,String childLeadId){
        ProspectActivityWrapper result = new ProspectActivityWrapper();
        ProspectActivityWrapper paw = new ProspectActivityWrapper();
        String cacheKey = 'pardotActivity' + prospectId; 
        try{ 
            if(orgPart.contains(cacheKey)) {
                paw = (ProspectActivityWrapper) orgPart.get(cacheKey);
                String newDateString = lastActivityDate.replace('T', ' ').replace('.000Z', '');
                Datetime dateTimeValue = Datetime.valueOfGmt(newDateString);
                if( paw.createdDate > dateTimeValue){
                    result.values  = filterByCampaign(paw,campaignId,childLeadId);
                }else{
                    return null;                    
                }                  
            }
            else{
                return null;
            }    
        }
        catch(exception ex){
            throw ex;
        }
        return result;
    }
    
    @AuraEnabled
    public static ProspectActivityWrapper prospectActivityFromCacheWithoutDateCheck(String prospectId,String campaignId,String childLeadId){
        ProspectActivityWrapper result = new ProspectActivityWrapper();
        String cacheKey = 'pardotActivity' + prospectId; 
        try{ 
            if(orgPart.contains(cacheKey)) {
                result = (ProspectActivityWrapper) orgPart.get(cacheKey);            
                result.values  = filterByCampaign(result,campaignId,childLeadId);                 
            }
            else{
                return null;
            }    
        }
        catch(exception ex){
            throw ex;
        }
        return result;
    }


    public static List<ProspectActivityWrapper.Values> filterFormsAndFormHandlers(ProspectActivityWrapper paw, Cache.OrgPartition orgPart,String cacheKey,String childLeadId){
        ProspectActivityWrapper filteredResults = new ProspectActivityWrapper();
        filteredResults.values = new List<ProspectActivityWrapper.Values>();
        try{        
            for(ProspectActivityWrapper.Values activityRecord : paw.values){             
                if(
                    ACTIVITY_TYPES.contains(activityRecord.typeName) &&
                    String.isNotBlank(activityRecord.details) && activityRecord.details.contains('Download:') 
                ){  
                    String tempString = activityRecord.updatedAt;
                    String tempString2 = tempString.replace('T', ' ').replaceAll('\\+.*', '');
                    activityRecord.updatedAt = tempString2;
                    filteredResults.values.add(activityRecord);
                }
            }
            
        }catch(exception ex){
           throw ex;
        }        
        return filteredResults.values;
    }
    
    public static List<ProspectActivityWrapper.Values> filterByCampaign(ProspectActivityWrapper paw, String campaignId,String childLeadId){
        ProspectActivityWrapper filteredResults = new ProspectActivityWrapper();
        filteredResults.values = new List<ProspectActivityWrapper.Values>();
        try{        
            for(ProspectActivityWrapper.Values activityRecord : paw.values){            
                if( activityRecord.campaign != null && activityRecord.campaign.salesforceId != null && activityRecord.campaign.salesforceId == campaignId ){                   
                    filteredResults.values.add(activityRecord);
                }
            }         
        }catch(exception ex){
            throw ex;
        }
        return filteredResults.values;
    }
    
    public static ID createDebugLogRecord(String childLeadId,String responseBody,String errorMessage,String endPoint ,String stackTrace,String operationName,String logType){
            DebugLog__c debuglogs = new DebugLog__c();
            debuglogs.Object__c = 'Child Lead';
            debuglogs.Errored_Process_Type__c = 'Integration - Outbound';
            debuglogs.Errored_Process_Name__c = 'Dispaly Documents Downloaded By Prospect In Component';
            debuglogs.Operation_Name__c = operationName;
            debuglogs.TypeName__c = logType;
            debuglogs.RecordId__c =childLeadId;       
            debuglogs.Response__c = responseBody!=null ? responseBody.left(32768) : null;            
            debuglogs.Message__c = errorMessage!=null ? errorMessage.left(255):null ;  
            debuglogs.Record__c = endPoint!=null ? endPoint.left(32768) : null;
            debuglogs.StackTraceString__c  = stackTrace;
            insert  debuglogs;
        	return debuglogs.id;
    }
}