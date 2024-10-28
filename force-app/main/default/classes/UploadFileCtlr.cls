/*
Created by Krishna on 11/02/2021.

*/
public without sharing class  UploadFileCtlr {
    
    // separateCommas method will split the values based on commas in file
    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');
        
        for(String result : results) {
            result = result.trim();
        }
        
        return results;
    }
    
    // getCSVObject method will mach the values for related objects(QLG and QL) for Quote  
    @AuraEnabled
    public static String getCSVObject(String csv_str,String quoteId,string fname) {
        
        
        Integer count = 0;
        String result = 'Succesfully uploaded';
        system.debug(csv_str);
        Boolean isSalesAreaLeadingZero = false;
        Boolean isPartnerRoleLeadingZero = false;
        Boolean isAccountLeadingZero = false;
        Boolean isProductLeadingZero = false;
        Set<String> sapNumbers = new Set<String>();     
        Set<String> partnerRoles = new Set<String>();   
        Set<String> Users = new Set<String>();          
        Set<String> salesAreas = new Set<String>();     
        Set<String> productCodes = new Set<String>();   
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
        Map<String, List<SBQQ__QuoteLine__c>> groupWithQuoteLineItems = new Map<String,  List<SBQQ__QuoteLine__c>>();
        
        List<String> lines_raw = csv_str.split('\n');       
        List<String> headers_raw = separateCommas(lines_raw[0]);
        List<List<String>> lines = new List<List<String>>();
        List<CSVHeader> headers = new List<CSVHeader>();
        
        lines_raw.remove(0);    
        Boolean flag = true;
         system.debug('lines_raw'+lines_raw);
        //Handling fields with commas
        for(String line: lines_raw){
            
            List<String> line_sep = separateCommas(line);
            system.debug('line_sep'+line_sep);
            if(string.isNotBlank(line_sep[1])){
                sapNumbers.add('%'+line_sep[1]+'%');
            }
            if(string.isNotBlank(line_sep[2])){
                partnerRoles.add('%'+line_sep[2]+'%');
            } if(string.isNotBlank(line_sep[3])){
                salesAreas.add('%'+line_sep[3]+'%');
            }
            if(string.isNotBlank(line_sep[4])){
                partnerRoles.add('%'+line_sep[4]+'%');
            }
            
            if(string.isNotBlank(line_sep[5])){
                Users.add('%'+line_sep[5]+'%'); 
            }
            if(string.isNotBlank(line_sep[14])){
                productCodes.add('%'+line_sep[14]+'%');
            }
            
            
            if(flag){                
                isAccountLeadingZero = line_sep[1].indexOfIgnoreCase('0') == 0 ? true : false;
                isPartnerRoleLeadingZero = line_sep[2].indexOfIgnoreCase('0') == 0 ? true : false;
                isSalesAreaLeadingZero = line_sep[3].indexOfIgnoreCase('0') == 0 ? true : false;
                isProductLeadingZero = line_sep[15].indexOfIgnoreCase('0') == 0 ? true : false;
                flag = false;
            }
        }
        Map<String,String> productCodesWithId = getProducts(productCodes, isProductLeadingZero); 
        Map<String,String> customerNumWithSalesId = getSalesAreas(salesAreas, isSalesAreaLeadingZero);
        Map<String,String> sapNumWithAccId = getAccounts(sapNumbers,isAccountLeadingZero);
        Map<String,String> sapNumWithPartnerRoleId = getPartnerRoles(partnerRoles, isPartnerRoleLeadingZero);
        Map<String,String> emailWithUserId = getUsers(Users);
        Set<String> setName = new Set<String>();
        for(String line : lines_raw) {                                    
            List<String> line_sep = separateCommas(line);
            system.debug('line_sep>>>>'+line_sep.size());
            if(line_sep.size() >= 20 ){
                if(line_sep[0] != null && !setName.contains(line_sep[0])){
                    SBQQ__QuoteLineGroup__c quoteLineGroup = new SBQQ__QuoteLineGroup__c(); 
                    quoteLineGroup.Name = line_sep[0]; 
                    setName.add(quoteLineGroup.Name);
                    quoteLineGroup.SBQQ__Quote__c= quoteId;
                    quoteLineGroup.SBQQ__Account__c = sapNumWithAccId.get(line_sep[1]);
                    quoteLineGroup.ship_To_Role__c   = sapNumWithPartnerRoleId.get(line_sep[2]);                
                    quoteLineGroup.Sales_Area__c     = customerNumWithSalesId.get(line_sep[3]);
                    //quoteLineGroup.Agent_Role__c   = sapNumWithPartnerRoleId.get(line_sep[4]);                
                   
                    Boolean overwriteCMO = Boolean.valueOf(line_sep[6].trim());
                    if(overwriteCMO == true){
                         quoteLineGroup.CMO__c   = emailWithUserId.get(line_sep[5]);
                    }
                    quoteLineGroup.Overwrite_CMO__c = overwriteCMO ? true : false;
                    system.debug(quoteLineGroup.Overwrite_CMO__c);
                    quoteLineGroup.Mode_of_Transport__c  = line_sep[7];
                    quoteLineGroup.IncoTerms__c  = line_sep[8];
                    quoteLineGroup.From_Country__c   = line_sep[9];
                    quoteLineGroup.To_Country__c     = line_sep[10];                
                    quoteLineGroup.Delivery_Moments_Per_Ship_To__c   = line_sep[11] != null ? Decimal.valueOf(line_sep[11]) : null;
                    
                    Boolean reefer = Boolean.valueOf(line_sep[12].trim());
                    
                    quoteLineGroup.Reefer__c = reefer ? true : false;
                    
                    Boolean singleShipment = Boolean.valueOf(line_sep[13].trim());
                    quoteLineGroup.Single_Shipment__c = singleShipment ? true : false;
                    
                    quoteLineGroups.add(quoteLineGroup);
                }
                
                SBQQ__QuoteLine__c quoteline = new SBQQ__QuoteLine__c();
            
                count++;
                quoteline.SBQQ__Quote__c = quoteId;
                quoteline.SBQQ__Product__c = productCodesWithId.get(line_sep[14]);
                quoteline.SBQQ__Quantity__c = line_sep[15] != null ? Decimal.valueOf(line_sep[15]) : null;
                quoteline.PR_Offered_Customer_Price_Unit__c = line_sep[16] != null ? Decimal.valueOf(line_sep[16]) : null;
                quoteline.Unit_of_measure__c = line_sep[17];
                Boolean overrideFright = Boolean.valueOf(line_sep[19].trim());
                if(overrideFright == true){
                       quoteline.Freight_per_UoM__c = line_sep[18] != null ? Decimal.valueOf(line_sep[18].trim()) : null;
                }
                quoteline.Override_Freight__c = overrideFright ? true : false;
                //quoteline.SBQQ__Number__c=count;
                //integer QNumber = integer.valueOf(line_sep[20].trim());
               // quoteline.SBQQ__Number__c=QNumber;
                //system.debug( quoteline.SBQQ__Number__c);
                if(groupWithQuoteLineItems.get(line_sep[0]) == null){
                    groupWithQuoteLineItems.put(line_sep[0], new List<SBQQ__QuoteLine__c>());   
                }               
                groupWithQuoteLineItems.get(line_sep[0]).add(quoteline);
            }
        }
        if(quoteLineGroups.size() > 0){ 
            try{
                
                Database.SaveResult[] srQLGList = Database.insert(quoteLineGroups, false);
                
                // Iterate through each returned result
                for (Database.SaveResult srQLG : srQLGList) {
                    if (srQLG.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        result='File uploaded Successfully';
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : srQLG.getErrors()) {
                            result = 'QLG file has wrong data so not able to upload';
                            
                        }
                    }
                }
                
                
                for(SBQQ__QuoteLineGroup__c quoteGroup: quoteLineGroups){
                    if(groupWithQuoteLineItems.containsKey(quoteGroup.Name)){
                        for(SBQQ__QuoteLine__c quoteLine: groupWithQuoteLineItems.get(quoteGroup.Name)){
                            quoteLine.SBQQ__Group__c = quoteGroup.Id;
                        }
                    }
                }
                if(groupWithQuoteLineItems.size() > 0){
                    list<SBQQ__QuoteLine__c> quotelineItems = new list<SBQQ__QuoteLine__c>();
                    for(string str : groupWithQuoteLineItems.keyset()){
                        quotelineItems.addAll(groupWithQuoteLineItems.get(str));
                    }
                    if(quotelineItems.size()>0){
                        Database.SaveResult[] srList = Database.insert(quotelineItems, false);
                        
                        // Iterate through each returned result
                        for (Database.SaveResult sr : srList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                result=' File uploaded Successfully ';
                               
                            }
                            else {
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    result = 'QuoteLineItems file has wrong data so not able to upload';
                                }
                            }
                        }
                    }
                }
                 saveFile(quoteId,csv_str,fname);
            } catch(Exception e){
                
                result = 'Cause: '+e.getCause()+' \n stack trace: '+e.getStackTraceString()+'\n message: '+e.getMessage();
            }
        }        
        
        return result;
    }
    
    // get product by Query dynamic    
    public static Map<String,String> getProducts(Set<String> productCodes, Boolean isLeadingZero){
        
        id recTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Product SKU').getRecordTypeId();
        Map<String,String> productCodesWithId = new Map<String, String>();    
        for(Product2 prod : [SELECT Id, Name, Product_Code_SAP__c,recordtype.id FROM Product2 WHERE Product_Code_SAP__c  Like : productCodes And recordtype.Id =: recTypeId]){                        
            if(isLeadingZero){
                productCodesWithId.Put(prod.Product_Code_SAP__c, prod.Id);
            } else {
                productCodesWithId.Put(removeLeadingzeros(prod.Product_Code_SAP__c), prod.Id);
            }   
        }
        
        return productCodesWithId;
    }        
    
    //get Sales Area by Query dynamic 
    public static Map<String,String> getSalesAreas(Set<String> salesAreas, Boolean isLeadingZero ){
        Map<String,String> customerNumWithSalesId = new Map<String, String>();
        if(salesAreas.size() > 0){            
            for(Sales_Area__c salesArea : [SELECT Id, Name, External_Key__c FROM Sales_Area__c WHERE External_Key__c Like : salesAreas]){
                if(isLeadingZero){
                    customerNumWithSalesId.put(salesArea.External_Key__c, salesArea.Id);    
                } else {
                    customerNumWithSalesId.put(removeLeadingzeros(salesArea.External_Key__c), salesArea.Id);
                }            
            }
        }    
        return customerNumWithSalesId;
    }
    
    //get Accounts by Query dynamic 
    public static Map<String,String> getAccounts(Set<String> accSapNumbers, Boolean isLeadingZero){
        Map<String,String> sapNumWithAccId = new Map<String, String>();
        for(Account acc : [SELECT Id, Name, SAP_Number_PE1__c FROM Account WHERE SAP_Number_PE1__c Like : accSapNumbers]){            
            if(isLeadingZero){
                sapNumWithAccId.put(acc.SAP_Number_PE1__c, acc.Id);
            } else {
                sapNumWithAccId.put(removeLeadingzeros(acc.SAP_Number_PE1__c), acc.Id);
            }                        
        }
        return sapNumWithAccId;
    }
    
    // get Partner Roles by Query dynamic
    public static Map<String,String> getPartnerRoles(Set<String> partnerRoleNumbers, Boolean isLeadingZero){
        Map<String,String> sapNumWithpartnerRoleId = new Map<String, String>();
        for(Partner_Role__c partnerRole: [SELECT Id, Name, External_Key__c FROM Partner_Role__c WHERE External_Key__c Like : partnerRoleNumbers ]){            
            if(isLeadingZero){
                sapNumWithpartnerRoleId.put(partnerRole.External_Key__c, partnerRole.Id);
            } else {
                sapNumWithpartnerRoleId.put(removeLeadingzeros(partnerRole.External_Key__c), partnerRole.Id);
            }   
        }
        return sapNumWithpartnerRoleId;
    }
    
    //get Users by Dynamic Query
    public static Map<String,String> getUsers(Set<String> userEmails){
        Map<String,String> emailWithUserId = new Map<String, String>();
        for(User usr: [SELECT Id, Name, Email FROM User WHERE Email Like : userEmails]){
            emailWithUserId.put(usr.Email, usr.Id);
        }
        return emailWithUserId;
    }
    
    // Removing zoros from the file
    public static String removeLeadingzeros(String str){
        if(!String.isBlank(str)){
            String strPattern = '^0+(?!$)';
            str = str.replaceAll(strPattern,'');
            return str;
        } else {
            return null;            
        }       
    }
    
    public static void saveFile(String parentId,  String base64Data, string filename){
        blob csvfile = blob.valueOf(base64Data);
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = filename+'.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = filename; // Display name of the files
        conVer.VersionData = csvfile; // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion
        
        
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = parentId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;       
      
    }
}