/*
    Author : Praneeth Krishna
    Description : This is a handler class for Opportunity Object. This class updates campaign field on opportunity
                  if plantaris products are linked to opportunity    
*/
public class OpportunityCampaign {
    public static void updateCampaign(List<Opportunity> Opportunities){
      Integer allProductCount = 0;
      Integer plantarisProductCount = 0;
      set<String> productName = OpportunityLineItemTriggerHandler.getPlantProducts();
      set<ID> planratisOpportunities = new set<ID>();
      for(OpportunityLineItem Oli : [select Id,Name,Product2Id,Product2.Name,OpportunityId from OpportunityLineItem where OpportunityId IN:Opportunities]){
           allProductCount ++;
           if(productName.contains(Oli.Product2.Name)){
                planratisOpportunities.add(Oli.OpportunityId);
                plantarisProductCount ++;
            }
       }
       if(plantarisProductCount > 0){
           for(Opportunity opp : Opportunities){           
                   Opportunity oldOpportunity =(Opportunity) Trigger.oldMap.get(opp.ID);
                   if(opp.CampaignId == null && oldOpportunity.CampaignId != null){
                       if(planratisOpportunities.contains(opp.id)){
                         opp.CampaignId = OpportunityLineItemTriggerHandler.getCampaign();
                       } 
                   } 
           }
       }
    }
}