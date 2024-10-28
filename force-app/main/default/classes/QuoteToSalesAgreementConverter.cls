public with sharing class QuoteToSalesAgreementConverter {

    private static Set<String> quoteFields = new Set<String>();
    private static Set<String> quoteLineGroupFields = new Set<String>();
    private static Set<String> quoteLineFields = new Set<String>();
    private static List<SalesAgreement> salesAgreementsList = new List<SalesAgreement>();

    private static final String quoteObject = 'SBQQ__Quote__c';
    private static final String quoteLineObject = 'SBQQ__QuoteLine__c';
    private static final String quoteLineGroupObject = 'SBQQ__QuoteLineGroup__c';

    @InvocableMethod(Label='Process Quote and create Sales Agreements' Description='Processes information from Quote, Quote Line and Quote Line Group and creates Sales Agreements' Category='Quote')
    public static void processData(List<String> quoteId) {
        List<SalesAgreementProduct> sapToInsert = new List<SalesAgreementProduct>();
        List<Synchronization_Config__mdt> syncConfig = retrieveCustomMetadata();
        prepareFieldSetsForSync(syncConfig, quoteFields, quoteLineGroupFields, quoteLineFields);
        SBQQ__Quote__c quote = retrieveQuoteFields(quoteId[0], quoteFields).get(0);
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLines = retrieveQuoteLineGroupsWithQuoteLines(quoteId[0], false, quoteLineGroupFields, quoteLineFields);
        Map<Id, List<SalesAgreementProduct>> groupIdToSapMap = prepareSalesAgreementsAndProducts(syncConfig, quote, quoteLineGroupsWithQuoteLines, salesAgreementsList);

        Savepoint sp = Database.setSavepoint();
        try {
            Database.insert(salesAgreementsList);
            populateAgreementProductsWithSalesAgreementId(groupIdToSapMap, salesAgreementsList);

            for (List<SalesAgreementProduct> sapList : groupIdToSapMap.values()) {
                sapToInsert.addAll(sapList);
            }
            Database.insert(sapToInsert);
            SalesAgreementPublisher.processData(new List<Id>(new Map<Id, SalesAgreement>(salesAgreementsList).keySet()));
        } catch (Exception ex) {
            Database.rollback(sp);
            String comment = 'Failed during inserting Sales Agreement and Products in QuoteToSalesAgreementConverter apex class';
            List<SObject> scope = new List<SObject>();
            scope.addAll(salesAgreementsList);
            scope.addAll(sapToInsert);
            Utilities.generateDebugLogsForErrorHandling(ex, scope, comment);
        }
    }

    /*------------------------------------------------------------
    Description: Retrieves Custom Metadata
    ------------------------------------------------------------*/
    public static List<Synchronization_Config__mdt> retrieveCustomMetadata() {

        return [
                SELECT
                        Source_Object__c, Source_Field__c, Target_Object__c, Target_Field__c
                FROM
                        Synchronization_Config__mdt
                WHERE
                        (Source_Object__c = :quoteObject OR Source_Object__c = :quoteLineGroupObject OR Source_Object__c = :quoteLineObject)
                        AND (Target_Object__c = 'SalesAgreement' OR Target_Object__c = 'SalesAgreementProduct')
                        AND Active__c = TRUE
                ORDER BY Source_Object__c
        ];
    }

    /*------------------------------------------------------------
    Description: Retrieves Quote fields
    ------------------------------------------------------------*/
    public static List<SBQQ__Quote__c> retrieveQuoteFields(Id quoteId, Set<String> quoteFields) {

        if (!quoteFields.isEmpty()) {
            String query = 'SELECT Name, Sync_To_Agreement__c, ';

            for (String field : quoteFields) {
                query += field + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM SBQQ__Quote__c WHERE Id = \'' + quoteId + '\'';

            return (List<SBQQ__Quote__c>) Database.query(query);
        }
        return null;
    }

    /*------------------------------------------------------------
    Description: Retrieves Quote Line Group and Quote Lines
    ------------------------------------------------------------*/
    public static List<SBQQ__QuoteLineGroup__c> retrieveQuoteLineGroupsWithQuoteLines(Id quoteId, Boolean processIsAmendment, Set<String> quoteLineGroupFields, Set<String> quoteLineFields) {

        if (!quoteLineGroupFields.isEmpty()) {
            String subQuery = buildQuoteLinesSubQuery(processIsAmendment, quoteLineFields);
            String query = 'SELECT SBQQ__Account__r.Name, Ship_To_Customer__r.Name, SBQQ__Number__c, Sync_To_Agreement__c, ';

            for (String field : quoteLineGroupFields) {
                query += field + ', ';
            }
            query = query.removeEnd(', ');
            query += subQuery + ' FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = \'' + quoteId + '\'';

            return (List<SBQQ__QuoteLineGroup__c>) Database.query(query);
        }
        return null;
    }

    /*------------------------------------------------------------
    Description: Prepares sets of fields
    ------------------------------------------------------------*/
    public static void prepareFieldSetsForSync(List<Synchronization_Config__mdt> syncConfig,
            Set<String> quoteFields,
            Set<String> quoteLineGroupFields,
            Set<String> quoteLineFields) {

        for (Synchronization_Config__mdt sc : syncConfig) {
            if (sc.Source_Object__c == quoteObject) {
                quoteFields.add(sc.Source_Field__c);
            } else if (sc.Source_Object__c == quoteLineGroupObject) {
                quoteLineGroupFields.add(sc.Source_Field__c);
            } else if (sc.Source_Object__c == quoteLineObject) {
                quoteLineFields.add(sc.Source_Field__c);
            }
        }
    }

    /*------------------------------------------------------------
    Description: Prepares Sales Agreement and Sales Agreement Products
    ------------------------------------------------------------*/
    public static Map<Id, List<SalesAgreementProduct>> prepareSalesAgreementsAndProducts(
            List<Synchronization_Config__mdt> syncConfig,
            SBQQ__Quote__c quote,
            List<SBQQ__QuoteLineGroup__c> quoteLineGroupsWithQuoteLines,
            List<SalesAgreement> salesAgreementsList) {

        Map<Id, List<SalesAgreementProduct>> groupIdToSapMap = new Map<Id, List<SalesAgreementProduct>>();
        List<SalesAgreementProduct> sapList = new List<SalesAgreementProduct>();

        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroupsWithQuoteLines) {
            SalesAgreement sa = new SalesAgreement();
            // Setting some required fields
            sa.Quote__c = quote.Id;
            sa.Quote_Line_Group__c = qlg.Id;
            sa.ScheduleCount = 1;
            sa.ScheduleFrequency = 'Onetime';
            sa.StartDate = Date.today();
            sa.Name = qlg.SBQQ__Account__r.Name + ' ' + qlg.Ship_To_Customer__r.Name + ' ' + quote.Name;

            for (Synchronization_Config__mdt sc : syncConfig) {
                if (sc.Source_Object__c == quoteObject) {
                    sa.put(sc.Target_Field__c, quote.get(sc.Source_Field__c));
                }

                if (sc.Source_Object__c == quoteLineGroupObject) {
                    sa.put(sc.Target_Field__c, qlg.get(sc.Source_Field__c));
                }

                if (sc.Source_Object__c == quoteLineObject) {
                    Integer currentIndex = 0;
                    for (SBQQ__QuoteLine__c ql : qlg.SBQQ__LineItems__r) {
                        if (sapList.size() != qlg.SBQQ__LineItems__r.size()) {
                            SalesAgreementProduct sap = new SalesAgreementProduct();
                            sap.Name = ql.SBQQ__Product__r.Name;
                            sap.Ordered_Quantity__c = 0;

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
                            sapList.add(sap);
                        } else {
                            if (sc.Target_Field__c == 'InitialPlannedQuantity') {
                                Integer initialQuantity = Integer.valueOf(Math.round(Double.valueOf(ql.get(sc.Source_Field__c))));
                                sapList.get(currentIndex).put(sc.Target_Field__c, initialQuantity < 1 ? 1 : initialQuantity);
                            } else if (sc.Target_Field__c == 'TotalCOGS__c' && (ql.Category_Item__c == 'ZKPS' || ql.Category_Item__c == 'ZKN1')) {
                                sapList.get(currentIndex).put(sc.Target_Field__c, 0);
                            } else if (Schema.DisplayType.CURRENCY == SalesAgreementProduct.getSObjectType().getDescribe().fields.getMap().get(sc.Target_Field__c).getDescribe().getType()) {
                                sapList.get(currentIndex).put(sc.Target_Field__c, ((Decimal) ql.get(sc.Source_Field__c))?.setScale(2, System.RoundingMode.HALF_UP));
                            } else {
                                sapList.get(currentIndex).put(sc.Target_Field__c, ql.get(sc.Source_Field__c));
                            }
                        }
                        currentIndex++;
                    }
                }
            }
            salesAgreementsList.add(sa);
            groupIdToSapMap.put(sa.Quote_Line_Group__c, new List<SalesAgreementProduct>(sapList));
            sapList.clear();
        }
        return groupIdToSapMap;
    }

    /*------------------------------------------------------------
    Description: Populates Sales Agreement Products with Agreement Id
    ------------------------------------------------------------*/
    public static void populateAgreementProductsWithSalesAgreementId(Map<Id, List<SalesAgreementProduct>> saToSapMap, List<SalesAgreement> salesAgreementsList) {
        for (SalesAgreement sa : salesAgreementsList) {
            for (SalesAgreementProduct sap : saToSapMap.get(sa.Quote_Line_Group__c)) {
                sap.SalesAgreementId = sa.Id;
            }
        }
    }

    /*------------------------------------------------------------
    Description: builds subquery for Quote Line fields
    ------------------------------------------------------------*/
    private static String buildQuoteLinesSubQuery(Boolean processIsAmendment, Set<String> quoteLineFields) {

        if (!quoteLineFields.isEmpty()) {
            String query = ', (SELECT SBQQ__Product__r.Name, ';

            for (String field : quoteLineFields) {
                query += field + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM SBQQ__LineItems__r WHERE Product_Type__c = \'Product SKU\' AND SBQQ__Number__c < 3000';

            if (processIsAmendment) {
                query += ' AND (Sync_To_Agreement__c = \'To Insert\' OR Sync_To_Agreement__c = \'To Update\')';
            }
            query += ')';

            return query;
        }
        return '';
    }
}