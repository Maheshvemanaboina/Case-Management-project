/*------------------------------------------------------------  
Author:       Praneeth Krishna
Description:  This is the Test class for "SendNotificationToPortalUsersTest"

------------------------------------------------------------*/
@isTest
public class SendNotificationToPortalUsersTest {
    
    @testSetup
    static void setupData(){

        String CONTENT_MANAGEMENT_CONTROLLER_CLASS = 'ContentManagementController';
        TriggerHandler.skipTrigger = true;

        /* Test Data for Knowledge Update */
        
        
         Account commercialCustIMCD = TestUtility.createAccount('IMCD Holding');
         insert commercialCustIMCD;
        
        Account customerLocIMCDItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCustIMCD);
        insert customerLocIMCDItaly;
        
        Contact cItalySU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly);
        cItalySU.Business_Segment__c = 'Adult Nutrition';
        cItalySU.Sub_Segment__c = 'Active Nutrition';
        insert cItalySU;
        
        Contact cItalySU1 = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly);
        cItalySU1.Business_Segment__c = 'Adult Nutrition';
        cItalySU1.Sub_Segment__c = 'Active Nutrition';
        insert cItalySU1;
        
        User usrIMCDItalySU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDItalySU.ContactId = cItalySU.Id;
        insert usrIMCDItalySU;
        
        User usrIMCDItalySU1 = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDItalySU1.ContactId = cItalySU1.Id;
        usrIMCDItalySU1.Community_Account_Role__c = 'Sub-Segment Responsible User';
        insert usrIMCDItalySU1;

        List<Tile__c> parentTiles = new List<Tile__c>();
        Tile__c parentTileUpdate = TestUtility.createTile('Test Update Parent');
        parentTileUpdate.Review_End_Date__c = System.today();
        parentTileUpdate.Business_Segment__c = 'Adult Nutrition';
        parentTileUpdate.Sub_Segment__c = 'Active Nutrition';
        parentTileUpdate.Sales_Region__c = 'EMEA;APAC;';
        parentTileUpdate.Community_Name__c = 'FCI Distributor Community;FCI Customer Community';
        parentTiles.add(parentTileUpdate);

        Tile__c parentTile = TestUtility.createTile('Test Parent');
        parentTiles.add(parentTile);

        insert parentTiles;

        List<Tile__c> childTiles = new List<Tile__c>();
        Tile__c childTile1 = TestUtility.createTile('Test Child 1');
        childTile1.Parent_Tile__c = parentTile.Id;
        childTiles.add(childTile1);

        Tile__c childTile2 = TestUtility.createTile('Test Child 2');
        childTile2.Parent_Tile__c = parentTile.Id;
        childTiles.add(childTile2);

        Tile__c childTile3 = TestUtility.createTile('Test Child for Related Tile');
        childTiles.add(childTile3);

        //Child Tile of Parent tile Update
        Tile__c childTileUpdLevel_1 = TestUtility.createTile('Test Child for Update Level 1');
        childTileUpdLevel_1.Parent_Tile__c = parentTileUpdate.Id;
        childTiles.add(childTileUpdLevel_1);

        //Child Tile of Parent Tile Update
        Tile__c childTileUpdLevel_2 = TestUtility.createTile('Test Child for Update Level 2');
        childTileUpdLevel_2.Parent_Tile__c = parentTileUpdate.Id;
        childTiles.add(childTileUpdLevel_2);

        //Related Tile
        Tile__c relatedTileUpd_1 = TestUtility.createTile('Related Tile for Update 1');
        childTiles.add(relatedTileUpd_1);

        insert childTiles;
         //Related Tile

        //Child Tile of childTileUpdLevel_2
        Tile__c childTileUpdLevel_2_1 = TestUtility.createTile('Test Child for Update Level 2_1');
        childTileUpdLevel_2_1.Parent_Tile__c = childTileUpdLevel_2.Id;
        insert childTileUpdLevel_2_1;

        List<User> usersList = new List<User>();
        User adminUser = TestUtility.createUser('AdminUser@abc.com'+TestUtility.generateRandomString(8),'System Administrator');
        adminUser.UserPermissionsKnowledgeUser = true;
        adminUser.Disable_Listed_Triggers__c = 'SRM_ContentVersionTrigger;';
        usersList.add(adminUser);

        User user1 = TestUtility.createUser('User1@frieslandabc.com'+TestUtility.generateRandomString(8),'New FCl Lightning Users');
        user1.UserPermissionsKnowledgeUser = false;
        user1.Disable_Listed_Triggers__c = 'SRM_ContentVersionTrigger;';
        usersList.add(user1);

        User user2 = TestUtility.createUser('User2@frieslandabc.com'+TestUtility.generateRandomString(8),'New FCl Lightning Users');
        user2.UserPermissionsKnowledgeUser = true;
        user2.Disable_Listed_Triggers__c = 'SRM_ContentVersionTrigger;';
        usersList.add(user2);

        User user3 = TestUtility.createUser('User3@frieslandabc.com'+TestUtility.generateRandomString(8),'New FCl Lightning Users');
        user3.UserPermissionsKnowledgeUser = true;
        user3.Disable_Listed_Triggers__c = 'SRM_ContentVersionTrigger;';
        usersList.add(user3);

        insert usersList;

        TriggerHandler.skipTrigger = false;

        System.RunAs(adminUser){

            ContentWorkSpace contWorkSpace = new ContentWorkSpace(Name = 'Test WorkSpace',
                                                 Description = 'Test Description');
        
            insert contWorkSpace;

            contWorkSpace = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Id =: contWorkSpace.Id];

            ContentFolder contFolder = new ContentFolder(Name = 'Test Folder',
                                                        ParentContentFolderId = contWorkSpace.RootContentFolderId);
            insert contFolder;

            ContentFolder contFolder2 = new ContentFolder(Name = 'Test Folder 2',
                                                        ParentContentFolderId = contFolder.Id);
            insert contFolder2;

            List<Knowledge__kav> knowledgeList = new List<Knowledge__kav>();

            Knowledge__kav knowKav = TestUtility.createKnowledgeKav('Knowledge Article','Knowledge-Article');
            knowledgeList.add(knowKav);

            //Knowledge Article used for update
            Knowledge__kav knowledgeRelatedTile = TestUtility.createKnowledgeKav('Knowledge Related Tile','Knowledge-Related-Tile');
            knowledgeList.add(knowledgeRelatedTile);

            insert knowledgeList;

            PermissionSet manageArticlePermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Manage_Knowledge_Articles'];

            PermissionSetAssignment permAssign = new PermissionSetAssignment(
                AssigneeId      = user2.Id,
                PermissionSetId = manageArticlePermSet.Id);
            
            insert permAssign;
            
            relatedTileUpd_1.Article_Name__c = knowledgeRelatedTile.Id;
            update relatedTileUpd_1;
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text')), 'Test file Name');
            insert conVer;
            //createTileAndKnowledgeArticleForUpdate();
            /* Create Data to used for Update */

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder 2'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = childTileUpdLevel_1.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 1';

            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder 2';
            
            Test.startTest();
            ContentManagementController.createfinalKnowledgeData(

                //childTileUpdLevel_1.Id,     
                'FCI Distributor Community',
                'Knowledge Article Update under Test Child for Update Level 1',
                'Test knowledge description Test Child for Update Level 1',
                String.valueOf(Date.today()+2),
                '[{"tileKnowledgeId":"' + relatedTileUpd_1.Id + '","contentCategorySelected":"Certificate"}]',//contentCategories as blank
                new List<String>{'Industry','Adult Nutrition'},
                new List<String>{'Beverages','Food'},
                new List<String>{'EMEA','APAC'},
                'Test file Name',
                conVer.Id,
                'Knowledge-Article-Update-under-Test-Child-for-Update-Level-1',
                JSON.serialize(new List<ContentManagementController.ContentLocationWrapper>{conLocWrap}),
                JSON.serialize(new List<ContentManagementController.ContentLibraryWrapper>{conLibraryWrap}),
                '',
                '',
                user3.Id
                //folderId + '-' + libraryId,
                //'[{"businessSegmentsSelected":["Industry"],"subSegmentsSelected":["Beverages"],"salesRegionsSelected":["EMEA"],"SelectedFolderLibraryId":"'+folderId + '-' + libraryId+'","SelectedTileId":"'+childTile1.Id+'","SectionHeaderName":"Content sharing & path information ","contentStoragePath":"Recipes > Trend Report 2020 -2021","LibraryStoragePath":"Library > Industry - Community Content"}]'
            );
            Test.stopTest();
        }

    }

    





       
    @isTest
    static void shouldDeleteProperData(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){

            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text UPD')), 'Test ABCD');
            insert conVer;

            Id contentDocId = ContentManagementController.getContentDocIdFromContentVersion(conVer);

            ContentWorkSpace contWorkSpace = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'];

            insert new ContentDocumentLink(
                    ContentDocumentId   = contentDocId,
                    LinkedEntityId      = contWorkSpace.Id, // This is the library Id
                    ShareType           = 'I',              // V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    Visibility          = 'AllUsers'        // AllUsers, InternalUsers, SharedUsers
            );

            ContentFolder contFold = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder 2'];

            ContentFolderMember contFoldMemb = [SELECT Id, ParentContentFolderId,ChildRecordId FROM ContentFolderMember WHERE ChildRecordId =: contentDocId];
            contFoldMemb.ParentContentFolderId = contFold.Id;
            update contFoldMemb;

            String filepublicURL = ContentManagementHelper.getFilePublicURL(conVer.Id, 'Test ABCD');

            Knowledge__kav newArticle = KnowledgeArticleUtility.createNewArticleAsADraft(

                    'Knowledge Article Update',
                    'Knowledge-Article-Update',
                    true,
                    ContentManagementController.KNOWLEDGE_COMMUNITY_ARTICLE_RECORD_TYPE_ID,
                    'Industry',
                    'Beverages',
                    'EMEA;APAC;',
                    UserInfo.getUserId(),
                    Date.valueOf(Date.today()+2),
                    false,
                    true,
                    true,
                    ContentManagementHelper.getArticleDetailsIframeURL(filepublicURL),
                    'Test Description'
                );
            
            insert newArticle;

            Id KnowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id =: newArticle.Id].KnowledgeArticleId;

            KnowledgeArticleUtility.publishArticle(KnowledgeArticleId);

            Tile__c parentTileUpd = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                                    Business_Segment__c, Sub_Segment__c, Community_Name__c,
                                    Sales_Region__c, Article_Name__c, Review_End_Date__c FROM Tile__c WHERE Name = 'Test Update Parent'];

            Knowledge__kav knowledgeArt = [SELECT Id, Article_Details__c FROM Knowledge__kav WHERE UrlName = 'Knowledge-Article-Update'];

            parentTileUpd.Article_Name__c = knowledgeArt.Id;
            parentTileUpd.File_ContentDocumentId__c = contentDocId;
            update parentTileUpd;

            Test.startTest();
            
            ContentManagementController.deleteAllArticlesFromDB(
                new List<Id>{ ContentManagementController.getATileInfo(parentTileUpd.Id).Id }    
            );

            Test.stopTest();

            System.assertEquals(0, [SELECT Id FROM ContentDocument WHERE Id =: contentDocId].size());
            System.assertEquals(0, [SELECT Id FROM Knowledge__kav WHERE UrlName = 'Knowledge-Article-Update'].size());
            System.assertEquals(0, [SELECT Id FROM Tile__c WHERE Name = 'Test Update Parent'].size());
        }
    }
   
  
    


    private static String getTileObjJSON(Tile__c parentTileUpd, Knowledge__kav knowledgeArt){

        String tileObjJSON = '{';
        tileObjJSON += '"Name":"' + checkNull(parentTileUpd.Name) + '",';
        tileObjJSON += '"UI_Name__c":"' + checkNull(parentTileUpd.UI_Name__c) + '",';
        tileObjJSON += '"UI_Description__c":"' + checkNull(parentTileUpd.UI_Description__c) + '",';
        tileObjJSON += '"Work_Location__c":"' + checkNull(parentTileUpd.Work_Location__c) + '",';
        tileObjJSON += '"Parent_Account__c":"' + checkNull(parentTileUpd.Parent_Account__c) + '",';
        tileObjJSON += '"Review_End_Date__c":"' + checkNull(parentTileUpd.Review_End_Date__c) + '",';
        tileObjJSON += '"Business_Segment__c":"' + checkNull(parentTileUpd.Business_Segment__c) + '",';
        tileObjJSON += '"Sub_Segment__c":"' + checkNull(parentTileUpd.Sub_Segment__c) + '",';
        tileObjJSON += '"Community_Name__c":"' + checkNull(parentTileUpd.Community_Name__c) + '",';
        tileObjJSON += '"Sales_Region__c":"' + checkNull(parentTileUpd.Sales_Region__c) + '",';
        tileObjJSON += '"Article_Name__c":"' + checkNull(knowledgeArt.Id) + '",';
        tileObjJSON += '"File_ContentDocumentId__c":"' + checkNull(parentTileUpd.File_ContentDocumentId__c) + '"';
        tileObjJSON += '}';

        return tileObjJSON;
    }

    private static String checkNull(Object fieldValue){

        if(fieldValue != null) return String.valueOf(fieldValue);
        else return '';
    }
    
  
    

}