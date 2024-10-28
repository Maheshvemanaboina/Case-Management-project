/*------------------------------------------------------------  
Author:       Sibananda Bhuyan
Description:  This is the controller used for Content Mananagement component

History
27-10-2020      Sibananda Bhuyan    Created Class
18-11-2020      Sibananda Bhuyan    Updated Class to add Library structure
15-06-2021      Sibananda Bhuyan    Moved code to helper class "ContentManagementHelper" and moved all article update methods to the helper class
03-12-2021      Mohammad rafi -> Modified
19-07-2022		Mahendra Kumar		Updated class to add Content owner update logic
28-07-2022		Mahendra Kumar		Added logic in this method (getBusinessSegmentDependency) to get business segment and subsegments of FCP_New_Business_Opportunity record type 
------------------------------------------------------------*/
public without sharing class ContentManagementController {
    
    public static String OPPORTUNITY_API_NAME                       = 'Opportunity';
    public static String TILE_API_NAME								= 'Tile__c';
    public static String OPPORTUNITY_FCI_NEW_BUSINESS_RECORDTYPE    = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Business').getRecordTypeId();
    public static String OPPORTUNITY_FCP_NEW_BUSINESS_RECORDTYPE    = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('FCP_New_Business_Opportunity').getRecordTypeId();
    //public static String SUB_SEGMENT_FIELD_API_NAME                 = 'Sub_Segment__c'; //Commented this line to not fetch Sub Segment picklist values from opportunity
    public static String SUB_SEGMENT_FIELD_API_NAME                 = 'Content_Sub_Segment__c'; //Added this field to fetch values of content sub segment field from Tile object
    public static Id TILE_GLOBAL_RECORD_TYPE_ID                     = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Global').getRecordTypeId();
    public static Id KNOWLEDGE_COMMUNITY_ARTICLE_RECORD_TYPE_ID     = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Community_Article').getRecordTypeId();
    public static String VALIDATION_MESSAGE                         = '{0}-{1}';
    
    public static Map<Id, TreeItemElement> tileTreeElementMap;
    public static Map<Integer, Map<Id, TreeItemElement>> depthTileTreeElementMap;
    public static Map<Id, Id> childParentIdMap;
    public static List<Id> tileswithNoChilds;
    public static Map<String,String> communityNameMap;
    
    public static Map<Id, TreeItemElement> libraryTreeElementMap;
    public static Map<Integer, Map<Id, TreeItemElement>> depthlibraryTreeElementMap;
    
    
    /* @Description
Method Name : checkKnowledgeUser( )

Once the ContentManagement tab is clicked, this method is called and authorizes if logged in user has required access to perform
knowledge operations or not.

*/
    @AuraEnabled
    public static Boolean checkKnowledgeUser(){
        
        Boolean hasApexClassAccess = UserUtility.checkUserAccessToApexClass('ContentManagementController', UserInfo.getProfileId());
        Boolean hasKnowledgeAccess = UserUtility.checkIfUserHasAllAccessToKnowledge(UserInfo.getUserId());
        
        return (hasApexClassAccess && hasKnowledgeAccess);
    }
    
    /* @Description
Method Name : initializeContentData( )

1. This method sets up the ContentManagementWrapper values.
2. It is wrapper which intializes the business segment, sub-segment, sales region values from Tile__c object
3. Each community has certain content types associated with it.
a. For ex: Distributor community has Recipes, products, Additional Info, Marketing Info content types
b. Customer community also has certain content types.
c. This wrapper also generates the community and content type map to send it back to aura component
4. This is called during after checkKnowledgeUser() method is called.
5. If the logged in user has required permission then initialize all the required info.

*/
    
    @AuraEnabled
    public static ContentManagementWrapper initializeContentData(){
        
        ContentManagementWrapper contentWrapper = new ContentManagementWrapper();
        
        for(Community_Setting__mdt eachCommSetting : [SELECT Id,Community_Name_on_Content_Creation__c,Content_type_Main_tile_Info__c 
                                                      FROM Community_Setting__mdt
                                                      WHERE Content_type_Main_tile_Info__c != null]){
                                                          
                                                          contentWrapper.names.add(eachCommSetting.Community_Name_on_Content_Creation__c);
                                                          setNameContentTypeMap(eachCommSetting, contentWrapper);
                                                      }
        
        return contentWrapper;
    }
    
    /* @Description
Method Name : getContentTree( String, String )

1. This method return the complete content tree based on the content type selected.
2. Each Content Tree is different based on the selected content type.
a. For ex: Recipes has a different content tree/content structure than "Products"
b. Content Structure of "Recipes" starts from "FCI Distributor Recipes Main Tile" tile object record.
3. Every new content will be stored under a place where it will be visible in community. This selection of place happens from
the content Tree

@PARAMS
1. NAME ( contentfirstTileName )    => TYPE ( String ) => DESCRIPTION ( The first tile name from where the content tree hierarchy begins )
2. NAME ( tileCommunityName )       => TYPE ( String ) => DESCRIPTION ( The tiles related to the community name should be fetched )
*/
    
    @AuraEnabled
    public static ContentTreeWrapper getContentTree(String contentfirstTileName, String tileCommunityName){
        
        System.debug(' contentfirstTileName -- '+contentfirstTileName);
        System.debug(' tileCommunityName -- '+tileCommunityName);
        /* Initialize variables */
        tileTreeElementMap = new Map<Id,TreeItemElement>(); // Stores the tileId, TreeItemElement
        childParentIdMap = new Map<Id,Id>(); // tileId, Tile's ParentId
        tileswithNoChilds = new List<Id>();// List<tileId>
        List<String> communityNames = new List<String>();
        
        /* Build Community names with the format having '' (single quotes) to be used in dynamic soql */
        for(String eachCommName : tileCommunityName.split(';')){
            communityNames.add('\''+ eachCommName + '\'');
        }
        /* Stores the tiledepth , <tileId, TreeItemElement>
This stores the current depth of the current tile along with it's tileId, TreeItemElement
*/
        depthTileTreeElementMap = new Map<Integer, Map<Id,TreeItemElement>>();
        
        //TemporaryTiles to use in While Loop, used to make sure all the child elements are fetched and stored
        List<Tile__c> tempContentTiles = new List<Tile__c>();
        
        //Fetches the Parent Tile : For Distributor it will be "FCI Distributor Recipe Main Tile", the tile from where the content hierarchy starts
        //List<Tile__c> parentTl = [SELECT Id,UI_Name__c, UI_Description__c, Parent_Tile__c FROM Tile__c WHERE Name =:contentfirstTileName AND Community_Name__c INCLUDES (:tileCommunityName)];
        List<Tile__c> parentTl = (List<Tile__c>) Database.query('SELECT Id,UI_Name__c, UI_Description__c, Parent_Tile__c FROM Tile__c WHERE Name =:contentfirstTileName AND Community_Name__c INCLUDES (' + String.join(communityNames, ',') + ')');
        
        //This is the first/top most tile, hence depth is given as 1
        if(!parentTl.isEmpty()){
            
            Tile__c parentTile = parentTl.get(0);
            tileTreeElementMap.put(parentTile.Id, new TreeItemElement(parentTile.UI_Name__c, parentTile.Id, null, false, null, null /*parentTile.UI_Description__c*/));
            depthTileTreeElementMap.put(1, new Map<Id,TreeItemElement>{parentTile.Id => new TreeItemElement(parentTile.UI_Name__c, parentTile.Id, null, false, null, null /*parentTile.UI_Description__c*/)});
            childParentIdMap.put(parentTile.Id, parentTile.Parent_Tile__c);
            tempContentTiles.add(parentTile);
        }
        
        Integer currentTileDepth = 1;
        while (!tempContentTiles.isEmpty()) {
            
            currentTileDepth = currentTileDepth + 1;
            
            /* The child query is specifically written to capture the tiles having no child. 
This will serve as a list to make sure these are valid tiles and content/articles 
can only added under these tiles & no where else */
            //Temporary tileTreeMap at current Depth
            Map<Id,TreeItemElement> tileTreeMapAtCurrentDepth = new Map<Id,TreeItemElement>();
            
            String temptilesQuery = 'SELECT Id,UI_Name__c, UI_Description__c, Parent_Tile__c,';
            temptilesQuery += '(SELECT Id FROM Child_Tiles__r WHERE Article_Name__c = null AND File_Public_Link__c = null) ';
            temptilesQuery += 'FROM Tile__c ';
            temptilesQuery += 'WHERE Parent_Tile__c IN: tempContentTiles ';
            temptilesQuery += 'AND Article_Name__c = null ';
            temptilesQuery += 'AND File_Public_Link__c = null ';
            temptilesQuery += 'AND Community_Name__c INCLUDES (' + String.join(communityNames, ',') + ') ';
            temptilesQuery += 'ORDER BY UI_Name__c';
            
            List<Tile__c> tempTiles = Database.query(temptilesQuery);
            
            for(Tile__c tl : tempTiles){
                
                TreeItemElement eachTreeElement = new TreeItemElement(tl.UI_Name__c, tl.Id, null, false, null, null /*tl.UI_Description__c*/);
                
                tileTreeElementMap.put(tl.Id, eachTreeElement);
                childParentIdMap.put(tl.Id, tl.Parent_Tile__c);
                tileTreeMapAtCurrentDepth.put(tl.Id, eachTreeElement);
                
                if(tl.Child_Tiles__r.isEmpty()){
                    tileswithNoChilds.add(tl.Id);
                }
            }
            
            depthTileTreeElementMap.put(currentTileDepth, tileTreeMapAtCurrentDepth);
            
            //Clears the tempContentTiles to store the queried temptiles and start loop again, untile temptiles is Empty and loop exits after that
            tempContentTiles.clear();
            tempContentTiles.addAll(tempTiles);
        }
        
        //Sort the depths of tile to ascending order
        List<Integer> sortingOrders = new List<Integer>(depthTileTreeElementMap.keySet());
        sortingOrders.sort();
        
        Map<Id,String> validContentMap = new Map<Id,String>();
        /*Run the loop in the descending order of tile depth from the sorted list above
to make sure the iteration starts from the lowest level/depth
*/
        for(Integer j = sortingOrders.size() - 1; j > 0; j--){
            
            for(Id tileId : depthTileTreeElementMap.get(j).keySet()){
                
                if(childParentIdMap.containsKey(tileId)){
                    
                    Id ParentId = childParentIdMap.get(tileId);
                    if(ParentId != null){
                        
                        //Get the ParentTree Element and add the child tree elements to the Parent TreeItemElement's "items"
                        TreeItemElement  parentTree = tileTreeElementMap.get(ParentId);
                        if( parentTree!=null && parentTree.items!=null){
                            parentTree.items.add(tileTreeElementMap.get(tileId));
                        }
                        
                        //Add data to valid content Map only for lowest depth (only in this place content can be added)
                        if(tileswithNoChilds.contains(tileId)){
                            validContentMap.put(tileId, getTileIdContentHierarchyName(tileId));
                        }
                        
                        //Remove the child Element from the map once it is added to the Parent TreeItemElement's "items"
                        tileTreeElementMap.remove(tileId);
                        
                        //Add the updated ParentTreeItemElement to the Map again.
                        tileTreeElementMap.put(ParentId, parentTree);
                    }
                }
            }
        }
        
        //returns the Final required Tree
        return new ContentTreeWrapper(validContentMap, tileTreeElementMap.values());
    }
    
    /* @Description
Method Name : getLibraryTree()

1. This method return the complete Library tree of the org
2. Each Library has sub-folders inside and these are constructed properly and is returned back to aura component
3. Every new content has a file attached to it and that file will be stored under a place in library. This place selection is
enabled using the library tree. 
4. This method will only return those library which the current logged in user has access to. There are specific permissions
which enable a particular library to be shown during selection

*/
    
    @AuraEnabled
    public static LibraryTreeWrapper getLibraryTree(){
        
        /* Initialize variables */
        libraryTreeElementMap = new Map<Id,TreeItemElement>(); // Stores the folderId, TreeItemElement
        childParentIdMap = new Map<Id,Id>(); // folderId, folder's ParentId
        Map<Id,Id> folderLibraryMap = new Map<Id,Id>();
        
        /* Stores the librarydepth , <folderId, TreeItemElement>
This stores the current depth of the current folder along with it's folderId, TreeItemElement
*/
        depthlibraryTreeElementMap = new Map<Integer, Map<Id,TreeItemElement>>();
        
        //TemporaryTiles to use in While Loop, used to make sure all the child elements are fetched and stored
        List<ContentFolder> tempContentFolders      = new List<ContentFolder>();
        Set<Id> libraryIds                          = new Set<Id>();
        
        Id libraryvirtualId                         = [SELECT Id,Community_Name_on_Content_Creation__c,Content_type_Main_tile_Info__c FROM Community_Setting__mdt][0].Id;
        TreeItemElement libraryVirtualTreeElement   = new TreeItemElement('Library', libraryvirtualId, null, false, null, null /*parentTile.UI_Description__c*/);
        
        depthlibraryTreeElementMap.put(1, new Map<Id,TreeItemElement>{libraryvirtualId => libraryVirtualTreeElement});
        libraryTreeElementMap.put(libraryvirtualId, libraryVirtualTreeElement);
        
        //Fetches the Parent Tile : For Distributor it will be "FCI Distributor Recipe Main Tile", the tile from where the content hierarchy starts
        List<ContentWorkspace> contentWorkSpaces = [SELECT Id, Name, RootContentFolderId 
                                                    FROM ContentWorkspace 
                                                    WHERE RootContentFolderId != null
                                                    AND RootContentFolderId IN: getUserAccessibleContentWorkSpaces()];
        
        //This is the first/top most tile, hence depth is given as 1
        if(!contentWorkSpaces.isEmpty()){
            
            Map<Id,TreeItemElement> contentWorkSpaceTreeMapAtCurrentDepth = new Map<Id,TreeItemElement>();
            
            for(ContentWorkspace eachWorkSpace : contentWorkSpaces){
                
                TreeItemElement eachTreeElement = new TreeItemElement(eachWorkSpace.Name, eachWorkSpace.RootContentFolderId, null, false, null, null /*tl.UI_Description__c*/);
                libraryTreeElementMap.put(eachWorkSpace.RootContentFolderId, eachTreeElement);
                childParentIdMap.put(eachWorkSpace.RootContentFolderId, libraryvirtualId);
                contentWorkSpaceTreeMapAtCurrentDepth.put(eachWorkSpace.RootContentFolderId, eachTreeElement);
                libraryIds.add(eachWorkSpace.RootContentFolderId);
                folderLibraryMap.put(eachWorkSpace.RootContentFolderId, eachWorkSpace.RootContentFolderId);
            }
            depthlibraryTreeElementMap.put(2, contentWorkSpaceTreeMapAtCurrentDepth);
        }
        
        /* This is first depth of folders that runs outside the while loop because the first
depth is where the folder starts and the parent is always Library(ContentWorkSpace) */
        tempContentFolders = [SELECT Id, ParentContentFolderId, Name, ParentContentFolder.Name FROM ContentFolder where ParentContentFolderId IN: libraryIds];
        
        if(!tempContentFolders.isEmpty()){
            
            Map<Id,TreeItemElement> contentFolderTreeMapAtCurrentDepth = new Map<Id,TreeItemElement>();
            
            for(ContentFolder contFolder : tempContentFolders){
                
                TreeItemElement eachTreeElement = new TreeItemElement(contFolder.Name, contFolder.Id, null, false, null, null /*tl.UI_Description__c*/);
                
                libraryTreeElementMap.put(contFolder.Id, eachTreeElement);
                childParentIdMap.put(contFolder.Id, contFolder.ParentContentFolderId);
                contentFolderTreeMapAtCurrentDepth.put(contFolder.Id, eachTreeElement);
                
                if(folderLibraryMap.containsKey(contFolder.ParentContentFolderId)){
                    folderLibraryMap.put(contFolder.Id, folderLibraryMap.get(contFolder.ParentContentFolderId));
                }
            }
            
            depthlibraryTreeElementMap.put(3, contentFolderTreeMapAtCurrentDepth);
        }
        
        /* This is where the depth starts for 2nd level of folders as after this all will be folders (ContentFolder), hence while loop is used here */
        Integer currentLibraryDepth = 3;
        while (!tempContentFolders.isEmpty()) {
            
            currentLibraryDepth = currentLibraryDepth + 1;
            
            //Temporary contentfolderTreeMap at current Depth
            Map<Id,TreeItemElement> contentFolderMapAtCurrentDepth = new Map<Id,TreeItemElement>();
            List<ContentFolder> tempConFolders = [SELECT Id, ParentContentFolderId, Name, ParentContentFolder.Name FROM ContentFolder where ParentContentFolderId IN: tempContentFolders];
            for(ContentFolder eachContentFolder : tempConFolders){
                
                TreeItemElement eachTreeElement = new TreeItemElement(eachContentFolder.Name, eachContentFolder.Id, null, false, null, null /*tl.UI_Description__c*/);
                
                libraryTreeElementMap.put(eachContentFolder.Id, eachTreeElement);
                childParentIdMap.put(eachContentFolder.Id, eachContentFolder.ParentContentFolderId);
                contentFolderMapAtCurrentDepth.put(eachContentFolder.Id, eachTreeElement);
                
                if(folderLibraryMap.containsKey(eachContentFolder.ParentContentFolderId)){
                    folderLibraryMap.put(eachContentFolder.Id, folderLibraryMap.get(eachContentFolder.ParentContentFolderId));
                }
                
            }
            
            depthlibraryTreeElementMap.put(currentLibraryDepth, contentFolderMapAtCurrentDepth);
            
            //Clears the tempContentFolders to store the queried tempfolders and start loop again, until tempFolders is Empty and loop exits after that
            tempContentFolders.clear();
            tempContentFolders.addAll(tempConFolders);
        }
        
        //Sort the depths of folders to ascending order
        List<Integer> sortingOrders = new List<Integer>(depthlibraryTreeElementMap.keySet());
        sortingOrders.sort();
        
        Map<Id,String> validLibraryMap = new Map<Id,String>();
        /*Run the loop in the descending order of folder depth from the sorted list above
to make sure the iteration starts from the lowest level/depth
*/
        for(Integer j = sortingOrders.size() - 1; j > 1; j--){
            
            for(Id contentLibFoldId : depthlibraryTreeElementMap.get(j).keySet()){
                
                if(childParentIdMap.containsKey(contentLibFoldId)){
                    
                    Id ParentId = childParentIdMap.get(contentLibFoldId);
                    if(ParentId != null){
                        
                        //Get the ParentTree Element and add the child tree elements to the Parent TreeItemElement's "items"
                        TreeItemElement  parentTree = libraryTreeElementMap.get(ParentId);
                        parentTree.items.add(libraryTreeElementMap.get(contentLibFoldId));
                        
                        //Add the library content path
                        validLibraryMap.put(contentLibFoldId, getLibraryIdContentHierarchyName(contentLibFoldId));
                        
                        //Remove the child Element from the map once it is added to the Parent TreeItemElement's "items"
                        libraryTreeElementMap.remove(contentLibFoldId);
                        
                        //Add the updated ParentTreeItemElement to the Map again.
                        libraryTreeElementMap.put(ParentId, parentTree);
                    }
                }
            }
        }
        
        //returns the Final required Tree
        return new LibraryTreeWrapper(validLibraryMap, folderLibraryMap, libraryTreeElementMap.values());
    }
    
    /* @Description
Method Name : getLibraryIdContentHierarchyName( Id )

1. Return the path of the Library from the current folder( represented by folderId)
2. For ex: if the library "Food & Beverages" has a folder "ABCD" inside which also has a "XYZ" folder inside it
then the path returned would be "Food & Beverages > ABCD > XYZ"
3. This is a visualization to be shown to the user when they select a library and also in the review page
4. It will be shown in the review page where the user can verify the path under which the file will be stored.

@PARAMS
1. NAME ( folderId )    => TYPE ( Id ) => DESCRIPTION ( Folder Id for which the path will be generated )
*/
    
    private static String getLibraryIdContentHierarchyName(Id folderId){
        
        Id tempParentId = childParentIdMap.get(folderId);
        String libraryStoragePath = libraryTreeElementMap.get(folderId).label;
        
        while(!String.isBlank(tempParentId)){
            
            libraryStoragePath = libraryTreeElementMap.get(tempParentId).label + ' > ' + libraryStoragePath;
            
            tempParentId = childParentIdMap.get(tempParentId);
            if(String.isBlank(tempParentId)){
                break;
            } 
        }
        return libraryStoragePath;
    }
    
    
    /* @Description
Method Name : getLibraryIdContentHierarchyName( Id )

1. return the library Ids to which the logged in user has permission to.
2. User must have AddContent and DeliverContent permission to see a library

*/
    
    private static Set<Id> getUserAccessibleContentWorkSpaces(){
        
        Set<Id> libraryRootFolderIds = new Set<Id>();
        
        List<ContentWorkspaceMember> ContentWSM = [SELECT 
                                                   ContentWorkspace.RootContentFolderId, 
                                                   ContentWorkspacePermission.PermissionsAddContent, 
                                                   ContentWorkspacePermission.PermissionsDeliverContent, 
                                                   MemberId 
                                                   FROM ContentWorkspaceMember 
                                                   WHERE MemberId =: UserInfo.getUserId() 
                                                   AND ContentWorkspacePermission.PermissionsAddContent = true
                                                   AND ContentWorkspacePermission.PermissionsDeliverContent = true];
        
        for(ContentWorkspaceMember eachcontentWSM : ContentWSM){
            
            libraryRootFolderIds.add(eachcontentWSM.ContentWorkspace.RootContentFolderId);
        }
        return libraryRootFolderIds;
    }
    
    /* @Description
Method Name : getTileIdContentHierarchyName( Id )

1. Return the path of the Content from the current tile ( represented by tileId) till the parent tile
2. For ex: if the Root Tile "Recipes" has a child Tile "ABCD" inside which also has a "XYZ" child Tile inside it
then the path returned would be "Recipes > ABCD > XYZ"
3. This is a visualization to be shown to the user when they select a Tile path and also in the review page
4. It will be shown in the review page where the user can verify the path under which the content will be visible in community.

@PARAMS
1. NAME ( tileId )  => TYPE ( Id ) => DESCRIPTION ( Tile Id for which the path will be generated )
*/
    
    private static String getTileIdContentHierarchyName(Id tileId){
        
        Id tempParentId = childParentIdMap.get(tileId);
        String contentStoragePath = tileTreeElementMap.get(tileId).label;
        
        while(!String.isBlank(tempParentId)){
            if (tileTreeElementMap.containsKey(tempParentId)) {
                contentStoragePath = tileTreeElementMap.get(tempParentId).label + ' > ' + contentStoragePath;
            }
            else{
                break;
            }
            tempParentId = childParentIdMap.get(tempParentId);
            if(String.isBlank(tempParentId)){
                break;
            } 
        }
        return contentStoragePath;
    }
    
    /* @Description
Method Name : setNameContentTypeMap( Community_Setting__mdt , ContentManagementWrapper )

1. Sets the community name and content type map
2. This uses the community setting metadata to set this value.
3. The custom field "Content_type_Main_tile_Info__c" from Community setting metadata stores the content type info along with
the root tile name for each content type name
4. For ex: for distributor community record in the metadata the "Content_type_Main_tile_Info__c" will have the following data
"Recipes - FCI Distributor Recipes Main Tile
Products - FCI Distributor Product Main Tile
Additional Info - FCI Distributor Additional Information Main Tile
Marketing Info - FCI Distributor Marketing Information Main Tile"
5. So for "Recipes" the root tile from where the content Tree begins is "FCI Distributor Recipes Main Tile" and same for Products, Additional Info etc.
@PARAMS
1. NAME ( commSetting )  => TYPE ( Community_Setting__mdt ) => DESCRIPTION ( The community setting custom metadata )
2. NAME ( contentWrapper )  => TYPE ( ContentManagementWrapper ) => DESCRIPTION ( The contentManagementWrapper formed on InitializeContentData method )
*/
    
    private static void setNameContentTypeMap(Community_Setting__mdt commSetting, ContentManagementWrapper contentWrapper){
        
        List<String> contentTileInfoList    = commSetting.Content_type_Main_tile_Info__c.split('\n');
        
        for(String eachInfo : contentTileInfoList){
            
            if(!contentWrapper.nameContentTypeMap.containsKey(commSetting.Community_Name_on_Content_Creation__c)){
                
                contentWrapper.nameContentTypeMap.put(commSetting.Community_Name_on_Content_Creation__c, new List<String>());
            }
            contentWrapper.nameContentTypeMap.get(commSetting.Community_Name_on_Content_Creation__c).add(eachInfo);
        }
        
    }
    
    /* @Description
Method Name : getBusinessSegmentDependency( )

1. Return the Business segment and List<Sub-segment> dependency back to aura component
2. This uses the User interface API to fetch the data
*/
    
    private static Map<String, List<String>> getBusinessSegmentDependency(){
        /*UserInterfaceAPIUtility.SinglePicklistWrapper singlePickWrap = UserInterfaceAPIUtility.getSinglePicklistValues(OPPORTUNITY_API_NAME,OPPORTUNITY_FCI_NEW_BUSINESS_RECORDTYPE,SUB_SEGMENT_FIELD_API_NAME);
return singlePickWrap.controllingWithDependentValues;*/
        
        /*
* As we have the FCI, FCP reocrd type split in the opportunity,
* and for this logic, we need the business segments and subsegments of both FCI, FCP.
* so commented above code and modified as below
*/
        Map<String, List<String>> fciFcpBusinessSegmentSubSegmentsMap = new Map<String, List<String>>();
        //fciFcpBusinessSegmentSubSegmentsMap.putAll(UserInterfaceAPIUtility.getSinglePicklistValues(OPPORTUNITY_API_NAME,OPPORTUNITY_FCI_NEW_BUSINESS_RECORDTYPE,SUB_SEGMENT_FIELD_API_NAME).controllingWithDependentValues);
        //fciFcpBusinessSegmentSubSegmentsMap.putAll(UserInterfaceAPIUtility.getSinglePicklistValues(OPPORTUNITY_API_NAME,OPPORTUNITY_FCP_NEW_BUSINESS_RECORDTYPE,SUB_SEGMENT_FIELD_API_NAME).controllingWithDependentValues);
        
        //ENH-5684 - Commented the above two lines to fetch the Business Segment and Sub Segment picklist values from Tile Object instead of fetching those from Opportunity Object.
        fciFcpBusinessSegmentSubSegmentsMap.putAll(UserInterfaceAPIUtility.getSinglePicklistValues(TILE_API_NAME,TILE_GLOBAL_RECORD_TYPE_ID,SUB_SEGMENT_FIELD_API_NAME).controllingWithDependentValues);
        return fciFcpBusinessSegmentSubSegmentsMap;
    }
    
    /* @Description
Method Name : getPicklistValues( Schema.SObjectField )

1. Returns all the list of picklist values for a given picklist
2. Returns each value as string in the format "Picklist Label - Picklist Value"

@PARAMS
1. NAME ( fieldName )  => TYPE ( Schema.SObjectField ) => DESCRIPTION ( This sObject picklist field API name for which all values needs to fetched )
*/
    
    private static List<String> getPicklistValues(Schema.SObjectField fieldName){
        List<String> pickListValues = new List<String>();
        Schema.DescribeFieldResult fldRes = fieldName.getDescribe();
        for(Schema.PicklistEntry eachPicklist :  fldRes.getPicklistValues()){
            if(eachPicklist.isActive()){
                pickListValues.add(eachPicklist.getLabel() + '-' + eachPicklist.getValue()); 
            }
        }
        
        return pickListValues;
    }
    
    /* @Description
Method Name : checkValidationAndSendMessage( String , String )

1. This method is called first when a user proceeds to save an article
2. It does 2 things:
a. Checks if the tile name provided for creation already exists in the system. If yes, then duplicate is not allowed as there is a duplicate rule which states that Tile Name cannot be duplicated
b. Checks if the knowledge URL is valid as the "URLName" field on Knowledge accepts URL in spefic format

@PARAMS
1. NAME ( selectArticleTileName )  => TYPE ( String ) => DESCRIPTION ( The entered article name by user )
1. NAME ( knowledgeURL )  => TYPE ( String ) => DESCRIPTION ( The knowledge URL generated from the article name provided )
*/
    
    @AuraEnabled
    public static String checkValidationAndSendMessage(String selectArticleTileName, String knowledgeURL){
        
        if(!String.isBlank(checkTileNameDuplicate(selectArticleTileName)))                          return VALIDATION_MESSAGE;
        if(!String.isBlank(checkKnowledgeTileOrURLDuplicate(knowledgeURL,selectArticleTileName)))   return VALIDATION_MESSAGE;
        //if(!String.isBlank(checkContentLibraryAccess(libraryId)))                                   return VALIDATION_MESSAGE;
        return '';
    }
    
    /* @Description
Method Name : checkTileNameDuplicate( String )

1. One of the method called when user saves record
2. Called from "checkValidationAndSendMessage" method.
3. Checks if the tile name provided for creation already exists in the system. If yes, then duplicate is not allowed as there is a duplicate rule which states that Tile Name cannot be duplicated

@PARAMS
1. NAME ( selectArticleTileName )  => TYPE ( String ) => DESCRIPTION ( The entered article name by user )
*/
    
    private static String checkTileNameDuplicate(String selectArticleTileName){
        
        List<Tile__c> existingTile = [SELECT Id,Name FROM Tile__c WHERE Name =: selectArticleTileName];
        
        if(!existingTile.isEmpty()) return VALIDATION_MESSAGE = String.format(VALIDATION_MESSAGE, new List<String>{'Duplicate Article','Article with the same name already exists. Please give another article name'});
        return '';
    }
    
    /* @Description
Method Name : checkKnowledgeTileOrURLDuplicate( String , String )

1. One of the method called when user saves record
2. Called from "checkValidationAndSendMessage" method.
3. Checks if the knowledge URL is valid as the "URLName" field on Knowledge accepts URL in spefic format

@PARAMS
1. NAME ( selectArticleTileName )  => TYPE ( String ) => DESCRIPTION ( The entered article name by user )
1. NAME ( knowledgeURL )  => TYPE ( String ) => DESCRIPTION ( The knowledge URL generated from the article name provided )
*/
    
    private static String checkKnowledgeTileOrURLDuplicate(String knowledgeURL, String selectArticleTileName){
        
        List<Knowledge__kav> knowledgeKavs = [SELECT Id FROM Knowledge__kav WHERE title =: selectArticleTileName OR urlName =: knowledgeURL LIMIT 1];
        
        if(!knowledgeKavs.isEmpty()) return VALIDATION_MESSAGE = String.format(VALIDATION_MESSAGE, new List<String>{'Duplicate Knowledge URL','Article with the same URL already exists. Please give another article URL by changing the article name'});
        return '';
    }
    
    // private static String checkContentLibraryAccess(String libraryId){
    
    //     List<ContentWorkspaceMember> ContentWSM = [SELECT ContentWorkspacePermission.PermissionsAddContent, ContentWorkspacePermission.PermissionsDeliverContent , MemberId FROM ContentWorkspaceMember WHERE MemberId =: UserInfo.getUserId() AND ContentWorkspace.RootContentFolderId =: libraryId];
    
    //     if(ContentWSM.isEmpty() || (!ContentWSM.isEmpty() && !ContentWSM.get(0).ContentWorkspacePermission.PermissionsAddContent && !ContentWSM.get(0).ContentWorkspacePermission.PermissionsDeliverContent)) 
    //         return VALIDATION_MESSAGE = String.format(VALIDATION_MESSAGE, new List<String>{'Access Denied','You do not have access to the selected library or you cannot publish your content under this Library, please choose another path to which you have access to'});       
    
    //     return '';
    // }
    
    @AuraEnabled
    public static void createfinalKnowledgeData(
        /*String selectedKnowledgeTileId, */
        String selectedCommunityNames, 
        String knowledgeArticleName,
        String knowledgeDescription, 
        String reviewOrEndDate, 
        String contentCategoriesObjList,
        List<String> businessSegments, List<String> subSegments, List<String> salesRegions,
        String fileName, 
        String contenVersionId, 
        String knowledgeArticleURL, 
        String contentPathLocationList,
        String contentLibraryLocationList,
        /*ENH-4370*/String selectedContentOwner,
        /*B2B-325*/List<Id> selectedH1Accounts, List<Id> selectedH5Accounts, /* B2B-326*/String categoryObjArrayData,String contentType){
            system.debug('categoryObjArrayData::::'+categoryObjArrayData);
            
            Id contentVersionId = saveFileUnderLibrariesAndCreateKnowledgeArticle(fileName, contenVersionId, knowledgeArticleURL, contentLibraryLocationList, selectedContentOwner);
            createPublicURLAndCreateKnowedgeAndTiles(
                /* These information are for Knowledge Article creation */
                contenVersionId, 
                knowledgeArticleName, 
                knowledgeArticleURL, 
                fileName, 
                reviewOrEndDate, 
                contentPathLocationList,
                /* Segment & Sales Region Informations */
                businessSegments, subSegments, salesRegions,
                /* These information are for tile creation */
                selectedCommunityNames,
                knowledgeDescription,
                contentCategoriesObjList,
                /* Content Owner - ENH-4370*/
                selectedContentOwner,
                /*B2B-325*/                
                selectedH1Accounts,
                selectedH5Accounts,
                /* B2B-326*/
                categoryObjArrayData,
                contentType);
        }
    
    private static Id saveFileUnderLibrariesAndCreateKnowledgeArticle(
        String fileName,
        String contenVersionId,
        String knowledgeArticleURL,
        String contentLibraryLocationList,
        String contentOwnerId){
            
            // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            
            //ContentVersion conVer   = ContentManagementHelper.getContentVersionToInsert(EncodingUtil.base64Decode(base64Data), fileName);
            //insert conVer;
            ContentVersion conVer = [SELECT Id, ContentDocumentId, OwnerId FROM ContentVersion WHERE Id =:contenVersionId];
            //ENH-4370 check the file owner with the owner selected in cms tool while creating article and update if the owner is different
            /*if(conVer.OwnerId != contentOwnerId){
conVer.OwnerId = contentOwnerId;
update conVer;
}*/
            
            Id contentDocumentId = getContentDocIdFromContentVersion(conVer);
            ContentManagementHelper.associateFileInLibraries(contentDocumentId, contentLibraryLocationList, contentOwnerId, contenVersionId, conVer.OwnerId);
            
            return conVer.Id;
        }
    
    //@future
    public static void createPublicURLAndCreateKnowedgeAndTiles(
        /* These information are for Knowledge creation */
        Id contentVerId, 
        String knowledgeArticleName, 
        String knowledgeArticleURL, 
        String fileName, 
        String reviewOrEndDate, 
        String contentPathLocationList,
        /* Segment & Sales Region Informations */
        List<String> businessSegments, List<String> subSegments, List<String> salesRegions,
        /* These information are for tile creation */
        String selectedCommunityNames,
        String knowledgeDescription,
        String contentCategoriesObjList,
        /*Content owner - ENH-4370*/
        String selectedContentOwner,        
        /*B2B-325*/
        List<Id> selectedH1Accounts, 
        List<Id> selectedH5Accounts,
        /* B2B-326*/
        String categoryObjArrayData,
        String contentType){
            
            String filepublicURL = ContentManagementHelper.getFilePublicURL(contentVerId, fileName);
            
            Knowledge__kav newArticle = KnowledgeArticleUtility.createNewArticleAsADraft(
                
                knowledgeArticleName,
                knowledgeArticleURL,
                true,
                KNOWLEDGE_COMMUNITY_ARTICLE_RECORD_TYPE_ID,
                String.join(businessSegments, ';'),
                String.join(subSegments, ';'),
                String.join(salesRegions, ';'),
                //UserInfo.getUserId(),
                selectedContentOwner,/*ENH-4370*/
                Date.valueOf(reviewOrEndDate),
                false,
                true,
                true,
                ContentManagementHelper.getArticleDetailsIframeURL(filepublicURL),
                knowledgeDescription
            );
            try{
                insert newArticle;
            }catch (Exception e) {
                throw new MyException(e.getMessage().substringBeforeLast(':').substringBeforeLast(':').substringAfter(';'));
            }
            
            Id KnowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;
            
            KnowledgeArticleUtility.publishArticle(KnowledgeArticleId);
            
            createKnowledgeTilesAndRelatedTiles(contentVerId, selectedCommunityNames,
                                                knowledgeArticleName, knowledgeDescription, reviewOrEndDate,
                                                contentCategoriesObjList, contentPathLocationList,
                                                businessSegments, subSegments, salesRegions,
                                                newArticle.Id, /*selectedH1, selectedH5,*/ /*ENH-4370*/selectedContentOwner,
                                                /*B2B-325*/selectedH1Accounts,selectedH5Accounts, /* B2B-326*/ categoryObjArrayData,contentType);
        }
    
    public static void createKnowledgeTilesAndRelatedTiles(Id contentVerId, String selectedCommunityNames, 
                                                           String knowledgeArticleName, String knowledgeDescription, String reviewOrEndDate, 
                                                           String contentCategoriesObjList, String contentPathLocationList,
                                                           List<String> businessSegments, List<String> subSegments, List<String> salesRegions,
                                                           String knowledgeArticleId, /*String h1Account, String h5Account, ENH-4370*/ String selectedContentOwner,
                                                           /*B2B-325*/List<Id> selectedH1Accounts, List<Id> selectedH5Accounts, /* B2B-326*/ String categoryObjArrayData,String contentType){
                                                               
                                                               List<Tile__c> tilesToInsert = new List<Tile__c>();
                                                               List<ContentLocationWrapper> contentLWList = (List<ContentLocationWrapper>)JSON.deserialize(contentPathLocationList, List<ContentLocationWrapper>.CLASS);
                                                               Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVerId].ContentDocumentId;
                                                               System.debug('###SP Inside createKnowledgeTilesAndRelatedTiles');
                                                               for(ContentLocationWrapper eachContentLW : contentLWList){
                                                                   
                                                                   tilesToInsert.add(
                                                                       new Tile__c(
                                                                           
                                                                           Parent_Tile__c              = !String.isBlank(eachContentLW.SelectedTileId) ? eachContentLW.SelectedTileId : null,
                                                                           Community_Name__c           = selectedCommunityNames,
                                                                           Name                        = knowledgeArticleName,
                                                                           UI_Name__c                  = knowledgeArticleName,
                                                                           UI_Description__c           = knowledgeDescription,
                                                                           Review_End_Date__c          = Date.valueOf(reviewOrEndDate),
                                                                           Business_Segment__c         = String.join(businessSegments, ';'),
                                                                           Sub_Segment__c              = String.join(subSegments, ';'),
                                                                           Sales_Region__c             = String.join(salesRegions, ';'),
                                                                           OwnerId                     = selectedContentOwner,//ENH-4370
                                                                           RecordTypeId                = TILE_GLOBAL_RECORD_TYPE_ID,
                                                                           Article_Name__c             = knowledgeArticleId,
                                                                           File_ContentDocumentId__c   = contentDocId
                                                                           //Work_Location__c            = !String.isBlank(h5Account) ? h5Account : null,
                                                                           //Parent_Account__c           = !String.isBlank(h1Account) ? h1Account : null
                                                                       ));
                                                                   
                                                               }
                                                               try{
                                                                   insert tilesToInsert;
                                                               }catch (Exception e) {
                                                                  
                                                                   throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
                                                                   
                                                               }
                                                               Set<Id> tileIds = (new Map<Id,Tile__c>(tilesToInsert)).keySet();
                                                               
                                                               /*B2B-325*/
                                                               createTileAccounts(tileIds, selectedH1Accounts, selectedH5Accounts); 
                                                               createRelatedKnowledgeTiles(contentCategoriesObjList, tileIds, categoryObjArrayData, contentType);
                                                           }
    
    
    /* B2B-325 */
    public static void createTileAccounts(Set<Id> tileIds, List<Id> selectedH1Accounts, List<Id> selectedH5Accounts) {
        if ((tileIds == null || tileIds.isEmpty()) ||
            ((selectedH1Accounts == null || selectedH1Accounts.isEmpty()) &&
             (selectedH5Accounts == null || selectedH5Accounts.isEmpty()))) {
                 return;
             }
        List<Tile_Account__c> tileAccountsToInsert = new List<Tile_Account__c>();
        // Map to hold account IDs to avoid duplicate records
        Map<Id, Set<Id>> accountTileMap = new Map<Id, Set<Id>>();
        
        // Map for H1 Accounts
        if (selectedH1Accounts != null && !selectedH1Accounts.isEmpty()) {
            for (Id h1AccountId : selectedH1Accounts) {
                if (!accountTileMap.containsKey(h1AccountId)) {
                    accountTileMap.put(h1AccountId, new Set<Id>());
                }
                accountTileMap.get(h1AccountId).addAll(tileIds);
            }
        }
        // Map with H5 Accounts
        if (selectedH5Accounts != null && !selectedH5Accounts.isEmpty()) {
            for (Id h5AccountId : selectedH5Accounts) {
                if (!accountTileMap.containsKey(h5AccountId)) {
                    accountTileMap.put(h5AccountId, new Set<Id>());
                }
                accountTileMap.get(h5AccountId).addAll(tileIds);
            }
        }
        // Convert the map entries to Tile_Account__c records
        for (Id accountId : accountTileMap.keySet()) {
            for (Id tileId : accountTileMap.get(accountId)) {
                tileAccountsToInsert.add(new Tile_Account__c(
                    Account__c = accountId,
                    Tile__c = tileId
                ));
            }
        }
        system.debug('tileAccountsToInsert--?'+tileAccountsToInsert);
        if (!tileAccountsToInsert.isEmpty()) {
            try {
                insert tileAccountsToInsert;
            } catch (Exception e) {
                throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
            }
        }
    }
    
    public static void createRelatedKnowledgeTiles(String contentCategoriesObjList, Set<Id> tileIds, String categoryObjArrayData,String contentType) {
        // Deserializing the contentCategoriesObjList into ContentCategoriesWrapper
        List<ContentManagementController.ContentCategoriesWrapper> contentCategories = 
            (List<ContentManagementController.ContentCategoriesWrapper>)JSON.deserialize(contentCategoriesObjList, 
                                                                                         List<ContentManagementController.ContentCategoriesWrapper>.class);
        system.debug('categoryObjArrayData-->'+categoryObjArrayData);
        // Deserializing categoryObjArrayData into a list of generic objects
        /* B2B-326*/
        List<Object> categoryDataList = (List<Object>) JSON.deserializeUntyped(categoryObjArrayData);
        system.debug('categoryDataList-->'+categoryDataList);
        List<Related_Tile__c> relatedKnowledgeTiles = new List<Related_Tile__c>();
        Integer i = 0;
        
        // Loop through the deserialized categoryDataList
        for (Object obj : categoryDataList) {
            Map<String, Object> categoryData = (Map<String, Object>) obj; 
            i++;
            
            String category = (String) categoryData.get('contentCategorySelected');
            String tileKnowledgeId = (String) categoryData.get('tileKnowledgeId');
            String tileId = (String) categoryData.get('tileKnowledgeId');
            system.debug('category-->'+category);
            system.debug('tileKnowledgeId-->'+tileKnowledgeId);
            system.debug('tileId-->'+tileId);
            system.debug('contentType-->'+contentType);
            if (!String.isBlank(category) && !String.isBlank(tileId)) {
                if (contentType == 'Related Article') {
                    for (Id eachTileId : tileIds) {
                        relatedKnowledgeTiles.add(
                            new Related_Tile__c(
                                Tile__c                 = tileId,
                                Related_Tile_Type__c    = category,
                                Related_Tile__c         = eachTileId,
                                Sorting_Order__c        = i
                            )
                        );
                    }
                } /*B2B-326*/
                else{
                    // Logic for other content types
                    for (Id eachTileId : tileIds) {
                        relatedKnowledgeTiles.add(
                            new Related_Tile__c(
                                Tile__c                 = eachTileId ,
                                Related_Tile_Type__c    = category,
                                Related_Tile__c         = tileId,
                                Sorting_Order__c        = i
                            )
                        );
                    }
                }
            }
            system.debug('relatedKnowledgeTiles-->'+relatedKnowledgeTiles);
            if(!relatedKnowledgeTiles.isEmpty()){
                try{
                    upsert relatedKnowledgeTiles;
                }catch (Exception e) {
                    throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
                }
                
            }
        }
    }
    
    @AuraEnabled
    public static void saveEditedArticleData(String tileObj, String contentVersionId, 
                                             String fileName, String knowledgeURL,
                                             String contentLibraryLocationList, String contentPathLocationList, 
                                             String operation, String contentCategoriesObjList,
                                             String selectedContentOwnerId, /* B2B-326*/String categoryObjArrayData,String contentType){
                                                 SavePoint sp = Database.setSavePoint();
                                                 try{
                                                     Object tileObjdeserialized = (Object)JSON.deserializeUntyped(tileObj);
                                                     Map<String, Object> tileObjNameValueMap = (Map<String, Object>)tileObjdeserialized;
                                                     Id existingArticleId = String.valueOf(tileObjNameValueMap.get('Article_Name__c'));
                                                     String oldfileContentDocumentId = String.valueOf(tileObjNameValueMap.get('File_ContentDocumentId__c'));
                                                     List<Tile__c> relatedExistingTiles = ContentManagementHelper.getTileWithRelatedTiles(existingArticleId);
                                                     system.debug('####SP -> relatedExistingTiles-->'+relatedExistingTiles);
                                                     // Collect all Tile Ids in a list
                                                     List<Id> tileIds = new List<Id>();
                                                     for (Tile__c tile : relatedExistingTiles) {
                                                         tileIds.add(tile.Id);
                                                     }
                                                     system.debug('#####SP->tileIds-->'+tileIds);
                                                     //B2B-325
                                                     getH5AndH1Accounts(tileIds);
                                                     
                                                     if(!String.isBlank(contentVersionId)){
                                                         //After upadating it is 
                                                         contentVersionId = contentVersionId;
                                                     }
                                                     system.debug('operation-->'+operation);
                                                     switch on operation {
                                                         
                                                         //1
                                                         when 'onlyKnowledgeFields' {
                                                             
                                                             ContentManagementHelper.onlyKnowledgeFields( tileObjNameValueMap, existingArticleId, knowledgeURL, selectedContentOwnerId );
                                                         }
                                                         
                                                         //2
                                                         when 'onlyContentPaths' {
                                                             
                                                             ContentManagementHelper.onlyContentPaths( tileObjNameValueMap, contentPathLocationList, existingArticleId, oldfileContentDocumentId );
                                                         }
                                                         
                                                         //3
                                                         when 'onlyLibraryPaths' {
                                                             
                                                             ContentManagementHelper.onlyLibraryPaths( tileObjNameValueMap, existingArticleId, knowledgeURL, oldfileContentDocumentId, contentLibraryLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //4
                                                         when 'onlyNewFileChosen' {
                                                             
                                                             ContentManagementHelper.onlyNewFileChosen( tileObjNameValueMap, oldfileContentDocumentId, existingArticleId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //5
                                                         when 'knowledgeFields_contentPaths' {
                                                             
                                                             ContentManagementHelper.knowledgeFields_contentPaths( tileObjNameValueMap, existingArticleId, knowledgeURL, contentPathLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //6
                                                         when 'knowledgeFields_libraryPaths' {
                                                             
                                                             ContentManagementHelper.knowledgeFields_libraryPaths( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentLibraryLocationList, knowledgeURL, selectedContentOwnerId );
                                                         }
                                                         
                                                         //7
                                                         when 'knowledgeFields_newFileChosen' {
                                                             
                                                             ContentManagementHelper.knowledgeFields_newFileChosen( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //8
                                                         when 'contentPaths_libraryPaths' {
                                                             
                                                             ContentManagementHelper.contentPaths_libraryPaths( tileObjNameValueMap, oldfileContentDocumentId, existingArticleId, contentLibraryLocationList, contentPathLocationList );
                                                         }
                                                         
                                                         //9
                                                         when 'contentPaths_newFileChosen' {
                                                             
                                                             ContentManagementHelper.contentPaths_newFileChosen( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, contentPathLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //10
                                                         when 'libraryPaths_newFileChosen' {
                                                             
                                                             ContentManagementHelper.libraryPaths_newFileChosen( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //11
                                                         when 'knowledgeFields_contentPaths_libraryPaths' {
                                                             
                                                             ContentManagementHelper.knowledgeFields_contentPaths_libraryPaths( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, knowledgeURL, contentLibraryLocationList, contentPathLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //12
                                                         when 'knowledgeFields_contentPaths_newFileChosen' {
                                                             
                                                             ContentManagementHelper.knowledgeFields_contentPaths_newFileChosen( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, contentPathLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //13
                                                         when 'knowledgeFields_libraryPaths_newFileChosen' {
                                                             
                                                             ContentManagementHelper.knowledgeFields_libraryPaths_newFileChosen( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //14
                                                         when 'contentPaths_libraryPaths_newFileChosen' {
                                                             
                                                             ContentManagementHelper.contentPaths_libraryPaths_newFileChosen( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, contentPathLocationList, selectedContentOwnerId );
                                                         }
                                                         
                                                         //15
                                                         when 'knowledgeFields_contentPaths_libraryPaths_newFileChosen' {
                                                             
                                                             ContentManagementHelper.knowledgeFields_contentPaths_libraryPaths_newFileChosen( tileObjNameValueMap, existingArticleId, oldfileContentDocumentId, contentVersionId, fileName, knowledgeURL, contentLibraryLocationList, contentPathLocationList, selectedContentOwnerId );
                                                         }
                                                     }
                                                     system.debug('contentCategoriesObjList before if-->'+contentCategoriesObjList);
                                                     if(!String.isBlank(contentCategoriesObjList)){
                                                         system.debug('contentCategoriesObjList-->'+contentCategoriesObjList);
                                                         
                                                         List<Tile__c> existingTiles = getExistingTilesAfterEditOperation( String.valueOf(tileObjNameValueMap.get('UI_Name__c')) );
                                                         List<Related_Tile__c> relatedTilesToDelete = new List<Related_Tile__c>();
                                                         List<Related_Tile__c> relatedKnowledgeTiles = new List<Related_Tile__c>();
                                                         Integer i = 0;
                                                         
                                                         for(Tile__c eachTile : existingTiles){
                                                             
                                                             relatedTilesToDelete.addAll( eachTile.Related_Tiles__r );
                                                         }
                                                         system.debug('relatedTilesToDelete: '+relatedTilesToDelete);
                                                         system.debug('relatedKnowledgeTiles: '+relatedKnowledgeTiles);
                                                         delete relatedTilesToDelete;
                                                         createRelatedKnowledgeTiles( contentCategoriesObjList, (new Map<Id, Tile__c> (existingTiles)).keySet(),categoryObjArrayData,contentType);
                                                         
                                                     }
                                                 }catch(Exception ex){
                                                     String ErrorMessage = 'Exception: ' + ex.getMessage();
                                                     Database.rollback(sp);
                                                     System.debug('Exception: ' + ex.getMessage() + ' at line number '+ ex.getLineNumber());
                                                     throw new MyException(ErrorMessage);
                                                 }
                                                 
                                             }
    
    private static List<Tile__c> getExistingTilesAfterEditOperation( String tileName ){
        
        List<Tile__c> tiles = [ SELECT Id, Article_Name__c FROM Tile__c WHERE UI_Name__c =: tileName ];
        
        if(!tiles.isEmpty()){
            
            return ContentManagementHelper.getTileWithRelatedTiles( tiles.get(0).Article_Name__c );
        }
        
        return tiles;
    }
    
    @AuraEnabled
    public static Tile__c getATileInfo(String tileId){
        return [SELECT Id, Name, UI_Name__c, UI_Description__c, Article_Name__c, Article_Name__r.Review_Exp_Date__c, File_ContentDocumentId__c, Parent_Tile__c, Parent_Tile__r.Name, Community_Name__c FROM Tile__c WHERE Id =: tileId]; 
    }
    
    @AuraEnabled
    public static String getRootTileName(Tile__c tileObj, String rootTileName){
        
        if( tileObj.Parent_Tile__c != null ) {
            rootTileName = tileObj.Parent_Tile__r.Name;
            Tile__c rootTile = [Select Id, Parent_Tile__r.Name FROM Tile__c WHERE Id =: tileObj.Parent_Tile__c];
            return getRootTileName( rootTile, rootTileName );
        } 
        return rootTileName;
    }
    
    @AuraEnabled
    public static List<String> getExistingRelatedArticles(String tileId){
        
        List<String> existingContentRelatedTiles = new List<String>();
        
        for(Related_Tile__c eachRelatedTile : [SELECT Id, Related_Tile_Type__c, Related_Tile__c, Related_Tile__r.Name FROM Related_Tile__c WHERE Tile__c =: tileId ORDER BY Sorting_Order__c]){
            
            String str = eachRelatedTile.Related_Tile_Type__c + '-' + eachRelatedTile.Related_Tile__c + '-' + eachRelatedTile.Related_Tile__r.Name;
            existingContentRelatedTiles.add(str);
        }
        
        return existingContentRelatedTiles;
    }
    
    @AuraEnabled
    public static List<Id> getExistingContentPath(/*String communityNames, String rootTile,*/ String tileName, String articleId){
        
        //Map<Id,String> validContentMap = getContentTree(rootTile, communityNames).validContentMap;
        List<Id> tileIds = new List<Id>();
        for(Tile__c eachTile : [SELECT Id, Parent_Tile__c FROM Tile__c WHERE Name =: tileName AND Article_Name__c =: articleId]){
            
            if(!String.isBlank(eachTile.Parent_Tile__c)) tileIds.add(eachTile.Parent_Tile__c);
        }
        
        return tileIds;
    }
    
    @AuraEnabled
    public static List<String> getExistingLibraryPaths(String tileId){
        List<String> folderLibraryIds = new List<String>();
        Tile__c[] tile = [SELECT Id, File_ContentDocumentId__c FROM Tile__c WHERE Id =: tileId];
        Id contentDocumentId = tile.size() > 0 ? tile[0].File_ContentDocumentId__c : '';
        //List<ContentFolderMember> ContentFolderMembers = [SELECT Id, ParentContentFolderId FROM ContentFolderMember WHERE ChildRecordId =: contentDocumentId];
        Map<Id, ContentFolder> contentFolderMap = new Map<Id, ContentFolder>(
            [SELECT Id, ParentContentFolderId, Name FROM ContentFolder WHERE (NOT Name LIKE '005%')]
        );
        
        String rootLibraryFolderId = '';
        for(ContentFolderMember eachContentFoldMember : [SELECT Id, ParentContentFolderId FROM ContentFolderMember WHERE ChildRecordId =: contentDocumentId]){
            rootLibraryFolderId = getRootLibraryFolderId(eachContentFoldMember.ParentContentFolderId, contentFolderMap);
            if(String.isBlank(rootLibraryFolderId)){
                continue;
            }
            folderLibraryIds.add(eachContentFoldMember.ParentContentFolderId + '-' + rootLibraryFolderId);
        }
        
        return folderLibraryIds;
    }
    
    private static String getRootLibraryFolderId(String folderId, Map<Id, ContentFolder> contentFolderMap){
        
        /*ContentFolder contFolder = [SELECT Id, ParentContentFolderId , Name FROM ContentFolder WHERE Id =: folderId];

if(!String.isBlank(contFolder.ParentContentFolderId)){

return getRootLibraryFolderId( contFolder.ParentContentFolderId );
}*/
        
        ContentFolder contFolder = contentFolderMap != null && !contentFolderMap.isEmpty() && contentFolderMap.containsKey(folderId) ? contentFolderMap.get(folderId) : new ContentFolder();
        
        if(String.isNotBlank(contFolder.ParentContentFolderId)){
            return getRootLibraryFolderId(contFolder.ParentContentFolderId, contentFolderMap);
        }
        
        ContentWorkSpace[] contWorkSpace = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Id =:contFolder.Name];
        if(contWorkSpace.size() > 0){
            return contWorkSpace[0].RootContentFolderId;
        }
        return null;
    }
    
    @AuraEnabled
    public static void deleteAllArticlesFromDB(List<Id> tileIds){
        String oldKnowledgeFilePublicURL = '';
        List<Tile__c> tilesToDelete = [SELECT Id, Article_Name__c, File_ContentDocumentId__c FROM Tile__c WHERE Id IN: tileIds];
        Set<Id> articleIds = new Set<Id>();
        Set<Id> contentDocIdsToDelete = new Set<Id>();
        
        for(Tile__c tileObj : tilesToDelete){
            
            if(!String.isBlank(tileObj.File_ContentDocumentId__c)){
                
                articleIds.add(tileObj.Article_Name__c);
                contentDocIdsToDelete.add(tileObj.File_ContentDocumentId__c);
            }
        }
        
        //B2B-156 Start
        delete [SELECT Id,Name FROM Related_Tile__c where Related_Tile__c IN: tileIds];
        //B2B-156 End
        /*B2B-315*/
        try{
            delete [SELECT Id FROM Tile__c WHERE Article_Name__c IN: articleIds];
        } catch (Exception e) {
            throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
        }
        /*B2B-315*/
        for(Knowledge__kav eachKnowledgeArticle : [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id IN: articleIds]){
            
            KbManagement.PublishingService.archiveOnlineArticle(eachKnowledgeArticle.KnowledgeArticleId, null);
            KbManagement.PublishingService.deleteArchivedArticle(eachKnowledgeArticle.KnowledgeArticleId);
        }
        
        delete [SELECT Id FROM ContentDocument WHERE Id IN: contentDocIdsToDelete];
    }
    
    /*
private static void assignNewContentDocumentToProperFolders(String oldContentDocId,String newContentDocId, Map<Id,Id> folderLibMap){

List<ContentFolderMember> newContentFolderMemberList = [SELECT Id,ParentContentFolderId,ChildRecordId FROM ContentFolderMember WHERE ChildRecordId =: newContentDocId];

Map<Id, List<ContentFolderMember>> folderIdContentFoldMap = getfolderIdContentFolderMap(newContentFolderMemberList); // RootLibraryFolderId always as it is inserted now.

for(ContentFolderMember eachOldContMember : [SELECT Id,ParentContentFolderId,ChildRecordId FROM ContentFolderMember WHERE ChildRecordId =: oldContentDocId]){

if(folderIdContentFoldMap.containsKey(folderLibMap.get(eachOldContMember.ParentContentFolderId))){

for(ContentFolderMember eachNewContMember : folderIdContentFoldMap.get(folderLibMap.get(eachOldContMember.ParentContentFolderId))){

eachNewContMember.ParentContentFolderId = eachOldContMember.ParentContentFolderId;
}
}
}

update newContentFolderMemberList; 
}

private static Map<Id, List<ContentFolderMember>> getfolderIdContentFolderMap(List<ContentFolderMember> newContentFolderMemberList){

Map<Id, List<ContentFolderMember>> folderIdContentFoldMap = new Map<Id, List<ContentFolderMember>>();

for(ContentFolderMember eachContMember : newContentFolderMemberList){

if(!folderIdContentFoldMap.containsKey(eachContMember.ParentContentFolderId)){

folderIdContentFoldMap.put(eachContMember.ParentContentFolderId, new List<ContentFolderMember>());
}

folderIdContentFoldMap.get(eachContMember.ParentContentFolderId).add(eachContMember);
}

return folderIdContentFoldMap;
}

private static String getContentDocumentIdFromContentDistribution(String knowledgeFilePublicURL){

for(ContentDistribution eachContDist : [SELECT ContentDocumentId, DistributionPublicURL FROM ContentDistribution]){

if(eachContDist.DistributionPublicURL != null && eachContDist.DistributionPublicURL.contains(knowledgeFilePublicURL)){

return eachContDist.ContentDocumentId;
}
}
return '';
}

private static Map<String,Id> getKnowledgeURLContentIdMap(){

Map<String,Id> knowledgeURLContentIdMap = new Map<String,Id>();

for(ContentDistribution eachContDist : [SELECT ContentDocumentId, DistributionPublicURL FROM ContentDistribution]){

if(eachContDist.DistributionPublicURL != null){

knowledgeURLContentIdMap.put(eachContDist.DistributionPublicURL, eachContDist.ContentDocumentId);
}
}
return knowledgeURLContentIdMap;
}

private static List<ContentDocumentLink> getNewContentDocumentsToInsert(String oldContentDocId, String newContentDocId){

List<ContentDocumentLink> newContentDocList = new List<ContentDocumentLink>();

for(ContentDocumentLink contDocLink : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: oldContentDocId]){

newContentDocList.add(new ContentDocumentLink(
ContentDocumentId   = newContentDocId,
LinkedEntityId      = contDocLink.LinkedEntityId, // This is the library Id
ShareType           = 'I',              // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
Visibility          = 'AllUsers'        // AllUsers, InternalUsers, SharedUsers
));
}

return newContentDocList;
}*/
    
    @TestVisible
    private static String getContentDocIdFromContentVersion(ContentVersion conVer){
        
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
    }
    
    public class ContentManagementWrapper {
        
        @AuraEnabled public List<String> names { get; set; }
        @AuraEnabled public List<String> salesRegions { get; set; }
        @AuraEnabled public Map<String, List<String>> nameContentTypeMap { get; set; }
        @AuraEnabled public Map<String, List<String>> businessSegSubSegMap { get; set; }
        @AuraEnabled public String contentOwnerName { get; set; }
        @AuraEnabled public List<String> contentCategories { get; set; }
        @AuraEnabled public Id contentOwnerId { get; set; }//ENH-4370
        
        public ContentManagementWrapper(){
            this.names                  = new List<String>();
            this.salesRegions           = getPicklistValues(Tile__c.Fields.Sales_Region__c); //Schema.SObjectField
            this.nameContentTypeMap     = new Map<String, List<String>>();
            this.businessSegSubSegMap   = getBusinessSegmentDependency();
            this.contentCategories      = getPicklistValues(Related_Tile__c.Fields.Related_Tile_Type__c);
            this.contentOwnerName       = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            this.contentOwnerId			= UserInfo.getUserId(); //ENH-4370
        }
    }
    
    public class ContentTreeWrapper {
        
        /*Used to validate the current selection done by User
Stores Id -> Name of the tile to display if selection is valid    
*/
        @AuraEnabled public Map<Id,String> validContentMap {get; set;} //format - validId - "Parent.Parent Name > Parent Name > Curent Name"
        @AuraEnabled public List<TreeItemElement> contentTree {get; set;}
        public ContentTreeWrapper(Map<Id,String> validContentMap, List<TreeItemElement> contentTree){
            
            this.validContentMap    = validContentMap;
            this.contentTree        = contentTree;
        }
    }
    
    public class LibraryTreeWrapper {
        
        /*Used to store the Library folder structure
Stores the Folder Id => Library Id map   
*/
        @AuraEnabled public Map<Id,String> validLibraryMap {get; set;} //format - validLibraryId - "Parent.Parent Library Name > Parent Library Name > Curent Library Name"
        @AuraEnabled public Map<Id,Id> folderLibraryMap {get; set;} //format - "FolderId => LibraryId"
        @AuraEnabled public List<TreeItemElement> libraryTree {get; set;}
        public LibraryTreeWrapper(Map<Id,String> validLibraryMap, Map<Id,String> folderLibraryMap, List<TreeItemElement> libraryTree){
            
            this.validLibraryMap    = validLibraryMap;
            this.folderLibraryMap   = folderLibraryMap;
            this.libraryTree        = libraryTree;
        }
    }
    
    public class ContentCategoriesWrapper {
        
        public String contentCategorySelected { get; set; }
        public String tileKnowledgeId { get; set; }
        public String category {get; set;}
    }
    
    public class ContentLibraryWrapper {
        
        public String SelectedFolderLibraryId { get; set; }
        public String LibraryStoragePath { get; set; }
        public String SelectedLibraryFolder { get; set; }
    }
    
    public class ContentLocationWrapper {
        
        public String SelectedTileId { get; set; }
        public String contentStoragePath { get; set; }
        public String isATreeSelected { get; set; }
        public String isACorrectTreeSelected { get; set; }
    }
    
    /* Commenting this part of the code as this will upload the file in chunks, Keeping it because it might be required later */
    /*private static Id saveAttachmentUnderTile(Id knowledgeArticleTileId,String fileName,String base64Data,String contentType){

base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

Attachment knowledgeAttachment = new Attachment(

ParentId    = knowledgeArticleTileId,
Body        = EncodingUtil.base64Decode(base64Data),
Name        = fileName,
contentType = contentType
);

insert knowledgeAttachment;

return knowledgeAttachment.Id;
}

@AuraEnabled
public static Id appendToExistingKnowledgeAttachment(Id attachmentId, String base64Data) {
base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

Attachment knowledgeAttachment = [
SELECT Id, Body
FROM Attachment
WHERE Id =: attachmentId
];

String existingBody = EncodingUtil.base64Encode(knowledgeAttachment.Body);

knowledgeAttachment.Body = EncodingUtil.base64Decode(existingBody + base64Data);

update knowledgeAttachment;

return knowledgeAttachment.Id;
}

@AuraEnabled
public static void createfileOutofAttachment(String attachmentId,String knowledgeArticleURL){

Attachment knowledgeAttachment = [
SELECT Id, Name, ContentType, ParentId, Body
FROM Attachment
WHERE Id =: attachmentId
];

ContentVersion conVer   = new ContentVersion(
ContentLocation = 'S',                      // to use S specify this document is in Salesforce, to use E for external files
PathOnClient    = knowledgeAttachment.Name, // The files name, extension is very important here which will help the file in preview.
Title           = knowledgeAttachment.Name, // Display name of the files
versionData     = knowledgeAttachment.Body  // Body/Content of the File
);

insert conVer;

Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;

createContentDocumentForKnowledgeTile(contentDocumentId, knowledgeAttachment.ParentId);

//Delete the attachment as it is no longer valid, only contentDocument is required for LEX
delete knowledgeAttachment;

//Create public URL from content Distributor and use the same to construct the knowledge Article
createPublicURLAndCreateKnowedgeArticle(conVer.Id, knowledgeAttachment.ParentId, knowledgeArticleURL, knowledgeAttachment.Name);
}*/
    
    
    /*
@CreatedDate             : 03-12-2021
@CreatedBy               : Mohammad Rafi
@methods                 : saveTheChunkFile
@Descritption            : This method used to insert file in chuck,when fileIf will be blank then saveFiles method will call
other appendToFile call and it will return file ID.      
*/
    @AuraEnabled                         
    public static Id saveTheChunkFile(String fileName, String base64Data,String fileId){
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        if (String.isBlank(fileId)) {
            fileId = saveFiles(fileName, base64Data);
        }else {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
    
    public static String saveFiles(String fileName, String base64Data)  { 
        ContentVersion cvObj = new ContentVersion(); 
        cvObj.ContentLocation = 'S';
        cvObj.Title = fileName; 
        cvObj.VersionData = EncodingUtil.base64Decode(base64Data);
        cvObj.PathOnClient = '/' + fileName ;
        cvObj.IsMajorVersion = false;
        
        system.debug('cvObj'+cvObj);
        insert cvObj; 
        return cvObj.Id;
    }
    
    public static void appendToFile(String conDocuementId, String base64Data) {
        ContentVersion cvObj = [SELECT Id,IsMajorVersion ,VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: conDocuementId];
        String existingFileContent = EncodingUtil.base64Encode(cvObj.VersionData);
        cvObj.VersionData = EncodingUtil.base64Decode(existingFileContent + base64Data); 
        update cvObj;   
    }
    
    /*	@Description
Method Name : getContentOwnerName
Written by	: Mahendra
Purpose		: to get the user name based on the given user id so that we can fetch the content owner name to be displayed in the content management component while updating the article

@PARAMS
1. UserId that was selected as content owner in the cms tool
*/
    @AuraEnabled
    public static String getContentOwnerName(String contentOwnerId){
        User contentOwner = [SELECT Name FROM User WHERE Id=: contentOwnerId];
        if(contentOwner != null){
            return contentOwner.Name;
        }
        return '';
    }
    
    /* B2B-325 */
    @AuraEnabled
    public static Map<String, Object> getH5AndH1Accounts(List<Id> tileIds) {
        
        List<Account> existingH5Accounts = new List<Account>();
        List<Account> existingH1Accounts = new List<Account>();
        List<String> existingH5AccountsNames = new List<String>();
        List<String> existingH1AccountsNames = new List<String>();
        
        List<Tile_Account__c> tileAccountRecords = [
            SELECT Id, Account__c, Account__r.ParentId, Account__r.Name
            FROM Tile_Account__c 
            WHERE Tile__r.Id IN :tileIds
        ];
        for (Tile_Account__c tileAccounts : tileAccountRecords) {
            if (tileAccounts.Account__r.ParentId != null) {
                existingH5Accounts.add(tileAccounts.Account__r);
                existingH5AccountsNames.add(tileAccounts.Account__r.Name);
            } else {
                existingH1Accounts.add(tileAccounts.Account__r);
                existingH1AccountsNames.add(tileAccounts.Account__r.Name);
            }
        }
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('existingH5Accounts', existingH5Accounts);
        resultMap.put('selectedH5AccountsNames', existingH5AccountsNames);
        resultMap.put('existingH1Accounts', existingH1Accounts);
        resultMap.put('selectedH1AccountsNames', existingH1AccountsNames);
        
        return resultMap;
    }
    
    //B2B-325
    @AuraEnabled
    public static void updateTileAccounts(Id tileId, List<Id> accountsToDelete, List<Id> accountsToInsert) {
        // Delete Tile_Account__c records
        if (!accountsToDelete.isEmpty()) {
            List<Tile_Account__c> recordsToDelete = [
                SELECT Id FROM Tile_Account__c 
                WHERE Tile__c = :tileId AND Account__c IN :accountsToDelete
            ];
            system.debug('recordsToDelete=->'+recordsToDelete);
            try {
                delete recordsToDelete;
            } catch (Exception e) {
                throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
            }
        }
        system.debug('accountsToInsert=->'+accountsToInsert);
        // Insert new Tile_Account__c records
        if (!accountsToInsert.isEmpty()) {
            List<Tile_Account__c> recordsToInsert = new List<Tile_Account__c>();
            for (Id accountId : accountsToInsert) {
                Tile_Account__c newRecord = new Tile_Account__c(Tile__c = tileId, Account__c = accountId);
                recordsToInsert.add(newRecord);
            }
            system.debug('recordsToInsert--?'+recordsToInsert);
            try {
                insert recordsToInsert;
            } catch (Exception e) {
                throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
            }
        }
    }
    
    public class MyException extends Exception {}
}