/**
 * Created by KJM on 03/07/2019..
 */

public without sharing class AccountContactsListController {

    @AuraEnabled
    public static MembersTableWrapper getTableData() {
        return new MembersTableWrapper();
    }

    private static final List<String> headerValues = new List<String>{
        	Constants.CUSTOMER_TEAM_HEADER_VALUE_BLANK,
            Constants.CUSTOMER_TEAM_HEADER_VALUE_NAME,
            Constants.CUSTOMER_TEAM_HEADER_VALUE_JOB_TITLE,
            Constants.CUSTOMER_TEAM_HEADER_VALUE_DEPARTMENT,
            Constants.CUSTOMER_TEAM_HEADER_VALUE_BUSINESS_SEGMENT,
            Constants.CUSTOMER_TEAM_HEADER_VALUE_EMAIL,
            Constants.CUSTOMER_TEAM_HEADER_VALUE_MOBILE
   };

    private static List<String> getHeaderValues() {
        if (UserUtility.isUserCommunityManagerRole()) {
            headerValues.add(Constants.CUSTOMER_TEAM_HEADER_VALUE_WORK_LOCATION);
        }

        if (CommunityUtility.getCurrentCommunityOptions().Show_chatter_button_on_my_Customer_team__c) {
            headerValues.add(Constants.CUSTOMER_TEAM_HEADER_VALUE_ACTION);
        }

        return headerValues;
    }

    private static List<List<String>> getTeamMembers() {
        if (UserUtility.isUserCommunityManagerRole()) {
            return getTeamMembersForManagerUser();
        }

        return getTeamMembersForStandardUser();
    }

    private static List<List<String>> getTeamMembersForStandardUser() {
        List<Contact> accContacts = [
            SELECT PhotoUrl, Name, Job_Title__c, Department__c, Operating_Company__c, email, phone, business_segment__c
            FROM Contact
            WHERE AccountId = :UserUtility.getCurrentUserContact().AccountId and Active__c = true
        ];
		
        List<List<String>> contactsWrapperList = new List<List<String>>();
        for (Contact cont : accContacts) {
            if (cont.Name == UserUtility.getCurrentUserContact().Name) {
                continue;
            }

            contactsWrapperList.add(getDataRow(cont));
        }
		
        return contactsWrapperList;
    }

    private static List<List<String>> getTeamMembersForManagerUser() {
        List<Contact> accContacts = [
            SELECT PhotoUrl, Name, Account.Name, Job_Title__c, Department__c, Operating_Company__c, email, phone, business_segment__c
            FROM Contact
            WHERE AccountId IN :AccountUtility.getAllChildAccounts(UserUtility.getCurrentUserContact().Parent_Account__c) and Active__c = true
            ORDER BY Account.Name ASC
        ];

        Map<String, List<Contact>> contactsMap = new Map<String, List<Contact>>();
        for (Contact cont : accContacts) {
            if (!contactsMap.containsKey(cont.Account.Name)) {
                contactsMap.put(cont.Account.Name, new List<Contact>());
            }

            contactsMap.get(cont.Account.Name).add(cont);
        }

        List<List<String>> contactsWrapperList = new List<List<String>>();
        for (String workLocationName : contactsMap.keySet()) {
            for (Contact cont : contactsMap.get(workLocationName)) {
                if (cont.Name == UserUtility.getCurrentUserContact().Name) {
                    continue;
                }

                List<String> rowData = getDataRow(cont);
                rowData.add(cont.Account.Name);

                contactsWrapperList.add(rowData);
            }
        }

        return contactsWrapperList;
    }

    private static List<String> getDataRow(Contact cont) {
        return new List<String>{
            Utilities.returnValueOrEmpty(cont.PhotoUrl),
            Utilities.returnValueOrEmpty(cont.Name),
            Utilities.returnValueOrEmpty(cont.Job_Title__c),
            Utilities.returnValueOrEmpty(cont.Department__c),
            Utilities.returnValueOrEmpty(cont.business_segment__c),
            Utilities.returnValueOrEmpty(cont.email),
            Utilities.returnValueOrEmpty(cont.phone)
        };
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