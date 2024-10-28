public class CreatePublicURLAndKnowledgeTiles implements Queueable {

    // Class variables to hold the method parameters
    private Id contentVerId;
    private String knowledgeArticleName;
    private String knowledgeArticleURL;
    private String fileName;
    private String reviewOrEndDate;
    private String contentPathLocationList;
    private List<String> businessSegments;
    private List<String> subSegments;
    private List<String> salesRegions;
    private String selectedCommunityNames;
    private String knowledgeDescription;
    private String contentCategoriesObjList;
    private String selectedH1;
    private String selectedH5;
    private String selectedContentOwner;

    // Constructor to initialize the class variables
    public CreatePublicURLAndKnowledgeTiles(
        Id contentVerId, 
        String knowledgeArticleName, 
        String knowledgeArticleURL, 
        String fileName, 
        String reviewOrEndDate, 
        String contentPathLocationList,
        List<String> businessSegments, 
        List<String> subSegments, 
        List<String> salesRegions,
        String selectedCommunityNames,
        String knowledgeDescription,
        String contentCategoriesObjList,
        String selectedH1,
        String selectedH5,
        String selectedContentOwner) {
        
        this.contentVerId = contentVerId;
        this.knowledgeArticleName = knowledgeArticleName;
        this.knowledgeArticleURL = knowledgeArticleURL;
        this.fileName = fileName;
        this.reviewOrEndDate = reviewOrEndDate;
        this.contentPathLocationList = contentPathLocationList;
        this.businessSegments = businessSegments;
        this.subSegments = subSegments;
        this.salesRegions = salesRegions;
        this.selectedCommunityNames = selectedCommunityNames;
        this.knowledgeDescription = knowledgeDescription;
        this.contentCategoriesObjList = contentCategoriesObjList;
        this.selectedH1 = selectedH1;
        this.selectedH5 = selectedH5;
        this.selectedContentOwner = selectedContentOwner;
    }

    // Implement the execute method of the Queueable interface
    public void execute(QueueableContext context) {
        String filepublicURL = ContentManagementHelper.getFilePublicURL(contentVerId, fileName);

        Knowledge__kav newArticle = KnowledgeArticleUtility.createNewArticleAsADraft(
            knowledgeArticleName,
            knowledgeArticleURL,
            true,
            ContentManagementController.KNOWLEDGE_COMMUNITY_ARTICLE_RECORD_TYPE_ID,
            String.join(businessSegments, ';'),
            String.join(subSegments, ';'),
            String.join(salesRegions, ';'),
            selectedContentOwner, // ENH-4370
            Date.valueOf(reviewOrEndDate),
            false,
            true,
            true,
            ContentManagementHelper.getArticleDetailsIframeURL(filepublicURL),
            knowledgeDescription
        );

        try {
            insert newArticle;
        } catch (Exception e) {
            system.debug('+++++exception while creating article record: ' + e.getMessage());
        }

        Id KnowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :newArticle.Id].KnowledgeArticleId;
        
        KnowledgeArticleUtility.publishArticle(KnowledgeArticleId);

        ContentManagementController.createKnowledgeTilesAndRelatedTiles(
            contentVerId, 
            selectedCommunityNames,
            knowledgeArticleName, 
            knowledgeDescription, 
            reviewOrEndDate,
            contentCategoriesObjList, 
            contentPathLocationList,
            businessSegments, 
            subSegments, 
            salesRegions,
            newArticle.Id, 
            selectedH1, 
            selectedH5, 
            selectedContentOwner // ENH-4370
        );
    }
}