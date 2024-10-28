public without sharing class CaseController {
    @AuraEnabled
    public static Boolean checkForCaseProducts(String recordId){
        Boolean result = false;
        list<Case_Product_Association__c> caseProduct = [select id,Name from Case_Product_Association__c where Case_Number__c =:recordId];         
        result = caseProduct.size() > 0 ? false : true;
        return result;
    }
}