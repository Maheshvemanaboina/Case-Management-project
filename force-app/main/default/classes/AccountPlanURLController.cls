/**
 * AccountPlanController class is crated to show account plan url for the account
 * Created By :   Charan K.
 * Crated Date :  24/09/2024.
 */
public with sharing class AccountPlanURLController {
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