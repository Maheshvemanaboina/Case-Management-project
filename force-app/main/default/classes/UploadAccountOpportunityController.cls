/*************************************************************** KJM - 09/04/2019
 Name: UploadAccountController
 ======================================================
 Purpose: Class used for Upload Controllers
 ======================================================
***************************************************************/
public with sharing class UploadAccountOpportunityController {

    @AuraEnabled
    public static CsvTemplateWrapper getCsvTemplateIds(String objectToGetTemplate) {
        Set<String> namesToGet = new Set<String>();
        if (objectToGetTemplate == Constants.ACCOUNT_API_NAME) {
            namesToGet.add(Constants.CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME);
            namesToGet.add(Constants.CSV_TEMPLATE_ACCOUNT_NON_LOCALE_DEVELOPER_NAME);
        } else if (objectToGetTemplate == Constants.OPPORTUNITY_API_NAME) {
            namesToGet.add(Constants.CSV_TEMPLATE_OPPORTUNITY_LOCALE_DEVELOPER_NAME);
            namesToGet.add(Constants.CSV_TEMPLATE_OPPORTUNITY_NON_LOCALE_DEVELOPER_NAME);
        }

        String localId = '';
        String nonLocalId = '';

        List<Document> documents = [SELECT Id, DeveloperName FROM Document WHERE DeveloperName IN :namesToGet];
        for (Document doc : documents) {
            if (doc.DeveloperName == Constants.CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME || doc.DeveloperName == Constants.CSV_TEMPLATE_OPPORTUNITY_LOCALE_DEVELOPER_NAME) {
                localId = doc.Id;
            } else {
                nonLocalId = doc.Id;
            }
        }

        return new CsvTemplateWrapper(localId, localId, nonLocalId);
    }

    public class CsvTemplateWrapper {
        @AuraEnabled public String defaultId { get; private set; }
        @AuraEnabled public String localId { get; private set; }
        @AuraEnabled public String nonLocalId { get; private set; }

        public CsvTemplateWrapper(String defaultId, String localId, String nonLocalId) {
            this.defaultId = defaultId;
            this.localId = localId;
            this.nonLocalId = nonLocalId;
        }
    }
}