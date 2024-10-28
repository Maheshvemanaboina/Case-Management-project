/**      
* @description          To create a relationship between cloned and source opportunity
*/
public without sharing class OpportunityClone {
    
/**    
* @description  To populate source opportunity id on the cloned opportunity
* @param        newOpportunities DESCRIPTION: Accepts the list of new opportunities
*/  
    public static void linkSourceOpportunity(List<Opportunity> newOpportunities){
        Map<id,Opportunity> oppSourceidMap = new Map<id,Opportunity>();
        try{
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FCI New Business Opportunity').getRecordTypeId();
            for(Opportunity opp : newOpportunities){
                if(opp.isClone() && opp.RecordTypeId == oppRecordTypeId){
                    opp.Source_Opportunity_New_Business__c = opp.getCloneSourceId();
                    if(opp.StageName == 'Trial Order'){
                        opp.Trail_Order_Stage_Entered__c = true;
                    }
                }
            }
        }catch(exception e){
            system.debug('line number '+e.getLineNumber()+'error message '+e.getMessage()+'error message'+e.getStackTraceString());
        }
    }
/**    
* @description  To populate cloned opportunity id on the source opportunity
* @param         newOpportunities DESCRIPTION: Accepts the list of new opportunities
*/  
    
    public static void linkClonedOpportunity(List<Opportunity> newOpportunities){
        Map<ID,ID> oppclonedidMap = new Map<ID,ID>();
        List<Opportunity> parentOpp = new List<Opportunity>();
        try{
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('FCI New Business Opportunity').getRecordTypeId();
            for(Opportunity opp : newOpportunities){
                if(opp.Source_Opportunity_New_Business__c != null && opp.RecordTypeId == oppRecordTypeId ){
                    oppclonedidMap.put(opp.ID,opp.Source_Opportunity_New_Business__c);
                }
            }  
            for(opportunity clonedOpp : [select id,Cloned_Opportunity_New_Business__c,Source_Opportunity_New_Business__c from opportunity where id IN :oppclonedidMap.keySet()]){
                Opportunity opp = new Opportunity(ID=clonedOpp.Source_Opportunity_New_Business__c);
                opp.Cloned_Opportunity_New_Business__c = clonedOpp.id;
                parentOpp.add(opp);
            }
            if(!parentOpp.isEmpty()){
                update parentOpp;
            }
        }catch(exception e){
            system.debug('line number '+e.getLineNumber()+'error message '+e.getMessage()+'error message'+e.getStackTraceString());
        }       
    }
}