/*------------------------------------------------------------  
Author:       Sibananda Bhuyan
Description:  This is the helper class used for "ContentMananagementController" class

History
14-06-2021      Sibananda Bhuyan    Created Class
19-07-2021		Mahendra Kumar		Modified Class
------------------------------------------------------------*/
public inherited sharing class ContentManagementHelper {
    

    /* @Description
        Method Name : onlyKnowledgeFields( Map<String, Object> , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. If there are updates that only do a Knowledge Article update and nothing else
        4. Changes to any one of the following field needs a knowledge update
            a. UI_Name__c, UI_Description__c, Review_End_Date__c, Business_Segment__c, Sub_Segment__c, Sales_Region__c
        5. This is done because unnecessary changes should not update knowledge because it requires a new knowledge version to be published

        @PARAMS
            1. NAME ( tileObj )             	=> TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( existingArticleId )   	=> TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            3. NAME ( knowledgeURL )        	=> TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
			4. NAME ( selectedContentOwnerId )	=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void onlyKnowledgeFields( Map<String, Object> tileObj, String existingArticleId, String knowledgeURL, String selectedContentOwnerId ){

        Knowledge__kav newPublishedArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, '', selectedContentOwnerId);
        updateTilesWithNewArticle( tileObj, existingArticleId, newPublishedArticle, '' );
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        ContentVersion conVer = getExistingContentVersion(String.valueOf(tileObj.get('File_ContentDocumentId__c')));
        if(conVer != null && conVer.OwnerId != selectedContentOwnerId){
            updateFileOwner(conVer.Id, selectedContentOwnerId);
        }
        
    }

    /* @Description
        Method Name : onlyContentPaths( String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. If only a content path is changed during update and nothing has changed
        4. This is done because unnecessary changes should not update knowledge because it requires a new knowledge version to be published

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( contentPathLocationList )     => TYPE ( String )              => DESCRIPTION ( ContentLocationWrapper list from ContentManagement Class )
            3. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            4. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
    */
    public static void onlyContentPaths( Map<String,Object> tileObj, String contentPathLocationList, String existingArticleId, String oldFileContentDocumentId ){

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, existingArticleId, oldFileContentDocumentId );
    }

    /* @Description
        Method Name : onlyLibraryPaths( Map<String,Object> , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. If only a Library path is changed during update and nothing has changed
        4. This is done because unnecessary changes should not update knowledge because it requires a new knowledge version to be published

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            3. NAME ( knowledgeURL )                => TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
            4. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
            5. NAME ( contentLibraryLocationList )  => TYPE ( String )              => DESCRIPTION ( The new Library locations selected by user during content update )
			6. NAME ( selectedContentOwnerId )		=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void onlyLibraryPaths( Map<String,Object> tileObj, String existingArticleId, String knowledgeURL, String oldfileContentDocumentId, String contentLibraryLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = cloneOldContentVersionAndAssociateToLibraries( oldfileContentDocumentId, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];
        system.debug('contentVersion==>'+contentVersion);

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, contentVersion.Title), selectedContentOwnerId );
		system.debug('newArticle==>'+newArticle);
        updateTilesWithNewArticle( tileObj, existingArticleId, newArticle, newfileContentDocumentId );
        
		//delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];
    }

    /* @Description
        Method Name : onlyNewFileChosen( Map<String,Object> , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. If only a new file is chosen during update and nothing has changed
        4. This is done because unnecessary changes should not update knowledge because it requires a new knowledge version to be published

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
            3. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            4. NAME ( base64Data )                  => TYPE ( String )              => DESCRIPTION ( The based64 converted file data. This is basically file data from the chosen file by user )
            5. NAME ( fileName )                    => TYPE ( String )              => DESCRIPTION ( The file name of the new file selected by user )
            6. NAME ( knowledgeURL )                => TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
            7. NAME ( contentLibraryLocationList )  => TYPE ( String )              => DESCRIPTION ( The new Library locations selected by user during content update )
			8. NAME ( selectedContentOwnerId )		=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void onlyNewFileChosen( Map<String, Object> tileObj, String oldfileContentDocumentId, String existingArticleId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String selectedContentOwnerId ){

        //base64Data
        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries(contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId);
       // String newfileContentDocumentId =base64Data;

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        updateTilesWithNewArticle( tileObj, existingArticleId, newArticle, newfileContentDocumentId );

        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    /* @Description
        Method Name : knowledgeFields_contentPaths( Map<String,Object> , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. This method is called if there are 2 changes
            a. Any of the knowledge fields are changed meaning any change which required Knowledge republish
            b. Any change in the content path meaning the change in location's visibility of the article
        4. Changes to any one of the following field needs a knowledge update
            a. UI_Name__c, UI_Description__c, Review_End_Date__c, Business_Segment__c, Sub_Segment__c, Sales_Region__c

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            3. NAME ( knowledgeURL )                => TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
            4. NAME ( contentPathLocationList )     => TYPE ( String )              => DESCRIPTION ( ContentLocationWrapper list from ContentManagement Class )
			5. NAME ( selectedContentOwnerId )		=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void knowledgeFields_contentPaths( Map<String, Object> tileObj, String existingArticleId, String knowledgeURL, String contentPathLocationList, String selectedContentOwnerId ){

        Knowledge__kav newPublishedArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, '', selectedContentOwnerId );

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, newPublishedArticle.Id , '' );
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        ContentVersion conVer = getExistingContentVersion(String.valueOf(tileObj.get('File_ContentDocumentId__c')));
        if(conVer != null && conVer.OwnerId != selectedContentOwnerId){
            updateFileOwner(conVer.Id, selectedContentOwnerId);
        }
    }

    /* @Description
        Method Name : knowledgeFields_libraryPaths( Map<String,Object> , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. This method is called if there are 2 changes
            a. Any of the knowledge fields are changed meaning any change which required Knowledge republish
            b. Any change in the Library path meaning the change in file's location in library
        4. Changes to any one of the following field needs a knowledge update
            a. UI_Name__c, UI_Description__c, Review_End_Date__c, Business_Segment__c, Sub_Segment__c, Sales_Region__c

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            3. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
            4. NAME ( contentLibraryLocationList )  => TYPE ( String )              => DESCRIPTION ( The new Library locations selected by user during content update )
            5. NAME ( knowledgeURL )                => TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
			6. NAME ( selectedContentOwnerId )		=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void knowledgeFields_libraryPaths( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String contentLibraryLocationList, String knowledgeURL, String selectedContentOwnerId ){

        String newfileContentDocumentId = cloneOldContentVersionAndAssociateToLibraries( oldfileContentDocumentId, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newPublishedArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL( contentVersion.Id, contentVersion.Title ), selectedContentOwnerId );

        updateTilesWithNewArticle( tileObj, existingArticleId, newPublishedArticle, newfileContentDocumentId );
        
        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*ContentVersion conVer = getExistingContentVersion(String.valueOf(tileObj.get('File_ContentDocumentId__c')));
        if(conVer != null && conVer.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    /* @Description
        Method Name : knowledgeFields_newFileChosen( Map<String,Object> , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. This method is called if there are 2 changes
            a. Any of the knowledge fields are changed meaning any change which required Knowledge republish
            b. A new file is chosen to replace the existing article
        4. Changes to any one of the following field needs a knowledge update
            a. UI_Name__c, UI_Description__c, Review_End_Date__c, Business_Segment__c, Sub_Segment__c, Sales_Region__c

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            3. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
            4. NAME ( base64Data )                  => TYPE ( String )              => DESCRIPTION ( The based64 converted file data. This is basically file data from the chosen file by user )
            5. NAME ( fileName )                    => TYPE ( String )              => DESCRIPTION ( The file name of the new file selected by user )
            6. NAME ( contentLibraryLocationList )  => TYPE ( String )              => DESCRIPTION ( The new Library locations selected by user during content update )
            7. NAME ( knowledgeURL )                => TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
			8. NAME ( selectedContentOwnerId )		=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void knowledgeFields_newFileChosen( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries( contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        updateTilesWithNewArticle( tileObj, existingArticleId, newArticle, newfileContentDocumentId );
        
        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    /* @Description
        Method Name : contentPaths_libraryPaths( Map<String,Object> , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. This method is called if there are 2 changes
            a. Any change in the content path meaning the change in location's visibility of the article
            b. Any change in the Library path meaning the change in file's location in library

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
            3. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            4. NAME ( contentLibraryLocationList )  => TYPE ( String )              => DESCRIPTION ( The new Library locations selected by user during content update )
            5. NAME ( contentPathLocationList )     => TYPE ( String )              => DESCRIPTION ( ContentLocationWrapper list from ContentManagement Class )
    */
    public static void contentPaths_libraryPaths( Map<String,Object> tileObj, String oldfileContentDocumentId, String existingArticleId, String contentLibraryLocationList, String contentPathLocationList ){

        String newfileContentDocumentId = cloneOldContentVersionAndAssociateToLibraries( oldfileContentDocumentId, contentLibraryLocationList, '' );

        ContentVersion newContentVersion = [SELECT Id, VersionData, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, existingArticleId, newContentVersion.ContentDocumentId );

        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];
    }

    /* @Description
        Method Name : contentPaths_newFileChosen( Map<String,Object> , String , String , String , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. This method is called if there are 2 changes
            a. Any change in the content path meaning the change in location's visibility of the article
            b. A new file is chosen to replace the existing article

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            3. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
            4. NAME ( base64Data )                  => TYPE ( String )              => DESCRIPTION ( The based64 converted file data. This is basically file data from the chosen file by user )
            5. NAME ( fileName )                    => TYPE ( String )              => DESCRIPTION ( The file name of the new file selected by user )
            6. NAME ( knowledgeURL )                => TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
            7. NAME ( contentLibraryLocationList )  => TYPE ( String )              => DESCRIPTION ( The new Library locations selected by user during content update )
            8. NAME ( contentPathLocationList )     => TYPE ( String )              => DESCRIPTION ( ContentLocationWrapper list from ContentManagement Class )
			9. NAME ( selectedContentOwnerId )		=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void contentPaths_newFileChosen( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String contentPathLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries(contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, newArticle.Id, newfileContentDocumentId );

        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    /* @Description
        Method Name : libraryPaths_newFileChosen( Map<String,Object> , String , String , String , String , String , String )

        1. One of the method called on Update
        2. Called from "saveEditedArticleData" method on ContentManagementController.
        3. This method is called if there are 2 changes
            a. Any change in the Library path meaning the change in file's location in library
            b. A new file is chosen to replace the existing article

        @PARAMS
            1. NAME ( tileObj )                     => TYPE ( Map<String, Object> ) => DESCRIPTION ( The tile's "FieldAPIName -> FieldValue" Map passed from Component )
            2. NAME ( existingArticleId )           => TYPE ( String )              => DESCRIPTION ( The knowledge article Id associated with the Tile, this represents the old Id before new article is mapped to tile )
            3. NAME ( oldFileContentDocumentId )    => TYPE ( String )              => DESCRIPTION ( ContentDocumentId of the file associated with the Tile's Knowledge Article )
            4. NAME ( base64Data )                  => TYPE ( String )              => DESCRIPTION ( The based64 converted file data. This is basically file data from the chosen file by user )
            5. NAME ( fileName )                    => TYPE ( String )              => DESCRIPTION ( The file name of the new file selected by user )
            6. NAME ( knowledgeURL )                => TYPE ( String )              => DESCRIPTION ( The knowledge URL generated from the article name provided )
            7. NAME ( contentLibraryLocationList )  => TYPE ( String )              => DESCRIPTION ( The new Library locations selected by user during content update )
			8. NAME ( selectedContentOwnerId )		=> TYPE ( String )              => DESCRIPTION ( The UserId that is selected in the Content Owner field while updating the article )
    */
    public static void libraryPaths_newFileChosen( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries(contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        updateTilesWithNewArticle( tileObj, existingArticleId, newArticle, newfileContentDocumentId );

        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    //For 11th Condition of Switch statement
    public static void knowledgeFields_contentPaths_libraryPaths( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String knowledgeURL, String contentLibraryLocationList, String contentPathLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = cloneOldContentVersionAndAssociateToLibraries( oldfileContentDocumentId, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion newContentVersion = [SELECT Id, OwnerId, VersionData, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL( newContentVersion.Id, newContentVersion.Title ), selectedContentOwnerId );

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, newArticle.Id, newfileContentDocumentId );
        
        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(newContentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(newContentVersion.Id, selectedContentOwnerId);
        }*/
    }

    //For 12th Condition of Switch statement
    public static void knowledgeFields_contentPaths_newFileChosen( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String contentPathLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries(contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, newArticle.Id, newfileContentDocumentId );
        
        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    //For 13th condition of Switch statement
    public static void knowledgeFields_libraryPaths_newFileChosen( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries(contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        updateTilesWithNewArticle( tileObj, existingArticleId, newArticle, newfileContentDocumentId );

        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    //For 14th condition of Switch statement
    public static void contentPaths_libraryPaths_newFileChosen( Map<String, Object> tileObj, String existingArticleId, String oldfileContentDocumentId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String contentPathLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries(contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, newArticle.Id, newfileContentDocumentId );
		
        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    //For 15th condition of Switch statement
    public static void knowledgeFields_contentPaths_libraryPaths_newFileChosen( Map<String, Object> tileObj, STring existingArticleId, String oldfileContentDocumentId, String contentVersionId, String fileName, String knowledgeURL, String contentLibraryLocationList, String contentPathLocationList, String selectedContentOwnerId ){

        String newfileContentDocumentId = insertContentVersionAndAssociateToLibraries(contentVersionId, fileName, contentLibraryLocationList, selectedContentOwnerId );

        ContentVersion contentVersion = [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: newfileContentDocumentId];

        Knowledge__kav newArticle = publishNewKnowledgeArticle( tileObj, existingArticleId, knowledgeURL, getFilePublicURL(contentVersion.Id, fileName), selectedContentOwnerId );

        createNewTileStructureOnUpdate( tileObj, contentPathLocationList, existingArticleId, newArticle.Id, newfileContentDocumentId );

        //delete [SELECT Id FROM ContentDocument WHERE Id =: oldfileContentDocumentId];

            delete new ContentDocument(Id = oldfileContentDocumentId);
        
        //ENH-4370 - Update file owner if the Content Owner is changed while Updating the knowledge Article from CMS Tool (Content Management Tab)
        /*if(contentVersion.OwnerId != selectedContentOwnerId){
            updateFileOwner(contentVersion.Id, selectedContentOwnerId);
        }*/
    }

    public static Knowledge__kav publishNewKnowledgeArticle(Map<String, Object> tileObj, String existingArticleId, String knowledgeURL, String filepublicURL, String selectedContentOwnerId){

        Knowledge__kav currentOnlineKnowledgeArt = [SELECT KnowledgeArticleId, Article_Details__c FROM Knowledge__kav WHERE Id =: existingArticleId];

        String draftarticleId = unPublishArticle(currentOnlineKnowledgeArt.KnowledgeArticleId);

        Knowledge__kav newArticle = KnowledgeArticleUtility.createNewArticleAsADraft(

                String.valueOf(tileObj.get('UI_Name__c')),
                knowledgeURL,
                true,
                ContentManagementController.KNOWLEDGE_COMMUNITY_ARTICLE_RECORD_TYPE_ID,
                String.valueOf(tileObj.get('Business_Segment__c')),
                String.valueOf(tileObj.get('Sub_Segment__c')),
                String.valueOf(tileObj.get('Sales_Region__c')),
                //UserInfo.getUserId(),
                selectedContentOwnerId,//ENH-4370
                //String.valueOf(tileObjNameValueMap.get('Review_End_Date__c')) != null ? String.valueOf(tileObjNameValueMap.get('Review_End_Date__c')) : '',
                Date.valueOf(String.valueOf(tileObj.get('Review_End_Date__c'))),
                false,
                true,
                true,
                (!String.isBlank(filepublicURL)) ? getArticleDetailsIframeURL(filepublicURL) : currentOnlineKnowledgeArt.Article_Details__c,
                String.valueOf(tileObj.get('UI_Description__c'))
            );
        
        Knowledge__kav knowledgeV = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE KnowledgeArticleId =: draftarticleId];

        newArticle.Id = knowledgeV.Id;
        update newArticle;

        KnowledgeArticleUtility.publishArticle(knowledgeV.KnowledgeArticleId);

        return newArticle;
    }

    private static String cloneOldContentVersionAndAssociateToLibraries( String oldfileContentDocumentId, String contentLibraryLocationList, String selectedOwnerId ){

        ContentVersion oldContentVersion = [SELECT Id, VersionData, Title FROM ContentVersion WHERE ContentDocumentId =: oldfileContentDocumentId];

       // return insertContentVersionAndAssociateToLibraries1( oldContentVersion.VersionData, oldContentVersion.Title, contentLibraryLocationList );
       return insertContentVersionAndAssociateToLibraries( oldContentVersion.Id, oldContentVersion.Title, contentLibraryLocationList, selectedOwnerId );
    }

    private static String insertContentVersionAndAssociateToLibraries(String contentVersionId, String fileName, String contentLibraryLocationList, String selectedOwnerId ){

      //  ContentVersion conVer = getContentVersionToInsert(contentVersionId, fileName );
      ///  insert conVer;

        ContentVersion newContentVersionData = [SELECT Id, VersionData, OwnerId FROM ContentVersion WHERE Id =: contentVersionId];

        String newfileContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersionId].ContentDocumentId;

        associateFileInLibraries( newfileContentDocumentId, contentLibraryLocationList, selectedOwnerId, contentVersionId, newContentVersionData.OwnerId);

        return newfileContentDocumentId;
    }

    

    /*public static void callassociateFileInLibraries( String contentDocumentId, String contentLibraryLocationList ){

        if(Test.isRunningTest()) associateFileInLibraries( contentDocumentId, contentLibraryLocationList );
        else associateFileInLibrariesfuture( contentDocumentId, contentLibraryLocationList );
    }

    @future
    public static void associateFileInLibrariesfuture( String contentDocumentId, String contentLibraryLocationList ){

        associateFileInLibraries( contentDocumentId, contentLibraryLocationList );
    }*/
    
    @future
    public static void associateFileInLibraries(String contentDocumentId, String contentLibraryLocationList, String selectedOwnerId, String contentVersionId, String existingOwnerId){
       
        Map<Id,List<Id>> libraryRCFfolderSetMap = new Map<Id,List<Id>>();
        Map<Id,Id> folderLibraryRCFIdMap = new Map<Id,Id>();
        Map<Id,Id> rootContentFolderLibraryId = new Map<Id,Id>();
        List<ContentDocumentLink> contDocList = new List<ContentDocumentLink>();

        List<ContentManagementController.ContentLibraryWrapper> contentVWList = (List<ContentManagementController.ContentLibraryWrapper>)JSON.deserialize(contentLibraryLocationList, List<ContentManagementController.ContentLibraryWrapper>.CLASS);

        for(ContentManagementController.ContentLibraryWrapper eachContVisWrap : contentVWList){

            if(!libraryRCFfolderSetMap.containsKey(eachContVisWrap.SelectedFolderLibraryId.split('-')[1])){

                libraryRCFfolderSetMap.put(eachContVisWrap.SelectedFolderLibraryId.split('-')[1], new List<Id>());
            }
            libraryRCFfolderSetMap.get(eachContVisWrap.SelectedFolderLibraryId.split('-')[1]).add(eachContVisWrap.SelectedFolderLibraryId.split('-')[0]);
            folderLibraryRCFIdMap.put(eachContVisWrap.SelectedFolderLibraryId.split('-')[0], eachContVisWrap.SelectedFolderLibraryId.split('-')[1]);
        }

        List<ContentWorkSpace> contentWSpaceList = [SELECT Id,RootContentFolderId FROM ContentWorkSpace WHERE RootContentFolderId =: libraryRCFfolderSetMap.keySet()];
        for(ContentWorkSpace eachContentWSp : contentWSpaceList){

            rootContentFolderLibraryId.put(eachContentWSp.RootContentFolderId, eachContentWSp.Id);
        }
        for(Id eachFolderId : folderLibraryRCFIdMap.keySet()){
            contDocList.add(new ContentDocumentLink(
                    ContentDocumentId   = contentDocumentId,
                    LinkedEntityId      = rootContentFolderLibraryId.get(folderLibraryRCFIdMap.get(eachFolderId)), // This is the library Id
                    ShareType           = 'I',              // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    Visibility          = 'AllUsers'        // AllUsers, InternalUsers, SharedUsers
            ));
        }
 
        insert contDocList;       

        List<ContentFolderMember> contFolderList = [SELECT Id,ParentContentFolderId,ChildRecordId FROM ContentFolderMember 
                                            WHERE ChildRecordId =: contentDocumentId
                                            AND ParentContentFolderId =: libraryRCFfolderSetMap.keySet()];
        
        for(ContentFolderMember eachContMember : contFolderList){

            for(Id eachFolderId : libraryRCFfolderSetMap.get(eachContMember.ParentContentFolderId)){

                eachContMember.ParentContentFolderId = eachFolderId;
            }
        }

        update contFolderList;
        
        if(existingOwnerId != selectedOwnerId){
            updateFileOwner(contentVersionId, selectedOwnerId);
        }

        /*for(Id eachFolderId : folderLibraryRCFIdMap.keySet()){

            ContentDocumentLink contDocLink = new ContentDocumentLink(
                    ContentDocumentId   = contentDocumentId,
                    LinkedEntityId      = rootContentFolderLibraryId.get(folderLibraryRCFIdMap.get(eachFolderId)), // This is the library Id
                    ShareType           = 'I',              // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    Visibility          = 'AllUsers'        // AllUsers, InternalUsers, SharedUsers
            );

            insert contDocLink;

            ContentFolderMember eachContentFolderMember = [SELECT Id, ParentContentFolderId, ChildRecordId FROM ContentFolderMember WHERE ChildRecordId =: contDocLink.contentDocumentId];
            Id eachChosenFolderId = libraryRCFfolderSetMap.get(eachContentFolderMember.ParentContentFolderId).get(0);

            Integer eachChosenFolderIdIndex = libraryRCFfolderSetMap.get(eachContentFolderMember.ParentContentFolderId).indexOf(eachChosenFolderId);
            libraryRCFfolderSetMap.get(eachContentFolderMember.ParentContentFolderId).remove(eachChosenFolderIdIndex);

            eachContentFolderMember.ParentContentFolderId = eachChosenFolderId;
            update eachContentFolderMember;

            System.debug(' --> '+libraryRCFfolderSetMap.get(eachContentFolderMember.ParentContentFolderId));
        }*/
        
    }

    public static ContentVersion getContentVersionToInsert(Blob base64Data,String fileName){

       //  base64Data = EncodingUtil.urlDecode(String.valueOf(base64Data), 'UTF-8');

        ContentVersion conVer   = new ContentVersion(
                        ContentLocation = 'S',          // to use S specify this document is in Salesforce, to use E for external files
                        PathOnClient    = fileName,     // The files name, extension is very important here which will help the file in preview.
                        Title           = fileName,     // Display name of the files
                        versionData     = base64Data,  // Body/Content of the File
                        IsMajorVersion = false  
                );

        return conVer;
    }

    public static void createNewTileStructureOnUpdate( Map<String,Object> tileObj, String contentPathLocationList, String existingArticleId, String knowledgeArticleId, String fileContentDocumentId ){
		System.debug('####Tile'+tileObj);
        List<ContentManagementController.ContentLocationWrapper> contentLWList = (List<ContentManagementController.ContentLocationWrapper>)JSON.deserialize(contentPathLocationList, List<ContentManagementController.ContentLocationWrapper>.CLASS);
        List<Tile__c> parentTiles = new List<Tile__c>();
        List<Tile__c> tiles = getTileWithRelatedTiles(existingArticleId);
        List<Related_Tile__c> relatedTilesToInsert = new List<Related_Tile__c>();

        if(!tiles.isEmpty()){

            Tile__c tileToClone = tiles.get(0).clone(false, true, false, false);
            List<Related_Tile__c> relatedTilesToClone = tileToClone.Related_Tiles__r;
            delete tiles;

            for(ContentManagementController.ContentLocationWrapper eachContentLocWrap : contentLWList){

                if(!String.isBlank(eachContentLocWrap.SelectedTileId)){

                    Tile__c clonedTile = tileToClone.clone(false, true, false, false);
                    //clonedTile.Name = tileToClone.UI_Name__c;
                    //clonedTile.UI_Name__c = String.valueOf(tileObj.get('UI_Name__c'));
                    for(String eachField : getFieldsToUpdate()){

                        if(eachField != 'Review_End_Date__c') clonedTile.put( eachField, String.valueOf(tileObj.get(eachField)) );
                        else clonedTile.put( eachField, Date.valueOf(String.valueOf(tileObj.get('Review_End_Date__c'))) );
                    }

                    clonedTile.Name = String.valueOf(tileObj.get('UI_Name__c'));
                    clonedTile.Parent_Tile__c = eachContentLocWrap.SelectedTileId;
                    clonedTile.Article_Name__c = knowledgeArticleId;
                    clonedTile.RecordTypeId = ContentManagementController.TILE_GLOBAL_RECORD_TYPE_ID;
                    if(!String.isBlank(fileContentDocumentId)) {
                        clonedTile.File_ContentDocumentId__c = fileContentDocumentId;
                    }else{
                        clonedTile.File_ContentDocumentId__c = tileToClone.File_ContentDocumentId__c;
                    }

                    String contentOwnerId = String.valueOf(tileObj.get('OwnerId'));
                    if(String.isNotBlank(contentOwnerId) && clonedTile.OwnerId != contentOwnerId){
                        clonedTile.OwnerId = contentOwnerId;
                    }
                    
                    parentTiles.add(clonedTile);

                }
            }
            try{
        	insert parentTiles;
            }catch (Exception e) {
                throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
            }
            for(Tile__c eachNewParentTile : parentTiles){

                for(Related_Tile__c eachRelatedTile : relatedTilesToClone){

                    Related_Tile__c clonedRelatedTile = eachRelatedTile.clone(false, true, false, false);
                    clonedRelatedTile.Tile__c = eachNewParentTile.Id;
                    relatedTilesToInsert.add(clonedRelatedTile);
                }
            }
			try{
        	insert relatedTilesToInsert;
            }catch (Exception e) {
                throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
            }
        }
    }

    public static void updateTilesWithNewArticle( Map<String,Object> tileObj, String existingArticleId, Knowledge__kav newArticle, String newContentDocId ){

        List<Tile__c> tiles = getTileWithRelatedTiles(existingArticleId);

        if(!tiles.isEmpty()){

            for(Tile__c eachTile : tiles){

                for(String eachField : getFieldsToUpdate()){

                    if(eachField != 'Review_End_Date__c') eachTile.put( eachField, String.valueOf(tileObj.get(eachField)) );
                    else eachTile.put( eachField, Date.valueOf(String.valueOf(tileObj.get('Review_End_Date__c'))) );
                }
                eachTile.put( 'Name', String.valueOf(tileObj.get('UI_Name__c')) );
                eachTile.Article_Name__c = newArticle.Id;
                if(!String.isBlank(newContentDocId)) eachTile.File_ContentDocumentId__c = newContentDocId;
                if(newArticle.OwnerId != eachTile.OwnerId){ eachTile.OwnerId = newArticle.OwnerId; }
            }
            system.debug('tiles = '+ tiles);
			try{
        	update tiles;
            }catch (DmlException e) {
                system.debug('#####tiles = '+ tiles);
                throw new MyException(e.getMessage().substringBeforeLast(':').substringBeforeLast(':').substringAfter(';'));
            }
                
            }  
    }

    public static List<Tile__c> getTileWithRelatedTiles(String existingArticleId){
        
        return [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, Review_End_Date__c, Business_Segment__c, Sub_Segment__c, Community_Name__c, Sales_Region__c, File_ContentDocumentId__c, OwnerId,
                (SELECT Id, Related_Tile__c, Tile__c FROM Related_Tiles__r)
                FROM Tile__c
                WHERE Article_Name__c =: existingArticleId];
    }

    public static String getFilePublicURL(Id contentVerId, String fileName){

        ContentDistribution contentdist = new ContentDistribution(

                Name                            = fileName,
                ContentVersionId                = contentVerId,
                PreferencesAllowViewInBrowser   = true,
                PreferencesLinkLatestVersion    = true,
                PreferencesNotifyOnVisit        = false,
                PreferencesPasswordRequired     = false,
                PreferencesAllowOriginalDownload= true
            );
		try{
        	insert contentdist;
            }catch (Exception e) {
                throw new MyException(e.getMessage().substringBeforeLast(':').substringAfter(';'));
            }
        return [select DistributionPublicUrl from ContentDistribution where ContentVersionId =: contentVerId].DistributionPublicUrl;

    }

    public static String unPublishArticle(String articleId){

        String newArticleId = KbManagement.PublishingService.editOnlineArticle(articleId, true); 
        return [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticleId].KnowledgeArticleId;
    }

    public static String getArticleDetailsIframeURL(String filepublicURL){

        return '<iframe frameborder="1" scrolling="auto" height="550px" src="'+ filepublicURL +'" width="100%"></iframe>';
    }

    public static List<String> getFieldsToUpdate(){

        return new List<String>{
            'UI_Name__c',
            'UI_Description__c',
            'Review_End_Date__c',
            'Business_Segment__c',
            'Sub_Segment__c',
            'Sales_Region__c',
            'Work_Location__c',
            'Parent_Account__c',
            'Community_Name__c'
        };
    }
    
    /*
     * @Description
     * Method Name : getExistingContentVersion
     * Return Type : ContentVersion
     * Written By  : Mahendra
       1. Get the latest version of the file based on the File Content DocumentId stored in the tile record
	   JIRA Ticket - ENH-4370
	 * @PARAMS
	   		1. NAME ( fileContentDocId )	=> TYPE ( String )	=> DESCRIPTION ( Content Document Id stored in the File content document id field of the Tile record )
	*/
    private static ContentVersion getExistingContentVersion(String fileContentDocId){
        System.debug('###fileContentDocId:'+fileContentDocId);
        System.debug('###fileContentDocIdisNotBlank:'+String.isNotBlank(fileContentDocId));
        if(String.isNotBlank(fileContentDocId)){
            return [SELECT Id, OwnerId FROM ContentVersion WHERE ContentDocumentId =: fileContentDocId AND IsLatest = true];
        }
        System.debug('###else:');
        return null;
    }
    
    /*
     * @Description
     * Method Name : updateFileOwner
     * Written By  : Mahendra
       1. Update the owner of the File when the owner of the knowledge article is updated from the CMS tool (Content Management Tab)
	   JIRA Ticket - ENH-4370
	 * @PARAMS
	   		1. NAME ( contentVersionId )	=> TYPE ( String )	=> DESCRIPTION ( Id of the existing ContentVersion (file that is embedded in the knowledge article) on which the owner should be updated )
			2. NAME ( contentOwnerId )		=> TYPE ( String )	=> DESCRIPTION ( UserId that is selected (while updating the knowledge article) in the Content owner field in the CMS Tool (Content Management Tab) )
	*/
    private static void updateFileOwner(String contentVersionId, String contentOwnerId){
        ContentVersion conVer = new ContentVersion(
        	Id = contentVersionId,
            OwnerId = contentOwnerId
        );
        update conVer;
    }
    public class MyException extends Exception {}
}