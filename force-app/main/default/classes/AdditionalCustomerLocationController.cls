public class AdditionalCustomerLocationController {
	@AuraEnabled
    public static void insertOrUpdateAdditionalCustomerLocation(Other_Related_Customer_Location__c custLocRecord){
        custLocRecord.RecordTypeId = KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID;
        system.debug('custLocRecord >>> '+custLocRecord);
        //upsert custLocRecord;
        insert custLocRecord;
    }
    
    @AuraEnabled
    public static List<Other_Related_Customer_Location__c> getAllAdditionalCustomerLocations(String contactId){
        return [SELECT Id, Related_Contact__c, Additional_Customer_Location__c, Additional_Customer_Location__r.Name FROM Other_Related_Customer_Location__c
                WHERE Related_Contact__c =: contactId];
    }
    
    @AuraEnabled
    public static void deleteSelectedAdditionalCustomerLocation(String custLocId){
        delete [SELECT Id FROM Other_Related_Customer_Location__c WHERE Id=: custLocId];
    }
    
    @AuraEnabled
    public static Boolean isContactEnabledAsPartner(String contactId){
        List<User> portalUsers = [SELECT Id, IsPortalEnabled FROM user WHERE IsActive=true AND
                                  ContactId =:contactId AND IsPortalEnabled=true AND
                                  Community_User_Role__c =: Constants.COMMUNITY_USER_ROLE_STANDARD_USER AND
                                  Profile.UserLicense.Name =: Constants.FCI_DISTRIBUTOR_PROFILE_LICENSE];
        if(portalUsers.size() > 0){
            return true;
        }
        return false;
    }
}