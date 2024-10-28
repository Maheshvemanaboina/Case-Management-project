@isTest
public class TileAccountSelectorControllerTest {
    
    @TestSetup
    static void setup() {
        // Get RecordTypeId for H1 (Commercial Customer) and H5 (Customer Location) accounts
        Id h1RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Commercial Customer' LIMIT 1].Id;
        Id h5RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Customer Location' LIMIT 1].Id;

        // Creating test data for H1 accounts
        List<Account> h1Accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            h1Accounts.add(new Account(
                Name = 'H1 Account ' + i,
                BillingStreet = 'TestBillingStreet',
                BillingPostalCode = '0000',
                BillingCity = 'TestCity',
                BillingCountry = 'Italy',
                BillingCountryCode = 'IT',
                Active__c = true,
                RecordTypeId = h1RecordTypeId));
        }
        insert h1Accounts;
        
        // Creating test data for H5 accounts
        List<Account> h5Accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            h5Accounts.add(new Account(
                Name = 'H5 Account ' + i, 
                BillingStreet = 'TestBillingStreet',
                BillingPostalCode = '0000',
                BillingCity = 'TestCity',
                BillingCountry = 'Italy',
                BillingCountryCode = 'IT',
                ParentId = h1Accounts[0].Id,
                Active__c = true,
                RecordTypeId = h5RecordTypeId));
        }
        insert h5Accounts;
        
        // Creating test data for Knowledge__kav and Tiles using TestUtility
        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt', 'testArt');
        insert art;

        // Create main parent tile and child tiles
        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile;
	
        // Creating child tiles with relationships
        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED;
        childTile1.Business_Segment__c = 'Industry';
        childTile1.Sub_Segment__c = 'Beverages';
        try{
            insert childTile1;
        }catch(Exception e){
            system.debug('error-->'+e.getMessage());
        }
        
        

        Tile__c childTile11 = TestUtility.createTile('childTile11');
        childTile11.Parent_Tile__c = childTile1.Id;
        childTile11.Business_Segment__c = 'Industry'; 
        childTile11.Sub_Segment__c = 'Beverages';
        childTile11.Article_Name__c = art.Id;
        insert childTile11;

        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = childTile1.Id;
        childTile12.Business_Segment__c = 'Industry'; 
        childTile12.Sub_Segment__c = 'Beverages';
        childTile12.Article_Name__c = art.Id;
        insert childTile12;

        Tile__c childTile13 = TestUtility.createTile('childTile13');
        childTile13.Parent_Tile__c = childTile1.Id;
        childTile13.Business_Segment__c = 'Industry'; 
        childTile13.Sub_Segment__c = 'Food';
        childTile13.Article_Name__c = art.Id;
        insert childTile13;
        //User usrAgent = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestAgentSubSegment'];

        TileUtility.TileStructureWrapper tilesWrapperByName;
        TileUtility.TileStructureWrapper tilesWrapperById;
        TileUtility.TileStructureWrapper tileInfoWrapper;
    }
    
    static void createChildTiles(Id parentTileId, Id articleId) {
        // Create child tiles related to the parent
        List<Tile__c> childTiles = new List<Tile__c>();
        
        for (Integer i = 1; i <= 3; i++) {
            childTiles.add(new Tile__c(
                Name = 'childTile' + i,
                Parent_Tile__c = parentTileId,
                Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED,
                Business_Segment__c = 'Industry',
                Sub_Segment__c = (i == 3) ? 'Food' : 'Beverages',
                Article_Name__c = (i <= 2) ? articleId : null
            ));
        }
        
        insert childTiles;
    }

    @IsTest
    static void testGetAvailableAccounts() {
        Test.startTest();
        List<Account> h1Accounts = TileAccountsSelectorController.getAvailableAccounts(true, false);
        System.assertEquals(5, h1Accounts.size(), 'Expected 5 H1 accounts');
        
        List<Account> h5Accounts = TileAccountsSelectorController.getAvailableAccounts(false, true);
        System.assertEquals(5, h5Accounts.size(), 'Expected 5 H5 accounts');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetKnowledgeArticle() {
        Knowledge__kav art = [SELECT Id, Title, UrlName FROM Knowledge__kav WHERE Title = 'testArt' LIMIT 1];
        Knowledge__kav retrievedArt = TileUtility.getKnowledgeArticle(art.Id);
        
        System.assertNotEquals(null, retrievedArt, 'Expected a Knowledge__kav record to be returned');
        System.assertEquals(art.Id, retrievedArt.Id, 'Expected the article ID to match');
        System.assertEquals('testArt', retrievedArt.Title, 'Expected the title to be "testArt"');
    }

    @IsTest
    static void testGetTileByArticleUrlName() {
        Test.startTest();
        // Retrieve the tile by article URL name
        Tile__c retrievedTile = TileUtility.getTileByArticleUrlName('test-article-url');
        System.assertEquals(null, retrievedTile, 'Expected no Tile__c record to be returned for non-existing URL');
        Test.stopTest();
    }

    @IsTest
    static void testGetTileByName() {
        Test.startTest();
        // Retrieve the tile by name
        Tile__c retrievedTile = TileUtility.getTileByName('childTile1');
        
        System.assertNotEquals(null, retrievedTile, 'Tile should not be null');
        System.assertEquals('childTile1', retrievedTile.Name, 'Tile Name should match');
        Test.stopTest();
    }

    @IsTest
    static void testGetTileById() {
        Tile__c tileWithId = [SELECT Id FROM Tile__c WHERE Name = 'childTile11' LIMIT 1];

        Test.startTest();
        Tile__c retrievedTile = TileUtility.getTileById(tileWithId.Id);
        
        System.assertNotEquals(null, retrievedTile, 'Tile should not be null');
        System.assertEquals(tileWithId.Id, retrievedTile.Id, 'Tile Id should match');
        Test.stopTest();
    }

    @IsTest
    static void testTileStructureWrapper() {
        Tile__c parentTile = [SELECT Id FROM Tile__c WHERE Name = 'parentTileMainRoot' LIMIT 1];
        List<Tile__c> childTiles = TileUtility.getChildTilesById(parentTile.Id);
        
        Test.startTest();
        TileUtility.TileStructureWrapper wrapper = new TileUtility.TileStructureWrapper(parentTile, childTiles);
        
        System.assertNotEquals(null, wrapper, 'TileStructureWrapper should not be null');
        System.assertEquals(parentTile.Id, wrapper.ParentTile.Id, 'Parent tile ID should match');
        System.assertEquals(childTiles.size(), wrapper.ChildTiles.size(), 'Child tile count should match');
        Test.stopTest();
    }

    @IsTest
    static void testGetTilesImageMap() {
        Test.startTest();
        List<TileUtility.TileStructureWrapper> tiles = TileUtility.getTilesStructuredByName('parentTileMainRoot');
        Map<Id, ContentVersion> result = TileUtility.getTilesImageMap(tiles);
        System.assertNotEquals(null, result, 'Image map should not be null');
        Test.stopTest();
    }

    @IsTest
    static void testGetAllTilesTreeFromRoot() {
        Test.startTest();
        List<Tile__c> allTiles = TileUtility.getAllTilesTreeFromRoot('parentTileMainRoot');
        System.assertNotEquals(null, allTiles, 'All tiles should not be null');
        System.assert(allTiles.size() > 0, 'There should be at least one tile');
        Test.stopTest();
    }

    @IsTest
    static void testGetAllEndTilesTreeFromRoot() {
        Test.startTest();
        List<Tile__c> allEndTiles = TileUtility.getAllEndTilesTreeFromRoot('parentTileMainRoot');
        System.assertNotEquals(null, allEndTiles, 'All end tiles should not be null');
        System.assert(allEndTiles.size() > 0, 'There should be at least one end tile');
        Test.stopTest();
    }
}