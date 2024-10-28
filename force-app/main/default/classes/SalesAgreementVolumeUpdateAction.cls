public with sharing class SalesAgreementVolumeUpdateAction {
    @InvocableMethod(callout=true Label='Update Volume on Sales Agreement Products' Description='Update Volume on Sales Agreement Products' Category='Quote')
    public static List<Id> processData(List<String> salesAgreementId) {

        List<SalesAgreementWrapper.SADetails> detailsToSend = new List<SalesAgreementWrapper.SADetails>();
        List<SalesAgreementProduct> agreementProductsToUpdate = new List<SalesAgreementProduct>();
        Map<Integer, SalesAgreementProduct> positionNumberToAgreementProduct = new Map<Integer, SalesAgreementProduct>();
        OrderStatusIntegration__c settings = OrderStatusIntegration__c.getOrgDefaults();

        SalesAgreement agreement = [SELECT SAP_Number__c, SAP_Contract_Status__c, (SELECT Id, Position_Number__c, Ordered_Quantity__c, Unit_Of_Measure__c FROM SalesAgreementProducts) FROM SalesAgreement WHERE Id = :salesAgreementId[0]];

        // prepare the payload
        detailsToSend.add(new SalesAgreementWrapper.SADetails(agreement.SAP_Number__c, '000000', 'C'));
        for (SalesAgreementProduct sap : agreement.SalesAgreementProducts) {
            positionNumberToAgreementProduct.put((Integer) sap.Position_Number__c, sap);
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
        VolumeResponseWrapper resp = (VolumeResponseWrapper)JSON.deserialize(toReturn.getBody(), VolumeResponseWrapper.class);

        // parse the outcome
        for (VolumeResponseWrapper.ResponseDetails rd : resp.RecordSet.Response) {
            if (String.isBlank(rd.ContractHeaderStatus)) {
                agreement.SAP_Contract_Status__c = 'N/A';
            } else {
                agreement.SAP_Contract_Status__c = rd.ContractHeaderStatus;
            }

            for (VolumeResponseWrapper.ItemDetails item : rd.Item) {
                if (item.ItemStatus != 'CANCELLED') {
                    Integer positionNumber = Integer.valueOf(item.ItemNumber) / 10;
                    if (positionNumberToAgreementProduct.containsKey(positionNumber)) {
                        Decimal salesforceQuantity = positionNumberToAgreementProduct.get(positionNumber).Ordered_Quantity__c;
                        Decimal sapQuantity;
                        if (String.isNotBlank(item.ItemOrderedQty) && item.ItemOrderedQty != '0000') {
                            sapQuantity = Decimal.valueOf(item.ItemOrderedQty);
                        } else {
                            sapQuantity = 0;
                        }

                        if (salesforceQuantity != sapQuantity) {
                            if (positionNumberToAgreementProduct.get(positionNumber).Unit_Of_Measure__c == 'MT') {
                                positionNumberToAgreementProduct.get(positionNumber).Ordered_Quantity__c = sapQuantity / 1000;
                            } else {
                                positionNumberToAgreementProduct.get(positionNumber).Ordered_Quantity__c = sapQuantity;
                            }
                            agreementProductsToUpdate.add(positionNumberToAgreementProduct.get(positionNumber));
                        }
                    }
                }
            }
        }

        try {
            Database.update(agreementProductsToUpdate);
            Database.update(agreement);
            return salesAgreementId;
        } catch (Exception ex) {
            String comment = 'Failed during updating SalesAgreementProduct records in SalesAgreementVolumeUpdateAction';
            Utilities.generateDebugLogsForErrorHandling(ex, agreementProductsToUpdate, comment);
            return null;
        }
    }
}