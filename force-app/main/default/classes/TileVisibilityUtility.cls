/**
 * Created by KJM on 20/05/2019.
 */

public with sharing class TileVisibilityUtility {

    public static String getVisibilityCriteria(String fieldPreFix) {
        
        //List to store the profile ids for which the tile visibility criteria needs to be bypassed
        List<Id> byPassedProfileIds = System.Label.ByPass_Tile_Visibility_Criteria.trim().split(',');
        
        if (!UserUtility.isCurrentUserPartnerUser() || byPassedProfileIds?.contains(UserInfo.getProfileId())) {
            return getCommunityNameQuery(fieldPreFix);
        }

        return buildCommunityUserCriteriaQuery(fieldPreFix);
    }

    private static String buildCommunityUserCriteriaQuery(String fieldPreFix) {
        Map<String, List<String>> mapINCLUDEQuery = new Map<String, List<String>>();
        Map<String, List<String>> mapINQuery = new Map<String, List<String>>();
        Map<String, List<String>> mapNOTEMPTYQuery = new Map<String, List<String>>();

        addCommunityCriteriaQuery(mapNOTEMPTYQuery, fieldPreFix);
        addBusinessSegmentCriteriaToMap(mapINCLUDEQuery, fieldPreFix);
        if(UserUtility.getCurrentUser().Community_Account_Role__c.equals(Constants.USER_COMMUNITY_ACCOUNT_ROLE_SUB_SEGMENT) ||
            UserUtility.getCurrentUser().Community_Account_Role__c.equals(Constants.USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION)){
            addSubSegmentCriteriaToMap(mapINCLUDEQuery, fieldPreFix);   
        }

        addRegionCriteriaToMap(mapINCLUDEQuery, fieldPreFix);

        /*if(UserUtility.getCurrentUser().Community_Account_Role__c.equals(Constants.USER_COMMUNITY_ACCOUNT_ROLE_APPLICATION)){
            addApplicationCriteriaToMap(mapINCLUDEQuery, fieldPreFix);  
        }*/
        
        addWorkLocationCriteriaToMap(mapINQuery, fieldPreFix);

        if(!UserUtility.getCurrentUser().Contact.Account.RecordType.DeveloperName.equals(Constants.ACCOUNT_RECORD_TYPE_DEVELOPERNAME_AGENT)){
            addCommercialCustomerCriteriaToMap(mapINQuery, fieldPreFix);
        }
        

        return QueryUtility.buildMultiSelectCondition(mapNOTEMPTYQuery, false) + Constants.QUERY_AND +
               QueryUtility.buildMultiSelectINCLUDEConditionWithEmptyCondition(mapINCLUDEQuery, false) + Constants.QUERY_AND +
               QueryUtility.buildMultiSelectINConditionWithEmptyCondition(mapINQuery, false);
    }

    private static String getCommunityNameQuery(String fieldPreFix) {
        Map<String, List<String>> mapToBuildQuery = new Map<String, List<String>>();
        addCommunityCriteriaQuery(mapToBuildQuery, fieldPreFix);
        return QueryUtility.buildMultiSelectCondition(mapToBuildQuery, false);
    }

    private static void addCommunityCriteriaQuery(Map<String, List<String>> mapToBuildQuery , String fieldPreFix) {
        String communityName = buildFieldName(Constants.TILE_FIELD_COMMUNITY_NAME, fieldPreFix);
        mapToBuildQuery.put(communityName, new List<String>{CommunityUtility.getCurrentCommunityName()});
    }

    private static void addBusinessSegmentCriteriaToMap(Map<String, List<String>> mapToBuildQuery , String fieldPreFix) {
        String businessSegment = buildFieldName(Constants.TILE_FIELD_BUSINESS_SEGMENT, fieldPreFix);
        mapToBuildQuery.put(businessSegment, UserUtility.getCurrentUserBusinessSegment());
    }

    private static void addSubSegmentCriteriaToMap(Map<String, List<String>> mapToBuildQuery , String fieldPreFix) {
        String subSegment = buildFieldName(Constants.TILE_FIELD_SUB_SEGMENT, fieldPreFix);
        mapToBuildQuery.put(subSegment, UserUtility.getCurrentUserSubSegment());
    }

    private static void addRegionCriteriaToMap(Map<String, List<String>> mapToBuildQuery , String fieldPreFix) {
        String salesRegion = buildFieldName(Constants.TILE_FIELD_SALES_REGION, fieldPreFix);
        mapToBuildQuery.put(salesRegion, UserUtility.getCurrentUserRegion());
    }

    /*private static void addApplicationCriteriaToMap(Map<String, List<String>> mapToBuildQuery , String fieldPreFix) {
        String application = buildFieldName(Constants.TILE_FIELD_APPLICATION, fieldPreFix);
        mapToBuildQuery.put(application, UserUtility.getCurrentUserApplication());
    }*/

    private static void addWorkLocationCriteriaToMap(Map<String, List<String>> mapToBuildQuery , String fieldPreFix) {
        String workLocation = buildFieldName(Constants.TILE_FIELD_WORK_LOCATION, fieldPreFix);
        if (UserUtility.isUserCommunityManagerRole()) {
            List<String> customerLocations = new List<String>();

            for (Id customLocId :  UserUtility.getMUCommercialCustomerHierarchyWrapper( new List<User>{ UserUtility.getCurrentUser() } ).get(UserUtility.getCurrentUser().Id).customerLocationsIds) {
                customerLocations.add((String)customLocId);
            }

            mapToBuildQuery.put(workLocation, customerLocations);
        } else {
            //mapToBuildQuery.put(workLocation, new List<String> {UserUtility.getCurrentUser().Contact.Work_Location__c});
            mapToBuildQuery.put(workLocation, new List<String> {UserUtility.getCurrentUser().Contact.AccountId});
        }
    }

    private static void addCommercialCustomerCriteriaToMap(Map<String, List<String>> mapToBuildQuery , String fieldPreFix){
        
        String commercialCustomer = buildFieldName(Constants.TILE_FIELD_COMMERCIAL_CUSTOMER, fieldPreFix);
        mapToBuildQuery.put(commercialCustomer, new List<String> {UserUtility.getCurrentUser().Contact.Parent_Account__c});
    }

    private static String buildFieldName(String fieldName, String fieldPreFix) {
        return fieldPreFix + fieldName;
    }

    //Added as per JIRA Ticket - 3834
    public static String getAccountCriteriaQuery(String tileName){
		system.debug('inside');
        String accountQuery = '';
        Map<String, List<String>> mapNOTINQuery = new Map<String, List<String>>();
		
        User currentCommunityUser = UserUtility.getCurrentUser();
        List<Tile__c> accountCriteriaTiles = getAccountCriteriaTiles( tileName, currentCommunityUser );
        
        if(!accountCriteriaTiles.isEmpty() 
        && !String.isEmpty(currentCommunityUser.ContactId)) {

            addTilesINMap(mapNOTINQuery, Constants.EMPTY_STRING, getTilesToExcludeBasedOnAccountCriteria(accountCriteriaTiles));

            if(mapNOTINQuery.isEmpty()) return '';

            accountQuery += ' ( ';
            
            return ' ( ' + 
                (!mapNOTINQuery.isEmpty() ? QueryUtility.buildINCondition(mapNOTINQuery, false, true) : '') + 
                //(!mapINQuery.isEmpty() ? Constants.QUERY_OR + QueryUtility.buildINCondition(mapINQuery, false, false) : '') + 
                ' ) ';
        }

        return '';

    }

    private static void addTilesINMap(Map<String, List<String>> mapToBuildQuery , String fieldPreFix, Set<Id> tileIds){

        if(tileIds.isEmpty()) return;

        String tileIdVal = buildFieldName('Id', fieldPreFix);
        List<String> tileIdToevaluate = new List<String>();

        for( Id eachTileId : tileIds ) {

            tileIdToevaluate.add( eachTileId );
        }

        mapToBuildQuery.put( tileIdVal , tileIdToevaluate );
    }

    public static List<Tile__c> getAccountCriteriaTiles( String parentTileInfo, User currentCommunityUser ){

        String query = ' SELECT Tile_Related__c, Parent_Account__c, Work_Location__c, Sharing_criteria__c ' +
                        'FROM Tile__c ';

        Boolean isParentTileInfoisId = Pattern.compile( '[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}' ).matcher( parentTileInfo ).matches();

        if(isParentTileInfoisId) query += ' WHERE Tile_Related__r.Parent_Tile__c = ';
        else query += ' WHERE Tile_Related__r.Parent_Tile__r.Name = ';

        query += '\'' + parentTileInfo + '\'';
        query += Constants.QUERY_AND + ' Tile_Related__c != null ';
        query += Constants.QUERY_AND + ' Tile_Related__r.Article_Name__c = null ';
        query += Constants.QUERY_AND + ' Tile_Related__r.Work_Location__c = null ';
        query += Constants.QUERY_AND + ' Tile_Related__r.Parent_Account__c = null ';
        query += Constants.QUERY_AND + ' ( Work_Location__c != null OR Parent_Account__c != null ) ';
		System.debug('query'+Database.query(query));
        return (List<Tile__c>)Database.query(query);
    }

    public static Set<Id> getTilesToExcludeBasedOnAccountCriteria(List<Tile__c> accountCriteriaTiles){
        System.debug('accountCriteriaTiles'+accountCriteriaTiles);
        Contact currContact = UserUtility.getCurrentUserContact();

        Set<Id> tilesToExclude = new Set<Id>();

        for( Tile__c eachTileToConsider : accountCriteriaTiles ){
				System.debug('Count'+eachTileToConsider);
            if( eachTileToConsider.Sharing_criteria__c.equals( Constants.TILE_ACCOUNT_CRITERIA_DO_NOT_SHARE_WITH ) ){
                
                if( (!String.isBlank( eachTileToConsider.Work_Location__c ) && eachTileToConsider.Work_Location__c.equals( currContact.AccountId )) ||
                (!String.isBlank( eachTileToConsider.Parent_Account__c ) && eachTileToConsider.Parent_Account__c.equals( currContact.Parent_Account__c )) )

                tilesToExclude.add(eachTileToConsider.Tile_Related__c);

                continue;
            }

            if( eachTileToConsider.Sharing_criteria__c.equals( Constants.TILE_ACCOUNT_CRITERIA_SHARE_WITH ) ){
                
				System.debug('eachTileToConsider'+eachTileToConsider);                
                if( (
                    
                        ( !String.isBlank( eachTileToConsider.Work_Location__c ) && !eachTileToConsider.Work_Location__c.equals( currContact.AccountId )) ||
                        ( !String.isBlank( eachTileToConsider.Parent_Account__c ) && !eachTileToConsider.Parent_Account__c.equals( currContact.Parent_Account__c )) 
                    )
                  )
                      
                      tilesToExclude.add( eachTileToConsider.Tile_Related__c ); 
                      
                  
                
                
                 

                else if( (
                        ( !String.isBlank( eachTileToConsider.Work_Location__c ) && eachTileToConsider.Work_Location__c.equals( currContact.AccountId )) ||
                        ( !String.isBlank( eachTileToConsider.Parent_Account__c ) && eachTileToConsider.Parent_Account__c.equals( currContact.Parent_Account__c )) 
                    ) && tilesToExclude.contains( eachTileToConsider.Tile_Related__c )
                       ) 
                           tilesToExclude.remove( eachTileToConsider.Tile_Related__c );
                           
                       
                
                tilesToExclude.remove( eachTileToConsider.Tile_Related__c );
            }
        }
		System.debug('tilesToExclude'+tilesToExclude);
        return tilesToExclude;
        
    }

}