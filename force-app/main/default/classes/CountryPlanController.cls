/*       
@Name           - CountryPlanController
@Author         - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@ModifiedBy     - Sibananda Bhuyan | Email - sibananda.bhuyan@frieslandcampina.com
@Version        - 1.0
@CreatedDate    - 11-04-2020

@Description    - The is the controller for CountryPlan Component. This will be used for both the creation & Edit page of Account plan

UserId              | Author-Email                  | Date          | Comment
====================|===============================|===============|=========
0054H000004H3IaQAK  | sibananda.bhuyan@frieslandcampina.com | 11-04-2020    | Created Class
*/

public without sharing class CountryPlanController {
    
    
    public static final Id ACCOUNT_RECORD_TYPE_COMPETITOR_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BGI_Competitor').getRecordTypeId();
    public static final Id ACCOUNT_PLAN_DISTRIBUTOR_RECORD_TYPE_ID = Schema.SObjectType.Field_of_Play__c.getRecordTypeInfosByDeveloperName().get('Distributor_Account_Plan').getRecordTypeId();
    public static final Id OTHER_CUST_LOC_RECORD_TYPE_ID = Schema.SObjectType.Other_Related_Customer_Location__c.getRecordTypeInfosByDeveloperName().get('Distributor_Related_Customer_Locations').getRecordTypeId();
    public static final Id BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID = Schema.SObjectType.Business_Strategy__c.getRecordTypeInfosByDeveloperName().get('Business_Strategy_Account_Plan').getRecordTypeId();
    public static final String ACCOUNT_PLAN_API_NAME = 'Field_of_Play__c';
    public static final String ADDITIONAL_COUNTRY_API_NAME = 'Additional_Countries__c';
    public static final String OTHER_PRINCIPAL_API_NAME = 'Other_Principals__c';
    public static final String MARKET_TRENDS_API_NAME = 'Market_Trends__c';
    public static final String BUSINESS_STRATEGY_API_NAME = 'Business_Strategy__c';
    public static final String SUB_SEGMENT_API_NAME = 'Sub_Segment__c';
    public static final String BUSINESS_SEGMENT_DEFAULT_VALUE_ON_CREATE = 'Industry';
    
    
    @AuraEnabled
    public static CountryPlanWrapper getDataOnInit(String accPlanId,String sObjectName, String businessStrategyId, Boolean isClone){

        User currUsr = getCurrentUserData();
        
        UserInterfaceAPIUtility.SinglePicklistWrapper singlePickWrap = UserInterfaceAPIUtility.getSinglePicklistValues(ACCOUNT_PLAN_API_NAME,ACCOUNT_PLAN_DISTRIBUTOR_RECORD_TYPE_ID,MARKET_TRENDS_API_NAME);
        
        List<String> fiscalYearList = new List<String>();
        Field_of_Play__c existingCountryPlanObj;
        
        //for New Account Plan Creation
        if(String.isNotBlank(businessStrategyId) && businessStrategyId != null && !isClone){

            fiscalYearList.add(getBusinessStrategyDataFROMId(businessStrategyId));
        //for Edit Account Plan Creation    
        }else if(String.isNotBlank(accPlanId) && accPlanId != null && !isClone){

            existingCountryPlanObj = getCurrentCountryPlanData(accPlanId);
            fiscalYearList.add(existingCountryPlanObj.Distributor_Business_Strategy__r.Fiscal_Year_FY__c);
        //for Clone Account Plan
        }else if(String.isNotBlank(accPlanId) && accPlanId != null && isClone){

            existingCountryPlanObj = getCurrentCountryPlanData(accPlanId);
            fiscalYearList.addAll(getAllBusinessStrategyFiscalYearsByLocations(existingCountryPlanObj.Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__c, existingCountryPlanObj.Distributor_Business_Strategy__r.Fiscal_Year_FY__c));
        }

        if(String.isBlank(accPlanId) || accPlanId == null){
            return new CountryPlanWrapper(fiscalYearList,'',
                                        currUsr.Contact.Region__c, currUsr.Contact.Account.BillingCountry,
                                        singlePickWrap.controllingFieldValues ,BUSINESS_SEGMENT_DEFAULT_VALUE_ON_CREATE,
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, SUB_SEGMENT_API_NAME),new List<String>(),
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, ADDITIONAL_COUNTRY_API_NAME),new List<String>(),
                                        0,0,
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, OTHER_PRINCIPAL_API_NAME),new List<String>(),
                                        '',
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, BUSINESS_STRATEGY_API_NAME),'',
                                        '','',
                                        singlePickWrap.controllingWithDependentValues.get(BUSINESS_SEGMENT_DEFAULT_VALUE_ON_CREATE),new List<String>(),
                                        '','','','',
                                        new List<CompetitorInfoWrapper>(),
                                        new List<RelatedCustomerLocInfoWrapper>()
                                        );
        }else{
            
            Share_Of_Wallet__c existingShareOfWalletObj = getShareOfWalletObjData(accPlanId);
            
            return new CountryPlanWrapper(fiscalYearList,existingCountryPlanObj.Confirmed_by_FCI_Sales_Manager__c,
                                        currUsr.Contact.Region__c, currUsr.Contact.Account.BillingCountry,
                                        singlePickWrap.controllingFieldValues, existingCountryPlanObj.Business_Segment__c,
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, SUB_SEGMENT_API_NAME), String.isNotBlank(existingCountryPlanObj.Sub_Segment__c) ? existingCountryPlanObj.Sub_Segment__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR) : new List<String>(),
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, ADDITIONAL_COUNTRY_API_NAME), String.isNotBlank(existingCountryPlanObj.Additional_Countries__c) ? existingCountryPlanObj.Additional_Countries__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR) : new List<String>(),
                                        existingShareOfWalletObj.Distributor_Volume_in_mT__c, existingShareOfWalletObj.FCI_Budget_Volume_in_mT__c,
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, OTHER_PRINCIPAL_API_NAME), String.isNotBlank(existingCountryPlanObj.Other_Principals__c) ? existingCountryPlanObj.Other_Principals__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR) : new List<String>(),
                                        existingCountryPlanObj.other_Comments__c,   
                                        getPicklistValues(ACCOUNT_PLAN_API_NAME, BUSINESS_STRATEGY_API_NAME), existingCountryPlanObj.Business_Strategy__c,
                                        existingCountryPlanObj.Growth_Opportunities__c, existingCountryPlanObj.Account_Market__c,
                                        singlePickWrap.controllingWithDependentValues.get(existingCountryPlanObj.Business_Segment__c), String.isNotBlank(existingCountryPlanObj.Market_Trends__c) ? existingCountryPlanObj.Market_Trends__c.split(Constants.SALESFORCE_PICKLIST_SEPARATOR) : new List<String>(),
                                        existingCountryPlanObj.Strength__c,   existingCountryPlanObj.Weakness__c, existingCountryPlanObj.Sweet_Spot__c,   existingCountryPlanObj.Sour_Spot__c,
                                        getCompetitorInfoList(existingCountryPlanObj.Id),
                                        getCustomerLocInfoList(existingCountryPlanObj.Id)
                                        );
        }
        
    }

    private static String getBusinessStrategyDataFROMId(String businessStrategyId){

        return [SELECT Id,Fiscal_Year_FY__c FROM Business_Strategy__c WHERE Id =: businessStrategyId].Fiscal_Year_FY__c;
    }

    private static List<String> getAllBusinessStrategyFiscalYearsByLocations(String distiLocationId, String currentfiscalYear){

        List<String> fiscalYearList = new List<String>();
        for(Business_Strategy__c biz : [SELECT Id,Fiscal_Year_FY__c FROM Business_Strategy__c
                                        WHERE Parent_Business_Strategy__c !=  Null
                                        AND Parent_Business_Strategy__r.Distributor_Account__c != Null
                                        AND Parent_Business_Strategy__r.Distributor_Account__c =: distiLocationId
                                        AND RecordTypeId =: BUSINESS_STRATEGY_ACCOUNT_PLAN_RECORD_TYPE_ID]){
            if(biz.Fiscal_Year_FY__c > currentfiscalYear){
                fiscalYearList.add(biz.Fiscal_Year_FY__c);
            }
            
        }
        return fiscalYearList;
    }
    
    @AuraEnabled
    public static List<SObject> getCompetitorAccountsByName(String searchKeyWord,String sObjectName){
        if(searchKeyWord != null && !String.isBlank(searchKeyWord)){
            List<sObject> returnList = new List<sObject>();
            String searchStr = '*' + searchKeyWord + '*';
            String searchQuery = 'FIND \'' + searchStr + '\' IN ALL FIELDS RETURNING '+ sObjectName +' (Id,Name WHERE RecordTypeId =\''+ ACCOUNT_RECORD_TYPE_COMPETITOR_ID +'\' AND Active__c = True)  LIMIT 10 ';
            List<List<sObject>> searchList = search.query(searchQuery);
            for(sObject Tl : (List<sObject>)searchList[0]){
                returnList.add(Tl);
            }
            return returnList;
        }
        else{
            String query = 'SELECT Id,Name FROM '+ sObjectName + ' WHERE RecordTypeId =\''+ ACCOUNT_RECORD_TYPE_COMPETITOR_ID +'\' LIMIT 10';
            return (List<sObject>)Database.query(query);
        }
    }
    
    @AuraEnabled
    public static List<SObject> getCustomerLocsAccountsByName(String custLocSearchKey,String sObjectName){
        User currUsr = getCurrentUserData();
        if(custLocSearchKey != null && !String.isBlank(custLocSearchKey)){
            List<sObject> returnList = new List<sObject>();
            String searchStr = '*' + custLocSearchKey + '*';
            String searchQuery = 'FIND \'' + searchStr + '\' IN ALL FIELDS RETURNING '+ sObjectName +' (Id,Name WHERE RecordTypeId =\''+ Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID +'\'  AND ParentId = \''+ currUsr.Contact.Parent_Account__c +'\') LIMIT 10';

            List<List<sObject>> searchList = search.query(searchQuery);
            for(sObject Tl : (List<sObject>)searchList[0]){
                returnList.add(Tl);
            }
            return returnList;
        }
        else{
            String query = 'SELECT Id,Name FROM '+ sObjectName + ' WHERE RecordTypeId =\''+ Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID +'\' AND ParentId = \''+ currUsr.Contact.Parent_Account__c +'\' LIMIT 10';
            return (List<sObject>)Database.query(query);
        }
    }
    
    @AuraEnabled
    public static String saveCountryPlanData(String countryPlanId,String businessStratId,String otherPrincipalsData,String countryWrapperData,
                                            List<String> otherPrincipalsChoosen,List<String> subSegmentsChoosen,
                                            List<String> additionalCountriesChoosen, List<String> marketTrendsChoosen, String relatedCustomerLocations,
                                            List<String> custLocDeleteIds,List<String> competitorDeleteIds,String fiscalYearChoosen, Boolean isClone){
        
        //Get Current User Data to return
        User currUsr = getCurrentUserData();
        
        String targetBusinessStrategyId = '';
        //get Current Business Strategy record to Link Account Plan
        if(isClone){

            targetBusinessStrategyId = getTargetBusinessStrategyBasedonFiscalYear(fiscalYearChoosen, currUsr.Contact.AccountId);
        }
        
        //Deserialize the Entire Country Wrapper
        CountryPlanWrapper countryWrap = (CountryPlanWrapper)(JSON.deserialize(countryWrapperData, CountryPlanWrapper.CLASS));
        
        //deserialize the Competitors Selected
        List<CompetitorInfoWrapper> compInfoWrapList = (List<CompetitorInfoWrapper>)(JSON.deserialize(otherPrincipalsData, List<CompetitorInfoWrapper>.CLASS));
        
        //deserialize the relatedCustomerLocations Selected
        List<RelatedCustomerLocInfoWrapper> relatedWrapInfoList = (List<RelatedCustomerLocInfoWrapper>)(JSON.deserialize(relatedCustomerLocations, List<RelatedCustomerLocInfoWrapper>.CLASS));
        
        //create or Update Account Plan Record
        Field_of_Play__c countryPlanObj;
        Share_of_Wallet__c shareOfWallet = new Share_of_Wallet__c();
        
        //If condition is to create new Account Plan data and its related records like Share of Wallet & Competitor info
        if(String.isBlank(countryPlanId) || countryPlanId == null || isClone){
            countryPlanObj = new Field_of_Play__c( RecordTypeId = ACCOUNT_PLAN_DISTRIBUTOR_RECORD_TYPE_ID );
            
            //else condition is to update/upsert existing Account Plan data and its related records like Share of Wallet & Competitor info
        }else{
            countryPlanObj = new Field_of_Play__c( Id = countryPlanId);
            shareOfWallet = getShareOfWalletObjData(countryPlanId);
        }
        
        //sets Country Plan data once user saves the record
        Field_of_Play__c countryPlansObj = setCountryPlanObjData(countryPlanObj, countryWrap, otherPrincipalsChoosen,subSegmentsChoosen, additionalCountriesChoosen, MarketTrendsChoosen, businessStratId, targetBusinessStrategyId, isClone);
        countryPlansObj.Account__c = currUsr.Contact.AccountId;
        countryPlansObj.Customer_location__c = currUsr.Contact.AccountId;
        countryPlansObj.distributor_Location__c = currUsr.Contact.Account.Name;
        upsert countryPlansObj;
        
        //sets share of Wallet data once user saves the record
        shareOfWallet.Field_of_Play__c = countryPlansObj.Id;
        shareOfWallet.Distributor_Volume_in_mT__c = countryWrap.distributorVol;
        shareOfWallet.FCI_Budget_Volume_in_mT__c = countryWrap.FCIBudgetVol;
        upsert shareOfWallet;
        
        //delete Customer Location Info data if user removes a customer location from selected ones
        deleteCustLocs(custLocDeleteIds, isClone);
        
        //Delete competitors data if user removes competitors from selected ones
        deleteCompetitors(competitorDeleteIds, isClone);
        
        //Inserts/Updates competitor info data once user saves the record
        upsertCompetitorInfoData(compInfoWrapList, countryPlansObj, isClone);
        
        //Inserts/Updates Customer Location info data once user saves the record
        upsertCustomerLocData(relatedWrapInfoList,countryPlansObj, isClone);
        
        
        return countryPlansObj.Id;
    }
    
    private static void deleteCompetitors(List<String> competitorDeleteIds, Boolean isClone){
        
        if(!competitorDeleteIds.isEmpty() && !isClone){
            delete [SELECT Id FROM Business_Strategy__c WHERE Id IN: competitorDeleteIds];
        }
    }
    
    private static void deleteCustLocs(List<String> custLocDeleteIds, Boolean isClone){
        
        if(!custLocDeleteIds.isEmpty() && !isClone){
            delete [SELECT Id FROM Other_Related_Customer_Location__c WHERE Id IN: custLocDeleteIds];
        }
    }
    
    //Inserts/Updates competitor info data once user saves the record
    private static void upsertCompetitorInfoData(List<CompetitorInfoWrapper> compInfoWrapList,Field_of_Play__c countryPlansObj, Boolean isClone){
        if(!compInfoWrapList.isEmpty()){
            List<Business_Strategy__c> compInfoList = new List<Business_Strategy__c>();
            for(CompetitorInfoWrapper eachCompInfo : compInfoWrapList){
                if(String.isNotBlank(eachCompInfo.CompetitorId)){
                    Business_Strategy__c competitorObj = new Business_Strategy__c();
                    competitorObj.RecordTypeId = KPIConstants.COMPETITION_ACCOUNT_PLAN_RECORD_TYPE_ID;
                    if(String.isNotBlank(eachCompInfo.recordObjId) && !isClone){
                        competitorObj.Id = eachCompInfo.recordObjId;
                    }
                    competitorObj.Name = eachCompInfo.recordName;
                    competitorObj.Account_Plan__c = countryPlansObj.Id;
                    competitorObj.Competitor_Account__c = eachCompInfo.CompetitorId;
                    competitorObj.Direct_Supply__c = eachCompInfo.dirOrIndirVal;
                    competitorObj.Name_of_Distributors__c = eachCompInfo.distributorNames;
                    compInfoList.add(competitorObj);
                }
            }
            
            if(!compInfoList.isEmpty()){
                upsert compInfoList;
            }
        }
        
    }
    
    //Inserts/Updates Customer/Location info data once user saves the record
    private static void upsertCustomerLocData(List<RelatedCustomerLocInfoWrapper> relatedWrapInfoList,Field_of_Play__c countryPlansObj, Boolean isClone){
        if(!relatedWrapInfoList.isEmpty()){
            List<Other_Related_Customer_Location__c> otherCustLocInfoList = new List<Other_Related_Customer_Location__c>();
            for(RelatedCustomerLocInfoWrapper eachCustLocInfo : relatedWrapInfoList){
                if(String.isNotBlank(eachCustLocInfo.CustLocId)){
                    Other_Related_Customer_Location__c otherCustLocObj = new Other_Related_Customer_Location__c();
                    otherCustLocObj.RecordTypeId = OTHER_CUST_LOC_RECORD_TYPE_ID;
                    if(String.isNotBlank(eachCustLocInfo.recordObjId) && !isClone){
                        otherCustLocObj.Id = eachCustLocInfo.recordObjId;
                    }else{
                        otherCustLocObj.Distributor_Location__c = eachCustLocInfo.CustLocId;
                    }
                    otherCustLocObj.Account_Plan__c = countryPlansObj.Id;
                    otherCustLocInfoList.add(otherCustLocObj);
                }
            }
            
            if(!otherCustLocInfoList.isEmpty()){
                upsert otherCustLocInfoList;
            }
        }
        
    }
    
    //returns existing competitor info on Edit Page of Country Plan
    private static List<CompetitorInfoWrapper> getCompetitorInfoList(String countryPlanId){
        
        List<CompetitorInfoWrapper> compInfoWrapList = new List<CompetitorInfoWrapper>();
        List<Business_Strategy__c> competitorInfoList = [SELECT Id,Name,Competitor_Account__c,Competitor_Account__r.Name,Direct_Supply__c,Name_of_Distributors__c
                                                   FROM Business_Strategy__c
                                                   WHERE Account_Plan__c =: countryPlanId
                                                   AND RecordTypeId =: KPIConstants.COMPETITION_ACCOUNT_PLAN_RECORD_TYPE_ID];
        for(Business_Strategy__c eachCompetitor : competitorInfoList){
            compInfoWrapList.add(new CompetitorInfoWrapper(eachCompetitor.Id,
                                                           eachCompetitor.Competitor_Account__r.Name,
                                                           eachCompetitor.Competitor_Account__c,
                                                           eachCompetitor.Name_of_Distributors__c,
                                                           eachCompetitor.Direct_Supply__c,
                                                           eachCompetitor.Name ));
        }
        
        return compInfoWrapList;
    }
    
    //returns existing Customer Location info on Edit Page of Country Plan
    private static List<RelatedCustomerLocInfoWrapper> getCustomerLocInfoList(String countryPlanId){
        
        List<RelatedCustomerLocInfoWrapper> compInfoWrapList = new List<RelatedCustomerLocInfoWrapper>();
        List<Other_Related_Customer_Location__c> customerLocInfoList = [SELECT Id,Distributor_Location__c,Distributor_Location__r.Name
                                                                        FROM Other_Related_Customer_Location__c
                                                                        WHERE Account_Plan__c =: countryPlanId];
        for(Other_Related_Customer_Location__c eachCustLoc : customerLocInfoList){
            compInfoWrapList.add(new RelatedCustomerLocInfoWrapper('icon',
                                                                   eachCustLoc.Id,
                                                                   eachCustLoc.Distributor_Location__c,
                                                                   eachCustLoc.Distributor_Location__r.Name,
                                                                   'standard:account',
                                                                   'Account' ));
        }
        
        return compInfoWrapList;
    }
    
    //get existing Share of Wallet record related to Account Plan record
    private static Share_of_Wallet__c getShareOfWalletObjData(String countryPlanId){
        
        return [SELECT Id,Distributor_Volume_in_mT__c, FCI_Budget_Volume_in_mT__c
                FROM Share_of_Wallet__c
                WHERE Field_of_Play__c =: countryPlanId order by createdDate desc LIMIT 1];
    }

    private static String getTargetBusinessStrategyBasedonFiscalYear(string fiscalYear, Id distributorLocationId){

        Business_Strategy__c bizStart = [SELECT Id FROM Business_Strategy__c
                                        WHERE Fiscal_Year_FY__c =: fiscalYear
                                        AND Parent_Business_Strategy__r.Distributor_Account__c =: distributorLocationId];
        return bizStart.Id;
    }
    
    // sets/builds the country plan record to insert/update once user saves the record.
    private static Field_of_Play__c setCountryPlanObjData(Field_of_Play__c countryPlanObj, CountryPlanWrapper countryWrap,List<String> otherPrincipalsChoosen,List<String> subSegmentsChoosen, List<String> additionalCountriesChoosen,List<String> MarketTrendsChoosen, String BusinessStrategyId,String targetBusinessStrategyId, Boolean isClone){
        
        countryPlanObj.Business_Strategy__c = countryWrap.businessStrategySelected;
        countryPlanObj.Market_Trends__c = getMultiPicklistValueSet(MarketTrendsChoosen);
        countryPlanObj.Business_Segment__c = countryWrap.businessSegmentSelected;
        countryPlanObj.Growth_Opportunities__c = countryWrap.growthOpportunity;
        countryPlanObj.Account_Market__c = countryWrap.marketInfo;
        countryPlanObj.Strength__c = countryWrap.distributorStrengths;
        countryPlanObj.Weakness__c = countryWrap.distributorWeaknesses;
        countryPlanObj.Sweet_Spot__c = countryWrap.distributorOpportunities;
        countryPlanObj.Sour_Spot__c = countryWrap.distributorThreats;
        countryPlanObj.Sub_Segment__c = getMultiPicklistValueSet(subSegmentsChoosen);
        countryPlanObj.Additional_Countries__c = getMultiPicklistValueSet(additionalCountriesChoosen);
        countryPlanObj.Other_Principals__c = getMultiPicklistValueSet(otherPrincipalsChoosen);
        countryPlanObj.Other_Comments__c = countryWrap.OtherComments;
        if(!String.isBlank(BusinessStrategyId) && BusinessStrategyId != null){
            countryPlanObj.Distributor_Business_Strategy__c = BusinessStrategyId;
        }
        if(isClone && String.isNotEmpty(targetBusinessStrategyId) && targetBusinessStrategyId != null && targetBusinessStrategyId != ''){

            countryPlanObj.Distributor_Business_Strategy__c = targetBusinessStrategyId;
        }
        return countryPlanObj;
    }
    
    //return the multipicklist values in the pattern accepted by SFDC
    private static String getMultiPicklistValueSet(List<String> allValues){
        
        String multiPickValue = '';
        for(String eachVal : allValues){
            multiPickValue = eachVal + ';' +multiPickValue;
        }
        return multiPickValue;
    }
    
    //the wrapper to store entire Country plan record's data
    public class CountryPlanWrapper {
        
        //Generic Information
        @AuraEnabled public List<String> fiscalYearList { get; set; }
        @AuraEnabled public String confirmedBySm { get; set; }
        @AuraEnabled public String userRegion { get; set; }
        @AuraEnabled public String userCountry { get; set; }
        @AuraEnabled public List<String> businessSegments { get; set; }
        @AuraEnabled public String businessSegmentSelected { get; set; }
        @AuraEnabled public List<String> subSegments { get; set; }
        @AuraEnabled public List<String> subSegmentsSelected { get; set; }
        @AuraEnabled public List<String> additionalCountries { get; set; }
        @AuraEnabled public List<String> additionalCountriesSelected { get; set; }
        
        
        //Share Of Wallet
        @AuraEnabled public Decimal distributorVol { get; set; }
        @AuraEnabled public Decimal FCIBudgetVol { get; set; }
        @AuraEnabled public List<String> otherPrincipals { get; set; }
        @AuraEnabled public List<String> otherPrincipalsSelected { get; set; }
        @AuraEnabled public String OtherComments { get; set; }
        
        //Strategy Distrubutor Info
        @AuraEnabled public List<String> businessStrategies { get; set; }
        @AuraEnabled public String businessStrategySelected { get; set; }
        @AuraEnabled public String growthOpportunity { get; set; }
        @AuraEnabled public String marketInfo { get; set; }
        @AuraEnabled public List<String> marketTrends { get; set; }
        @AuraEnabled public List<String> marketTrendsSelected { get; set; }
        
        //SWOT
        @AuraEnabled public String distributorStrengths { get; set; }
        @AuraEnabled public String distributorWeaknesses { get; set; }
        @AuraEnabled public String distributorOpportunities { get; set; }
        @AuraEnabled public String distributorThreats { get; set; }
        
        //Used to Store Competitor Info
        @AuraEnabled public List<CompetitorInfoWrapper> competitorInfoWrapList { get; set; }
        
        //Used to Store Customer Locations Info
        @AuraEnabled public List<RelatedCustomerLocInfoWrapper> relatedCustLocInfoWrapList { get; set; }
        
        //Businesss Segment & Market Segment dependent Values
        @AuraEnabled public Map<String,List<String>> controllingWithDependentValues {get; set;}
        
        public CountryPlanWrapper(List<String> fiscalYearList,String confirmedBySm,
                                String userRegion, String userCountry,
                                List<String> businessSegments,String businessSegmentSelected,
                                List<String> subSegments, List<String> subSegmentsSelected, 
                                List<String> additionalCountries, List<String> additionalCountriesSelected,
                                Decimal distributorVol, Decimal FCIBudgetVol, 
                                List<String> otherPrincipals, List<String> otherPrincipalsSelected, 
                                String OtherComments,
                                List<String> businessStrategies,String businessStrategySelected, 
                                String growthOpportunity, String marketInfo,
                                List<String> marketTrends, List<String> marketTrendsSelected,
                                String distributorStrengths, String distributorWeaknesses, String distributorOpportunities, String distributorThreats,
                                List<CompetitorInfoWrapper> competitorInfoWrapList,
                                List<RelatedCustomerLocInfoWrapper> relatedCustLocInfoWrapList){
                                      
                                      this.fiscalYearList = fiscalYearList;
                                      this.confirmedBySm = confirmedBySm;
                                      this.userRegion = userRegion;
                                      this.userCountry = userCountry;
                                      this.businessSegments = businessSegments;//singlePickWrap.controllingFieldValues;
                                      this.businessSegmentSelected = businessSegmentSelected;
                                      this.subSegments = subSegments;//getPicklistValues(ACCOUNT_PLAN_API_NAME, SUB_SEGMENT_API_NAME);
                                      this.subSegmentsSelected = subSegmentsSelected;
                                      this.additionalCountries = additionalCountries;//getPicklistValues(ACCOUNT_PLAN_API_NAME, ADDITIONAL_COUNTRY_API_NAME);
                                      this.additionalCountriesSelected = additionalCountriesSelected;
                                      this.distributorVol = distributorVol;
                                      this.FCIBudgetVol = FCIBudgetVol;
                                      this.otherPrincipals = otherPrincipals;//getPicklistValues(ACCOUNT_PLAN_API_NAME, OTHER_PRINCIPAL_API_NAME);
                                      this.otherPrincipalsSelected = otherPrincipalsSelected;
                                      this.OtherComments = OtherComments;
                                      this.businessStrategies = businessStrategies;//getPicklistValues(ACCOUNT_PLAN_API_NAME, BUSINESS_STRATEGY_API_NAME);
                                      this.businessStrategySelected = businessStrategySelected;
                                      this.growthOpportunity = growthOpportunity;
                                      this.marketInfo = marketInfo;
                                      this.marketTrends = marketTrends;//singlePickWrap.dependentFieldValues;
                                      this.marketTrendsSelected = marketTrendsSelected;
                                      this.distributorStrengths = distributorStrengths;
                                      this.distributorWeaknesses = distributorWeaknesses;
                                      this.distributorOpportunities = distributorOpportunities;
                                      this.distributorThreats = distributorThreats;
                                      this.competitorInfoWrapList = competitorInfoWrapList;
                                      this.relatedCustLocInfoWrapList = relatedCustLocInfoWrapList;
                                  }
    }
    
    //the wrapper to store competitor info records data
    public class CompetitorInfoWrapper {
        
        @AuraEnabled public String recordObjId { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String CompetitorId { get; set; }
        @AuraEnabled public String distributorNames { get; set; }
        @AuraEnabled public String dirOrIndirVal { get; set; }
        @AuraEnabled public String recordName {get;set;}
        
        public CompetitorInfoWrapper(String recordObjId,String Name, String CompetitorId, String distributorNames, String dirOrIndirVal,String recordName){
            this.recordObjId = recordObjId;
            this.Name = Name;
            this.CompetitorId = CompetitorId;
            this.distributorNames = distributorNames;
            this.dirOrIndirVal = dirOrIndirVal;
            this.recordName = recordName;
        }
    }
    
    //the wrapper to store competitor info records data
    public class RelatedCustomerLocInfoWrapper {
        
        @AuraEnabled public String type { get; set; }
        @AuraEnabled public String recordObjId { get; set; }
        @AuraEnabled public String CustLocId { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String iconName { get; set; }
        @AuraEnabled public String alternativeText { get; set; }
        
        public RelatedCustomerLocInfoWrapper(String type,String recordObjId,String CustLocId, String label, String iconName, String alternativeText){
            this.type = type;
            this.recordObjId = recordObjId;
            this.CustLocId = CustLocId;
            this.label = label;
            this.iconName = iconName;
            this.alternativeText = alternativeText;
        }
    }
    
    
    //returns current users Data
    public static User getCurrentUserData(){
        //Date.Today().Year()
        return [SELECT Id, ContactId, Contact.Parent_Account__c, Contact.AccountId,Contact.Account.Name, Contact.Region__c, Contact.Account.BillingCountry
                FROM User
                WHERE Id =: UserInfo.getUserId()
                AND ContactId != null];
    }
    
    // return existing Country plan record's data
    private static Field_of_Play__c getCurrentCountryPlanData(String countryPlanId){
        
        return [SELECT Id,Customers_Strategy_Goald_Objectives__c,Confirmed_by_FCI_Sales_Manager__c,Sub_Segment__c, Growth_Opportunities__c, Account_Market__c,Market_Trends__c,Business_Strategy__c,
                Strength__c, Weakness__c, Sweet_Spot__c, Sour_Spot__c, Additional_Countries__c, Other_Principals__c,Business_Segment__c,Other_Comments__c, Distributor_Business_Strategy__r.Fiscal_Year_FY__c,
                Distributor_Business_Strategy__r.Parent_Business_Strategy__r.Distributor_Account__c
                FROM Field_of_Play__c
                WHERE Id =: countryPlanId];
    }
    
    //returns all the picklist values from database using the field API Name
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        
        List<String> picklistValues = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.isActive()){
                picklistValues.add(String.valueOf(pickListVal.getLabel()));
                //System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            }
        }
        return picklistValues;
        
    }

    //the below method returns all the dependent values for picklists
    @AuraEnabled
    public static List<string> getDependentPickListValues(String businessSegmentSelected, String dependentAPIName){
        
        UserInterfaceAPIUtility.SinglePicklistWrapper singlePickWrap = UserInterfaceAPIUtility.getSinglePicklistValues(ACCOUNT_PLAN_API_NAME,ACCOUNT_PLAN_DISTRIBUTOR_RECORD_TYPE_ID,dependentAPIName);
        return singlePickWrap.controllingWithDependentValues.get(businessSegmentSelected);
    }
    
}