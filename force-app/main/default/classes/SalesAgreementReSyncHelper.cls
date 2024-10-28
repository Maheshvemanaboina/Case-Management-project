public with sharing class SalesAgreementReSyncHelper {
    @InvocableMethod(Label='Sales Agreement ReSync to SAP' Description='Fires again synchronization event' Category='Sales Agreement')
    public static List<Id> processData(List<String> salesAgreementId) {

        Savepoint sp = Database.setSavepoint();
        List<SObject> dataToUpdate = new List<SObject>();
        SalesAgreement salesAgreementDetails = [SELECT Id, SAP_Number__c, Quote__r.SBQQ__Type__c FROM SalesAgreement WHERE Id = :salesAgreementId[0]];

        if (salesAgreementDetails.Quote__r.SBQQ__Type__c == 'Amendment' && salesAgreementDetails.SAP_Number__c != null) {
            // Fire this to publish an event for amendment agreement
            EventBus.publish(new ContractAmendmentNotification__e(Sales_Agreement_ID__c = salesAgreementDetails.Id, Sales_Agreement_SAP_ID__c = salesAgreementDetails.SAP_Number__c));
            salesAgreementDetails.Last_Integration_Date__c = Datetime.now();
            salesAgreementDetails.Last_Integration_Status__c = 'To Sync';
            update salesAgreementDetails;

        } else {
            // Fire this to publish a creation event for specified agreement
            SalesAgreementPublisher.processData(new List<String>{salesAgreementDetails.Id});
        }

        return salesAgreementId;
    }
}