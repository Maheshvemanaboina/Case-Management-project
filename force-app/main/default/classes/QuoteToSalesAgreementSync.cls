public with sharing class QuoteToSalesAgreementSync {

    private static Set<String> quoteFields                      = new Set<String>();
    private static Set<String> quoteLineGroupFields             = new Set<String>();
    private static Set<String> quoteLineFields                  = new Set<String>();
    private static List<SalesAgreement> salesAgreementsToInsert = new List<SalesAgreement>();

    private static final String quoteObject             = 'SBQQ__Quote__c';
    private static final String quoteLineObject         = 'SBQQ__QuoteLine__c';
    private static final String quoteLineGroupObject    = 'SBQQ__QuoteLineGroup__c';

    @InvocableMethod(Label='Sync Quote and Lines to Agreements' Description='Syncs Quotes, Groups and Lines to Sales Agreements and Products' Category='Quote')
    public static void processData(List<String> quoteId) {
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLinesToInsert             = new List<SBQQ__QuoteLineGroup__c>();
        List<SalesAgreementProduct> sapToInsert                                         = new List<SalesAgreementProduct>();
        List<SObject> recordsToUpsert                                                   = new List<SObject>();
        Set<Id> quoteLineGroupIdsToUpdate                                               = new Set<Id>();
        Set<Id> quoteLineIdsToUpdate                                                    = new Set<Id>();
        Map<Id, List<SalesAgreementProduct>> groupIdToAgreementProductMapToInsert       = new Map<Id, List<SalesAgreementProduct>>();

        List<Synchronization_Config__mdt> syncConfig = QuoteToSalesAgreementConverter.retrieveCustomMetadata();
        QuoteToSalesAgreementConverter.prepareFieldSetsForSync(syncConfig, quoteFields, quoteLineGroupFields, quoteLineFields);
        SBQQ__Quote__c quote = QuoteToSalesAgreementConverter.retrieveQuoteFields(quoteId[0], quoteFields).get(0);
		System.debug('###SP-->quote'+quote);
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLines = QuoteToSalesAgreementConverter.retrieveQuoteLineGroupsWithQuoteLines(
                quote.Id,
                true,
                quoteLineGroupFields,
                quoteLineFields);
        Map<Id, Id> quoteLineGroupIdToSalesAgreementId = getMappingOfAgreementsAndGroups(quoteLineGroupsWithQuoteLines);
		System.debug('###SP-->MAP<id, id> quoteLineGroupIdToSalesAgreementId '+quoteLineGroupIdToSalesAgreementId);
        performSegmentation(
                quoteLineGroupsWithQuoteLines,
                quoteLineGroupsWithQuoteLinesToInsert,
                quoteLineGroupIdsToUpdate,
                quoteLineIdsToUpdate,
                syncConfig,
                quoteLineGroupIdToSalesAgreementId,
                recordsToUpsert,
                quote
        );

        if (!quoteLineGroupsWithQuoteLinesToInsert.isEmpty()) {
            groupIdToAgreementProductMapToInsert = QuoteToSalesAgreementConverter.prepareSalesAgreementsAndProducts(
                    syncConfig,
                    quote,
                    quoteLineGroupsWithQuoteLinesToInsert,
                    salesAgreementsToInsert);
        }
		system.debug('###SP--> groupIdToAgreementProductMapToInsert'+groupIdToAgreementProductMapToInsert);
		system.debug('###SP--> salesAgreementsToInsert'+salesAgreementsToInsert);

        Savepoint sp = Database.setSavepoint();
        try {
            if (!quoteLineGroupsWithQuoteLinesToInsert.isEmpty()) {
                Database.insert(salesAgreementsToInsert);
                QuoteToSalesAgreementConverter.populateAgreementProductsWithSalesAgreementId(groupIdToAgreementProductMapToInsert, salesAgreementsToInsert);
                for (List<SalesAgreementProduct> sapList : groupIdToAgreementProductMapToInsert.values()) {
                    sapToInsert.addAll(sapList);
                }
                recordsToUpsert.addAll(sapToInsert);
            }

            if (!quoteLineGroupIdsToUpdate.isEmpty() || !quoteLineIdsToUpdate.isEmpty()) {
                recordsToUpsert.addAll(markAgreementsAndProducts(quoteLineGroupIdsToUpdate, quoteLineIdsToUpdate, quote, quoteLineGroupsWithQuoteLines));
            }
            Database.upsert(recordsToUpsert);

            if (!recordsToUpsert.isEmpty() || !quoteLineGroupsWithQuoteLinesToInsert.isEmpty()) {
                List<SalesAgreement> salesAgreementsToSendAmendmentEvent = new List<SalesAgreement>();
                for (SObject record : recordsToUpsert) {
                    if (record.getSObjectType().getDescribe().getName() == 'SalesAgreement' && ((SalesAgreement) record).To_Update__c) {
                        salesAgreementsToSendAmendmentEvent.add((SalesAgreement) record);
                    }
            system.debug('###SP--> salesAgreementsToSendAmendmentEvent'+salesAgreementsToSendAmendmentEvent);

                }
                publishEventsAndUpdateAgreements(salesAgreementsToSendAmendmentEvent, salesAgreementsToInsert);
            }
        } catch (Exception ex) {
            system.debug('error--->'+ex.getMessage());
            Database.rollback(sp);
            String comment = 'Failed during inserting Sales Agreement and Products in QuoteToSalesAgreementSync apex class';
            List<SObject> scope = new List<SObject>();
            scope.addAll(salesAgreementsToInsert);
            scope.addAll(recordsToUpsert);
            Utilities.generateDebugLogsForErrorHandling(ex, scope, comment);
        }
    }

    /*------------------------------------------------------------
    Description: Performs main logic of dividing records to a different streams
    ------------------------------------------------------------*/
    private static void performSegmentation(List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLines,
            List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLinesToInsert,
            Set<Id> quoteLineGroupIdsToUpdate,
            Set<Id> quoteLineIdsToUpdate,
            List<Synchronization_Config__mdt> syncConfig,
            Map<Id, Id> quoteLineGroupIdToSalesAgreementId,
            List<SObject> recordsToUpsert,
            SBQQ__Quote__c quote) {
		
        system.debug('###SP--> quote.Sync_To_Agreement__c'+quote.Sync_To_Agreement__c);

        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroupsWithQuoteLines) {
            if (quote.Sync_To_Agreement__c == 'To Update' && qlg.Sync_To_Agreement__c != 'To Insert') {
                // Sync all Sales Agreements if there was a change on Quote level
                quoteLineGroupIdsToUpdate.add(qlg.Id);
            }
            

            if (qlg.Sync_To_Agreement__c == 'To Insert') {
                // new Quote Line Group and new Quote Lines
                quoteLineGroupsWithQuoteLinesToInsert.add(qlg);
            } else if (qlg.Sync_To_Agreement__c == 'To Update') {
                quoteLineGroupIdsToUpdate.add(qlg.Id);
                for (SBQQ__QuoteLine__c ql : qlg.SBQQ__LineItems__r) {
                    if (ql.Sync_To_Agreement__c == 'To Insert') {
                        // existing Quote Line Group (with changes) and new Quote Line
                        SalesAgreementProduct sap = prepareSalesAgreementProducts(syncConfig, ql, quoteLineGroupIdToSalesAgreementId.get(qlg.Id));
                        recordsToUpsert.add(sap);
                    } else if (ql.Sync_To_Agreement__c == 'To Update') {
                        // existing Quote Line Group (with changes) and existing Quote Line (with changes)
                        quoteLineIdsToUpdate.add(ql.Id);
                    }
                }
            } else {
                for (SBQQ__QuoteLine__c ql : qlg.SBQQ__LineItems__r) {
                    if (ql.Sync_To_Agreement__c == 'To Insert') {
                        // existing Quote Line Group (without changes) and new Quote Line
                        quoteLineGroupIdsToUpdate.add(qlg.Id);
                        SalesAgreementProduct sap = prepareSalesAgreementProducts(syncConfig, ql, quoteLineGroupIdToSalesAgreementId.get(qlg.Id));
                        recordsToUpsert.add(sap);
                    } else if (ql.Sync_To_Agreement__c == 'To Update') {
                        // existing Quote Line Group (without changes) and existing Quote Line (with changes)
                        quoteLineGroupIdsToUpdate.add(qlg.Id);
                        quoteLineIdsToUpdate.add(ql.Id);
                    }
                }
            }
        }
    }

    /*------------------------------------------------------------
    Description: Marks checkbox on SAs and SAPs
    ------------------------------------------------------------*/
    private static List<SObject> markAgreementsAndProducts(
            Set<Id> quoteLineGroupIdsToUpdate,
            Set<Id> quoteLineIdsToUpdate,
            SBQQ__Quote__c quote,
            List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLines) {

        List<SObject> recordsToUpsert = new List<SObject>();
        Map<Id, SBQQ__QuoteLineGroup__c> groupMap = new Map<Id, SBQQ__QuoteLineGroup__c>(quoteLineGroupsWithQuoteLines);
        Map<Id, SBQQ__QuoteLine__c> lineMap = new Map<Id, SBQQ__QuoteLine__c>();

        List<Synchronization_Config__mdt> syncConfig = [
                SELECT
                        Source_Object__c, Source_Field__c, Target_Object__c, Target_Field__c
                FROM
                        Synchronization_Config__mdt
                WHERE
                        (Source_Object__c = :quoteObject OR Source_Object__c = :quoteLineGroupObject OR Source_Object__c = :quoteLineObject)
                        AND (Target_Object__c = 'SalesAgreement' OR Target_Object__c = 'SalesAgreementProduct')
                        AND Active__c = TRUE
                        AND Use_for_Amendments__c = TRUE
                ORDER BY Source_Object__c
        ];

        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroupsWithQuoteLines) {
            for (SBQQ__QuoteLine__c ql : qlg.SBQQ__LineItems__r) {
                lineMap.put(ql.Id, ql);
            }
        }
        system.debug('###SP--> LineMap'+lineMap);
		system.debug('###SP--> quoteLineGroupIdsToUpdate'+quoteLineGroupIdsToUpdate);
        for (SalesAgreement sa : [
                SELECT
                        Id, To_Update__c, SAP_Number__c, Last_Integration_Date__c, Last_Integration_Status__c, Quote_Line_Group__c
                FROM
                        SalesAgreement
                WHERE
                        Quote_Line_Group__c IN :quoteLineGroupIdsToUpdate
        ]) {
            system.debug('###SP--> SalesAgreement'+sa.To_Update__c);
            sa.To_Update__c = true;
            sa.Marked_for_Amendment__c = false;
            for (Synchronization_Config__mdt sc : syncConfig) {
                if (sc.Source_Object__c == quoteObject) {
                    sa.put(sc.Target_Field__c, quote.get(sc.Source_Field__c));
                }

                if (sc.Source_Object__c == quoteLineGroupObject) {
                    sa.put(sc.Target_Field__c, groupMap.get(sa.Quote_Line_Group__c).get(sc.Source_Field__c));
                }
            }

            recordsToUpsert.add(sa);
        }

        for (SalesAgreement additionalSalesAgreement : [
                SELECT
                        Id, Marked_for_Amendment__c, To_Update__c, SAP_Number__c
                FROM
                        SalesAgreement
                WHERE
                        Quote_Line_Group__c NOT IN :quoteLineGroupIdsToUpdate
                        AND Quote__c = :quote.Id
        ]) {
            additionalSalesAgreement.Marked_for_Amendment__c = false;
            recordsToUpsert.add(additionalSalesAgreement);
        }

        for (SalesAgreementProduct sap : [
                SELECT
                        Id, To_Update__c, Quote_Line__c
                FROM
                        SalesAgreementProduct
                WHERE
                        Quote_Line__c IN :quoteLineIdsToUpdate
        ]) {
            sap.To_Update__c = true;
            for (Synchronization_Config__mdt sc : syncConfig) {
                if (sc.Source_Object__c == quoteLineObject) {
                    if (sc.Target_Field__c == 'InitialPlannedQuantity') {
                        Integer initialQuantity = Integer.valueOf(Math.round(Double.valueOf(lineMap.get(sap.Quote_Line__c).get(sc.Source_Field__c))));
                        sap.put(sc.Target_Field__c, initialQuantity < 1 ? 1 : initialQuantity);
                    } else if (sc.Target_Field__c == 'TotalCOGS__c' && (lineMap.get(sap.Quote_Line__c).Category_Item__c == 'ZKPS' || lineMap.get(sap.Quote_Line__c).Category_Item__c == 'ZKN1')) {
                        sap.put(sc.Target_Field__c, 0);
                    } else if (Schema.DisplayType.CURRENCY == SalesAgreementProduct.getSObjectType().getDescribe().fields.getMap().get(sc.Target_Field__c).getDescribe().getType()) {
                        sap.put(sc.Target_Field__c, ((Decimal) lineMap.get(sap.Quote_Line__c).get(sc.Source_Field__c))?.setScale(2, System.RoundingMode.HALF_UP));
                    } else {
                        sap.put(sc.Target_Field__c, lineMap.get(sap.Quote_Line__c).get(sc.Source_Field__c));
                    }
                }
            }
            recordsToUpsert.add(sap);
        }

        return recordsToUpsert;
    }

    /*------------------------------------------------------------
    Description: Prepares Sales Agreement Products
    ------------------------------------------------------------*/
    private static SalesAgreementProduct prepareSalesAgreementProducts(
            List<Synchronization_Config__mdt> syncConfig,
            SBQQ__QuoteLine__c ql,
            Id salesAgreementId) {

        SalesAgreementProduct sap = new SalesAgreementProduct();
        sap.Name = ql.SBQQ__Product__r.Name;
        sap.Ordered_Quantity__c = 0;
        sap.To_Update__c = true;
        sap.SalesAgreementId = salesAgreementId;
        for (Synchronization_Config__mdt sc : syncConfig) {
            if (sc.Source_Object__c == quoteLineObject) {
                if (sc.Target_Field__c == 'InitialPlannedQuantity') {
                    Integer initialQuantity = Integer.valueOf(Math.round(Double.valueOf(ql.get(sc.Source_Field__c))));
                    sap.put(sc.Target_Field__c, initialQuantity < 1 ? 1 : initialQuantity);
                } else if (sc.Target_Field__c == 'TotalCOGS__c' && (ql.Category_Item__c == 'ZKPS' || ql.Category_Item__c == 'ZKN1')) {
                    sap.put(sc.Target_Field__c, 0);
                } else if (Schema.DisplayType.CURRENCY == SalesAgreementProduct.getSObjectType().getDescribe().fields.getMap().get(sc.Target_Field__c).getDescribe().getType()) {
                    sap.put(sc.Target_Field__c, ((Decimal) ql.get(sc.Source_Field__c))?.setScale(2, System.RoundingMode.HALF_UP));
                } else {
                    sap.put(sc.Target_Field__c, ql.get(sc.Source_Field__c));
                }
            }
        }
        return sap;
    }

    /*------------------------------------------------------------
    Description: Creates mapping of SA to QLG
    ------------------------------------------------------------*/
    private static Map<Id, Id> getMappingOfAgreementsAndGroups(List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLines) {
        Map<Id, Id> quoteLineGroupIdToSalesAgreementId = new Map<Id, Id>();
        Set<Id> qlgIDs = new Map<Id, SBQQ__QuoteLineGroup__c>(quoteLineGroupsWithQuoteLines).keySet();

        for (SalesAgreement sa : [
                SELECT
                        Id, Quote_Line_Group__c
                FROM
                        SalesAgreement
                WHERE
                        Quote_Line_Group__c IN :qlgIDs
        ]) {
            quoteLineGroupIdToSalesAgreementId.put(sa.Quote_Line_Group__c, sa.Id);
        }

        return quoteLineGroupIdToSalesAgreementId;
    }

    /*------------------------------------------------------------
    Description: Publishes events and updates integration fields on records
    ------------------------------------------------------------*/
    private static void publishEventsAndUpdateAgreements(List<SalesAgreement> salesAgreementsToAmend, List<SalesAgreement> salesAgreementsToInsert) {
        List<ContractAmendmentNotification__e> amendmentEvents      = new List<ContractAmendmentNotification__e>();
        List<ContractNotification__e> contractEvents                = new List<ContractNotification__e>();
        List<SObject> events                                        = new List<SObject>();
        List<SalesAgreement> agreementsToUpdate                     = new List<SalesAgreement>();

        if (!salesAgreementsToAmend.isEmpty()) {
            for (SalesAgreement sa : salesAgreementsToAmend) {
                amendmentEvents.add(new ContractAmendmentNotification__e(Sales_Agreement_ID__c = sa.Id, Sales_Agreement_SAP_ID__c = sa.SAP_Number__c));
            }
            events.addAll(amendmentEvents);
            agreementsToUpdate.addAll(salesAgreementsToAmend);
        }

        if (!salesAgreementsToInsert.isEmpty()) {

            Set<Id> agreementIDs = new Map<Id, SalesAgreement>(salesAgreementsToInsert).keySet();

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
                            Id IN :agreementIDs
            ]) {
                contractEvents.add(ContractNotificationBuilder.buildNotification(agreement));
            }
            events.addAll(contractEvents);
            agreementsToUpdate.addAll(salesAgreementsToInsert);
        }

        List<Database.SaveResult> results = EventBus.publish(events);
        Boolean operationWasSucessfull = true;
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                operationWasSucessfull = false;
                for (Database.Error err : sr.getErrors()) {
                    Utilities.generateDebugLogsForErrorHandling(new ContractAmendmentNotificationPlatformEventException(err.getStatusCode()
                            + ' - ' + err.getMessage()), events, 'Failed during publishing events for Amendment Sales Agreements');
                }
            }
        }

        if (operationWasSucessfull) {
            for (SalesAgreement sa : agreementsToUpdate) {
                sa.Last_Integration_Date__c = Datetime.now();
                sa.Last_Integration_Status__c = 'To Sync';
            }

        } else {
            for (SalesAgreement sa : agreementsToUpdate) {
                sa.Last_Integration_Date__c = Datetime.now();
                sa.Last_Integration_Status__c = 'Error';
            }
        }
        update agreementsToUpdate;
    }

    public class ContractAmendmentNotificationPlatformEventException extends Exception {}
}