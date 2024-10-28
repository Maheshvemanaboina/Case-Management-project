/**
 * AccountHierarchyController class is created get ChildAccounts
 * Created By :   Charan K.
 * Crated Date :  23/08/2024.
 */
public with sharing class AccountHierarchyController {
    @AuraEnabled(Cacheable=true)
    public static List<Account> getChildAccounts(String accountId){
        Account accountRecord = [ SELECT Id, BillingCountry, ParentId FROM Account WHERE Id = :accountId LIMIT 1 ];
        List<Account> childAccounts = null;
        if (accountRecord.ParentId != null && accountRecord.BillingCountry != null){
            List<Account> accountRecordParent = [ SELECT Id, BillingCountry, ParentId FROM Account WHERE Id = :accountRecord.ParentId LIMIT 1 ];  
            if(accountRecordParent[0].ParentId != null) {
                childAccounts = [
                    SELECT Id, Name, SAP_Number__c, BillingCountry, Parent.Name 
                    FROM Account
                    WHERE BillingCountry = :accountRecord.BillingCountry
                    AND ParentId = :accountRecordParent[0].ParentId
                    AND Id != : accountRecord.Id
                ];
            } else {
                childAccounts = [
                    SELECT Id, Name, SAP_Number__c, BillingCountry, Parent.Name 
                    FROM Account
                    WHERE BillingCountry = :accountRecord.BillingCountry
                    AND ParentId = :accountRecord.ParentId
                    AND Id != : accountRecord.Id
                ];
            }
        }else if (accountRecord.ParentId != null && accountRecord.BillingCountry == null){
            childAccounts =[ SELECT Id, Name, SAP_Number__c, BillingCountry, Parent.Name FROM Account WHERE ParentId =: accountId ];
        }else if(accountRecord.ParentId == null){
            childAccounts = [
                SELECT Id, Name, SAP_Number__c, BillingCountry, ParentId
                FROM Account 
                WHERE ParentId = :accountId 
                AND SAP_Number__c =: null
            ];
        }
        return childAccounts;
    }
    
    
    // Method to fetch specific account plan details for an Account
    @AuraEnabled
    public static Account getAccountDetails(Id accountId) {
        return [ SELECT Account_Plan_for_FCP_T20_KA_Name__c, Account_Plan_for_FCP_T20_KA__c FROM Account WHERE Id = :accountId LIMIT 1 ];
    }

    // Method to Update Account
    @AuraEnabled
    public static void updateAccount(Id accountId, String planName, String planUrl) {
        Account accountToUpdate = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
        accountToUpdate.Account_Plan_for_FCP_T20_KA_Name__c = planName;
        accountToUpdate.Account_Plan_for_FCP_T20_KA__c = planUrl;
        update accountToUpdate;
    }
}