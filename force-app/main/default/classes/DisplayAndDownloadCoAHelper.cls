/*
@Author     : Rohit Kumar
@CreatedDate: 06/08/2021
@UsedBy     : DisplayAndDownloadCoAHandler
@Description: This Class use to check sharing/visiblity condition for CoA  

@History
  06-08-2021  Rohit Kumar : Created
*/
public without sharing class DisplayAndDownloadCoAHelper {
    

    /* @Description
        Method Name : checkEnteredNumberBelongToCurrentUser( )

		Check entered number is belong to current logged only applicable for community users.

    */
    public static Boolean checkEnteredNumberBelongToCurrentUser(User currentuser,Id customerLocationOnNumber,
                                                                Id commercialLocationOnNumber,String billingCountryOnNumber)
    {
        //Current User Details
        Set<String> additionalCountry = new Set<String>();
        String commercialCustomer = currentuser.Contact.Parent_Account__c ;
        String customerLocation = currentuser.Contact.AccountId ;
        String communityUserrole ;

        if(String.isBlank(currentuser.Community_User_Role__c))
        communityUserrole ='Standard User';
        else 
        communityUserrole = currentuser.Community_User_Role__c;

        if(currentuser.Contact.Additional_Country_Responsibility__c!=null && currentuser.Contact.Additional_Country_Responsibility__c!=''){
            for(String country:currentuser.Contact.Additional_Country_Responsibility__c.split(';')){
                additionalCountry.add(country);
            }
        }

        if(communityUserrole.equals('Standard User') && (customerLocation.equals(customerLocationOnNumber) ||
           additionalCountry.contains(billingCountryOnNumber) && commercialCustomer.equals(commercialLocationOnNumber)))
        {
            return true;
        }else if(communityUserrole.equals('Manager User') && commercialCustomer.equals(commercialLocationOnNumber)){
            return true;
        }

        return false;
    }
   
    /* @Description
        Method Name : getBatchNumberAndItsRelatedShipToList( )

		Get all Delivery Line Item Record belong to entered batch number, so it will easy to get all
		related ship with that batch number

    */
    public static List<Delivery_Line_Item__c> getBatchNumberAndItsRelatedShipToList(String typeOfNumber,String enteredNumber){

        List<Delivery_Line_Item__c> batchList = new List<Delivery_Line_Item__c>();
        List<Delivery_Line_Item__c> batchListRelatedToUser = new List<Delivery_Line_Item__c>();
        String batchQuery;
    
        if(typeOfNumber.contains('Child')){
            batchQuery = 'SELECT SAP_Batch_Number__c,Delivery__r.Sold_To__c,Delivery__r.Sold_To__r.ParentId,'+
                          'Delivery__r.Ship_To__r.SAP_Number__c,Delivery__r.Sold_To__r.BillingCountry FROM Delivery_Line_Item__c WHERE '+ 
                          'SAP_Batch_Number__c =:enteredNumber';
        }
        else {
            batchQuery = 'SELECT Mother_Batch_Number__c,Delivery__r.Sold_To__c,Delivery__r.Sold_To__r.ParentId,'+
                         'Delivery__r.Ship_To__r.SAP_Number__c,Delivery__r.Sold_To__r.BillingCountry FROM Delivery_Line_Item__c WHERE '+ 
                         'Mother_Batch_Number__c =:enteredNumber';                 

        }
        if(batchQuery!=null){
            batchList = (List<Delivery_Line_Item__c>)Database.query(batchQuery);
        }

        if(!batchList.isEmpty() ){
            return batchList;
        }
       
        
        return batchList;

    }

    /* @Description
        Method Name : shipToRelatedToEnteredBatch( )

		From Delivery Line Item list out the Ship to related with entered Batc Number.

    */
    public static Set<String> shipToRelatedToEnteredBatch(List<Delivery_Line_Item__c> batchList,User currentuser){

        Set<String> shipToList = new Set<String>();
        Boolean  validate = false;

            for(Delivery_Line_Item__c batch :batchList ){
                
                 if(currentUser.ContactId!=null){
                    validate = DisplayAndDownloadCoAHelper.checkEnteredNumberBelongToCurrentUser(currentuser,batch.Delivery__r.Sold_To__c , batch.Delivery__r.Sold_To__r.ParentId,
                                                                                                        batch.Delivery__r.Sold_To__r.BillingCountry);
                 } else{
                    shipToList.add(batch.Delivery__r.Ship_To__r.SAP_Number__c);
                 }                                                                                     
                 if(validate){
                    shipToList.add(batch.Delivery__r.Ship_To__r.SAP_Number__c);
                 }
            }
            return shipToList;
    }
    
	/* @Description
        Method Name : checkCoAVisiblityForDeliveryNotPresentInSF( )

		This method check that entered Delivery number belongs to current user(Coomunity users) or not ,
		this method only applicable for if CoA request made for Delivery Number which is
        not present in Salesforce and COA successfully received from SAP.

    */
    public static boolean checkCoAVisiblityForDeliveryNotPresentInSF(String shiptToNo, User  communityUser){
        
        List<SObject> objectList = new List<SObject>();
        String relationType = 'Ship To';
        String  customerLocation = communityUser.Contact.AccountId;
        String  commercialLocation = communityUser.Contact.Parent_Account__c ;
        String  communityUserRole =  communityUser.Community_User_Role__c;
        String soqlQuery =  'SELECT id FROM Partner_Role__c ';
               soqlQuery += 'WHERE Target_Account_Number__c =:shiptToNo  AND Relation_Name__c=:relationType';
      
        if(String.isBlank(communityUserRole) || communityUserRole.equals('Standard User')){
            soqlQuery += ' AND Source_Account__c =:customerLocation LIMIT 1';
        }else{
            soqlQuery += ' AND Source_Account__r.ParentId =:commercialLocation LIMIT 1'; 
        }
        objectList =  Database.query(soqlQuery);

        if(!objectList.isEmpty()){

            return true;
        }else{

            return false;
        }
    }

    /* @Description
        Method Name : updateContentVersionsOwner( )

		This method update owner of CoA(ContentVersion) received from SAP after because
		it will restrict the access(only give view) on CoA for community user.

    */
    @future
    public static void updateContentVersionsOwner(List<id> contentVesrionIds,id contentOwner){
        
        
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for(ContentVersion version :[SELECT id,OwnerId FROM ContentVersion WHERE id IN:contentVesrionIds]){
               version.OwnerId =contentOwner;
               contentVersions.add(version);
           }
          if(contentVersions.size()>0 ){
              UPDATE contentVersions;
          }
    }
    
   /* public static void clearExistingCoAInSFLinkedToParticularNumber(List<id> linkedEntityIdSet){
        
        Set<Id> contentId = new Set<Id>();
       
        if(linkedEntityIdSet.size()>0){
            for(ContentDocumentLink content:[SELECT id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:linkedEntityIdSet]){
                contentId.add(content.ContentDocumentId);
            }
        }    
        
        if(contentId.size()>0){
           clearExistingCoA(contentId);
        }    
        
    }
    
    @future
    public static void clearExistingCoA(Set<id> contentDocumentIdSet){
        
         List<ContentDocument> contentDocuments = [SELECT id FROM ContentDocument WHERE id IN:contentDocumentIdSet];
           
        if(!contentDocuments.isEmpty()){
             DELETE contentDocuments;
        }    
    }*/
    
    @future 
    public static void countAPICallsForCoA(integer coAAPICount){

        Date currentDate =  System.today();
        Boolean isSameDay = false;
        String tileCoAAPICallRecordName = 'API_Calls_Count_for_CoA_Interface'+'-'+currentDate ;
         Id coARecordTypeId = Schema.SObjectType.Tile__c.getRecordTypeInfosByDeveloperName().get('Certificate_of_Analysis').getRecordTypeId();
        
        List<Tile__c> tileList = new List<Tile__c>();
        
        tileList = [SELECT id,Name,Total_API_Call_In_a_Day__c,LastModifiedDate FROM Tile__c
                    WHERE Name=:tileCoAAPICallRecordName AND RecordTypeId=:coARecordTypeId];
        
        
        if(tileList.size()>0){
            if(tileList[0].LastModifiedDate.Date().isSameDay(currentDate)){
                isSameDay = true;
                tileList[0].Total_API_Call_In_a_Day__c+= coAAPICount;
                UPDATE tileList[0];
              } 
        }else if(!isSameDay){
            Tile__c countAPICallForCoA = new Tile__c();
            countAPICallForCoA.Name = tileCoAAPICallRecordName;
            countAPICallForCoA.Total_API_Call_In_a_Day__c = coAAPICount;
            countAPICallForCoA.RecordTypeId = coARecordTypeId;
            INSERT countAPICallForCoA;
        }
        
        
    }

}