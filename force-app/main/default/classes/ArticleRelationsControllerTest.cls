/**
 * Created by KJM on 17/05/2019.
 */

@isTest
public class ArticleRelationsControllerTest {
    @isTest
    static void shouldReturnOneArticleRelationsDECustomerPortal(){
        CommunityUtility.communityOptionsInstance = TestUtility.getCommunityOptions();

        /// certificate
        Knowledge__kav knowlCert = TestUtility.createKnowledgeKav('testTitle', 'testURLName');
        knowlCert.business_segment__c = 'Industry;';
        knowlCert.Sub_Segment__c = 'Beverages;';
        insert knowlCert;

        Tile__c tlCert = TestUtility.createTile('testUIName');
        tlCert.Article_Name__c = knowlCert.Id;
        insert tlCert;

        /// product spec - fit all requirements
        Knowledge__kav knowlProd = TestUtility.createKnowledgeKav('testTitle2', 'testURLName2');
        knowlProd.business_segment__c = 'Industry;';
        knowlProd.Sub_Segment__c = 'Beverages;';
        insert knowlProd;

        Tile__c tlProd = TestUtility.createTile('testUIName2');
        tlProd.Article_Name__c = knowlProd.Id;
        insert tlProd;

        /// product spec 2 - not fit application requirement
        Knowledge__kav knowlProd2 = TestUtility.createKnowledgeKav('testTitle3', 'testURLName3');
        knowlProd2.business_segment__c = 'Industry;';
        knowlProd2.Sub_Segment__c = 'Beverages;';
        insert knowlProd2;

        // Tile__c tlProd2 = TestUtility.createTile('testUIName3');
        // tlProd2.Application__c = 'Cheese Powder;';
        // tlProd2.Article_Name__c = knowlProd2.Id;
        // insert tlProd2;

        /// relations
        Related_Tile__c rel = TestUtility.createRelatedTile(tlProd, tlCert, Constants.TILE_TYPE_CERTIFICATE);
        insert rel;

        // Related_Tile__c rel2 = TestUtility.createRelatedTile(tlProd2, tlCert, Constants.TILE_TYPE_CERTIFICATE);
        // insert rel2;

        String relatedArt;
        System.runAs(TestUtility.createDECustomerPortalUser('testKrzysUser@flc.com.test.PCU', null)) {
            Test.startTest();

            relatedArt = ArticleRelationsController.getRelatedArticles(knowlCert.Id);

            Test.stopTest();
        }
        system.debug(JSON.serialize(relatedArt));
        List<TreeItemElement> relatedArts = (List<TreeItemElement>)JSON.deserialize(relatedArt, List<TreeItemElement>.class);
        System.assertEquals(1, relatedArts.size());
        System.assertEquals('Related Product Specifications', relatedArts.get(0).label);
        System.assertEquals(false, relatedArts.get(0).items.isEmpty());
        System.assertEquals('testUIName2', relatedArts.get(0).items.get(0).name);
    }
    @isTest
    static void shouldReturnArticleRelationsPartnerPortal() {
        /// certificate
        Knowledge__kav knowlCert = TestUtility.createKnowledgeKav('testTitle', 'testURLName');
        // knowlCert.business_segment__c = 'Industry;';
        // knowlCert.Sub_Segment__c = 'Beverages;';
        insert knowlCert;

        Tile__c tlCert = TestUtility.createTile('testUIName');
        tlCert.Article_Name__c = knowlCert.Id;
        insert tlCert;

        /// product spec
        Knowledge__kav knowlProd = TestUtility.createKnowledgeKav('testTitle2', 'testURLName2');
        // knowlProd.business_segment__c = 'Industry;';
        // knowlProd.Sub_Segment__c = 'Beverages;';
        insert knowlProd;

        Tile__c tlProd = TestUtility.createTile('testUIName2');
        tlProd.Article_Name__c = knowlProd.Id;
        insert tlProd;

        /// product spec 2
        Knowledge__kav knowlProd2 = TestUtility.createKnowledgeKav('testTitle3', 'testURLName3');
        // knowlProd2.business_segment__c = 'Industry;';
        // knowlProd2.Sub_Segment__c = 'Beverages;';
        insert knowlProd2;

        Tile__c tlProd2 = TestUtility.createTile('testUIName3');
        tlProd2.Article_Name__c = knowlProd2.Id;
        insert tlProd2;

        Related_Tile__c rel = TestUtility.createRelatedTile(tlProd, tlCert, Constants.TILE_TYPE_CERTIFICATE);
        insert rel;
        Related_Tile__c rel2 = TestUtility.createRelatedTile(tlProd2, tlProd, Constants.RELATED_TILE_TYPE_RECOMMENDED_PRODUCTS);
        insert rel2;
        String relatedArt;
        System.runAs(TestUtility.createPartnerPortalUser('testPartner367@coreflexsolutions.com', null)) {
            Test.startTest();
            relatedArt = ArticleRelationsController.getRelatedArticles(knowlProd.Id);
			system.debug('relatedArt-->'+relatedArt);
            Test.stopTest();
        }        
       List<TreeItemElement> relatedArts = (List<TreeItemElement>)JSON.deserialize(relatedArt, List<TreeItemElement>.class);
        System.assertEquals(Constants.TILE_TYPE_CERTIFICATE, relatedArts.get(0).name);
        System.assertEquals(false, relatedArts.get(0).items.isEmpty());
        System.assertEquals('testUIName', relatedArts.get(0).items.get(0).name);
    }
    
    @isTest
    static void testGetArticleRelationsListFromCertificate() {
        Knowledge__kav knowlCert = TestUtility.createKnowledgeKav('testTitle', 'testURLName');
        insert knowlCert;
    
        Tile__c tlCert = TestUtility.createTile('testUIName');
        tlCert.Article_Name__c = knowlCert.Id;
        insert tlCert;
    
        // Create related Tile__c records
        Knowledge__kav relatedKnowl = TestUtility.createKnowledgeKav('relatedTitle', 'relatedURLName');
        insert relatedKnowl;
    
        Tile__c relatedTile = TestUtility.createTile('relatedUIName');
        relatedTile.Article_Name__c = relatedKnowl.Id;
        insert relatedTile;
    
        // Create Related_Tile__c records linking tlCert to relatedTile
        Related_Tile__c rel = new Related_Tile__c();
        rel.Tile__c = tlCert.Id;
        rel.Related_Tile__c = relatedTile.Id;
        rel.Related_Tile_Type__c = 'Finished Product Specification';
        insert rel;
    
        // Prepare input data for the method
        Map<String, List<Related_Tile__c>> tileMapByType = new Map<String, List<Related_Tile__c>>();
        List<Related_Tile__c> relatedTiles = new List<Related_Tile__c>();
        relatedTiles.add(rel);
        tileMapByType.put('Product Specification', relatedTiles);
    
        Test.startTest();
         List<TreeItemElement> result = ArticleRelationsService.getArticleRelationsListFromCertificate(tileMapByType);
        Test.stopTest();
    
        // Perform assertions based on the expected behavior
        System.assertEquals(1, result.size());
        System.assertEquals(Constants.TILE_TYPE_PRODUCT_SPECIFICATION, result[0].name);
        System.assertEquals(false, result[0].items.isEmpty());
    }

}