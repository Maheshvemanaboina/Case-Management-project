public class RollUpChildsToParent {
     
    
    public static List<Supplier_Hub__c> rollUpChilddata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier_Name__c, Start_Date__c, End_Date__c ,Contract_Type__c,Bonus_clause__c, Volume_commitment_given_by_FC__c, OwnerId from  Supplier_Contracts__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    /*public static List<Supplier_Hub__c> rollUpChilddataProject(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier_Name__c, Phase__c, Project_Category__c,Project_Type__c,Project_Goal__c, Status__c, Location__c,Location__r.Name from  Supplier_Projects__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> rollUpChilddataClaims(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier_Name__c, Cost__c, Comments__c,Deadline__c,Traffic_Light__c from  Claims__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> rollUpContingencyPlan(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (SELECT Id, Name,Supplier_Name__c, Source__c, Material__r.name  , Status__c, CreatedById, createdby.name  FROM Contingency_Plans__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }*/
    @AuraEnabled
    public static void delContract(Supplier_Contract__c recordId){
        delete recordId;
    }
    @AuraEnabled
    public static void delprojectRecord(Supplier_Project__c recordId){
        delete recordId;
    }
    @AuraEnabled
    public static void delClaim(Claim__c recordId){
        delete recordId;
    }
     @AuraEnabled
    public static void delComplaint(Complaints__c recordId){
        delete recordId;
    }
     @AuraEnabled
    public static void delCplan(Contingency_Plan__c recordId){
        delete recordId;
    }
    /*public static List<Claim__c> collateAllSupplierClaims(String recordId){
        List<Claim__c> relatedclaimsFinal = new List<Claim__c>();
        List<Supplier_Hub__c> allRelatedChildhubs = rollUpChilddataClaims(recordId);
        if(! allRelatedChildhubs.isEmpty()){
            for(Supplier_Hub__c obj: allRelatedChildhubs){
                relatedclaimsFinal.addAll(obj.Claims__r);
            }
        }
        system.debug('relatedclaimsFinal '+ relatedclaimsFinal.size());
        return relatedclaimsFinal;          
    }*/
    
    /*public static List<Complaints__c> collateAllSupplierComplaints(String recordId){
        List<Complaints__c> relatedComplaints = new List<Complaints__c>();
        List<Supplier_Hub__c> allRelatedChildhubs = rollUpComplaintdata(recordId);
        if(! allRelatedChildhubs.isEmpty()){
            for(Supplier_Hub__c obj: allRelatedChildhubs){
                relatedComplaints.addAll(obj.Complaints__r);
            }
        }
        system.debug('relatedComplaints '+ relatedComplaints.size());
        return relatedComplaints;          
    }*/
    
    /*public static List<Contingency_Plan__c> collateAllSupplierCPlans(String recordId){
        List<Contingency_Plan__c> relatedCplans = new List<Contingency_Plan__c>();
        List<Supplier_Hub__c> allRelatedChildhubs = rollUpContingencyPlan(recordId);
        if(! allRelatedChildhubs.isEmpty()){
            for(Supplier_Hub__c obj: allRelatedChildhubs){
                relatedCplans.addAll(obj.Contingency_Plans__r);
            }
        }
        system.debug('relatedCplans '+ relatedCplans.size());
        return relatedCplans;          
    }*/
    @AuraEnabled
    public static List<Supplier_Contract__c> getContractdata (string recordId){
        List<Supplier_Contract__c> finalList = new List<Supplier_Contract__c>();
        List<Supplier_Hub__c> relatedContractsFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedContractdata = getRelatedContractdata(recordId);
        List<Supplier_Hub__c> nativeContractdata = getNativeContractdata(recordId);
        if( relatedContractdata.isEmpty()){
            return null;
        }
        relatedContractsFinal.AddAll(nativeContractdata);
        relatedContractsFinal.AddAll(relatedContractdata);
       
        if(! relatedContractsFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedContractsFinal){
               
                finalList.addAll(obj.Supplier_Contracts__r);
            }
        }
        system.debug('final list '+ finalList);
        return finalList;
    }
    public class dataWrapper{
        @AuraEnabled public List<Supplier_Contract__c> finalList;
        @AuraEnabled public User objectUser;
    }
    public static List<Supplier_Hub__c> getRelatedContractdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier_Hub__c, Supplier_Name__c, Start_Date__c, End_Date__c ,Contract_Type__c,Bonus_clause__c, Volume_commitment_given_by_FC__c, OwnerId,Supplier_Hub__r.Name from  Supplier_Contracts__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeContractdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier_Name__c, Supplier_Hub__c, Start_Date__c, End_Date__c ,Contract_Type__c,Bonus_clause__c, Volume_commitment_given_by_FC__c, OwnerId,Supplier_Hub__r.Name from  Supplier_Contracts__r) from Supplier_Hub__c where Id =: recordId];
    }
    @AuraEnabled
    public static List<Supplier_Project__c> collateAllSupplierProjects (string recordId){
        List<Supplier_Project__c> finalList = new List<Supplier_Project__c>();
        List<Supplier_Hub__c> relatedProjectsFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedProjectdata = getRelatedProjectdata(recordId);
        List<Supplier_Hub__c> nativeProjectdata = getNativeProjectdata(recordId);
        if( relatedProjectdata.isEmpty()){
            return null;
        }
        relatedProjectsFinal.AddAll(nativeProjectdata);
        relatedProjectsFinal.AddAll(relatedProjectdata);
       
        if(! relatedProjectsFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedProjectsFinal){
                finalList.addAll(obj.Supplier_Projects__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }
    public static List<Supplier_Hub__c> getRelatedProjectdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier_Name__c, Supplier__c, Phase__c, Project_Category__c,Project_Type__c,Project_Goal__c, Status__c, Location__c, Location__r.Name,Supplier__r.Name,Start_Date__c,FYI_approved__c from  Supplier_Projects__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeProjectdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier_Name__c, Supplier__c, Phase__c, Project_Category__c,Project_Type__c,Project_Goal__c, Status__c, Location__c, Location__r.Name,Supplier__r.Name,Start_Date__c,FYI_approved__c from  Supplier_Projects__r) from Supplier_Hub__c where Id =: recordId];
    }

@AuraEnabled
    public static List<Claim__c> collateAllSupplierClaims (string recordId){
        List<Claim__c> finalList = new List<Claim__c>();
        List<Supplier_Hub__c> relatedClaimsFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedClaimdata = getRelatedclaimdata(recordId);
        List<Supplier_Hub__c> nativeClaimdata = getNativeClaimdata(recordId);
        if( relatedClaimdata.isEmpty()){
            return null;
        }
        relatedClaimsFinal.AddAll(nativeClaimdata);
        relatedClaimsFinal.AddAll(relatedClaimdata);
       
        if(! relatedClaimsFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedClaimsFinal){
                finalList.addAll(obj.Claims__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }
    public static List<Supplier_Hub__c> getRelatedclaimdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier__c, Supplier_Name__c, Cost__c, Comments__c,Deadline__c,Traffic_Light__c,Supplier__r.Name from  Claims__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeClaimdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier__c, Supplier_Name__c, Cost__c, Comments__c,Deadline__c,Traffic_Light__c,Supplier__r.Name from  Claims__r) from Supplier_Hub__c where Id =: recordId];
    }

@AuraEnabled
    public static List<Contingency_Plan__c> collateAllSupplierCPlans (string recordId){
        List<Contingency_Plan__c> finalList = new List<Contingency_Plan__c>();
        List<Supplier_Hub__c> relatedDataFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedData = getRelatedcPandata(recordId);
        List<Supplier_Hub__c> nativeData = getNativecPlandata(recordId);
        if( relatedData.isEmpty()){
            return null;
        }
        relatedDataFinal.AddAll(nativeData);
        relatedDataFinal.AddAll(relatedData);
       
        if(! relatedDataFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedDataFinal){
                finalList.addAll(obj.Contingency_Plans__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }
    public static List<Supplier_Hub__c> getRelatedcPandata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (SELECT Id, Name,Supplier_Name__c, Supplier_Hub__c, Source__c, Material__c, Material__r.name  , Status__c,Description_Of_Contingency_Measure__c, CreatedById, createdby.name,Supplier_Hub__r.Name  FROM Contingency_Plans__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativecPlandata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (SELECT Id, Name,Supplier_Name__c, Supplier_Hub__c, Source__c,Material__c,  Material__r.name  , Status__c,Description_Of_Contingency_Measure__c, CreatedById, createdby.name,Supplier_Hub__r.Name  FROM Contingency_Plans__r) from Supplier_Hub__c where Id =: recordId];
    }

@AuraEnabled
    public static List<Complaints__c> collateAllSupplierComplaints (string recordId){
        List<Complaints__c> finalList = new List<Complaints__c>();
        List<Supplier_Hub__c> relatedDataFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedData = getRelateddata(recordId);
        List<Supplier_Hub__c> nativeData = getNativedata(recordId);
        if( relatedData.isEmpty()){
            return null;
        }
        relatedDataFinal.AddAll(nativeData);
        relatedDataFinal.AddAll(relatedData);
       
        if(! relatedDataFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedDataFinal){
                finalList.addAll(obj.Complaints__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }
    public static List<Supplier_Hub__c> getRelateddata(String recordId){
        return [select id ,Name, Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (SELECT Id, Name, Supplier__c, Category_Name__c, Supplier_Name__c,Category_Group_Name__c, Category_Subgroup__r.Name,Description__c, Current_Age__c,Supplier__r.Name FROM Complaints__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativedata(String recordId){
        return [select id , Name, Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (SELECT Id, Name, Supplier__c, Supplier_Name__c,Category_Name__c, Category_Group_Name__c, Category_Subgroup__r.Name,Description__c, Current_Age__c,Supplier__r.Name FROM Complaints__r) from Supplier_Hub__c where Id =: recordId];
    }
    @AuraEnabled
    public static List<Supplier_Combined_Categories__c> collateAllSupplierCategories (string recordId){
        List<Supplier_Combined_Categories__c> finalList = new List<Supplier_Combined_Categories__c>();
        List<Supplier_Hub__c> relatedDataFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedData = getRelatedCategoryData(recordId);
        List<Supplier_Hub__c> nativeData = getNativeCategorydata(recordId);
        if( relatedData.isEmpty()){
            return null;
        }
        relatedDataFinal.AddAll(nativeData);
        relatedDataFinal.AddAll(relatedData);
       
        if(! relatedDataFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedDataFinal){
                finalList.addAll(obj.SupplierCombinedCategories__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }
    public static List<Supplier_Hub__c> getRelatedCategoryData(String recordId){
        return [select id , Name, Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, OwnerId,Combined_Category_Name__c,Combined_Category_Subgroup__c, Combined_Category_Subgroup__r.name,Combined_Category_Group_Name__c, Supplier_Hub_Number__c,Supplier_Hub_Number__r.Supplier_Name__c,Supplier_Hub_Number__r.Name,Subcategory_slotting__c from  SupplierCombinedCategories__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeCategorydata(String recordId){
    return [select id , Name, Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, OwnerId,Combined_Category_Name__c,Combined_Category_Subgroup__c, Combined_Category_Group_Name__c, Supplier_Hub_Number__c, Combined_Category_Subgroup__r.name, Supplier_Hub_Number__r.Supplier_Name__c,Supplier_Hub_Number__r.Name,Subcategory_slotting__c from  SupplierCombinedCategories__r) from Supplier_Hub__c where Id =: recordId];

    }
    @AuraEnabled
    public static List<Meeting_Structure__c> getMeetingStructuredata (string recordId){
        List<Meeting_Structure__c> finalList = new List<Meeting_Structure__c>();
        List<Supplier_Hub__c> relatedMSFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedMSdata = getRelatedMeetingStructuredata(recordId);
        List<Supplier_Hub__c> nativeMSdata = getNativeMeetingStructuredata(recordId);
        if( relatedMSdata.isEmpty()){
            return null;
        }
        relatedMSFinal.AddAll(nativeMSdata);
        relatedMSFinal.AddAll(relatedMSdata);
       
        if(! relatedMSFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedMSFinal){
                finalList.addAll(obj.Meeting_Structures__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }

    public static List<Supplier_Hub__c> getRelatedMeetingStructuredata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Frequency_of_the_Meeting__c, Type__c, OwnerId,Supplier_Hub_Number__r.Name,Supplier_Hub_Number__r.Supplier_Name__c from  Meeting_Structures__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeMeetingStructuredata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Frequency_of_the_Meeting__c, Type__c, OwnerId,Supplier_Hub_Number__r.Name,Supplier_Hub_Number__r.Supplier_Name__c from  Meeting_Structures__r) from Supplier_Hub__c where Id =: recordId];
    }
    
    @AuraEnabled
    public static List<Meeting_Notes__c> getMeetingSummarydata (string recordId){
        List<Meeting_Notes__c> finalList = new List<Meeting_Notes__c>();
        List<Supplier_Hub__c> relatedMNFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedMNdata = getRelatedMeetingSummarydata(recordId);
        List<Supplier_Hub__c> nativeMNdata = getNativeMeetingSummarydata(recordId);
        if( relatedMNdata.isEmpty()){
            return null;
        }
        relatedMNFinal.AddAll(nativeMNdata);
        relatedMNFinal.AddAll(relatedMNdata);
       
        if(! relatedMNFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedMNFinal){
                finalList.addAll(obj.Meeting_Notes__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }

    public static List<Supplier_Hub__c> getRelatedMeetingSummarydata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Meeting_Date__c, Type__c, Meeting_Type__c, OwnerId,Supplier_Hub_Number__r.Name , Supplier_Hub_Number__r.Supplier_Name__c from  Meeting_Notes__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeMeetingSummarydata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Meeting_Date__c, Type__c, Meeting_Type__c, OwnerId,Supplier_Hub_Number__r.Name, Supplier_Hub_Number__r.Supplier_Name__c from  Meeting_Notes__r) from Supplier_Hub__c where Id =: recordId];
    }
    @AuraEnabled
    public static User verifyIfPortaluser(){
        User objUser = [SELECT Id , IsPortalEnabled,Supplier_Hub_ID__c FROM User WHERE Id =: userinfo.getUserId()];
        return objuser;
    }
    //Roll up Vendor BK data
    @AuraEnabled
    public static List<Supplier_SAP_Numbers_And_Payment_Terms__c> getVendorBkdata (string recordId){
        List<Supplier_SAP_Numbers_And_Payment_Terms__c> finalList = new List<Supplier_SAP_Numbers_And_Payment_Terms__c>();
        List<Supplier_Hub__c> relatedMNFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedMNdata = getRelatedBKdata(recordId);
        List<Supplier_Hub__c> nativeMNdata = getNativeBKdata(recordId);
        if( relatedMNdata.isEmpty()){
            return null;
        }
        relatedMNFinal.AddAll(nativeMNdata);
        relatedMNFinal.AddAll(relatedMNdata);
       
        if(! relatedMNFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedMNFinal){
                finalList.addAll(obj.Supplier_SAP_Numbers_And_Payment_Terms__r);
            }
        }
        system.debug('finalList '+ finalList.size());        
        return finalList;
    }

    public static List<Supplier_Hub__c> getRelatedBKdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Duns_Sid__c, Payment_Term_Code__c, Payment_Term_Description__c, Vendor_SAP_Description__c, Vendor_Sap_Number__c, Vendor_Source__c,Supplier_Hub__c, Supplier_Hub__r.Name , Supplier_Hub__r.Supplier_Name__c from  Supplier_SAP_Numbers_And_Payment_Terms__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeBKdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Duns_Sid__c, Payment_Term_Code__c, Payment_Term_Description__c, Vendor_SAP_Description__c, Vendor_Sap_Number__c, Supplier_Hub__c, Vendor_Source__c,Supplier_Hub__r.Name , Supplier_Hub__r.Supplier_Name__c from  Supplier_SAP_Numbers_And_Payment_Terms__r) from Supplier_Hub__c where Id =: recordId];
    }
    
     @AuraEnabled
    public static List<Risk__c> getRisks (string recordId){
        List<Risk__c> finalList = new List<Risk__c>();
        List<Supplier_Hub__c> relatedContractsFinal = new List<Supplier_Hub__c>();
        List<Supplier_Hub__c> relatedContractdata = getRelatedRiskdata(recordId);
        List<Supplier_Hub__c> nativeContractdata = getNativeRiskdata(recordId);
        system.debug('relatedRiskdata '+ relatedContractdata);
        system.debug('nativeRiskData '+ nativeContractdata);
        if( relatedContractdata.isEmpty()){
            return null;
        }
        relatedContractsFinal.AddAll(relatedContractdata);
        relatedContractsFinal.AddAll(nativeContractdata);
       
        if(! relatedContractsFinal.isEmpty()){
            for(Supplier_Hub__c obj: relatedContractsFinal){
               
                finalList.addAll(obj.Risks__r);
            }
        }
        system.debug('final list risk'+ finalList);
        return finalList;
    }
    
    public static List<Supplier_Hub__c> getRelatedRiskdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier__c, Supplier__r.Supplier_Name__c,Supplier__r.Name,Classification_incident__c,Severity_assessment_date__c from  Risks__r) from Supplier_Hub__c where Parent_Supplier__c =: recordId];
    }
    public static List<Supplier_Hub__c> getNativeRiskdata(String recordId){
        return [select id , Supplier_Name__c , Parent_Supplier__r.Supplier_Name__c , Parent_Supplier__c, (select id, Name, Supplier__c, Supplier__r.Supplier_Name__c,Supplier__r.Name,Classification_incident__c, Severity_assessment_date__c from  Risks__r) from Supplier_Hub__c where Id =: recordId ];
    }
}