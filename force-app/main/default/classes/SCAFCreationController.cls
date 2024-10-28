public without sharing class SCAFCreationController {
    @AuraEnabled
    public static list<SCAFCreationController.ScafNotificationWrapper> SCAFCeation(String recordId){
        Boolean isShowMessage = false;
        
        list<SCAFCreationController.ScafNotificationWrapper> scafWrapperList = new list<SCAFCreationController.ScafNotificationWrapper>();
        Legal_Sales_Document__c legalSales = [SELECT Id, RecordTypeId, Total_Net_Sales_Value__c, Name,Termination_Notice_Period_In_Months__c, Initial_Term_of_LSD_In_Months__c, Status_of_LSD__c, Extension_Type__c, Deviations_from_RFC_LSD_Template__c, SCAF_Approval_Status__c, SCAF_Count__c,ShowPopUpMessage__c,document_uploaded__c FROM Legal_Sales_Document__c WHERE Id = :recordId LIMIT 1];
        System.debug('legalSales Id '+legalSales.Id);
        System.debug('recordId '+recordId);
        List<SCAF__c> SCAF = [Select Id, Name, SCAF_Approval_Status__c,Legal_Sales_Document__c FROM SCAF__c WHERE Legal_Sales_Document__c = :recordId order by createddate desc];
        //System.debug('SCAF --> '+SCAF[0].Legal_Sales_Document__c);
        List<LSD_Product__c> LSDProduct = [Select Id, Name FROM LSD_Product__c WHERE Legal_Sales_Document__c = :recordId];
        Integer FileCount = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId].size();
        System.debug('FileCount --> '+FileCount);
        /*if(((legalSales.Total_Net_Sales_Value__c >= 25000000 && legalSales.Total_Net_Sales_Value__c < 100000000) || (legalSales.Total_Net_Sales_Value__c >= 100000000)) && legalSales.Initial_Term_of_LSD_In_Months__c >= 36 && legalSales.Termination_Notice_Period_In_Months__c > 12 && legalsales.Deviations_from_RFC_LSD_Template__c == 'Without Deviations'){
if((legalSales.ShowPopUpMessage__c == 0 || legalSales.ShowPopUpMessage__c == 1)){
legalSales.ShowPopUpMessage__c = legalSales.ShowPopUpMessage__c + 1;
update legalSales;
}
else if(legalSales.ShowPopUpMessage__c == null){
legalSales.ShowPopUpMessage__c = 1;
update legalSales;
}
}*/
        System.debug('ShowPopUpMessage__c in SCAFCeation after If --> '+legalSales.ShowPopUpMessage__c);
        if(legalSales.Status_of_LSD__c == 'LSD Agreed with Customer and Pending Formalization' && legalSales.Deviations_from_RFC_LSD_Template__c == 'Deviations' && SCAF.isempty()) {
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = true;
            scafWrapper.TemplateDeviationMSG = 'Please submit your approval(s) request for deviating from Sales Contracting Policy by initiating approval flow via the “SCAF” tab. Be aware that the LSD cannot be formalized without approval(s) in place.';
            scafWrapper.StatusValue = 'The LSD Requires Internal Approval(s)!';
            scafWrapperList.add(scafWrapper);
        } else {
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = false;
            scafWrapper.TemplateDeviationMSG = '';
            scafWrapperList.add(scafWrapper);
        }
        
     /*   if(legalSales.Status_of_LSD__c == 'LSD Agreed with Customer and Pending Formalization' && legalSales.Deviations_from_RFC_LSD_Template__c == 'Deviations' && LSDProduct.isempty()){
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = true;
            scafWrapper.TemplateDeviationMSG = 'Please indicate the relevant products being supplied under this LSD by using the “LSD Product Group” relatedlist';
            scafWrapper.StatusValue = 'Product Information Required!';
            scafWrapperList.add(scafWrapper);
        } else {
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = false;
            scafWrapper.TemplateDeviationMSG = '';
            scafWrapperList.add(scafWrapper);
        }*/
        
        if(legalSales.Status_of_LSD__c == 'LSD in Place' && legalSales.Deviations_from_RFC_LSD_Template__c == 'Without Deviations' && FileCount == 0){
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = true;
            scafWrapper.StatusValue = 'LSD to be Uploaded for Storage!';
            scafWrapper.TemplateDeviationMSG = 'Please upload the signed LSD or explicit customer approval on RFC TCs by using the “Files” button.';
            scafWrapperList.add(scafWrapper);
        } else {
            if(legalSales.Document_Uploaded__c == false && legalSales.Status_of_LSD__c == 'LSD in Place' && FileCount == 1){
                legalSales.document_uploaded__c = true;
                update legalSales;
            }
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = false;
            scafWrapper.TemplateDeviationMSG = '';
            scafWrapperList.add(scafWrapper);
        }
        if(legalSales.Status_of_LSD__c == 'LSD in Place' && legalSales.Deviations_from_RFC_LSD_Template__c == 'Deviations' && legalSales.SCAF_Approval_Status__c == 'Approved' && FileCount == 0){
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = true;
            scafWrapper.StatusValue = 'LSD to be uploaded for storage!';
            scafWrapper.TemplateDeviationMSG = 'Please upload the signed LSD or explicit customer approval on RFC TCs by using the “Files” button.';
            scafWrapperList.add(scafWrapper);
        }
        //added else part now ( not added before )
        else{
            if(legalSales.Document_Uploaded__c == false  && legalSales.Status_of_LSD__c == 'LSD in Place' && FileCount == 1){
                legalSales.document_uploaded__c = true;
                update legalSales;
            }
        }
        if(legalSales.Status_of_LSD__c == 'LSD Agreed with Customer and Pending Formalization' && legalSales.Deviations_from_RFC_LSD_Template__c == 'Deviations' && !SCAF.isEmpty() && SCAF[0].SCAF_Approval_Status__c == 'Draft'){
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = true;
            scafWrapper.StatusValue = 'Review SCAF and Submit Approval';
            scafWrapper.TemplateDeviationMSG = 'New SCAF is created, please review it and use "Submit for Approval" button to submit it for Approval.';
            scafWrapperList.add(scafWrapper);
        }
        else {
            SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
            scafWrapper.isTemplateDeviation = false;
            scafWrapper.TemplateDeviationMSG = '';
            scafWrapperList.add(scafWrapper);
        }
        
        list<SCAFCreationController.ScafNotificationWrapper> finalSc = new list<SCAFCreationController.ScafNotificationWrapper>();
        for(SCAFCreationController.ScafNotificationWrapper sc : scafWrapperList){
            system.debug(sc.isTemplateDeviation+'   ----> '+sc.TemplateDeviationMSG);
            if(sc.isTemplateDeviation !=null && sc.TemplateDeviationMSG !='' && sc.TemplateDeviationMSG != '' && sc.isTemplateDeviation != false ){
                finalSc.add(sc);
            }
        }
        //System.debug('Scaf wrapper ' + finalSc);
        /*if(finalSc.isEmpty()){
SCAFCreationController.ScafNotificationWrapper scafWrapper = new SCAFCreationController.ScafNotificationWrapper();
finalSc.add(scafWrapper);
}*/
        System.debug('Scaf wrapper ' + finalSc);
        return finalSc;
    }
    /*@AuraEnabled
    public static LSDWrapper RetShowPopUpMessage(String recordId){
        Legal_Sales_Document__c legalSales = [SELECT Id, RecordTypeId, Total_Net_Sales_Value__c, Name,Termination_Notice_Period_In_Months__c, Initial_Term_of_LSD_In_Months__c, Status_of_LSD__c, Extension_Type__c, Deviations_from_RFC_LSD_Template__c, SCAF_Approval_Status__c, SCAF_Count__c,ShowPopUpMessage__c FROM Legal_Sales_Document__c WHERE Id = :recordId LIMIT 1];
        //System.debug('legalSales.Total_Net_Sales_Value__c --> '+legalSales.Total_Net_Sales_Value__c);
        //System.debug('legalSales.Initial_Term_of_LSD_In_Months__c --> '+legalSales.Initial_Term_of_LSD_In_Months__c);
        //System.debug('legalSales.Termination_Notice_Period_In_Months__c --> '+legalSales.Termination_Notice_Period_In_Months__c);
        //System.debug('legalSales.Deviations_from_RFC_LSD_Template__c --> '+legalSales.Deviations_from_RFC_LSD_Template__c);
        //System.debug('ShowPopUpMessage__c in RetShowPopUpMessage before If --> '+legalSales.ShowPopUpMessage__c);
        Boolean bool = false;
        if(((legalSales.Total_Net_Sales_Value__c >= 25000000 && legalSales.Total_Net_Sales_Value__c < 100000000) || (legalSales.Total_Net_Sales_Value__c >= 100000000)) && legalSales.Initial_Term_of_LSD_In_Months__c >= 36 && legalSales.Termination_Notice_Period_In_Months__c > 12 && legalsales.Deviations_from_RFC_LSD_Template__c == 'Without Deviations'){
            System.debug('Entered If condition to update Showpopup');
            bool = true;
            if((legalSales.ShowPopUpMessage__c == 0 || legalSales.ShowPopUpMessage__c == 1)){
                legalSales.ShowPopUpMessage__c = legalSales.ShowPopUpMessage__c + 1;
                update legalSales;
            }
            else if(legalSales.ShowPopUpMessage__c == null){
                legalSales.ShowPopUpMessage__c = 1;
                update legalSales;
            }
        }
        //System.debug('ShowPopUpMessage__c in RetShowPopUpMessage after If --> '+legalSales.ShowPopUpMessage__c);
        LSDWrapper lsd = new LSDWrapper();
        if(bool){
            
            lsd.showPopUpCnt = legalSales.ShowPopUpMessage__c;
            lsd.TotalNetSls = legalSales.Total_Net_Sales_Value__c;
            lsd.InitialTLSD = legalSales.Initial_Term_of_LSD_In_Months__c;
            lsd.TermPeriod = legalSales.Termination_Notice_Period_In_Months__c;
            lsd.DevRFC = legalSales.Deviations_from_RFC_LSD_Template__c;
            if(legalSales.Total_Net_Sales_Value__c >= 25000000 && legalSales.Total_Net_Sales_Value__c < 100000000 && bool){
                lsd.displayless100 = true;
                lsd.displaygrt100 = false;
            }
            if(legalSales.Total_Net_Sales_Value__c >= 100000000 && bool){
                lsd.displayless100 = false;
                lsd.displaygrt100 = true;
            }
            System.debug('lsd --> '+lsd);
        }
        return lsd;
    }*/
    public class ScafNotificationWrapper {
        @AuraEnabled
        public Boolean isTemplateDeviation {get;set;}
        @AuraEnabled
        public String TemplateDeviationMSG {get;set;}
        @AuraEnabled
        public String StatusValue {get;set;}
        @AuraEnabled
        public boolean filecnt{set;get;}
        /* @AuraEnabled
public Boolean isExtensionType {get;set;}
@AuraEnabled
public String ExtensionTypeMSG {get;set;}
@AuraEnabled
public Boolean isAgreementWithCustomer {get;set;}
@AuraEnabled
public String AgreementWithCustomerMSG {get;set;}
@AuraEnabled
public Boolean isLSDInPlace {get;set;}
@AuraEnabled
public String LSDInPlaceMSG {get;set;}
@AuraEnabled
public Boolean isLSDInPlaceWithDev {get;set;}
@AuraEnabled
public String LSDInPlaceWithDevMSG {get;set;}
@AuraEnabled
public Boolean isAgreementWithCustomerSCAF {get;set;}
@AuraEnabled
public String AgreementWithCustomerSCAFMSG {get;set;}
@AuraEnabled
public Boolean isExclusivity {get;set;}
@AuraEnabled
public String ExclusivityMSG {get;set;}
*/
    }
    /*public class LSDWrapper{
        @AuraEnabled
        public decimal showPopUpCnt{set;get;}
        @AuraEnabled
        public decimal TotalNetSls{set;get;}
        @AuraEnabled
        public decimal InitialTLSD{set;get;}
        @AuraEnabled
        public decimal TermPeriod{set;get;}
        @AuraEnabled
        public String DevRFC{set;get;}
        @AuraEnabled
        public boolean displayless100{set;get;}
        @AuraEnabled
        public boolean displaygrt100{set;get;}
    }*/
}