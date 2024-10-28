public with sharing class SalesAgreementPublisher {

    @InvocableMethod(Label='Publish event based on Sales Agreement' Description='Publishes platform event based on given Sales Agreement' Category='Quote')
    public static void processData(List<String> salesAgreementId) {

        List<ContractNotification__e> contractEvents = new List<ContractNotification__e>();
        List<SalesAgreement> agreements = new List<SalesAgreement>();
        List<SalesAgreement> agreementsToUpdate = new List<SalesAgreement>();
        List<SalesAgreement> agreementsThatFailed = new List<SalesAgreement>();
        String error;
        for (SalesAgreement agreement : [
                SELECT
                        Id, AccountId, Account.SAP_Number__c, CurrencyIsoCode, Sales_Area__c, Sales_Area__r.SALES_ORG__c,
                        Sales_Area__r.DISTR_CHAN__c, Sales_Area__r.DIVISION__c, Agreement_Number__c, Quote__r.Name,
                        Quote_Line_Group__r.Ship_To_Customer__c, Quote_Line_Group__r.Ship_To_Customer__r.SAP_Number__c,
                        StartDate, EndDate, Last_Integration_Status__c, Last_Integration_Date__c, PO_Number__c, PO_Number2__c, Quotation_Type__c,
                        Payment_Terms__c, IncoTerms__c, IncoTerms_Destination__c, Quote_Line_Group__r.Agent_Account__r.SAP_Number__c, Start_Date__c
                FROM
                        SalesAgreement
                WHERE
                        Id IN :salesAgreementId
        ]) {
            contractEvents.add(ContractNotificationBuilder.buildNotification(agreement));
            agreements.add(agreement);
        }


        List<Database.SaveResult> results = EventBus.publish(contractEvents);

        Integer counter = 0;
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
                agreements[counter].Last_Integration_Date__c = Datetime.now();
                agreements[counter].Last_Integration_Status__c = 'To Sync';
                agreementsToUpdate.add(agreements[counter]);
                counter++;
            } else {
                agreementsThatFailed.add(agreements[counter]);
                for (Database.Error err : sr.getErrors()) {
                    error += err.getStatusCode() + ' - ' + err.getMessage() + '; ';
                }
            }
        }
        update agreementsToUpdate;
        if (!agreementsThatFailed.isEmpty()) {
            Utilities.generateDebugLogsForErrorHandling(new ContractNotificationPlatformEventException(error), agreementsThatFailed, 'Failed during publishing events for Sales Agreement');
        }
    }

    public class ContractNotificationPlatformEventException extends Exception {}
}