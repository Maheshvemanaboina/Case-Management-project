public with sharing class SalesAgreementVolumeUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public SalesAgreementVolumeUpdateBatch() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
                SELECT
                        Id, SAP_Number__c, SAP_Contract_Status__c, (SELECT Id, Position_Number__c, Ordered_Quantity__c, Unit_Of_Measure__c FROM SalesAgreementProducts)
                FROM
                        SalesAgreement
                WHERE
                        (EndDate < TODAY
                        OR Planned_different_from_Ordered__c = TRUE)
                        AND SAP_Number__c != NULL
                        AND Closed__c != TRUE
                        AND Quote__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<SalesAgreement> scope) {

        List<SalesAgreementWrapper.SADetails> detailsToSend = new List<SalesAgreementWrapper.SADetails>();
        List<SalesAgreementProduct> agreementProductsToUpdate = new List<SalesAgreementProduct>();
        Map<String, Map<Integer, SalesAgreementProduct>> sapAndPositionNumberToAgreementProduct = new Map<String, Map<Integer, SalesAgreementProduct>>();
        Map<String, SalesAgreement> salesAgreementMap = new Map<String, SalesAgreement>();
        OrderStatusIntegration__c settings = OrderStatusIntegration__c.getOrgDefaults();

        // prepare the payload
        for (SalesAgreement sa: scope) {
            detailsToSend.add(new SalesAgreementWrapper.SADetails(sa.SAP_Number__c, '000000', 'C'));
            salesAgreementMap.put(sa.SAP_Number__c, sa);
            for (SalesAgreementProduct sap : sa.SalesAgreementProducts) {
                String key = sa.SAP_Number__c + '-' + sap.Position_Number__c;
                if (sapAndPositionNumberToAgreementProduct.containsKey(key)) {
                    sapAndPositionNumberToAgreementProduct.get(key).put((Integer) sap.Position_Number__c, sap);
                } else {
                    sapAndPositionNumberToAgreementProduct.put(sa.SAP_Number__c + '-' + sap.Position_Number__c, new Map<Integer, SalesAgreementProduct>{(Integer) sap.Position_Number__c => sap});
                }
            }
        }

        SalesAgreementWrapper rc = new SalesAgreementWrapper();
        rc.RecordSet = new SalesAgreementWrapper.RecordDetails(detailsToSend);

        // prepare the callout
        HttpRequest apiRequest = new HttpRequest();
        apiRequest.setMethod('GET');
        apiRequest.setHeader('APIKey', settings.API_Key__c);
        apiRequest.setHeader('Content-Type', 'application/json');
        apiRequest.setBody(JSON.serialize(rc));
        apiRequest.setTimeout(120000);
        apiRequest.setEndpoint(settings.Endpoint__c);
        Http http = new Http();
        HttpResponse toReturn = http.send(apiRequest);
        VolumeResponseWrapper resp;
        try {
            resp = (VolumeResponseWrapper)JSON.deserialize(toReturn.getBody(), VolumeResponseWrapper.class);

            // parse the outcome
            for (VolumeResponseWrapper.ResponseDetails rd : resp.RecordSet.Response) {
                if (String.isBlank(rd.ContractHeaderStatus)) {
                    salesAgreementMap.get(rd.SAPOrderNumber).SAP_Contract_Status__c = 'N/A';
                } else {
                    salesAgreementMap.get(rd.SAPOrderNumber).SAP_Contract_Status__c = rd.ContractHeaderStatus;
                }
                for (VolumeResponseWrapper.ItemDetails item : rd.Item) {
                    if (item.ItemStatus != 'CANCELLED') {
                        Integer positionNumber = Integer.valueOf(item.ItemNumber) / 10;
                        if (sapAndPositionNumberToAgreementProduct.containsKey(rd.SAPOrderNumber + '-' + positionNumber)) {
                            Decimal salesforceQuantity = sapAndPositionNumberToAgreementProduct.get(rd.SAPOrderNumber + '-' + positionNumber).get(positionNumber).Ordered_Quantity__c;

                            Decimal sapQuantity;
                            if (String.isNotBlank(item.ItemOrderedQty) && item.ItemOrderedQty != '0000') {
                                sapQuantity = Decimal.valueOf(item.ItemOrderedQty);
                            } else {
                                sapQuantity = 0;
                            }

                            if (salesforceQuantity != sapQuantity) {
                                if (sapAndPositionNumberToAgreementProduct.get(rd.SAPOrderNumber + '-' + positionNumber).get(positionNumber).Unit_Of_Measure__c == 'MT') {
                                    sapAndPositionNumberToAgreementProduct.get(rd.SAPOrderNumber + '-' + positionNumber).get(positionNumber).Ordered_Quantity__c = sapQuantity / 1000;
                                } else {
                                    sapAndPositionNumberToAgreementProduct.get(rd.SAPOrderNumber + '-' + positionNumber).get(positionNumber).Ordered_Quantity__c = sapQuantity;
                                }
                                agreementProductsToUpdate.add(sapAndPositionNumberToAgreementProduct.get(rd.SAPOrderNumber + '-' + positionNumber).get(positionNumber));
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            String comment = 'Failed during updating SalesAgreementProduct records in SalesAgreementVolumeUpdateBatch'
            + '\n JSON BODY: ' +  toReturn.getBody()
            + '\n REQUEST: ' + rc;
            Utilities.generateDebugLogsForErrorHandling(ex, agreementProductsToUpdate, comment);
        }

        // update results
        try {
            update agreementProductsToUpdate;
            update salesAgreementMap.values();
        } catch (Exception ex) {
            String comment = 'Failed during updating SalesAgreementProduct records in SalesAgreementVolumeUpdateBatch';
            Utilities.generateDebugLogsForErrorHandling(ex, agreementProductsToUpdate, comment);
        }
    }

    public void finish(Database.BatchableContext bc) {}

}