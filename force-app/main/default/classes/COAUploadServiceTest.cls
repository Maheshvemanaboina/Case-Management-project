@isTest
public class COAUploadServiceTest {
    
    @testSetup
    static void setup(){
        Account commercialCustDanone = createAccount('Danone SA');
        insert commercialCustDanone;
        
        Account customerLocItaly = createCustomerLocation('IMCD Italy Spa', commercialCustDanone);
        insert customerLocItaly;
        
        Tile__c docTile = createTileForFCICommunity('Certificate of Analysis','FCI Customer Community');
        insert docTile;
        System.debug('DoctileId --> '+docTile.Id);
        List<Tile__c> YearTileList = new List<Tile__c>();
        Tile__c YearTile1 = createChildTile('Year Child 1','FCI Customer Community',docTile);
        YearTileList.add(YearTile1);
        insert YearTileList;
        System.debug('YearTile1 --> '+YearTile1.Parent_Tile__c);
        List<Tile__c> monthTileList = new List<Tile__c>();
        Tile__c monthTile1 = createChildTile('Month Child 1','FCI Customer Community',YearTile1);
        Tile__c monthTile2 = createChildTile('Month Child 2','FCI Customer Community',YearTile1);
        monthTileList.add(monthTile1);
        monthTileList.add(monthTile2);
        insert monthTileList;
        
        List<Tile__c> productGrpTile = new List<Tile__c>();
        Tile__c productGroupTile1 = createChildTile('productGroup Child 1','FCI Customer Community',monthTile1);
        Tile__c productGroupTile2 = createChildTile('productGroup Child 2','FCI Customer Community',monthTile2);
        productGrpTile.add(productGroupTile1);
        productGrpTile.add(productGroupTile2);
        insert productGrpTile;
        
        List<Tile__c> ShipToTiles = new List<Tile__c>();
        Tile__c ShipToTile1 = createChildTile('ShipTo Child 1','FCI Customer Community',productGroupTile1);
        Tile__c ShipToTile2 = createChildTile('ShipTo Child 2','FCI Customer Community',productGroupTile2);
        ShipToTiles.add(ShipToTile1);
        ShipToTiles.add(ShipToTile2);
        insert ShipToTiles;
    }
    
    @isTest
    static void YearTest(){
        Tile__c yrTile = [Select Id from Tile__c where Name = 'Year Child 1'];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = yrTile.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        COAUploadService.fetchYear('','Nothing');
        COAUploadService.fetchYear('Year','Nothing');
    }
    
    @isTest
    static void monthTest(){
        List<Tile__c> monthTiles = [Select Id from Tile__c where Name like '%Month%'];
        Tile__c yrTile = [Select Id from Tile__c where Name = 'Year Child 1'];
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = monthTiles[0].Id;
        fixedSearchResults[1] = monthTiles[1].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        COAUploadService.fetchMonthName('',yrTile);
        COAUploadService.fetchMonthName('Month',yrTile);
    }
    
    @isTest 
    static void saveRecordTest(){
        Tile__c ShipToTile = [Select Id from Tile__c where Name = 'ShipTo Child 1'];
        Tile__c prodGrpTile = [Select Id from Tile__c where Name = 'productGroup Child 1'];
        Tile__c yrTile = [Select Id from Tile__c where Name = 'Year Child 1'];
        List<Tile__c> monthTiles = [Select Id from Tile__c where Name like '%Month%'];
        Account custLoc = [Select Id from Account where Name = 'IMCD Italy Spa'];
        blob file=  Blob.valueOf('sample text');
        //String base64Content = (String)JSON.deserialize('sampletext', String.class);
        //Blob body = EncodingUtil.base64Decode(base64Content);
        COAUploadService.saveRecord(yrTile.Id, monthTiles[0].id, prodGrpTile.Id, ShipToTile.Id, custLoc.Id, 'fileName', 'hello', 'contentType', 'TileName');
    }
    
    private static Account createCustomerLocation(String AccName, Account parentAcc) {
        return new Account(
            Name = AccName,
            ParentId = parentAcc.Id,
            RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'Customer Location' AND SobjectType = 'Account' LIMIT 1].Id,
            Active__c = true,
            Type = 'Direct Customer: Sold-to;Ship-to;Bill-to',
            BillingStreet = 'Centro Leoni-Edificio A',
            BillingPostalCode = '20141',
            BillingCity = 'MILANO',
            BillingCountry = 'Italy',
            BillingCountryCode = 'IT'
        );
    }
    
    private static Account createAccount(String accountName) {
        return new Account(
            Name = accountName,
            BillingStreet = 'TestBillingStreet',
            BillingPostalCode = '0000',
            BillingCity = 'TestCity',
            BillingCountry = 'Italy',
            BillingCountryCode = 'IT',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'BGI_Commercial_Customer' LIMIT 1].Id
        );
    }
    
    private static Tile__c createTileForFCICommunity(String uIName,String communityName){
        return new Tile__c(
            Name = uIName,
            UI_Name__c = uIName,
            Community_Name__c = communityName);
    }
    
    private static Tile__c createChildTile(String uIName,String communityName,Tile__c parentTile){
        return new Tile__c(
        	Name = uIName,
        	UI_Name__c = uIName,
        	community_Name__c = communityName,
        	Parent_Tile__c = parentTile.Id);
    }
}