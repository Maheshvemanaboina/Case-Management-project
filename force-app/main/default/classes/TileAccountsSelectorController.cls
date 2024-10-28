public with sharing class TileAccountsSelectorController {
    
    @AuraEnabled
    public static List<Account> getAvailableAccounts(Boolean isH1Account, Boolean isH5Account) {
        List<Account> accounts = new List<Account>();
        
        if (isH1Account) {
                accounts = [SELECT Id, Name, SAP_Number__c FROM Account 
                            WHERE ParentId = null 
                            AND Active__c = TRUE 
                            AND RecordType.name = 'Commercial Customer'
                        ];
        }
        
        if (isH5Account) {
            accounts = [SELECT Id, Name, SAP_Number__c FROM Account 
                        WHERE ParentId != null 
                        AND Active__c = TRUE 
                        AND RecordType.name = 'Customer Location'];
        }
        
        return accounts;
    }
}