public with sharing class CloseSalesAgreementBatch implements Database.Batchable<SObject>{
   
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([

            SELECT
                Id, SAP_Number__c
            FROM
                SalesAgreement
            WHERE
                Agreement_Status__c = 'Expired'
                AND SAP_Contract_Status__c = 'Fully referenced'
                AND SAP_Number__c != NULL
                AND Closed__c = FALSE
                AND Cancelled__c = FALSE
                AND Marked_for_Amendment__c = FALSE
                AND Last_Integration_Status__c = 'In Sync'

        ]);

    } 
    
    public void execute(Database.BatchableContext bc, List<SalesAgreement> scope) {

        List<SObject> events                                       = new List<SObject>();
        List<ContractCloseNotification__e> contractListToClose     = new List<ContractCloseNotification__e>();
        List<SalesAgreement> salesAgreementsInScope                = new List<SalesAgreement>();
        List<SalesAgreement> salesAgreementsToUpdate               = new List<SalesAgreement>();
        List<SalesAgreement> salesAgreementsFailed                 = new List<SalesAgreement>();
        String error;

        for (SalesAgreement agreement : scope) {
            ContractCloseNotification__e contractToclose = new ContractCloseNotification__e();
            contractToclose.SAP_Contract_Number__c = agreement.SAP_Number__c;
            contractToclose.SF_Agreement_ID__c = agreement.Id;
            contractToclose.Reason_for_Rejection__c = '';
            contractListToClose.add(contractToclose);
        }   
        events.addAll(contractListToClose); 
        salesAgreementsInScope.addAll(scope);
        
        List<Database.SaveResult> results = EventBus.publish(events);
        
        Integer counter = 0;
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                salesAgreementsInScope[counter].Last_Integration_Date__c = Datetime.now();
                salesAgreementsInScope[counter].Last_Integration_Status__c = 'To Sync';
                salesAgreementsToUpdate.add(salesAgreementsInScope[counter]);
            } else {
                salesAgreementsInScope[counter].Last_Integration_Date__c = Datetime.now();
                salesAgreementsInScope[counter].Last_Integration_Status__c = 'Error';
                salesAgreementsFailed.add(salesAgreementsInScope[counter]);   
                for (Database.Error err : sr.getErrors()) {
                    error += err.getStatusCode() + ' - ' + err.getMessage() + '; ';
                }             
            }
            counter++;
        }       
       
        if(!salesAgreementsToUpdate.isEmpty())
        update salesAgreementsToUpdate;
        

        if (!salesAgreementsFailed.isEmpty()) {
            update salesAgreementsFailed;
            Utilities.generateDebugLogsForErrorHandling(new ContractCloseNotificationPlatformEventException(error), salesAgreementsFailed, 'Failed during publishing events for Sales Agreement');
        }
    }   

    public void finish(Database.BatchableContext bc) {}

    public class ContractCloseNotificationPlatformEventException extends Exception {}

    
    
}