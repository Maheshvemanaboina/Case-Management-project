/***************************************************************************************************
* Class Name   : LSDHandler
* Created Date : November 26, 2021
* Author       : Sheshadri Pattar Srinivas
* Description  : This class is used to handle the LSD auto extension validation
****************************************************************************************************/
public class LSDHandler {
    
    public static void validateAutoExtension(List<Legal_Sales_Document__c> newLSDList,Map<Id,Legal_Sales_Document__c> oldLSDMap){
        set<Id> parentLSDIdSet = new set<Id>();
        for(Legal_Sales_Document__c lsdRec : newLSDList){
            if(lsdRec.LSD_Child_Extension__c != null && lsdRec.Type_of_Related_LSD__c == 'Extension of Term Existing LSD'){
                parentLSDIdSet.add(lsdRec.LSD_Child_Extension__c);
            }
        }
        String errorMessage = Label.LSD_Auto_Extension_Error_Message;
        Map<Id,Legal_Sales_Document__c> parentLSDMap = new Map<Id,Legal_Sales_Document__c>([SELECT Id,Business_Group__c,Account_Name__c,FC_Legal_Entity__c,Leading_Business_Segment__c,Other_Business_Segment__c,Deviations_from_RFC_LSD_Template__c FROM Legal_Sales_Document__c WHERE Id IN : parentLSDIdSet AND LSD_Auto_Extension__c ='Yes']);
        for(Legal_Sales_Document__c lsdRec : newLSDList){
            if(!parentLSDMap.isEmpty() && lsdRec.LSD_Child_Extension__c != null && parentLSDMap.containskey(lsdRec.LSD_Child_Extension__c) && validateRelatedLSD(lsdRec,oldLSDMap.get(lsdRec.Id),parentLSDMap.get(lsdRec.LSD_Child_Extension__c)) && errorMessage != null){
                lsdRec.addError(errorMessage);
            }
        }
    }
    
    public static Boolean validateRelatedLSD(Legal_Sales_Document__c newLSD,Legal_Sales_Document__c oldLSD,Legal_Sales_Document__c parentLSD){
        Boolean validationFailed = false;
        if(newLSD.Business_Group__c != oldLSD.Business_Group__c && newLSD.Business_Group__c != parentLSD.Business_Group__c){
            validationFailed = true;
        }
        if(newLSD.Account_Name__c != oldLSD.Account_Name__c && newLSD.Account_Name__c != parentLSD.Account_Name__c){
            validationFailed = true;
        }
        if(newLSD.FC_Legal_Entity__c != oldLSD.FC_Legal_Entity__c && newLSD.FC_Legal_Entity__c != parentLSD.FC_Legal_Entity__c){
            validationFailed = true; 
        }
        if(newLSD.Leading_Business_Segment__c != oldLSD.Leading_Business_Segment__c && newLSD.Leading_Business_Segment__c != parentLSD.Leading_Business_Segment__c){
            validationFailed = true;
        }
        if(newLSD.Other_Business_Segment__c != oldLSD.Other_Business_Segment__c && newLSD.Other_Business_Segment__c != parentLSD.Other_Business_Segment__c){
            validationFailed = true;
        }
        if(newLSD.Deviations_from_RFC_LSD_Template__c != oldLSD.Deviations_from_RFC_LSD_Template__c && newLSD.Deviations_from_RFC_LSD_Template__c != parentLSD.Deviations_from_RFC_LSD_Template__c){
            validationFailed = true;
        }
        return validationFailed;
    }
    
    
}