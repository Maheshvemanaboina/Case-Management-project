/*
@Author     : Rohit Kumar
@CreatedDate: 08-11-2021
@UsedBy     : ContentDocLinkTrigger (Trigger Handler)
@Description: This class set the content visiblity to all user, except for investigaton report send from SAP to notification request 

@History
08-11-2021  Rohit Kumar : Created
*/
public class ContentDocLinkUpdateVisiblity {
    
    
    public static void updateVisiblityOfLinkedContentToSObject(List<ContentDocumentLink> contentLinkList){
        Id currentUserProfileId = UserInfo.getProfileId();
        //initialized the variable for null pointer exception.
       
        Set<Id> contentDocumentIdSet = new Set<Id>();
        Set<Id> contentLinkedEntityIdSet = new Set<Id>();
        List<ContentDocumentLink> caseRealtedContentLink = new List<ContentDocumentLink>();
        
        for(ContentDocumentLink cdl :contentLinkList){
            
            if(cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Case' && cdl.LinkedEntityId.getSObjectType().getDescribe().getName() != 'Supplier_Hub__c'){
                
                contentLinkedEntityIdSet.add(cdl.LinkedEntityId);
                contentDocumentIdSet.add(cdl.ContentDocumentId);
                caseRealtedContentLink.add(cdl);
            }else if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() != 'Supplier_Hub__c'){
                cdl.Visibility = 'AllUsers';
            }   
        }
        
        if(!contentLinkedEntityIdSet.isEmpty()){
            excludeUpdateOfContentVisiblityCase(contentLinkedEntityIdSet,contentDocumentIdSet,caseRealtedContentLink);
        }
        
    }      
    
    private static void excludeUpdateOfContentVisiblityCase(Set<id> CaseIdsSet, Set<id> contentIdSet,List<ContentDocumentLink> caseRealtedContentLink){
        
        Map<Id,String> caseIdAndRecordTypeDeveloperNameMap = new Map<Id,String>();
        Map<Id,ContentVersion> contentIdAndContentVersionMap = new Map<Id,ContentVersion>();
        BGI_Salesforce_Settings__c  customSettings = BGI_Salesforce_Settings__c.getOrgDefaults();
        //List<User> getAPIUserId = [SELECT id FROM User WHERE Profile.Name='BGI Integration' AND Name='API User' LIMIT 1];
        
        for(Case record : [SELECT Id,RecordType.DeveloperName FROM Case WHERE id IN:CaseIdsSet]){
            if(record.RecordType.DeveloperName == 'Danone_Complaint'){
                caseIdAndRecordTypeDeveloperNameMap.put(record.Id,record.RecordType.DeveloperName);
            }
        }
        
        if(customSettings.API_User_ID__c != null){
            for(ContentVersion version : [SELECT ContentDocumentId,CreatedById,Title,FileExtension FROM ContentVersion
                                          WHERE ContentDocumentId IN:contentIdSet AND IsLatest=true AND
                                          CreatedById=:customSettings.API_User_ID__c AND FileExtension ='pdf'])
            {
                contentIdAndContentVersionMap.put(version.ContentDocumentId, version);
            }
        }    
        
        for(ContentDocumentLink cdl : caseRealtedContentLink){
            
            if(caseIdAndRecordTypeDeveloperNameMap.containsKey(cdl.LinkedEntityId) && contentIdAndContentVersionMap.containskey(cdl.ContentDocumentId)){
                /*if(caseIdAndRecordTypeDeveloperNameMap.get(cdl.LinkedEntityId) == 'Danone_Complaint' &&
                   contentIdAndContentVersionMap.get(cdl.ContentDocumentId).CreatedById == getAPIUserId[0].id &&
                   contentIdAndContentVersionMap.get(cdl.ContentDocumentId).FileExtension =='pdf')
                {
                    continue;
                }else{
                    cdl.Visibility = 'AllUsers';
                }*/
                continue;
            }else{
                cdl.Visibility = 'AllUsers';
            }
        }
    }
    
}