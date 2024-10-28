/*
@Author     : Rohit Kumar
@CreatedDate: 10-05-2021
@UsedBy     : CaseCommentTriggerHandler
@Description: Update Case status(by bypassing validation rule for customer community)  if customer created any case comment record
*/

public without sharing class CaseUpdateOnCreationOfCaseCommentHandler {
    
    public static void updateCaseStatusOnCreationOfCaseComment(List<CaseComment> caseCommentList){
        
        List<Case> updateCaseOnCreationOfCaseComment = new List<Case>();
        Map<Id,Id> caseToCaseCommentCreatedByIdMapping = new Map<Id,Id>();
        Boolean isCommunityUser = false;
        
        User currentUser = [SELECT id,Contactid,Profile.Name FROM User WHERE id=:userinfo.getUserId()];
        system.debug('currentUser:'+currentUser);
        if(currentUser.Contactid!=null){
            isCommunityUser=true;
        }
        
        Global_Automation_Setting__c globalSetting =  Global_Automation_Setting__c.getInstance(currentUser.ProfileId);
        
        for(CaseComment comment : caseCommentList){
            
            if(String.isNotBlank(comment.CommentBody)){
                caseToCaseCommentCreatedByIdMapping.put(comment.ParentId,comment.CreatedById);
            }
        }
        
        for(Case caseToUpdate :[SELECT id,Status,Case_Requestor__c FROM Case WHERE id IN:caseToCaseCommentCreatedByIdMapping.keySet()]){
            system.debug('casecommentRequest::'+caseToCaseCommentCreatedByIdMapping.get(caseToUpdate.id));
            system.debug('caseRequest::'+caseToUpdate.Case_Requestor__c);
            if(!(caseToUpdate.Status).equals('Closed') && !(caseToUpdate.Status).equals('Response Received') && caseToUpdate.Case_Requestor__c != null && caseToUpdate.Case_Requestor__c.equals(caseToCaseCommentCreatedByIdMapping.get(caseToUpdate.id))){
                caseToUpdate.Status = 'Response Received';
                updateCaseOnCreationOfCaseComment.add(caseToUpdate);
            }else if((caseToUpdate.Status).equals('Closed') && isCommunityUser){
                caseToUpdate.Status = 'Reopened';
                updateCaseOnCreationOfCaseComment.add(caseToUpdate);
            }
        }
        
        if(isCommunityUser && !globalSetting.Skip_Validation_Rule__c && updateCaseOnCreationOfCaseComment.size()>0){
            globalSetting.Skip_Validation_Rule__c = true;
            UPDATE globalSetting;
        }
        
        if(updateCaseOnCreationOfCaseComment.size()>0){
            UPDATE updateCaseOnCreationOfCaseComment;
        }
        
        if(isCommunityUser && globalSetting.Skip_Validation_Rule__c && updateCaseOnCreationOfCaseComment.size()>0){
            globalSetting.Skip_Validation_Rule__c = false;
            UPDATE globalSetting;
        }
        
    }
}