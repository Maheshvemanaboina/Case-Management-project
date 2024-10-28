/*------------------------------------------------------------  
Author:       Sibananda Bhuyan
Description:  This is the Test class for "ContentManagementController"

History
21-11-2020      Sibananda Bhuyan    Created Class
04-05-2021      Sibananda Bhuyan    Updated Class to add test method for updating contents
15-06-2021      Sibananda Bhuyan    Updated class to have test methods for new version of updating contents, each methods based on each scenario
------------------------------------------------------------*/
@isTest
public class ContentManagementControllerTest {
    
    @testSetup
    static void setupData(){

        String CONTENT_MANAGEMENT_CONTROLLER_CLASS = 'ContentManagementController';
        TriggerHandler.skipTrigger = true;

        /* Test Data for Knowledge Update */

        List<Tile__c> parentTiles = new List<Tile__c>();
        Tile__c parentTileUpdate = TestUtility.createTile('Test Update Parent');
        parentTileUpdate.Review_End_Date__c = System.today();
        parentTileUpdate.Business_Segment__c = 'Industry';
        parentTileUpdate.Sub_Segment__c = 'Beverages';
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
            List<Account> accIds = new List<Account>();
            Account acc1 = TestUtility.createAccount('H1 Account');
            acc1.BillingCity = 'Bhopal';
            acc1.BillingCountry = 'India';
            acc1.BillingPostalCode = '411098';
            acc1.BillingCountryCode = 'IN';
            Account acc2 = TestUtility.createAccount('H5 Account');
            acc2.ParentId = acc1.Id;
            accIds.add(acc1);
            accIds.add(acc2);
            insert accIds;
            
            List<Id> selectedH1Accounts = new List<Id>{ acc1.Id };
			List<Id> selectedH5Accounts = new List<Id>{ acc2.Id };
            
            Tile_Account__c tileAccount = new Tile_Account__c();
            tileAccount.Account__c = acc1.Id;
            tileAccount.Tile__c = childTiles[0].Id;
            INSERT tileAccount;
			String categoryObjArrayData = '[{"tileKnowledgeId":"' + relatedTileUpd_1.Id + '","contentCategorySelected":"Certificate"}]';                  
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
                user3.Id,
                selectedH1Accounts,selectedH5Accounts,
                categoryObjArrayData,
                'FCI Distributor Product Main Tile'                 
            );
            Test.stopTest();
        }

        /*blob blobdata =  Blob.valueOf('sample text');

        Attachment knowledgeAttachment = new Attachment(

                ParentId    = childTile1.Id,
                Body        = blobdata,
                Name        = 'Test Attachment',
                contentType = 'pdf'
            );
        
        insert knowledgeAttachment;*/
    }

    @isTest
    static void testKnowledgeUserAndInitializeContentDataAndContentTree(){

        Test.setMock(HttpCalloutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"controllerValues":{"Industry":0,"Adult Nutrition":1,"Animal Nutrition":2,"Milkpowder":3,"Early Life Nutrition & Cell Nutrition":4,"Africa":5,"Foodservice BOH - Foodservice":6,"Foodservice BOH - Global Accounts":7,"BeLux":8,"DACH Germany":9,"Greece":10,"Growth Markets - North America":11,"Growth Markets - Latin - America/Pacific":12,"Growth Markets - Future Markets Europe & B2B":13,"Growth Markets - France":14,"Growth Markets - Italy":15,"Growth Markets - Spain (incl. Canarias and Millan Vincente)":16,"Growth Markets - UK & Ireland":17,"Growth Markets - Zijerveld Int.":18,"Hungary":19,"Indonesia":20,"Middle East":21,"Netherlands - Branded NL":22,"Netherlands - OOH NL":23,"Nigeria":24,"Pakistan":25,"Philippines AMC":26,"Romania":27,"Russia":28,"Thailand":29,"Vietnam":30,"Singapore":31},"defaultValue":null,"eTag":"87b1c145f8f37ce3e36b545b5fd81200","url":"/services/data/v48.0/ui-api/object-info/Field_of_Play__c/picklist-values/01225000000bso1AAA/Market_Trends__c","values":[{"attributes":null,"label":"Market Trend A","validFor":[0,1],"value":"Market Trend A"},{"attributes":null,"label":"Market Trend B","validFor":[1,2],"value":"Market Trend B"}]}','Success',200));

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];


        ContentManagementController.ContentManagementWrapper contentWrapper;

        System.runAs(adminUser){

            Test.startTest();

            if(ContentManagementController.checkKnowledgeUser()){

                contentWrapper = ContentManagementController.initializeContentData();
            }

            Test.stopTest();
        }

        System.assertEquals(true, [SELECT UserPermissionsKnowledgeUser FROM User WHERE UserName like '%AdminUser@abc.com%'].UserPermissionsKnowledgeUser);
        System.assertEquals(12, contentWrapper.contentCategories.size());
        System.assertEquals(adminUser.FirstName + ' '+ adminUser.LastName, contentWrapper.contentOwnerName);
        
    }

    @isTest
    static void testUserWithNoKnowledgeAccess(){

        User user1 = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%user1@frieslandabc.com%'];

        
        System.runAs(user1){

            Test.startTest();

            ContentManagementController.checkKnowledgeUser();
            
            Test.stopTest();
        }        
    }

    @isTest
    static void testUserWithNoManageArticleAccess(){

        User user3 = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        
        System.runAs(user3){

            Test.startTest();

            ContentManagementController.checkKnowledgeUser();

            Test.stopTest();
        }        
    }

    @isTest
    static void testUserWithAllAccess(){

        User user2 = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User2@frieslandabc.com%'];

        System.runAs(user2){
            
            Test.startTest();

            ContentManagementController.checkKnowledgeUser();

            Test.stopTest();
        }        
    }

    @isTest
    static void getProperContentTree(){

        //Test.setMock(HttpCalloutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"controllerValues":{"Industry":0,"Adult Nutrition":1,"Animal Nutrition":2,"Milkpowder":3,"Early Life Nutrition & Cell Nutrition":4,"Africa":5,"Foodservice BOH - Foodservice":6,"Foodservice BOH - Global Accounts":7,"BeLux":8,"DACH Germany":9,"Greece":10,"Growth Markets - North America":11,"Growth Markets - Latin - America/Pacific":12,"Growth Markets - Future Markets Europe & B2B":13,"Growth Markets - France":14,"Growth Markets - Italy":15,"Growth Markets - Spain (incl. Canarias and Millan Vincente)":16,"Growth Markets - UK & Ireland":17,"Growth Markets - Zijerveld Int.":18,"Hungary":19,"Indonesia":20,"Middle East":21,"Netherlands - Branded NL":22,"Netherlands - OOH NL":23,"Nigeria":24,"Pakistan":25,"Philippines AMC":26,"Romania":27,"Russia":28,"Thailand":29,"Vietnam":30,"Singapore":31},"defaultValue":null,"eTag":"87b1c145f8f37ce3e36b545b5fd81200","url":"/services/data/v48.0/ui-api/object-info/Field_of_Play__c/picklist-values/01225000000bso1AAA/Market_Trends__c","values":[{"attributes":null,"label":"Market Trend A","validFor":[0,1],"value":"Market Trend A"},{"attributes":null,"label":"Market Trend B","validFor":[1,2],"value":"Market Trend B"}]}','Success',200));

        User adminUser = [SELECT Id FROM User WHERE UserName like '%AdminUser@abc.com%'];
        Tile__c parentTile = [SELECT Id,Name FROM Tile__c WHERE Name like '%Test Parent%'];
        Tile__c childTile1 = [SELECT Id,Name FROM Tile__c WHERE Name like '%Test Child 1%'];
        Tile__c childTile2 = [SELECT Id,Name FROM Tile__c WHERE Name like '%Test Child 2%'];

        ContentManagementController.ContentTreeWrapper contentTreeWrap;
        
        System.runAs(adminUser){

            Test.startTest();

            contentTreeWrap = ContentManagementController.getContentTree(parentTile.Name, Constants.TEST_COMMUNITY_FAKE_NAME);

            Test.stopTest();
        }

        System.assertEquals(1, contentTreeWrap.contentTree.size());
        System.assertEquals(2, contentTreeWrap.contentTree[0].items.size());
        System.assertEquals(2, contentTreeWrap.validContentMap.size());
        System.assertEquals('Test Parent > Test Child 1', contentTreeWrap.validContentMap.get(childTile1.Id));
        System.assertEquals('Test Parent > Test Child 2', contentTreeWrap.validContentMap.get(childTile2.Id));
    }

    @isTest
    static void getProperLibraryTree(){

        //Test.setMock(HttpCalloutMock.class, new HttpCallOutMockGenerator(new Map<String,String>(),'{"controllerValues":{"Industry":0,"Adult Nutrition":1,"Animal Nutrition":2,"Milkpowder":3,"Early Life Nutrition & Cell Nutrition":4,"Africa":5,"Foodservice BOH - Foodservice":6,"Foodservice BOH - Global Accounts":7,"BeLux":8,"DACH Germany":9,"Greece":10,"Growth Markets - North America":11,"Growth Markets - Latin - America/Pacific":12,"Growth Markets - Future Markets Europe & B2B":13,"Growth Markets - France":14,"Growth Markets - Italy":15,"Growth Markets - Spain (incl. Canarias and Millan Vincente)":16,"Growth Markets - UK & Ireland":17,"Growth Markets - Zijerveld Int.":18,"Hungary":19,"Indonesia":20,"Middle East":21,"Netherlands - Branded NL":22,"Netherlands - OOH NL":23,"Nigeria":24,"Pakistan":25,"Philippines AMC":26,"Romania":27,"Russia":28,"Thailand":29,"Vietnam":30,"Singapore":31},"defaultValue":null,"eTag":"87b1c145f8f37ce3e36b545b5fd81200","url":"/services/data/v48.0/ui-api/object-info/Field_of_Play__c/picklist-values/01225000000bso1AAA/Market_Trends__c","values":[{"attributes":null,"label":"Market Trend A","validFor":[0,1],"value":"Market Trend A"},{"attributes":null,"label":"Market Trend B","validFor":[1,2],"value":"Market Trend B"}]}','Success',200));

        User adminUser = [SELECT Id FROM User WHERE UserName like '%AdminUser@abc.com%'];

        ContentManagementController.LibraryTreeWrapper LibraryTreeWrap;
        
        System.runAs(adminUser){

            Test.startTest();

            LibraryTreeWrap = ContentManagementController.getLibraryTree();

            Test.stopTest();
        }
        
    }

    @isTest
    static void checkExistingTileNameDuplicacy(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        String tileDuplicateMessage;
      
        System.runAs(adminUser){

            Test.startTest();
            
            tileDuplicateMessage = ContentManagementController.checkValidationAndSendMessage('Test Child 1','');

            Test.stopTest();
        }
        
        String tileDuplicateMessageTitle = tileDuplicateMessage.split('-')[0];
        String tileDuplicateMessageError = tileDuplicateMessage.split('-')[1];

        System.assertEquals(tileDuplicateMessageTitle,'Duplicate Article');
        System.assertEquals(tileDuplicateMessageError,'Article with the same name already exists. Please give another article name');
    }

    @isTest
    static void checkDuplicateKnowledgeURL(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        String KnowledgeDuplicateMessage;

        System.runAs(adminUser){

            Test.startTest();

            KnowledgeDuplicateMessage = ContentManagementController.checkValidationAndSendMessage('ABCD','Knowledge-Article');

            Test.stopTest();
        }
        
        String KnowledgeDuplicateMessageTitle = KnowledgeDuplicateMessage.split('-')[0];
        String KnowledgeDuplicateMessageError = KnowledgeDuplicateMessage.split('-')[1];

        System.assertEquals(KnowledgeDuplicateMessageTitle,'Duplicate Knowledge URL');
        System.assertEquals(KnowledgeDuplicateMessageError,'Article with the same URL already exists. Please give another article URL by changing the article name');
    }

    @isTest
    static void checkSuccess(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        String checkSuccessMessage;

        System.runAs(adminUser){

            Test.startTest();

            ContentWorkSpace conWSP = [SELECT Id,RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'];
            checkSuccessMessage = ContentManagementController.checkValidationAndSendMessage('ABCD','Knowledge-Article-abcd');

            Test.stopTest();
        }

        System.assertEquals(checkSuccessMessage,'');
    }

    //This is with no content CategoriesList
    @isTest
    static void shouldCreateFinalKnowledgeData(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        Tile__c childTile1 = [SELECT Id,Name FROM Tile__c WHERE Name like '%Test Child 1%'];
        Tile__c testTileForRelatedTile = [SELECT Id,Name FROM Tile__c WHERE Name like '%Test Child for Related Tile%'];

        System.runAs(adminUser){

            Test.startTest();

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = childTile1.Id;
            conLocWrap.contentStoragePath = 'Recipes > Trend Report 2020 -2021';

            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Industry - Community Content';
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text')), 'Test file Name');
            insert conVer;

            List<Account> accIds = new List<Account>();
            Account acc2 = [Select Id,Name FROM Account WHERE Name='H5 Account'];
            Account acc1 = [Select Id,Name FROM Account WHERE Name='H1 Account'];
            
            List<Id> selectedH1Accounts = new List<Id>{ acc1.Id };
			List<Id> selectedH5Accounts = new List<Id>{ acc2.Id };
			String categoryObjArrayData = '[{"tileKnowledgeId":"' + testTileForRelatedTile.Id + '","contentCategorySelected":"Certificate"}]';                  

    		ContentManagementController.createfinalKnowledgeData(
    
                    //childTile1.Id,     
                    'FCI Distributor Community',
                    'Test Knowledge Article',
                    'Test knowledge description',
                    String.valueOf(Date.today()+2),
                    '[{"tileKnowledgeId":"'+ testTileForRelatedTile.Id +'","contentCategorySelected":"Certificate"}]',//contentCategories as blank
                    new List<String>{'Industry','Adult Nutrition'},
                    new List<String>{'Beverages','Food'},
                    new List<String>{'EMEA','APAC'},
                    'Test file Name',
                    conVer.Id,
                    'Test-Knowledge-Article',
                    JSON.serialize(new List<ContentManagementController.ContentLocationWrapper>{conLocWrap}),
                    JSON.serialize(new List<ContentManagementController.ContentLibraryWrapper>{conLibraryWrap}),
                    selectedContentOwner.Id,
                    selectedH1Accounts,selectedH5Accounts,
                	categoryObjArrayData,
                	'FCI Distributor Product Main Tile'
                );


            Test.stopTest();
        }

        Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id, Related_Tile__c, Tile__c FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Test Knowledge Article'];
        
        System.assertEquals(1, [SELECT Id FROM Related_Tile__c WHERE Tile__c =: newKnowledgeTile.Id].size());
        System.assertEquals('Certificate', [SELECT Id,Related_Tile_Type__c FROM Related_Tile__c WHERE Tile__c =: newKnowledgeTile.Id].Related_Tile_Type__c);
        System.assertEquals([SELECT Name FROM Tile__c WHERE Name ='Test Knowledge Article'].Id, [SELECT Id,Tile__c FROM Related_Tile__c WHERE Tile__c =: newKnowledgeTile.Id].Tile__c);
        System.assertEquals(testTileForRelatedTile.Id, [SELECT Id,Related_Tile__c FROM Related_Tile__c WHERE Tile__c =: newKnowledgeTile.Id].Related_Tile__c);
        System.assertEquals(1, [SELECT Id FROM Knowledge__kav WHERE UrlName = 'Test-Knowledge-Article'].size());
        System.assertEquals('Online', [SELECT Id,PublishStatus FROM Knowledge__kav WHERE UrlName = 'Test-Knowledge-Article'].PublishStatus);
        System.assertEquals(true, [SELECT Id,IsVisibleInCsp FROM Knowledge__kav WHERE UrlName = 'Test-Knowledge-Article'].IsVisibleInCsp);
        System.assertEquals(false, [SELECT Id,IsVisibleInPkb FROM Knowledge__kav WHERE UrlName = 'Test-Knowledge-Article'].IsVisibleInPkb);
        System.assertEquals(true, [SELECT Id,IsVisibleInPrm FROM Knowledge__kav WHERE UrlName = 'Test-Knowledge-Article'].IsVisibleInPrm);
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
   
    @isTest
    static void getProperRootTileName(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){
            
            Tile__c childTile1 = [SELECT Id, Parent_Tile__c, Parent_Tile__r.Name FROM Tile__c WHERE Name like '%Test Child 1%'];

            String parentTileName = ContentManagementController.getRootTileName(childTile1, '');

            System.assertEquals(parentTileName, 'Test Parent');
        }
    }

    /* Below Test methods are the methods for all update operations, there are 15 scenarios for which there are 15 methods */

    @isTest
    static void testonlyKnowledgeFields(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c knowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTile = [SELECT Id FROM Knowledge__kav WHERE Id =: knowledgeTile.Article_Name__c];

            String tileObjJSON = getTileObjJSON(knowledgeTile, knowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(knowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(knowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(knowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(knowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(knowledgeTile.Sales_Region__c, 'EMEA');
			
            Test.startTest();
			String categoryObjArrayData = '[{"tileKnowledgeId":"' + knowledgeArticleWithTile.Id + '","contentCategorySelected":"Certificate"}]';                  

            ContentManagementController.saveEditedArticleData(
                tileObjJSON, 
                /*(Blob.valueOf('sample text update')).toString()*/ '',
                '',
                'tile-knowledge-URL-Edited',
                '',
                '',
                'onlyKnowledgeFields',
                '',
                selectedContentOwner.Id,
                categoryObjArrayData,
                'FCI Distributor Product Main Tile'
            );

            Test.stopTest();

            Tile__c knowledgeTileUpdated = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Id =: knowledgeTile.Id];

            Knowledge__kav knowledgeArticleWithTileUpdated = [SELECT Id, UrlName FROM Knowledge__kav WHERE Id =: knowledgeTileUpdated.Article_Name__c];

            System.assertEquals('tile knowledge URL Edited', knowledgeTileUpdated.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', knowledgeTileUpdated.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', knowledgeArticleWithTileUpdated.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', knowledgeTileUpdated.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', knowledgeTileUpdated.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', knowledgeTileUpdated.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', knowledgeTileUpdated.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
        }
    }

    
    @isTest
    static void testonlyContentPaths(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c knowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTile = [SELECT Id, UrlName FROM Knowledge__kav WHERE Id =: knowledgeTile.Article_Name__c];

            Tile__c oldTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newTileToMoveArticle = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newTileToMoveArticle.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            
            Test.startTest();


            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(knowledgeTile, knowledgeArticleWithTile),
                '',
                '',
                knowledgeArticleWithTile.UrlName,
                '',
                JSON.serialize(new List<ContentManagementController.ContentLocationWrapper>{conLocWrap}),
                'onlyContentPaths',
                '',
                selectedContentOwner.Id,
                '',
                'FCI Distributor Product Main Tile'
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id, Related_Tile__c, Tile__c FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTileUpdated = [SELECT Id, UrlName FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals( 'Knowledge Article Update under Test Child for Update Level 1', newKnowledgeTile.UI_Name__c, 'UI Name should not be changed on only ContentPath change' );
            System.assertEquals( 'Knowledge Article Update under Test Child for Update Level 1', newKnowledgeTile.Name, 'Name should not be changed on only ContentPath change' );
            System.assertEquals( 'Knowledge-Article-Update-under-Test-Child-for-Update-Level-1', knowledgeArticleWithTileUpdated.UrlName, 'Knowledge URL should not be changed on only ContentPath change' );
            System.assert( oldTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newTileToMoveArticle.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newTileToMoveArticle.Name );
            System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: knowledgeTile.Id].size(), 'Old Tile is not deleted' );
        }
    }

  /*  
    @isTest
    static void testonlyLibraryPaths(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        System.runAs(adminUser){
            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];
           
            Knowledge__kav knowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];
           
            ContentVersion OldContentVersionData = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =: oldknowledgeTile.File_ContentDocumentId__c];
           
            Id folderId1    = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id folderId2    = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder 2'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;
            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            //ContentManagementController.ContentLibraryWrapper conLibraryWrap1 = new ContentManagementController.ContentLibraryWrapper();
            //conLibraryWrap1.SelectedFolderLibraryId = folderId1 + '-' + libraryId;
            //conLibraryWrap1.LibraryStoragePath = 'Library > Test Folder';
            //contentLibraryWrapList.add(conLibraryWrap1);
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap2 = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap2.SelectedFolderLibraryId = folderId2 + '-' + libraryId;
            conLibraryWrap2.LibraryStoragePath = 'Library > Test Folder 2';
            contentLibraryWrapList.add(conLibraryWrap2);
            Test.startTest();
            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(oldknowledgeTile, knowledgeArticleWithTile),
                '',
                '',
                knowledgeArticleWithTile.UrlName,
                JSON.serialize(contentLibraryWrapList),
                '',
                'onlyLibraryPaths',
                ''
            );

            Test.stopTest();

            Tile__c knowledgeTileupdated = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id, Related_Tile__c, Tile__c FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTileUpdated = [SELECT Id, UrlName, Article_Details__c FROM Knowledge__kav WHERE Id =: knowledgeTileupdated.Article_Name__c];

            ContentVersion newContentVersionData = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =: knowledgeTileupdated.File_ContentDocumentId__c];

            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: knowledgeTileupdated.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != knowledgeTileupdated.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
          
        }
    } 
  */
    
    @isTest
    static void testonlyNewFileChosen(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];
            system.debug('oldknowledgeTile'+oldknowledgeTile);
            Knowledge__kav knowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c,OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];
            system.debug('knowledgeArticleWithTile'+knowledgeArticleWithTile);
            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test file Name Update');
            insert conVer;
            
            Test.startTest();


            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(oldknowledgeTile, knowledgeArticleWithTile), //tileObj
                conVer.Id,                                                       //ContentVersionId
                'Test file Name Update',                                    //fileName
                knowledgeArticleWithTile.UrlName,                           //knowledgeURL
                JSON.serialize(contentLibraryWrapList),                     //contentLibraryLocationList
                '',                                                         //contentPathLocationList
                'onlyNewFileChosen',                                        //operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c knowledgeTileupdated = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id, Related_Tile__c, Tile__c FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTileUpdated = [SELECT Id, UrlName, Article_Details__c FROM Knowledge__kav WHERE Id =: knowledgeTileupdated.Article_Name__c];

            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: knowledgeTileupdated.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != knowledgeTileupdated.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( knowledgeArticleWithTile.Article_Details__c != knowledgeArticleWithTileUpdated.Article_Details__c, 'Article Details be updated according to new file if only new file is chosen'); 
        }
    }

    @isTest
    static void testknowledgeFields_contentPaths(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Tile__c oldTile = [SELECT Id, Name , Parent_Tile__c FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newTileToMoveArticle = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            List<ContentManagementController.ContentLocationWrapper> conLocWrapList = new List<ContentManagementController.ContentLocationWrapper>();

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newTileToMoveArticle.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            conLocWrapList.add(conLocWrap);

            String tileObjJSON = getTileObjJSON(oldknowledgeTile, knowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sales_Region__c, 'EMEA');
            
            Test.startTest();


            ContentManagementController.saveEditedArticleData(
                tileObjJSON,                    //tileObj
                '',                             //base64Data
                '',                             //fileName
                'tile-knowledge-URL-Edited',    //knowledgeURL
                '',                             //contentLibraryLocationList
                JSON.serialize(conLocWrapList), //contentPathLocationList
                'knowledgeFields_contentPaths', //operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c knowledgeTileupdated = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id, Related_Tile__c, Tile__c FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'tile knowledge URL Edited'];

            Knowledge__kav knowledgeArticleWithTileUpdated = [SELECT Id, UrlName, Article_Details__c FROM Knowledge__kav WHERE Id =: knowledgeTileupdated.Article_Name__c];

            System.assertEquals('tile knowledge URL Edited', knowledgeTileUpdated.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', knowledgeTileUpdated.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', knowledgeArticleWithTileUpdated.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', knowledgeTileUpdated.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', knowledgeTileUpdated.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', knowledgeTileUpdated.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', knowledgeTileUpdated.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
            System.assert( oldTile.Id != knowledgeTileupdated.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newTileToMoveArticle.Id == knowledgeTileupdated.Parent_Tile__c, 'New knowledge tile has not moved under '+newTileToMoveArticle.Name );
            //System.assertEquals( 1, knowledgeTileupdated.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: oldknowledgeTile.Id].size(), 'Old Tile is not deleted' );
        }
    }
/*
    @isTest
    static void testknowledgeFields_libraryPaths(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, PublishStatus FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder 2'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder 2';
            contentLibraryWrapList.add(conLibraryWrap);

            String tileObjJSON = getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sales_Region__c, 'EMEA');
            
            Test.startTest();


            ContentManagementController.saveEditedArticleData(
                tileObjJSON,                            //tileObj
                '',                                     //base64Data
                '',                                     //fileName
                'tile-knowledge-URL-Edited',            //knowledgeURL
                JSON.serialize(contentLibraryWrapList), //contentLibraryLocationList
                '',                                     //contentPathLocationList
                'knowledgeFields_libraryPaths',         //operation
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'tile knowledge URL Edited'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', newknowledgeArticleWithTile.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', newKnowledgeTile.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', newKnowledgeTile.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', newKnowledgeTile.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', newKnowledgeTile.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
            System.assert( oldknowledgeTile.Parent_Tile__c == newKnowledgeTile.Parent_Tile__c, 'Old and new updated tile are not under same parent tile, this is should happen as content path is not changed');
            System.assert( oldknowledgeTile.Id == newKnowledgeTile.Id, 'Old and new tile are not equal, they are re-created which should not happen ');
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
        }
    }
*/
    @isTest
    static void testknowledgeFields_newFileChosen(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);

            String tileObjJSON = getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sales_Region__c, 'EMEA');
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test file Name Update');
            insert conVer;
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                tileObjJSON,                                //tileObj
                conVer.Id,                                       //ContentVersionId
                'Test file Name Update',                     //fileName
                'tile-knowledge-URL-Edited',                //knowledgeURL
                JSON.serialize(contentLibraryWrapList),     //contentLibraryLocationList
                '',                                         //contentPathLocationList
                'knowledgeFields_newFileChosen',            //operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'tile knowledge URL Edited'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', newknowledgeArticleWithTile.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', newKnowledgeTile.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', newKnowledgeTile.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', newKnowledgeTile.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', newKnowledgeTile.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
            System.assert( oldknowledgeTile.Parent_Tile__c == newKnowledgeTile.Parent_Tile__c, 'Old and new updated tile are not under same parent tile, this is should happen as content path is not changed');
            System.assert( oldknowledgeTile.Id == newKnowledgeTile.Id, 'Old and new tile are not equal, they are re-created which should not happen ');
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( oldknowledgeArticleWithTile.Article_Details__c != newknowledgeArticleWithTile.Article_Details__c, 'Article Details be updated according to new file if only new file is chosen'); 
            
        }
    }
/*
    @isTest
    static void testcontentPaths_libraryPaths(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){
            
            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Tile__c oldParentTile = [SELECT Id, Name , Parent_Tile__c FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newParentTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            List<ContentManagementController.ContentLocationWrapper> conLocWrapList = new List<ContentManagementController.ContentLocationWrapper>();

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newParentTile.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            conLocWrapList.add(conLocWrap);

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);
            
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile),  //tileObj
                '',                                                             //Content Version Id
                '',                                                             //fileName
                oldknowledgeArticleWithTile.UrlName,                            //knowledgeURL
                JSON.serialize(contentLibraryWrapList),                         //contentLibraryLocationList
                JSON.serialize(conLocWrapList),                                 //contentPathLocationList
                'contentPaths_libraryPaths',                                    //operation
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals( oldknowledgeTile.UI_Name__c, newKnowledgeTile.UI_Name__c, 'UI Name is changed which should not happen');
            System.assertEquals( oldknowledgeTile.Name, newKnowledgeTile.Name, 'Name is changed which should not happen');
            System.assertEquals( oldknowledgeArticleWithTile.UrlName, newknowledgeArticleWithTile.UrlName, 'Knowledge article is updated & URL is updated');
            System.assert( oldParentTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newParentTile.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newKnowledgeTile.Name );
            System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: oldknowledgeTile.Id].size(), 'Old Tile is not deleted' );
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            
        }
    }
*/
    @isTest
    static void testcontentPaths_newFileChosen(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){
            
            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Tile__c oldParentTile = [SELECT Id, Name , Parent_Tile__c FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newParentTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            List<ContentManagementController.ContentLocationWrapper> conLocWrapList = new List<ContentManagementController.ContentLocationWrapper>();

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newParentTile.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            conLocWrapList.add(conLocWrap);

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test file Name Update');
            insert conVer;
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile),  //tileObj
                conVer.Id,                     										//ContentVersionId
                'Test file Name Update',                                        //fileName
                oldknowledgeArticleWithTile.UrlName,                            //knowledgeURL
                JSON.serialize(contentLibraryWrapList),                         //contentLibraryLocationList
                JSON.serialize(conLocWrapList),                                 //contentPathLocationList
                'contentPaths_newFileChosen',                                   //operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assert( oldknowledgeTile.Name == newKnowledgeTile.Name, 'New and old tile Name is not same');
            System.assertEquals( oldknowledgeTile.UI_Description__c, newKnowledgeTile.UI_Description__c, 'New and old tile UI Description is not same');
            System.assertEquals( oldknowledgeTile.Business_Segment__c, newKnowledgeTile.Business_Segment__c, 'New and old tile Business segment is not same');
            System.assert( oldParentTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newParentTile.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newKnowledgeTile.Name );
            //System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: oldknowledgeTile.Id].size(), 'Old Tile is not deleted' );
            System.assert( oldknowledgeTile.Article_Name__c != newKnowledgeTile.Article_Name__c, 'The new article is not updated on the tile' );
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            
        }
    }

    @isTest
    static void testlibraryPaths_newFileChosen(){
        
        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){
            
            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test file Name Update');
            insert conVer;
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile),  //tileObj
                conVer.Id,                                                      //ContentVersion
                'Test file Name Update',                                        //fileName
                oldknowledgeArticleWithTile.UrlName,                            //knowledgeURL
                JSON.serialize(contentLibraryWrapList),                         //contentLibraryLocationList
                '',                                                             //contentPathLocationList
                'libraryPaths_newFileChosen',                                   //operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assert( oldknowledgeTile.Id == newKnowledgeTile.Id, 'New tile is created which should not happen');
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( oldknowledgeTile.Article_Name__c != newKnowledgeTile.Article_Name__c, 'The new article is not updated on the tile' );

        }
    }
/*
    @isTest
    static void testknowledgeFields_contentPaths_libraryPaths(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];
            system.debug('oldknowledgeTile'+oldknowledgeTile);
            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Tile__c oldParentTile = [SELECT Id, Name , Parent_Tile__c FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newParentTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            List<ContentManagementController.ContentLocationWrapper> conLocWrapList = new List<ContentManagementController.ContentLocationWrapper>();

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newParentTile.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            conLocWrapList.add(conLocWrap);

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);

            String tileObjJSON = getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sales_Region__c, 'EMEA');
            
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                tileObjJSON,                                //tileObj
                '',                                         //base64Data
                '',                                         //fileName
                'tile-knowledge-URL-Edited',                //knowledgeURL
                JSON.serialize(contentLibraryWrapList),     //contentLibraryLocationList
                JSON.serialize(conLocWrapList),             //contentPathLocationList
                'knowledgeFields_contentPaths_libraryPaths',//operation
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'tile knowledge URL Edited'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', newknowledgeArticleWithTile.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', newKnowledgeTile.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', newKnowledgeTile.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', newKnowledgeTile.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', newKnowledgeTile.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
            System.assert( oldParentTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newParentTile.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newKnowledgeTile.Name );
            System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: oldknowledgeTile.Id].size(), 'Old Tile is not deleted' );
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( oldknowledgeTile.Article_Name__c != newKnowledgeTile.Article_Name__c, 'The new article is not updated on the tile' );
        }
    }
*/
    @isTest
    static void testknowledgeFields_contentPaths_newFileChosen(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Tile__c oldParentTile = [SELECT Id, Name , Parent_Tile__c FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newParentTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            List<ContentManagementController.ContentLocationWrapper> conLocWrapList = new List<ContentManagementController.ContentLocationWrapper>();

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newParentTile.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            conLocWrapList.add(conLocWrap);

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);

            String tileObjJSON = getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sales_Region__c, 'EMEA');
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test file name updated');
            insert conVer;
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                tileObjJSON,                                //tileObj
                conVer.Id, 									     //ContentVersionId
                'Test file name updated',                   //fileName
                'tile-knowledge-URL-Edited',                //knowledgeURL
                JSON.serialize(contentLibraryWrapList),     //contentLibraryLocationList
                JSON.serialize(conLocWrapList),             //contentPathLocationList
                'knowledgeFields_contentPaths_newFileChosen',//operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'tile knowledge URL Edited'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', newknowledgeArticleWithTile.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', newKnowledgeTile.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', newKnowledgeTile.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', newKnowledgeTile.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', newKnowledgeTile.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
            System.assert( oldParentTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newParentTile.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newKnowledgeTile.Name );
            //System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: oldknowledgeTile.Id].size(), 'Old Tile is not deleted' );
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( oldknowledgeTile.Article_Name__c != newKnowledgeTile.Article_Name__c, 'The new article is not updated on the tile' );
        }
    }

    @isTest
    static void testknowledgeFields_libraryPaths_newFileChosen(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);

            String tileObjJSON = getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sales_Region__c, 'EMEA');
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test ABCD');
            insert conVer;
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                tileObjJSON,                                //tileObj
                conVer.Id, 										//ContentVersionId
                'Test ABCD',                   //fileName
                'tile-knowledge-URL-Edited',                //knowledgeURL
                JSON.serialize(contentLibraryWrapList),     //contentLibraryLocationList
                '',                                         //contentPathLocationList
                'knowledgeFields_libraryPaths_newFileChosen',//operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                FROM Tile__c 
                WHERE Name = 'tile knowledge URL Edited'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', newknowledgeArticleWithTile.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', newKnowledgeTile.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', newKnowledgeTile.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', newKnowledgeTile.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', newKnowledgeTile.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
            System.assert( oldknowledgeTile.Parent_Tile__c == newKnowledgeTile.Parent_Tile__c, 'New & old tile location changed which should not happen as no content path is updated');
            System.assert( oldknowledgeTile.Id == newKnowledgeTile.Id, 'New & Old tile are same and is not re-created' );
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( oldknowledgeTile.Article_Name__c != newKnowledgeTile.Article_Name__c, 'The new article is not updated on the tile' );
        }
    }

    @isTest
    static void testcontentPaths_libraryPaths_newFileChosen(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Tile__c oldParentTile = [SELECT Id, Name , Parent_Tile__c FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newParentTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            List<ContentManagementController.ContentLocationWrapper> conLocWrapList = new List<ContentManagementController.ContentLocationWrapper>();

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newParentTile.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            conLocWrapList.add(conLocWrap);

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test file name updated');
            insert conVer;
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile),  //tileObj
                conVer.Id,                     								    //ContentVersionId
                'Test file name updated',                                                    //fileName
                oldknowledgeArticleWithTile.UrlName,                            //knowledgeURL
                JSON.serialize(contentLibraryWrapList),                         //contentLibraryLocationList
                JSON.serialize(conLocWrapList),                                 //contentPathLocationList
                'contentPaths_libraryPaths_newFileChosen',                      //operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assert( oldknowledgeTile.Name == newKnowledgeTile.Name, 'New and old tile Name is not same');
            System.assertEquals( oldknowledgeTile.UI_Description__c, newKnowledgeTile.UI_Description__c, 'New and old tile UI Description is not same');
            System.assertEquals( oldknowledgeTile.Business_Segment__c, newKnowledgeTile.Business_Segment__c, 'New and old tile Business segment is not same');
            System.assert( oldParentTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newParentTile.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newKnowledgeTile.Name );
            //System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            //System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: oldknowledgeTile.Id].size(), 'Old Tile is not deleted' );
            //System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            //System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            //System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( oldknowledgeTile.Article_Name__c != newKnowledgeTile.Article_Name__c, 'The new article is not updated on the tile' );
        }
    }

    @isTest
    static void testknowledgeFields_contentPaths_libraryPaths_newFileChosen(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c oldknowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
            Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
            Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav oldknowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: oldknowledgeTile.Article_Name__c];

            Tile__c oldParentTile = [SELECT Id, Name , Parent_Tile__c FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newParentTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            List<ContentManagementController.ContentLocationWrapper> conLocWrapList = new List<ContentManagementController.ContentLocationWrapper>();

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newParentTile.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            conLocWrapList.add(conLocWrap);

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            List<ContentManagementController.ContentLibraryWrapper> contentLibraryWrapList = new List<ContentManagementController.ContentLibraryWrapper>();
            
            ContentManagementController.ContentLibraryWrapper conLibraryWrap = new ContentManagementController.ContentLibraryWrapper();
            conLibraryWrap.SelectedFolderLibraryId = folderId + '-' + libraryId;
            conLibraryWrap.LibraryStoragePath = 'Library > Test Folder';
            contentLibraryWrapList.add(conLibraryWrap);

            String tileObjJSON = getTileObjJSON(oldknowledgeTile, oldknowledgeArticleWithTile);
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Name__c, 'tile knowledge URL Edited');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.UI_Description__c, 'tile knowledge URL Edited Description');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Business_Segment__c, 'Adult Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sub_Segment__c, 'Active Nutrition');
            tileObjJSON = tileObjJSON.replace(oldknowledgeTile.Sales_Region__c, 'EMEA');
            ContentVersion conVer = TestUtility.getContentVersionToInsert((Blob.valueOf('sample text U')), 'Test file name updated');
            insert conVer;
            Test.startTest();

            ContentManagementController.saveEditedArticleData(
                tileObjJSON,                                                //tileObj
                conVer.Id,                                                       //Content Version Id
                'Test file name updated',                                   //fileName
                'tile-knowledge-URL-Edited',                                //knowledgeURL
                JSON.serialize(contentLibraryWrapList),                     //contentLibraryLocationList
                JSON.serialize(conLocWrapList),                             //contentPathLocationList
                'knowledgeFields_contentPaths_libraryPaths_newFileChosen',  //operation
                '',
                selectedContentOwner.Id,
                '',
                ''
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'tile knowledge URL Edited'];

            Knowledge__kav newknowledgeArticleWithTile = [SELECT Id, UrlName, Article_Details__c, PublishStatus FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            
            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.UI_Name__c, 'UI Name is not updated after article is saved/edited');
            System.assertEquals('tile knowledge URL Edited', newKnowledgeTile.Name, 'Name is not updated/is not equal to UI Name');
            System.assertEquals('tile-knowledge-URL-Edited', newknowledgeArticleWithTile.UrlName, 'Knowledge article not updated & URL is not updated');
            System.assertEquals('tile knowledge URL Edited Description', newKnowledgeTile.UI_Description__c, 'UI Description is not updated after article is saved/edited');
            System.assertEquals('Adult Nutrition', newKnowledgeTile.Business_Segment__c, 'Business Segment is not updated after article is saved/edited');
            System.assertEquals('Active Nutrition', newKnowledgeTile.Sub_Segment__c, 'Sub-Segment is not updated after article is saved/edited');
            System.assertEquals('EMEA', newKnowledgeTile.Sales_Region__c, 'Sales Region is not updated after article is saved/edited');
            System.assert( oldParentTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newParentTile.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newKnowledgeTile.Name );
            //System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: oldknowledgeTile.Id].size(), 'Old Tile is not deleted' );
            System.assertEquals( 1, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: newKnowledgeTile.File_ContentDocumentId__c ].size(), 'New File is not present under library folders selected' );
            System.assertEquals( 0, [SELECT Id FROM ContentFolderMember WHERE ChildRecordId =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not removed from the old selected Library folders' );
            System.assertEquals( 0, [SELECT Id FROM ContentDocument WHERE Id =: oldknowledgeTile.File_ContentDocumentId__c ].size(), 'Old File is not deleted' );
            System.assert( oldknowledgeTile.File_ContentDocumentId__c != newKnowledgeTile.File_ContentDocumentId__c, 'New file contentDocumentId is not mapped in the tile record');
            System.assert( oldknowledgeTile.Article_Name__c != newKnowledgeTile.Article_Name__c, 'The new article is not updated on the tile' );
        }
    }

    @isTest
    static void testgetExistingContentPath(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){

            Tile__c knowledgeTile = [SELECT Id, Name, Article_Name__c, Parent_Tile__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            List<Id> tileIds;
            Test.startTest();

            tileIds = ContentManagementController.getExistingContentPath(
                knowledgeTile.Name, 
                knowledgeTile.Article_Name__c
            );

            Test.stopTest();

            System.assertEquals(knowledgeTile.Parent_Tile__c, tileIds.get(0) , 'Parent tile fetched is not equal to Tile parent tile');
        }
    }

    @isTest
    static void testgetExistingLibraryPaths(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){

            Tile__c knowledgeTile = [SELECT Id, Name, Article_Name__c, Parent_Tile__c
            FROM Tile__c 
            WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            List<String> folderLibraryIds;

            Test.startTest();

            folderLibraryIds = ContentManagementController.getExistingLibraryPaths(
                knowledgeTile.Id
            );

            Test.stopTest();

            Id folderId     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder 2'].Id;
            Id folderId1     = [SELECT Id FROM ContentFolder WHERE Name = 'Test Folder'].Id;
            Id libraryId    = [SELECT Id, RootContentFolderId FROM ContentWorkSpace WHERE Name = 'Test WorkSpace'].RootContentFolderId;

            System.assertEquals(folderId + '-' + libraryId, folderLibraryIds.get(0) , 'Folder-Library Id returned is not equal to the current tile files folder-library Id');
        }
    }

    @isTest
    static void testRelatedTileAddition(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];
        User selectedContentOwner = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%User3@frieslandabc.com%'];

        System.runAs(adminUser){

            Tile__c knowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                                    Business_Segment__c, Sub_Segment__c, Community_Name__c,
                                    Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c
                                    FROM Tile__c 
                                    WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTile = [SELECT Id, UrlName, OwnerId FROM Knowledge__kav WHERE Id =: knowledgeTile.Article_Name__c];

            Tile__c oldTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 1'];

            Tile__c newTileToMoveArticle = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 2_1'];

            ContentManagementController.ContentLocationWrapper conLocWrap = new ContentManagementController.ContentLocationWrapper();
            conLocWrap.SelectedTileId = newTileToMoveArticle.Id;
            conLocWrap.contentStoragePath = 'Recipes > Test Child for Update Level 2_1';
            
            Tile__c testTileForRelatedTile = [SELECT Id,Name FROM Tile__c WHERE Name like '%Test Child for Related Tile%'];

            Test.startTest();
            String categoryArray = '[{"tileKnowledgeId":"' + testTileForRelatedTile.Id + '","contentCategorySelected":"Certificate"}]';
            ContentManagementController.saveEditedArticleData(
                getTileObjJSON(knowledgeTile, knowledgeArticleWithTile),
                '',
                '',
                knowledgeArticleWithTile.UrlName,
                '',
                JSON.serialize(new List<ContentManagementController.ContentLocationWrapper>{conLocWrap}),
                'onlyContentPaths',
                '[{"tileKnowledgeId":"' + testTileForRelatedTile.Id + '","contentCategorySelected":"Certificate"}]',
                selectedContentOwner.Id,
                categoryArray,
                'FCI Distributor Product Main Tile'
            );

            Test.stopTest();

            Tile__c newKnowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c, Parent_Tile__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id, Related_Tile__c, Tile__c FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            Knowledge__kav knowledgeArticleWithTileUpdated = [SELECT Id, UrlName FROM Knowledge__kav WHERE Id =: newKnowledgeTile.Article_Name__c];

            System.assertEquals( 'Knowledge Article Update under Test Child for Update Level 1', newKnowledgeTile.UI_Name__c, 'UI Name should not be changed on only ContentPath change' );
            System.assertEquals( 'Knowledge Article Update under Test Child for Update Level 1', newKnowledgeTile.Name, 'Name should not be changed on only ContentPath change' );
            System.assertEquals( 'Knowledge-Article-Update-under-Test-Child-for-Update-Level-1', knowledgeArticleWithTileUpdated.UrlName, 'Knowledge URL should not be changed on only ContentPath change' );
            System.assert( oldTile.Id != newKnowledgeTile.Parent_Tile__c, 'New tile did not transfer to new path and is still under the old path even after new content path is selected');
            System.assert( newTileToMoveArticle.Id == newKnowledgeTile.Parent_Tile__c, 'New knowledge tile has not moved under '+newTileToMoveArticle.Name );
            //System.assertEquals( 1, newKnowledgeTile.Related_Tiles__r.size(), 'Related tile not created under new article' );
            System.assertEquals( 0, [SELECT Id FROM Tile__c WHERE Id =: knowledgeTile.Id].size(), 'Old Tile is not deleted' );
        }
    }

    @isTest
    static void getgetExistingRelatedArticles(){

        User adminUser = [SELECT Id,FirstName, LastName FROM User WHERE UserName like '%AdminUser@abc.com%'];

        System.runAs(adminUser){

            Tile__c knowledgeTile = [SELECT Id, Name, UI_Name__c, UI_Description__c, Work_Location__c, Parent_Account__c, 
                Business_Segment__c, Sub_Segment__c, Community_Name__c,
                Sales_Region__c, Article_Name__c, Review_End_Date__c , File_ContentDocumentId__c,
                (SELECT Id, Related_Tile_Type__c, Related_Tile__c, Related_Tile__r.Name FROM Related_Tiles__r)
                FROM Tile__c 
                WHERE Name = 'Knowledge Article Update under Test Child for Update Level 1'];

            List<String> existingContentRelatedTiles;

            Test.startTest();

            existingContentRelatedTiles = ContentManagementController.getExistingRelatedArticles(knowledgeTile.Id);

            Test.stopTest();

            System.assertEquals(knowledgeTile.Related_Tiles__r.size(), existingContentRelatedTiles.size());
            //System.assertEquals('Product Data Sheet', knowledgeTile.Related_Tiles__r.get(0).Related_Tile_Type__c);
            //System.assertEquals('certificate', knowledgeTile.Related_Tiles__r.get(0).Related_Tile__c);
            //System.assertEquals('Related Tile for Update 1', knowledgeTile.Related_Tiles__r.get(0).Related_Tile__r.Name);

            //System.assertEquals((existingContentRelatedTiles.get(0).split('-')).get(0), knowledgeTile.Related_Tiles__r.get(0).Related_Tile_Type__c);
            //System.assertEquals((existingContentRelatedTiles.get(0).split('-')).get(2), knowledgeTile.Related_Tiles__r.get(0).Related_Tile__r.Name);
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
    
    @isTest
    static void getSelectedContentOwnerNameTest(){
        User selectedContentOwner = [SELECT Id,FirstName, LastName,Name FROM User WHERE UserName like '%User3@frieslandabc.com%'];
        String contentOwnerName = ContentManagementController.getContentOwnerName(selectedContentOwner.Id);
        system.assertEquals(selectedContentOwner.Name, contentOwnerName);
    }
    
    @isTest
    static void saveFilesInChunksTest(){
        String base64Data = EncodingUtil.base64Encode(Blob.valueof('Test File data'));
        Id contentVersionId = ContentManagementController.saveTheChunkFile('FCI Test Content', base64Data, '');
        system.assertEquals('FCI Test Content', [SELECT Id, Title FROM ContentVersion WHERE Id =: contentVersionId].Title);
    }
    
    @isTest
    static void appendFilesTest(){
        String base64Data = EncodingUtil.base64Encode(Blob.valueof('Recipes - PSS - FCI - Updated'));
        //Upload a new file
        String testFileData = 'Recipes - PSS - FCI';
        Blob fileContentBlob = Blob.valueOf(testFileData);
        ContentVersion conVersion = new ContentVersion();
        conVersion.ContentLocation = 'S';
        conVersion.PathOnClient = 'TestFile.txt';
        conVersion.Title = 'Test Recipe 1';
        conVersion.VersionData = fileContentBlob;
        insert conVersion;
        ContentVersion existingContentVersion = [SELECT Id, LastModifiedDate FROM ContentVersion WHERE Id =: conVersion.Id];
        Id contentVersionId = ContentManagementController.saveTheChunkFile('FCI Test Content', base64Data, conVersion.Id);
    }
    
    @isTest
    static void updateTileAccountsTest(){
        Id acc1 = [SELECT Id,Name FROM Account WHERE Name = 'H1 Account'].Id;
        Id acc2 = [SELECT Id,Name FROM Account WHERE Name = 'H5 Account'].Id;
        List<Id> accounts = new List<Id>{acc1,acc2};
        Tile_Account__c tileAcc = [SELECT Id,Name FROM Tile_Account__c WHERE Account__c = :acc1 LIMIT 1];
        Tile__c oldTile = [SELECT Id, Name FROM Tile__c WHERE Name = 'Test Child for Update Level 1'LIMIT 1];
        ContentManagementController.updateTileAccounts(oldTile.Id, accounts, accounts);
        
        
    }
    
    
}