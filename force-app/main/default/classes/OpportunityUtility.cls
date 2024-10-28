/**
* Created by KJM on 28/05/2019.
*/

public with sharing class OpportunityUtility {

    private static List<Opportunity_Stage_Mapping__mdt> opportunityStageMappingList;
    
    public static List<Opportunity_Stage_Mapping__mdt> getOpportunityStageMappingList() {
        if (opportunityStageMappingList == null) {
            opportunityStageMappingList = [
                SELECT Id,
                FCI_Opp_Stage_Name__c,
                External_Opp_Stage_Name__c,
                External_Opp_Stage_Probability__c,
                External_probability_greater_than__c,
                External_probability_less_than_equal_to__c,
                Related_Account_Name__c
                FROM Opportunity_Stage_Mapping__mdt
                WHERE External_probability_greater_than__c != NULL 
                AND External_probability_less_than_equal_to__c != NULL
            ];
        }
        
        return opportunityStageMappingList;
    }

    public static Map<String,Opportunity_Stage_Mapping__mdt> getOppStageMappingMapByProbabilityBrackets() {
        //List<Opportunity_Stage_Mapping__mdt> oppStageMapping = getOpportunityStageMappingListByRelatedAccount(accountName);
        List<Opportunity_Stage_Mapping__mdt> oppStageMapping = getOpportunityStageMappingList();
        
        Map<String, Opportunity_Stage_Mapping__mdt> oppStageMappMapToRet = new Map<String, Opportunity_Stage_Mapping__mdt>();
        for (Opportunity_Stage_Mapping__mdt oppStageMap : oppStageMapping) {
            if (!oppStageMappMapToRet.containsKey(oppStageMap.External_probability_greater_than__c+'/'+oppStageMap.External_probability_less_than_equal_to__c)) {
                oppStageMappMapToRet.put(oppStageMap.External_probability_greater_than__c+'/'+oppStageMap.External_probability_less_than_equal_to__c, oppStageMap);
            }
        }
        
        return oppStageMappMapToRet;
    }

    public static String getFCIStageNameFromProbabilityBracketMap(Map<String, Opportunity_Stage_Mapping__mdt> oppStageMap, String probability, String stageName) {
        if(Integer.valueOf(probability) == Constants.CONSTANT_VALUE_ZERO){
            return oppStageMap.get(Constants.CONSTANT_VALUE_OPPORTUNITY_STAGE_MAPPING_ZERO_BY_ZERO).FCI_Opp_Stage_Name__c;
        }
        for(String probilityBracket : oppStageMap.keySet()){
            if(Integer.valueOf(probability) > Integer.valueOf(probilityBracket.substringBefore('/')) &&  Integer.valueOf(probability) <= Integer.valueOf(probilityBracket.substringAfter('/'))){
                return oppStageMap.get(probilityBracket).FCI_Opp_Stage_Name__c;
            }
        }
        
        return null;
    }
    
    /*public static List<Opportunity_Stage_Mapping__mdt> getOpportunityStageMappingListByRelatedAccount(String accountName) {
        List<Opportunity_Stage_Mapping__mdt> opportunityStageMappings = getOpportunityStageMappingList();
        
        List<Opportunity_Stage_Mapping__mdt> opportunityStageMappingsToReturn = new List<Opportunity_Stage_Mapping__mdt>();
        for (Opportunity_Stage_Mapping__mdt opp : opportunityStageMappings) {
            if (opp.Related_Account_Name__c == accountName) {
                opportunityStageMappingsToReturn.add(opp);
            }
        }
        
        return opportunityStageMappingsToReturn;
    }
    
    public static Map<String, Map<String, Opportunity_Stage_Mapping__mdt>> getOppStageMappingMapByProbabilityAndStageName(String accountName) {
        List<Opportunity_Stage_Mapping__mdt> oppStageMapping = getOpportunityStageMappingListByRelatedAccount(accountName);
        
        Map<String, Map<String, Opportunity_Stage_Mapping__mdt>> oppStageMappMapToRet = new Map<String, Map<String, Opportunity_Stage_Mapping__mdt>>();
        for (Opportunity_Stage_Mapping__mdt oppStageMap : oppStageMapping) {
            if (!oppStageMappMapToRet.containsKey(oppStageMap.External_Opp_Stage_Probability__c)) {
                oppStageMappMapToRet.put(oppStageMap.External_Opp_Stage_Probability__c, new Map<String, Opportunity_Stage_Mapping__mdt>());
            }
            
            oppStageMappMapToRet.get(oppStageMap.External_Opp_Stage_Probability__c).put(oppStageMap.External_Opp_Stage_Name__c, oppStageMap);
        }
        
        return oppStageMappMapToRet;
    }
    
    public static String getFCIStageNameFromMap(Map<String, Map<String, Opportunity_Stage_Mapping__mdt>> oppStageMap, String probability, String stageName) {
        System.debug('oppStageMap --> '+oppStageMap.keySet());
        if (oppStageMap.containsKey(probability)) {
            System.debug('Entered 1st');
            if (oppStageMap.get(probability).size() > 1) {
                System.debug('Entered 2nd');
                if (oppStageMap.get(probability).containsKey(stageName)) {
                    System.debug('Entered 3rd');
                    return oppStageMap.get(probability).get(stageName).FCI_Opp_Stage_Name__c;
                }
            } else {
                System.debug('Entered else 4th');
                return oppStageMap.get(probability).values().get(0).FCI_Opp_Stage_Name__c;
            }
        }
        
        return null;
    }*/
}