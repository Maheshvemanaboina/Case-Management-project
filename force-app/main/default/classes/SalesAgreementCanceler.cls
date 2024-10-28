public with sharing class SalesAgreementCanceler {
    @InvocableMethod(Label='Cancel Sales Agreement' Description='Publishes platform event that cancels Sales Agreement' Category='Quote')
    public static void processData(List<String> salesAgreementId) {

        ContractCancelNotification__e contractEvent = new ContractCancelNotification__e();
        SalesAgreement agreement = [
                SELECT
                        Id, SAP_Number__c, Last_Integration_Status__c, Last_Integration_Date__c
                FROM
                        SalesAgreement
                WHERE
                        Id = :salesAgreementId[0]
        ];

        contractEvent.Contract_SAP_Number__c = agreement.SAP_Number__c;
        contractEvent.Sales_Agreement_ID__c = agreement.Id;

        List<Database.SaveResult> results = EventBus.publish(new List<ContractCancelNotification__e>{contractEvent});

        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
                agreement.Last_Integration_Date__c = Datetime.now();
                agreement.Last_Integration_Status__c = 'To Sync';
                update agreement;
            } else {
                for (Database.Error err : sr.getErrors()) {
                    Utilities.generateDebugLogsForErrorHandling(new ContractNotificationPlatformEventException(err.getStatusCode() + ' - ' + err.getMessage()), new List<SObject>{agreement}, 'Failed during publishing cancel events for Sales Agreement');
                }
            }
        }
    }

    public class ContractNotificationPlatformEventException extends Exception {}
}