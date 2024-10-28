public without sharing class SAPCaseCreationController {
    

    @AuraEnabled
    public static Boolean checkCaseOwnerAndCreateAttachedFilePublicURL(Id userId,Id caseRecordId){
        try {
        Boolean sapUserNameNotFound = false;
        User userRec = [SELECT Id,Name,SAP_UserName__c FROM User WHERE ID=:userId];
        if(userRec.SAP_UserName__c == null){
            sapUserNameNotFound = true;
        }else{
            createAttachedFilePublicURL(caseRecordId,null);    
        }
        
        return sapUserNameNotFound;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //This Methoud use by both Create and Update Complaint Iterface to genrate Public URl for the files
    public static void createAttachedFilePublicURL(Id caseRecordId,Id taskRecordId){
        
        Set<Id> contentIdSet = new Set<Id>();  //List of files attached to the complainr after creation
        Map<Id,String> contentVersionIdAndNameMap = new Map<Id,String>(); // Use to ContentDistribution record name same as file name
        Set<Id> alreadyExistingPublicUrlCVIdSet = new Set<Id>();   // Set of all content version whose public url already created
        List<ContentDistribution> insertContentDistributionList = new List<ContentDistribution>();  // Insert ContentDistribution Record To genrate public URL for the files 
        Set<Id> contentDistributionRecordCVIdList = new Set<Id>();  // List of Content Vesrion Id whose public need to be created
        Case caseRecord = [SELECT CaseNumber FROM Case WHERE id =: caseRecordId];
        
        final Integer MAX_LENGTH_FOR_FILE = 4000000;
        String csvHeader = 'File Name'+','+'File URL'+','+'Password'+'\n';
        String csvFinalString = csvHeader; 
        String csvFileTitle;
        String csvFilePathOnClient;
        Id recordId;
        
        if(taskRecordId != null){
            String taskNumber = [SELECT SF_Task_Number__c FROM Task WHERE Id=:taskRecordId].SF_Task_Number__c;
            recordId = taskRecordId;
            taskNumber = taskNumber != null ? '_'+taskNumber : '';
            csvFileTitle = 'Files_Link'+taskNumber;
            csvFilePathOnClient = 'SF_CPI_SAP_'+taskRecordId+'.csv';
        }else{
            recordId = caseRecordId;
            csvFileTitle = 'Files_Link_'+caseRecord.CaseNumber;
            csvFilePathOnClient = 'SF_CPI_SAP_'+caseRecord.CaseNumber+'.csv';
        }
        
        //Get all File related to the case except csv file which contains public URL for all file and share with the SAP
        for(ContentDocumentLink eachCDL :[SELECT ContentDocumentId,ContentDocument.Title,ContentDocument.LatestPublishedVersion.PathOnclient,ContentDocument.LatestPublishedVersionId,
                                          LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId=:recordId])
        {
            if(eachCDL.ContentDocument.LatestPublishedVersion.PathOnClient != csvFilePathOnClient){
                String fileTitle = eachCDL.ContentDocument.title;
                if(fileTitle.contains(',')){
                    fileTitle.replace(',', '_');
                    
                }
				contentIdSet.add(eachCDL.ContentDocumentId);       
                contentVersionIdAndNameMap.put(eachCDL.ContentDocument.LatestPublishedVersionId,fileTitle);
             }   
        }    
        if(!contentIdSet.isEmpty()){
            for(ContentDistribution eachCDS : [SELECT id,ContentVersionId,Name, ContentDocumentId,DistributionPublicUrl,
                                               Password FROM ContentDistribution WHERE ContentDocumentId IN:contentIdSet AND RelatedRecordId =:caseRecordId])
            {
                 alreadyExistingPublicUrlCVIdSet.add(eachCDS.ContentVersionId);
                 String recordString = eachCDS.Name + ',' +eachCDS.DistributionPublicUrl+','+eachCDS.Password +'\n';
                 if(csvFinalString.length() < MAX_LENGTH_FOR_FILE){
                 	csvFinalString = csvFinalString + recordString;
                 }   
            }
            for(Id eachCVId : contentVersionIdAndNameMap.keySet()){
                if(!alreadyExistingPublicUrlCVIdSet.contains(eachCVId)){
                     contentDistributionRecordCVIdList.add(eachCVId);
               		 ContentDistribution contentShare = new ContentDistribution();
                     contentShare.Name = contentVersionIdAndNameMap.get(eachCVId);
                     contentShare.ContentVersionId = eachCVId;
                     contentShare.RelatedRecordId = caseRecordId;
                     contentShare.PreferencesPasswordRequired = true;
                     contentShare.PreferencesNotifyOnVisit = false;
                     insertContentDistributionList.add(contentShare);
                }    
                
            }
        }    
            if(!insertContentDistributionList.isEmpty()){
                INSERT insertContentDistributionList;
                 // After insertion SOQL is required to get DistributionPublicUrl and Password, without query both fields returns null value              
                 for(ContentDistribution eachCDE : [SELECT Name, DistributionPublicUrl,Password FROM ContentDistribution 
                                                 WHERE ContentVersionId IN:contentDistributionRecordCVIdList AND RelatedRecordId =:caseRecordId])
                {
                     String recordString = eachCDE.Name + ',' +eachCDE.DistributionPublicUrl+','+eachCDE.Password +'\n';
                     if(csvFinalString.length() < MAX_LENGTH_FOR_FILE){
                 			csvFinalString = csvFinalString + recordString;
                 	 } 
                }
            }    

           //Create or Update CSV file
            if(csvHeader != csvFinalString){
                createOrUpdateCSVFile(csvFinalString,csvFileTitle,csvFilePathOnClient,caseRecordId);
            }
    }
    
    public static void createOrUpdateCSVFile(String csvFinalString,String csvFileTitle,String filePathOnClient,Id caseRecordId){
        
        
        List<ContentVersion> fileForSAP = [SELECT ID,VersionData,Title FROM ContentVersion WHERE PathOnClient=:filePathOnClient LIMIT 1];
        if(!fileForSAP.isEmpty()){
            fileForSAP[0].VersionData = Blob.valueOf(csvFinalString);
            UPDATE fileForSAP[0];
        }else{
            ContentVersion content = new ContentVersion();
            content.VersionData = Blob.valueOf(csvFinalString);
            content.PathOnClient = filePathOnClient;
            content.Title = csvFileTitle;
            content.IsMajorVersion = false;
            INSERT content;
           
            ContentVersion getCV = [SELECT ContentDocumentId,OwnerId FROM ContentVersion WHERE  Id =:content.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = getCV.ContentDocumentId;
            cdl.LinkedEntityId = caseRecordId;
            INSERT cdl;
            
            cdl.Visibility = 'InternalUsers';
            UPDATE cdl;
        }
    }
    
    @AuraEnabled
    public static Object createComplaintInSAPAndGetSAPCaseNumber(Id recId){
       
      return ComplaintCreationOnSAPCallout.createComplaintOnSAPAndGetSAPCaseNumber(new set<Id>{recId});
          
    }
    
     
}