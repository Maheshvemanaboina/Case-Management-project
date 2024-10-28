public with sharing class SalesAgreementAmendmentCreator {
    @InvocableMethod(Label='Process Sales Agreement and create Amendment' Description='Creates Amendments for Quote' Category='Quote')
    public static List<Id> processData(List<String> salesAgreementId) {

        Savepoint sp = Database.setSavepoint();
        List<SObject> dataToUpdate = new List<SObject>();
        SalesAgreement salesAgreementDetails = [SELECT Quote__c,Reason_for_Amendment__c FROM SalesAgreement WHERE Id = :salesAgreementId[0]];

        QuoteCloneController.reasonForAmendment = salesAgreementDetails.Reason_for_Amendment__c;
        List<Id> quoteId = QuoteCloneController.amendmentQuote(new List<String>{salesAgreementDetails.Quote__c});

        List<SalesAgreement> allConnectedSAsAndProducts = [
                SELECT
                        Quote__c, Quote_Line_Group__c, Marked_for_Amendment__c, (SELECT Id, Quote_Line__c FROM SalesAgreementProducts)
                FROM
                        SalesAgreement
                WHERE
                        Quote__c = :salesAgreementDetails.Quote__c
        ];

        List<SBQQ__QuoteLineGroup__c> newQuoteLineGroups = [
                SELECT
                        Id, SBQQ__Source__c, SBQQ__Account__r.Name, Ship_To_Customer__r.Name, SBQQ__Quote__r.Name
                FROM
                        SBQQ__QuoteLineGroup__c
                WHERE
                        SBQQ__Quote__c = :quoteId[0]
        ];

        Map<Id, Id> sourceGroupToNewGroupMap = createMapping(newQuoteLineGroups);

        List<SBQQ__QuoteLine__c> newQuoteLines = [
                SELECT
                        Id, SBQQ__Source__c
                FROM
                        SBQQ__QuoteLine__c
                WHERE
                        SBQQ__Quote__c = :quoteId[0]
        ];

        Map<Id, Id> sourceLineToNewLineMap = createMapping(newQuoteLines);

        for (SalesAgreement sa : allConnectedSAsAndProducts) {
            sa.Quote__c = quoteId[0];
            sa.Marked_for_Amendment__c = true;
            sa.Quote_Line_Group__c = sourceGroupToNewGroupMap.get(sa.Quote_Line_Group__c);
            sa.Name = newQuoteLineGroups[0].SBQQ__Account__r.Name + ' ' + newQuoteLineGroups[0].Ship_To_Customer__r.Name + ' ' + newQuoteLineGroups[0].SBQQ__Quote__r.Name;
            dataToUpdate.add(sa);

            for (SalesAgreementProduct sap : sa.SalesAgreementProducts) {
                sap.Quote_Line__c = sourceLineToNewLineMap.get(sap.Quote_Line__c);
                dataToUpdate.add(sap);
            }
        }

        try {
            dataToUpdate.sort();
            Database.update(dataToUpdate);
        } catch (Exception ex) {
            Database.rollback(sp);
            String comment = 'Failed during updating Sales Agreements and Products with new Quote Lines and Groups IDs in apex class SalesAgreementAmendmentCreator';
            List<SObject> scope = new List<SObject>();
            scope.addAll(dataToUpdate);
            Utilities.generateDebugLogsForErrorHandling(ex, scope, comment);
        }

        return quoteId;
    }

    private static Map<Id, Id> createMapping(List<SObject> newRecords) {
        Map<Id, Id> sourceRecordToNewRecordMap = new Map<Id, Id>();

        for (SObject item : newRecords) {
            sourceRecordToNewRecordMap.put((Id) item.get('SBQQ__Source__c'), item.Id);
        }
        return sourceRecordToNewRecordMap;
    }
}