/*------------------------------------------------------------  
Author:       Sibananda Bhuyan
Description:  This is the controller used for all utilities related to Knowledge objects

History
11-11-2020    Sibananda Bhuyan    Created Class
------------------------------------------------------------*/
public without sharing class KnowledgeArticleUtility {
      
    public static Knowledge__kav createNewArticleAsADraft(String title, String urlName, Boolean isValidated, Id recordTypeId,
                                                String businessSegments, String subSegments,String regions, Id knowledgeOwnerId, Date reviewOrExpDate, 
                                                Boolean isVisiblePublicKB, Boolean isVisibleCustomer, Boolean isVisiblePartner,
                                                String articleDetails, String articleDescription) {
    
        Knowledge__kav newArticle = new Knowledge__kav(

                    Title                   = title,
                    UrlName                 = urlName,
                    ValidationStatus        = isValidated ? 'Validated' : 'Not Validated',
                    RecordTypeId            = recordTypeId,
                    Business_Segment__c     = businessSegments,
                    Sub_Segment__c          = subSegments,
                    Region__c               = regions,
                    OwnerId                 = knowledgeOwnerId,
                    Review_Exp_Date__c      = reviewOrExpDate,
                    IsVisibleInPkb          = isVisiblePublicKB,
                    IsVisibleInCsp          = isVisibleCustomer,
                    IsVisibleInPrm          = isVisiblePartner,
                    Article_Details__c      = articleDetails,
                    Article_Description__c  = articleDescription
            );

        return newArticle;
    }
    
    //It need to be KnowledgeArticleId
    public static void publishArticle(String KnowledgeArticleId) { 
        KbManagement.PublishingService.publishArticle(KnowledgeArticleId, true);
    }
    
    /*
    public static List<Knowledge__kav> getAllArticles(){
        return [ SELECT Id, KnowledgeArticleId, Title, UrlName FROM Knowledge__kav ];
    }

    public static String unPublishArticle(String recordId){ //It need to be KnowledgeArticleId
        String newArticleId = KbManagement.PublishingService.editOnlineArticle(recordId, true); //Method new version id use it to update 
        return [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticleId].KnowledgeArticleId;
    }
    
    public static String updateDraftArticleWithoutPublish(String title, String urlName, Id recordId) {
    
        Knowledge__kav newArticle = [ SELECT Id, KnowledgeArticleId, Title, UrlName FROM Knowledge__kav WHERE KnowledgeArticleId =: recordId ];   
    
        newArticle.Title = title;
        newArticle.UrlName = urlName;
    
        update newArticle;
    
        return newArticle.KnowledgeArticleId;
    }
    
    public static String updatetArticle(String title, String urlName, Id recordId) {
    
        String newVersionId = unPublishArticle(recordId);
    
        Knowledge__kav newArticle = [ SELECT Id, KnowledgeArticleId, Title, UrlName FROM Knowledge__kav WHERE KnowledgeArticleId =: newVersionId ];   
    
        newArticle.Title = title;
        newArticle.UrlName = urlName;
    
        update newArticle;
    }*/
}