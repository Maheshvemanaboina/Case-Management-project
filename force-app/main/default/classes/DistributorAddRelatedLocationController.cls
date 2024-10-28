public without sharing class DistributorAddRelatedLocationController {
    
    @AuraEnabled
    public static Boolean createRelatedLocation(String fiscalYear, String objectName , String custLocId, String relatedLocationKPILookUpAPIName, String masterBucketInitial) {
        
        String currentUserAccount =  UserUtility.getCurrentUser().contact.AccountId;

        String kPIMasterName = masterBucketInitial.trim() + ' - ' + fiscalYear;
        
        String query = 'Select Id, Name, Distributor_Account__c FROM ' + objectName + ' WHERE Distributor_Account__c =: currentUserAccount';
        query = query + ' AND Fiscal_Year_FY__c =: fiscalYear';
        query = query + ' AND Name =: kPIMasterName' ;
        
        List<SObject> kpiSObjectList = Database.query(query);

        if(kpiSObjectList.isEmpty()) return false;

        List<Other_Related_Customer_Location__c> newORCLListToInsert = new List<Other_Related_Customer_Location__c>();
        for (sObject masterKPI : kpiSObjectList) {
            
            Other_Related_Customer_Location__c newORCL = new Other_Related_Customer_Location__c();
            //newORCL.Related_Commercial_Activity__c = masterKPI.Id;
            newORCL.put(relatedLocationKPILookUpAPIName,masterKPI.Id);
            newORCL.Distributor_Location__c = custLocId;
            newORCLListToInsert.add(newORCL);
        }
        insert newORCLListToInsert;
        return true;
    }
    
    @AuraEnabled
    public static List<sObject> fetchExistingRelatedLocations(String fiscalYear, String ObjectAPIName, String masterKPIInitial, String relatedLocationKPILookUpRelationName) {
        
        String kPIMasterName = masterKPIInitial.trim() + ' - ' + fiscalYear;
        
        String query = 'Select Name,Distributor_Location__r.Name FROM Other_Related_Customer_Location__c WHERE ';
        query = query + relatedLocationKPILookUpRelationName + '.Name =: kPIMasterName';
        return Database.query(query);
        
    }
    
    @AuraEnabled
    public static void deleteRecords(String recordId) {
        
        Other_Related_Customer_Location__c delORCl  = [Select Id FROM Other_Related_Customer_Location__c WHERE Id =: recordId];
        Delete delORCl;
        
    }
    
}