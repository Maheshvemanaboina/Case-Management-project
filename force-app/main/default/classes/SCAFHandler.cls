/***************************************************************************************************
* Class Name   : SCAFHandler
* Created Date : November 26, 2021
* Author       : Sheshadri Pattar Srinivas
* Description  : This class is used to handle the LSD auto extension validation on SCAF records
****************************************************************************************************/
public class SCAFHandler {
    
    public static void validateAutoExtension(List<SCAF__c> newScafList,Map<Id,SCAF__c> oldScafMap){
        set<Id> lsdIIdSet = new set<Id>();
        set<Id> parentLSDIdSet = new set<Id>();
        for(SCAF__c scafRec : newScafList){
            lsdIIdSet.add(scafRec.Legal_Sales_Document__c);
        }
        Map<Id,Id> relatedLSDParentLSDMap = new Map<Id,Id>();
        Map<Id,Legal_Sales_Document__c> lsdMap = new Map<Id,Legal_Sales_Document__c>([SELECT Id,LSD_Child_Extension__c FROM Legal_Sales_Document__c WHERE LSD_Child_Extension__c!=null AND LSD_Child_Extension__r.LSD_Auto_Extension__c = 'Yes' AND Type_of_Related_LSD__c = 'Extension of Term Existing LSD']);
        for(Legal_Sales_Document__c lsdRec : lsdMap.values()){
            parentLSDIdSet.add(lsdRec.LSD_Child_Extension__c);
            relatedLSDParentLSDMap.put(lsdRec.Id,lsdRec.LSD_Child_Extension__c);
        }
        List<SCAF__c> parentScafList = [SELECT Id,Legal_Sales_Document__c,Indemnity__c,Standard_Warranties__c,Standard_Liability__c,Standard_Order_Process__c,Aggregate_Liability_Cap_Amount_EUR__c,Liability_Cap_Per_Year_EUR__c,Standard_Termination__c,Direct_Damages_Capped__c,Standard_Governing_Law__c,Indirect_Damages_ExcludedCapped__c,Penalties_or_Other_Financial_Exposure__c FROM SCAF__c WHERE Legal_Sales_Document__c IN : parentLSDIdSet];
        Map<Id,SCAF__c> parentLSDScafMap = new Map<Id,SCAF__c>();
        String errorMessage = Label.LSD_Auto_Extension_Error_Message_For_Scaf;
        for(SCAF__c scafRec : parentScafList){
              parentLSDScafMap.put(scafRec.Legal_Sales_Document__c,scafRec);
        }
        
        for(SCAF__c scafRec : newScafList){
            if(parentLSDScafMap.containskey(relatedLSDParentLSDMap.get(scafRec.Legal_Sales_Document__c)) && evaluateRelatedSCAF(scafRec,oldScafMap.get(scafRec.Id),parentLSDScafMap.get(relatedLSDParentLSDMap.get(scafRec.Legal_Sales_Document__c))) && errorMessage != null){
                scafRec.addError(errorMessage);
            }
        }
    }
    
    public static boolean evaluateRelatedSCAF(SCAF__c newScafRec,SCAF__c oldScaf,SCAF__c parentScaf){
        Boolean validationFailed = false;
        if(oldScaf.Indemnity__c != newScafRec.Indemnity__c && newScafRec.Indemnity__c != parentScaf.Indemnity__c){
            validationFailed = true;
        }
        if(oldScaf.Standard_Warranties__c != newScafRec.Standard_Warranties__c && newScafRec.Standard_Warranties__c != parentScaf.Standard_Warranties__c){
            validationFailed = true;
        }
        if(oldScaf.Standard_Liability__c != newScafRec.Standard_Liability__c && newScafRec.Standard_Liability__c != parentScaf.Standard_Liability__c){
            validationFailed = true;
        }
        if(oldScaf.Aggregate_Liability_Cap_Amount_EUR__c != newScafRec.Aggregate_Liability_Cap_Amount_EUR__c && newScafRec.Aggregate_Liability_Cap_Amount_EUR__c != parentScaf.Aggregate_Liability_Cap_Amount_EUR__c){
            validationFailed = true;
        }
        if(oldScaf.Liability_Cap_Per_Year_EUR__c != newScafRec.Liability_Cap_Per_Year_EUR__c && newScafRec.Liability_Cap_Per_Year_EUR__c != parentScaf.Liability_Cap_Per_Year_EUR__c){
            validationFailed = true;
        }
        if(oldScaf.Standard_Termination__c != newScafRec.Standard_Termination__c && newScafRec.Standard_Termination__c != parentScaf.Standard_Termination__c){
            validationFailed = true;
        }
        if(oldScaf.Direct_Damages_Capped__c != newScafRec.Direct_Damages_Capped__c && newScafRec.Direct_Damages_Capped__c != parentScaf.Direct_Damages_Capped__c){
            validationFailed = true;
        }
        if(oldScaf.Standard_Governing_Law__c != newScafRec.Standard_Governing_Law__c && newScafRec.Standard_Governing_Law__c != parentScaf.Standard_Governing_Law__c){
            validationFailed = true;
        }
        if(oldScaf.Indirect_Damages_ExcludedCapped__c != newScafRec.Indirect_Damages_ExcludedCapped__c && newScafRec.Indirect_Damages_ExcludedCapped__c != parentScaf.Indirect_Damages_ExcludedCapped__c){
            validationFailed = true;
        }
        if(oldScaf.Penalties_or_Other_Financial_Exposure__c != newScafRec.Penalties_or_Other_Financial_Exposure__c && newScafRec.Penalties_or_Other_Financial_Exposure__c != parentScaf.Penalties_or_Other_Financial_Exposure__c){
            validationFailed = true;
        }
        return validationFailed;
    }
}