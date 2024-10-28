/*
@Author     : Rohit Kumar
@CreatedDate: 03-06-2021
@UsedBy     : SAPCaseCreationController (Called by Lightning Component)
@Description: This class will create case on SAP System. 
                Note: As of Now we can set multiple case to request but we can't map which case belong to which
                SAP case (when reponse is returned from SAP) becasue of reponse format received from SAP. So, right we can only 
                sending one case to SAP at a time and based on response we will update SAP Case Number in SF.

                Methods : 1.createComplaintOnSAPAndGetSAPCaseNumber:- It will fetch SF equivalent SAP field value from metadata 
                and create Request parameter for REST callout.
                2.sendComplaintToSAP :- Send request to SAP and create and wrapper which will return response to lightning
                component and update SAP Case Number in SF if Complaint is created Successfuly in SAP.
                3.logErrorToCustomDebugLogIfErrorOccurred :-  Log Error/Failed Record to Custom Debug Log.
@History
03-06-2021   Rohit Kumar : Created
26-08-2021   Rohit Kumar : Included File Extension	,File Title and CaseId(Case Number) in the request parameter.
31-03-2022   Rohit Kumar : Added logic instead of sending all file to SAP, Just send CSV file which will auto genrated in 
							the backend which will contains list of public URL and name of the file.
*/



public  without sharing class ComplaintCreationOnSAPCallout {
    
    /* @Description

    It will fetch SF equivalent SAP field value from metadata and create Request parameter for REST callout.
    
    @param complaintToBeCreatedOnSAPList - Set of Case id pass from lightning component Controller class(SAPCaseCreationController).
    
    @return SetResponseFromSAPForComponent(Wrapper Class)
    */
    public static SetResponseFromSAPForComponent createComplaintOnSAPAndGetSAPCaseNumber(Set<Id> complaintToBeCreatedOnSAPList){
        
        /*Case Field API Names*/
        final String Case_Type_APIName = 'Type';
        final String Case_Sub_Type_APIName = 'Sub_Type__c';
        final String Case_RecordTypeId_APIName = 'RecordTypeId';
        final String Case_Priority_APIName = 'Priority';
        
        final Integer MAX_FILE_SIZE_ALLOWED = 4000000;
        
        /*Request and Response Wrapper class Initialization*/
        RequestParameterList requestListInstance = new RequestParameterList();
        requestListInstance.Request  = new List<RequestParameter>();
        List<RequestParameter> createRequestParameter = new List<RequestParameter>();
        SetResponseFromSAPForComponent setSAPResponseInstance =  new SetResponseFromSAPForComponent();
        
        List<Case> listOfValidatedComplaint = new List<Case>();
        Set<String> complaintSFField1Values = new Set<String>();  // SAP field value Retrive based on SF Field1 and Field2 combination
        Set<String> complaintSAPEquivalentSFUniqueFieldMapping = new Set<String>(); // One to One relation b/w SF and SAP field values e.g. SF Priority is High then SAP equivalent Priority is 1
        Set<String> complaintSFField2Values = new Set<String>();
        Map<String,Map_SF_SAP_Field_Values__mdt> SF_SAP_FieldMapping = new Map<String,Map_SF_SAP_Field_Values__mdt>();
        Map<String,List<String>> complaintContentMapping = new Map<String,List<String>>();
        Set<Id> listOfComplaintOwnerInSF = new Set<Id>();
        Map<Id,String> mapSFOwnerIdWithSAPUserName = new Map<Id,String>();
        
        Map<String,List<ContentVersion>> complaintIdContentVersionMapping = new Map<String,List<ContentVersion>>();
        Map<String,String> contentIdAndLinkedEntityIdMap = new Map<String,String>();
        Set<String> csvfilePathList = new Set<String>();
        Integer countFileSize = 0;
       
        for(Case cs:[SELECT id,CaseNumber,Type,Sub_Type__c,CreatedDate,Delivery_Number__c,
                     Delivery_Line_Item__c,Priority,RecordType.DeveloperName,Subject,Ownerid,
                     Description,Complaint_Quantity__c FROM Case WHERE id IN:complaintToBeCreatedOnSAPList])
        {
                         csvfilePathList.add('SF_CPI_SAP_'+cs.CaseNumber+'.csv');
                         complaintSFField1Values.add(cs.Type);
                         complaintSFField2Values.add(cs.Sub_Type__c);
                         complaintSAPEquivalentSFUniqueFieldMapping.add(cs.Priority);
                         complaintSAPEquivalentSFUniqueFieldMapping.add(cs.RecordType.DeveloperName);
                         listOfComplaintOwnerInSF.add(cs.OwnerId);
                         listOfValidatedComplaint.add(cs);
         }
         /*Fetch latest version of File for each complaint and convert it into base64*/
        for(ContentDocumentLink cdl : [SELECT Id,ContentDocumentId, ContentDocument.LatestPublishedVersion.ContentSize,LinkedEntityId 
                                       FROM ContentDocumentLink WHERE LinkedEntityId IN:complaintToBeCreatedOnSAPList AND ContentDocument.LatestPublishedVersion.PathOnClient IN:csvfilePathList])
        {
            contentIdAndLinkedEntityIdMap.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            countFileSize +=  cdl.ContentDocument.LatestPublishedVersion.ContentSize;
            
          	if(countFileSize > MAX_FILE_SIZE_ALLOWED){
				setSAPResponseInstance.Status = 'MAX_FILE_SIZE_LIMIT_ERROR';     
                return setSAPResponseInstance;
            }
        }
        
        if(!contentIdAndLinkedEntityIdMap.isEmpty()){
            for(ContentVersion cv:[SELECT id,ContentDocumentId,VersionData,FileExtension, Send_To_SAP__c,Title 
                                   FROM ContentVersion WHERE ContentDocumentId IN:contentIdAndLinkedEntityIdMap.keySet()
                                   AND IsLatest = true ORDER BY CreatedDate asc])
            {
                String linkedEntityId = contentIdAndLinkedEntityIdMap.get(cv.ContentDocumentId);
                complaintIdContentVersionMapping.put(linkedEntityId,new List<ContentVersion>{cv});
            }
        }
        /*Retriving SAP UserName for Owner of Complaint in SF.*/
        for(user usr: [SELECT id,SAP_UserName__c FROM User WHERE id IN:listOfComplaintOwnerInSF]){
            if(usr.SAP_UserName__c!=null)
                mapSFOwnerIdWithSAPUserName.put(usr.id,usr.SAP_UserName__c);
        }
        
        /*Retriving SF Eqivalent SAP field Values Based On Combination of SF Field Values*/
        for(Map_SF_SAP_Field_Values__mdt mapData :[SELECT Entity_Name__c,SF_Field_1_Name__r.QualifiedApiName,SF_Field1_Value__c,SAP_Field1_Value__c,
                                                   SF_Field_2_Name__r.QualifiedApiName,SF_Field2_Value__c,SAP_Field2_Value__c FROM Map_SF_SAP_Field_Values__mdt 
                                                   WHERE SF_Field1_Value__c IN:complaintSFField1Values AND SF_Field2_Value__c IN:complaintSFField2Values
                                                   AND Entity_Name__r.QualifiedApiName='Case'])
            
        {
            if(mapData.SF_Field1_Value__c!=null && mapData.SF_Field2_Value__c!=null && mapData.SAP_Field1_Value__c!=null && mapData.SAP_Field2_Value__c!=null ){
                SF_SAP_FieldMapping.put(mapData.SF_Field_1_Name__r.QualifiedApiName+mapData.SF_Field1_Value__c+mapData.SF_Field_2_Name__r.QualifiedApiName+mapData.SF_Field2_Value__c,mapData);
            } 
            
        }
        
        /*Retriving SF Eqivalent SAP field Values Based On unique value of SF Field*/
        for(Map_SF_SAP_Field_Values__mdt mapData :[SELECT Entity_Name__c,SF_Field_1_Name__r.QualifiedApiName,SF_Field1_Value__c,SAP_Field1_Value__c
                                                   FROM Map_SF_SAP_Field_Values__mdt WHERE SF_Field1_Value__c IN:complaintSAPEquivalentSFUniqueFieldMapping
                                                   AND Entity_Name__r.QualifiedApiName='Case'])
            
        {
            if(mapData.SF_Field1_Value__c!=null && mapData.SAP_Field1_Value__c!=null){
                SF_SAP_FieldMapping.put(mapData.SF_Field_1_Name__r.QualifiedApiName+mapData.SF_Field1_Value__c,mapData);
            }
            
        }
        
        /*Creating Request Parameter*/
        if(!SF_SAP_FieldMapping.isEmpty()){
            for(Case cs:listOfValidatedComplaint){
                
                // List<String> complaintRelatedContentList = new List<String>();   
                List<ContentVersion> complaintRelatedContentList = new List<ContentVersion>();
                String setPriorityValue = '';
                String setNotificationType = '';
                String setComplaintType = '';
                String setComplaintSubType = '';
                String setSAPUserName = ''; 
                String setStartDate = cs.CreatedDate.formatGmt('ddMMYYYY');
                String setStartTime =  cs.CreatedDate.formatGmt('HHmmss'); 
                
                
                if(SF_SAP_FieldMapping.containsKey(Case_Type_APIName+cs.Type +Case_Sub_Type_APIName+cs.Sub_Type__c) ){
                    setComplaintType = SF_SAP_FieldMapping.get(Case_Type_APIName+cs.Type +Case_Sub_Type_APIName+cs.Sub_Type__c).SAP_Field1_Value__c;
                    setComplaintSubType = SF_SAP_FieldMapping.get(Case_Type_APIName+cs.Type +Case_Sub_Type_APIName+cs.Sub_Type__c).SAP_Field2_Value__c;
                }
                if(SF_SAP_FieldMapping.containsKey(Case_Priority_APIName+cs.Priority)){
                    setPriorityValue = SF_SAP_FieldMapping.get(Case_Priority_APIName+cs.Priority).SAP_Field1_Value__c;
                }
                if(SF_SAP_FieldMapping.containsKey(Case_RecordTypeId_APIName+cs.RecordType.DeveloperName)){
                    
                    setNotificationType = SF_SAP_FieldMapping.get(Case_RecordTypeId_APIName+cs.RecordType.DeveloperName).SAP_Field1_Value__c;
                }
                /* if(complaintContentMapping.containsKey(cs.Id)){
                complaintRelatedContentList =  complaintContentMapping.get(cs.id);
                }*/
                if(complaintIdContentVersionMapping.containsKey(cs.id)){
                    complaintRelatedContentList = complaintIdContentVersionMapping.get(cs.id);
                }
                if(mapSFOwnerIdWithSAPUserName.containskey(cs.OwnerId)){
                    setSAPUserName = mapSFOwnerIdWithSAPUserName.get(cs.OwnerId);
                }
                
                requestListInstance.Request.add(new RequestParameter(setNotificationType,cs.CaseNumber,cs.Delivery_Number__c,cs.Delivery_Line_Item__c,setComplaintType,
                                                                     setComplaintSubType,cs.Subject ,cs.Description ,setSAPUserName,setPriorityValue ,setSAPUserName,setStartDate,setStartTime,
                                                                     complaintRelatedContentList,String.valueOf(cs.Complaint_Quantity__c) 
                                                                    ));
            }
        }    
        String requestBody = JSON.serializePretty(requestListInstance);
        system.debug('JSON request body size->'+requestBody.length());
        system.debug('JSON request body->'+requestBody.length());
        setSAPResponseInstance = sendComplaintToSAP(requestBody,listOfValidatedComplaint);
        //system.debug('reponse:'+JSON.serializePretty(setSAPResponseInstance) );
        return setSAPResponseInstance;
        
    }
    
    /* @Description

        Send request to SAP and create and wrapper which will return response to lightning
        component and update SAP Case Number in SF if Complaint is created Successfuly in SAP.
        
        @param requestBody - http body(Type - String) for creation of Complaint in SAP. 
        @param listOfComplaint - list of case(as of now only one case) which is present in SF and now sending to SAP for complaint creation in SAP system.
        
        @return SetResponseFromSAPForComponent(Wrapper Class)
	*/
    public static SetResponseFromSAPForComponent sendComplaintToSAP(String requestBody ,List<case> listOfComplaint){
        
        ResponseParameterList responseListInstance = new ResponseParameterList();
        responseListInstance.Response = new List<ResponseParameter>();
        SetResponseFromSAPForComponent setResponse = new SetResponseFromSAPForComponent(); 
        DebugLog__c logDebugForError = new DebugLog__c();        
        
        try{            
            Http httpInstance = new Http();
            HttpRequest httpRequestInstance = new HttpRequest();
            httpRequestInstance.setEndpoint('callout:SAP_PO_Callout_Complaint');
            httpRequestInstance.setMethod('POST');
            httpRequestInstance.setHeader('Content-Type' , 'application/json');
            httpRequestInstance.setBody(requestBody);
            httpRequestInstance.setTimeout(120000);
            HttpResponse httpResponseInstance =httpInstance.send(httpRequestInstance);
            
            system.debug('Status scode-->'+httpResponseInstance.getStatusCode());
            
            if(httpResponseInstance.getStatusCode() == 200){
                String responseBody = httpResponseInstance.getBody();
                
                /*Object obj1 = JSON.deserializeUntyped(reponseBody);
				 system.debug('SAP response:'+JSON.serializePretty(obj1) );*/  
                
                responseListInstance = (ResponseParameterList)JSON.deserialize(responseBody,ResponseParameterList.class ); 
                system.debug('response:'+JSON.serializePretty(responseListInstance) );
                
                /* Only Updating Single Case in SF */   
                if(responseListInstance.ErrorIndicator == 'S' && setResponse.NotificationNumber!=null){
                    setResponse.NotificationNumber = responseListInstance.NotifNr;
                    listOfComplaint.get(0).SAP_Case_Number__c = setResponse.NotificationNumber;
                    UPDATE  listOfComplaint.get(0);
                    setResponse.Status = 'SUCCESS';
                    updateStatusOnContentVersionIfContentSentToSAP(listOfComplaint.get(0).id);
                }
                else if(responseListInstance.ErrorIndicator == 'F' && responseListInstance.Response.size()>0){
                    for(ResponseParameter resList :responseListInstance.Response){
                        setResponse.SAP_ErrorOrMessage.add(resList.ErrorOrMessage);
                    }
                    ResponseParameter getErrorFromLast = responseListInstance.Response.get(responseListInstance.Response.size()-1);
                    setResponse.ErrorMessage = getErrorFromLast.ErrorOrMessage;
                    setResponse.Status = 'FAILED';
                    
                    /* Log Error to Custom Debug Log*/
                    logErrorToCustomDebugLogIfErrorOccurred(setResponse.Status,setResponse.ErrorMessage,'Error',requestBody,responseBody,listOfComplaint.get(0),null,'sendComplaintToSAP');
                    
                }
            } 
            else{
                system.debug(httpResponseInstance.getStatus() );
                setResponse.ErrorMessage = httpResponseInstance.getStatus();
                setResponse.Status='INTEGRATION_ERROR'; 
                String error = 'Status-'+httpResponseInstance.getStatus()+':StatusCode-'+httpResponseInstance.getStatusCode();
                
                /* Log Error to Custom Debug Log*/
                logErrorToCustomDebugLogIfErrorOccurred(setResponse.Status,error,'Error',requestBody,null,listOfComplaint.get(0),null,'sendComplaintToSAP');
                
            }
        }Catch(Exception exp){
            system.debug(' Line Number '+exp.getLineNumber() + ' Error message'+exp.getMessage());
            setResponse.ErrorMessage = ' Line Number '+exp.getLineNumber() + ' Error message'+exp.getMessage()+' Stack Trace:'+exp.getStackTraceString();
            setResponse.Status='INTERNAL_ERROR'; 
            
            /* Log Error to Custom Debug Log*/
            logErrorToCustomDebugLogIfErrorOccurred(setResponse.Status,setResponse.ErrorMessage,'Fatal',requestBody,null,listOfComplaint.get(0),exp.getStackTraceString(),'sendComplaintToSAP');
            
        }
        
        return setResponse;
        
    }
    
    /* @Description

        Log Error/Failed Record to Custom Debug Log
        
        @param status - A text which will use to identified where error occured.
        @param errorMessage - A text which explain what exactly error Is.
        @param severity - A text which state level of error.
        @param requestBody - Request text which is send to SAP as 
        @param responseBody -Reponse text received from SAP
        @param caseRecord - A Case Record which is send to SAP
        @param stackTrace - A text which will help on which line error occured.
        @param opertationType - method name where error is occured.
        
        @return void
        */  
    public static void logErrorToCustomDebugLogIfErrorOccurred(String status,String errorMessage,String severity, String requestBody, String responseBody,Case caseRecord,String stackTrace,String opertationType){
        
        try{
            DebugLog__c logDebugForError = new DebugLog__c();
            logDebugForError.Object__c = 'Case';
            logDebugForError.RecordId__c = caseRecord.id;
            logDebugForError.Object_Number__c =caseRecord.CaseNumber;
            logDebugForError.Errored_Process_Type__c = 'Integration - Outbound';
            logDebugForError.Errored_Process_Name__c = 'ComplaintCreationOnSAPCallout';
            logDebugForError.Record__c = requestBody!=null ? requestBody.left(32768) : null;
            logDebugForError.Response__c = responseBody!=null ? responseBody.left(32768) : null;
            logDebugForError.Operation_Name__c = opertationType;
            logDebugForError.Severity__c = severity;
            logDebugForError.Message__c = errorMessage!=null ? errorMessage.left(255):null ;
            logDebugForError.TypeName__c = status;
            logDebugForError.StackTraceString__c  = stackTrace;
            INSERT  logDebugForError;
            
        }Catch(Exception exp){
            system.debug('error encounter while loging error to debug log:'+exp.getMessage());
        }
    }
    
    public static void updateStatusOnContentVersionIfContentSentToSAP(Id caseRecordId){
        
        Set<id> contentIdSet = new Set<id>();
        
        for(ContentDocumentLink cdl :[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:caseRecordId ]){
            contentIdSet.add(cdl.ContentDocumentId );
        }
       
        if(!contentIdSet.isEmpty()){
            updateStatusOnContentVersionIfContentSentToSAP(contentIdSet);
        }
    }
    
    @future
    public static void updateStatusOnContentVersionIfContentSentToSAP(Set<id> contentIdSet){
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        
        for(ContentVersion cv :[SELECT id,Send_To_SAP__c FROM ContentVersion WHERE ContentDocumentId IN:contentIdSet AND Send_To_SAP__c = false]){
            cv.Send_To_SAP__c = true;
            contentVersionList.add(cv);
        }
        if(!contentVersionList.isEmpty()){
            UPDATE contentVersionList;
        }
        
    }
        
    public class RequestParameter{
        public String NotificationType='';            
        public String PlantForMaterial='';            
        public String Batch='';						
        public String Delivery='';						
        public String DeliveryItem='';				
        public String SalesOrder='';					
        public String SalesOrderItem='';				
        public String PurchasingDocumentNumber='';		
        public String PurchaseOrderItem='';			
        public String ReferenceNotification='';		
        public String ProductionPlant='';				
        public String ProductGroup='';				
        public String CodingCatalog='';				
        public String CodingCatalogCode='';			
        public String Priority='';						
        public String ShortDescription='';				
        public String LongText='';						
        public String ComplaintQuantity='';			
        public String ItemNumber='';					
        public String DefectGroup='';					
        public String DefectCode='';					
        public String DefectiveQuantityExternal='';	
        public String DefectiveQuantityInternal='';	
        public String Coordinator='';					
        public String FCDepartmentResponsible='';		
        public String UserName='';
        public String RequiredStartDate = '';
        public String RequiredStartTime = '';
        public String Attachment1='';	
        public String AttachmentName1='';	
        public String AttachmentType1='';
        public String Attachment2='';
        public String AttachmentName2='';
        public String AttachmentType2='';
        public String Attachment3='';	
        public String AttachmentName3='';	
        public String AttachmentType3='';	
        public String Attachment4='';
        public String AttachmentName4='';
        public String AttachmentType4='';
        public String Attachment5='';
        public String AttachmentName5='';
        public String AttachmentType5='';
        public String caseID = '';
        
        
        public RequestParameter( String NotificationType,String caseID,String Delivery, String DeliveryItem,
                                String CodingCatalog, String CodingCatalogCode, String ShortDescription, String LongText,
                                String UserName, String Priority, String Coordinator, String RequiredStartDate,
                                String RequiredStartTime,List<ContentVersion> complaintContentList,String ComplaintQuantity
                               )
        {                   
            This.NotificationType = NotificationType;
            This.Delivery = Delivery;
            This.DeliveryItem = DeliveryItem;
            This.CodingCatalog = CodingCatalog;
            This.CodingCatalogCode = CodingCatalogCode;
            This.ShortDescription = ShortDescription;
            This.LongText = LongText;
            This.UserName = UserName;
            This.Priority = Priority;
            This.Coordinator = Coordinator; 
            This.RequiredStartDate = RequiredStartDate;
            This.RequiredStartTime = RequiredStartTime;
            This.ComplaintQuantity = ComplaintQuantity;
            This.caseID = caseID;
            /* if(complaintContentList.size()>0)
                This.Attachment1 = complaintContentList.get(0);
                
                if(complaintContentList.size()>1)
                This.Attachment2 = complaintContentList.get(1);
                
                if(complaintContentList.size()>2)
                This.Attachment3 = complaintContentList.get(2);
                
                if(complaintContentList.size()>3)
                This.Attachment4 = complaintContentList.get(3);
                
                if(complaintContentList.size()>4)
                This.Attachment5 = complaintContentList.get(4);   */
            if(complaintContentList.size()>0){
                This.Attachment1 = EncodingUtil.base64Encode(complaintContentList.get(0).VersionData);
                This.AttachmentName1 = complaintContentList.get(0).Title;
                This.AttachmentType1 = complaintContentList.get(0).FileExtension; 
            }
            
            //Commented because for complaint creation only one CSV file will send to SAP
           /* if(complaintContentList.size()>1){
                This.Attachment2 = EncodingUtil.base64Encode(complaintContentList.get(1).VersionData);
                This.AttachmentName2 = complaintContentList.get(1).Title;
                This.AttachmentType2 = complaintContentList.get(1).FileExtension;
            }
            if(complaintContentList.size()>2){
                This.Attachment3 = EncodingUtil.base64Encode(complaintContentList.get(2).VersionData);
                This.AttachmentName3 = complaintContentList.get(2).Title;
                This.AttachmentType3 = complaintContentList.get(2).FileExtension;
            }
            if(complaintContentList.size()>3){
                This.Attachment4 = EncodingUtil.base64Encode(complaintContentList.get(3).VersionData);
                This.AttachmentName4 = complaintContentList.get(3).Title;
                This.AttachmentType4 = complaintContentList.get(3).FileExtension;
            }
            if(complaintContentList.size()>4){
                This.Attachment5 = EncodingUtil.base64Encode(complaintContentList.get(4).VersionData);
                This.AttachmentName5 = complaintContentList.get(4).Title;
                This.AttachmentType5 = complaintContentList.get(4).FileExtension;
            }*/
        }
    }
    
    public class RequestParameterList{
        List<RequestParameter>  Request;
    }
    
    public class ResponseParameter{
        
        public string ErrorOrMessage;
    }
    
    public class ResponseParameterList{
        String NotifNr;
        String ErrorIndicator;
        List<ResponseParameter> Response;
    }
    /*Return Response To Component */
    public class SetResponseFromSAPForComponent{
        @AuraEnabled public List<String> SAP_ErrorOrMessage {get;set;}
        @AuraEnabled public String ErrorMessage             {get;set;}
        @AuraEnabled public String NotificationNumber       {get;set;}
        @AuraEnabled public String Status                   {get;set;}   
        
        
        public SetResponseFromSAPForComponent(){
            This.SAP_ErrorOrMessage = new List<String>();
            This.ErrorMessage = '';
            This.NotificationNumber = '';
            This.Status = '';
        }
    }
}