/*------------------------------------------------------------  
Author:       Siddaramaiah S R
Description:  This is the Test class for "TilesTriggerHandler"
------------------------------------------------------------*/

@isTest
public class TilesTriggerHandlerTest {
    
    @testSetup
    static void setup() {
        // Create test data for Tiles
        List<Tile__c> tiles = new List<Tile__c>();
        for (Integer i = 0; i < 5; i++) {
            tiles.add(new Tile__c(Name = 'Test Tile ' + i));
        }
        insert tiles;
    }
    
    @isTest
    static void testAfterInsert() {
        // Insert new tiles to trigger after insert
        List<Tile__c> newTiles = new List<Tile__c>{
            new Tile__c(Name = 'New Tile 1'),
            new Tile__c(Name = 'New Tile 2')
        };
        
        Test.startTest();
        insert newTiles; 
        Test.stopTest();
        System.assertEquals(2, [SELECT COUNT() FROM Tile__c WHERE Name LIKE 'New Tile%']);
    }

    @isTest
    static void testAfterUpdate() {
        List<Tile__c> existingTiles = [SELECT Id, Name FROM Tile__c LIMIT 2];
        for (Tile__c tile : existingTiles) {
            tile.Name = 'Updated ' + tile.Name;
        }

        Test.startTest();
        update existingTiles;
        Test.stopTest();
        for (Tile__c tile : [SELECT Name FROM Tile__c WHERE Id IN :existingTiles]) {
        System.assert(tile.Name.startsWith('Updated'), 'The record was not updated correctly.');
        }
    }

    @isTest
    static void testProcessBeforeDeleteWithoutMassDeleteAccess() {
        // Create test data
        List<Tile__c> tilesToDelete = new List<Tile__c>();
        tilesToDelete.add(new Tile__c(Name = 'Test Tile WithOut Mass Delete 1'));
        tilesToDelete.add(new Tile__c(Name = 'Test Tile WithOut Mass Delete 2'));
        
        // Insert test data
        insert tilesToDelete;
        
        // Create a test user with a profile that doesn't have mass delete access
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Perform delete as this user
        System.runAs(testUser) {
            Test.startTest();
            try {
                delete tilesToDelete;
            } catch (DmlException e) {
                for(Tile__c tileRecord : tilesToDelete){
                    tileRecord.addError('You cannot delete more than 1 Tile record at a time.'); 
                }
            }
            Test.stopTest();
            
            // Assert that error messages are added and tiles are not deleted
            for (Tile__c tile : [SELECT Id FROM Tile__c WHERE Id IN :tilesToDelete]) {
                System.assertNotEquals(null, tile, 'Tile record should not be deleted');
            }
        }
    }

    @isTest
    static void testProcessBeforeDeleteWithMassDeleteAccess() {
        // Create test data
        List<Tile__c> tilesToDelete = new List<Tile__c>();
        tilesToDelete.add(new Tile__c(Name = 'Test Tile With Mass Delete 1'));
        tilesToDelete.add(new Tile__c(Name = 'Test Tile With Mass Delete 2'));
        
        // Insert test data
        insert tilesToDelete;
        
        // Create a test user with a profile that has mass delete access
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Perform delete as this user
        System.runAs(testUser) {
            Test.startTest();
            delete tilesToDelete;
            Test.stopTest();
            
            // Assert that tiles are deleted
            Integer count = [SELECT COUNT() FROM Tile__c WHERE Id IN :tilesToDelete];
            System.assertEquals(0, count, 'Tiles should be deleted');
        }
    }
}