public with sharing class QuotesInDraftBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        Set<String> ignoreQuotesOnStatus = new Set<String>{'Accepted by customer', 'Archived', 'Rejected by customer'};
        String stdAccTeamMembersQuery = 'select id, Name, SBQQ__Opportunity2__r.StageName, Opportunity_Close_Date__c, SBQQ__Status__c, CreatedDate, RecordType.name from SBQQ__Quote__c where SBQQ__Primary__c = false and SBQQ__Opportunity2__r.IsClosed = true and SBQQ__Status__c NOT IN (\''+String.join(ignoreQuotesOnStatus,'\',\'')+'\') order by CreatedDate desc';
        return Database.getQueryLocator(stdAccTeamMembersQuery);
    }

    public void execute(Database.BatchableContext batchContext, List<SBQQ__Quote__c> quotesToClose) {
        List<SBQQ__Quote__c> toUpdate = new List<SBQQ__Quote__c>();
      
        for (SBQQ__Quote__c quote : quotesToClose) {
            if (quote.SBQQ__Opportunity2__r.StageName == 'Closed Lost') {
                quote.SBQQ__Status__c = 'Rejected by customer';
                quote.Reason_Opportunity_Won_Loss__c='Cancelled';
            }
            else if (quote.SBQQ__Opportunity2__r.StageName == 'Closed Won') {
                quote.SBQQ__Status__c = 'Archived';
            }
            toUpdate.add(quote);
        }

        List<Database.SaveResult> quotesUpdateResults = Database.update(toUpdate, false);//duplicated records will be ignored
    }

    public void finish(Database.BatchableContext batchContext) {
    }
}