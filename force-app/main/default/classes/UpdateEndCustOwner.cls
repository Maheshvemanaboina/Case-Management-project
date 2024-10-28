global class UpdateEndCustOwner implements Database.Batchable<sObject> {
    
    global Set<Id> accBatchList = new set<Id>();
     global UpdateEndCustOwner(Set<Id> accList){
        accBatchList=accList;
    }
    global Database.QueryLocator  start(Database.BatchableContext bc) {
       String endCustomerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();
        
        String query = 'SELECT Id,Name,Business_Segment__c, OwnerId,RecordTypeId,Distributor_Location__c,Distributor_Location__r.OwnerId FROM Account WHERE RecordTypeId =: endCustomerRecordTypeId AND Distributor_Location__c IN : accBatchList';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> accList ){
        
       
        //try {
            // Update the Account Record
            UpdateAccountOwner.updateOwner(accList);
         
       // } catch(Exception e) {
           // System.debug(e);
       // }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}