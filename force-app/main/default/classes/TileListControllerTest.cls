/**
 * Created by KJM on 22/05/2019.
 * Upadted by SSM on 30/05/2024.
 */

@isTest
public with sharing class TileListControllerTest {

    @testSetup
    static void setup() {
        TestUtility.createInitialTestAccountsAndUsers();
    }

    @isTest
    static void shouldReturnProperTilesStructuredAgent() {

        TriggerHandler.skipTrigger = true;

        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocAgent = accsMap.get('Usta');

        User usrAgent = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestAgentSubSegment'];
        
        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c FROM Contact WHERE Id = :usrAgent.ContactId];
        con.Additional_Region_Responsibility__c ='Greater China';
        con.Business_Segment__c ='Industry';
        con.Sub_Segment__c = 'Beverages';
        con.Region__c ='EMEA';
        update con;

        

        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt', 'testArt');
        insert art;

         // ROOT
        // appear for all users into proper community +
        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile;
	

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

        TileListController.TilesListWrapper tilesWrapperByName;
        TileListController.TilesListWrapper tilesWrapperById;
        TileListController.TilesInfoWrapper tileInfoWrapper;
        System.runAs(usrAgent) {
            Test.startTest();

            tilesWrapperByName = TileListController.getTileListOnInit('parentTileMainRoot');
            tilesWrapperById = TileListController.getTileListByParent(childTile1.Id);
            //tileInfoWrapper = TileListController.getTileInfoByName(childTile2.Name);

            Test.stopTest();
        }

        TriggerHandler.skipTrigger = false;

        System.assertEquals(false, String.isBlank(tilesWrapperByName.DisplayOption));
        System.assertEquals(false, tilesWrapperByName.TilesAsTiles.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsList.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsNestedList.isEmpty());

        System.assertEquals(Constants.TILE_CHILD_TYPE_LIST, tilesWrapperByName.DisplayOption);
        System.assertEquals(1, tilesWrapperByName.TilesAsTiles.size());
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsTiles.get(0).UIName);
        System.assertEquals(1, tilesWrapperByName.TilesAsList.size());
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsList.get(0).name);
        System.assertEquals(1, tilesWrapperByName.TilesAsNestedList.size());
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsNestedList.get(0).name);

        
        System.assertEquals(0, tilesWrapperById.TilesAsNestedList.size());
        
        
        

    }

    @isTest
    static void shouldReturnProperTilesStructuredSU() {

        TriggerHandler.skipTrigger = true;

        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');
       

        User usrItaly = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDItaly'];
		
        Integer index ;
        String busSeg,subSeg,subSeg1,reg,appl,addReg,reg1;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues =	FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Sub_Segment__c);
        index = pckValues.indexOf('Alcoholic Beverages');
        subSeg = index !=-1 ? pckValues[index] : pckValues[0];
        index = pckValues.indexOf('Beverages');
        subSeg1 = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Additional_Region_Responsibility__c);
        index = pckValues.indexOf('Greater China');
        addReg = index !=-1 ? pckValues[index] : pckValues[0] ;
        
        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c FROM Contact WHERE Id = :usrItaly.ContactId];
        con.Additional_Region_Responsibility__c =addReg;   //'Greater China';
        con.Business_Segment__c =busSeg;   //'Industry';
        con.Sub_Segment__c = subSeg;   //'Alcoholic Beverages';
        con.Region__c =reg;   //'EMEA';
        update con;
		
        pckValues.clear();
        // pckValues =FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Business_Segment__c) ;
        // index = pckValues.indexOf('Industry');
        // busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        // pckValues.clear();
        // pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Sub_Segment__c) ;
        // index = pckValues.indexOf('Beverages');
        // subSeg = index !=-1 ? pckValues[index] :pckValues[0] ;
        
        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt', 'testArt');
        // art.business_segment__c = busSeg;  //'Industry';
        // art.Sub_Segment__c = subSeg; //'Beverages';
        insert art;

        // ROOT
        // appear for all users into proper community +
        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile;
		//fetching picklistValues.	
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Sales_Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        index = pckValues.indexOf('Greater China');
        reg1 = index !=-1 ? pckValues[index] :pckValues[0];
        
        // CHILD1
        // appear only for work location +
        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED;
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Work_Location__c = customerLocItaly.Id;
        insert childTile1;

        // appear only for work location -
        Tile__c childTile11 = TestUtility.createTile('childTile11');
        childTile11.Parent_Tile__c = childTile1.Id;
        childTile11.Work_Location__c = customerLocFrance.Id;
        insert childTile11;

        

        // appear only for food and beverages user +
        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = childTile1.Id;
        childTile12.Business_Segment__c = busSeg; //'Industry';
        childTile12.Article_Name__c = art.Id;
        insert childTile12;

        // appear only for food and beverages and emea region user +
        Tile__c childTile13 = TestUtility.createTile('childTile13');
        childTile13.Parent_Tile__c = childTile1.Id;
        childTile13.Business_Segment__c = busSeg; //'Industry';
        childTile13.Sales_Region__c = reg; //'EMEA';
        childTile13.Article_Name__c = art.Id;
        insert childTile13;

        // appear only for food and beverages and emea region and from italy work location user +
        Tile__c childTile14 = TestUtility.createTile('childTile14');
        childTile14.Parent_Tile__c = childTile1.Id;
        childTile14.Work_Location__c = customerLocItaly.Id;
        childTile14.Business_Segment__c = busSeg; //'Industry';
        childTile14.Sales_Region__c = reg; //'EMEA';
        childTile14.Article_Name__c = art.Id;
        insert childTile14;
		
         
        // appear only for users with EMEA region or additional region as Greater China +
        Tile__c childTile15 = TestUtility.createTile('childTile15');
        childTile15.Parent_Tile__c = childTile1.Id;
        childTile15.Sales_Region__c = reg1; //'Greater China';
        childTile15.Article_Name__c = art.Id;
        insert childTile15;

        // appear only for food and beverages and emea region and from italy work location and application Cheese Powder -
        Tile__c childTile16 = TestUtility.createTile('childTile16');
        childTile16.Parent_Tile__c = childTile1.Id;
        childTile16.Work_Location__c = customerLocItaly.Id;
        childTile16.Business_Segment__c = busSeg; //'Industry';
        childTile16.Sales_Region__c = reg; //'EMEA';
        childTile16.Article_Name__c = art.Id;
        insert childTile16;

        // appear only for italy work location +
        Tile__c childTile17 = TestUtility.createTile('childTile17');
        childTile17.Parent_Tile__c = childTile1.Id;
        childTile17.Work_Location__c = customerLocItaly.Id;
        childTile17.Article_Name__c = art.Id;
        insert childTile17;

        // appear only for italy work location and if user have access to confidential content -
        Confidential_Content__c confCont = new Confidential_Content__c();
        confCont.Name = 'testConfCont1';
        insert confCont;

        Tile__c childTile18 = TestUtility.createTile('childTile18');
        childTile18.Parent_Tile__c = childTile1.Id;
        childTile18.Work_Location__c = customerLocItaly.Id;
        childTile18.Confidential_Content__c = confCont.Id;
        insert childTile18;

        

        // appear only for italy work location and if user have access to confidential content +
        Confidential_Content__c confCont2 = new Confidential_Content__c();
        confCont2.Name = 'testConfCont2';
        insert confCont2;

        Confidential_Content__Share confShare = new Confidential_Content__Share();
        confShare.UserOrGroupId = usrItaly.Id;
        confShare.ParentId = confCont2.Id;
        confShare.AccessLevel = 'Read';
        insert confShare;

        Tile__c childTile19 = TestUtility.createTile('childTile19');
        childTile19.Parent_Tile__c = childTile1.Id;
        childTile19.Work_Location__c = customerLocItaly.Id;
        childTile19.Confidential_Content__c = confCont2.Id;
        insert childTile19;

        // appear only for italy work location +
        Tile__c childTile110 = TestUtility.createTile('childTile110');
        childTile110.Parent_Tile__c = childTile1.Id;
        childTile110.Work_Location__c = customerLocItaly.Id;
        childTile110.File_Public_Link__c = 'testPublicFileLink';
        insert childTile110;

        // CHILD2
        // appear only for france work location -
        Tile__c childTile2 = TestUtility.createTile('childTile2');
        childTile2.Parent_Tile__c = parentMainTile.Id;
        childTile2.Work_Location__c = customerLocFrance.Id;
        insert childTile2;

        // appear only for france work location -
        Tile__c childTile21 = TestUtility.createTile('childTile21');
        childTile21.Parent_Tile__c = childTile2.Id;
        childTile21.Work_Location__c = customerLocFrance.Id;
        childTile21.Article_Name__c = art.Id;
        insert childTile21;

        // appear only for work location Usta -
        TriggerHandler.skipTrigger = false;

        TileListController.TilesListWrapper tilesWrapperByName;
        TileListController.TilesListWrapper tilesWrapperById;
        TileListController.TilesInfoWrapper tileInfoWrapper;
        System.runAs(usrItaly) {
            Test.startTest();

            tilesWrapperByName = TileListController.getTileListOnInit('parentTileMainRoot');
            tilesWrapperById = TileListController.getTileListByParent(childTile1.Id);
            tileInfoWrapper = TileListController.getTileInfoByName(childTile110.Name);

            Test.stopTest();
        }


        System.assertEquals(false, String.isBlank(tilesWrapperByName.DisplayOption));
        System.assertEquals(false, tilesWrapperByName.TilesAsTiles.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsList.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsNestedList.isEmpty());

        System.assertEquals(Constants.TILE_CHILD_TYPE_LIST, tilesWrapperByName.DisplayOption);
        System.assertEquals(2, tilesWrapperByName.TilesAsTiles.size());
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsTiles.get(0).UIName);
        System.assertEquals(2, tilesWrapperByName.TilesAsList.size());
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsList.get(0).name);
        System.assertEquals(2, tilesWrapperByName.TilesAsNestedList.size());
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsNestedList.get(0).name);

        System.assertEquals(false, String.isBlank(tilesWrapperById.DisplayOption));
        System.assertEquals(true, tilesWrapperById.TilesAsTiles.isEmpty());
        //System.assertEquals(false, tilesWrapperById.TilesAsList.isEmpty());
        //System.assertEquals(false, tilesWrapperById.TilesAsNestedList.isEmpty());

        System.assertEquals(Constants.TILE_CHILD_TYPE_NESTED, tilesWrapperById.DisplayOption);
        //System.assertEquals(7, tilesWrapperById.TilesAsTiles.size());
        //System.assertEquals(7, tilesWrapperById.TilesAsList.size());
        //System.assertEquals(7, tilesWrapperById.TilesAsNestedList.size());
        
    }

    @isTest
    static void shouldReturnProperTilesStructuredMU() {

        TriggerHandler.skipTrigger = true;

        List<Account> accs = [SELECT Id, Name, Sales_Region__c FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account commercialCust = accsMap.get('IMCD Holding');
        Account commercialCustDanone = accsMap.get('Danone SA');
        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');
        Account customerLocPoland = accsMap.get('IMCD Poland Spa');
        Account customerLocDanone = accsMap.get('Danone Poland');
        Account customerLocAgent = accsMap.get('Usta');
        Account customerLocChina = accsMap.get('IMCD China');

        customerLocChina.Sales_Region__c = 'Greater China';
        update customerLocChina;

        User usrManager = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDManager'];
        
        //Fetching picklistValues.
        Integer index ;
        String busSeg,subSeg,subSeg1,reg,appl,addReg,reg1;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues =	FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Sub_Segment__c);
        index = pckValues.indexOf('Alcoholic Beverages');
        subSeg = index !=-1 ? pckValues[index] : pckValues[0];
        index = pckValues.indexOf('Beverages');
        subSeg1 = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Additional_Region_Responsibility__c);
        index = pckValues.indexOf('Greater China');
        addReg = index !=-1 ? pckValues[index] : pckValues[0] ;
        
        
        

        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c FROM Contact WHERE Id = :usrManager.ContactId];
        con.Business_Segment__c =busSeg;   //'Industry';
        con.Sub_Segment__c = subSeg;  //'Alcoholic Beverages';
        con.Region__c =reg;  //'EMEA';
        update con;
		
        //fetch picklist values.
        //
        pckValues.clear();
        // pckValues =FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Business_Segment__c) ;
        // index = pckValues.indexOf('Industry');
        // busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        // pckValues.clear();
        // pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Sub_Segment__c) ;
        // index = pckValues.indexOf('Beverages');
        // subSeg = index !=-1 ? pckValues[index] :pckValues[0] ;
        
        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt', 'testArt');
        // art.business_segment__c = busSeg;  //'Industry';
        // art.Sub_Segment__c = subSeg; //'Beverages';
        insert art;

        // ROOT
        // appear for all users into proper community +
        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile;
        
        //fetch picklistValues.
        //
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Sales_Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        index = pckValues.indexOf('Greater China');
        reg1 = index !=-1 ? pckValues[index] :pckValues[0];
       

        // CHILD1
        // appear only for work location +
        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED;
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Work_Location__c = customerLocItaly.Id;
        insert childTile1;

        // appear only for work location -
        Tile__c childTile11 = TestUtility.createTile('childTile11');
        childTile11.Parent_Tile__c = childTile1.Id;
        childTile11.Work_Location__c = customerLocFrance.Id;
        insert childTile11;

        // appear only for food and beverages user +
        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = childTile1.Id;
        childTile12.Business_Segment__c =busSeg;  //'Industry';
        childTile12.Article_Name__c = art.Id;
        insert childTile12;

        // appear only for food and beverages and emea region user +
        Tile__c childTile13 = TestUtility.createTile('childTile13');
        childTile13.Parent_Tile__c = childTile1.Id;
        childTile13.Business_Segment__c = busSeg;  //'Industry';
        childTile13.Sales_Region__c = reg;  //'EMEA';
        childTile13.Article_Name__c = art.Id;
        insert childTile13;

        // appear only for food and beverages and emea region and from italy work location user +
        Tile__c childTile14 = TestUtility.createTile('childTile14');
        childTile14.Parent_Tile__c = childTile1.Id;
        childTile14.Work_Location__c = customerLocItaly.Id;
        childTile14.Business_Segment__c =busSeg;  //'Industry';
        childTile14.Sales_Region__c = reg; //'EMEA';
        childTile14.Article_Name__c = art.Id;
        insert childTile14;

        // appear only for users with EMEA region or additional region as Greater China (manager user can see all relcated to commercial customer) +
        Tile__c childTile15 = TestUtility.createTile('childTile15');
        childTile15.Parent_Tile__c = childTile1.Id;
        childTile15.Sales_Region__c =reg1;   //'Greater China';
        childTile15.Article_Name__c = art.Id;
        insert childTile15;

        // appear only for food and beverages and emea region and from italy work location
        Tile__c childTile16 = TestUtility.createTile('childTile16');
        childTile16.Parent_Tile__c = childTile1.Id;
        childTile16.Work_Location__c = customerLocItaly.Id;
        childTile16.Business_Segment__c =busSeg;  //'Industry';
        childTile16.Sales_Region__c =reg;   //'EMEA';
        childTile16.Article_Name__c = art.Id;
        insert childTile16;

        // appear only for italy work location +
        Tile__c childTile17 = TestUtility.createTile('childTile17');
        childTile17.Parent_Tile__c = childTile1.Id;
        childTile17.Work_Location__c = customerLocItaly.Id;
        childTile17.Article_Name__c = art.Id;
        insert childTile17;

        // appear only for italy work location and if user have access to confidential content -
        Confidential_Content__c confCont = new Confidential_Content__c();
        confCont.Name = 'testConfCont';
        insert confCont;

        Tile__c childTile18 = TestUtility.createTile('childTile18');
        childTile18.Parent_Tile__c = childTile1.Id;
        childTile18.Work_Location__c = customerLocItaly.Id;
        childTile18.Confidential_Content__c = confCont.Id;
        insert childTile18;

        // appear only for italy work location and if user have access to confidential content +
        Confidential_Content__c confCont2 = new Confidential_Content__c();
        confCont2.Name = 'testConfCont';
        insert confCont2;

        Confidential_Content__Share confShare = new Confidential_Content__Share();
        confShare.UserOrGroupId = usrManager.Id;
        confShare.ParentId = confCont2.Id;
        confShare.AccessLevel = 'Read';
        insert confShare;

        Tile__c childTile19 = TestUtility.createTile('childTile19');
        childTile19.Parent_Tile__c = childTile1.Id;
        childTile19.Work_Location__c = customerLocItaly.Id;
        childTile19.Confidential_Content__c = confCont2.Id;
        insert childTile19;

        // appear for all users +
        Tile__c childTile110 = TestUtility.createTile('childTile110');
        childTile110.Parent_Tile__c = childTile1.Id;
        childTile110.File_Public_Link__c = 'testPublicFileLink';
        insert childTile110;

        // CHILD2
        // appear only for france work location +
        Tile__c childTile2 = TestUtility.createTile('childTile2');
        childTile2.Parent_Tile__c = parentMainTile.Id;
        childTile2.Work_Location__c = customerLocFrance.Id;
        insert childTile2;

        // appear only for france work location +
        Tile__c childTile21 = TestUtility.createTile('childTile21');
        childTile21.Parent_Tile__c = childTile2.Id;
        childTile21.Work_Location__c = customerLocFrance.Id;
        childTile21.Article_Name__c = art.Id;
        insert childTile21;

        TriggerHandler.skipTrigger = false;

        TileListController.TilesListWrapper tilesWrapperByName;
        TileListController.TilesListWrapper tilesWrapperById;
        TileListController.TilesInfoWrapper tileInfoWrapper;
        System.runAs(usrManager) {
            Test.startTest();

            tilesWrapperByName = TileListController.getTileListOnInit('parentTileMainRoot');
            tilesWrapperById = TileListController.getTileListByParent(childTile1.Id);
            tileInfoWrapper = TileListController.getTileInfoByName(childTile110.Name);

            Test.stopTest();
        }


        System.assertEquals(false, String.isBlank(tilesWrapperByName.DisplayOption));
        System.assertEquals(false, tilesWrapperByName.TilesAsTiles.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsList.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsNestedList.isEmpty());

        System.assertEquals(Constants.TILE_CHILD_TYPE_LIST, tilesWrapperByName.DisplayOption);
        System.assertEquals(2, tilesWrapperByName.TilesAsTiles.size());
        System.assertEquals(2, tilesWrapperByName.TilesAsList.size());
        System.assertEquals(2, tilesWrapperByName.TilesAsNestedList.size());

        System.assertEquals(false, String.isBlank(tilesWrapperById.DisplayOption));
        System.assertEquals(true, tilesWrapperById.TilesAsTiles.isEmpty());
        System.assertEquals(true, tilesWrapperById.TilesAsList.isEmpty());
        System.assertEquals(true, tilesWrapperById.TilesAsNestedList.isEmpty());

        System.assertEquals(Constants.TILE_CHILD_TYPE_NESTED, tilesWrapperById.DisplayOption);

        System.assertEquals(0, tilesWrapperById.TilesAsTiles.size());
        //System.assertEquals(7, tilesWrapperById.TilesAsList.size());
        //System.assertEquals(7, tilesWrapperById.TilesAsNestedList.size());
 
    }

    @isTest
    static void shouldReturnTilesInProperOrder() {

        TriggerHandler.skipTrigger = true;

        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');

        User usrItaly = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDItaly'];
			
        //fetch picklistValues.
        //
        Integer index ;
        String busSeg,subSeg,subSeg1,reg,appl,addReg,reg1;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues =	FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Sub_Segment__c);
        index = pckValues.indexOf('Alcoholic Beverages');
        subSeg = index !=-1 ? pckValues[index] : pckValues[0];
        index = pckValues.indexOf('Beverages');
        subSeg1 = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Additional_Region_Responsibility__c);
        index = pckValues.indexOf('Greater China');
        addReg = index !=-1 ? pckValues[index] : pckValues[0] ;

        
        
        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c FROM Contact WHERE Id = :usrItaly.ContactId];
        con.Additional_Region_Responsibility__c = addReg;  //'Greater China';
        con.Business_Segment__c =busSeg;  //'Industry';
        con.Sub_Segment__c =subSeg ; //'Alcoholic Beverages';
        con.Region__c = reg;  //'EMEA';
        update con;
		
        //fetch picklist values.
        //
        pckValues.clear();
        // pckValues =FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Business_Segment__c) ;
        // index = pckValues.indexOf('Industry');
        // busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        // pckValues.clear();
        // pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Sub_Segment__c) ;
        // index = pckValues.indexOf('Beverages');
        // subSeg = index !=-1 ? pckValues[index] :pckValues[0] ;
        
        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt', 'testArt');
        // art.business_segment__c =busSeg;  //'Industry';
        // art.Sub_Segment__c = subSeg;  //'Beverages';
        insert art;

        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED;
        parentMainTile.Child_Order_Option__c = Constants.TILE_CHILD_ORDER_OPTION_BY_ORDER_NUMBER;
        insert parentMainTile;

        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Order_Number__c = 2;
        insert childTile1;

        Tile__c childTile2 = TestUtility.createTile('childTile2');
        childTile2.Parent_Tile__c = parentMainTile.Id;
        childTile2.Order_Number__c = 1;
        childTile2.Child_Order_Option__c = Constants.TILE_CHILD_ORDER_OPTION_BY_ORDER_NUMBER;
        insert childTile2;

        Tile__c childTile11 = TestUtility.createTile('childTile11');
        childTile11.Parent_Tile__c = childTile1.Id;
        childTile11.File_Public_Link__c = 'filePublicLink';
        childTile11.Order_Number__c = 2;
        insert childTile11;

        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = childTile1.Id;
        childTile12.File_Public_Link__c = 'filePublicLink';
        childTile12.Order_Number__c = 1;
        insert childTile12;

        Tile__c childTile21 = TestUtility.createTile('childTile21');
        childTile21.Parent_Tile__c = childTile2.Id;
        childTile21.File_Public_Link__c = 'filePublicLink';
        childTile21.Order_Number__c = 2;
        insert childTile21;

        Tile__c childTile22 = TestUtility.createTile('childTile22');
        childTile22.Parent_Tile__c = childTile2.Id;
        childTile22.File_Public_Link__c = 'filePublicLink';
        childTile22.Order_Number__c = 1;
        insert childTile22;

        TriggerHandler.skipTrigger = false;

        TileListController.TilesListWrapper tilesWrapperByName;
        System.runAs(usrItaly) {
            Test.startTest();

            tilesWrapperByName = TileListController.getTileListOnInit('parentTileMainRoot');

            Test.stopTest();
        }


        System.assertEquals(false, String.isBlank(tilesWrapperByName.DisplayOption));
        System.assertEquals(false, tilesWrapperByName.TilesAsTiles.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsList.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsNestedList.isEmpty());

        System.assertEquals(Constants.TILE_CHILD_TYPE_NESTED, tilesWrapperByName.DisplayOption);
        System.assertEquals(2, tilesWrapperByName.TilesAsNestedList.size());
        System.assertEquals('childTile2', tilesWrapperByName.TilesAsNestedList.get(0).name);
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsNestedList.get(1).name);

        System.assertEquals(2, tilesWrapperByName.TilesAsNestedList.get(0).items.size());
        System.assertEquals('childTile22', tilesWrapperByName.TilesAsNestedList.get(0).items.get(0).name);
        System.assertEquals('childTile21', tilesWrapperByName.TilesAsNestedList.get(0).items.get(1).name);

        System.assertEquals(2, tilesWrapperByName.TilesAsNestedList.get(1).items.size());
        System.assertEquals('childTile11', tilesWrapperByName.TilesAsNestedList.get(1).items.get(0).name);
        System.assertEquals('childTile12', tilesWrapperByName.TilesAsNestedList.get(1).items.get(1).name);
    }

    @isTest
    static void shouldShareProperlySubSegmentUsers(){

        TriggerHandler.skipTrigger = true;

        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');

        User usrItalySubSegment = [SELECT Id, ContactId,Community_Account_Role__c FROM User WHERE Username LIKE '%TestIMCDItalySubSegment'];
		
        Integer index ;
        String busSeg,subSeg,subSeg1,reg,appl,addReg,reg1;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues =	FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Sub_Segment__c);
        index = pckValues.indexOf('Alcoholic Beverages');
        subSeg = index !=-1 ? pckValues[index] : pckValues[0];
        index = pckValues.indexOf('Beverages');
        subSeg1 = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Additional_Region_Responsibility__c);
        index = pckValues.indexOf('Greater China');
        addReg = index !=-1 ? pckValues[index] : pckValues[0] ;
        
        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c FROM Contact WHERE Id = :usrItalySubSegment.ContactId];
        con.Additional_Region_Responsibility__c =addReg;   //'Greater China';
        con.Business_Segment__c =busSeg;   //'Industry';
        con.Sub_Segment__c = subSeg;   //'Alcoholic Beverages';
        con.Region__c =reg;   //'EMEA';
        update con;
		
        pckValues.clear();
        // pckValues =FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Business_Segment__c) ;
        // index = pckValues.indexOf('Industry');
        // busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        // pckValues.clear();
        // pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Sub_Segment__c) ;
        // index = pckValues.indexOf('Beverages');
        // subSeg = index !=-1 ? pckValues[index] :pckValues[0] ;
        
        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt', 'testArt');
        // art.business_segment__c = busSeg;  //'Industry';
        // art.Sub_Segment__c = subSeg; //'Beverages';
        insert art;

        // ROOT
        // appear for all users into proper community +
        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile;
		//fetching picklistValues.	
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Sales_Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        index = pckValues.indexOf('Greater China');
        reg1 = index !=-1 ? pckValues[index] :pckValues[0];
        pckValues.clear();

        // CHILD1
        // appear only for work location +
        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED;
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Work_Location__c = customerLocItaly.Id;
        insert childTile1;

        // appear only for work location -
        Tile__c childTile11 = TestUtility.createTile('childTile11');
        childTile11.Parent_Tile__c = childTile1.Id;
        childTile11.Work_Location__c = customerLocFrance.Id;
        insert childTile11;

        // appear only for food and beverages user +
        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = childTile1.Id;
        childTile12.Business_Segment__c = busSeg; //'Industry';
        childTile12.Article_Name__c = art.Id;
        insert childTile12;

        // appear only for food and beverages and emea region user +
        Tile__c childTile13 = TestUtility.createTile('childTile13');
        childTile13.Parent_Tile__c = childTile1.Id;
        childTile13.Business_Segment__c = busSeg; //'Industry';
        childTile13.Sales_Region__c = reg; //'EMEA';
        childTile13.Article_Name__c = art.Id;
        insert childTile13;

        // appear only for food and beverages and emea region and from italy work location user +
        Tile__c childTile14 = TestUtility.createTile('childTile14');
        childTile14.Parent_Tile__c = childTile1.Id;
        childTile14.Work_Location__c = customerLocItaly.Id;
        childTile14.Business_Segment__c = busSeg; //'Industry';
        childTile14.Sales_Region__c = reg; //'EMEA';
        childTile14.Article_Name__c = art.Id;
        insert childTile14;
		
         
        // appear only for users with EMEA region or additional region as Greater China +
        Tile__c childTile15 = TestUtility.createTile('childTile15');
        childTile15.Parent_Tile__c = childTile1.Id;
        childTile15.Sales_Region__c = reg1; //'Greater China';
        childTile15.Article_Name__c = art.Id;
        insert childTile15;

        // appear only for food and beverages and emea region and from italy work location 
        Tile__c childTile16 = TestUtility.createTile('childTile16');
        childTile16.Parent_Tile__c = childTile1.Id;
        childTile16.Work_Location__c = customerLocItaly.Id;
        childTile16.Business_Segment__c = busSeg; //'Industry';
        childTile16.Sales_Region__c = reg; //'EMEA';
        childTile16.Article_Name__c = art.Id;
        insert childTile16;

        // appear only for italy work location +
        Tile__c childTile17 = TestUtility.createTile('childTile17');
        childTile17.Parent_Tile__c = childTile1.Id;
        childTile17.Work_Location__c = customerLocItaly.Id;
        childTile17.Article_Name__c = art.Id;
        insert childTile17;

        // appear only for italy work location and if user have access to confidential content -
        Confidential_Content__c confCont = new Confidential_Content__c();
        confCont.Name = 'testConfCont';
        insert confCont;

        Tile__c childTile18 = TestUtility.createTile('childTile18');
        childTile18.Parent_Tile__c = childTile1.Id;
        childTile18.Work_Location__c = customerLocItaly.Id;
        childTile18.Confidential_Content__c = confCont.Id;
        insert childTile18;

        // appear only for italy work location and if user have access to confidential content +
        Confidential_Content__c confCont2 = new Confidential_Content__c();
        confCont2.Name = 'testConfCont';
        insert confCont2;

        Confidential_Content__Share confShare = new Confidential_Content__Share();
        confShare.UserOrGroupId = usrItalySubSegment.Id;
        confShare.ParentId = confCont2.Id;
        confShare.AccessLevel = 'Read';
        insert confShare;

        Tile__c childTile19 = TestUtility.createTile('childTile19');
        childTile19.Parent_Tile__c = childTile1.Id;
        childTile19.Work_Location__c = customerLocItaly.Id;
        childTile19.Confidential_Content__c = confCont2.Id;
        insert childTile19;

        // appear only for italy work location +
        Tile__c childTile110 = TestUtility.createTile('childTile110');
        childTile110.Parent_Tile__c = childTile1.Id;
        childTile110.Work_Location__c = customerLocItaly.Id;
        childTile110.File_Public_Link__c = 'testPublicFileLink';
        insert childTile110;

        // CHILD2
        // appear only for france work location -
        Tile__c childTile2 = TestUtility.createTile('childTile2');
        childTile2.Parent_Tile__c = parentMainTile.Id;
        childTile2.Work_Location__c = customerLocFrance.Id;
        insert childTile2;

        // appear only for france work location -
        Tile__c childTile21 = TestUtility.createTile('childTile21');
        childTile21.Parent_Tile__c = childTile2.Id;
        childTile21.Work_Location__c = customerLocFrance.Id;
        childTile21.Article_Name__c = art.Id;
        insert childTile21;

        TriggerHandler.skipTrigger = false;
        
        TileListController.TilesListWrapper tilesWrapperByName;
        TileListController.TilesListWrapper tilesWrapperById;
        TileListController.TilesInfoWrapper tileInfoWrapper;
        System.runAs(usrItalySubSegment) {
            Test.startTest();

            tilesWrapperByName = TileListController.getTileListOnInit('parentTileMainRoot');
            tilesWrapperById = TileListController.getTileListByParent(childTile1.Id);
            tileInfoWrapper = TileListController.getTileInfoByName(childTile110.Name);

            Test.stopTest();
        }

    }

    /*@isTest
    static void shouldShareProperlyApplicationUsers(){

        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');

        User usrItalySubSegment = [SELECT Id, ContactId,Community_Account_Role__c FROM User WHERE Username LIKE '%TestIMCDItalyApplication'];
		
        Integer index ;
        String busSeg,subSeg,subSeg1,reg,appl,addReg,reg1;
        List<String> pckValues = new List<String>();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues =	FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Sub_Segment__c);
        index = pckValues.indexOf('Alcoholic Beverages');
        subSeg = index !=-1 ? pckValues[index] : pckValues[0];
        index = pckValues.indexOf('Beverages');
        subSeg1 = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        pckValues.clear();
        pckValues =FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Application__c);
        index = pckValues.indexOf('Hamburger');
        appl = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Contact.Additional_Region_Responsibility__c);
        index = pckValues.indexOf('Greater China');
        addReg = index !=-1 ? pckValues[index] : pckValues[0] ;
        
        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c, Application__c FROM Contact WHERE Id = :usrItalySubSegment.ContactId];
        con.Additional_Region_Responsibility__c =addReg;   //'Greater China';
        con.Business_Segment__c =busSeg;   //'Industry';
        con.Sub_Segment__c = subSeg;   //'Alcoholic Beverages';
        con.Region__c =reg;   //'EMEA';
        con.Application__c =appl;  //'Hamburger';
        update con;
		
        pckValues.clear();
        // pckValues =FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Business_Segment__c) ;
        // index = pckValues.indexOf('Industry');
        // busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        // pckValues.clear();
        // pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Knowledge__kav.Sub_Segment__c) ;
        // index = pckValues.indexOf('Beverages');
        // subSeg = index !=-1 ? pckValues[index] :pckValues[0] ;
        
        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt', 'testArt');
        // art.business_segment__c = busSeg;  //'Industry';
        // art.Sub_Segment__c = subSeg; //'Beverages';
        insert art;

        // ROOT
        // appear for all users into proper community +
        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile;
		//fetching picklistValues.	
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Business_Segment__c);
        index = pckValues.indexOf('Industry');
        busSeg = index !=-1 ? pckValues[index] : pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Sales_Region__c);
        index = pckValues.indexOf('EMEA');
        reg = index !=-1 ? pckValues[index] : pckValues[0] ;
        index = pckValues.indexOf('Greater China');
        reg1 = index !=-1 ? pckValues[index] :pckValues[0];
        pckValues.clear();
        pckValues = FetchPicklistValueUtilityClass.fetchPickListValues(Tile__c.Application__c);
        index = pckValues.indexOf('Cheese Powder');
        appl = index !=-1 ? pckValues[index] :pckValues[0];
        // CHILD1
        // appear only for work location +
        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED;
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Work_Location__c = customerLocItaly.Id;
        insert childTile1;

        // appear only for work location -
        Tile__c childTile11 = TestUtility.createTile('childTile11');
        childTile11.Parent_Tile__c = childTile1.Id;
        childTile11.Work_Location__c = customerLocFrance.Id;
        insert childTile11;

        // appear only for food and beverages user +
        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = childTile1.Id;
        childTile12.Business_Segment__c = busSeg; //'Industry';
        childTile12.Article_Name__c = art.Id;
        insert childTile12;

        // appear only for food and beverages and emea region user +
        Tile__c childTile13 = TestUtility.createTile('childTile13');
        childTile13.Parent_Tile__c = childTile1.Id;
        childTile13.Business_Segment__c = busSeg; //'Industry';
        childTile13.Sales_Region__c = reg; //'EMEA';
        childTile13.Article_Name__c = art.Id;
        insert childTile13;

        // appear only for food and beverages and emea region and from italy work location user +
        Tile__c childTile14 = TestUtility.createTile('childTile14');
        childTile14.Parent_Tile__c = childTile1.Id;
        childTile14.Work_Location__c = customerLocItaly.Id;
        childTile14.Business_Segment__c = busSeg; //'Industry';
        childTile14.Sales_Region__c = reg; //'EMEA';
        childTile14.Article_Name__c = art.Id;
        insert childTile14;
		
         
        // appear only for users with EMEA region or additional region as Greater China +
        Tile__c childTile15 = TestUtility.createTile('childTile15');
        childTile15.Parent_Tile__c = childTile1.Id;
        childTile15.Sales_Region__c = reg1; //'Greater China';
        childTile15.Article_Name__c = art.Id;
        insert childTile15;

        // appear only for food and beverages and emea region and from italy work location and application Cheese Powder -
        Tile__c childTile16 = TestUtility.createTile('childTile16');
        childTile16.Parent_Tile__c = childTile1.Id;
        childTile16.Work_Location__c = customerLocItaly.Id;
        childTile16.Business_Segment__c = busSeg; //'Industry';
        childTile16.Sales_Region__c = reg; //'EMEA';
        childTile16.Application__c = appl; //'Cheese Powder';
        childTile16.Article_Name__c = art.Id;
        insert childTile16;

        // appear only for italy work location +
        Tile__c childTile17 = TestUtility.createTile('childTile17');
        childTile17.Parent_Tile__c = childTile1.Id;
        childTile17.Work_Location__c = customerLocItaly.Id;
        childTile17.Article_Name__c = art.Id;
        insert childTile17;

        // appear only for italy work location and if user have access to confidential content -
        Confidential_Content__c confCont = new Confidential_Content__c();
        confCont.Name = 'testConfCont';
        insert confCont;

        Tile__c childTile18 = TestUtility.createTile('childTile18');
        childTile18.Parent_Tile__c = childTile1.Id;
        childTile18.Work_Location__c = customerLocItaly.Id;
        childTile18.Confidential_Content__c = confCont.Id;
        insert childTile18;

        // appear only for italy work location and if user have access to confidential content +
        Confidential_Content__c confCont2 = new Confidential_Content__c();
        confCont2.Name = 'testConfCont';
        insert confCont2;

        Confidential_Content__Share confShare = new Confidential_Content__Share();
        confShare.UserOrGroupId = usrItalySubSegment.Id;
        confShare.ParentId = confCont2.Id;
        confShare.AccessLevel = 'Read';
        insert confShare;

        Tile__c childTile19 = TestUtility.createTile('childTile19');
        childTile19.Parent_Tile__c = childTile1.Id;
        childTile19.Work_Location__c = customerLocItaly.Id;
        childTile19.Confidential_Content__c = confCont2.Id;
        insert childTile19;

        // appear only for italy work location +
        Tile__c childTile110 = TestUtility.createTile('childTile110');
        childTile110.Parent_Tile__c = childTile1.Id;
        childTile110.Work_Location__c = customerLocItaly.Id;
        childTile110.File_Public_Link__c = 'testPublicFileLink';
        insert childTile110;

        // CHILD2
        // appear only for france work location -
        Tile__c childTile2 = TestUtility.createTile('childTile2');
        childTile2.Parent_Tile__c = parentMainTile.Id;
        childTile2.Work_Location__c = customerLocFrance.Id;
        insert childTile2;

        // appear only for france work location -
        Tile__c childTile21 = TestUtility.createTile('childTile21');
        childTile21.Parent_Tile__c = childTile2.Id;
        childTile21.Work_Location__c = customerLocFrance.Id;
        childTile21.Article_Name__c = art.Id;
        insert childTile21;

        TileListController.TilesListWrapper tilesWrapperByName;
        TileListController.TilesListWrapper tilesWrapperById;
        TileListController.TilesInfoWrapper tileInfoWrapper;
        System.runAs(usrItalySubSegment) {
            Test.startTest();

            tilesWrapperByName = TileListController.getTileListOnInit('parentTileMainRoot');
            tilesWrapperById = TileListController.getTileListByParent(childTile1.Id);
            tileInfoWrapper = TileListController.getTileInfoByName(childTile110.Name);

            Test.stopTest();
        }

    }*/

    /*@isTest
    static void shouldShareProperlySubSegmentUsersAccountCriteria() {

        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }

        Account customerLocIMCDItaly    = accsMap.get('IMCD Italy Spa');
        Account customerLocIMCDFrance   = accsMap.get('IMCD France Spa');
        Account customerLocDanonePoland = accsMap.get('Danone Poland');

        Account commercialCustIMCD      = accsMap.get('IMCD Holding');
        Account commercialCustDanone    = accsMap.get('Danone SA');

        //Business Segment = Industry
        //Sub-Segment = Beverages
        //Region = EMEA
        //CustLoc = IMCD Italy, Commercial Customer = IMCD Holding
        User usrItalySubSegment = [SELECT Id, ContactId,Community_Account_Role__c FROM User WHERE Username LIKE '%TestIMCDItalySubSegment'];
        
        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c FROM Contact WHERE Id = :usrItalySubSegment.ContactId];
        con.Business_Segment__c = 'Industry';
        con.Sub_Segment__c = 'Food;Beverages';
        con.Region__c = 'EMEA';
        update con;

        // ROOT
        // appear for all users into proper community +
        Tile__c parentMainTile = TestUtility.createTile('parent Tile Main Root');
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_NESTED;
        insert parentMainTile;
        
        List<Tile__c> childTiles = new List<Tile__c>();
        // CHILD1
        // appear only for work location +
        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Business_Segment__c = 'Industry';
        childTile1.Sub_Segment__c = 'Food;Beverages';
        childTile1.Sales_Region__c = 'EMEA';
        childTiles.add(childTile1);

        // CHILD2
        // appear only for france work location -
        Tile__c childTile2 = TestUtility.createTile('childTile2');
        childTile2.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        childTile2.Parent_Tile__c = parentMainTile.Id;
        childTile2.Business_Segment__c = 'Industry';
        childTile2.Sub_Segment__c = 'Food;Beverages';
        childTile2.Sales_Region__c = 'EMEA';
        childTiles.add(childTile2);

        insert childTiles;

        List<Tile__c> subchildTiles = new List<Tile__c>();

        // Sub-childs of ChildTile1 and ChildTile2 
        Tile__c childTile11 = TestUtility.createTile('childTile11');
        childTile11.Parent_Tile__c = childTile1.Id;
        childTile11.Business_Segment__c = 'Industry';
        childTile11.Sub_Segment__c = 'Food;Beverages';
        childTile11.Sales_Region__c = 'EMEA';
        subchildTiles.add(childTile11);

        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = childTile1.Id;
        childTile12.Business_Segment__c = 'Adult Nutrition';
        childTile12.Sub_Segment__c = 'Active Nutrition';
        childTile12.Sales_Region__c = 'EMEA';
        subchildTiles.add(childTile12);

        Tile__c childTile21 = TestUtility.createTile('childTile21');
        childTile21.Parent_Tile__c = childTile2.Id;
        childTile21.Business_Segment__c = 'Industry';
        childTile21.Sub_Segment__c = 'Food;Beverages';
        childTile21.Sales_Region__c = 'EMEA';
        subchildTiles.add(childTile21);

        Tile__c childTile22 = TestUtility.createTile('childTile22');
        childTile22.Parent_Tile__c = childTile2.Id;
        childTile22.Business_Segment__c = 'Adult Nutrition';
        childTile22.Sub_Segment__c = 'Active Nutrition';
        childTile22.Sales_Region__c = 'EMEA';
        subchildTiles.add(childTile22);

        insert subchildTiles;

        // Insert tile visibility Criteria records 

        List<Tile__c> tileVisibilities = new List<Tile__c>();

        Tile__c tileVisibilityChild1 = TestUtility.createTile('tileVisibilityChild1');
        tileVisibilityChild1.Tile_Related__c = childTile1.Id;
        tileVisibilityChild1.Sharing_Criteria__c = Constants.TILE_ACCOUNT_CRITERIA_SHARE_WITH;
        tileVisibilityChild1.Parent_Account__c = commercialCustIMCD.Id;
        tileVisibilities.add(tileVisibilityChild1);

        Tile__c tileVisibilityChild11 = TestUtility.createTile('tileVisibilityChild11');
        tileVisibilityChild11.Tile_Related__c = childTile11.Id;
        tileVisibilityChild11.Sharing_Criteria__c = Constants.TILE_ACCOUNT_CRITERIA_SHARE_WITH;
        tileVisibilityChild11.Work_Location__c = customerLocIMCDItaly.Id;
        tileVisibilities.add(tileVisibilityChild11);

        Tile__c tileVisibilityChild12 = TestUtility.createTile('tileVisibilityChild12');
        tileVisibilityChild12.Tile_Related__c = childTile12.Id;
        tileVisibilityChild12.Sharing_Criteria__c = Constants.TILE_ACCOUNT_CRITERIA_DO_NOT_SHARE_WITH;
        tileVisibilityChild12.Parent_Account__c = commercialCustIMCD.Id;
        tileVisibilities.add(tileVisibilityChild12);

        Tile__c tileVisibilityChild21 = TestUtility.createTile('tileVisibilityChild21');
        tileVisibilityChild21.Tile_Related__c = childTile21.Id;
        tileVisibilityChild21.Sharing_Criteria__c = Constants.TILE_ACCOUNT_CRITERIA_DO_NOT_SHARE_WITH;
        tileVisibilityChild21.Parent_Account__c = commercialCustIMCD.Id;
        tileVisibilities.add(tileVisibilityChild21);

        Tile__c tileVisibilityChild22 = TestUtility.createTile('tileVisibilityChild22');
        tileVisibilityChild22.Tile_Related__c = childTile22.Id;
        tileVisibilityChild22.Sharing_Criteria__c = Constants.TILE_ACCOUNT_CRITERIA_DO_NOT_SHARE_WITH;
        tileVisibilityChild22.Parent_Account__c = commercialCustDanone.Id;
        tileVisibilities.add(tileVisibilityChild22);

        insert tileVisibilities;

        TileListController.TilesListWrapper tilesWrapperByName;
        TileListController.TilesListWrapper tilesWrapperByIdChild1;
        TileListController.TilesListWrapper tilesWrapperByIdChild2;

        System.runAs(usrItalySubSegment) {
            Test.startTest();

            tilesWrapperByName = TileListController.getTileListOnInit('parent Tile Main Root');
            tilesWrapperByIdChild1 = TileListController.getTileListByParent(childTile1.Id);
            tilesWrapperByIdChild2 = TileListController.getTileListByParent(childTile2.Id);

            Test.stopTest();
        }

        System.assertEquals(false, String.isBlank(tilesWrapperByName.DisplayOption));
        System.assertEquals(false, tilesWrapperByName.TilesAsTiles.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsList.isEmpty());
        System.assertEquals(false, tilesWrapperByName.TilesAsNestedList.isEmpty());

        System.assertEquals(Constants.TILE_CHILD_TYPE_NESTED, tilesWrapperByName.DisplayOption);
        System.assertEquals(2, tilesWrapperByName.TilesAsNestedList.size());
        System.assertEquals('childTile1', tilesWrapperByName.TilesAsNestedList.get(0).name);
        System.assertEquals('childTile2', tilesWrapperByName.TilesAsNestedList.get(1).name);

        System.assertEquals(1, tilesWrapperByName.TilesAsNestedList.get(1).items.size());
        System.assertEquals('childTile21', tilesWrapperByName.TilesAsNestedList.get(1).items.get(0).name);
        //System.assertEquals('childTile21', tilesWrapperByName.TilesAsNestedList.get(1).items.get(1).name);

        System.assertEquals(1, tilesWrapperByName.TilesAsNestedList.get(0).items.size());
        System.assertEquals('childTile11', tilesWrapperByName.TilesAsNestedList.get(0).items.get(0).name);
        //System.assertEquals('childTile12', tilesWrapperByName.TilesAsNestedList.get(0).items.get(1).name);

        System.assertEquals(Constants.TILE_CHILD_TYPE_LIST, tilesWrapperByIdChild1.DisplayOption);
        System.assertEquals(0, tilesWrapperByIdChild1.TilesAsTiles.size());
        System.assertEquals(0, tilesWrapperByIdChild1.TilesAsList.size());
        System.assertEquals(0, tilesWrapperByIdChild1.TilesAsNestedList.size());
        //System.assertEquals('childTile11', tilesWrapperByIdChild1.TilesAsNestedList.get(0).name);

        System.assertEquals(Constants.TILE_CHILD_TYPE_LIST, tilesWrapperByIdChild2.DisplayOption);
        //System.debug(tilesWrapperByIdChild2.TilesAsTiles);
        System.assertEquals(0, tilesWrapperByIdChild2.TilesAsTiles.size());
        System.assertEquals(0, tilesWrapperByIdChild2.TilesAsList.size());
        System.assertEquals(0, tilesWrapperByIdChild2.TilesAsNestedList.size());

    }*/
    @isTest()
    static void getTiles() {
        TileUtility.setTileWholeTileStructureFromMainTile('');
        TileUtility.getAllEndTilesTreeFromRoot('');        
    }
}