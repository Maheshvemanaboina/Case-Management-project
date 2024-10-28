/*
 * Class Name-CustomSearchController
 * Description-This class is used as a controller for customSearch LWC and CustomSearchResults LWC component
*/

public with sharing class CustomSearchController {
    // Wrapper class to represent search results
    public class SearchResultWrapper {
        @AuraEnabled
        public String objectName { get; set; }       //Stores the object name
        @AuraEnabled
        public String objectNamePlural { get; set; } //Stores the plural name of object
        @AuraEnabled
        public String recordName { get; set; }       //Stores the recordname
        @AuraEnabled
        public String recordId { get; set; }         // Stores the record id
        @AuraEnabled
        public String redirectUrl { get; set; }      // the redirecturl
        @AuraEnabled
        public Boolean isFile { get; set; }
    }
    
    @AuraEnabled
    public static List<SearchResultWrapper> searchForIds(String searchText) {
        //Id currentNetworkId = Network.getNetworkId();
        String networkName = (Test.isRunningTest()) ?  'FC Distributor Community' : ConnectApi.Communities.getCommunity(Network.getNetworkId()).name;
        //Network networkName = [SELECT Id, Name, UrlPathPrefix FROM Network WHERE Id = :currentNetworkId];
        System.debug('networkName'+networkName);
        //creating the base url
        String baseUrl =(Test.isRunningTest()) ?  'https://yourcommunityurl.com/login' : Network.getLoginUrl( Network.getNetworkId() );
        if (baseUrl.endsWith('/login')) {
            // Remove the '/logins/' part
            baseUrl = baseUrl.substring(0, baseUrl.length() - '/login'.length());
        }
        system.debug('baseUrl'+baseUrl);
        //List<String> objectNames = new List<String>{'Account', 'Contact','Lead'};
        Map<String,String>ObjTypeFieldMap=new Map<String,string>();
        List<Custom_Search_Object_Setting__mdt> objectNames = [Select Id,Object_API_Name__c,Search_Field__c,Community_Name__c From Custom_Search_Object_Setting__mdt];
        //newtry
        boolean haveKnowledgeItem=false;
        boolean haveObjectToSearch=false;
        //endtry
        // Build SOSL query dynamically based on objectNames parameter
        String query = 'FIND :searchText IN All FIELDS RETURNING ';
        for (Custom_Search_Object_Setting__mdt objName : objectNames) {
            /*ObjTypeFieldMap.put(objName.Object_API_Name__c,objName.Search_Field__c);
            if(objName.Object_API_Name__c!='Knowledge__kav')
            {
            	query += objName.Object_API_Name__c + '(Id,'+objName.Search_Field__c +'), ';
            }
            else
            {
                haveKnowledgeItem=true;
            }*/
            List<String> CommunityNameList=new List<String>();
            if(objName.Community_Name__c!=Null)
            {
            	CommunityNameList = objName.Community_Name__c.split(',');
                //System.debug('CommunityNameList--->'+CommunityNameList);
            }
            ObjTypeFieldMap.put(objName.Object_API_Name__c,objName.Search_Field__c);
            if(objName.Object_API_Name__c!='Knowledge__kav' && CommunityNameList.contains(networkName))
            {
            	query += objName.Object_API_Name__c + '(Id,'+objName.Search_Field__c +'), ';
                haveObjectToSearch=true;
            }
            if(objName.Object_API_Name__c=='Knowledge__kav' && CommunityNameList.contains(networkName))
            {
                haveKnowledgeItem=true;
                haveObjectToSearch=true;
            }
        }
        query = query.removeEnd(', '); // Remove trailing comma
        
        System.debug('New Created Query: ' + query);
        List<List<SObject>> results=new List<List<SObject>>();
        if(haveObjectToSearch==true)
        {
            // Execute the SOSL query
            results = Search.query(query);
        }
        
        List<SearchResultWrapper> records = new List<SearchResultWrapper>();
        // Process search results
        if(results!=Null)
        {            
            for (List<SObject> sobjs : results) {
                for (SObject sobj : sobjs) {
                    SearchResultWrapper recordInfo = new SearchResultWrapper();    
                    recordInfo.objectName = sobj.getSObjectType().getDescribe().getName();
                    Schema.DescribeSObjectResult objDescribe = sobj.getSObjectType().getDescribe();
                    recordInfo.objectNamePlural=objDescribe.getLabelPlural();
                    recordInfo.recordName = String.valueOf(sobj.get(ObjTypeFieldMap.get(sobj.getSObjectType().getDescribe().getName())));
                    recordInfo.recordId = String.valueOf(sobj.get('Id'));
                    // Add default values for RedirectUrl and IsFile properties
                    recordInfo.redirectUrl = baseUrl+'/detail/'+String.valueOf(sobj.get('Id')); // Add your logic to determine redirect URL
                    recordInfo.isFile = false; // Add your logic to determine if it's a file
                    records.add(recordInfo);
                }
            }
        }
        if(haveKnowledgeItem==true)
        {
            System.debug('inside haveKnowledgeItem');
            //TilesSearchController.CustomSearchResultHandler knowledgeReturned=TilesSearchController.searchForObjs(searchText,'FCI Distributor Product Main Tile');
            //System.debug('knowledgeReturnedt->'+knowledgeReturnedt);
            //List<String> tileListStr=new List<String>{'FCI Distributor Product Main Tile','FCI Distributor Recipes Main Tile'};
            List<String> tileListStr=new List<String>();
			List<Tile__c> tileList=[Select id,Name,Is_Main_Tile__c FROM Tile__c WHERE Is_Main_Tile__c=True ];
            for(Tile__c tl:tileList)
            {
                tileListStr.add(tl.Name);
            }
            System.debug('tileListStr-->'+tileListStr+'size->'+tileListStr.size());
            CustomTileSearchController.CustomSearchResultHandler knowledgeReturned=CustomTileSearchController.searchForObjs(searchText,tileListStr);
            System.debug(knowledgeReturned);
            if(knowledgeReturned.ResultList.size()>0)
            {
                for (CustomTileSearchController.CustomSearchResultItemHandler knowledgeResult : knowledgeReturned.ResultList) 
                {
                    SearchResultWrapper knowledgeRecord = new SearchResultWrapper();
                    knowledgeRecord.objectName = knowledgeResult.ObjType;
                    knowledgeRecord.objectNamePlural='Articles';
                    knowledgeRecord.recordName = knowledgeResult.ObjName;
                    //knowledgeRecord.recordId = knowledgeResult.recordId;
                    knowledgeRecord.redirectUrl = knowledgeResult.redirectUrl;
                    knowledgeRecord.isFile = knowledgeResult.IsFile;
                    records.add(knowledgeRecord);
                }
            }            
        }
        System.debug('search records: ' + records);
        return records;
    }
}