@isTest
public class SObjectLookUpControllerTest {
    
    @TestSetup
    static void createTileDataToSearch(){
        
        TriggerHandler.skipTrigger = true;
        Id TILE_GLOBAL_RECORD_TYPE_ID = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Global').getRecordTypeId();

        Tile__c parentTile = TestUtility.createTile('Test Parent');
        parentTile.RecordTypeId = TILE_GLOBAL_RECORD_TYPE_ID;
        insert parentTile;

        List<Tile__c> childTiles = new List<Tile__c>();
        Tile__c childTile1 = TestUtility.createTile('Test Child 1');
        childTile1.Parent_Tile__c = parentTile.Id;
        childTile1.RecordTypeId = TILE_GLOBAL_RECORD_TYPE_ID;
        childTiles.add(childTile1);

        Tile__c childTile2 = TestUtility.createTile('Test Child 2');
        childTile2.Parent_Tile__c = parentTile.Id;
        childTile2.RecordTypeId = TILE_GLOBAL_RECORD_TYPE_ID;
        childTiles.add(childTile2);

        Tile__c childTile3 = TestUtility.createTile('Test Child 3');
        childTile3.RecordTypeId = TILE_GLOBAL_RECORD_TYPE_ID;
        childTiles.add(childTile3);

        insert childTiles;

        List<Account> accsCommercCustToInsert = new List<Account>(); //Commercial customers list to be created
        Account commercialCustIMCD = TestUtility.createAccount('IMCD Holding'); //Commercial customer test record
        accsCommercCustToInsert.add(commercialCustIMCD);

        insert accsCommercCustToInsert;

        List<Account> accsToInsert = new List<Account>(); //Customer locations list to be created
        Account customerLocIMCDItaly = TestUtility.createCustomerLocation('IMCD Italy Spa', commercialCustIMCD); //Customer location test record
        accsToInsert.add(customerLocIMCDItaly);

        insert accsToInsert;

        List<Contact> contactsToInsert = new List<Contact>(); //Contacts list to be created
        Contact cItalySU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly); //Contact test record
        contactsToInsert.add(cItalySU);

        Contact cIMCDMU = TestUtility.createContact(commercialCustIMCD, customerLocIMCDItaly); //Contact test record
        contactsToInsert.add(cIMCDMU);

        insert contactsToInsert;

        List<User> usersToInsert = new List<User>(); //Users list to be created
        User usrIMCDItalySU = TestUtility.createUser(TestUtility.generateRandomUserName() + 'TestIMCDItaly', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDItalySU.ContactId = cItalySU.Id;
        usersToInsert.add(usrIMCDItalySU);

        User usrIMCDMU = TestUtility.createCommunityManagerUser(TestUtility.generateRandomUserName() + 'TestIMCDManager', Constants.TEST_FCI_DISTRIBUTOR_PROFILE); //Partner User test record
        usrIMCDMU.ContactId = cIMCDMU.Id;
        usersToInsert.add(usrIMCDMU);

        insert usersToInsert;

        Product2 sampleProduct = DataFactoryTest.getProductSKUs( 1 )[ 0 ];
        sampleProduct.Product_Code__c = '000000000000094500';
        Database.insert( sampleProduct );

        List<Listing__c> listingsToInsert = new List<Listing__c>();
        listingsToInsert.add(TestUtility.createListings(customerLocIMCDItaly.Id, sampleProduct.Id));
        insert listingsToInsert;
        
        //insert knowledge user
        User contentOwner = TestUtility.createUser('User2@frieslandabc.com'+TestUtility.generateRandomString(8),'New FCl Lightning Users');
        contentOwner.UserPermissionsKnowledgeUser = true;
        contentOwner.Disable_Listed_Triggers__c = 'SRM_ContentVersionTrigger;';
        insert contentOwner;
        
        system.runAs(contentOwner){
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
        }

        TriggerHandler.skipTrigger = false;
    }

    @isTest
    static void searchCorrectRecordsAndReturn(){

        Tile__c childTile1 = [SELECT Id, Name, UI_Name__c FROM Tile__c WHERE Name like '%Test Child 1%'];
        Tile__c childTile2 = [SELECT Id, Name, UI_Name__c FROM Tile__c WHERE Name like '%Test Child 2%'];
        Tile__c childTile3 = [SELECT Id, Name, UI_Name__c FROM Tile__c WHERE Name like '%Test Child 3%'];

        List<Tile__c> sobjList;
        Test.startTest();

        sobjList = (List<Tile__c>)SObjectLookUpController.getRecords('Tile__c', 'UI_Name__c', 'UI_Name__c', 
                                            new List<String>{'UI_Description__c','UI_Name__c'}, 
                                            new List<String>{'Global'}, 
                                            'Test Child',
                                            10, '', false);

        Test.stopTest();

        List<String> tileNameList = new List<String>();
        for(Tile__c eachTl : sobjList){
            tileNameList.add(eachTl.UI_Name__c);
        }

        System.assertEquals(3, sobjList.size());
        System.assert(tileNameList.contains(childTile1.UI_Name__c));
        System.assert(tileNameList.contains(childTile2.UI_Name__c));
        System.assert(tileNameList.contains(childTile3.UI_Name__c));
    }

    @isTest
    static void searchProperListingsForStandardCommunityUsers(){

        User usrItaly = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDItaly'];

        List<Product2> sobjList;
        System.runAs(usrItaly){

            Test.startTest();

            sobjList = (List<Product2>)SObjectLookUpController.getRecords('Product2', 'Name', 'Name', 
                                                new List<String>{'Name'}, 
                                                new List<String>{'BGI_Product_SKU'}, 
                                                'Sample Product',
                                                10, '', false);

            Test.stopTest();

        }

    }
    @isTest
    static void searchAccountForCommunityUsers(){

        User usrItaly = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDItaly'];

        List<Account> sobjList;
        System.runAs(usrItaly){

            Test.startTest();

            sobjList = (List<Account>)SObjectLookUpController.getRecords('Account', 'Name', 'Name', 
                                                new List<String>{'Name'}, 
                                                new List<String>{'BGI_Customer_Location'}, 
                                                'Sample Product',
                                                11,'', false);

            Test.stopTest();

        }

    }

    @isTest
    static void searchProperListingsForManagerCommunityUsers(){

        User usrItalyManager = [SELECT Id FROM User WHERE UserName LIKE '%TestIMCDManager'];

        List<Product2> sobjList;
        System.runAs(usrItalyManager){

            Test.startTest();

            sobjList = (List<Product2>)SObjectLookUpController.getRecords('Product2', 'Name', 'Name', 
                                                new List<String>{'Name'}, 
                                                new List<String>{'BGI_Product_SKU'}, 
                                                'Sample Product',
                                                10,'', false);

            Test.stopTest();

        }

    }
    
    @isTest
    static void searchAccountForCommunityUsersBasedOnAssociatedContactId(){

        User usrItaly = [SELECT Id, ContactId FROM User WHERE UserName LIKE '%TestIMCDItaly'];

        List<Account> sobjList;

            Test.startTest();

            sobjList = (List<Account>)SObjectLookUpController.getRecords('Account', 'Name', 'Name', 
                                                new List<String>{'Name'}, 
                                                new List<String>{'BGI_Customer_Location'}, 
                                                'Sample Product',
                                                11,usrItaly.ContactId, false);

            Test.stopTest();

    }
    
    @isTest
    static void searchForKnowledgeUsers(){

        User contentOwner = [SELECT Id,Name, UserRole.Name FROM User WHERE UserName LIKE '%User2@frieslandabc.com%'];

        List<User> sobjList;

            Test.startTest();

            sobjList = (List<User>)SObjectLookUpController.getRecords('User', 'Name', 'Name', 
                                                new List<String>{'UserRole.Name'}, 
                                                new List<String>(), 
                                                contentOwner.Name,
                                                11,'', true);

            Test.stopTest();

    }
}