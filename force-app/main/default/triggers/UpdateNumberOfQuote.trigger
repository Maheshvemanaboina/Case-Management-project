/*
Created by Krishna on 07/05/2021.

*/

trigger UpdateNumberOfQuote on SBQQ__Quote__c (after insert, after update, after delete, after undelete) {
    
    List<SBQQ__Quote__c> quotes = Trigger.isDelete ? Trigger.old : Trigger.new;
    
    Set<Id> oppoIds = new Set<Id>();
    for (SBQQ__Quote__c q : quotes) {
        if (q.SBQQ__Opportunity2__c  != null) {
            oppoIds.add(q.SBQQ__Opportunity2__c);
        }
    }
    
    List<Opportunity > opposToRollup = new List<Opportunity >();
    
    for (AggregateResult ar : [SELECT SBQQ__Opportunity2__c,Min(SBQQ__Status__c), Count(id) QuoteCount 
                               FROM SBQQ__Quote__c 
                               WHERE SBQQ__Status__c ='Accepted by customer' and SBQQ__Opportunity2__c in: oppoIds 
                               GROUP BY SBQQ__Opportunity2__c])
    						  {
                                   Opportunity opp = new Opportunity();
                                   opp.Id = (Id) ar.get('SBQQ__Opportunity2__c');
                                   opp.No_of_Quotes__c  = (Integer) ar.get('QuoteCount');
                                   opposToRollup.add(opp);
                               }
    
    if(!opposToRollup.isEmpty()){
        update opposToRollup;
    }
}