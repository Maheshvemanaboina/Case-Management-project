/*
 * Class Name-CustomSearchControllerTest
 * Description-Test class for CustomSearchController
 * Updated on 30/05/2024
*/

@isTest
public class CustomSearchControllerTest 
{
    
     @testSetup
    static void setup() {
       TestUtility.createInitialTestAccountsAndUsers();
    }
	 @isTest
    static void testSearchForIds() 
    {
        List<Account> accs = [SELECT Id, Name FROM Account];
        Map<String, Account> accsMap = new Map<String, Account>();
        for (Account acc : accs) {
            accsMap.put(acc.Name, acc);
        }
        Account customerLocItaly = accsMap.get('IMCD Italy Spa');
        Account customerLocFrance = accsMap.get('IMCD France Spa');

        User usrItaly = [SELECT Id, ContactId FROM User WHERE Username LIKE '%TestIMCDItaly'];
	    
        Contact con = [SELECT Id, Additional_Region_Responsibility__c, Business_Segment__c, Sub_Segment__c, Region__c FROM Contact WHERE Id = :usrItaly.ContactId];
        con.Additional_Region_Responsibility__c = 'Greater China';   //'Greater China';
        con.Business_Segment__c = 'Industry';   //'Industry';
        con.Sub_Segment__c = 'Beverages';   //'Alcoholic Beverages';
        con.Region__c = 'EMEA';   //'EMEA';
        update con;
        
        Knowledge__kav art = TestUtility.createKnowledgeKav('testArt123', 'testArt123');
        art.Language = 'en_US';
        // art.business_segment__c =busSeg;  //'Industry';
        // art.Sub_Segment__c = subSeg;  //'Beverages';
        insert art;

        Knowledge__kav art2 = TestUtility.createKnowledgeKav('testArt1234', 'testArt1234');
        art2.Language = 'en_US';
        // art2.business_segment__c =busSeg;   //'Industry';
        // art2.Sub_Segment__c = subSeg;  //'Beverages';
        insert art2;

        Knowledge__kav art3 = TestUtility.createKnowledgeKav('testArt12345', 'testArt12345');
        art3.Language = 'en_US';
        // art3.business_segment__c = busSeg;   //'Industry';
        // art3.Sub_Segment__c =subSeg;    //'Beverages';
        insert art3;

        // ROOTS
        Tile__c parentMainTile = TestUtility.createTile('parentTileMainRoot');
        parentMainTile.Is_Main_Tile__c=true;
        parentMainTile.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile;

        Tile__c parentMainTile2 = TestUtility.createTile('parentTileMainRoot2');
        parentMainTile2.Is_Main_Tile__c=true;
        parentMainTile2.Child_Display_Option__c = Constants.TILE_CHILD_TYPE_LIST;
        insert parentMainTile2;

        // CHILDS article
        // not visible because another work location
        Tile__c childTile1 = TestUtility.createTile('childTile1');
        childTile1.Parent_Tile__c = parentMainTile.Id;
        childTile1.Work_Location__c = customerLocFrance.Id;
        childTile1.Article_Name__c = art3.Id;
        insert childTile1;

        Tile__c childTile12 = TestUtility.createTile('childTile12');
        childTile12.Parent_Tile__c = parentMainTile.Id;
        childTile12.Work_Location__c = customerLocItaly.Id;
        childTile12.Article_Name__c = art.Id;
        insert childTile12;

        // confidential contents
        Confidential_Content__c confCont = new Confidential_Content__c();
        confCont.Name = 'testConfCont';
        insert confCont;

        Confidential_Content__c confCont2 = new Confidential_Content__c();
        confCont2.Name = 'testConfCont2';
        insert confCont2;

        Confidential_Content__Share confShare = new Confidential_Content__Share();
        confShare.UserOrGroupId = usrItaly.Id;
        confShare.ParentId = confCont.Id;
        confShare.AccessLevel = 'Read';
        insert confShare;

        Tile__c childTile13 = TestUtility.createTile('childTile13');
        childTile13.Parent_Tile__c = parentMainTile.Id;
        childTile13.Work_Location__c = customerLocItaly.Id;
        childTile13.Confidential_Content__c = confCont.Id;
        insert childTile13;

        Tile__c childTile14 = TestUtility.createTile('childTile14');
        childTile14.Parent_Tile__c = parentMainTile.Id;
        childTile14.Work_Location__c = customerLocItaly.Id;
        childTile14.Confidential_Content__c = confCont2.Id;
        insert childTile14;

        Tile__c childTile15 = TestUtility.createTile('testFileChildTile15');
        childTile15.Parent_Tile__c = parentMainTile.Id;
        childTile15.Work_Location__c = customerLocItaly.Id;
        childTile15.File_Public_Link__c = 'publiclinktofile';
        insert childTile15;

        // child parent -
        Tile__c childTile16 = TestUtility.createTile('childTile16');
        childTile16.Parent_Tile__c = parentMainTile.Id;
        childTile16.Work_Location__c = customerLocItaly.Id;
        insert childTile16;

        // child child parent +
        Tile__c childTile161 = TestUtility.createTile('testFilechildTile161');
        childTile161.Parent_Tile__c = childTile16.Id;
        childTile161.Work_Location__c = customerLocItaly.Id;
        childTile161.File_Public_Link__c = 'publiclinktofile';
        insert childTile161;

        Tile__c childTile162 = TestUtility.createTile('childTile162');
        childTile162.Parent_Tile__c = childTile16.Id;
        childTile162.Work_Location__c = customerLocItaly.Id;
        insert childTile162;

        Tile__c childTile1621 = TestUtility.createTile('childTile1621');
        childTile1621.Parent_Tile__c = childTile162.Id;
        childTile1621.Work_Location__c = customerLocItaly.Id;
        childTile1621.Article_Name__c = art2.Id;
        insert childTile1621;

        Tile__c childTile1622 = TestUtility.createTile('teFilechildTile1622');
        childTile1622.Parent_Tile__c = childTile162.Id;
        childTile1622.Work_Location__c = customerLocItaly.Id;
        childTile1622.File_Public_Link__c = 'publiclinktofiletest';
        insert childTile1622;

        List<CustomSearchController.SearchResultWrapper> searchResultHandler=new List<CustomSearchController.SearchResultWrapper>();
        String searchText = 'test';
		
        TriggerHandler.skipTrigger = false;
        System.runAs(usrItaly)
        {
            Test.startTest();

            Id[] fixedSearchResults = new Id[4];
            fixedSearchResults[0] = art.Id;
            fixedSearchResults[1] = art2.Id;
            fixedSearchResults[2] = confCont.Id;
            fixedSearchResults[3] = customerLocItaly.Id;
            Test.setFixedSearchResults(fixedSearchResults);

            searchResultHandler = CustomSearchController.searchForIds(searchText);

            Test.stopTest();
        }
    }
}