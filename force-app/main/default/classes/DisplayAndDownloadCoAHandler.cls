/*
@Author     : Rohit Kumar
@CreatedDate: 15/07/2020
@UsedBy     : DisplayAndDownloadCoA (Lightning Component)
@Description: This Class Fetch Certificate Of Analysis Either From Tile Object if already exist otherwise it will 
              Call Rest Callout Class(COARequestClass). 

@History
  20-07-2020  Rohit Kumar : Created
  02-08-2021  Rohit Kumar : Update Class to include logic for retrival and visibility condition for Community user of CoA based on Batch Number.
  13-09-2021  Rohit Kumar : Remove the retrival of CoA from saleforce (if for particular number any CoA present in SF), becasue
							user are not able to fetch new CoA entries becasue of Cahing Mechnaism.
  21-09-2021  Rohit Kumar : Hide the retrival of CoA based on Child Batch Number.
*/



public  without sharing class   DisplayAndDownloadCoAHandler {
    
     
    
   

	/* @Description
        Method Name : IsCommunityUserCheck( )

		On Load Of DisplayAndDownload Lightning Component, this method is called and check
		type of Current logged in user. Mainly it will check Comunity User Role for community
		user.
	*/    
    @AuraEnabled
    public static String IsCommunityUserCheck(){
        id userId = userinfo.getUserId();
       
        User currentUser = [SELECT id,ContactId,Profile.UserLicense.Name,Community_User_Role__c FROM user WHERE id=:userId];
       
        if(currentUser.contactId!=null && currentUser.Profile.UserLicense.Name == 'Customer Community Plus' && (String.isBlank(currentUser.Community_User_Role__c) || currentUser.Community_User_Role__c.equals('Standard User'))){
            return 'CUSTOMER_STANDARD';
        }
        else if(currentUser.contactId!=null && currentUser.Profile.UserLicense.Name == 'Customer Community Plus' && currentUser.Community_User_Role__c.equals('Manager User')){
            return 'CUSTOMER_MANAGER';
        }
        else if(currentUser.contactId!=null && currentUser.Profile.UserLicense.Name == 'Partner Community' && (String.isBlank(currentUser.Community_User_Role__c) || currentUser.Community_User_Role__c.equals('Standard User'))){
            return 'DISTRIBUTOR_STANDARD';
        }
        else if(currentUser.contactId!=null && currentUser.Profile.UserLicense.Name == 'Partner Community' && currentUser.Community_User_Role__c.equals('Manager User')){
            return 'DISTRIBUTOR_MANAGER';
        }
        
        return 'INTERNAL_USER';
    }
        
    /* @Description
        Method Name : getRecordTypeAndCurrentUserDetails( )

		This method will  autopopulate few fields of case  for Missing COA case creation
	*/  
    @AuraEnabled
    public static PrePopulateCaseFieldsForMissingCoA getRecordTypeAndCurrentUserDetails(){
        
        Id userId = userinfo.getUserId();
        String missingCoARecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Missing_COA').getRecordTypeId();
        
        User communityUser = [SELECT id,ContactId,Contact.AccountId,Contact.Parent_Account__c FROM user WHERE id=:userId]; // Fetching current community user details and its parent contact record for creating missing coa case
        
        return new PrePopulateCaseFieldsForMissingCoA(communityUser.Contact.Parent_Account__c,communityUser.Contact.AccountId,communityUser.ContactId,userId,missingCoARecordTypeId);
        
    }
    
    
     /* @Description
        Method Name : getRecordTypeAndCurrentUserDetails( )

		1. This mehtod will receive input number entred by user through UI(DisplayAndDownloadCoA Lightning Component).
		2. Check that entered number is present in salesforce, if not then show appropriate error
		  (exception condition applies to batch and Delivery Number if entered number not found in SF)
		3. Validate that current logged in user has access to entered Number only for community user,
		   if not then show appropriate error.
		4. If entered number is correct then it call CoARequestClass and fetch and display to the user.

		@PARAMS
			1.tile : (Type - Tile__c(Sobject)) input from UI(Lightning Component) map to tile object different fields
			  depend on type of number entered.
			2.baseURLSFDC : (Type - String (URL)) base URL of salesforce for Downloading of CoA.
			3.typeOfNumberSelected : (Type - String) use to identified which type of Number selected by user on the UI.
			4.isUserUsedSearchFunctionality : (Type) use to identified that user use search functionlity(Lookup on COA UI).
      	  
	*/  
    @AuraEnabled
    public static AllDetailsRelatedToCoAs validateAndFetchCertificateofAnalysis(Tile__c tile, String baseURLSFDC,String typeOfNumberSelected,boolean isUserUsedSearchFunctionality){
        
        Id coARecordTypeId = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        AllDetailsRelatedToCoAs details = new AllDetailsRelatedToCoAs();
        Boolean isCommunity =  false;     
        Boolean validate = false;
        Boolean enteredNumberIsNotPresentInSF = false;
        String communityUserrole='';
        details.errorsInfo='';

        String commercialCustomer='';
        String customerLocation='';
        List<String> additionalCountry = new List<String>();
        

        User communityUser = [SELECT id,Contact.AccountId,Contact.Additional_Country_Responsibility__c,
                              Contact.Parent_Account__c,ContactId,Community_User_Role__c FROM user WHERE id=:userinfo.getUserId()]; 

        
        if(communityUser.ContactId!=null){
            
                isCommunity = true;  
                commercialCustomer = communityUser.Contact.Parent_Account__c;
                customerLocation = communityUser.Contact.AccountId;
            
            if(String.isBlank(communityUser.Community_User_Role__c)){
                communityUserrole ='Standard User';
              }  
            else {
                communityUserrole =communityUser.Community_User_Role__c;
                }
        }
        
        if(tile.Delivery_Number__c!=null && tile.Delivery_Number__c!='' && typeOfNumberSelected.equals('Delivery Number')){

            List<Delivery__c> deliveryList =  new List<Delivery__c>();

                if(isUserUsedSearchFunctionality){
                    validate = true;
                }else{
                    deliveryList = [SELECT id,Sold_To__c,Sold_To__r.ParentId,SAP_Delivery_Number__c,Sold_To__r.BillingCountry FROM Delivery__c WHERE SAP_Delivery_Number__c=:tile.Delivery_Number__c];
                     
                      if(!deliveryList.isEmpty() && isCommunity){
                        validate = DisplayAndDownloadCoAHelper.checkEnteredNumberBelongToCurrentUser(communityUser,deliveryList.get(0).Sold_To__c,
                                                              deliveryList.get(0).Sold_To__r.ParentId, deliveryList.get(0).Sold_To__r.BillingCountry);
                      }else if(!deliveryList.isEmpty() && !isCommunity){
                        validate = true;
                      }
                }
                if(deliveryList.isEmpty()   && tile.Delivery_Number__c.isNumeric())
                {
                    details.errorsInfo = '';
                    validate=true;
                    enteredNumberIsNotPresentInSF = true;
                }
                if(validate){
                    tile.RecordTypeId = coARecordTypeId;
                    details = userEnteredDeliveryNumber(tile,baseURLSFDC,enteredNumberIsNotPresentInSF,isCommunity,communityUser,
                                                        typeOfNumberSelected,isUserUsedSearchFunctionality);
                }else if(!validate && !isUserUsedSearchFunctionality){
                    details.errorsInfo = 'This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.';
                }
                                                                             

                return details;
        }
        else if(tile.Sales_Order_Number__c!=null && tile.Sales_Order_Number__c!='' && typeOfNumberSelected.equals('Sales Order Number')){

                if(isUserUsedSearchFunctionality){
                    validate = true;
                }else{
                       List<Order> orderList = [SELECT id,Parent_Account__c,Account.BillingCountry,AccountId,SAP_Sales_Order_Number__c,
                                                PoNumber FROM order WHERE SAP_Sales_Order_Number__c=:tile.Sales_Order_Number__c]; 
                     
                        if(!orderList.isEmpty() && isCommunity){
                            validate = DisplayAndDownloadCoAHelper.checkEnteredNumberBelongToCurrentUser(communityUser,orderList.get(0).AccountId,
                                                                    orderList.get(0).Parent_Account__c, orderList.get(0).Account.BillingCountry);
                        }else if(!orderList.isEmpty() && !isCommunity){
                             validate = true;
                        }       
                } 
                if(validate){
                    tile.RecordTypeId = coARecordTypeId;
                    details = userEnteredSalesOrderNumber(tile,baseURLSFDC,isCommunity,typeOfNumberSelected);
                }else if(!validate && !isUserUsedSearchFunctionality){
                    details.errorsInfo ='This Sales Order Number is either incorrect or does not exist.'+
                                        ' Please verify and try again.\n If this error persists, please retry with the Delivery Number.';
                }

                return details;
        }
        else if(tile.Purchase_Order_Number__c!=null && tile.Purchase_Order_Number__c!='' && typeOfNumberSelected.equals('Purchase Order Number')){

                if(isUserUsedSearchFunctionality){
                    validate = true;
                }else{
                        List<Order> orderList = [SELECT id,Parent_Account__c,Account.BillingCountry,AccountId,SAP_Sales_Order_Number__c,
                                                PoNumber FROM order WHERE PoNumber=:tile.Purchase_Order_Number__c LIMIT 1]; 
                      
                        if(!orderList.isEmpty() && isCommunity){
                            validate = DisplayAndDownloadCoAHelper.checkEnteredNumberBelongToCurrentUser(communityUser,orderList.get(0).AccountId,
                                                                         orderList.get(0).Parent_Account__c, orderList.get(0).Account.BillingCountry);
                        }else if(!orderList.isEmpty() && !isCommunity){
                             validate = true;
                        }         
                } 
                if(validate){
                    tile.RecordTypeId = coARecordTypeId;
                    details = userEnteredPurchaseOrderNumber(tile,baseURLSFDC,isCommunity,typeOfNumberSelected);
                }else if(!validate && !isUserUsedSearchFunctionality){
                    details.errorsInfo ='This Purchase Order Number is either incorrect or does not exist.'+
                                        ' Please verify and try again.\n If this error persists, please retry with the Delivery Number.';
                }
            return details;
        }
        else if(tile.Batch_Number__c!=null && tile.Batch_Number__c!='' && typeOfNumberSelected.contains('Batch')){
 
            List<Delivery_Line_Item__c> batchList = new List<Delivery_Line_Item__c>();
            Set<String> shipToNumberList = new Set<String>();
             
            batchList = DisplayAndDownloadCoAHelper.getBatchNumberAndItsRelatedShipToList(typeOfNumberSelected,tile.Batch_Number__c);

                if(isUserUsedSearchFunctionality || (!batchList.isEmpty() && !isCommunity)){
                    shipToNumberList = DisplayAndDownloadCoAHelper.shipToRelatedToEnteredBatch(batchList,communityUser);
                    validate =  true;
                }else if(!batchList.isEmpty() && isCommunity){
                    shipToNumberList = DisplayAndDownloadCoAHelper.shipToRelatedToEnteredBatch(batchList,communityUser);
                    validate =  shipToNumberList.isEmpty() ? false : true;
                }

                if(!validate && isCommunity && communityUserrole.equals('Standard User'))
                {
                   enteredNumberIsNotPresentInSF = true;
                   for(Partner_Role__c partner :[SELECT Target_Account_Number__c FROM Partner_Role__c WHERE 
                                                Source_Account__c =:customerLocation  AND 
                                                Relation_Name__c=:'Ship To']){
                    shipToNumberList.add(partner.Target_Account_Number__c );
                   }
                   validate = shipToNumberList.isEmpty() ? false : true;
                }else if(!validate &&  !isCommunity && tile.ShipToParty__c != null && tile.ShipToParty__c != ''){
                    enteredNumberIsNotPresentInSF = true;
                    validate = true;
                    shipToNumberList.add(tile.ShipToParty__c );
                }
                
                if(validate){
                    tile.RecordTypeId = coARecordTypeId;
                    details = userEnterBatchNumber(tile,baseURLSFDC,communityUser,typeOfNumberSelected,
                              enteredNumberIsNotPresentInSF,shipToNumberList);
                }
                else if(!validate && isCommunity){
                    
                    details.errorsInfo ='Entered Batch Details not Found';
                    
                }else if(!validate && !isCommunity && (tile.ShipToParty__c == null || tile.ShipToParty__c == '')){
                    details.errorsInfo ='Entered Batch Details not Found in SF, please enter ship to number also if you think'+
                                        ' Entered batch number is correct and has CoA' ;
                }
                
                return details;
        }

        return details;
    }
    
    /* @Description
        Method Name : userEnteredDeliveryNumber( )

		1. Called when user entered Delivery Number and entered number is valid or belongs to current logged in user.
		2. Check if CoA already present in SF for enterd number then retrive it from tile don't initiate webservice call.
		3. If CoA not in SF then call CoA webservice to reterive CoA from SAP.

    */
    public static AllDetailsRelatedToCoAs userEnteredDeliveryNumber(Tile__c tile, String baseURLSFDC,Boolean enteredNumberIsNotPresentInSF, 
                                                                    Boolean isCommunity, User communityUser,String typeOfNumber,
                                                                    Boolean isUserUsedSearchFunctionality)
    {
        
       /* List<Tile__c> deliveryPresentInTile = [SELECT id,ShipToParty__c,Name,Delivery_Number__c,RecordTypeId FROM Tile__c WHERE 
                                               RecordTypeId=:tile.RecordTypeId AND Delivery_Number__c=:tile.Delivery_Number__c LIMIT 1];*/
        AllDetailsRelatedToCoAs details = new AllDetailsRelatedToCoAs();
        
        
       /* if(!deliveryPresentInTile.isEmpty()){
            
            Set<FileData> fetchFiles = new Set<FileData>();
            Boolean showCoA = false;
            
            system.debug('tiles already in SF:'+deliveryPresentInTile.size());

            if(!isCommunity || (isCommunity && !enteredNumberIsNotPresentInSF) || isUserUsedSearchFunctionality){
                showCoA=true;
            }
            else if(enteredNumberIsNotPresentInSF && isCommunity && communityUser!=null){
                showCoA = DisplayAndDownloadCoAHelper.checkCoAVisiblityForDeliveryNotPresentInSF(deliveryPresentInTile[0].ShipToParty__c,communityUser);
            }
            
            if(showCoA){
                Set<Id> deliveryTilesId = new Set<Id>();
                deliveryTilesId.add(deliveryPresentInTile[0].id);
                fetchFiles =fetchAlreadyExistFilesInSFDCFromTile(deliveryTilesId,baseURLSFDC);
            }
            else if(isCommunity && enteredNumberIsNotPresentInSF && !showCoA){
                details.errorsInfo ='This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.';
            }
            if(showCoA && fetchFiles.size()>0){
                details.fileRecord=fetchFiles;
            }
            return details;
        }else{*/
            Set<Tile__c>  createTilesRecords = new Set<Tile__c>();
            if(enteredNumberIsNotPresentInSF){
                tile.Name = 'DELIVERY:'+tile.Delivery_Number__c;
                createTilesRecords.add(tile);
                details = callCoAWebservice(createTilesRecords,baseURLSFDC,communityUser,isCommunity,enteredNumberIsNotPresentInSF,typeOfNumber,0);
            }
            else {
                tile.Name = 'DELIVERY:'+tile.Delivery_Number__c;
                for(Delivery_Line_Item__c  deliveryLineItem : [SELECT id,Delivery__r.SAP_Delivery_Number__c,
                                                               Sales_Order_number__r.SAP_Sales_Order_Number__c,
                                                               Sales_Order_number__r.PoNumber FROM Delivery_Line_Item__c 
                                                               WHERE Delivery__r.SAP_Delivery_Number__c =: tile.Delivery_Number__c LIMIT 1])
                {
                    tile.Sales_Order_Number__c = deliveryLineItem.Sales_Order_number__r.SAP_Sales_Order_Number__c;
                    tile.Purchase_Order_Number__c = deliveryLineItem.Sales_Order_number__r.PoNumber;
                }  
                createTilesRecords.add(tile);
                details = callCoAWebservice(createTilesRecords,baseURLSFDC,communityUser,isCommunity,enteredNumberIsNotPresentInSF,typeOfNumber,0);
            }
            return details;
       // }
    }
    
    /* @Description
        Method Name : userEnteredSalesOrderNumber( )

		1. Called when user entered Sales Order Number and entered number is valid or belongs to current logged in user.
		2. Check if CoA already present in SF for related Delivery Number then retrive it from tile and only
		   initiate webservice call for that delivery whose CoA not present in SF, if all Delivery CoA is already in
		   In SF then don't initiate webservice call.
    */
    public static AllDetailsRelatedToCoAs userEnteredSalesOrderNumber(Tile__c tile, String baseURLSFDC, Boolean isCommunity,String typeOfNumber){
        
        AllDetailsRelatedToCoAs details = new AllDetailsRelatedToCoAs();
        Set<FileData> fetchFiles = new Set<FileData>();
        Set<String> orderRelatedDelivery =  new Set<String>();
        Set<String> deliveryPresentInTile =  new Set<String>();  //If CoA already present in salesforce
        Set<Tile__c> createTilesRecords = new Set<Tile__c>();    //If CoA is not present in salesforce, then  fetch from SAP, and create tile record and attach CoA with that
        Set<Id> alreadyPresentDeliveryTilesId =  new Set<Id>();
        
        
        for(Delivery_Line_Item__c deliveryLineItem: [SELECT id,Delivery__r.SAP_Delivery_Number__c,Sales_Order_number__r.SAP_Sales_Order_Number__c,
                                                     Sales_Order_number__r.PoNumber FROM Delivery_Line_Item__c WHERE 
                                                     Sales_Order_number__r.SAP_Sales_Order_Number__c =: tile.Sales_Order_Number__c]){
            if(deliveryLineItem.Delivery__r.SAP_Delivery_Number__c!=null)
               orderRelatedDelivery.add(deliveryLineItem.Delivery__r.SAP_Delivery_Number__c);
            if(tile.Purchase_Order_Number__c == null || tile.Purchase_Order_Number__c == '')
               tile.Purchase_Order_Number__c = deliveryLineItem.Sales_Order_number__r.PoNumber ;   
        }
        
       /* for(Tile__c deliveryTile : [SELECT id,Name,Delivery_Number__c,Sales_Order_Number__c,RecordTypeId 
                                    FROM Tile__c WHERE RecordTypeId=:tile.RecordTypeId AND Delivery_Number__c IN:orderRelatedDelivery])
        {
            deliveryPresentInTile.add(deliveryTile.Delivery_Number__c);
            alreadyPresentDeliveryTilesId.add(deliveryTile.id);
        }*/
        
        for(String deliveryNumber:orderRelatedDelivery){
          //  if(!deliveryPresentInTile.contains(deliveryNumber)){
                
                Tile__c insertTile = new Tile__c();
                insertTile.Name = 'DELIVERY:'+deliveryNumber;
                insertTile.Delivery_Number__c = deliveryNumber;
                insertTile.Sales_Order_Number__c = tile.Sales_Order_Number__c;
                insertTile.Purchase_Order_Number__c = tile.Purchase_Order_Number__c;
                insertTile.RecordTypeId = tile.RecordTypeId;
                insertTile.Batch_Number__c = '';
                insertTile.ShipToParty__c = '';
                createTilesRecords.add(insertTile);
          //  }
        }   
        
       /* if(alreadyPresentDeliveryTilesId.size()>0){
            system.debug('tiles already in SF:'+alreadyPresentDeliveryTilesId.size());
            fetchFiles.addAll(fetchAlreadyExistFilesInSFDCFromTile(alreadyPresentDeliveryTilesId,baseURLSFDC));
        }*/
        if(createTilesRecords.size()>0){
            
            AllDetailsRelatedToCoAs fetchFromSAP = callCoAWebservice(createTilesRecords,baseURLSFDC,null,isCommunity,false,typeOfNumber,orderRelatedDelivery.size());
            details.errorsInfo = fetchFromSAP.errorsInfo;
            fetchFiles.addAll(fetchFromSAP.fileRecord);
        }
       if(fetchFiles.size()>0)
            details.fileRecord = fetchFiles;
        
        
        return details;
    }
    
    /* @Description
        Method Name : userEnteredPurchaseOrderNumber( )

		1. Called when user entered Purchase Order Number and entered number is valid or belongs to current logged in user.
		2. Check if CoA already present in SF for related Delivery Number then retrive it from tile and only
		   initiate webservice call for that delivery whose CoA not present in SF, if all Delivery CoA is already in
		   In SF then don't initiate webservice call.
    */
    public static AllDetailsRelatedToCoAs userEnteredPurchaseOrderNumber(Tile__c tile, String baseURLSFDC, Boolean isCommunity,String typeOfNumber){
        
        AllDetailsRelatedToCoAs details = new AllDetailsRelatedToCoAs();
        Set<FileData> fetchFiles = new Set<FileData>();
        Set<Tile__c> createTilesRecords = new Set<Tile__c>();    //If CoA is not present in salesforce, then  fetch from SAP, and create tile record and attach CoA with that
        Set<String> deliveryPresentInTile =  new Set<String>();  //If CoA already present in salesforce
        Map<String,String> orderRelatedDelivery =  new Map<String,String>();
        Set<Id> alreadyPresentDeliveryTilesId =  new Set<Id>();  //If CoA already present in salesforce. fetch related tile id and fetch All CoA associated with it
        
        for(Delivery_Line_Item__c deliveryLineItem: [SELECT id,Delivery__r.SAP_Delivery_Number__c,
                                                     Sales_Order_number__r.SAP_Sales_Order_Number__c,Sales_Order_number__r.PoNumber 
                                                     FROM Delivery_Line_Item__c WHERE Sales_Order_number__r.PoNumber =: tile.Purchase_Order_Number__c])
        {
            if(deliveryLineItem.Delivery__r.SAP_Delivery_Number__c!=null)
               orderRelatedDelivery.put(deliveryLineItem.Delivery__r.SAP_Delivery_Number__c,deliveryLineItem.Sales_Order_number__r.SAP_Sales_Order_Number__c);
        }
        
        
       /* for(Tile__c delivery : [SELECT id,Name,Delivery_Number__c,Purchase_Order_Number__c,RecordTypeId 
                                FROM Tile__c WHERE RecordTypeId=:tile.RecordTypeId AND Delivery_Number__c IN:orderRelatedDelivery.keySet()])
        {
            deliveryPresentInTile.add(delivery.Delivery_Number__c);
            alreadyPresentDeliveryTilesId.add(delivery.id);
        }*/
        
        if(!orderRelatedDelivery.isEmpty()){
        for(String deliveryNumber:orderRelatedDelivery.keySet()){
          //  if(!deliveryPresentInTile.contains(deliveryNumber)){
                
                Tile__c insertTile = new Tile__c();
                insertTile.Name = 'DELIVERY:'+deliveryNumber;
                insertTile.Delivery_Number__c = deliveryNumber;
                insertTile.Sales_Order_Number__c = orderRelatedDelivery.get(deliveryNumber);
                insertTile.Purchase_Order_Number__c = tile.Purchase_Order_Number__c;
                insertTile.RecordTypeId = tile.RecordTypeId;
                insertTile.Batch_Number__c = '';
                insertTile.ShipToParty__c = '';
                createTilesRecords.add(insertTile);
           // }
        }
        }
        
      /*  if(alreadyPresentDeliveryTilesId.size()>0){
            system.debug('tiles already in SF:'+alreadyPresentDeliveryTilesId.size());
            fetchFiles.addAll(fetchAlreadyExistFilesInSFDCFromTile(alreadyPresentDeliveryTilesId,baseURLSFDC));
        }*/
        if(createTilesRecords.size()>0){
            system.debug('delivery size-->'+createTilesRecords.size());
            AllDetailsRelatedToCoAs fetchFromSAP = callCoAWebservice(createTilesRecords,baseURLSFDC,null,isCommunity,false,typeOfNumber,orderRelatedDelivery.size());
            details.errorsInfo = fetchFromSAP.errorsInfo;
            fetchFiles.addAll(fetchFromSAP.fileRecord);
        }
        
      if(fetchFiles.size()>0)
            details.fileRecord = fetchFiles;
        
        
        return details;
    }
        
     /* @Description
        Method Name : userEnterBatchNumber( )

		1. Called when user entered Batch Number and entered number is valid or belongs to current logged in user.
	   */
    public static AllDetailsRelatedToCoAs userEnterBatchNumber(Tile__c tile,String baseURLSFDC, User currentUser,
                                          String typeOfNumber, Boolean enteredNumberIsNotPresentInSF,
                                          Set<String> shipToNumberList)
    {
        
        AllDetailsRelatedToCoAs details = new AllDetailsRelatedToCoAs();
        Set<Tile__c> tileList = new Set<Tile__c>();
        Set<FileData> fetchFiles = new Set<FileData>();
        Set<String> shipToNumberSet = new Set<String>();
        Set<String> batchShipToCombinationsInTile= new Set<String>();
        Set<Id> tileObjectIdList = new Set<id>();
        //String typeOfUser = IsCommunityUserCheck();
        Boolean IsCommunityUserCheck = false;
        
        IsCommunityUserCheck = currentUser.ContactId!=null ? true : false;

        if(!shipToNumberList.isEmpty()){
           /* for(Tile__c cOAInSF : [SELECT id,Name,Batch_Number__c,ShipToParty__c,RecordTypeId FROM Tile__C 
                                   WHERE ShipToParty__c IN:shipToNumberList AND Batch_Number__c=:tile.Batch_Number__c 
                                   AND RecordTypeId=:tile.RecordTypeId])
            {
                batchShipToCombinationsInTile.add(cOAInSF.Batch_Number__c + cOAInSF.ShipToParty__c);
                tileObjectIdList.add(cOAInSF.id);

            }*/
            for(String shipTo: shipToNumberList){
                 // if(!batchShipToCombinationsInTile.contains(tile.Batch_Number__c+shipTo)){
                    Tile__c newTile = new Tile__c();
                    newTile.Name = 'BATCH:'+tile.Batch_Number__c+shipTo;
                    newTile.RecordTypeId = tile.RecordTypeId;
                    newTile.Batch_Number__c = tile.Batch_Number__c;
                    newTile.ShipToParty__c = shipTo;
                    newTile.Delivery_Number__c = ''; 
                    tileList.add(newTile);
                 // }
            }
        }
       /* if(!tileObjectIdList.isEmpty()){
            system.debug('tiles already in SF:'+tileObjectIdList.size());
            fetchFiles.addAll(fetchAlreadyExistFilesInSFDCFromTile(tileObjectIdList,baseURLSFDC));
        }*/
        if(!tileList.isEmpty()){
            details = callCoAWebservice(tileList,baseURLSFDC,currentUser, false,false,typeOfNumber,0);
        }  
       
        /*if(fetchFiles.size()>0)
            details.fileRecord = fetchFiles;*/
        
        return details;
        
    }
    
    /* @Description
        Method Name : fetchAlreadyExistFilesInSFDCFromTile( )

		Fetch already existing CoA from Tile Object
	   */
   /* public static Set<FileData> fetchAlreadyExistFilesInSFDCFromTile(Set<Id>  alreadyPresentDeliveryTilesId, string baseURLSFDC){
        Set<Id> contentDocumentIds = new Set<Id>();
        Set<Id> tileId = new Set<Id>();
        Set<FileData> fetchFiles = new Set<FileData>();
        
        
        for(ContentDocumentLink link:[SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : alreadyPresentDeliveryTilesId]){
            contentDocumentIds.add(link.ContentDocumentId);
        } 
            for(ContentVersion version:[SELECT id,Title,ContentDocumentId,PathOnClient FROM ContentVersion WHERE ContentDocumentId IN:contentDocumentIds]){
                FileData fData = new FileData(
                    version.Title,
                    version.ContentDocumentId,
                    baseURLSFDC+'/sfc/servlet.shepherd/document/download/'+version.ContentDocumentId);
                fetchFiles.add(fData);
            }
        system.debug('coa already in SF-->'+fetchFiles.size());
        return fetchFiles;
    }*/
    
    /* @Description
        Method Name : callCoAWebservice( )

		call CoARequestClass and fetch CoA from SAP
	*/
    public static AllDetailsRelatedToCoAs callCoAWebservice(Set<Tile__c> createTilesRecords,String baseURLSFDC,User currentUser,
                                                            Boolean isCommunity,Boolean enteredNumberIsNotPresentInSF, 
                                                            String typeOfNumberEntered, Integer numberOfDelivery)
    {
        
        
        COARequestClass.contentUserInfo contentInfoInMaster = new COARequestClass.contentUserInfo();
        contentInfoInMaster.contentTileMap = new Map<String, List<ContentVersion>>();
        contentInfoInMaster.ShipToNoSet = new Set<String>();
        AllDetailsRelatedToCoAs details = new AllDetailsRelatedToCoAs();
        List<String> errorFromSAP = new List<String>();
       
        
        for(Tile__c tile : createTilesRecords){
            COARequestClass.contentUserInfo contentInfoTemp = COARequestClass.callSAPCOAService(tile,enteredNumberIsNotPresentInSF,typeOfNumberEntered);
                
                if(contentInfoTemp != null && contentInfoTemp.errorInfo != null && contentInfoTemp.errorInfo != ''){
                    
                    details.errorsInfo = contentInfoTemp.errorInfo;
                    
                    if(!typeOfNumberEntered.equals('Delivery Number') && contentInfoTemp.errorInfo.equals('An unexpected error occurred. The technical team has been notified.')){
                        errorFromSAP.add(contentInfoTemp.errorInfo);
                    }
                    
                    if(!contentInfoTemp.logCustomDebugLog.isEmpty()){
                        contentInfoInMaster.logCustomDebugLog.addAll(contentInfoTemp.logCustomDebugLog);
                    }
                }
                if(contentInfoTemp != null && !contentInfoTemp.contentTileMap.isEmpty() && contentInfoTemp.contentTileMap.containsKey(tile.Name)){
                    
                    if(!contentInfoInMaster.contentTileMap.containsKey(tile.Name)){
                        contentInfoInMaster.contentTileMap.putAll(contentInfoTemp.contentTileMap);   
                    }else if(contentInfoInMaster.contentTileMap.containsKey(tile.Name)){
                        contentInfoInMaster.contentTileMap.get(tile.Name).addAll(contentInfoTemp.contentTileMap.get(tile.Name));   
                    }
                    if(!contentInfoInMaster.tilesToInsert.containsKey(tile.Name)){
                        contentInfoInMaster.tilesToInsert.put(tile.Name,tile);
                    }

                } 
            
                if(contentInfoTemp != null && contentInfoTemp.ShipToNo != null && contentInfoTemp.ShipToNo != '' && enteredNumberIsNotPresentInSF){
                    contentInfoInMaster.ShipToNo = contentInfoTemp.ShipToNo;
            }
              
            }
            
            if(!contentInfoInMaster.contentTileMap.isEmpty() && !contentInfoInMaster.tilesToInsert.isEmpty()){
                details = insertAndPrepareContentData(contentInfoInMaster, baseURLSFDC, currentUser, isCommunity,enteredNumberIsNotPresentInSF);
            }
            else if(!contentInfoInMaster.logCustomDebugLog.isEmpty()){
                INSERT contentInfoInMaster.logCustomDebugLog;
            }
        
             //.debug('api limit'+Limits.getCallouts());
             DisplayAndDownloadCoAHelper.countAPICallsForCoA(Limits.getCallouts());
         
            if(errorFromSAP.size()>0 && !typeOfNumberEntered.equals('Delivery Number')){
                
                if(typeOfNumberEntered.equals('Sales Order Number') && errorFromSAP.size()<numberOfDelivery){
                    details.errorsInfo='Some of the Certificates under this Sales Order Number had errors and were not received.';
                }
                
                else if(typeOfNumberEntered.equals('Purchase Order Number') && errorFromSAP.size()<numberOfDelivery){
                    details.errorsInfo='Some of the Certificates under this Purchase Order Number had errors and were not received.';
                }
            }
            
        return details;
    }
    
    /* @Description
        Method Name : insertAndPrepareContentData( )

		After getting CoA from SAP insert that COA in SF and attached to Tile Record and return response to
        UI. 
	*/
    public static AllDetailsRelatedToCoAs insertAndPrepareContentData(COARequestClass.contentUserInfo continfoMaster, String baseURLSFDC, User currentUser, Boolean isCommunityUser,Boolean enteredNumberIsNotPresentInSF){
        
       
        List<ContentVersion> insertCoAWithAttachedToTile = new List<ContentVersion>();
        List<Tile__c> tilesToInsert = new List<Tile__c>();
        Map<String, Id> contentTileMapping = new Map<String,id>();
        List<Id> contentVersionIds = new List<Id>();
        AllDetailsRelatedToCoAs allCOAs = new AllDetailsRelatedToCoAs();
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();
        Set<FileData> fileFromSAP = new Set<FileData>();
        Boolean showCoA = false;
        Id contentOwner;
        
        Map<String,id> tileNameAndIdMap = new Map<String,id>();
        List<Tile__c> tileAlreadyInSFList= new List<Tile__c>();
        
        BGI_Salesforce_Settings__c  customSettings = BGI_Salesforce_Settings__c.getOrgDefaults();   // Fetch SAP Po user Id from this custom setting, and assign it as Owner for inserted ContentVersion and for Tile record
        
        List<User> systemAdmin = [SELECT id,Name,Profile.Name,IsActive FROM user WHERE Profile.Name=:'System Administrator' AND id=:customSettings.Default_Content_Owner_For_COA__c AND IsActive=:true];
        
        if(systemAdmin.size()>0){
            contentOwner = systemAdmin.get(0).id;
        }
        else{
            List<User> randomSystemAdmin = [SELECT id,Name,Profile.Name,IsActive FROM user WHERE Profile.Name=:'System Administrator' AND IsActive=:true limit 1]; // If in Case SAP Po user is inactive in future, then any user whose profile is system admin is assign as ContentVersion Owner
            if(randomSystemAdmin.size()>0)
            contentOwner = randomSystemAdmin.get(0).id;
        }
        
        for(Tile__c tile:[SELECT id,Name FROM Tile__c WHERE Name=:continfoMaster.contentTileMap.keySet()]){
            tileNameAndIdMap.put(tile.Name,tile.id);
            tileAlreadyInSFList.add(tile);
        }
        
       /* if(!tileNameAndIdMap.isEmpty()){
            if(tileNameAndIdMap.values().size()>0){
               DisplayAndDownloadCoAHelper.clearExistingCoAInSFLinkedToParticularNumber(tileNameAndIdMap.values());
            }
        }*/
        
        for(String eachTileName : continfoMaster.contentTileMap.keySet()){
            
            if(continfoMaster.tilesToInsert.containsKey(eachTileName)){
                if(!tileNameAndIdMap.containsKey(eachTileName)){
                   continfoMaster.tilesToInsert.get(eachTileName).OwnerId = contentOwner;
                   tilesToInsert.add(continfoMaster.tilesToInsert.get(eachTileName));
                }    
            }       
        }
        
        if(tilesToInsert.size()>0){
            INSERT tilesToInsert;
         }    
        if(!tileAlreadyInSFList.isEmpty()){
         tilesToInsert.addAll(tileAlreadyInSFList);
        }    
        
        if(!tilesToInsert.isEmpty()){
            for(Tile__c tile:tilesToInsert){
                List<ContentVersion> contentVersionList = continfoMaster.contentTileMap.get(tile.Name);
                
                if(contentVersionList != null && !contentVersionList.isEmpty()){
                    insertCoAWithAttachedToTile.addAll(contentVersionList);
                    for(ContentVersion cv:contentVersionList){
                        contentTileMapping.put(cv.Title,tile.id);
                    }
                }
                
            }
           
        }    
       
        if(insertCoAWithAttachedToTile.size()>0){
            INSERT insertCoAWithAttachedToTile;
            
            for(ContentVersion content: insertCoAWithAttachedToTile){
                contentVersionIds.add(content.id);
            }
        }
            for(ContentVersion content : [SELECT Id, ContentDocumentId,Title FROM ContentVersion WHERE Id IN: contentVersionIds]){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = content.ContentDocumentId;
                cdl.LinkedEntityId = contentTileMapping.get(content.Title);
                cdl.ShareType = 'V';
                contentDocLinkList.add(cdl);
                
            }
       
        if(!continfoMaster.logCustomDebugLog.isEmpty()){

            INSERT continfoMaster.logCustomDebugLog;
        }
        
        if(!contentDocLinkList.isEmpty()){
            INSERT contentDocLinkList;
        }
        
        
        if(insertCoAWithAttachedToTile.size()>0 && !contentOwner.equals(userinfo.getUserId())){
            
              DisplayAndDownloadCoAHelper.updateContentVersionsOwner(contentVersionIds, contentOwner);
        }
        
        
          if(!isCommunityUser || (isCommunityUser && !enteredNumberIsNotPresentInSF)){
                showCoA=true;
            }
            else if(enteredNumberIsNotPresentInSF && isCommunityUser){  // Checking if Delivery Number is not present In delivery object(also not in Tile Object) , then Authorization is happen by comparing Partner role data for visiblity of COA for current logged in user.
             
                showCoA = DisplayAndDownloadCoAHelper.checkCoAVisiblityForDeliveryNotPresentInSF(continfoMaster.ShipToNo,currentUser);
            }

        if(showCoA && contentVersionIds.size()>0){
            for(ContentVersion version:[select id,Title,ContentDocumentId,PathOnClient from ContentVersion where Id IN:contentVersionIds]){
                FileData fData = new FileData(
                    version.Title,
                    version.ContentDocumentId,
                    baseURLSFDC+'/sfc/servlet.shepherd/document/download/'+version.ContentDocumentId);
                fileFromSAP.add(fData);
            }
            allCOAs.fileRecord=fileFromSAP;
        }    
        else if(isCommunityUser && enteredNumberIsNotPresentInSF && !showCoA){
            allCOAs.errorsInfo ='This Delivery Number is either incorrect or does not exist.\n\t Please verify and try again.';
        }
        system.debug('COA from SAP-->'+allCOAs.fileRecord.size());
        return allCOAs;
    }
    
   
    public class AllDetailsRelatedToCoAs{
        
        @AuraEnabled public string errorsInfo{get;set;}
        @AuraEnabled public Set<FileData> fileRecord{get;set;} 
        
        public AllDetailsRelatedToCoAs(){
            This.errorsInfo = '';
            This.fileRecord = new Set<FileData>();
        }
    }
    
    public class FileData{
        
        @AuraEnabled public String fileName {get;set;}
        @AuraEnabled public String fileId {get;set;}
        @AuraEnabled Public String downloadUrl {get;set;}
        
        public FileData(String fileName,String fileId,String downloadUrl){
            This.fileName = fileName;
            This.fileId = fileId;
            This.downloadUrl = downloadUrl;
        }
    }
    
    
    Public class PrePopulateCaseFieldsForMissingCoA{
        
        @AuraEnabled public String accountName{get;set;}
        @AuraEnabled public String customerLocation{get;set;}
        @AuraEnabled public String contactName{get;set;}
        @AuraEnabled public String caseOwnereId{get;set;}
        @AuraEnabled public String missingCoARecordType{get;set;}
        
        public PrePopulateCaseFieldsForMissingCoA(String accountName,String customerLocation,String contactName,String caseOwnereId, String missingCoARecordType){
            This.accountName = accountName;
            This.customerLocation = customerLocation;
            This.contactName = contactName;
            This.caseOwnereId = caseOwnereId;
            This.missingCoARecordType = missingCoARecordType;
        }
    }
}