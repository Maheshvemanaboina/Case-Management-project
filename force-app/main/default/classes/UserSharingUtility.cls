/*      
@Name                  UserSharingUtility
@Author                Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com
@ModifiedBy            Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com
@Version               1.1
@CreatedDate           04-08-2019
@UsedBy                UserTriggerHandler
@Description           Created by Sibananda to share accounts, Opportunities, cases on user create/Update.
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Sibananda Bhuyan-sibananda.bhuyan@frieslandcampina.com | 29.01.2021 | Updated to move all code from UserTriggerHandler to UserSharingUtility & changes for New Account Re-design
*/
public with Sharing class UserSharingUtility {
    
    /* @Description

    Method to calculate sharing on Community User create

    @param newUsers - New users list (Trigger.new)

    @return void
    */
    public static void calculateSharingOnUserCreate(List<User> newUsers){

        List<User> usersToCalculate = getCommunityUsers(newUsers); //Users list to consider

        /* Contract Sharing */
        //Set<Id> conIdToRecalculateAddCountryRespContracts = new Set<Id>(); //Set of users Id to calculate contract sharing (account sharing)

        if(!usersToCalculate.isEmpty()){

            //Get the contact Id to Recalculate Contract Sharing for Additional Country Responsability
            
            /* for (User usr : usersToCalculate) {
                conIdToRecalculateAddCountryRespContracts.add(usr.ContactId);
            } */

            //Collect all Account & ParentAccount to consider for calculation
            Map<Id,User> userMap    = UserUtility.getAllSelectedCommunityUsers(usersToCalculate); //Map of user Id and user to collect account and parent account fields
            Set<Id> accountIds      = getAccountIdsToCalculate(userMap.values()); //Set of account Id related to users

            //Shares proper accounts to community users
            //AccountSharingUtility.initiateAccountSharing(usersToCalculate, AccountUtility.getAccountAllAccountsToShareWithCommunityUsers(userMap.values()));

            //Shares proper opportunities and cases to community users
            createSharingRecordsFuture(
                (new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(accountIds))).keySet(), 
                (new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(accountIds))).keySet(),
                userMap.keySet(),
                (new Map<Id, Account>(AccountUtility.getAccountAllAccountsToShareWithCommunityUsers(userMap.values()))).keySet(),/*,
                conIdToRecalculateAddCountryRespContracts*/
                /*(new Map<Id, Lead>(LeadSharingUtility.allLeadsRelatedToAccounts(accountIds))).keySet()*/
                (new Map<Id, Child_Lead__c>(ChildLeadSharingUtility.allLeadsRelatedToAccounts(accountIds))).keySet()
            );
            
            createKPISharingRecords(
                userMap.values(),
                BusinessStrategySharingUtility.allBusinessStrategiesRelatedToAccounts(accountIds),
                CommercialActivitySharingUtility.allCommercialActivitiesRelatedToAccounts(accountIds),
                FCICustomerSupportSharingUtility.allFCICustomerSupportsRelatedToAccounts(accountIds),
                ForecastAccuracySharingUtility.allForecastAccuraciesRelatedToAccounts(accountIds),
                SalesFunnelSharingUtility.allSalesFunnelsRelatedToAccounts(accountIds),
                AccountPlanSharingUtility.allAccountPlansRelatedToAccounts(accountIds)
            );
        }

    }

    /* @Description

    Method to calculate sharing on Community User update

    @param newUsers - New users list (Trigger.new)

    @return void
    */
    public static void recalculateSharingOnUserUpdate(List<User> newUsers){

        List<User> usrsToRecalculate = new List<User>(); //Users list to consider
        /* Contract Sharing */
        //Set<Id> conIdToRecalculateAddCountryRespContracts = new Set<Id>();
        List<User> usersToRecalculateKPISharing = new List<User>();
        Boolean createHelpDeskCaseForKPISharing = false;

        for (User usr : newUsers) {
            if (isRecalculationRequired((User)trigger.OldMap.get(usr.Id), usr)) {
                usrsToRecalculate.add(usr);
				if(UserUtility.isUserManagerCommunityUser(usr)) usersToRecalculateKPISharing.add(usr);
                //Get the contact Id to Recalculate Contract Sharing for Additional Country Responsability
                //conIdToRecalculateAddCountryRespContracts.add(usr.ContactId);
                User oldUser = (User)trigger.OldMap.get(usr.Id);
                if(oldUser.Community_User_Role__c == Constants.COMMUNITY_USER_ROLE_MANAGER_USER
                  && usr.Community_User_Role__c != oldUser.Community_User_Role__c) createHelpDeskCaseForKPISharing = true;
            }
        }

        if(!usrsToRecalculate.isEmpty()){

            //Collect all Account & ParentAccount to consider for calculation
            Set<Id> accountIds      = getAccountIdsToCalculate(usrsToRecalculate);  //Set of account Id related to users
            Map<Id,User> userMap    = UserUtility.getAllSelectedCommunityUsers(usrsToRecalculate); //Map of user Id and user to collect account and parent account fields

            //Shares proper accounts to community users
            AccountSharingUtility.deleteAllAccountRelatedSharing(usrsToRecalculate);
            //AccountSharingUtility.initiateAccountSharing(usrsToRecalculate, AccountUtility.getAccountAllAccountsToShareWithCommunityUsers(userMap.values()));

            //Shares delete OpportunityShares to community users
            OpportunitySharingUtility.deleteAllOpportunityRelatedSharing((new Map<Id, User>(usrsToRecalculate)).keySet(), (new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(accountIds))).keySet());

            //Shares delete CaseShares to community users
            CaseSharingUtility.deleteAllCasesRelatedSharing((new Map<Id, User>(usrsToRecalculate)).keySet(), (new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(accountIds))).keySet());

            //Shares delete LeadShares to community users
            //DAOUtilityWithoutShar.deleteAllLeadRelatedSharing(usrsToRecalculate, LeadSharingUtility.allLeadsRelatedToAccounts(accountIds));
            
            //Shares delete ChildLeadShares to community users
            DAOUtilityWithoutShar.deleteAllChildLeadsRelatedSharing(usrsToRecalculate, ChildLeadSharingUtility.allLeadsRelatedToAccounts(accountIds));
            
            //Shares proper opportunities and cases to community users
            createSharingRecordsFuture(
                (new Map<Id, Opportunity>(OpportunitySharingUtility.allOpportunitiesRelatedToAccounts(accountIds))).keySet(), 
                (new Map<Id, Case>(CaseSharingUtility.allCasesRelatedToAccounts(accountIds))).keySet(),
                userMap.keySet(),
                (new Map<Id, Account>(AccountUtility.getAccountAllAccountsToShareWithCommunityUsers(userMap.values()))).keySet(),/*,
                conIdToRecalculateAddCountryRespContracts*/
                /*(new Map<Id, Lead>(LeadSharingUtility.allLeadsRelatedToAccounts(accountIds))).keySet()*/
                (new Map<Id, Child_Lead__c>(ChildLeadSharingUtility.allLeadsRelatedToAccounts(accountIds))).keySet()
            );
            
            if(createHelpDeskCaseForKPISharing) KPIsSharingRecalculationHelpDeskCase.createHelpDeskCase(userMap.values(), false);
            if(!usersToRecalculateKPISharing.isEmpty()){
                createKPISharingRecords(
                    usersToRecalculateKPISharing,
                    BusinessStrategySharingUtility.allBusinessStrategiesRelatedToAccounts(accountIds),
                    CommercialActivitySharingUtility.allCommercialActivitiesRelatedToAccounts(accountIds),
                    FCICustomerSupportSharingUtility.allFCICustomerSupportsRelatedToAccounts(accountIds),
                    ForecastAccuracySharingUtility.allForecastAccuraciesRelatedToAccounts(accountIds),
                    SalesFunnelSharingUtility.allSalesFunnelsRelatedToAccounts(accountIds),
                    AccountPlanSharingUtility.allAccountPlansRelatedToAccounts(accountIds)
                );
            }
        }
    }
    
    /* @Description

    Checks if re-calculation is required if any update is done on a community user record

    @param oldUser - Old user to compare (From Trigger.old)
    @param newUser - New user to compare (From Trigger.new)

    @return Boolean - True or false if the user sharing recalculaton is required
    */
    private static boolean isRecalculationRequired(User oldUser, User newUser){
        return (
                newUser.isActive == true && 
                (
                    oldUser.Community_User_Role__c != newUser.Community_User_Role__c ||
                    !String.isBlank(oldUser.Community_User_Role__c) && String.isBlank(newUser.Community_User_Role__c) ||
                    oldUser.isActive != newUser.isActive
                )
               );
    }

    /* @Description

    Checks & returns if user is a community user

    @param newUsers - New users list (Trigger.new)

    @return List<User> - List of community users to consider
    */
    private static List<User> getCommunityUsers(List<User> newUsers) {
        List<User> communityUsers = new List<User>(); //Users list to return

        for (User usr : newUsers){
            if (usr.IsPortalEnabled && usr.ContactId != null && usr.isActive){
                communityUsers.add(usr);
            }
        }

        return communityUsers;
    }

    /* @Description

    Gets all the AccountIds to Recalculate (H5 & H1) Ids

    @param communityUsers - Community users to consider

    @return Set<Id> - Set of account Ids related from those community users
    */
    public static Set<Id> getAccountIdsToCalculate(List<User> communityUsers){

        Set<Id> accountIds = new Set<Id>(); //Set of Account Ids from those community users
        for(User us : UserUtility.getAllSelectedCommunityUsers(communityUsers).values()){

            if(String.isNotBlank(us.Contact.AccountId)) accountIds.add(us.Contact.AccountId);
            if(String.isNotBlank(us.Contact.Parent_Account__c)) accountIds.add(us.Contact.Parent_Account__c);
        }

        return accountIds;
    }

    /* @Description

    Creates Sharing Records for Partner Users

    @param oppIds - Opportunity Ids to consider to recalculate sharing
    @param csIds - Case Ids to consider to recalculate sharing
    @param userIds - User Ids to consider to recalculate account sharing
    @param accountIds - Account Ids to consider to recalculate sharing

    @return void
    */
    @Future    
    public static void createSharingRecordsFuture(Set<Id> oppIds, Set<Id> csIds, Set<Id> userIds, Set<Id> accountIds,/*, Set<Id> conIds*/ /*Set<Id> leadIds*/ Set<Id> childLeadIds){

        AccountSharingUtility.createSharingForAccount(userIds, accountIds);
        //ContractSharingUtility.createAccountSharingForAdditionalCountryResponsabilityUsers(conIds);
        OpportunitySharingUtility.createOpportunitySharing(oppIds);
        CaseSharingUtility.createSharingForCase(csIds);
        //LeadSharingUtility.createSharingForLead(userIds, leadIds);
        ChildLeadSharingUtility.createSharingForLead(userIds, childLeadIds);
    }
    
    public static void createKPISharingRecords(List<User> usersToRecalculate, List<Business_Strategy__c> businessStrategyList, List<Commercial_Activity__c> commercialActivityList, List<FCI_Customer_Support__c> fciCustomerSupportList, List<Forecast_Accuracy__c> forecastAccuracyList, List<Sales_Funnel__c> salesFunnelList, List<Field_of_Play__c> accountPlanList){
        BusinessStrategySharingUtility.initiateBusinessStrategySharing(usersToRecalculate, businessStrategyList);
        CommercialActivitySharingUtility.initiateComActivitySharing(usersToRecalculate, commercialActivityList);
        FCICustomerSupportSharingUtility.initiateFCICustomerSupportSharing(usersToRecalculate, fciCustomerSupportList);
        ForecastAccuracySharingUtility.initiateForecastAccuracySharing(usersToRecalculate, forecastAccuracyList);
        SalesFunnelSharingUtility.initiateSalesFunnelSharing(usersToRecalculate, salesFunnelList);
        AccountPlanSharingUtility.initiateAccountPlanSharing(usersToRecalculate, accountPlanList);
    }
}