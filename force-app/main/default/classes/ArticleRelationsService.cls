/**
 * Created by KJM on 20/05/2019.
 */

public with sharing class ArticleRelationsService {
    public static List<TreeItemElement> getChildTileRelations(Tile__c currentTile) {
        if (!ifGetRelations(currentTile)) {return new List<TreeItemElement>();}

        List<Related_Tile__c> relations = RelatedTileUtility.getRelatedTiles(currentTile.Id);
        return getArticleRelationsListFromParent(RelatedTileUtility.getRelatedTilesByTileType(relations));
    }

    public static List<TreeItemElement> getParentsTileRelations(Tile__c currentTile) {
        if (!ifGetRelations(currentTile) || !ifGetParentRelations(currentTile)) {return new List<TreeItemElement>();}

        List<Related_Tile__c> relations = RelatedTileUtility.getRelatedToTiles(currentTile.Id);
        return getArticleRelationsListFromChild(RelatedTileUtility.getRelatedTilesByTileType(relations));
    }

    public static List<TreeItemElement> getCertificateTileRelations(Tile__c currentTile) {
        if (!ifGetRelations(currentTile) || !ifGetRelationsForCertificate(currentTile)) {return new List<TreeItemElement>();}

        List<Related_Tile__c> relations = RelatedTileUtility.getRelatedToTiles(currentTile.Id);
        return getArticleRelationsListFromCertificate(RelatedTileUtility.getRelatedTilesByTileType(relations));
    }

    private static Boolean ifGetRelations(Tile__c currentTile) {
        return  currentTile.Tile_Type__c != Constants.TILE_TYPE_CERTIFICATE && CommunityUtility.getCurrentCommunityOptions().Show_relations_on_articles__c ||
                currentTile.Tile_Type__c == Constants.TILE_TYPE_CERTIFICATE && CommunityUtility.getCurrentCommunityOptions().Show_relations_on_certificate_article__c;
    }

    private static Boolean ifGetParentRelations(Tile__c currentTile) {
        return currentTile.Tile_Type__c != Constants.TILE_TYPE_CERTIFICATE && CommunityUtility.getCurrentCommunityOptions().Show_relations_in_both_sides__c;
    }

    private static Boolean ifGetRelationsForCertificate(Tile__c currentTile) {
        return currentTile.Tile_Type__c == Constants.TILE_TYPE_CERTIFICATE;
    }

    private static List<TreeItemElement> getArticleRelationsListFromParent(Map<String, List<Related_Tile__c>> tileMapByType) {
        List<TreeItemElement> TreeItemElements = new List<TreeItemElement>();

        for (String tileType : tileMapByType.keySet()) {
            List<TreeItemElement> itms = new List<TreeItemElement>();

            for (Related_Tile__c tl : tileMapByType.get(tileType)) {
                itms.add(new TreeItemElement(tl.Related_Tile__r.UI_Name__c, tl.Related_Tile__r.UI_Name__c, null, false, CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_ARTICLE_LINK + tl.Related_Tile__r.Article_Url_Name__c, Constants.EMPTY_STRING));
            }

            TreeItemElements.add(new TreeItemElement(
                    tileType, tileType, itms, true, null, Constants.EMPTY_STRING
            ));
        }

        return TreeItemElements;
    }

    /*private static List<TreeItemElement> getArticleRelationsListFromChild(Map<String, List<Related_Tile__c>> tileMapByType) {
        List<TreeItemElement> TreeItemElements = new List<TreeItemElement>();
        for (String tileType : tileMapByType.keySet()) {
            List<TreeItemElement> itms = new List<TreeItemElement>();

            for (Related_Tile__c tl : tileMapByType.get(tileType)) {
                if (tl.Tile__r.Tile_Type__c == Constants.TILE_TYPE_CERTIFICATE) {continue;}

                itms.add(new TreeItemElement(tl.Tile__r.UI_Name__c, tl.Tile__r.UI_Name__c, null, false, CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_ARTICLE_LINK + tl.Tile__r.Article_Url_Name__c, Constants.EMPTY_STRING));
            }

            if (itms.isEmpty()){continue;}

            TreeItemElements.add(new TreeItemElement(
                    'Related Product Specifications',tileType, itms, true, null, Constants.EMPTY_STRING
            ));
        }
        return TreeItemElements;
    }*/
    private static List<TreeItemElement> getArticleRelationsListFromChild(Map<String, List<Related_Tile__c>> tileMapByType) {
    List<TreeItemElement> TreeItemElements = new List<TreeItemElement>();
    List<TreeItemElement> consolidatedItems = new List<TreeItemElement>();

    for (String tileType : tileMapByType.keySet()) {
        for (Related_Tile__c tl : tileMapByType.get(tileType)) {
            if (tl.Tile__r.Tile_Type__c == Constants.TILE_TYPE_CERTIFICATE) {
                continue;
            }
            consolidatedItems.add(new TreeItemElement(
                tl.Tile__r.UI_Name__c,
                tl.Tile__r.UI_Name__c,
                null,
                false,
                CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_ARTICLE_LINK + tl.Tile__r.Article_Url_Name__c,
                Constants.EMPTY_STRING
            ));
        }
    }
    if (!consolidatedItems.isEmpty()) {
        TreeItemElements.add(new TreeItemElement(
            'Related Product Specifications',
            null,
            consolidatedItems,
            true,
            null,
            Constants.EMPTY_STRING
        ));
    }
    return TreeItemElements;
}
    @TestVisible
    private static List<TreeItemElement> getArticleRelationsListFromCertificate(Map<String, List<Related_Tile__c>> tileMapByType) {
        List<TreeItemElement> TreeItemElements = new List<TreeItemElement>();

        for (String tileType : tileMapByType.keySet()) {
            List<TreeItemElement> itms = new List<TreeItemElement>();

            for (Related_Tile__c tl : tileMapByType.get(tileType)) {
                itms.add(new TreeItemElement(tl.Tile__r.UI_Name__c, tl.Tile__r.UI_Name__c, null, false, CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_ARTICLE_LINK + tl.Tile__r.Article_Url_Name__c, Constants.EMPTY_STRING));
            }

            if (tileType == Constants.TILE_TYPE_CERTIFICATE) {
                tileType = Constants.TILE_TYPE_PRODUCT_SPECIFICATION;
            }

            TreeItemElements.add(new TreeItemElement(
                    tileType, tileType, itms, true, null, Constants.EMPTY_STRING
            ));
        }

        return TreeItemElements;
    }

}