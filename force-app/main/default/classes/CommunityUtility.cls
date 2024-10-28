/**
 * Created by KJM on 20/05/2019.
 */

public with sharing class CommunityUtility {

    private static String communityName;
    private static String communityUrl;
    @testVisible private static Community_Setting__mdt communityOptionsInstance;

    public static String getCurrentCommunityName() {
        if (communityName == null) {
            communityName =
                Test.isRunningTest() ?
                Constants.TEST_COMMUNITY_FAKE_NAME :
                ConnectApi.Communities.getCommunity(Network.getNetworkId()).name;
        }
        system.debug('communityName 18 line--> '+communityName);
        if (communityName == 'FC Distributor Community'){
            communityName = 'FCI Distributor Community';
        } if (communityName == 'FC Customer Community'){
            communityName = 'FCI Customer Community';
        }
        system.debug('communityName '+communityName);
        return communityName;
    }

    public static String getCurrentCommunityUrl() {
        if (communityUrl == null) {
            communityUrl =
                Test.isRunningTest() ?
                Constants.TEST_COMMUNITY_FAKE_URL :
                ConnectApi.Communities.getCommunity(Network.getNetworkId()).siteUrl;
        }

        return communityUrl;
    }

    public static List<String> getAccountTeamRoles() {
        return getCurrentCommunityOptions().Account_team_roles_to_get__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR);
    }

    public static Community_Setting__mdt getCurrentCommunityOptions() {
        String currentCommunityName = getCurrentCommunityName();

        if (communityOptionsInstance == null) {
            communityOptionsInstance = [
                SELECT DeveloperName,
                        Community_name__c,
                        Community_url__c,
                        Show_relations_on_certificate_article__c,
                        Show_relations_on_articles__c,
                        Show_relations_in_both_sides__c,
                        Default_child_tiles_display_option__c,
                        Account_team_roles_to_get__c,
                        Show_chatter_button_on_my_FCI_team__c,
                        Show_chatter_button_on_my_Customer_team__c,
                        Show_contact_details_on_my_FCI_team__c
                FROM Community_Setting__mdt
                WHERE Community_Name__c = :currentCommunityName
            ];
        }

        return communityOptionsInstance;
    }
}