/*
@Author     : Rohit Kumar
@CreatedDate: 20-10-2021
@UsedBy     : ComplaintUpdateFromSFToSAP,ComplaintUpdateFromSFToSAPController
@Description: 1.Used to Create Task to SAP . 
			  2.Trigger Task/Complaint Update To SAP
				Note : Complaint/Notification/Case - All are same.
@History
20-10-2021   Rohit Kumar : Created
31-03-2022   Rohit Kumar : Added logic instead of sending all file to SAP, Just send CSV file which will auto genrated in 
							the backend which will contains list of public URL and name of the file.
*/
public without sharing class Complaint_UpdateFromSFToSAP_Callout {
    
    /* 
    @Description - Whenever Relevant Case(Notification Request) Field Update happen in SF this medthod sync SF complaint details to SAP
    @param ComplaintUpdateFromSFToSAP.UpdatedComplaintFieldValues - Wrapper class contains complaint fileds values.
    @return SFResponse(Wrapper Class)
    */
    
    public static SFResponse updateComplaintToSAP(ComplaintUpdateFromSFToSAP.UpdatedComplaintFieldValues updateFieldValues){
        
        SFResponse sFResponseInstance = new SFResponse();
        //Request instance initialization
        RequestStructure requestStructureInstance = new RequestStructure();
        
        requestStructureInstance.RecordSet.NotificationHeader.NotificationType = updateFieldValues.complaintRecordTypeInSAP;
        requestStructureInstance.RecordSet.NotificationHeader.NotificationNo = updateFieldValues.complaintNotifcationNumber ;
        requestStructureInstance.RecordSet.NotificationHeader.Priority = updateFieldValues.complaintPriority;
        requestStructureInstance.RecordSet.NotificationHeader.ShortText = updateFieldValues.complaintSubject;
        requestStructureInstance.RecordSet.NotificationHeader.LongTextHeader = updateFieldValues.complaintDescription;
        requestStructureInstance.RecordSet.NotificationHeader.CodeGroupCoding = updateFieldValues.complaintType;    
        requestStructureInstance.RecordSet.NotificationHeader.Coding = updateFieldValues.complaintSubType; 
        requestStructureInstance.RecordSet.NotificationHeader.NotificationStatusOrigin = updateFieldValues.notifcationOrigin;
        requestStructureInstance.RecordSet.NotificationHeader.NotificationInProcess = updateFieldValues.notificationInProcess;
        requestStructureInstance.RecordSet.NotificationHeader.CloseNotification = updateFieldValues.closeNotification;
        requestStructureInstance.RecordSet.UserStatus.UserStatusCode = updateFieldValues.complaintCloserReason;
        requestStructureInstance.RecordSet.Partner.add(new PartnerDetails(updateFieldValues.complaintPartnerFunctionInSAP,updateFieldValues.complaintSapUserName));
        
        String complaintRequestStructure = JSON.serializePretty(requestStructureInstance);
        system.debug('Case JSON Request:\n'+complaintRequestStructure);
        sFResponseInstance = syncComplaintOrRelatedTaskToSAP(complaintRequestStructure,updateFieldValues.caseRecordId,'Case');
        return sFResponseInstance;
    }
    
    /*
    @Description : 1. Send SF task to SAP.
				   2. Update SAP task	

    @param taskRecord - Task which will upsert to SAP.
	@param contentDocumentIdList - Set of ContentDocument Id which is related to Task
    @param isTaskCompleted - Specify that current task needs to completed in SAP also
    @return SFResponse(Wrapper Class)
    */
    public static SFResponse syncComplaintTaskToSAP(Task taskRecord,Set<id> contentDocumentIdList, Boolean isTaskCompleted){
        
        //Request instance initialization
        RequestStructure requestStructureInstance = new RequestStructure(); 
        SFResponse sFResponseInstance = new SFResponse();
        
        Case complaintRecord = [SELECT id,Type,Sub_Type__c,Priority,Subject,Ownerid,Notification_Origin__c,SAP_Case_Number__c,Department_Responsible__c,
                                RecordType.DeveloperName,Case_Closer_Reason__c,Description,LastModifiedByid,SAP_Case_Status__c,Status,Partner_Function__c
                                FROM Case WHERE id=:taskRecord.WhatId];
        
        if(complaintRecord.SAP_Case_Number__c == null){
            sFResponseInstance.isSuccess = false;
            sFResponseInstance.errorMessage = 'NOT_PRESENT_IN_SAP';
            return sFResponseInstance;
        }
        requestStructureInstance = createNoficationHeaderStructure(complaintRecord,taskRecord.Type);
        
        if(taskRecord.SAP_Task_Number__c == null){
            requestStructureInstance.RecordSet.Tasks.add(sendTaskDetailRecordToSAP(taskRecord,complaintRecord.Department_Responsible__c,complaintRecord.Partner_Function__c,isTaskCompleted ));
        }
        else if(taskRecord.SAP_Task_Number__c != null){
            requestStructureInstance.RecordSet.Tasks.add(updateTaskDetailRecordToSAP(taskRecord,isTaskCompleted)) ;
        }
        
        if(!contentDocumentIdList.isEmpty()){
            for(ContentVersion cv :[SELECT id,ContentDocumentId,VersionData,FileExtension,Send_To_SAP__c,
                                    Title FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentIdList 
                                    AND IsLatest = true ORDER BY CreatedDate desc LIMIT 5]){
                requestStructureInstance.RecordSet.Attachements.add(new AttachementsDetails(EncodingUtil.base64Encode(cv.VersionData) ,
                                                                                            cv.FileExtension, cv.Title)); 
            }
        }
        
        String taskRequestStructure = JSON.serializePretty(requestStructureInstance);
        system.debug('Task JSON Request:\n'+taskRequestStructure);
        sFResponseInstance = syncComplaintOrRelatedTaskToSAP(taskRequestStructure,taskRecord.id,'Task');
        
        return sFResponseInstance;
    }
     /*
    @Description : 1.This method use to get Task related Complaint/Case details and create Header Request structure.
    @param taskRecord - Task which will upsert to SAP.
	@param contentDocumentIdList - Set of ContentDocument Id which is related to Task
    @param isTaskCompleted - Specify that current task needs to completed in SAP also
    @return RequestStructure(Wrapper Class)
    */
    public static RequestStructure createNoficationHeaderStructure(Case caseDetails,String taskType){
        
        RequestStructure requestStructureInstance = new RequestStructure();
        Map<Id,String> userIdToSAPUserNameMap = ComplaintUpdateFromSFToSAP.getSAPUserName(new Set<id>{caseDetails.OwnerId});
        Map<String,Map_SF_SAP_Field_Values__mdt> SF_SAP_FieldMapping = ComplaintUpdateFromSFToSAP.getSAPFieldValuesBasedOnSFFieldValues(new List<Case>{caseDetails});
        ComplaintUpdateFromSFToSAP.UpdatedComplaintFieldValues updateFieldValues = ComplaintUpdateFromSFToSAP.getComplaintUpdatedFieldValues(caseDetails,
                                                                                                                                             caseDetails, 
                                                                                                                                             userIdToSAPUserNameMap, 
                                                                                                                                             SF_SAP_FieldMapping,false);
        requestStructureInstance.RecordSet.NotificationHeader.NotificationType = updateFieldValues.complaintRecordTypeInSAP;
        requestStructureInstance.RecordSet.NotificationHeader.NotificationNo = updateFieldValues.complaintNotifcationNumber ;
        requestStructureInstance.RecordSet.NotificationHeader.Priority = updateFieldValues.complaintPriority;
        requestStructureInstance.RecordSet.NotificationHeader.ShortText = updateFieldValues.complaintSubject;
        requestStructureInstance.RecordSet.NotificationHeader.LongTextHeader = updateFieldValues.complaintDescription;
        requestStructureInstance.RecordSet.NotificationHeader.CodeGroupCoding = updateFieldValues.complaintType;    
        requestStructureInstance.RecordSet.NotificationHeader.Coding = updateFieldValues.complaintSubType; 
        requestStructureInstance.RecordSet.NotificationHeader.NotificationStatusOrigin = updateFieldValues.notifcationOrigin;
        requestStructureInstance.RecordSet.NotificationHeader.NotificationInProcess = updateFieldValues.notificationInProcess;
        requestStructureInstance.RecordSet.UserStatus.UserStatusCode = updateFieldValues.complaintCloserReason;
        requestStructureInstance.RecordSet.NotificationHeader.CloseNotification = updateFieldValues.closeNotification;
        requestStructureInstance.RecordSet.Partner.add(new PartnerDetails(updateFieldValues.complaintPartnerFunctionInSAP,updateFieldValues.complaintSapUserName));
        if(taskType == 'Re-Open SAP Notification'){
            requestStructureInstance.RecordSet.NotificationHeader.ReopenNotification = 'TRUE';
        }        
        return requestStructureInstance;
        
    }
    /*
    @Description : 1.Create Request Structure for task details.
				   Note : This Structure is created when new task has to created in SAP.	
    @param taskRecord - Task which will Insert to SAP.
	@param departmentResponsible - Id of User in SAP who is reponsible for the Task.
    @param partnerFunction - Partner Function of Department Responsible.
    @param isTaskCompleted - Specify that current task needs to completed in SAP also
    @return : TaskDetails(Wrapper Class)
    */
    public static TaskDetails  sendTaskDetailRecordToSAP(Task taskRecord,String departmentResponsible, String partnerFunction,Boolean isTaskCompleted){
        
        TaskDetails taskStructure = new TaskDetails();         
        taskStructure.ShortText = taskRecord.Subject;
        taskStructure.TaskLongText = taskRecord.Description ;
        taskStructure.PersonResponsibleforTaskPartnerNumber = departmentResponsible;
        taskStructure.FunctionofPersonResponsibleforTask = partnerFunction;
        if(getSAPEquivalentFieldValueOfTaskType(taskRecord.Type) != null){
            taskStructure.TaskCode = getSAPEquivalentFieldValueOfTaskType(taskRecord.Type).SAP_Field1_Value__c;
            taskStructure.CodeGroupTasks = getSAPEquivalentFieldValueOfTaskType(taskRecord.Type).SAP_Field2_Value__c;
        }
        if(isTaskCompleted && taskRecord.Type != 'Re-Open SAP Notification'){
            taskStructure.IndicatorTaskCompleted = 'TRUE';
        }
        
        return taskStructure;
    }
     /*
    @Description : 1.Create Request Structure for task details.
				   Note : This Structure is created when existing(IN SAP) task has to update in SAP.	
    @param taskRecord - Task which will Update to SAP.
    @param isTaskCompleted - Specify that current task needs to completed in SAP also
    @return TaskDetails(Wrapper Class)
    */
    public static TaskDetails  updateTaskDetailRecordToSAP(Task taskRecord,Boolean isTaskCompleted){
        
        TaskDetails taskStructure = new TaskDetails(); 
        taskStructure.ShortText = taskRecord.Subject;
        taskStructure.TaskLongText = taskRecord.Description ;
        taskStructure.ObjectNumberforStatusManagement = taskRecord.SAP_Task_Number__c ; 
        if(getSAPEquivalentFieldValueOfTaskType(taskRecord.Type) != null){
            taskStructure.TaskCode = getSAPEquivalentFieldValueOfTaskType(taskRecord.Type).SAP_Field1_Value__c;
            taskStructure.CodeGroupTasks = getSAPEquivalentFieldValueOfTaskType(taskRecord.Type).SAP_Field2_Value__c;
        }    
        if(isTaskCompleted ){
            taskStructure.IndicatorTaskCompleted = 'TRUE';
        }
        
        return taskStructure;
    }
     /*
    @Description :  Use to Get SAP equivalent field value of SF field value of Task.
    @param taskType - Type of Current Task.
    @return Map_SF_SAP_Field_Values__mdt(Custom Metadata)
    */
    public static Map_SF_SAP_Field_Values__mdt getSAPEquivalentFieldValueOfTaskType(String taskType){
        
        List<Map_SF_SAP_Field_Values__mdt> mapData  = [SELECT SAP_Field1_Value__c,SAP_Field2_Value__c FROM Map_SF_SAP_Field_Values__mdt WHERE SF_Field1_Value__c =:taskType]; 
        
        if(!mapData.isEmpty()){
            return  mapData[0];                                         
        }else{
            return null;
        }
    }
     /*
    @Description :  Send Complaint/Task details to SAP
    @param requestBody - Request Struture of Complaint/Task
	@param recordId - Case or Task Record Id
    @param objectName - Either Task or Case/Complaint Object API Name, based on trigger point.
    @return SFResponse(Wrapper Class)
    */
    public static SFResponse syncComplaintOrRelatedTaskToSAP(String requestBody, String recordId, String objectName){        
        
        SFResponse sFResponseInstance = new SFResponse();
            
        try{
            Http httpInstance = new Http();
            HttpRequest httpRequestInstance = new HttpRequest();
            httpRequestInstance.setMethod('PUT');
            httpRequestInstance.setEndpoint('callout:SF_CPI_Complaint_Interface');
            httpRequestInstance.setHeader('APIKey', '{!$Credential.Password}');
            httpRequestInstance.setHeader('Content-Type' , 'application/json');
            httpRequestInstance.setBody(requestBody);
            httpRequestInstance.setTimeout(120000);
           
            HttpResponse httpResponseInstance =httpInstance.send(httpRequestInstance);
            String responseBody = httpResponseInstance.getBody();
           
            system.debug('Status -->'+httpResponseInstance.getStatus());            
            if(httpResponseInstance.getStatusCode() == 200){
                SAPResponseWrapper responseSAP = (SAPResponseWrapper)JSON.deserialize(responseBody, SAPResponseWrapper.class);
                system.debug('response from SAP->'+JSON.serializePretty(responseSAP));
                
                if(responseSAP.Response.APIRuntimeResponse =='Success' && responseSAP.Response.Notification.NotificationErrorIndicator =='E') //Error Occured At SAP Side
                {
                    sFResponseInstance.isSuccess = false;
                    sFResponseInstance.errorMessage = responseSAP.Response.Notification.Errors[0].ErrorMessage;
                    // Log Error to Custom Debug Log
                   logErrorToCustomDebugLogIfErrorOccurred('SAP_ERROR','Upsert Failed Becuase Error Occured On SAP','Error',requestBody,responseBody,recordId,null,'syncComplaintOrRelatedTaskToSAP',objectName);
                }else if(responseSAP.Response.APIRuntimeResponse =='Success' && responseSAP.Response.Notification.NotificationErrorIndicator =='S') 
                {
                    sFResponseInstance.isSuccess = true;
                    if(!responseSAP.Response.Notification.Tasks.isEmpty()){
                        if(!String.isEmpty(responseSAP.Response.Notification.Tasks[0].TaskNumber))
                    	   sFResponseInstance.sapTaskNumber = responseSAP.Response.Notification.Tasks[0].TaskNumber;
                      }
                }
                
                return sFResponseInstance;
            }else{
                sFResponseInstance.isSuccess = false;
                sFResponseInstance.errorMessage = 'INTEGRATION_ERROR';
                String error = 'Status-'+httpResponseInstance.getStatus()+':StatusCode-'+httpResponseInstance.getStatusCode();
                // Log Error to Custom Debug Log
                logErrorToCustomDebugLogIfErrorOccurred('INTEGRATION_ERROR',error,'Error',requestBody,responseBody,recordId,null,'syncComplaintOrRelatedTaskToSAP',objectName);
                return sFResponseInstance;
            }
        }Catch(Exception exp){
            system.debug('excp->'+exp);
            system.debug('stack trace API->'+exp.getStackTraceString() );
            sFResponseInstance.isSuccess = false;
            sFResponseInstance.errorMessage = 'INTERNAL_ERROR';
            String errorMessage = ' Line Number '+exp.getLineNumber() + ' Error message'+exp.getMessage()+' Stack Trace:'+exp.getStackTraceString(); 
            /* Log Error to Custom Debug Log*/
            logErrorToCustomDebugLogIfErrorOccurred('INTERNAL_ERROR',errorMessage,'Fatal',requestBody,null,recordId,exp.getStackTraceString(),'syncComplaintOrRelatedTaskToSAP',objectName);
            
            return sFResponseInstance;
        }
    }
    
     /* @Description

        Log Error/Failed Record to Custom Debug Log
        
        @params status - A text which will use to identified where error occured.
        @param errorMessage - A text which explain what exactly error Is.
        @param severity - A text which state level of error.
        @param requestBody - Request text which is send to SAP as 
        @param responseBody -Reponse text received from SAP
        @param recordId - Object(Case/Task) record id
        @param stackTrace - A text which will help on which line error occured.
        @param opertationType - method name where error is occured.
        @param objectName - Object(Case/Task) API Name.
        
        @return void
        */  
    public static void logErrorToCustomDebugLogIfErrorOccurred(String status,String errorMessage,String severity,String requestBody, String responseBody,
                                                               String recordId,String stackTrace,String opertationType,String objectName){
        
        try{
            DebugLog__c logDebugForError = new DebugLog__c();
            logDebugForError.Object__c = objectName;
            logDebugForError.RecordId__c = recordId;
            logDebugForError.Errored_Process_Type__c = 'Integration - Outbound';
            logDebugForError.Errored_Process_Name__c = 'Complaint_UpdateFromSFToSAP_Callout';
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
    
    public class RequestStructure{
        public RequestParameter RecordSet = new RequestParameter();
    }
    public class RequestParameter{
        public NotificationHeaderDetails NotificationHeader = new NotificationHeaderDetails();
        public List<TaskDetails> Tasks = new List<TaskDetails>();
        public List<AttachementsDetails> Attachements =  new List<AttachementsDetails>();
        public List<PartnerDetails> Partner = new List<PartnerDetails>();
        public UserStatusDetails UserStatus = new UserStatusDetails();
    }
    
    public class NotificationHeaderDetails{
        
        public String NotificationNo = '';
        public String NotificationType = '';
        public String Priority = '';
        public String ShortText = '';
        public String LongTextHeader = '';  
        public String CodeGroupCoding = '';
        public String Coding = '';
        public String NotificationStatusOrigin = '';
        public String NotificationInProcess;
        public String CloseNotification;  
        public String ReopenNotification;
    }
    
    public class TaskDetails{
        
        Public String ShortText = '';
        public String TaskLongText = ''; 
        Public String CodeGroupTasks = '';
        Public String TaskCode = '';     
        Public String ObjectNumberforStatusManagement = ''; 
        Public String IndicatorTaskCompleted;
        Public String FunctionofPersonResponsibleforTask = '';  
        Public String PersonResponsibleforTaskPartnerNumber = '';  
        
    }
    public class PartnerDetails{
        
        public String PartnerFunction = '';
        public String Partner = '';
        public PartnerDetails(String PartnerFunction,String Partner){
            This.PartnerFunction = PartnerFunction;
            This.Partner= Partner;
        }
    }
    public class UserStatusDetails{
        Public String UserStatusCode;
    }
    public Class AttachementsDetails{
        
        public String Attachement1 = '';
        public String AttachmentType1 = '';
        public String AttachmentName1 = '';
        
        public AttachementsDetails(String Attachement1,String AttachmentType1,String AttachmentName1){
            This.Attachement1 = Attachement1;
            This.AttachmentType1 = AttachmentType1;
            This.AttachmentName1 = AttachmentName1;
        }
    }
    public class SAPResponseErrors{
        public String ErrorMessage;
    }
    
    public class SAPTaskResponse{
        public String TaskNumber;
    }
    public class SAPNotificationResponse{
        public String NotificationNumber;
        public String NotificationErrorIndicator;
        public List<SAPTaskResponse> Tasks; 
        public List<SAPResponseErrors> Errors;
    }
    public class SAPResponse{
        public String APIRuntimeResponse;
        public String APIRuntimeResponseDesc;
        public SAPNotificationResponse Notification;
    }
    public class SAPResponseWrapper{
        public SAPResponse Response;
    }
    
    public Class SFResponse{
        
        @AuraEnabled public boolean isSuccess = false;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public String sapTaskNumber;
        
    }
}