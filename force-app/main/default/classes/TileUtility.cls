/**
 * Created by KJM on 20/05/2019.
 */

public without sharing class TileUtility {

    //public static final String FCI_DISTRIBUTOR_MAIN_TILE_NAME = 'FCI Distributor Recipes Main Tile';

    public static List<Tile__c> allTiles { get; set; }
    public static List<Tile__c> allEndTiles { get; set; }

    public static List<TileStructureWrapper> getTilesStructuredByName(String tileName) {
        List<Tile__c> tiles  = validateTiles(getChildTilesByName(tileName));
        return buildTileStructureWrappers(getUserAccessToRelatedObjects(tiles), tiles);
    }
    public static List<TileStructureWrapper> getTilesStructuredById(String parentId) {
        List<Tile__c> tiles = validateTiles(getChildTilesById(parentId));
        return buildTileStructureWrappers(getUserAccessToRelatedObjects(tiles), tiles);
    }

    public static Map<Id, ContentVersion> getTilesImageMap(List<TileUtility.TileStructureWrapper> tiles) {
        Set<Id> tilesDocsIds = new Set<Id>();
        for (TileUtility.TileStructureWrapper tl : tiles) {
            if (tl.ParentTile.ContentDocumentLinks == null || tl.ParentTile.ContentDocumentLinks.isEmpty()) {
                continue;
            }

            tilesDocsIds.add(tl.ParentTile.ContentDocumentLinks.get(0).ContentDocumentId);
        }

        List<ContentVersion> contentVersions = [
                SELECT Id,
                        ContentBodyId,
                        ContentDocumentId,
                        ContentUrl
                FROM ContentVersion
                WHERE ContentDocumentId IN :tilesDocsIds
        ];

        Map<Id, ContentVersion> contentDocs = new Map<Id, ContentVersion>();
        for (ContentVersion contVer : contentVersions) {
            contentDocs.put(contVer.ContentDocumentId, contVer);
        }

        Map<Id, ContentVersion> tileImageMap = new Map<Id, ContentVersion>();
        for (TileUtility.TileStructureWrapper tl : tiles) {
            if (tl.ParentTile.ContentDocumentLinks == null || tl.ParentTile.ContentDocumentLinks.isEmpty() || !contentDocs.containsKey(tl.ParentTile.ContentDocumentLinks.get(0).ContentDocumentId)) {
                continue;
            }

            tileImageMap.put(tl.ParentTile.Id, contentDocs.get(tl.ParentTile.ContentDocumentLinks.get(0).ContentDocumentId));
        }

        return tileImageMap;
    }

    public static Knowledge__kav getKnowledgeArticle(String articleId) {
        List<Knowledge__kav> knows = [
                SELECT Id, Title, UrlName
                FROM Knowledge__kav
                WHERE Id = :articleId
        ];

        if (knows.isEmpty()) {
            return null;
        }

        return knows.get(0);
    }

    public static Tile__c getTileByArticleUrlName(String articleUrlName) {
        List<Tile__c> tls = [
                SELECT Id, Business_Segment__c, Sales_Region__c, Tile_Type__c
                FROM Tile__c
                WHERE Article_Url_Name__c = :articleUrlName
        ];

        if (tls.isEmpty()) {
            return null;
        }

        return tls.get(0);
    }

    public static Tile__c getTileByName(String tileName) {
        List<Tile__c> tls = [
                SELECT Id, Name, UI_Name__c, Child_Order_Option__c, Order_Number__c, Child_Display_Option__c, Redirect_To_Details__c, Article_Url_Name__c, File_Public_Link__c, Confidential_Content__c
                FROM Tile__c
                WHERE Name = :tileName
        ];

        if (tls.isEmpty()) {
            return null;
        }

        return tls.get(0);
    }

    public static Tile__c getTileById(String tileId) {
        List<Tile__c> tls = [
                SELECT Id, Child_Order_Option__c, Order_Number__c, Child_Display_Option__c, Redirect_To_Details__c, Article_Url_Name__c, File_Public_Link__c, Confidential_Content__c
                FROM Tile__c
                WHERE Id = :tileId
        ];

        if (tls.isEmpty()) {
            return null;
        }

        return tls.get(0);
    }

    private static List<Tile__c> getChildTilesByName(String tileName) {


        String childQuery = getMainTileQueryFields() + ' FROM Child_Tiles__r WHERE ';
        childQuery += TileVisibilityUtility.getVisibilityCriteria(Constants.EMPTY_STRING);
        childQuery = childQuery.trim();
        if (childQuery.endsWith('AND')) {
            childQuery = childQuery.removeEnd('AND');
        }
        system.debug('childQuery---'+childQuery);
        String query = getMainTileQueryFields() + ', ' +
                '(SELECT ContentDocumentId FROM ContentDocumentLinks), ' +
                '(' + childQuery + ' ORDER BY UI_Name__c ) '+
                'FROM Tile__c ' +
        		'WHERE Parent_Tile__r.Name = :tileName ';

        query += Constants.QUERY_AND +  TileVisibilityUtility.getVisibilityCriteria(Constants.EMPTY_STRING);

        String accountQuery = TileVisibilityUtility.getAccountCriteriaQuery(tileName);

        if(!String.isBlank(accountQuery)){

            query += Constants.QUERY_AND + accountQuery;
        }

        //query += ' ORDER BY LastmodifiedDate desc ';
		 query = query.trim();
        if (query.endsWith('AND')) {
            query = query.removeEnd('AND');
        }
        system.debug('query----'+query);
		query += ' ORDER BY UI_Name__c ';
        return (List<Tile__c>)Database.query(query);
    }

    private static List<Tile__c> getChildTilesById(String parentId) {
        string accId = UserUtility.getCurrentUser().Community_User_Role__c == 'Standard User' ? UserUtility.getCurrentUser().Contact.AccountId : UserUtility.getCurrentUser().Contact.Parent_Account__c;
        Set<Id> tilesAccountRelated = new Set<Id>();

        String childQuery = getMainTileQueryFields() + ' FROM Child_Tiles__r WHERE ';
        childQuery += TileVisibilityUtility.getVisibilityCriteria(Constants.EMPTY_STRING);
        childQuery = childQuery.trim();
        if (childQuery.endsWith('AND')) {
            childQuery = childQuery.removeEnd('AND');
        }
        String query = getMainTileQueryFields() + ', ' +
                '(SELECT ContentDocumentId FROM ContentDocumentLinks), ' +
                '(' + childQuery + ' ORDER BY UI_Name__c ) '+
                'FROM Tile__c ' +
        		'WHERE Parent_Tile__c = :parentId ';

        query += Constants.QUERY_AND +  TileVisibilityUtility.getVisibilityCriteria(Constants.EMPTY_STRING);

        String accountQuery = TileVisibilityUtility.getAccountCriteriaQuery(parentId);

        if(!String.isBlank(accountQuery)){

            query += Constants.QUERY_AND + accountQuery;
        }
        query += 'ID IN (SELECT Tile__c from Tile_Account__c where Account__c = :accId AND Tile__r.Parent_Tile__c = :parentId)';
         query = query.trim();
        if (query.endsWith('AND')) {
            query = query.removeEnd('AND');
        }
        system.debug('query----'+query);
		query += ' ORDER BY UI_Name__c ';
        return (List<Tile__c>)Database.query(query);
    }

    private static String getMainTileQueryFields() {
        return 'SELECT Id, Name, UI_Name__c, UI_Description__c, Redirect_To_Details__c, Article_Url_Name__c, Article_Name__c, Tile_Type__c, File_Public_Link__c, Confidential_Content__c, Child_Display_Option__c, Child_Order_Option__c, Order_Number__c ';
    }

    private static String getParentQueryBasedOnChildTileAvailablity(){
        return 'Id IN (SELECT Parent_Tile__c FROM Tile__c)';
    }

    private static Set<Id> getUserAccessToRelatedObjects(List<Tile__c> tiles) {
        Set<Id> objToCheckIds = new Set<Id>();

        Set<Id> confidentialIds = new Set<Id>();

        for (Tile__c tl : tiles) {
            if (!String.isBlank(tl.Confidential_Content__c)) {confidentialIds.add(tl.Confidential_Content__c);}
            if (!String.isBlank(tl.Article_Name__c))  {objToCheckIds.add(tl.Article_Name__c);}
            for (Tile__c chTl : tl.Child_Tiles__r) {
                if (!String.isBlank(chTl.Confidential_Content__c)) {confidentialIds.add(chTl.Confidential_Content__c);}
                if (!String.isBlank(chTl.Article_Name__c)) {objToCheckIds.add(chTl.Article_Name__c);}
            }
        }

        for(Confidential_Content__Share eachConfidential : [SELECT Id,ParentId FROM Confidential_Content__Share
                                                            WHERE ParentId IN: confidentialIds
                                                            AND UserOrGroupId =: UserInfo.getUserId()]){
            objToCheckIds.add(eachConfidential.ParentId);

        }

        return objToCheckIds;
    }

    private static List<TileStructureWrapper> buildTileStructureWrappers(Set<Id> usrAccessToRelatedObjSet, List<Tile__c> tiles) {
        List<TileStructureWrapper> tileStructureWrappers = new List<TileStructureWrapper>();
        for (Tile__c tl : tiles) {

            List<Tile__c> accessibleChildTiles = new List<Tile__c>();
            for (Tile__c chTl : tl.Child_Tiles__r) {
                if (
                     (!String.isBlank(chTl.Confidential_Content__c) && !usrAccessToRelatedObjSet.contains(chTl.Confidential_Content__c)) ||
                     (!String.isBlank(chTl.Article_Name__c) && !usrAccessToRelatedObjSet.contains(chTl.Article_Name__c))
                   ) {
                    continue;
                }

                accessibleChildTiles.add(chTl);
            }

            if (
                    (!String.isBlank(tl.Confidential_Content__c) && !usrAccessToRelatedObjSet.contains(tl.Confidential_Content__c)) ||
                    (!String.isBlank(tl.Article_Name__c) && !usrAccessToRelatedObjSet.contains(tl.Article_Name__c))
                ) {
                continue;
            }

            tileStructureWrappers.add(new TileStructureWrapper(
                    tl, accessibleChildTiles
            ));
        }

        return tileStructureWrappers;
    }

    public class TileStructureWrapper {
        public Tile__c ParentTile { get; set; }
        public List<Tile__c> ChildTiles { get; set; }

        public TileStructureWrapper(Tile__c parentTile, List<Tile__c> childTiles) {
            this.ParentTile = parentTile;
            this.ChildTiles = childTiles;
        }
    }

    public static List<Tile__c> getAllTilesTreeFromRoot(String mainTileName) {
        setTileWholeTileStructureFromMainTile(mainTileName);
        return allTiles;
    }

    public static List<Tile__c> getAllEndTilesTreeFromRoot(String mainTileName) {
        setTileWholeTileStructureFromMainTile(mainTileName);
        return allEndTiles;
    }

    public static void setTileWholeTileStructureFromMainTile(String mainTileName) {
        allTiles = new List<Tile__c>();
        allEndTiles = new List<Tile__c>();

        List<Tile__c> tls = [
                SELECT Id, Name, Order_Number__c, Child_Order_Option__c, UI_Name__c, Redirect_To_Details__c, Article_Url_Name__c, File_Public_Link__c, Confidential_Content__c,
                    (SELECT Id, Name FROM Child_Tiles__r)
                FROM Tile__c
                WHERE Name = :mainTileName
        ];

        getTileRecursive(tls);
    }

    private static void getTileRecursive(List<Tile__c> tiles) {
        allTiles.addAll(tiles);

        List<Tile__c> tilesToDeepGet = new List<Tile__c>();
        for (Tile__c tile : tiles) {
            if (!tile.Child_Tiles__r.isEmpty()) {
                tilesToDeepGet.addAll(tile.Child_Tiles__r);
            } else {
                allEndTiles.add(tile);
            }
        }

        if (tilesToDeepGet.isEmpty()) {
            return;
        }

        String query = 'SELECT Id, Name, UI_Name__c, Order_Number__c, Child_Order_Option__c, Redirect_To_Details__c, Article_Url_Name__c, File_Public_Link__c, Confidential_Content__c, (SELECT Id, Name FROM Child_Tiles__r) FROM Tile__c WHERE Id IN :tilesToDeepGet';
        query += Constants.QUERY_AND +  TileVisibilityUtility.getVisibilityCriteria(Constants.EMPTY_STRING);
        List<Tile__c> tilesToDeepGetDB = (List<Tile__c>)Database.query(query);
        getTileRecursive(tilesToDeepGetDB);
    }

    public static List<Tile__c> validateTiles(List<Tile__c> tiles){
        List<Tile__c> tilesWithChildRecords = new List<Tile__c>();
        for(Tile__c parentTile : tiles){
            if(parentTile.Article_Name__c == null && parentTile.File_Public_Link__c == null){
                if(parentTile.Child_Tiles__r.size() > 0){
                  tilesWithChildRecords.add(parentTile);
                }
            }else{
                tilesWithChildRecords.add(parentTile);
            }
        }
        return tilesWithChildRecords;
}
    }