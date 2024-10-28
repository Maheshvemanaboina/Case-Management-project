/********************************************************************************************************************************************************************************************************************
* @UserStory		:	143335-As a SM/Sales Support Officer, when a LSD SCAF record is not satisfying any of the Approval criteria, I should see a display message that Approval is not needed
* @Author   		:   LSD SCAF Expedition 2030 Dev Team
* @Modified Date 	:   27 May 2024
* @Desc 			:   Class for Lightning Web Component 'ScafApprovalDocumentsCheck' to display the error messages for file upload and no approval needed.
****************************************************************************************************************************************************************************************/
public class LSDFileUploadPopUpController {
    
    @AuraEnabled
    public static Integer getFileDetailsForLSD(string recordId){
        try{
            List<ContentDocumentLink> contentLinkList =   [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:recordId and LinkedEntity.Type='Legal_Sales_Document__c'];
            Legal_Sales_Document__c lsdRec = [SELECT Id,Name,File_Count__c FROM Legal_Sales_Document__c WHERE Id=:recordId];
            if(lsdRec.File_Count__c  != contentLinkList.size()){
                lsdRec.File_Count__c = contentLinkList.size();
                update lsdRec;
            }
            return contentLinkList.size();
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage()+' '+ex.getLineNumber());
        }  
    }
     
    @AuraEnabled
    public static Integer getFileDetailsForScaf(string recordId){
        try{
            List<ContentDocumentLink> contentLinkList =   [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:recordId and LinkedEntity.Type='Scaf__c'];
            return contentLinkList.size();
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage()+' '+ex.getLineNumber());
        }  
    }
    
    /*US-143335 - Method to get Approval_Levels_Required__c from SACF */
    @AuraEnabled
    public static Decimal getapprovalLevelsRequired(string recordId){
         Scaf__c scafRecord = [SELECT Approval_Levels_Required__c FROM Scaf__c WHERE Id = :recordId LIMIT 1];
    if(scafRecord != null ) {
        return scafRecord.Approval_Levels_Required__c;
        
    } else {
        return null;
    }
    }
}