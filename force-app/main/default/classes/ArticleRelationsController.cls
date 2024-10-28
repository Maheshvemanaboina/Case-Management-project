/**
 * Created by KJM on 01/04/2019.
 */
public with sharing class ArticleRelationsController {
    @AuraEnabled
    public static String getRelatedArticles(String articleId) {
        Knowledge__kav knowl = TileUtility.getKnowledgeArticle(articleId);
        if (knowl == null) {return '';}
        Tile__c currentTile = TileUtility.getTileByArticleUrlName(knowl.UrlName);
        if (currentTile == null) {return '';}
        List<TreeItemElement> allRelations = new List<TreeItemElement>();
        allRelations.addAll(ArticleRelationsService.getChildTileRelations(currentTile));
        allRelations.addAll(ArticleRelationsService.getParentsTileRelations(currentTile));
        allRelations.addAll(ArticleRelationsService.getCertificateTileRelations(currentTile));
        if (allRelations.isEmpty()) {return '';}        
        return JSON.serializePretty(allRelations);
    }
}