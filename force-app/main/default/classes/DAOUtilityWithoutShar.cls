/**
 * Created by KJM on 10/04/2019.
 */

public without sharing class DAOUtilityWithoutShar {

    public static List<Database.UpsertResult> dynamicUpsert(List<SObject> records, String sObjectType)
    {
        String listType = 'List<' + sObjectType + '>';
        List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        castRecords.addAll(records);

        return Database.upsert(castRecords, true);
    }

    public static List<Opportunity> getAllOpportunitiesByNameForDuplicates(Set<String> oppsNames, Id commercialCustomerId) {
        return [SELECT Id, Name FROM Opportunity WHERE Name IN :oppsNames AND Parent_Account__c = :commercialCustomerId];
    }

    public static List<Account> getAllAccountsByNameForDuplicates(Set<String> accNames, Id recTypeId) {
        return [SELECT Id, Name, Distributor_Location__r.Name, BillingCountry, BillingStreet, BillingPostalCode, BillingCity FROM Account WHERE Name IN :accNames AND RecordTypeId = :recTypeId];
    }

    public static List<Account> getAllAccountsByName(Set<String> accNames, Id recordTypeId) {
        String customerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        if(recordTypeId == customerLocationRecordTypeId ){
            
            return [SELECT Id, Name, Distributor_Location__c, Distributor__c FROM Account WHERE Name IN :accNames AND RecordTypeId = :recordTypeId AND Active__c = true AND Partner_Role__c = 'Sold-to'];
        }
        return [SELECT Id, Name, Distributor_Location__c, Distributor__c FROM Account WHERE Name IN :accNames AND RecordTypeId = :recordTypeId AND Active__c = true];
    }

    public static List<OpportunityLineItem> getAllOppItemsByOppNameForDuplicates(Set<String> oppsNames) {
        return [SELECT Id, Name, Opportunity.Name, Product2.Name FROM OpportunityLineItem WHERE Opportunity.Name IN :oppsNames];
    }

    public static List<SObject> getSObjects(String fromObj, List<String> nameValues) {
        return Database.query('SELECT Id, Name FROM '+ fromObj + ' WHERE Name IN :nameValues');
    }

    //added for Email Match
    public static List<SObject> getSObjectsEmailMatch(String fromObj, List<String> emailValues) {
        return Database.query('SELECT Id, Name, Email FROM '+ fromObj + ' WHERE Email IN :emailValues');
    }

    //added for Commerical H1 match
    public static List<sObject> getH1andH5SObjects(String fromObj, List<String> nameValues,Id H1andH5RecordTypeId){
        String customerLocationRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Customer_Location').getRecordTypeId();
        if(H1andH5RecordTypeId == customerLocationRecordTypeId ){
            String partnerRole = 'Sold-to';            
            return Database.query('SELECT Id, Name FROM '+ fromObj + ' WHERE Name IN :nameValues AND RecordTypeId = :H1andH5RecordTypeId AND Partner_Role__c = :partnerRole ');
        }         
        return Database.query('SELECT Id, Name FROM '+ fromObj + ' WHERE Name IN :nameValues AND RecordTypeId = :H1andH5RecordTypeId');
    }

    public static Case getCaseForSurvey(String caseId) {
        List<Case> css = [
            SELECT Id, CaseNumber, ContactId, ContactEmail, Contact.Survey_Sent_Date_Time__c, Contact.Survey_Sent__c, Contact.Name
            FROM Case
            WHERE ContactId != null AND Id = :caseId
        ];

        if (css.isEmpty()){
            return null;
        }

        return css.get(0);
    }

    public static void updateContactFromSurvey(Case cs) {
        Contact con = [
            SELECT Id, Survey_Sent_Date_Time__c, Survey_Sent__c
            FROM Contact
            WHERE Id = :cs.ContactId
        ];

        con.Survey_Sent_Date_Time__c = System.now();
        con.Survey_Sent__c = true;

        update con;
    }
	
    public static void insertWithoutAccess(List<SObject> obbjs) {
        
        insert obbjs;
        system.debug('obbjs'+obbjs);
    }

    public static void updateWithoutAccess(List<SObject> obbjs) {
        update obbjs;
    }

    public static void deleteWithoutAccess(List<SObject> obbjs) {
        delete obbjs;
    }

    public static List<User> getUsersForSharing(Set<Id> usersIds) {
        //return [SELECT Id, Location__c,Location__r.BillingCountry, AccountId, OwnerId, CreatedById FROM Opportunity WHERE Id IN :oppIds];
        return [SELECT Id, Contact.Parent_Account__r.Name, UserName, Contact.Name, Contact.Account.Name, Contact.Additional_Country_Responsibility__c, Contact.Business_Segment__c, Contact.Sub_Segment__c,
         Contact.Exclude_Customer_Location_Country__c, Community_Account_Role__c, Contact.Parent_Account__c, Contact.Account.BillingCountry, Contact.AccountId, Community_User_Role__c, IsPortalEnabled FROM User WHERE Id IN :usersIds];
    }

    public static List<Opportunity> getOpportunitiesForSharing(Set<Id> oppIds) {
        //return [SELECT Id, Location__c,Location__r.BillingCountry, AccountId, OwnerId, CreatedById FROM Opportunity WHERE Id IN :oppIds];
        return [SELECT Id, AccountId, Account.BillingCountry, Parent_Account__c, OwnerId FROM Opportunity WHERE Id IN: oppIds];
    }

    public static List<Opportunity> getOpenOpportunitiesForSharingByAccountIdOwnerId(Set<Id> accIds, Set<Id> ownerIds) {
        return [SELECT Id, AccountId, OwnerId FROM Opportunity WHERE isClosed = false AND AccountId IN: accIds AND OwnerId IN: ownerIds AND RecordTypeId = :Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID];
    }
    
    public static List<Lead> getLeadForSharing(Set<Id> ledIds) {
        return [SELECT Id, Distributor__c,Distributor_Location__c,OwnerId,Distributor_Location__r.BillingCountry, CreatedById FROM Lead WHERE Id IN :ledIds];
    }

    public static List<Case> getCasesForSharing(Set<Id> casesIds) {
        //return [SELECT Id, Sold_to_Location__c, AccountId,Sold_to_Location__r.BillingCountry, OwnerId FROM Case WHERE Id IN :casesIds];
        return [SELECT Id, AccountId, Account.BillingCountry, Parent_Account__c, OwnerId FROM Case WHERE Id IN :casesIds AND (CreatedBy.IsPortalEnabled = True OR RecordType.DeveloperName = 'Follow_up_Case')];
    }

    public static List<Account> getAccountsForSharing(Set<Id> accountsIds) {
        //added distributor and distributor location to share end customer with Community Users
        return [SELECT Id, Type, Name, BillingCountry, Partner_Role__c, Business_Segment__c, Sub_Segment__c, ParentId, OwnerId, Distributor__c, Distributor_Location__c, Distributor_Location__r.Name ,RecordTypeId FROM Account WHERE Id IN :accountsIds];
    }

    public static List<Contact> getContactsForSharing(Set<Id> contactsId){
        return [SELECT Id, Account.ParentId, Additional_Country_Responsibility__c FROM Contact WHERE Id IN :contactsId];
    }

    /* SOQLs to fetch records from KPI Objects */

    /* Sales Performance SOQLs ( for Sales Performance Query & for other Related locations associated with Sales performances) */
    public static List<Sales_Funnel__c> getSalesFunnelsForSharing(Set<Id> salesFunnelIds){

        return [SELECT Id, Name,Sales_Funnel_Sales_To_End_Customer__c, RecordTypeId, Distributor_Account_Name__c, Distributor_Parent_Account__c, Distributor_Account_Name__r.BillingCountry, OwnerId,
                Parent_Sales_Funnel__c, Sales_Funnel_Sales_To_End_Customer__r.Parent_Sales_Funnel__c, Distributor_Account__c, Distributor_Account__r.ParentId,
                Sales_Funnel_Sales_To_End_Customer__r.Distributor_Account_Name__c
                FROM Sales_Funnel__c 
                WHERE (Id IN: salesFunnelIds
                OR Parent_Sales_Funnel__c IN: salesFunnelIds
                OR Sales_Funnel_Sales_To_End_Customer__r.Parent_Sales_Funnel__c IN: salesFunnelIds)];
    }

    public static List<Other_Related_Customer_Location__c> getRelatedCustomerLocationForSalesFunnel(Set<Id> sFunnelIds){

        return [SELECT Id, Related_Sales_Performance__c, Distributor_Location__c FROM Other_Related_Customer_Location__c 
                WHERE Related_Sales_Performance__c IN: sFunnelIds
                AND Related_Sales_Performance__c != null
                AND RecordTypeId =: KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID];
    }
    
    /* Commercial Activities SOQLs ( for Commercial Activity Query & for other Related locations associated with Commercial Activities) */
    public static List<Commercial_Activity__c> getComActivityForSharing(Set<Id> comActivityIds){

        return [SELECT Id, Name, Commercial_Activity_Customer_Visit__c, Commercial_Activity_Promotion_Activity__c, Commercial_Activity_Sample__c, RecordTypeId, Distributor_Account_Name__c, Distributor_Parent_Account__c, Distributor_Account_Name__r.BillingCountry, OwnerId,
        Parent_Commercial_Activity__c, Commercial_Activity_Promotion_Activity__r.Parent_Commercial_Activity__c, Commercial_Activity_Customer_Visit__r.Parent_Commercial_Activity__c, Commercial_Activity_Sample__r.Parent_Commercial_Activity__c,
        Distributor_Account__c, Distributor_Account__r.ParentId, Commercial_Activity_Promotion_Activity__r.Distributor_Account_Name__c,
                Commercial_Activity_Customer_Visit__r.Distributor_Account_Name__c, Commercial_Activity_Sample__r.Distributor_Account_Name__c
                FROM Commercial_Activity__c 
                WHERE (Id IN: comActivityIds 
                OR Parent_Commercial_Activity__c IN: comActivityIds
                OR Commercial_Activity_Promotion_Activity__r.Parent_Commercial_Activity__c IN: comActivityIds
                OR Commercial_Activity_Customer_Visit__r.Parent_Commercial_Activity__c IN: comActivityIds
                OR Commercial_Activity_Sample__r.Parent_Commercial_Activity__c IN: comActivityIds)];
    }

    public static List<Other_Related_Customer_Location__c> getRelatedCustomerLocationForCommercialActivity(Set<Id> commercialActivitiesIds){

        return [SELECT Id, Related_Commercial_Activity__c, Distributor_Location__c FROM Other_Related_Customer_Location__c 
                WHERE Related_Commercial_Activity__c IN: commercialActivitiesIds
                AND Related_Commercial_Activity__c != null
                AND RecordTypeId =: KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID];
    }

    /* Forecast Accuracy SOQLs ( for Forecast Accuracy Query & for other Related locations associated with Forecast Accuracies) */
    public static List<Forecast_Accuracy__c> getForecastAccuracyForSharing(Set<Id> forecastAccIds){

        return [SELECT Id, Name, Forecast_Accuracy_Local_Stock__c, RecordTypeId, Distributor_Account_Name__c, Distributor_Parent_Account__c, Distributor_Account_Name__r.BillingCountry, OwnerId,
                Parent_Forecast__c, Forecast_Accuracy_Local_Stock__r.Parent_Forecast__c, Distributor_Account__c, Distributor_Account__r.ParentId,
                Forecast_Accuracy_Local_Stock__r.Distributor_Account_Name__c
                FROM Forecast_Accuracy__c 
                WHERE (Id IN: forecastAccIds
                OR Parent_Forecast__c IN: forecastAccIds
                OR Forecast_Accuracy_Local_Stock__r.Parent_Forecast__c IN: forecastAccIds)];
    }

    public static List<Other_Related_Customer_Location__c> getRelatedCustomerLocationForForecastAccuracy(Set<Id> fcastIds){

        return [SELECT Id, Related_Forecast_Accuracy__c, Distributor_Location__c FROM Other_Related_Customer_Location__c 
                WHERE Related_Forecast_Accuracy__c IN: fcastIds
                AND Related_Forecast_Accuracy__c != null
                AND RecordTypeId =: KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID];
    }

    /* FCI Customer Support SOQLs ( for FCI Customer Support Query & for other Related locations associated with FCI Customer Support) */
    public static List<FCI_Customer_Support__c> getFCICustomerSupportsForSharing(Set<Id> fciSuppIds){

        return [SELECT Id, Name, FCI_Customer_Support_Order_Process__c, RecordTypeId, Distributor_Account_Name__c, Distributor_Parent_Account__c, Distributor_Account_Name__r.BillingCountry, OwnerId,
                Parent_FCI_Customer_Support__c, FCI_Customer_Support_Order_Process__r.Parent_FCI_Customer_Support__c, Distributor_Account__c, Distributor_Account__r.ParentId,
                FCI_Customer_Support_Order_Process__r.Distributor_Account_Name__c
                FROM FCI_Customer_Support__c 
                WHERE (Id IN: fciSuppIds
                OR Parent_FCI_Customer_Support__c IN: fciSuppIds
                OR FCI_Customer_Support_Order_Process__r.Parent_FCI_Customer_Support__c IN: fciSuppIds)];
    }

    public static List<Other_Related_Customer_Location__c> getRelatedCustomerLocationForFCICustomerSupport(Set<Id> fciCustSuppIds){

        return [SELECT Id, Related_FCI_Customer_Support__c, Distributor_Location__c FROM Other_Related_Customer_Location__c 
                WHERE Related_FCI_Customer_Support__c IN: fciCustSuppIds
                AND Related_FCI_Customer_Support__c != null
                AND RecordTypeId =: KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID];
    }

    /* Business Strategy SOQLs ( for Business Strategy Query & for other Related locations associated with Business Strategies) */
    public static List<Business_Strategy__c> getBusinessStrategyForSharing(Set<Id> businessStrategyIds){

        return [SELECT Id, Name, Business_Strategy_High_Low_Lights__c, Business_Strategy_Competition__c, RecordTypeId, Distributor_Account_Name__c, Distributor_Parent_Account__c, Distributor_Account_Name__r.BillingCountry, OwnerId,
                Parent_Business_Strategy__c, Business_Strategy_High_Low_Lights__r.Parent_Business_Strategy__c, Business_Strategy_Competition__r.Parent_Business_Strategy__c,
                Distributor_Account__c, Distributor_Account__r.ParentId, Business_Strategy_High_Low_Lights__r.Distributor_Account_Name__c, Business_Strategy_Competition__r.Distributor_Account_Name__c
                FROM Business_Strategy__c 
                WHERE Id IN: businessStrategyIds
                OR Parent_Business_Strategy__c IN: businessStrategyIds
                OR Business_Strategy_High_Low_Lights__r.Parent_Business_Strategy__c IN: businessStrategyIds
                OR Business_Strategy_Competition__r.Parent_Business_Strategy__c IN: businessStrategyIds];
    }

    public static List<Other_Related_Customer_Location__c> getRelatedCustomerLocationForBusinessStrategy(Set<Id> businessStrategyIds){

        return [SELECT Id, Related_Business_Strategy__c, Distributor_Location__c FROM Other_Related_Customer_Location__c 
                WHERE Related_Business_Strategy__c IN: businessStrategyIds
                AND Related_Business_Strategy__c != null
                AND RecordTypeId =: KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID];
    }

    /* Account Plan SOQLs ( for Account Plan Query & for other Related locations associated with Account Plans) */
    public static List<Field_of_Play__c> getAccountPlansForSharing(Set<Id> accountPlanIds){

        return [SELECT Id, Name, RecordTypeId, Distributor_Business_Strategy__r.Distributor_Account_Name__c, Distributor_Business_Strategy__r.Distributor_Parent_Account__c, Distributor_Business_Strategy__r.Distributor_Account_Name__r.BillingCountry, OwnerId 
                FROM Field_of_Play__c 
                WHERE Id IN: accountPlanIds];
    }

    public static List<Other_Related_Customer_Location__c> getRelatedCustomerLocationForAccountPlans(Set<Id> accountPlanIds){

        return [SELECT Id, Account_Plan__c, Distributor_Location__c, Account_Plan__r.Distributor_Business_Strategy__r.Fiscal_Year_FY__c 
                FROM Other_Related_Customer_Location__c 
                WHERE Account_Plan__c IN: accountPlanIds
                AND Account_Plan__c != null
                AND Account_Plan__r.Distributor_Business_Strategy__c != null
                AND RecordTypeId =: KPIConstants.DISTRIBUTOR_OTHER_RELATED_CUSTOMER_RECORD_TYPE_ID];
    }

    public static Map<Id,SObject> getKPIRecords(List<Id> objIdsToShare,String sObjAPIName){

        String query = 'SELECT Id,OwnerId FROM '+ sObjAPIName +' WHERE Id IN: objIdsToShare';
        return new Map<Id,SObject>(Database.query(query));
    }

    public static List<User> getAllPartnerManagersFromCommercialCustomers (Set<Id> commercialCostumersIdSet){
        return [SELECT Id, AccountId, Account.ParentId FROM User WHERE 
        isActive = true AND 
        ContactId != null AND
        IsPortalEnabled = true AND
        Account.ParentId IN: commercialCostumersIdSet AND
        Community_User_Role__c =: CONSTANTS.COMMUNITY_USER_ROLE_MANAGER_USER];
    }

    public static List<User> getAllAdditionalCountryResponsibilityPartnerUsersFromCommercialCustomers (Set<Id> commercialCostumersIdSet, Set<String> billingCountries){
        String countries = '(\'' + String.join(new List<String>(billingCountries), '\',\'') + '\')';
        String query = 'SELECT Id, Account.ParentId, Contact.Additional_Country_Responsibility__c FROM User WHERE';
        query += ' isActive = true AND'; 
        query += ' ContactId != null AND';
        query += ' IsPortalEnabled = true AND';
        query += ' Account.ParentId IN: commercialCostumersIdSet AND';
        query += ' Contact.Additional_Country_Responsibility__c INCLUDES';
        query += ' ' + countries;
        return Database.query(query);
    }

    public static List<Account> getCustomerLocationChildrenAccountsByParentId (Set<Id> parentIds){
        return [SELECT Id, ParentId FROM Account WHERE ParentId IN: parentIds AND RecordTypeId = :Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID];
    }

    public static List<Account> getCustomerLocationChildrenAccountsByParentIdBillingCountry (Set<Id> parentIds, Set<String> billingCountries){
        return [SELECT Id, ParentId, billingCountry FROM Account WHERE ParentId IN: parentIds AND billingCountry IN :billingCountries AND RecordTypeId = :Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID];
    }
    
    //Commented this method as it is not required to share Leads with Disti Community users after Child Lead implementation
    /*public static void deleteAllLeadRelatedSharing(List<User> users,List<Lead> leadToRevokeAccess) {
        Set<Id> accUsrIdToRemove = new Set<Id>();
            
        for (User usr : users) {

            accUsrIdToRemove.add(usr.Id);
        }   
            
        delete [
                SELECT Id,LeadId
                FROM LeadShare
                WHERE UserOrGroupId IN :users AND
                LeadId IN :leadToRevokeAccess AND
                RowCause = :Schema.LeadShare.RowCause.Manual
        ];
    }*/
    
    public static List<Child_Lead__c> getChildLeadsForSharing(Set<Id> childLeadIds) {
        return [SELECT Id, Distributor_Parent_Account__c,Distributor_Account_Name__c,OwnerId,Distributor_Account_Name__r.BillingCountry, CreatedById FROM Child_Lead__c WHERE Id IN :childLeadIds];
    }
    
    public static void deleteAllChildLeadsRelatedSharing(List<User> users,List<Child_Lead__c> leadToRevokeAccess) {
        
        delete [
                SELECT Id,ParentId
                FROM Child_Lead__Share
                WHERE UserOrGroupId IN :users AND
                ParentId IN :leadToRevokeAccess AND
                (RowCause = 'Standard_User__c' OR RowCause = 'Manager_User__c')
        ];
    }
}