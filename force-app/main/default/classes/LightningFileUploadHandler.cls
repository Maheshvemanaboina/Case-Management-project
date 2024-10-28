/* *******************************************************************************************************
 * Name               : LightningFileUploadHandler                                                       *
 * Description        : SRM - Controller for aura methods                                                      *
 * Created Date       : 25-07-2020                                                                       *
 * Created By         : Szymon Szczepański                                                               *
 * -----------------------------------------------------------------------------------------------       *
 * VERSION    AUTHOR            DATE                                                                     *
 *   1.0 -    sszcz              25-07-2020 Initial version                                              *
 *                                                                                                       *
 *                                                                                                       *
 ******************************************************************************************************* */
public Without sharing class LightningFileUploadHandler {
    
    @AuraEnabled  
    public static List<ContentDocument> getFiles(String recordId){
        system.debug('getfileds called ');
        Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM
                                             ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];                         
        Set<Id> documentIds = new Set<Id>(); 
        for(ContentDocumentLink cdl:cdlList){  
            documentIds.add(cdl.ContentDocumentId);  
        }
        System.debug([SELECT Id, Title, FileType, (SELECT Id, Category__c FROM ContentVersions ORDER BY CreatedDate DESC LIMIT 1) FROM ContentDocument WHERE Id IN :documentIds]);

        return [SELECT Id, Title, FileType, (SELECT Category__c FROM ContentVersions ORDER BY CreatedDate DESC LIMIT 1) FROM ContentDocument WHERE Id IN :documentIds];
    } 
    
    @AuraEnabled  
    public static void deleteThisFile(String contentDocumentId){
        System.debug('delete attempt');
        delete [SELECT Id from ContentDocument WHERE Id = :contentDocumentId];
    }

    @AuraEnabled
    public static void updateFileCategory(String recordId, String category){
        system.debug('#########updated category called '+ category + ' '+ recordId);
        
        Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM
                ContentDocumentLink WHERE LinkedEntityId IN :recordIds
        ];
        Set<Id> documentIds = new Set<Id>();
        for(ContentDocumentLink cdl:cdlList){
            documentIds.add(cdl.ContentDocumentId);
        }
        ContentDocument contentDocument = [SELECT Id, Title, FileType, (SELECT Id FROM ContentVersions ORDER BY CreatedDate DESC LIMIT 1) FROM ContentDocument WHERE Id IN :documentIds ORDER BY LastModifiedDate DESC ][0];
        System.debug(contentDocument.ContentVersions[0].Id);
        ContentVersion contentVersion = [SELECT Category__c FROM ContentVersion WHERE Id = :contentDocument.ContentVersions[0].Id LIMIT 1];
        System.debug(contentVersion);
        contentVersion.Category__c = category;
        System.debug(contentVersion);
        try{
           update contentVersion; 
        }catch(exception e){
            system.debug('####### following exception '+ e.getMessage());
        }
        
        //system.assertEquals(1, 2);
    }

    /**
     * @description: if recordId is type of Account, then return Supplier Hub Id insted
     * @return same or modified (if was account id) recordId
     */
    @AuraEnabled
    public static String getProperRecordId(String recordId) {
        if(Id.valueOf(recordId).getSobjectType() == Schema.Account.SObjectType) {
            recordId = [SELECT Id FROM Supplier_Hub__c WHERE Supplier_Account__c = :recordId].Id;
        }
        return recordId;
    }

    /**
     * @description: build Category__c picklist values and labels
     * @return
     */
    @AuraEnabled
    public static List<SelectOptionWrapper> getCategoryOptions() {
        List<SelectOptionWrapper> selectOptions = new List<SelectOptionWrapper> ();
        selectOptions.add(new SelectOptionWrapper('', 'Select'));
        Map<String, String> picklists = Utils.getPicklistValues(ContentVersion.sObjectType, 'Category__c');
        for (String value : picklists.keySet()) {
            selectOptions.add(new SelectOptionWrapper(value, picklists.get(value)));
        }
        return selectOptions;
    }
    @AuraEnabled
    public static void updateExistingCategory(String recordId, String category) {
            ContentVersion contentVersion = [SELECT Category__c FROM ContentVersion WHERE Id = :recordId];
            contentVersion.Category__c = category;
            try{
               update contentVersion; 
            }catch(exception e){
                system.debug('####### following exception '+ e.getMessage());
            }
    }

    /**
     * wrapper for a picklist value list
     */
    public class SelectOptionWrapper {
        @AuraEnabled
        public String value;

        @AuraEnabled
        public String label;

        public SelectOptionWrapper(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }
}