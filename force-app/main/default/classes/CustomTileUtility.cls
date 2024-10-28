public with sharing class CustomTileUtility {

    public static List<Tile__c> allTiles { get; set; }
    public static List<Tile__c> allEndTiles { get; set; }

    public static List<Tile__c> getAllTilesTreeFromRoot(List<String> mainTileNames) {
        setTileWholeTileStructureFromMainTile(mainTileNames);
        return allTiles;
    }

    public static List<Tile__c> getAllEndTilesTreeFromRoot(List<String> mainTileNames) {
        setTileWholeTileStructureFromMainTile(mainTileNames);
        return allEndTiles;
    }

    public static void setTileWholeTileStructureFromMainTile(List<String> mainTileNames) {
        allTiles = new List<Tile__c>();
        allEndTiles = new List<Tile__c>();

        List<Tile__c> tls = [
                SELECT Id, Name, Order_Number__c, Child_Order_Option__c, UI_Name__c, Redirect_To_Details__c, Article_Url_Name__c, File_Public_Link__c, Confidential_Content__c,
                    (SELECT Id, Name FROM Child_Tiles__r)
                FROM Tile__c
                WHERE Name in:mainTileNames
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
    
}