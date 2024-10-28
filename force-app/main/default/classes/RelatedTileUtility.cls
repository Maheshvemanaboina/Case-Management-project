/**
 * Created by KJM on 20/05/2019.
 */

public with sharing class RelatedTileUtility {
    public static Map<String, List<Related_Tile__c>> getRelatedTilesByTileType(List<Related_Tile__c> tiles) {
        Map<String, List<Related_Tile__c>> tileMap = new Map<String, List<Related_Tile__c>>();

        for (Related_Tile__c tl : tiles) {
            System.debug('tl.Related_Tile_Type__c-->'+tl.Related_Tile_Type__c);
            if (!tileMap.containsKey(tl.Related_Tile_Type__c)) {
                tileMap.put(tl.Related_Tile_Type__c, new List<Related_Tile__c>());
            }
            tileMap.get(tl.Related_Tile_Type__c).add(tl);
        }

        return tileMap;
    }

    public static List<Related_Tile__c> getRelatedTiles(String tileId) {
        String query = getRelatedTileObjMainQuery() +
                'WHERE ' +
                'Tile__c = :tileId ';

        query += Constants.QUERY_AND + TileVisibilityUtility.getVisibilityCriteria(Constants.RELATED_TILE_SUB_QUERY_PREFIX);
        query += ' ORDER BY Sorting_Order__c ASC';
        return (List<Related_Tile__c>)Database.query(query);
    }

    public static List<Related_Tile__c> getRelatedToTiles(String tileId) {
        String query = getRelatedTileObjMainQuery() +
                'WHERE ' +
                'Related_Tile__c = :tileId ';

        query += Constants.QUERY_AND + TileVisibilityUtility.getVisibilityCriteria(Constants.TILE_SUB_QUERY_PREFIX);
        query += ' ORDER BY Sorting_Order__c ASC';
        return (List<Related_Tile__c>)Database.query(query);
    }

    private static String getRelatedTileObjMainQuery() {
        return 'SELECT Id, Related_Tile__c, Related_Tile__r.UI_Name__c, Related_Tile__r.Article_Url_Name__c, ' +
                'Tile__c, Tile__r.Id, Tile__r.Tile_Type__c, Tile__r.Article_Url_Name__c, Tile__r.UI_Name__c, Related_Tile_Type__c, ' +
                'Tile__r.Business_Segment__c, Tile__r.Sales_Region__c, Tile__r.Community_Name__c ' +
                'FROM Related_Tile__c ';
    }
}