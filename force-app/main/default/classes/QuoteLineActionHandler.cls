/**
 * Created by Michal Kwika on 23.10.2019.
 */

global with sharing class QuoteLineActionHandler {
    @InvocableMethod(
            label='Quote Line RT Info update'
    )
    global static void updateRTInformationOnQuoteLine(List<String> lRecordIds) {
        List<SBQQ__QuoteLine__c> lQuoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

        if (lRecordIds!=null && !lRecordIds.isEmpty()) {
            for (SBQQ__QuoteLine__c ql: [SELECT Product_RecordType_DeveloperName__c, SBQQ__Product__r.RecordType.DeveloperName
                                            FROM SBQQ__QuoteLine__c
                                            WHERE ID IN :lRecordIds AND SBQQ__Product__c!=null]){
                if (ql.Product_RecordType_DeveloperName__c != ql.SBQQ__Product__r.RecordType.DeveloperName) {
                    ql.Product_RecordType_DeveloperName__c = ql.SBQQ__Product__r.RecordType.DeveloperName;
                    lQuoteLinesToUpdate.add(ql);
                }
            }
        }

        if (lQuoteLinesToUpdate.size()>0) {
            Database.update(lQuoteLinesToUpdate);
        }
    }
}