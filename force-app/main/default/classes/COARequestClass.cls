/*
@Author     : Suyogya Jain
@CreatedDate: 15/07/2020
@UsedBy     : DisplayAndDownloadCoAHandler (Lightning Component Controller)
@Description: This Class will fetch CoA from the SAP based on Delivery number or Batch Number.

@History
  15/07/2020  Suyogya Jain : Created
  02/08/2021  Rohit Kumar : Added logic for retrival of CoA based on Batch Number and also added condition 
							to log Custome Debug to log integration error.
*/



Global  without sharing class COARequestClass {
    
    public static contentUserInfo callSAPCOAService(Tile__c tile,Boolean enteredNumberIsNotPresentInSF,String typeOfNumberEntered){
        
        contentUserInfo contUserInfo = new contentUserInfo();
        Map<String, List<ContentVersion>> contentTileMap = new Map<String, List<ContentVersion>>();
        wrapperforRecords wrap = new wrapperforRecords();   
        wrap.Record = new List<passingData>();
        List<passingData> passDataListInAPI = new List<passingData>();
        passingData passObj;            
        String str;

        contUserInfo.errorInfo = '';
        String shipToNumber='';
        
        try{ 
             //Creating Request data, which will send to SAP for fetching COA
            if(tile.Delivery_Number__c!=null && tile.Delivery_Number__c!=''){
                wrap.Record.add(new passingData(tile.Delivery_Number__c,'','', ''));
                    str = JSON.serializePretty(wrap);
            }
            else if(tile.Batch_Number__c!= null && tile.Batch_Number__c!='' && typeOfNumberEntered.equals('Child Batch Number')){   // Request for child batch
                wrap.Record.add(new passingData(tile.Delivery_Number__c,'',tile.Batch_Number__c, tile.ShipToParty__c));
                str = JSON.serializePretty(wrap);   
            }
            else if(tile.Batch_Number__c!= null && tile.Batch_Number__c!='' && typeOfNumberEntered.equals('Batch Number')){    //Request for Mother Batch
                wrap.Record.add(new passingData(tile.Delivery_Number__c,tile.Batch_Number__c, '',tile.ShipToParty__c));
                str = JSON.serializePretty(wrap);   
            }
            
            //system.debug('request-->'+str);
            Http h = new Http();    
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SAP_PO_CALLOUT_COA'); //callout endpoint and password is mention in the Named Credential
            req.setMethod('POST');
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(str);
            req.setTimeout(120000);
            HttpResponse response = h.send(req);
         
            system.debug('Status scode-->'+response.getStatusCode());
            
            if (response.getStatusCode() == 200) {
                
                string resbody = response.getBody();
                if(resbody!='""'){
                    Map<String,Object> results = (Map<String,Object>)JSON.deserializeUntyped(resbody);
                    Map<Id, object> testob = new Map<Id, object>();
                    List<Map<String, Object>> data = new List<Map<String, Object>>();
                    List<Object> getResult = New List<Object>();
                    getResult = results.values();
                    if(getResult.size()>0){
                        try{
                            for (Object instance :(List<Object>)results.get('Record'))  //if returned reponse is the list of record(which contains CoA for every delivery line item of the delivery)
                                data.add((Map<String, Object>)instance);
                        }
                        catch(exception ex){
                            for (Object instance :results.values())                       //if no COA found for the delivery number, returned response is in this format  
                                data.add((Map<String, Object>)instance);
                        }  
                        
                        list<ContentVersion> CV = new list<ContentVersion>();
                        list<ContentDocumentLink> CDLink = new list<ContentDocumentLink>();
                        Set<String> contentDocumentIds = new Set<String>();
                        integer count = 1 ;
                        for(Object mapa:data ){
                            
                            Map<String,Object> tempMap = (Map<String,Object>)mapa;
                            map<string,object> attc = (Map<String,Object>)tempMap.get('Attachment');
                            
                            /**************************************************************************************************/                
                            if(attc!=null){
                                contUserInfo.ShipToNoSet.add((String)tempMap.get('Ship_To_Party'));
                                if(tempMap.get('Ship_To_Party')!=null && shipToNumber=='' && enteredNumberIsNotPresentInSF)
                                    shipToNumber=(String)tempMap.get('Ship_To_Party');
                                count++;
                                for(string att : attc.keyset()){
                                    Object value = attc.get('Content');
                                    
                                    /* convert base64 format into PDF and store it into files object**************/
                                    if(att == 'Content'){
                                        String yourFilesContent = (string)attc.get('Content');
                                        ContentVersion conVer = new ContentVersion();
                                        conVer.ContentLocation = 'S';                  
                                        conVer.PathOnClient = 'CertificateOfAnalysis.pdf';           
                                        conVer.Title = (string)attc.get('Name');                          // Display name of the files
                                        conVer.VersionData = EncodingUtil.base64Decode(yourFilesContent); // converting your binary string to Blog
                                        cv.add(conVer);
                                    }
                                }
                            }
                            
                            /******************************If any error msg may occur than need to create case**************************/            
                            else if((tempMap.get('Error_Msg')!=null && tempMap.get('Error_Msg')!='')||(test.isRunningTest())){
                                system.debug('errorMessage-->'+tempMap.get('Error_Msg'));
                                if(count>1)
                                    contUserInfo.errorInfo = 'An unexpected error occurred. The technical team has been notified.';
                                else if(typeOfNumberEntered!=null)
                                {
                                  contUserInfo.errorInfo ='No certificates were found for the given '+typeOfNumberEntered+'!'; 
                                }
                            }
                            
                            
                        }
                      
                        
                        if(cv.size()>0){
                            contentTileMap = new Map<String, List<ContentVersion>>();
                            if(shipToNumber!=null && shipToNumber!=''){
                                tile.ShipToParty__c=shipToNumber;
                            }
                            contentTileMap.put(tile.Name, cv);
                            contUserInfo.contentTileMap = contentTileMap;
                            
                            if(shipToNumber != null && shipToNumber != ''){
                                contUserInfo.ShipToNo = shipToNumber;   
                            }
                        }    
                    }
                    else{ 
                        system.debug('Sending failed due to an error !');
                        system.debug('body details if fails'+response.getBody());
                    }
                }
            } 
            else{
                system.debug('integration failed');

                String errorMessage = 'Status-'+response.getStatus()+':StatusCode-'+response.getStatusCode();
                DebugLog__c logDebugForError = logErrorToCustomDebugLogIfErrorOccurred('INTEGRATION_ERROR',errorMessage,'Error',str,null,null,'callSAPCOAService');
                contUserInfo.logCustomDebugLog.add(logDebugForError);
                contUserInfo.errorInfo ='An unexpected error occurred. The technical team has been notified.';
            }
        }
        catch(exception excp){
            system.debug(' Line Number '+excp.getLineNumber() + 'Error message'+excp.getMessage());

            String  errorMessage = ' Line Number '+excp.getLineNumber() + ' Error message'+excp.getMessage()+' Stack Trace:'+excp.getStackTraceString();
            DebugLog__c logDebugForError = logErrorToCustomDebugLogIfErrorOccurred('INTERNAL_ERROR',errorMessage,'Fatal',str,null,excp.getStackTraceString(),'callSAPCOAService');
            contUserInfo.logCustomDebugLog.add(logDebugForError);
            contUserInfo.errorInfo ='An unexpected error occurred. The technical team has been notified.';
        }
        return contUserInfo;
    }
    private static DebugLog__c logErrorToCustomDebugLogIfErrorOccurred(String status,String errorMessage,String severity, String requestBody, String responseBody,String stackTrace,String opertationType){
        
             DebugLog__c logDebugForError = new DebugLog__c();
             logDebugForError.Object__c = 'Tile__c';
             logDebugForError.Errored_Process_Type__c = 'Integration - Outbound';
             logDebugForError.Errored_Process_Name__c = 'COARequestClass';
             logDebugForError.Record__c = requestBody!=null ? requestBody.left(32768) : null;
             logDebugForError.Response__c = responseBody!=null ? responseBody.left(32768) : null;
             logDebugForError.Operation_Name__c = opertationType;
             logDebugForError.Severity__c = severity;
             logDebugForError.Message__c = errorMessage!=null ? errorMessage.left(255) : null ;
             logDebugForError.TypeName__c = status;
             logDebugForError.StackTraceString__c  = stackTrace !=null ? stackTrace.left(32678) : null;

             return logDebugForError;
    }
    
    public class contentUserInfo{
        
        public Map<String, Tile__c> tilesToInsert{get;set;}
        public Map<String, List<ContentVersion>> contentTileMap{get;set;}
        public String ShipToNo{get;set;}
        public Set<String> ShipToNoSet{get;set;}
        public String errorInfo{get;set;}
        public List<DebugLog__c> logCustomDebugLog {get;set;}
        
        public contentUserInfo(){
            This.tilesToInsert = new Map<String, Tile__c>();
            This.contentTileMap = new Map<String, List<ContentVersion>>();
            This.ShipToNo ='';
            This.ShipToNoSet = new Set<String>();
            This.errorInfo = errorInfo;
            This.logCustomDebugLog = new List<DebugLog__c>();
        }
    }
    
    public class passingData{
        public string Delivery{get; set;}
        public string Delivery_Item_No{get; set;}
        public string Split_Del_Item_Number{get; set;}
        public string Sales_Org{get; set;}
        public string Distribution_Channel{get; set;}
        public string Ship_To_Party{get; set;}
        public string Delivery_Date{get; set;}
        public string Posting_Date_Doc{get; set;}
        public string Material_No{get; set;}
        public string Ship_Point{get; set;}
        public string Mother_Batch_No{get; set;}
        public string Child_Batch_No{get; set;}
        public string Referenced_Doc_No{get; set;}
        public string Originating_Doc{get; set;}
        public string Purchase_Order{get; set;}
        public string Purchase_Order_Item{get; set;}
        public string Sales_Order{get; set;}
        public string Sales_Order_Item{get; set;}
        public string Creation_Date{get; set;}
        public string Creation_Time{get; set;}
        
        public passingData(String delNo,String motherBatchNumber,String childBatchNumber, String shipToNumber){    
            
            This.Delivery = delNo;
            This.Delivery_Item_No = '';   
            This.Split_Del_Item_Number ='';
            This.Sales_Org='';                            
            This.Distribution_Channel='';
            This.Ship_To_Party = shipToNumber;
            This.Delivery_Date='';
            This.Posting_Date_Doc ='';
            This.Material_No ='';  
            This.Ship_Point ='';
            This.Mother_Batch_No = motherBatchNumber ;
            This.Child_Batch_No = childBatchNumber;
            This.Referenced_Doc_No  ='';
            This.Originating_Doc='';
            This.Purchase_Order='';
            This.Purchase_Order_Item='';
            This.Sales_Order='';
            This.Sales_Order_Item=''; 
            This.Creation_Date='';
            This.Creation_Time=''; 
        }      
    }
    public class wrapperforRecords{
        public List<passingData> Record;
    }
}