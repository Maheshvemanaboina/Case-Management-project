/*       
@Name           - CommunityBreadCrumbsController
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 23-10-2020

@Description    - Controller for lightning component "CommunitiesBreadCrumbs"

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 23-10-2020    | Created Class
*/
public without sharing class CommunityBreadCrumbsController {
    
    public final static String USER_TRAVERSAL_DELIMITER = ' | ';
    public final static String BREADCRUMB_RECORD_TYPE = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('BreadCrumb').getRecordTypeId();

    @AuraEnabled
    public static List<BreadCrumbWrapper> getBreadCrumbs(Id recordId, String designAttName, String communityName){
        
        Tile__c currentTile = getTilesInfo(designAttName, communityName);
        if(String.isNotBlank(recordId)){

            updateUserTraversalInfoForCurrentTile(currentTile, recordId);
        }

        return generateBreadCrumbsWrapper(currentTile);
    }

    private static List<BreadCrumbWrapper> generateBreadCrumbsWrapper(Tile__c currentTile){

        String tileFiveInfo     = getUINameRecordId(currentTile.User_traversal_Info__c, currentTile.UI_Name__c, UserInfo.getUserId());
        String tileFourInfo     = getUINameRecordId(currentTile.Parent_Tile__r.User_traversal_Info__c, currentTile.Parent_Tile__r.UI_Name__c, UserInfo.getUserId());
        String tileThreeInfo    = getUINameRecordId(currentTile.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c, currentTile.Parent_Tile__r.Parent_Tile__r.UI_Name__c, UserInfo.getUserId());
        String tileTwoInfo      = getUINameRecordId(currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c, currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.UI_Name__c, UserInfo.getUserId());
        String tileOneInfo      = getUINameRecordId(currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c, currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.UI_Name__c, UserInfo.getUserId());

        String tileFiveNavType  = currentTile.Navigation_Page_Type__c;
        String tileFourNavType  = currentTile.Parent_Tile__r.Navigation_Page_Type__c;
        String tileThreeNavType = currentTile.Parent_Tile__r.Parent_Tile__r.Navigation_Page_Type__c;
        String tileTwoNavType   = currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Navigation_Page_Type__c;
        String tileOneNavType   = currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Navigation_Page_Type__c;

        String tileFiveObjOrPage  = currentTile.Object_Api_Name_Page_Api_Name__c;
        String tileFourObjOrPage  = currentTile.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c;
        String tileThreeObjOrPage = currentTile.Parent_Tile__r.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c;
        String tileTwoObjOrPage   = currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c;
        String tileOneObjOrPage   = currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c;

        List<BreadCrumbWrapper> breadCrumbWrapperList = new List<BreadCrumbWrapper>();

        if(String.isNotBlank(tileFiveInfo)) { breadCrumbWrapperList.add(new BreadCrumbWrapper('5', tileFiveInfo.substringAfter(USER_TRAVERSAL_DELIMITER), tileFiveInfo.substringBefore(USER_TRAVERSAL_DELIMITER), tileFiveNavType, tileFiveObjOrPage)); }
        if(String.isNotBlank(tileFourInfo)) { breadCrumbWrapperList.add(new BreadCrumbWrapper('4', tileFourInfo.substringAfter(USER_TRAVERSAL_DELIMITER), tileFourInfo.substringBefore(USER_TRAVERSAL_DELIMITER), tileFourNavType, tileFourObjOrPage)); }
        if(String.isNotBlank(tileThreeInfo)){ breadCrumbWrapperList.add(new BreadCrumbWrapper('3', tileThreeInfo.substringAfter(USER_TRAVERSAL_DELIMITER), tileThreeInfo.substringBefore(USER_TRAVERSAL_DELIMITER), tileThreeNavType, tileThreeObjOrPage)); }
        if(String.isNotBlank(tileTwoInfo))  { breadCrumbWrapperList.add(new BreadCrumbWrapper('2', tileTwoInfo.substringAfter(USER_TRAVERSAL_DELIMITER), tileTwoInfo.substringBefore(USER_TRAVERSAL_DELIMITER), tileTwoNavType, tileTwoObjOrPage)); }
        if(String.isNotBlank(tileOneInfo))  { breadCrumbWrapperList.add(new BreadCrumbWrapper('1', tileOneInfo.substringAfter(USER_TRAVERSAL_DELIMITER), tileOneInfo.substringBefore(USER_TRAVERSAL_DELIMITER), tileOneNavType, tileOneObjOrPage)); }

        breadCrumbWrapperList.sort();

        return breadCrumbWrapperList;
    }

    private static String getUINameRecordId(String userTraversalInfo, String UIName, String currentUserId){

        if(!String.isBlank(UIName)){
            if(String.isBlank(userTraversalInfo)){

                return UIName + USER_TRAVERSAL_DELIMITER + '';
            }
            else if(!String.isBlank(userTraversalInfo)){
    
                String recordId = userTraversalInfo.substringBetween(currentUserId + USER_TRAVERSAL_DELIMITER, USER_TRAVERSAL_DELIMITER);
                UIName = userTraversalInfo.substringBetween(currentUserId + USER_TRAVERSAL_DELIMITER + recordId + USER_TRAVERSAL_DELIMITER , '\n');
                if(UIName == null){
                    UIName = userTraversalInfo.substringAfter(currentUserId + USER_TRAVERSAL_DELIMITER + recordId + USER_TRAVERSAL_DELIMITER);
                }
                return UIName + USER_TRAVERSAL_DELIMITER + recordId;
            }
        }

        return '';
    }

    private static void updateUserTraversalInfoForCurrentTile(Tile__c currentTile, Id recordId){

        if(currentTile.Has_RecordId__c){

            //Add currentURL if user traversal info is blank
            if(String.isBlank(currentTile.User_traversal_Info__c))  {
                 
                currentTile.User_traversal_Info__c = getUserRelativeInfoForNewUser(recordId); 
            }

            //Add a next line character & add the usertraversal info with the existing info
            else if(!String.isBlank(currentTile.User_traversal_Info__c) && !currentTile.User_traversal_Info__c.contains(UserInfo.getUserId())) { 

                currentTile.User_traversal_Info__c = currentTile.User_traversal_Info__c + '\n' + getUserRelativeInfoForNewUser(recordId);
            }
            //Update already existing userURL by removing the old one and replacing it with the new one
            else if(!String.isBlank(currentTile.User_traversal_Info__c) && currentTile.User_traversal_Info__c.contains(UserInfo.getUserId())){

                String existingRecordId = currentTile.User_traversal_Info__c.substringBetween(UserInfo.getUserId() + USER_TRAVERSAL_DELIMITER, USER_TRAVERSAL_DELIMITER);
                if(!existingRecordId.equals(recordId)){

                    String oldName = currentTile.User_traversal_Info__c.substringBetween(UserInfo.getUserId() + USER_TRAVERSAL_DELIMITER + existingRecordId + USER_TRAVERSAL_DELIMITER, '\n');
                    if(oldName == null){
                        oldName = currentTile.User_traversal_Info__c.substringAfter(UserInfo.getUserId() + USER_TRAVERSAL_DELIMITER + existingRecordId + USER_TRAVERSAL_DELIMITER);
                    }
                    String existingCurrentUserOldRelativeInfo =  UserInfo.getUserId() + USER_TRAVERSAL_DELIMITER + existingRecordId + USER_TRAVERSAL_DELIMITER + oldName;

                    String newName = getUserRelativeInfoForNewUser(recordId).substringAfterLast(USER_TRAVERSAL_DELIMITER);
                    String existingCurrentUserNewRelativeInfo = UserInfo.getUserId() + USER_TRAVERSAL_DELIMITER + recordId + USER_TRAVERSAL_DELIMITER + newName;

                    currentTile.User_traversal_Info__c = currentTile.User_traversal_Info__c.replace(existingCurrentUserOldRelativeInfo, existingCurrentUserNewRelativeInfo);
                }
                
            }
            update currentTile;
        }
    }

    private static String getUserRelativeInfoForNewUser(Id recordId){
        
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        String query = 'SELECT Id,Name FROM ' + sObjName + ' WHERE Id =: recordId';
        sObject obj = Database.query(query);
        return UserInfo.getUserId() + USER_TRAVERSAL_DELIMITER + recordId + USER_TRAVERSAL_DELIMITER + obj.get('Name'); 
    }

    private static Tile__c getTilesInfo(String designAttributeName, String communityName){

        String tileQuery = 'SELECT UI_Name__c, Parent_Tile__c, User_traversal_Info__c, Design_attribute_name__c, Has_RecordId__c, Navigation_Page_Type__c, Object_Api_Name_Page_Api_Name__c,';
        tileQuery += ' Parent_Tile__r.UI_Name__c, Parent_Tile__r.User_traversal_Info__c, Parent_Tile__r.Design_attribute_name__c, Parent_Tile__r.Has_RecordId__c, Parent_Tile__r.Navigation_Page_Type__c, Parent_Tile__r.Object_Api_Name_Page_Api_Name__c,';
        tileQuery += ' Parent_Tile__r.Parent_Tile__r.UI_Name__c, Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c, Parent_Tile__r.Parent_Tile__r.Design_attribute_name__c, Parent_Tile__r.Parent_Tile__r.Has_RecordId__c, Parent_Tile__r.Parent_Tile__r.Navigation_Page_Type__c, Parent_Tile__r.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c,';
        tileQuery += ' Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.UI_Name__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Design_attribute_name__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Has_RecordId__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Navigation_Page_Type__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c,';
        tileQuery += ' Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.UI_Name__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Design_attribute_name__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Has_RecordId__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Navigation_Page_Type__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c,';
        tileQuery += ' Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.UI_Name__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Design_attribute_name__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Has_RecordId__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Navigation_Page_Type__c, Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Object_Api_Name_Page_Api_Name__c,';
        tileQuery += ' Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__c';
        tileQuery += ' FROM Tile__c';
        tileQuery += ' WHERE Community_Name__c INCLUDES (:communityName)';
        tileQuery += ' AND Design_attribute_name__c =: designAttributeName';
        tileQuery += ' AND RecordTypeId =: BREADCRUMB_RECORD_TYPE';

        return (Tile__c)Database.query(tileQuery);
    }

    public class BreadCrumbWrapper implements Comparable{

        @AuraEnabled public String sortingOrder;
        @AuraEnabled public String pageInfo;
        @AuraEnabled public String UIName;

        public BreadCrumbWrapper(String sortingOrder, String recordId, String UIName, String navigationPageType, String objectAPIorPageName){

            this.sortingOrder   = sortingOrder;
            this.pageInfo       = navigationPageType + '-' + objectAPIorPageName + '-' + recordId;
            this.UIName         = UIName;

        }

        public Integer compareTo(Object ObjToCompare) {
            return sortingOrder.CompareTo(((BreadCrumbWrapper)ObjToCompare).sortingOrder);
        }
    }

    /*
    private static String getBreadCrumbName(String userTraversalInfo, String relativeURL, String UIName, String currentUserId){
        if(String.isNotBlank(relativeURL)){

            if(!relativeURL.contains('{recordId}')){

                return UIName + USER_TRAVERSAL_DELIMITER + relativeURL;
            }else if (relativeURL.contains('{recordId}') && String.isNotBlank(userTraversalInfo)) {
                
                String recordId = userTraversalInfo.substringBetween(currentUserId + USER_TRAVERSAL_DELIMITER, USER_TRAVERSAL_DELIMITER);
                UIName = userTraversalInfo.substringBetween(currentUserId + USER_TRAVERSAL_DELIMITER + recordId + USER_TRAVERSAL_DELIMITER , '\n');
                if(UIName == null){
                    UIName = userTraversalInfo.substringAfter(currentUserId + USER_TRAVERSAL_DELIMITER + recordId + USER_TRAVERSAL_DELIMITER);
                }
                String relURL = relativeURL.replace('{recordId}', recordId);
                return UIName + USER_TRAVERSAL_DELIMITER + relURL;
            }
        }

        return '';
    }

    @AuraEnabled
    public static String getBreadCrumbData(Id recordId,String communityName,String communityURL){

        Id currentUserId = UserInfo.getUserId();
        Tile__c homeTile = [SELECT Relative_URL__c FROM Tile__c WHERE Community_Name__c INCLUDES (:communityName) AND Name = 'FCI Distributor Community BreadCrumbs'];
        if(communityURL.equals(homeTile.Relative_URL__c)){
            removeAllCurrentToSetCurrentAsHome(homeTile, communityName, UserInfo.getUserId());
            return '';
        }

        String relativeURL = '';
        if(recordId != null && communityURL.contains(recordId)){
            relativeURL = communityURL.replace(recordId, '{recordId}');
            List<Tile__c> currentTile = [SELECT Id,User_traversal_Info__c FROM Tile__c WHERE Relative_URL__c =: relativeURL AND Community_Name__c INCLUDES (:communityName)];
            if(!currentTile.isEmpty()){

                if(String.isBlank(currentTile[0].User_traversal_Info__c)){ currentTile[0].User_traversal_Info__c = currentUserId + '-' + '(Current)'; }
                else if(String.isNotBlank(currentTile[0].User_traversal_Info__c)){

                    if(!currentTile[0].User_traversal_Info__c.contains(currentUserId) && !currentTile[0].User_traversal_Info__c.contains(currentUserId + '-' + '(Current)')){ currentTile[0].User_traversal_Info__c = currentTile[0].User_traversal_Info__c + '\n' + (currentUserId + '-' + '(Current)');}
                    if( currentTile[0].User_traversal_Info__c.contains(currentUserId) && !currentTile[0].User_traversal_Info__c.contains(currentUserId + '-' + '(Current)')){ currentTile[0].User_traversal_Info__c = currentTile[0].User_traversal_Info__c.replace(currentUserId, currentUserId + '-' + '(Current)');}
                } 
            }else if(currentTile.isEmpty()){
                Tile__c immediateParentTile;
                for(Tile__c eachParentTile : [SELECT Id,User_traversal_Info__c FROM Tile__c WHERE Community_Name__c INCLUDES (:communityName) AND RecordTypeId =: BREADCRUMB_RECORD_TYPE order by lastmodifiedDate desc]){

                    if(eachParentTile.User_traversal_Info__c.contains(currentUserId + '-' + '(Current)')){
                        immediateParentTile = eachParentTile;
                    }
                    break;
                }
                String commURLSubstring = communityURL.substringAfter('s/');
                String tileName = commURLSubstring.contains('/') ? commURLSubstring.substringBefore('/') : commURLSubstring;
            
                Tile__c newChildTile = new Tile__c(Name = tileName,
                                            Community_Name__c = communityName,
                                            User_traversal_Info__c = currentUserId + '-' + '(Current)',
                                            RecordTypeId = BREADCRUMB_RECORD_TYPE,
                                            Relative_URL__c = relativeURL,
                                            Parent_Tile__c = immediateParentTile.Id);
                
            }
        }

        Tile__c currentExistingTile;
        for(Tile__c eachTile :  [SELECT Id,User_traversal_Info__c FROM Tile__c WHERE Community_Name__c INCLUDES (:communityName) AND Relative_URL__c =: communityURL order by LastmodifiedDate]){
            if(eachTile.User_traversal_Info__c.contains(UserInfo.getUserId())){
                currentExistingTile = eachTile;
            }
            break;
        }
        if(currentExistingTile == null){

            //homeTile1 logic needs to change, needs to use previous (Current) Tile
            Tile__c homeTile1 = [SELECT Id FROM Tile__c WHERE Name = 'FCI Distributor Community BreadCrumbs'];
            String commURLSubstring = communityURL.substringAfter('s/');
            String tileName = commURLSubstring.contains('/') ? commURLSubstring.substringBefore('/') : commURLSubstring;
            
            Tile__c newChildTile = new Tile__c(Name = tileName,
                                            Community_Name__c = communityName,
                                            User_traversal_Info__c = UserInfo.getUserId() + '-' + '(Current)',
                                            RecordTypeId = BREADCRUMB_RECORD_TYPE,
                                            Relative_URL__c = communityURL,
                                            Parent_Tile__c = homeTile1.Id);
            insert newChildTile;
            redesignCurrentPathToRemoveCurrent(communityName, communityURL, UserInfo.getUserId(), newChildTile.Id);
            return 'HOME -> ' + newChildTile.Relative_URL__c;
        }
        else if(currentExistingTile != null){
            redesignCurrentPathToRemoveCurrent(communityName, communityURL, UserInfo.getUserId(), currentExistingTile.Id);
            redesignCurrentPathToAddCurrent(communityName, communityURL, UserInfo.getUserId(), currentExistingTile.Id);
        }
        Tile__c myperformanceTile = [SELECT Id,Relative_URL__c FROM Tile__c WHERE Id='a0y250000041ra6AAA'];
        myperformanceTile.Relative_URL__c = communityURL;
        update myperformanceTile;
        List<BreadCrumbWrapper> breadCrumbWrapList;
        List<String> tileRelations = new List<String>();
        Tile__c breadCrumbTile;
        String tileQuery = 'SELECT UI_Name__c,BreadCrumb_field_API_name__c,Community_Name__c,Relative_URL__c ';
        Integer i = 0;
        List<Tile__c> currentBreadCrumb = [SELECT Id,UI_Name__c,BreadCrumb_field_API_name__c,Parent_Tile__c,Community_Name__c,Relative_URL__c
                                            FROM Tile__c
                                            WHERE RecordTypeId =: Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('BreadCrumb').getRecordTypeId()
                                            AND Design_attribute_name__c =: designAttName
                                            AND Community_Name__c INCLUDES (:communityName) ];
        
        if(!currentBreadCrumb.isEmpty()){
            
            String TEMP_PARENT_TILE_API_NAME = PARENT_TILE_API_NAME;
            String TEMP_PARENT_TILE_RELATION_NAME = PARENT_TILE_RELATION_NAME;
            tileRelations.add(TEMP_PARENT_TILE_RELATION_NAME);
            
            while (i < depthOfBreadCrumbs && i <= 5) {

                tileQuery += ',' + TEMP_PARENT_TILE_RELATION_NAME + '.' + TILE_UI_NAME;
                tileQuery += ',' + TEMP_PARENT_TILE_RELATION_NAME + '.' + TILE_BREADCRUMB_API;
                tileQuery += ',' + TEMP_PARENT_TILE_RELATION_NAME + '.' + TILE_RELATIVE_URL;
                TEMP_PARENT_TILE_RELATION_NAME = TEMP_PARENT_TILE_RELATION_NAME + '.' + PARENT_TILE_RELATION_NAME;
                tileRelations.add(TEMP_PARENT_TILE_RELATION_NAME);
                i++;
            }

            tileQuery += ' FROM Tile__c ';
            tileQuery += ' WHERE RecordTypeId =: BREADCRUMB_RECORD_TYPE ';
            tileQuery += ' AND Design_attribute_name__c =: designAttName ';
            tileQuery += ' AND Community_Name__c INCLUDES (:communityName) ';
            breadCrumbTile = (Tile__c)Database.query(tileQuery);
            breadCrumbWrapList = generateBreadCrumbs(breadCrumbTile, tileRelations, depthOfBreadCrumbs);
        }else{
            return new BreadCrumbWrapper('', '', '');
        }*/
        //return new BreadCrumbWrapper('', '', '');
    

    /*private static void removeAllCurrentToSetCurrentAsHome(Tile__c homeTile, String communityName,Id currentUserId){

        List<Tile__c> allTilesToUpdate = new List<Tile__c>();
        List<Tile__c> allTiles = [SELECT Id,User_traversal_Info__c FROM Tile__c WHERE Community_Name__c INCLUDES (:communityName) AND RecordTypeId =: BREADCRUMB_RECORD_TYPE AND Id !=: homeTile.Id];
        for(Tile__c eachTl : allTiles){
            if(eachTl.User_traversal_Info__c.contains(currentUserId + '-' + '(Current)')){
                eachTl.User_traversal_Info__c = eachTl.User_traversal_Info__c.replace(currentUserId + '-' + '(Current)',currentUserId);
                allTilesToUpdate.add(eachTl);
            }
        }
        homeTile.User_traversal_Info__c = String.isBlank(homeTile.User_traversal_Info__c) ? currentUserId + '-' + '(Current)' : homeTile.User_traversal_Info__c + '\n' + (currentUserId + '-' + '(Current)');
        allTilesToUpdate.add(homeTile);
        if(!allTilesToUpdate.isEmpty()){
            update allTilesToUpdate;
        }
    }

    @future
    private static void redesignCurrentPathToAddCurrent(String communityName,String communityURL, Id userId, Id currentTileId){

        List<Tile__c> tilesToUpdateCurrent = new List<Tile__c>();
        Tile__c currentTile = [SELECT Id,User_traversal_Info__c,
                            Parent_Tile__r.User_traversal_Info__c,
                            Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c,
                            Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c,
                            Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c,
                            Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c
                            FROM Tile__c WHERE Id =: currentTileId];

        String tileOneInfo      = String.isNotBlank(currentTile.User_traversal_Info__c) && currentTile.User_traversal_Info__c.contains(userId) && !currentTile.User_traversal_Info__c.contains('(Current)') ? currentTile.User_traversal_Info__c.replace(userId, userId + '-' + '(Current)') : currentTile.User_traversal_Info__c;
        String tileTwoInfo      = String.isNotBlank(currentTile.Parent_Tile__r.User_traversal_Info__c) && currentTile.Parent_Tile__r.User_traversal_Info__c.contains(userId) && !currentTile.Parent_Tile__r.User_traversal_Info__c.contains('(Current)') ? currentTile.Parent_Tile__r.User_traversal_Info__c.replace(userId, userId + '-' + '(Current)') : currentTile.Parent_Tile__r.User_traversal_Info__c;
        String tileThreeInfo    = String.isNotBlank(currentTile.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c) && currentTile.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.contains(userId) && !currentTile.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.contains('(Current)') ? currentTile.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.replace(userId, userId + '-' + '(Current)') : currentTile.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c;
        String tileFourInfo     = String.isNotBlank(currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c) && currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.contains(userId) && !currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.contains('(Current)') ? currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.replace(userId, userId + '-' + '(Current)') : currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c;
        String tileFiveInfo     = String.isNotBlank(currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c) && currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.contains(userId) && !currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.contains('(Current)') ? currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c.replace(userId, userId + '-' + '(Current)') : currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.User_traversal_Info__c;

        currentTile.User_traversal_Info__c = tileOneInfo;
        tilesToUpdateCurrent.add(currentTile);
        if(currentTile.Parent_Tile__c != null) { tilesToUpdateCurrent.add(new Tile__c(Id = currentTile.Parent_Tile__c, User_traversal_Info__c = tileTwoInfo)); }
        if(currentTile.Parent_Tile__r.Parent_Tile__c != null) { tilesToUpdateCurrent.add(new Tile__c(Id = currentTile.Parent_Tile__r.Parent_Tile__c, User_traversal_Info__c = tileTwoInfo)); }
        if(currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__c != null) { tilesToUpdateCurrent.add(new Tile__c(Id = currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__c, User_traversal_Info__c = tileTwoInfo)); }
        if(currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__c != null) { tilesToUpdateCurrent.add(new Tile__c(Id = currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__c, User_traversal_Info__c = tileTwoInfo)); }
        if(currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__c != null) { tilesToUpdateCurrent.add(new Tile__c(Id = currentTile.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__r.Parent_Tile__c, User_traversal_Info__c = tileTwoInfo)); }

        if(!tilesToUpdateCurrent.isEmpty()){
            update tilesToUpdateCurrent;
        }
    }

    @future
    private static void redesignCurrentPathToRemoveCurrent(String communityName,String communityURL, Id userId, Id currentTileId){

        List<Tile__c> tilesToUpdate = new List<Tile__c>();
        Tile__c currentTile = [SELECT Id,User_traversal_Info__c,Relative_URL__c FROM Tile__c WHERE Id =: currentTileId];
        
        //Tiles to remove (current)
        List<Tile__c> tilesToremoveCurrent = [SELECT Id,User_traversal_Info__c FROM Tile__c
                                        WHERE Community_Name__c INCLUDES (:communityName)
                                        AND Relative_URL__c !=: currentTile.Relative_URL__c];
        for(Tile__c eachTile : tilesToremoveCurrent){
            if(!String.isBlank(eachTile.User_traversal_Info__c) && eachTile.User_traversal_Info__c.contains(userId + '-' + '(Current)')){
                eachTile.User_traversal_Info__c = eachTile.User_traversal_Info__c.remove(userId + '-' + '(Current)');
                eachTile.User_traversal_Info__c = String.isBlank(eachTile.User_traversal_Info__c) ? userId : eachTile.User_traversal_Info__c + '\n' + userId;
                tilesToUpdate.add(eachTile);
            }
        }
        if(!tilesToUpdate.isEmpty()){
            update tilesToUpdate;
        }
    }*/

    /*private static List<BreadCrumbWrapper> generateBreadCrumbs(Tile__c breadCrumbTile, List<String> tileRelations,Integer depthOfBreadCrumbs){

        Integer TEMP_DEPTH = depthOfBreadCrumbs;
        String eachUIName;
        String eachRelativeURL;

        List<BreadCrumbWrapper> breadCrumbWrapperList = new List<BreadCrumbWrapper>();
        for(String eachRelation : tileRelations){
            if(eachRelation.contains('.')){

                SObject sObjectVal;
                List<String> lookupFieldRelation = eachRelation.split('\\.');
                for(Integer i = 0 ; i < lookupFieldRelation.size() - 1 ; i++){
                    sObjectVal = breadCrumbTile.getSObject(lookupFieldRelation[i]);
                    if(sObjectVal == null){
                        break;
                    }
                }
                if(sObjectVal != null){
                    eachUIName = String.isNotBlank(String.valueOf(sObjectVal.get(TILE_BREADCRUMB_API))) ? String.valueOf(sObjectVal.get(TILE_BREADCRUMB_API)) : String.valueOf(sObjectVal.get(TILE_UI_NAME));
                    eachRelativeURL = String.valueOf(sObjectVal.get(TILE_RELATIVE_URL));
                    breadCrumbWrapperList.add(new BreadCrumbWrapper(String.valueOf(TEMP_DEPTH), eachRelativeURL, eachUIName));

                    TEMP_DEPTH --;
                }
            }else{
                eachUIName = String.isNotBlank(String.valueOf(breadCrumbTile.get(TILE_BREADCRUMB_API))) ? String.valueOf(breadCrumbTile.get(TILE_BREADCRUMB_API)) : String.valueOf(breadCrumbTile.get(TILE_UI_NAME));
                eachRelativeURL = String.valueOf(breadCrumbTile.get(TILE_RELATIVE_URL));
                breadCrumbWrapperList.add(new BreadCrumbWrapper(String.valueOf(TEMP_DEPTH), eachRelativeURL, eachUIName));
                TEMP_DEPTH --;
            }

        }
        return breadCrumbWrapperList;
    }*/
    
}