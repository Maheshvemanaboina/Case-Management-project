/*      
@Name                  EndCustomerBusinessSegmentValidation
@Author                Mahendra mahendra.kumar@frieslandcampina.com
@Version               1.0
@CreatedDate           15-09-2022
@UsedBy                AccountTriggerHandler
@TestClass			   EndCustomerBusinessSegmentValidationTest
@Description           To make the business segment field required and restrict to select only one value when the
					   distributor users create/update the end customer accounts from the distributor community.
@Changes
UserId           | Author-Email                   	  | Date      | Comment
=================|====================================|===========|=========
			     |									  | 	   	  | 
*/
public with sharing class EndCustomerBusinessSegmentValidation {
    
    static final Id END_CUSTOMER_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_End_Customer').getRecordTypeId();
    
    /*
		*@Description	Method to perform validation on End Customer Account Business segment when entered/updated
						from disti community
		*@param			accountList - New Accounts List (Trigger.new)
		*@param			accountOldMap - Map of Accounts (Trigger.oldMap)
		*@param			isUpdate - Boolean value to identify whether the account is updated or not
		*@return		void
	*/
    public static void validateEndCustomerBusinessSegment(List<Account> accountList, Map<Id, Account> accountOldMap, Boolean isUpdate){
        Boolean isAccountUpdated = isUpdate && accountOldMap != null && !accountOldMap.isEmpty();
        Boolean isValidationCriteriaMet;
        String errorMessage;
        for(Account acc : accountList){
            if(isAccountUpdated && accountOldMap.containsKey(acc.Id) &&
                				 acc.Business_Segment__c == accountOldMap.get(acc.Id).Business_Segment__c)
            {
                continue;
            }
            isValidationCriteriaMet = acc.RecordTypeId == END_CUSTOMER_RECORD_TYPE_ID &&
                                 	  isCurrentUserDistiCommunityUser() &&
                                      ((acc.Business_Segment__c != null && acc.Business_Segment__c.contains(';')) ||
                                      acc.Business_Segment__c == null);
            
            if((!isAccountUpdated && isValidationCriteriaMet) || (isAccountUpdated && isValidationCriteriaMet &&
                				 accountOldMap.containsKey(acc.Id) &&
                				 acc.Business_Segment__c != accountOldMap.get(acc.Id).Business_Segment__c))
            {
                acc.Business_Segment__c.addError(System.Label.End_Customer_Business_Segment_Validation);
            }
        }
    }
    
    /*
		*@Description	Method to perform validation on End Customer Account Business segment when inserted
						from disti community
		*@param			accountList - New Accounts List (Trigger.new)
		*@return		void
	*/
    public static void validateEndCustomerOnInsert(List<Account> accountList){
        validateEndCustomerBusinessSegment(accountList, null, false);
    }
    
    /*
		*@Description	Method to check whether the logged in user is distributor user or not
		*@return		Boolean	returns true if the logged in user is disti user otherwise it returns false
	*/
    private static Boolean isCurrentUserDistiCommunityUser(){
        User loggedInUser = UserUtility.getCurrentUser();
        return loggedInUser.Profile.Name == Constants.TEST_FCI_DISTRIBUTOR_PROFILE && loggedInUser.IsPortalEnabled;
    }
}