/*************************************************************************************************************************************
 Created By:   Rohit Kumar
 Created Date: 28/10/2020
 Description : This class will delete all COA, which are fetched from the SAP,through DisplayAndDownloadCoA component, in every 30 days
***************************************************************************************************************************************/
global class DeleteCertificateOfAnalysisFromSFDCBatch implements Database.Batchable<sObject>{
    
    global static Database.QueryLocator start(Database.BatchableContext context){
        Id coARecordTypeId = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        string listOfTileToDelete='select id,name,RecordTypeId from Tile__c where RecordTypeId=:coARecordTypeId';
        return Database.getQueryLocator(listOfTileToDelete);
    }
    
    global static void execute(Database.BatchableContext context, List<sObject> scope){
        
        List<Tile__c> tileList = (List<Tile__c>)scope;
        List<Id>  tileId = new List<Id>();
        List<Id> contentId = new List<Id>();
        List<ContentDocument> contentDocuments = new List<ContentDocument>();
        
        
        if(tileList.size()>0)
        for(Tile__c t:tileList){
            tileId.add(t.id);
        }
        
        if(tileId.size()>0)
        for(ContentDocumentLink content:[select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN:tileid]){
            contentId.add(content.ContentDocumentId);
        }
        
        if(contentId.size()>0){
            
        contentDocuments = [select id from ContentDocument where id in:contentId];
       
        delete contentDocuments;
        delete tileList;
        
        }    
        
    }
    
    global void finish(Database.BatchableContext context){
        
    }
}