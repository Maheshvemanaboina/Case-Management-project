/**
 * Created by KJM on 20/05/2019.
 */

public with sharing class TileListService {
    public static String getTileChildDisplayOption(String displayOption) {
        return String.isBlank(displayOption) ? CommunityUtility.getCurrentCommunityOptions().Default_child_tiles_display_option__c : displayOption;
    }

    public static TileListController.TilesInfoWrapper getTileInfoWrapper(String tileName) {
        Tile__c tl = TileUtility.getTileByName(tileName);

        if (tl == null) {
            return new TileListController.TilesInfoWrapper(null, null, null,  '', false, null);
        }

        TileListController.TilesInfoWrapper tlInfoWrap = new TileListController.TilesInfoWrapper(tl.Id, tl.Name, tl.UI_Name__c, '', false, tl.Redirect_To_Details__c);

        if (tlInfoWrap.RedirectToDetails) {
            tlInfoWrap.UrlLink = CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_TILE_LINK + tl.Id;
        } else if (!String.isBlank(tl.Article_Url_Name__c)) {
            tlInfoWrap.UrlLink = CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_ARTICLE_LINK + tl.Article_Url_Name__c;
        } else if (!String.isBlank(tl.File_Public_Link__c)) {
            tlInfoWrap.UrlLink = tl.File_Public_Link__c;
            tlInfoWrap.IsFile = true;
        } else if (!String.isBlank(tl.Confidential_Content__c)) {
            tlInfoWrap.UrlLink = CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_OBJECT_LINK + tl.Confidential_Content__c;
        }

        return tlInfoWrap;
    }

    public static List<TileListItemWrapper> getTileWrapperList(List<TileUtility.TileStructureWrapper> tiles) {
        Map<Id, ContentVersion> tilesImage = TileUtility.getTilesImageMap(tiles);

        List<TileListItemWrapper> tilesWrap = new List<TileListItemWrapper>();

        for (TileUtility.TileStructureWrapper tlWrap : tiles) {
            Tile__c tl = tlWrap.ParentTile;

            String imageVersionId = '';
            String imageContentId = '';

            if (tilesImage != null && !tilesImage.isEmpty() && tilesImage.containsKey(tl.Id)) {
                imageVersionId = tilesImage.get(tl.Id).Id;
                imageContentId = tilesImage.get(tl.Id).ContentBodyId;
            }

            tilesWrap.add(new TileListItemWrapper(
                    tl.Id, tl.Name, tl.UI_Name__c, tl.UI_Description__c, imageVersionId, imageContentId
            ));
        }

        return tilesWrap;
    }

    public static List<TreeItemElement> getTilesListList(List<TileUtility.TileStructureWrapper> tiles) {
        List<TreeItemElement> treeItemElements = new List<TreeItemElement>();

        for (TileUtility.TileStructureWrapper tlWrap : tiles) {
            Tile__c tl = tlWrap.ParentTile;

            treeItemElements.add(
                    new TreeItemElement(
                            tl.UI_Name__c, tl.Name, null, false, null, tl.UI_Description__c
                    )
            );
        }

        return treeItemElements;
    }

    public static List<TreeItemElement> getTilesNestedList(List<TileUtility.TileStructureWrapper> tiles) {
        List<TreeItemElement> treeItemElements = new List<TreeItemElement>();

        for (TileUtility.TileStructureWrapper tlWrap : tiles) {
            List<TreeItemElement> treeItemChildElements = new List<TreeItemElement>();
            for (Tile__c ctl : tlWrap.ChildTiles) {
                treeItemChildElements.add(
                        new TreeItemElement(
                                ctl.UI_Name__c, ctl.Name, null, false, null, ctl.UI_Description__c
                        )
                );
            }

            treeItemElements.add(
                    new TreeItemElement(
                            tlWrap.ParentTile.UI_Name__c,  tlWrap.ParentTile.Name, treeItemChildElements, false, null, tlWrap.ParentTile.UI_Description__c
                    )
            );
        }

        return treeItemElements;
    }

    public static List<TileUtility.TileStructureWrapper> sortTileStructure(List<TileUtility.TileStructureWrapper> tilesToSort, Tile__c currentTile) {
        List<TileUtility.TileStructureWrapper> sortedParentTiles = sortTileStructureWrapperParents(tilesToSort, currentTile);

        for (TileUtility.TileStructureWrapper tileStructWrapper : sortedParentTiles) {
            if (tileStructWrapper.ParentTile.Child_Order_Option__c == null || tileStructWrapper.ParentTile.Child_Order_Option__c == Constants.TILE_CHILD_ORDER_OPTION_BY_NAME) {
                continue;
            }

            tileStructWrapper.ChildTiles = sortTilesByOrderNumber(tileStructWrapper.ChildTiles);
        }

        return sortedParentTiles;
    }

    private static List<TileUtility.TileStructureWrapper> sortTileStructureWrapperParents(List<TileUtility.TileStructureWrapper> tilesToSort, Tile__c currentTile) {
        if (currentTile.Child_Order_Option__c == null || currentTile.Child_Order_Option__c == Constants.TILE_CHILD_ORDER_OPTION_BY_NAME) {
            return tilesToSort;
        }

        List<TileUtility.TileStructureWrapper> sortedTiles = new List<TileUtility.TileStructureWrapper>();

        Map<Decimal, List<TileUtility.TileStructureWrapper>> tilesOrderMap = new Map<Decimal, List<TileUtility.TileStructureWrapper>>();
        for (TileUtility.TileStructureWrapper tlsWrapp : tilesToSort) {
            tlsWrapp.ParentTile.Order_Number__c = tlsWrapp.ParentTile.Order_Number__c == null ? 100000 : tlsWrapp.ParentTile.Order_Number__c;

            if (!tilesOrderMap.containsKey(tlsWrapp.ParentTile.Order_Number__c)) {
                tilesOrderMap.put(tlsWrapp.ParentTile.Order_Number__c, new List<TileUtility.TileStructureWrapper>());
            }

            tilesOrderMap.get(tlsWrapp.ParentTile.Order_Number__c).add(tlsWrapp);
        }

        List<Decimal> keySetSorted = new List<Decimal>();
        keySetSorted.addAll(tilesOrderMap.keySet());
        keySetSorted.sort();

        for (Decimal integ : keySetSorted) {
            sortedTiles.addAll(tilesOrderMap.get(integ));
        }

        return sortedTiles;
    }

    private static List<Tile__c> sortTilesByOrderNumber(List<Tile__c> tilesToSort) {
        List<Tile__c> sortedTiles = new List<Tile__c>();

        Map<Decimal, List<Tile__c>> tilesOrderMap = new Map<Decimal, List<Tile__c>>();
        for (Tile__c til : tilesToSort) {
            til.Order_Number__c = til.Order_Number__c == null ? 100000 : til.Order_Number__c;

            if (!tilesOrderMap.containsKey(til.Order_Number__c)) {
                tilesOrderMap.put(til.Order_Number__c, new List<Tile__c>());
            }

            tilesOrderMap.get(til.Order_Number__c).add(til);
        }

        List<Decimal> keySetSorted = new List<Decimal>();
        keySetSorted.addAll(tilesOrderMap.keySet());
        keySetSorted.sort();

        for (Decimal integ : keySetSorted) {
            sortedTiles.addAll(tilesOrderMap.get(integ));
        }

        return sortedTiles;
    }


    public class TileListItemWrapper {
        @AuraEnabled public String Id { get; private set; }
        @AuraEnabled public String TlName { get; private set; }
        @AuraEnabled public String UIName { get; private set; }
        @AuraEnabled public String UIDescription { get; private set; }
        @AuraEnabled public String ImageVersionId { get; private set; }
        @AuraEnabled public String ImageContentId { get; private set; }

        public TileListItemWrapper(String id, String tlName, String uIName, String uIDescription, String imageVersionId, String imageContentId) {
            this.Id = id;
            this.TlName = tlName;
            this.UIName = uIName;
            this.UIDescription = uIDescription;
            this.ImageVersionId = imageVersionId;
            this.ImageContentId = imageContentId;
        }
    }


}