/*
@Author     : Rohit Kumar
@CreatedDate: 10-08-2021
@UsedBy     : complaintUpdateFromSFToSAPContainer(Aura Component) ,complaintUpdateFromSFToSAP (Web Component)
@Description: Controller class of lightning component
                1. Fetch files of task and task related to(case).
                2. Unlink the task files.
                3. Share the Investigation report with the customer
                4. Send the Task details to SAP
				Note : Complaint/Notification/Case - All are same.
@History
10-08-2021   Rohit Kumar : Created
31-03-2022   Rohit Kumar : Added logic instead of sending all file to SAP, Just send CSV file to SAP which will auto genrated in 
							the backend which will contains list of public URL and name of the file.
*/
public with sharing class ComplaintUpdateFromSFToSAPController {
    
     /* 
    @Description - Get the Task Type field value
    @param taskRecordId - task record id
    @return String - Task Type
    */
    @AuraEnabled
    public static String  getTaskType(String taskRecordId){ 
        return [SELECT Type FROM Task WHERE id=:taskRecordId].Type;
    }   
    
    /* 
    @Description - 1. Get All Files realted to task parent(Case).
				   2. Seprate list of file which is already sended to SAP or not yest sended to SAP.		
    @param taskRecordId - task record id
    @return ContentAndLinkedObjectDetails(Wrapper Class) - Contains files deatils such as File Title,File Size,File Type.
    */
    @AuraEnabled
    public static ContentAndLinkedObjectDetails getRelatedContentVesrion(String taskRecordId){
        
        ContentAndLinkedObjectDetails contentObjectDetails = new ContentAndLinkedObjectDetails();
        contentObjectDetails.contentSendedToSAPList = new List<ContentDetails>();
        contentObjectDetails.contentNotSendedToSAPList = new List<ContentDetails>();
        
        Task taskRecord= [SELECT WhatId,Type,Description FROM Task WHERE id=:taskRecordId];
        contentObjectDetails.taskRecord = taskRecord;
        if(taskRecord.WhatId != null && taskRecord.Type != 'Evaluate/judge Investigation Results' 
           && taskRecord.Type != 'Request Sample from Customer')
        {
            ContentAndLinkedObjectDetails getContentDetails = getSObjectContentDetailsList(taskRecord.WhatId,true);
            DescribeSObjectResult describeObject =  taskRecord.WhatId.getSObjectType().getDescribe();
            contentObjectDetails.objectLabel = describeObject.getLabel();  
            if(!getContentDetails.contentNotSendedToSAPList.isEmpty()){      
                contentObjectDetails.contentNotSendedToSAPList.addAll(getContentDetails.contentNotSendedToSAPList);
            }
            if(!getContentDetails.contentSendedToSAPList.isEmpty()){
                contentObjectDetails.contentSendedToSAPList.addAll(getContentDetails.contentSendedToSAPList);
            }
            
        }   
        
        
        
        return contentObjectDetails;
        
    }
    /* 
    @Description - 1. Get All Files realted to task.
    @param taskRecordId - task record id
    @return List<ContentDetails>(List of Wrapper Class) - Contains files deatils such as File Title,File Size,File Type.
    */
    @AuraEnabled
    public static List<ContentDetails> fetchTaskRelatedFiles(String taskRecordId){
        List<ContentDetails> contentDetailsList = new List<ContentDetails>();
        
        if(!getSObjectContentDetailsList(taskRecordId,false).contentRelatedToTask.isEmpty()){
            contentDetailsList.addAll(getSObjectContentDetailsList(taskRecordId,false).contentRelatedToTask);
            return contentDetailsList;
        }else{
            return contentDetailsList;
        }
        
    }
     /* 
    @Description - 1. Get All Files realted to task/case.
    @param sObjectRecordId - task/case record id.
    @param isRelatedToFiles - Differentiate is file related to Task or case.
    @return ContentAndLinkedObjectDetails(Wrapper Class) - Contains files deatils such as File Title,File Size,File Type.
    */
    private static ContentAndLinkedObjectDetails getSObjectContentDetailsList(String sObjectRecordId,Boolean isRelatedToFiles){
        ContentAndLinkedObjectDetails contentObjectDetails = new ContentAndLinkedObjectDetails();
        contentObjectDetails.contentSendedToSAPList = new List<ContentDetails>();
        contentObjectDetails.contentNotSendedToSAPList = new List<ContentDetails>();
        contentObjectDetails.contentRelatedToTask = new List<ContentDetails>();
        BGI_Salesforce_Settings__c  customSettings = BGI_Salesforce_Settings__c.getOrgDefaults();
        Integer uniqueId = 1;
        for(ContentDocumentLink contentInfo : [SELECT ContentDocument.LatestPublishedVersion.CreatedDate,ContentDocument.LatestPublishedVersionId,ContentDocument.LatestPublishedVersion.Send_To_SAP__c,
                                               ContentDocument.Title,ContentDocument.ContentSize,ContentDocumentId,ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.PathOnClient
                                               FROM ContentDocumentLink WHERE LinkedEntityId=:sObjectRecordId AND ContentDocument.LatestPublishedVersion.CreatedbyId <>:customSettings.API_User_ID__c ])
        {
            if(!contentInfo.ContentDocument.LatestPublishedVersion.PathOnClient.contains('SF_CPI_SAP_')){
                String contentShortInfo = contentInfo.ContentDocument.LatestPublishedVersion.CreatedDate.format('dd-MMM-YYYY ');
                contentShortInfo +=' • '+ convertContentSizeToItsNearestUnit(contentInfo.ContentDocument.ContentSize) ;
                contentShortInfo +=' • '+ contentInfo.ContentDocument.FileExtension;
                ContentDetails contentData = new ContentDetails();
                contentData.isSelected = false;
                contentData.disableFileSelection = false;
                contentData.uniqueId = String.valueOf(uniqueId);
                contentData.fileTitle = contentInfo.ContentDocument.Title; 
                contentData.contentShortInfo = contentShortInfo;
                contentData.contentVersionId = contentInfo.ContentDocument.LatestPublishedVersionId;
                contentData.contentDocumentId = contentInfo.ContentDocumentId;
                uniqueId++;
                
                if(contentInfo.ContentDocument.LatestPublishedVersion.Send_To_SAP__c && isRelatedToFiles){
                    contentObjectDetails.contentSendedToSAPList.add(contentData);
                }else if(isRelatedToFiles){
                    contentObjectDetails.contentNotSendedToSAPList.add(contentData);
                }else{
                    contentObjectDetails.contentRelatedToTask.add(contentData);
                }
            }    
       }
        return contentObjectDetails;     
    }
    /* 
    @Description - 1. Convert File Size to its nearest unit
    @param contentSize - Size of file in byte.
    @return String - File Size with unit.
    */
    public static String convertContentSizeToItsNearestUnit(Long contentSize){
        
        Decimal size = 2;
        
        if(contentSize<size.pow(10) && contentSize>0){
            return String.valueOf(contentSize) +'B';
        }else if(contentSize >= size.pow(10) && contentSize < size.pow(20)){
            Decimal fileSizeInKB = contentSize/size.pow(10);         
            return String.valueOf(fileSizeInKB.setScale(1) +'KB') ;
        }else if(contentSize >= size.pow(20) && contentSize < size.pow(30)){
            Decimal fileSizeInMB =  contentSize/size.pow(20); 
            return String.valueOf(fileSizeInMB.setScale(1)) +'MB';
        }else if(contentSize >= size.pow(30) && contentSize < size.pow(40)){
            Decimal fileSizeInGB =  contentSize/size.pow(30); 
            return String.valueOf(fileSizeInGB.setScale(1)) +'GB';
        }
        else{
            return '-' ;
        }
    }
    /* 
    @Description - Attach selected files to the Task
    @param recordId - task record id.
    @return FileStatus - is file successfully relate to Task or not.
    */
    @AuraEnabled
    public static FileStatus attachExistingContentToTask(String recordId,List<String> contentDocumentIdList){
        
        List<ContentDocumentLink> contentLinkToInsert = new List<ContentDocumentLink>();
        set<String> existingContentOnTaskIdSet = new Set<String>();
        FileStatus fileLinkingStatus = new FileStatus();
        
        for(ContentDocumentLink content : [SELECT ContentDocumentId FROM ContentDocumentLink 
                                           WHERE ContentDocumentId IN:contentDocumentIdList
                                           AND LinkedEntityId=:recordId])
        {
           existingContentOnTaskIdSet.add(content.ContentDocumentId);
        }
        if(!contentDocumentIdList.isEmpty() && contentDocumentIdList.size() == existingContentOnTaskIdSet.size()){
            fileLinkingStatus.errorOrMessage  = 'All Selected Files Are Already Attached To The Task';
            fileLinkingStatus.isAllFileAlreadyAttached = true;
            return fileLinkingStatus;
        }
        
        if(!contentDocumentIdList.isEmpty() && contentDocumentIdList!=null){
            
            for(String contentDocId : contentDocumentIdList){
                
                if(!existingContentOnTaskIdSet.contains(contentDocId)){
                    ContentDocumentLink contentLink = new ContentDocumentLink();
                    contentLink.ContentDocumentId = contentDocId;
                    contentLink.LinkedEntityId = recordId;
                    contentLink.ShareType = 'V';
                    contentLink.Visibility = 'InternalUsers';
                    contentLinkToInsert.add(contentLink);
                }
            }
            
            if(!contentLinkToInsert.isEmpty()){
                INSERT contentLinkToInsert;
                
                if(contentLinkToInsert.size() == contentDocumentIdList.size()){
                    fileLinkingStatus.errorOrMessage  = String.valueOf(contentLinkToInsert.size())+' Files Added To the Task';
                    fileLinkingStatus.isAllFileAttached = true;
                }else{
                    fileLinkingStatus.errorOrMessage  = String.valueOf(contentLinkToInsert.size())+' Files Added To the Task';
                    fileLinkingStatus.isSomeFileAttached = true;
                }
            }
            
            //system.debug('contentlinkid->'+contentLinkToInsert);
            return fileLinkingStatus;
        }
        
        else{ 
            fileLinkingStatus.errorOrMessage = 'No File Selected';
            return fileLinkingStatus;
        }
        
    }
    /* 
    @Description - Remove selected files to the Task
    @param recordId - task record id.
	@param contentDocumentId - File id which need to be unlink from the task.
    @return String - specifiy is file unlink from the task.
    */
    @AuraEnabled
    public static String unlinkSpecifiedContentFromTask(String taskRecordId,String contentDocumentId){
        
        try{
            DELETE [SELECT id FROM ContentDocumentLink WHERE LinkedEntityId=:taskRecordId AND ContentDocumentId=:contentDocumentId];
            return 'SUCCESS';
        }catch(Exception exp){
            return 'Fail';
        }
    }
    /* 
    @Description - 1. When user click sync to SAP, then public URL is genrated for filrs which are attached to the task.
				  
    @param recordId - task record id.
    @param caseRecordId - Record Id of the case from which current task is related
    @param taskType - Type of task
    @return void
    */
    @AuraEnabled
    public static void createAttachedFilePublicURL(Id caseRecordId, Id taskRecordId, String taskType){
       
        try{
        if((taskType == 'Additional Information from Customer' || taskType == 'Ask for Additional Information') && caseRecordId != null)  {
            SAPCaseCreationController.createAttachedFilePublicURL(caseRecordId,taskRecordId);
        }else{
             return;
        }
        }Catch(Exception excp){
            throw new AuraHandledException(excp.getMessage());
        }    
       
    }
    /* 
    @Description - 1. When user click sync to SAP, then specific task send to SAP.
				   2. If Task has SAP Task Number then task will update to SAP.
				   3. If Task don't have SAP Task Number then task will created in SAP.
    @param recordId - task record id.
    @param taskDescriptionByUser - Description of task entered by user (on the UI , only for task type - Evaluate/judge Investigation Results)
    @param taskType - Type of task
    @param reportAcceptedOrRejected - Accept or Reject (Only for task Type - Evaluate/judge Investigation Results)
    @return Complaint_UpdateFromSFToSAP_Callout.SFResponse(Wrapper class)
    */
    @AuraEnabled
    public static Complaint_UpdateFromSFToSAP_Callout.SFResponse synchTaskDetailsToSAP(String taskRecordId,String taskDescriptionByUser,String taskType,String reportAcceptedOrRejected){
        
        Set<Id> contentDocumentIdList = new Set<Id>();
        Complaint_UpdateFromSFToSAP_Callout.SFResponse sFResponseInstance = new Complaint_UpdateFromSFToSAP_Callout.SFResponse();
        final Integer MAX_FILE_SIZE_ALLOWED = 4000000;
        
        try {
            Boolean isTaskCompleted = false;
            Task taskRecord = [SELECT id,WhatId,Description,Subject,Type,SAP_Task_Number__c,Status FROM Task WHERE id=:taskRecordId];
            
            if(taskType == 'Additional Information from Customer' || taskType == 'Ask for Additional Information'){
                Integer countFileSize = 0;
                String csvFilePathOnClient = 'SF_CPI_SAP_'+taskRecordId+'.csv';
                
                for(ContentDocumentLink cdl :[SELECT ContentDocumentId,ContentDocument.LatestPublishedVersion.ContentSize 
                                              FROM ContentDocumentLink  WHERE LinkedEntityId=:taskRecord.WhatId AND ContentDocument.LatestPublishedVersion.PathOnClient=:csvFilePathOnClient])
                {
                    contentDocumentIdList.add(cdl.ContentDocumentId);
                    countFileSize += cdl.ContentDocument.LatestPublishedVersion.ContentSize;
                    if(countFileSize > MAX_FILE_SIZE_ALLOWED){
                        sFResponseInstance.isSuccess = false;
                        sFResponseInstance.errorMessage = 'MAX_FILE_SIZE_LIMIT_ERROR';
                        return sFResponseInstance;
                    }
                }
            }
            if(taskType == 'Evaluate/judge Investigation Results'){
                system.debug('taskDescriptionByUser->'+taskDescriptionByUser);
                String taskActualDescription = taskRecord.Description;
                taskRecord.Description = taskDescriptionByUser;
                if(reportAcceptedOrRejected == 'Accept'){
                    isTaskCompleted = true;
                }
                sFResponseInstance = Complaint_UpdateFromSFToSAP_Callout.syncComplaintTaskToSAP(taskRecord, contentDocumentIdList,isTaskCompleted);
                taskRecord.Description = taskActualDescription;
                if(reportAcceptedOrRejected == 'Accept'){
                    shareInvestigationReportWithTheCustomer(taskRecordId);
                }else if(reportAcceptedOrRejected == 'Reject'){
                    taskRecord.Status ='Awaiting Response';
                }
                
            }else{
                isTaskCompleted = true;
                sFResponseInstance = Complaint_UpdateFromSFToSAP_Callout.syncComplaintTaskToSAP(taskRecord, contentDocumentIdList,isTaskCompleted);
                if(!contentDocumentIdList.isEmpty() && sFResponseInstance.isSuccess){
                    updateStatusOnContentVersionIfContentSentToSAP(contentDocumentIdList,taskRecordId);
                }
            }
            if(sFResponseInstance.isSuccess && taskRecord.SAP_Task_Number__c == null && sFResponseInstance.sapTaskNumber != null ){
                taskRecord.SAP_Task_Number__c = sFResponseInstance.sapTaskNumber;
                updateTask(taskRecord,taskDescriptionByUser,isTaskCompleted);
                return sFResponseInstance;
            }else if(sFResponseInstance.isSuccess){
                updateTask(taskRecord,taskDescriptionByUser,isTaskCompleted);
                return sFResponseInstance;  
            }else{
                return sFResponseInstance;
            }
            
        } catch (Exception e) {
            sFResponseInstance.isSuccess = false;
            sFResponseInstance.errorMessage = 'INTERNAL_ERROR';
            return sFResponseInstance;
        }
    }
    /* 
    @Description - Update task Status,Description.
    @param updateTask - task record.
	@param taskUpdatedDescription - Task Description(Entered by user through the UI).
    @return Void 
    */
    private static void updateTask(Task updateTask,String taskUpdatedDescription, Boolean isTaskCompleted){
        
        Boolean isUpdate = false;
        
        if(updateTask.Type == 'Evaluate/judge Investigation Results'){
            updateTask.Description = taskUpdatedDescription;
            isUpdate = true;
        }
        if(isTaskCompleted){
            updateTask.Status ='Completed';
            isUpdate = true;
        }
        if(isUpdate){
            UPDATE updateTask;
        }
        if(updateTask.Type=='Re-Open SAP Notification' && isTaskCompleted){
            Case caseRecord = [SELECT id,SAP_Case_Status__c FROM Case WHERE id=:updateTask.WhatId];
            caseRecord.SAP_Case_Status__c = 'Notification In Process';
            UPDATE caseRecord;
        }
    }
    /* 
    @Description - Update Complaint File(which is sended from SAP to SF) Sharing with the customer
    @param updateTask - task record.
	@param taskUpdatedDescription - Task Description(Entered by user through the UI).
    @return Void 
    */
    private static void shareInvestigationReportWithTheCustomer(String taskRecordId){
        
        List<SortContentLinkBasedOnCreatedDate> sortContentList = new List<SortContentLinkBasedOnCreatedDate>();
        Task taskRecord= [SELECT WhatId,Type,Description FROM Task WHERE id=:taskRecordId];
        BGI_Salesforce_Settings__c  customSettings = BGI_Salesforce_Settings__c.getOrgDefaults();
        if(taskRecord.WhatId != null){
            for(ContentDocumentLink cdl : [SELECT id,ContentDocument.LatestPublishedVersion.CreatedDate,Visibility
                                           FROM ContentDocumentLink WHERE LinkedEntityId=:taskRecord.WhatId 
                                           AND ContentDocument.FileExtension ='pdf' AND ContentDocument.LatestPublishedVersion.CreatedbyId=:customSettings.API_User_ID__c])
            {
                sortContentList.add(new SortContentLinkBasedOnCreatedDate(cdl));                    
            }
            if(!sortContentList.isEmpty()){
                sortContentList.sort();
                system.debug('sort->'+sortContentList.size());
                ContentDocumentLink cdl = sortContentList[0].contentLink;
                if(cdl.Visibility != 'AllUsers'){
                    cdl.Visibility = 'AllUsers';
                    UPDATE cdl;
                }   
            }
            
        }
        
    }
     /* 
    @Description - Sort the Task Files according to created date
    */
    public class SortContentLinkBasedOnCreatedDate implements Comparable{
        
        public ContentDocumentLink contentLink;
        
        public SortContentLinkBasedOnCreatedDate(ContentDocumentLink contentLink){
            This.contentLink = contentLink;
        }
        
        public Integer compareTo(Object obj){
            Integer returnValue = 0;
            SortContentLinkBasedOnCreatedDate cdlInstance = (SortContentLinkBasedOnCreatedDate) obj;
            
            if(contentLink.ContentDocument.LatestPublishedVersion.CreatedDate<cdlInstance.contentLink.ContentDocument.LatestPublishedVersion.CreatedDate){
                returnValue = 1;
            }
            else if(contentLink.ContentDocument.LatestPublishedVersion.CreatedDate>cdlInstance.contentLink.ContentDocument.LatestPublishedVersion.CreatedDate){
                returnValue = -1;
            }
            return returnValue;
        }
    }
    
    @future
    public static void updateStatusOnContentVersionIfContentSentToSAP(Set<id> contentDocumentIdSet,Id taskRecordId){
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        //Get Task Related Files
        for(ContentDocumentLink cdl :[SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:taskRecordId]){
            contentDocumentIdSet.add(cdl.ContentDocumentId );
        }
        
        for(ContentVersion cv :[SELECT id,Send_To_SAP__c FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentIdSet AND Send_To_SAP__c = false]){
            cv.Send_To_SAP__c = true;
            contentVersionList.add(cv);
        }
        if(!contentVersionList.isEmpty()){
            UPDATE contentVersionList;
        }
        
    }
    public class ContentAndLinkedObjectDetails{
        
        @AuraEnabled public String  objectLabel {get;set;}
        @AuraEnabled public Task taskRecord {get;set;}
        @AuraEnabled public List<ContentDetails> contentNotSendedToSAPList {get;set;}
        @AuraEnabled public List<ContentDetails> contentSendedToSAPList {get;set;}
        @AuraEnabled public List<ContentDetails> contentRelatedToTask {get;set;}
        
        public ContentAndLinkedObjectDetails(){
            This.objectLabel = '';
            This.taskRecord = new Task();
            This.contentNotSendedToSAPList = new List<ContentDetails>();
            This.contentSendedToSAPList = new List<ContentDetails>();
            This.contentRelatedToTask = new List<ContentDetails>();
        }
    }
    public class ContentDetails{
        
        @AuraEnabled public String  uniqueId {get;set;}
        @AuraEnabled public String  fileTitle {get;set;}
        @AuraEnabled public String  contentShortInfo {get;set;}
        @AuraEnabled public String  contentVersionId {get;set;}
        @AuraEnabled public String  contentDocumentId {get;set;}
        @AuraEnabled public Boolean  isSelected {get;set;}
        @AuraEnabled public Boolean  disableFileSelection {get;set;}
        
        public ContentDetails(){
            This.uniqueId = '';
            This.fileTitle = '';
            This.contentShortInfo = '';
            This.contentVersionId = '';
            This.contentDocumentId = '';
            This.isSelected = false;
            This.disableFileSelection = false;
        }
        
    }
    
    public class FileStatus{
        
        @AuraEnabled public String  errorOrMessage {get;set;}
        @AuraEnabled public Boolean  isAllFileAttached {get;set;}
        @AuraEnabled public Boolean  isAllFileAlreadyAttached {get;set;}
        @AuraEnabled public Boolean  isSomeFileAttached {get;set;}
        
        public FileStatus(){
            This.errorOrMessage = '';
            This.isAllFileAlreadyAttached = false;
            This.isAllFileAttached = false;
            This.isSomeFileAttached = false;
        }
        
    }
}