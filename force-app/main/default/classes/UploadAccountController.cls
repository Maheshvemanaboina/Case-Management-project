/**
 * Created by KJM on 25/06/2019.
 */

public with sharing class UploadAccountController {

    @AuraEnabled
    public static CsvTemplateWrapper getCsvTemplateIds() {
        Set<String> namesToGet = new Set<String>();
        namesToGet.add(Constants.CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME);
        namesToGet.add(Constants.CSV_TEMPLATE_ACCOUNT_NON_LOCALE_DEVELOPER_NAME);
        namesToGet.add(Constants.ACCOUNT_INSTRUCTION_DOCUMENT_DEVELOPER_NAME);

        String localId = '';
        String nonLocalId = '';
        String accountInstructionDocumentId = '';
        List<Document> documents = [SELECT Id, DeveloperName FROM Document WHERE DeveloperName IN :namesToGet];
        for (Document doc : documents) {
            if (doc.DeveloperName == Constants.CSV_TEMPLATE_ACCOUNT_LOCALE_DEVELOPER_NAME) {
                localId = doc.Id;
            }else if(doc.DeveloperName == Constants.ACCOUNT_INSTRUCTION_DOCUMENT_DEVELOPER_NAME){
                accountInstructionDocumentId = doc.Id;
            }else {
                nonLocalId = doc.Id;

            }
        }

        return new CsvTemplateWrapper(nonLocalId, localId, nonLocalId,accountInstructionDocumentId);
    }

    public class CsvTemplateWrapper {
        @AuraEnabled public String defaultId { get; private set; }
        @AuraEnabled public String localId { get; private set; }
        @AuraEnabled public String nonLocalId { get; private set; }
        @AuraEnabled public String accountInstructionDocumentId { get; private set; }

        public CsvTemplateWrapper(String defaultId, String localId, String nonLocalId,String accountInstructionDocumentId) {
            this.defaultId = defaultId;
            this.localId = localId;
            this.nonLocalId = nonLocalId;
            this.accountInstructionDocumentId = accountInstructionDocumentId;
        }
    }
}