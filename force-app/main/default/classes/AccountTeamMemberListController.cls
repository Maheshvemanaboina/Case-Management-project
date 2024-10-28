/**
 * Created by KJM on 17/04/2019.
 *******************************
 * Modified By 		: Mahendra Kumar
 * Modified Date	: 08-08-2022
 * Changes			: Modified logic to display Account Team Members (reading from the custom account team object) in both FCI Distributor and Customer communities
 */

public without sharing class AccountTeamMemberListController {

    @AuraEnabled
    public static MembersTableWrapper getTableData() {
        return new MembersTableWrapper();
    }

    private static final List<String> HEADER_VALUES = new List<String>{
        Constants.ACCOUNT_TEAM_HEADER_VALUE_BLANK,
        Constants.ACCOUNT_TEAM_HEADER_VALUE_NAME//,
        //Constants.ACCOUNT_TEAM_HEADER_VALUE_TITLE
    };

    private static List<String> getHeaderValues() {
        if (CommunityUtility.getCurrentCommunityOptions().Show_contact_details_on_my_FCI_team__c) {
            HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_EMAIL);
            HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_MOBILE);
            //added
            HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_OUT_OF_OFFICE);
        } else {
            HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_TEAM_ROLE);
            HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_BUSINESS_SEGMENT);
            //HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_ABOUT_ME);
        }

        if (UserUtility.isUserCommunityManagerRole()) {
            HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_WORK_LOCATION);
        }

        if (CommunityUtility.getCurrentCommunityOptions().Show_chatter_button_on_my_FCI_team__c) {
            HEADER_VALUES.add(Constants.ACCOUNT_TEAM_HEADER_VALUE_ACTION);
        }

        return HEADER_VALUES;
    }

    private static List<List<String>> getTeamMembers() {
        if (UserUtility.isUserCommunityManagerRole()) {
            return getTeamMembersForManagerUser();
        }

        return getTeamMembersForStandardUser();
    }
    
    //Get the Business Segments from the associated contact of the logged in Distributor User
    private static final List<String> DISTRIBUTOR_BUSINESS_SEGMENTS = String.isNotBlank(
        UserUtility.getCurrentUserContact().Business_Segment__c
    ) ? UserUtility.getCurrentUserContact().Business_Segment__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR) : new List<String>();

    private static List<List<String>> getTeamMembersForStandardUser() {
        List<String> teamRolesToGet = CommunityUtility.getAccountTeamRoles();

        //Set to store the account team members if added twice with same role and different business segment
        Set<String> accountTeamMemberWithSameRoleSet = new Set<String>();        
        
        List<Account_Team__c> accountTeamMembers = [
            SELECT Team_Member__r.Name, /*Team_Member__r.AboutMe,*/ Team_Member__c, Source_Account__c, Team_Member__r.SmallPhotoUrl, /*Team_Member__r.Title,*/ Team_Role__c,Team_Member__r.Email,Team_Member__r.MobilePhone,Primary__c,Business_Segment__c
            FROM Account_Team__c
            WHERE Source_Account__c = :UserUtility.getCurrentUserContact().AccountId
            AND Team_Role__c IN :teamRolesToGet AND Business_Segment__c IN :DISTRIBUTOR_BUSINESS_SEGMENTS order by Team_Member__r.Name
        ];
        
        Set<Id> accountTeamMembersIdsSet = new Set<Id>(); //set to store the userids of account team members
        Map<String, List<String>> accountTeamMembersWithBusinessSegmentsMap = new Map<String, List<String>>(); //Map to store the account team members with same role and different business segments
        getAccountTeamMembersIdsAndBusinessSegments(accountTeamMembersIdsSet, accountTeamMembersWithBusinessSegmentsMap, accountTeamMembers);
        
        //added
        Map<Id,OutOfOffice> outOfOfficeMap = getOutOfOfficeMap(accountTeamMembersIdsSet);

        List<List<String>> accTeamsWrapperList = new List<List<String>>();
        for (Account_Team__c accTeamMem : accountTeamMembers) {
            if(!accountTeamMemberWithSameRoleSet.contains(accTeamMem.Source_Account__c + '-' + accTeamMem.Team_Member__c + '-' + accTeamMem.Team_Role__c + '-' + accTeamMem.Primary__c)){
                accTeamsWrapperList.add(getDataRowOverLoaded(accTeamMem,outOfOfficeMap.get(accTeamMem.Team_Member__c),accountTeamMembersWithBusinessSegmentsMap));
            }
            accountTeamMemberWithSameRoleSet.add(accTeamMem.Source_Account__c + '-' + accTeamMem.Team_Member__c + '-' + accTeamMem.Team_Role__c + '-' + accTeamMem.Primary__c);
        }

        return accTeamsWrapperList;
    }

    private static List<List<String>> getTeamMembersForManagerUser() {
        List<String> teamRolesToGet = CommunityUtility.getAccountTeamRoles();
		Set<String> accountTeamMemberWithSameRoleSet = new Set<String>();        
        
        List<Account_Team__c> accountTeamMembers = [
            SELECT Source_Account__r.Name, Team_Member__r.Name, /*Team_Member__r.AboutMe,*/ Source_Account__c, Team_Member__r.SmallPhotoUrl, /*Team_Member__r.Title,*/ Team_Role__c, Team_Member__r.Email, Team_Member__r.MobilePhone,Primary__c,Business_Segment__c
            FROM Account_Team__c
            WHERE Source_Account__c IN :AccountUtility.getAllChildAccounts(UserUtility.getCurrentUserContact().Parent_Account__c)
            AND Team_Role__c IN :teamRolesToGet AND Business_Segment__c IN :DISTRIBUTOR_BUSINESS_SEGMENTS
            ORDER BY Source_Account__r.Name ASC
        ];
        
        Set<Id> accountTeamMembersIdsSet = new Set<Id>();
        Map<String, List<String>> accountTeamMembersWithBusinessSegmentsMap = new Map<String, List<String>>();
        getAccountTeamMembersIdsAndBusinessSegments(accountTeamMembersIdsSet, accountTeamMembersWithBusinessSegmentsMap, accountTeamMembers);
        
        //added
        Map<Id,OutOfOffice> outOfOfficeMap = getOutOfOfficeMap(accountTeamMembersIdsSet);

        Map<String, List<Account_Team__c>> accountTeamMap = new Map<String, List<Account_Team__c>>();
        for (Account_Team__c accTeam : accountTeamMembers) {
            if (!accountTeamMap.containsKey(accTeam.Source_Account__r.Name)) {
                accountTeamMap.put(accTeam.Source_Account__r.Name, new List<Account_Team__c>());
            }

            accountTeamMap.get(accTeam.Source_Account__r.Name).add(accTeam);
        }

        List<List<String>> accTeamsWrapperList = new List<List<String>>();
        for (String accName : accountTeamMap.keySet()) {
            for (Account_Team__c teamMember : accountTeamMap.get(accName)) {
                if (teamMember.Team_Member__r.Name.equals(Constants.API_USER)) {
                    continue;
                }
                
                if(!accountTeamMemberWithSameRoleSet.contains(teamMember.Source_Account__c + '-' + teamMember.Team_Member__c + '-' + teamMember.Team_Role__c + '-' + teamMember.Primary__c)){
                    List<String> rowData = getDataRowOverLoaded(
                        teamMember,
                        outOfOfficeMap.get(teamMember.Team_Member__c),
                        accountTeamMembersWithBusinessSegmentsMap
                    );
                    rowData.add(accName);
                    accTeamsWrapperList.add(rowData);
                }
                accountTeamMemberWithSameRoleSet.add(teamMember.Source_Account__c + '-' + teamMember.Team_Member__c + '-' + teamMember.Team_Role__c + '-' + teamMember.Primary__c);
            }
		}
        /*List<List<String>> accTeamsWrapperList = new List<List<String>>();
        for (AccountTeamMember accTeamMem : accountTeamMembers) {
            if (accTeamMem.User.Name.equals(Constants.API_USER)) {
                continue;
            }
            List<String> rowData = getDataRowOverLoaded(accTeamMem,OutOfOfficeMap.get(accTeamMem.UserId));
            rowData.add(accTeamMem.Account.Name);
            accTeamsWrapperList.add(rowData);
        }*/
        return accTeamsWrapperList;
    }

    /*private static List<String> getDataRow(AccountTeamMember accTeamMem) {
        List<String> row = new List<String>();

        row.add(Utilities.returnValueOrEmpty(accTeamMem.PhotoUrl));
        row.add(Utilities.returnValueOrEmpty(accTeamMem.User.Name));
        row.add(Utilities.returnValueOrEmpty(accTeamMem.Title));

        if (CommunityUtility.getCurrentCommunityOptions().Show_contact_details_on_my_FCI_team__c) {
            row.add(Utilities.returnValueOrEmpty(accTeamMem.User.Email));
            row.add(Utilities.returnValueOrEmpty(accTeamMem.User.MobilePhone));
        } else {
            row.add(Utilities.returnValueOrEmpty(accTeamMem.TeamMemberRole));
            row.add(Utilities.returnValueOrEmpty(accTeamMem.User.AboutMe));
        }

        return row;
    }*/
    
    private static List<String> getDataRowOverLoaded(Account_Team__c accTeamMem,OutOfOffice ooo,Map<String, List<String>> accTeamsWithBusinessSegmentsMap) {
        String accountIdAccountTeamMemIdTeamRole = accTeamMem.Source_Account__c+'-'+accTeamMem.Team_Member__c+'-'+accTeamMem.Team_Role__c+'-'+accTeamMem.Primary__c;
        List<String> matchedBusinessSegments = getMatchedBusinessSegmentsOfAccTeamMemAndContact(
            accTeamsWithBusinessSegmentsMap.get(accountIdAccountTeamMemIdTeamRole),
            DISTRIBUTOR_BUSINESS_SEGMENTS
        );
        
        Boolean isAccountTeamMemberWithMultipleBusinessSegments = (
            accTeamsWithBusinessSegmentsMap.containsKey(accountIdAccountTeamMemIdTeamRole) &&
            accTeamsWithBusinessSegmentsMap.get(accountIdAccountTeamMemIdTeamRole) != null &&
            accTeamsWithBusinessSegmentsMap.get(accountIdAccountTeamMemIdTeamRole).size() > 1 &&
            matchedBusinessSegments.size() > 1
        ) ? true : false;
        
        List<String> row = new List<String>();
		//String accTeamPrimary = ;
        row.add(Utilities.returnValueOrEmpty(accTeamMem.Team_Member__r.SmallPhotoUrl.trim().split('.com')[1]));
        //row.add(Utilities.returnValueOrEmpty(accTeamMem.User.Name));
        row.add(/*accTeamMem.Primary__c ? Utilities.returnValueOrEmpty(accTeamMem.Team_Member__r.Name) + ' ( Primary )' :*/ Utilities.returnValueOrEmpty(accTeamMem.Team_Member__r.Name));
        //row.add(Utilities.returnValueOrEmpty(accTeamMem.Team_Member__r.Title));

        if (CommunityUtility.getCurrentCommunityOptions().Show_contact_details_on_my_FCI_team__c) {
            row.add(Utilities.returnValueOrEmpty(accTeamMem.Team_Member__r.Email));
            row.add(Utilities.returnValueOrEmpty(accTeamMem.Team_Member__r.MobilePhone));
            //added
            if(ooo != null && ooo.IsEnabled && ooo.Message != null && !String.isBlank(ooo.Message)){
                row.add('action:close');
            }
            else{
                row.add('action:approval');
            }
        } else {
            row.add(Utilities.returnValueOrEmpty(accTeamMem.Team_Role__c));
            row.add(
                isAccountTeamMemberWithMultipleBusinessSegments ?
                String.join(matchedBusinessSegments, Constants.SALESFORCE_PICKLIST_SEPARATOR).replace(';', '; ') :
                Utilities.returnValueOrEmpty(accTeamMem.Business_Segment__c)
            );
            //row.add(Utilities.returnValueOrEmpty(accTeamMem.Team_Member__r.AboutMe));
        }

        return row;
    }
    
    public static Map<Id,OutOfOffice> getOutOfOfficeMap(Set<Id> accountTeamMembersIds){
        Map<Id,OutOfOffice> outOfOfficeMap = new Map<Id,OutOfOffice>();
        for(OutOfOffice ooo : [SELECT Id,EndDate,IsEnabled,Message,StartDate,UserId 
                               FROM OutOfOffice WHERE UserId IN: accountTeamMembersIds])
        {
            outOfOfficeMap.put(ooo.UserId,ooo);     
        }
        return outOfOfficeMap;
    }
    
    /*
     * Method Name						:	getAccountTeamMembersIdsAndBusinessSegments
     * Written By						:	Mahendra
     * JIRA #							:	ENH-5002
     * @Description						:	Loop through the list of account team members to collect the user ids and add to a set
     * @PARAM accountTeamMembersIdsSet	:	Set of user ids who are added in the account teams
     * @PARAM accountTeamMembersWithBusinessSegmentsMap : Map of Account Team members having same role and multiple business segments
     * @PARAM accountTeamMembers		:	List of the account team members from which we need to prepare the user ids set
	*/
    private static void getAccountTeamMembersIdsAndBusinessSegments(Set<Id> accountTeamMembersIdsSet, Map<String, List<String>> accountTeamMembersWithBusinessSegmentsMap, List<Account_Team__c> accountTeamMembers){
        String accountIdAccTeamMemIdTeamRole = '';
        for(Account_Team__c accountTeamMember : accountTeamMembers){
            accountTeamMembersIdsSet.add(accountTeamMember.Team_Member__c);
            accountIdAccTeamMemIdTeamRole = accountTeamMember.Source_Account__c + '-' + accountTeamMember.Team_Member__c + '-' + accountTeamMember.Team_Role__c + '-' + accountTeamMember.Primary__c;
            if(!accountTeamMembersWithBusinessSegmentsMap.containsKey(accountIdAccTeamMemIdTeamRole)){
                accountTeamMembersWithBusinessSegmentsMap.put(accountIdAccTeamMemIdTeamRole, new List<String>{accountTeamMember.Business_Segment__c});
            }else{
                accountTeamMembersWithBusinessSegmentsMap.get(accountIdAccTeamMemIdTeamRole).add(accountTeamMember.Business_Segment__c);
            }
        }
    }
    
    /*
     * Method Name						:	getMatchedBusinessSegmentsOfAccTeamMemAndContact
     * Written By						:	Mahendra
     * JIRA #							:	ENH-5002
     * @Description						:	Loop through the list of account team members to collect the user ids and add to a set
     * @PARAM accTeamBusinessSegments	:	Multiple business segments of the same user of same role in the account team
     * @PARAM contactBusinessSegments	:	Business segments of the logged in community user's associated contact
	*/
    private static List<String> getMatchedBusinessSegmentsOfAccTeamMemAndContact(List<String> accTeamBusinessSegments, List<String> contactBusinessSegments){
        List<String> businessSegmentsToDisplay = new List<String>();
        if(accTeamBusinessSegments != null && contactBusinessSegments != null){
            for(String businessSegment : contactBusinessSegments){
                if(accTeamBusinessSegments.contains(businessSegment)){
                    businessSegmentsToDisplay.add(businessSegment);
                }
            }
        }
        businessSegmentsToDisplay.sort();
        return businessSegmentsToDisplay;
    }

    public class MembersTableWrapper {
        @AuraEnabled public List<String> headerValues { get; private set; }
        @AuraEnabled public List<List<String>> bodyValues { get; private set; }
        @AuraEnabled public Boolean showChatterMessageButton { get; private set; }

        public MembersTableWrapper() {
            this.headerValues = getHeaderValues();
            this.bodyValues = getTeamMembers();
            this.showChatterMessageButton = CommunityUtility.getCurrentCommunityOptions().Show_chatter_button_on_my_FCI_team__c;
        }
    }
}