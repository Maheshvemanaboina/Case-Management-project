public without sharing class COAUploadService {
    
    public static Tile__c docTile;
        
    @AuraEnabled
    public static List<sObject> fetchYear(String searchKeyWord,String ObjectName) {
        if(searchKeyWord != null && !String.isBlank(searchKeyWord)){
            List<sObject> returnList = new List<sObject>();
            String searchStr1 = '*' + searchKeyWord + '*';
            String searchQuery = 'FIND \'' + searchStr1 + '\' IN ALL FIELDS RETURNING  Tile__c (Id,UI_Name__c WHERE Parent_Tile__c =\''+getDocumentTile().Id+'\') LIMIT 10';
            List<List<sObject>> searchList = search.query(searchQuery);
            for(Tile__c Tl : (List<Tile__c>)searchList[0]){
                returnList.add(Tl);
            }
            return returnList;
        }
        else{
            List<Tile__c> tilelist = [SELECT Id,UI_Name__c from Tile__c where Parent_Tile__c =: getDocumentTile().Id];
            return (List<sObject>)tilelist;
        }
        //return returnList;
    }
    
    @AuraEnabled
    public static List<sObject> fetchMonthName(String searchKeyWord,sObject parentRecord) {
        Tile__c tile = (Tile__c)parentRecord;
        if(searchKeyWord != null && !String.isBlank(searchKeyWord)){
            List<sObject> returnList = new List<sObject>();
            String searchStr1 = '*' + searchKeyWord + '*';
            String searchQuery = 'FIND \'' + searchStr1 + '\' IN ALL FIELDS RETURNING  Tile__c (Id,UI_Name__c WHERE Parent_Tile__c =\''+tile.Id+'\' ) LIMIT 10';
            List<List<sObject>> searchList = search.query(searchQuery);
            
            for(Tile__c Tl : (List<Tile__c>)searchList[0]){
                returnList.add(Tl);
            }
            return returnList;
        }
        else{
            List<Tile__c> tilelist = [Select Id,UI_Name__c from Tile__c where Parent_Tile__c =: tile.Id];
            return (List<sObject>)tilelist;
        }
    }
    
    @AuraEnabled
    public static Tile__c saveRecord(String yearId,String monthId,String prdGrpId,String shipToId,String workLocId,String fileName,String base64Data,String contentType,String TileName){
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        System.debug('yearId --> '+yearId);
        System.debug('monthId --> '+monthId);
        System.debug('prdGrpId --> '+prdGrpId);
        System.debug('shipToId --> '+shipToId);
        System.debug('workLocId --> '+workLocId);
        
        
        Tile__c Tl = new Tile__c();
        Tl.Name = TileName;
        Tl.RecordTypeId = Constants.TILE_ORDER_AND_DELIVERY_RECORD_TYPE;
        Tl.UI_Name__c = TileName;
        Tl.Work_Location__c = workLocId;
        //tl.Ship_To_Location__c = shipToId;
        //Tl.File_Public_Link__c = contdis.DistributionPublicUrl;
        Tl.Parent_Tile__c = shipToId;
        Tl.Community_Name__c = 'FCI Customer Community';
        insert Tl; 
        
        
        Attachment a = new Attachment();
        a.parentId = Tl.Id;
        
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        insert a;
        
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = a.Name;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = a.OwnerId;//Owner of the file
        cVersion.Title = a.Name;//Name of the file
        cVersion.VersionData = a.Body;//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = a.ParentId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        
        ContentDistribution cd = new ContentDistribution();
        cd.Name = a.Name;
        cd.ContentVersionId = cVersion.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        
        ContentDistribution contdis = [select DistributionPublicUrl from ContentDistribution where ContentDocumentId = :cDocLink.ContentDocumentId];
        System.debug('cd url --> '+contdis.DistributionPublicUrl);
        
        Tile__c updTl = [SELECT Id,UI_Name__c,File_Public_Link__c from Tile__c where Id =:Tl.Id ];
        updTl.File_Public_Link__c = contdis.DistributionPublicUrl;
        update updTl;
        
        return updTl;
        //return Tl;
    }
    
    private static Tile__c getDocumentTile(){
        if(docTile == null){
            //docTile = new Tile__c();
            docTile = [SELECT Id from Tile__c where Name = 'Certificate of Analysis'];
            return docTile;
        }
        else{
            return docTile;
        }
    }
}