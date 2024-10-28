/*
@Author     : Rohit Kumar
@CreatedDate: 
@UsedBy     : 
@Description: 
Methods : 
@History
Rohit Kumar : Created
*/

public without sharing class CoASObjectLookUpController {
    
    @AuraEnabled
    public static List<sObject> getRecords(String objectAPIName, /* The sObject name from where the records will be queried */
                                           String fieldAPIName, /* The field that will be used in the search results */
                                           String whereFieldAPIName, /* The field that will be used in the where clause with Search Text */
                                           List<String> metaFieldsAPI, /* Field API for the fields to be shown under the record Name. Must be comma separated. Example: Email,Phone */
                                           String searchText, /* Search Text entered by User */
                                           Integer recordLimit, /* No of Records to return at once */
                                           Boolean isEnteredNumberIsUnique, /*Use to identified that searched number is unique or not*/
                                           String typeOfNumber /* Type of Number entred by user In DisplayAndDownloadCoA Ui*/ 
                                          )
    {
        
        List<sObject> objectList =  new List<sObject>();
        Set<String> extraCountryResponsiblity = new Set<String>();
        Boolean isSharingFieldFound = true;   //If Current Log In User is community User and no sharing Field found then don't show any number
        String sharingField = '';
        String communityUserRole;
        Id customerLocation;
        Id commercialLocation;
        
        User currentUser = [SELECT id,Contact.AccountId,Contact.Parent_Account__c,Community_User_Role__c,
                            Contact.Additional_Country_Responsibility__c FROM user WHERE id=:userinfo.getUserId()];
        
        
        if(currentUser.ContactId!=null){
            
            if(currentUser.Contact.Additional_Country_Responsibility__c!=null && 
               currentUser.Contact.Additional_Country_Responsibility__c!='')
            {
                for(String country:currentUser.Contact.Additional_Country_Responsibility__c.split(';')){
                    extraCountryResponsiblity.add(country);
                }
            }
            customerLocation = currentUser.Contact.AccountId;
            commercialLocation = currentUser.Contact.Parent_Account__c;
            communityUserRole = currentUser.Community_User_Role__c;
            
            sharingField = getSharingFiledAndValueBasedOnLoggedInUser(typeOfNumber,customerLocation,commercialLocation,
                                                                      communityUserRole,extraCountryResponsiblity);
            isSharingFieldFound =  sharingField == ''? false : true;                                                        
            //system.debug('sharingField-->'+sharingField);
        }
        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';
        
        String soqlQuery = 'SELECT Id,Name ';
        soqlQuery = !fieldAPIName.equalsIgnoreCase('Name') ? soqlQuery + ',' + fieldAPIName : soqlQuery;
        
        if(metaFieldsAPI.indexOf(fieldAPIName) != -1){
            metaFieldsAPI.remove(metaFieldsAPI.indexOf(fieldAPIName));
        }
        
        if(isEnteredNumberIsUnique && isSharingFieldFound){
            
            if(!metaFieldsAPI.isEmpty() && !metaFieldsAPI.contains(fieldAPIName)){
                soqlQuery = soqlQuery + ',' + String.join(metaFieldsAPI, ',') ;
            }
            
            soqlQuery += ' FROM ' + objectAPIName + ' WHERE ' + whereFieldAPIName +' LIKE ';
            soqlQuery += searchText+sharingField + ' LIMIT '+ recordLimit;    
            //system.debug('soql unique;'+soqlQuery);
            objectList = Database.query(soqlQuery);
            return objectList;
        }else{
            
            String metaFieldAPIForNotUnique = '';
            String metaFieldAPIName = '';
            String relationShipName = 'Ship To';
            String whereFieldsQuery = typeOfNumber.equals('SHIPTO_NUMBER') ? whereFieldAPIName +' LIKE '+ 
                                      searchText +sharingField+' AND '+' Relation_Name__c='+'\''+relationShipName+'\'' :
                                      whereFieldAPIName +' LIKE '+ searchText + sharingField;
            
            if(metaFieldsAPI.size()>0){
                metaFieldAPIForNotUnique = ','+metaFieldsAPI.get(0)+' METAFIELDVALUE';
                metaFieldAPIName = ','+metaFieldsAPI.get(0);
            }
            
            soqlQuery = 'SELECT Count(id),'+fieldAPIName+' RECORDFIELDVALUE'+metaFieldAPIForNotUnique+' FROM '+objectAPIName+
                        ' WHERE '+whereFieldsQuery +' GROUP BY '+fieldAPIName+metaFieldAPIName+
                        ' LIMIT '+ recordLimit  ;
            //system.debug('soql:'+soqlQuery);
            if(isSharingFieldFound){
                for(AggregateResult ar : Database.query(soqlQuery)){
                    //system.debug('ar:'+ar);
                    objectList.add(ar);
                }
            }
            return objectList;
        }
        
    }
    
 public static String getSharingFiledAndValueBasedOnLoggedInUser(String typeOfNumber,Id customerLocation,id commercialLocation,
                                                                    String communityUserRole,Set<String> extraCountryResponsiblity){
                                                                        
                                                                        
  if(String.isBlank(communityUserRole) || communityUserRole.equals('Standard User')){
  
      if(typeOfNumber.equals('Sales Order Number') || typeOfNumber.equals('Purchase Order Number')){
        
                      return ' AND '+'('+'AccountId=:customerLocation'+' OR '+
                                         '('+'Parent_Account__c=:commercialLocation'+' AND '+
                                          'Account.BillingCountry IN:extraCountryResponsiblity'+')'+
                                      ')';
       }
       else if(typeOfNumber.equals('Delivery Number')){
                      return ' AND '+'('+'Sold_To__c=:customerLocation'+' OR '+
                                          '('+'Sold_To__r.ParentId=:commercialLocation'+' AND '+
                                              'Sold_To__r.BillingCountry IN:extraCountryResponsiblity'+ ')'+
                                      ')';
        }
        else if(typeOfNumber.contains('Batch')){
                      return ' AND '+'('+'Delivery__r.Sold_To__c=:customerLocation'+' OR '+
                                         '('+'Delivery__r.Sold_To__r.ParentId=:commercialLocation'+' AND '+
                                             'Delivery__r.Sold_To__r.BillingCountry IN:extraCountryResponsiblity'+ ')'+
                                      ')';
         }
     }else if(communityUserRole.equals('Manager User')){
                                                                            
        if(typeOfNumber.equals('Sales Order Number') || typeOfNumber.equals('Purchase Order Number')){
                       return ' AND '+'Parent_Account__c='+'\''+commercialLocation+'\'';
        }
        else if(typeOfNumber.equals('Delivery Number')){
                      return ' AND '+'Sold_To__r.ParentId='+'\''+commercialLocation+'\'';
        }
        else if(typeOfNumber.contains('Batch')){
                      return ' AND '+'Delivery__r.Sold_To__r.ParentId='+'\''+commercialLocation+'\'';
        }
                                                                            
        }
      return '';
     }
    
}