public with sharing class CancelSalesAgreementAmendment {

    @InvocableMethod(Label='Cancel Sales Agreement Amendment' Description='Cancel Sales Agreement Amendment' Category='Quote')
    public static List<Id> processData(List<String> quoteId) {

        Savepoint sp = Database.setSavepoint();
        List<SObject> dataToUpdate = new List<SObject>();

        List<SalesAgreement> allConnectedSAsAndProducts = [
                SELECT
                        Quote__c, Quote__r.SBQQ__Source__c, Quote__r.SBQQ__Source__r.Name,
                        Quote_Line_Group__c, Quote_Line_Group__r.SBQQ__Source__c, Quote_Line_Group__r.SBQQ__Source__r.SBQQ__Account__r.Name,
                        Quote_Line_Group__r.SBQQ__Source__r.Ship_To_Customer__r.Name, Marked_for_Amendment__c,
                        (SELECT Id, Quote_Line__c, Quote_Line__r.SBQQ__Source__c FROM SalesAgreementProducts)
                FROM
                        SalesAgreement
                WHERE
                        Quote__c = :quoteId[0]
        ];

        SBQQ__Quote__c oldQuote = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Id = :allConnectedSAsAndProducts[0].Quote__r.SBQQ__Source__c];
        oldQuote.SBQQ__Primary__c = true;
        dataToUpdate.add(oldQuote);

        for (SalesAgreement sa : allConnectedSAsAndProducts) {
            sa.Quote__c = sa.Quote__r.SBQQ__Source__c;
            sa.Marked_for_Amendment__c = false;
            sa.Quote_Line_Group__c = sa.Quote_Line_Group__r.SBQQ__Source__c;
            sa.Name = sa.Quote_Line_Group__r.SBQQ__Source__r.SBQQ__Account__r.Name + ' ' + sa.Quote_Line_Group__r.SBQQ__Source__r.Ship_To_Customer__r.Name + ' ' + sa.Quote__r.SBQQ__Source__r.Name;
            dataToUpdate.add(sa);

            for (SalesAgreementProduct sap : sa.SalesAgreementProducts) {
                sap.Quote_Line__c = sap.Quote_Line__r.SBQQ__Source__c;
                dataToUpdate.add(sap);
            }
        }

        try {
            dataToUpdate.sort();
            Database.update(dataToUpdate);
            Database.delete(quoteId[0]);
        } catch (Exception ex) {
            Database.rollback(sp);
            String comment = 'Failed during updating Sales Agreements and Products with old Quote Lines and Groups IDs in apex class CancelSalesAgreementAmendment';
            List<SObject> scope = new List<SObject>();
            scope.addAll(dataToUpdate);
            Utilities.generateDebugLogsForErrorHandling(ex, scope, comment);
        }

        return new List<Id>{allConnectedSAsAndProducts[0].Quote__r.SBQQ__Source__c};
    }

}