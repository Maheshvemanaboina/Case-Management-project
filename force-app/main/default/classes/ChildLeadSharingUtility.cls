/**      
@Name                 ChildLeadSharingUtility
@Author               Mahendra Kumar | mahendra.kumar@frieslandcampina.com
@ModifiedBy           Mahendra Kumar | mahendra.kumar@frieslandcampina.com
@Version              1.0
@CreatedDate          17-04-2023
@UsedBy               ChildLeadTriggerHandler

UserId               | Author-Email                           | Date       	| Comment
=====================|========================================|=============|================
0058E000009TanLQAS	 | mahendra.kumar@frieslandcampina.com    | 17.04.2023	| Created class

* @description This class contains custom shaing logic for child lead records
*/
public with sharing class ChildLeadSharingUtility {
	public static final Id PARTNER_LEAD_RECORD_TYPE_ID = Schema.SObjectType.Child_Lead__c.getRecordTypeInfosByDeveloperName().get('Partner_Child_Lead').getRecordTypeId();// Store partner lead record type Id
    
    /**
     * @description This method is used share the child lead records on inserting them.
     * @param newChildLeads - child lead record list from trigger.New are passed as parameter.
	*/
    public static void recalculateChildLeadSharingOnInsert(List<Child_Lead__c> newChildLeads){
        
        List<Child_Lead__c> leadToRecalculate    = new List<Child_Lead__c>();//Stores the updated/New child leads 
        set<Id> accIdsToRecalculate     = new set<Id>();   //Stores the dist parent and dist account name Ids
        Map<Id,User> usersToConsider    = new Map<Id,User>();//Stores the community user ids
        
        for (Child_Lead__c childLead : newChildLeads) {
            if (isRecalculationRequiredToShare(childLead)){
                
                leadToRecalculate.add(childLead);
                if( childLead.Distributor_Account_Name__c!=Null ){
                    accIdsToRecalculate.add(childLead.Distributor_Account_Name__c);
                }
                if( childLead.Distributor_Parent_Account__c!=Null ){
                    accIdsToRecalculate.add(childLead.Distributor_Parent_Account__c);
                }
                
            }
        }
        if(!accIdsToRecalculate.isEmpty()){
            usersToConsider = UserUtility.getCommunityUsersByAccountIds(accIdsToRecalculate);
        }

        if(!leadToRecalculate.isEmpty()){
            
            createLeadSharing(usersToConsider.values(),leadToRecalculate);
        }
        
    }
	/**
	 * @description This method is used share the child lead records on updating them.
	 * @param newLeads - child lead record list from trigger.New are passed as parameter.
	*/
    public static void recalculateChildLeadSharingOnUpdate(List<Child_Lead__c> newLeads){
        
        List<Child_Lead__c> leadToRecalculate    = new List<Child_Lead__c>();//Stores the updated/New child leads 
        set<Id> accIdsToRecalculate     = new set<Id>();   //Stores the dist parent and dist account name Ids
        Map<Id,User> usersToConsider    = new Map<Id,User>();//Stores the community user ids
        
        for (Child_Lead__c childLead : newLeads) {
            if (isRecalculationRequiredToShare((Child_Lead__c)trigger.OldMap.get(childLead.Id), childLead)) {

                leadToRecalculate.add(childLead);
                if( childLead.Distributor_Account_Name__c != null ){
                    accIdsToRecalculate.add(childLead.Distributor_Account_Name__c);
                }
                if( childLead.Distributor_Parent_Account__c != null ){
                    accIdsToRecalculate.add(childLead.Distributor_Parent_Account__c);
                }
               	
            }
        }
        if(!accIdsToRecalculate.isEmpty()){
            usersToConsider = UserUtility.getCommunityUsersByAccountIds(accIdsToRecalculate);
        }
        
        if(!leadToRecalculate.isEmpty()){

            DAOUtilityWithoutShar.deleteAllChildLeadsRelatedSharing(usersToConsider.values(),leadToRecalculate);
            createLeadSharing(usersToConsider.values(),leadToRecalculate);
        }        
	}
    
    /**
     * @description This method is used fetch the child lead and user Ids and send to the createSharingForLeadFuture method.
     * @param userList - Community users list are passed as parameter. 
     * @param childLeadList - child lead record list from trigger.New are passed as parameter.
	*/
    public static void createLeadSharing(List<User> userList, List<Child_Lead__c> childLeadList){
        
        Set<Id> usersIds = new Set<Id>();//Store unique user Ids
        for (User usr : userList) {
            usersIds.add(usr.Id);
        }
        
        Set<Id> childLeadIds = new Set<Id>();//Store unique lead Ids
        for (Child_Lead__c childLead : childLeadList) {
            childLeadIds.add(childLead.Id);
        }
        
        createSharingForLeadFuture(usersIds, childLeadIds);
    }
    
     /**
      * @description This method is used to run the sharing asynchronously.
      * @param usersIds - Community user Ids are passed as parameter
      * @param childLeadIds - child lead records Ids from trigger.New are passed as parameter
	*/
    @future
    public static void createSharingForLeadFuture(Set<Id> usersIds, Set<Id> childLeadIds) {
        if(!system.isBatch()){
            createSharingForLead(usersIds, childLeadIds);
        }
    }
    
      /**
       * @description This method is used to fetch the child lead and user data which needs to be shared with community users
       * @param usersIds - Community user Ids are passed as parameter 
       * @param childLeadIds - child lead records Ids from trigger.New are passed as parameter
	*/
    public static void createSharingForLead(Set<Id> usersIds, Set<Id> childLeadIds) {
        
        List<User> userList = [SELECT Id,Contact.Parent_Account__c, Contact.Additional_Country_Responsibility__c, Contact.AccountId, Community_User_Role__c, ContactId, IsPortalEnabled FROM User WHERE Id IN :usersIds];//Store community user with which leads are shared
		List<Child_Lead__c> childLeadList = DAOUtilityWithoutShar.getChildLeadsForSharing(childLeadIds);//Store lead data which needs to be shared
        List<Child_Lead__Share> childLeadShareList = new List<Child_Lead__Share>();
        
        Map<Id, Set<Id>> usersWithAddCustLocsMap = new Map<Id, Set<Id>>();
        usersWithAddCustLocsMap = AccountUtility.getAdditionalCustLocsOfSelectedUsers(userList);
        
        for (User currUser : userList) {
            for (Child_Lead__c childLead : childLeadList) {

                if (childLead.OwnerId.equals(currUser.Id)) {
                    continue;
                }
                
                Child_Lead__Share childLeadShare;
                if (UserUtility.isUserStandardCommunityUser(currUser)) {
                    childLeadShare = createSharingForStandardUser(currUser, childLead, usersWithAddCustLocsMap);
                } else {
                    childLeadShare = createSharingForManagerUser(currUser, childLead);
                }
				
                if (childLeadShare == null) {
                    continue;
                }

                childLeadShareList.add(childLeadShare);           
            }
        }     
        DAOUtilityWithoutShar.insertWithoutAccess(childLeadShareList);
      
    }
    
     /**
      * @description This method creates the sharing for standard users
      * @param stdUser - Single community user record is passed as parameter 
      * @param childLeadObj - Single child lead record is passed as parameter
      * @param userAddCustLocsMap - users with Additional customer locations map
      * @return Child_Lead__Share - Returns the instance of LeadShare.
	*/
    private static Child_Lead__Share createSharingForStandardUser(User stdUser,Child_Lead__c childLeadObj, Map<Id, Set<Id>> userAddCustLocsMap){
        if(isEligibleForStandardUserLeadSharing(StdUser,childLeadObj, userAddCustLocsMap)){
            return createShareLeadRecord(StdUser, childLeadObj, false);
        }
        
        return null;
    }
    
    /**
     * @description This method creates the sharing for manager users
     * @param stdUser - Single community user record is passed as parameter
     * @param childLeadObj - Single child lead record is passed as parameter
     * @return Child_Lead__Share - Returns the instance of LeadShare.
	*/
    private static Child_Lead__Share createSharingForManagerUser(User stdUser, Child_Lead__c childLeadObj){
        if(isEligibleForManagerUserLeadSharing(StdUser,childLeadObj)){
            return createShareLeadRecord(StdUser, childLeadObj, true);
        }
        
        return null;
    }
    
    /**
     * @description This method checks whether the user is eligible standard user or not.
     * @param stdUser - Single community user record is passed as parameter 
     * @param childLeadObj - Single child lead record is passed as parameter
     * @param userAddCustLocsMap - users with Additional customer locations map
     * @return Boolean - returns the condition is true or false.
	*/
     private static boolean isEligibleForStandardUserLeadSharing(User stdUser, Child_Lead__c childLeadObj, Map<Id, Set<Id>> userAddcustLocMap){
        
         return stdUser.Contact.AccountId != null &&
            (stdUser.Contact.AccountId.equals(childLeadObj.Distributor_Account_Name__c) || 
            (stdUser.Contact.Additional_Country_Responsibility__c != null && 
            childLeadObj.Distributor_Account_Name__c !=null && childLeadObj.Distributor_Account_Name__r.BillingCountry != null &&
            stdUser.Contact.Additional_Country_Responsibility__c.containsIgnoreCase(childLeadObj.Distributor_Account_Name__r.BillingCountry)) ||
            (childLeadObj.Distributor_Account_Name__c !=null && userAddcustLocMap.containsKey(stdUser.Id) && userAddcustLocMap.get(stdUser.Id) != null &&
             userAddcustLocMap.get(stdUser.Id).contains(childLeadObj.Distributor_Account_Name__c)));
    }
    
     /**
      * @description This method checks whether the user is eligible manager user or not.
      * @param mngUser - Single community user record is passed as parameter. 
      * @param childLeadObj - Single child lead record is passed as parameter.
      * @return Boolean - returns the condition is true or false.
	*/
    private static boolean isEligibleForManagerUserLeadSharing(User mngUser, Child_Lead__c childLeadObj){
       
        return mngUser.Contact.AccountId != null &&
            mngUser.Contact.Parent_Account__c != null &&
            (mngUser.Contact.AccountId.equals(childLeadObj.Distributor_Account_Name__c) ||
            mngUser.Contact.Parent_Account__c.equals(childLeadObj.Distributor_Parent_Account__c));
    }
    
     /**
      * @description This method creats a Child_Lead__Share instance 
      * @param us - Single community user record is passed as parameter. 
      * @param childLeadObj - Single child lead record is passed as parameter.
      * @param isManagerUser - Accepts True or False.
      * @return Child_Lead__Share - Returns the instance of Child_Lead__Share.
	*/
    private static Child_Lead__Share createShareLeadRecord(User us, Child_Lead__c childLeadObj, Boolean isManagerUser){
        return new Child_Lead__Share(
            ParentId = childLeadObj.Id,
            AccessLevel = 'EDIT',
            RowCause = isManagerUser ? 'Manager_User__c' : 'Standard_User__c',
            UserOrGroupId = us.Id
        );
    }
    
     /**
      * @description This method checks old distributor account name is not equal to the new distributor account name and initiates the sharing only if they are different.
      * @param oldChildLead - Child Lead records for trigger.old
      * @param newChildLead - Child Lead records for trigger.New
      * @return Boolean - returns the condition is true or false.
	*/
    private static Boolean isRecalculationRequiredToShare(Child_Lead__c oldChildLead, Child_Lead__c newChildLead){
        return ((oldChildLead.Distributor_Account_Name__c != newChildLead.Distributor_Account_Name__c ) ||
                (oldChildLead.OwnerId != newChildLead.OwnerId ));
    }
    
    /**
     * @description This method checks child lead record type is equal to "Partner Child Lead" record type or no.If its a "Partner Child Lead" record type only at that time sharing is initiated.
     * @param newChildLead - Lead records for trigger.New.
     * @return Boolean - returns the condition is true or false.
	*/
    private static Boolean isRecalculationRequiredToShare(Child_Lead__c newChildLead){
        return newChildLead.RecordTypeId.equals(PARTNER_LEAD_RECORD_TYPE_ID);
    }
    
	/**
	 * @description Method to get all child leads related to accounts
	 * @param AccountIds - Set of Account Ids to get leads related
	 * @return List<Child_Lead__c> - Child Leads list related of that accounts
    */
    public static List<Child_Lead__c> allLeadsRelatedToAccounts(Set<Id> AccountIds){
        return [
                SELECT Id,Distributor_Account_Name__c,Distributor_Account_Name__r.BillingCountry,Distributor_Parent_Account__c,RecordTypeId,
            	OwnerId, CreatedById
                FROM Child_Lead__c
                WHERE RecordTypeId = :PARTNER_LEAD_RECORD_TYPE_ID
                AND Distributor_Account_Name__c != null
                AND Distributor_Parent_Account__c != null
                AND (Distributor_Parent_Account__c IN :AccountIds OR Distributor_Account_Name__c IN :AccountIds)
        ];
    }
}