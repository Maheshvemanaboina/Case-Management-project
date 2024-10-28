/**
 * Created by KJM on 01/04/2019.
 */

public with sharing class TileListController {
    @AuraEnabled
    public static TilesListWrapper getTileListOnInit(String tileName) {
        Tile__c currentTile = TileUtility.getTileByName(tileName);
        return buildTilesWrapper(TileUtility.getTilesStructuredByName(tileName), currentTile);
    }

    @AuraEnabled
    public static TilesListWrapper getTileListByParent(String parentId) {
        Tile__c currentTile = TileUtility.getTileById(parentId);
        return buildTilesWrapper(TileUtility.getTilesStructuredById(parentId), currentTile);
    }

    @AuraEnabled
    public static TilesInfoWrapper getTileInfoByName(String tileName) {
        return TileListService.getTileInfoWrapper(tileName);
    }

    private static TilesListWrapper buildTilesWrapper(List<TileUtility.TileStructureWrapper> structuredTiles, Tile__c currentTile) {
        List<TileUtility.TileStructureWrapper> sortedTileStructure = TileListService.sortTileStructure(structuredTiles, currentTile);
        return new TilesListWrapper(
                TileListService.getTileChildDisplayOption(currentTile.Child_Display_Option__c),
                TileListService.getTileWrapperList(sortedTileStructure),
                TileListService.getTilesListList(sortedTileStructure),
                TileListService.getTilesNestedList(sortedTileStructure)
        );
    }

    public class TilesListWrapper {
        @AuraEnabled public String DisplayOption { get; private set; }
        @AuraEnabled public List<TileListService.TileListItemWrapper> TilesAsTiles { get; private set; }
        @AuraEnabled public List<TreeItemElement> TilesAsList { get; private set; }
        @AuraEnabled public List<TreeItemElement> TilesAsNestedList { get; private set; }

        public TilesListWrapper(String displayOption, List<TileListService.TileListItemWrapper> tilesAsTiles, List<TreeItemElement> tilesAsList, List<TreeItemElement> tilesAsNestedList) {
            this.DisplayOption = displayOption;
            this.TilesAsTiles = tilesAsTiles;
            this.TilesAsList = tilesAsList;
            this.TilesAsNestedList = tilesAsNestedList;
        }
    }

    public class TilesInfoWrapper {
        @AuraEnabled public String Id { get; private set; }
        @AuraEnabled public String Name { get; private set; }
        @AuraEnabled public String UIName { get; private set; }
        @AuraEnabled public String UrlLink { get; set; }
        @AuraEnabled public Boolean IsFile { get; set; }
        @AuraEnabled public Boolean RedirectToDetails { get; set; }

        public TilesInfoWrapper(String tileId, String tileName, String tileUIName, String urlLink, Boolean isFile, Boolean redirectToDetails) {
            this.Id = tileId;
            this.Name = tileName;
            this.UIName = tileUIName;
            this.UrlLink = urlLink;
            this.IsFile = isFile;
            this.IsFile = isFile;
            this.RedirectToDetails = redirectToDetails;
        }
    }
}