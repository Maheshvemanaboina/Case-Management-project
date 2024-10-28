/**
 * Created by KJM on 14/08/2019.
 */

public with sharing class TilesSearchController {

    @AuraEnabled
    public static CustomSearchResultHandler searchForObjs(String searchText, String tileStructure) {
        List<List<SObject>> soslSearchResult = [FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Title, UrlName WHERE Language = 'en_US'), Confidential_Content__c(Name)];

        Set<String> knowledgeUrlNamesFilteredTiles = new Set<String>();
        Set<String> confContentIdsFilteredTiles = new Set<String>();
        Set<Tile__c> fileFilteredTiles = new Set<Tile__c>();
        Map<String, List<Id>> detailsFileFilteredTiles = new Map<String, List<Id>>();

        Set<Tile__c> detailsFileFilteredTilesToGetContent = new Set<Tile__c>();
        List<Tile__c> allTilesFromRoot = TileUtility.getAllEndTilesTreeFromRoot(tileStructure);
        for (Tile__c tl : allTilesFromRoot) {
            if (tl.Redirect_To_Details__c) {
                detailsFileFilteredTilesToGetContent.add(tl);
            }
        }

        Map<String, List<Id>> contentFilesFromTiles = getContentFilesMap(detailsFileFilteredTilesToGetContent);
        for (String contTitle : contentFilesFromTiles.keySet()) {
            if (contTitle.containsIgnoreCase(searchText)) {
                detailsFileFilteredTiles.put(contTitle, contentFilesFromTiles.get(contTitle));
            }
        }

        for (Tile__c tl : TileUtility.getAllEndTilesTreeFromRoot(tileStructure)) {
            if (!String.isBlank(tl.Article_Url_Name__c)) {
                knowledgeUrlNamesFilteredTiles.add(tl.Article_Url_Name__c);
            } else if (!String.isBlank(tl.Confidential_Content__c)) {
                confContentIdsFilteredTiles.add(tl.Confidential_Content__c);
            } else if (!String.isBlank(tl.File_Public_Link__c) && tl.UI_Name__c.containsIgnoreCase(searchText)) {
                fileFilteredTiles.add(tl);
            }
        }

        if (knowledgeUrlNamesFilteredTiles.isEmpty() &&
            confContentIdsFilteredTiles.isEmpty() &&
            fileFilteredTiles.isEmpty() &&
            detailsFileFilteredTiles.isEmpty()) {
            return null;
        }

        CustomSearchResultHandler resultList = new CustomSearchResultHandler();

        resultList.ResultList = new List<CustomSearchResultItemHandler>();
        resultList.ResultList.addAll(getKnowledgeList(knowledgeUrlNamesFilteredTiles, (List<Knowledge__kav>)soslSearchResult.get(0)));
        resultList.ResultList.addAll(getConfidentialContentList(confContentIdsFilteredTiles, (List<Confidential_Content__c>)soslSearchResult.get(1)));
        resultList.ResultList.addAll(getFileList(fileFilteredTiles));
        resultList.ResultList.addAll(getDetailsFileList(detailsFileFilteredTiles));

        return resultList;
    }

    private static  Map<String, List<Id>>  getContentFilesMap(Set<Tile__c> tilesToGetContent) {
        List<Tile__c> tilesWithContentFiles = [
                SELECT Id,
                    (SELECT Id, ContentDocument.Title, ContentDocument.LatestPublishedVersion.ContentDocumentId FROM ContentDocumentLinks)
                FROM Tile__c
                WHERE Id IN :tilesToGetContent
        ];

        Map<String, List<Id>> contentMapped = new Map<String, List<Id>>();
        for (Tile__c tl : tilesWithContentFiles) {
            for (ContentDocumentLink cont : tl.ContentDocumentLinks) {
                if (!contentMapped.containsKey(cont.ContentDocument.Title)) {
                    contentMapped.put(cont.ContentDocument.Title, new List<Id>());
                }
                contentMapped.get(cont.ContentDocument.Title).add(cont.ContentDocument.LatestPublishedVersion.ContentDocumentId);
            }
        }

        return contentMapped;
    }

    private static List<CustomSearchResultItemHandler> getDetailsFileList(Map<String, List<Id>> filteredContent) {
        List<CustomSearchResultItemHandler> fileList = new List<CustomSearchResultItemHandler>();

        for (String contentTitle : filteredContent.keySet()) {
            for (Id contId : filteredContent.get(contentTitle)) {
                fileList.add(new CustomSearchResultItemHandler(contentTitle, Constants.SEARCH_OBJECT_TYPE_FILE, CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_CONTENTDOCUMENT_LINK + contId, false));
            }
        }

        return fileList;
    }

    private static List<CustomSearchResultItemHandler> getFileList(Set<Tile__c> fileFilteredTiles) {
        List<CustomSearchResultItemHandler> fileList = new List<CustomSearchResultItemHandler>();

        for (Tile__c tl : fileFilteredTiles) {
            fileList.add(new CustomSearchResultItemHandler(tl.UI_Name__c, Constants.SEARCH_OBJECT_TYPE_FILE, tl.File_Public_Link__c, true));
        }

        return fileList;
    }

    private static List<CustomSearchResultItemHandler> getKnowledgeList(Set<String> knowledgeUrlNamesFilteredTiles, List<Knowledge__kav> soslKnowls) {
        List<CustomSearchResultItemHandler> knowledgesList = new List<CustomSearchResultItemHandler>();

        for (Knowledge__kav knowl : soslKnowls) {
            if (knowledgeUrlNamesFilteredTiles.contains(knowl.UrlName)) {
                knowledgesList.add(new CustomSearchResultItemHandler(knowl.Title, Constants.SEARCH_OBJECT_TYPE_ARTICLE, CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_ARTICLE_LINK + knowl.UrlName, false));
            }
        }

        return knowledgesList;
    }

    private static List<CustomSearchResultItemHandler> getConfidentialContentList(Set<String> confContentIdsFilteredTiles, List<Confidential_Content__c> soslConfCont) {
        List<CustomSearchResultItemHandler> confidentialContentList = new List<CustomSearchResultItemHandler>();

        for (Confidential_Content__c konfCont : soslConfCont) {
            if (confContentIdsFilteredTiles.contains(konfCont.Id)) {
                confidentialContentList.add(new CustomSearchResultItemHandler(konfCont.Name, Constants.SEARCH_OBJECT_TYPE_CONFIDENTIAL_CONTENT, CommunityUtility.getCurrentCommunityUrl() + Constants.COMMUNITY_OBJECT_LINK + konfCont.Id, false));
            }
        }

        return confidentialContentList;
    }

    public class CustomSearchResultHandler {
        @AuraEnabled public List<CustomSearchResultItemHandler> ResultList { get; set; }

        public CustomSearchResultHandler(){}
    }

    public class CustomSearchResultItemHandler {
        @AuraEnabled public String ObjName { get; private set; }
        @AuraEnabled public String ObjType { get; private set; }
        @AuraEnabled public String RedirectUrl { get; private set; }
        @AuraEnabled public Boolean IsFile { get; private set; }

        public CustomSearchResultItemHandler(String objName, String objType, String redirectUrl, Boolean isFile) {
            this.ObjName = objName;
            this.ObjType = objType;
            this.RedirectUrl = redirectUrl;
            this.IsFile = isFile;
        }
    }

}