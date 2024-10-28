/*
@Author     : Rohit Kumar
@CreatedDate: 20-07-2020
@UsedBy     : DisplayAndDownloadCoAsAtRecordPage (Lightning Component)
@Description: This class will fetch CoA from SAP , this Component present At Delivery And Order Record Page. 

@History
  20-07-2020  Rohit Kumar : Created
*/


public without sharing class DisplayCoAsAtRecordPageHandler {
    
    
    @AuraEnabled
    public static ShowCoAAtRecordDetailPage fetchCertificateOfAnalysis(id recordid,string baseURLSFDC){
        
        id coARecordTypeId = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        String objectType =recordid.getSObjectType().getDescribe().getName();
        ShowCoAAtRecordDetailPage coaDetails = new ShowCoAAtRecordDetailPage();
        Set<CoAFileData> filesFromSAPorSFDC = new Set<CoAFileData>();
        
        
        if(objectType.equals('Order')){
            
            Order orderDetails = [select id,SAP_Sales_Order_Number__c,PoNumber from Order  where id=:recordid limit 1];
            
            if(orderDetails!=null && orderDetails.SAP_Sales_Order_Number__c!=null){
                
                Tile__c tile = new Tile__c();
                tile.Sales_Order_Number__c = orderDetails.SAP_Sales_Order_Number__c;
                tile.Purchase_Order_Number__c = orderDetails.PoNumber;
                tile.RecordTypeId = coARecordTypeId;
                DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs fetchCoA = DisplayAndDownloadCoAHandler.userEnteredSalesOrderNumber(
                                                                                tile, baseURLSFDC, false,'Sales Order Number');
                coaDetails.errorsMessage = fetchCoA.errorsInfo;
                
                if(fetchCoA.fileRecord!=null && fetchCoA.fileRecord.size()>0){
                    for(DisplayAndDownloadCoAHandler.FileData file :fetchCoA.fileRecord){
                        CoAFileData coaData = new CoAFileData(file.fileName,file.fileId,file.downloadUrl);
                        filesFromSAPorSFDC.add(coaData);
                    }
                }   
                if(filesFromSAPorSFDC.size()>0)
                    coaDetails.coaRecord = filesFromSAPorSFDC;
                return coaDetails;
            }
            
        }
        else if(objectType.equals('Delivery__c')){
            
            String deliveryNumber =[select id,SAP_Delivery_Number__c from Delivery__c where id=:recordid limit 1].SAP_Delivery_Number__c;
            
            if(deliveryNumber!=null){
                
                Tile__c tile = new Tile__c();
                tile.Delivery_Number__c = deliveryNumber;
                tile.RecordTypeId = coARecordTypeId;
                DisplayAndDownloadCoAHandler.AllDetailsRelatedToCoAs fetchCoA = DisplayAndDownloadCoAHandler.userEnteredDeliveryNumber(
                                                                                tile, baseURLSFDC, false, false, null,'Delivery Number',true);
                coaDetails.errorsMessage = fetchCoA.errorsInfo;
                
                if(fetchCoA.fileRecord!=null && fetchCoA.fileRecord.size()>0){
                    for(DisplayAndDownloadCoAHandler.FileData file :fetchCoA.fileRecord){
                        CoAFileData coaData = new CoAFileData(file.fileName,file.fileId,file.downloadUrl);
                        filesFromSAPorSFDC.add(coaData);
                    }
                }   
                if(filesFromSAPorSFDC.size()>0)
                    coaDetails.coaRecord = filesFromSAPorSFDC;
                return coaDetails;
            }
            
        }
        
        return coaDetails;
    }
                
    public class ShowCoAAtRecordDetailPage{
        
        @AuraEnabled public string errorsMessage{get;set;}
        @AuraEnabled public Set<CoAFileData> coaRecord{get;set;}
        
        public ShowCoAAtRecordDetailPage(){
            This.errorsMessage='';
            This.coaRecord = new Set<CoAFileData>();
        }
    }
    public class CoAFileData{
        
        @AuraEnabled public String coAfileName {get;set;}
        @AuraEnabled public String coAFileId {get;set;}
        @AuraEnabled Public String coaDownloadUrl {get;set;}
        
        public  CoAFileData(String coAfileName,String coAFileId,String coaDownloadUrl){
            This.coAfileName = coAfileName;
            This.coAFileId = coAFileId;
            This.coaDownloadUrl = coaDownloadUrl;
        }
    }
}