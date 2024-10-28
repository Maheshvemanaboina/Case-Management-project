public with sharing class ChildLeadWrapper {
    @AuraEnabled       
    public string firstName{get;set;}
    @AuraEnabled       
    public string lastName{get;set;}
    @AuraEnabled    
    public string email{get;set;}
    @AuraEnabled    
    public string company{get;set;}
    @AuraEnabled    
    public string phone{get;set;}
    @AuraEnabled    
    public string campaignId{get;set;}

}