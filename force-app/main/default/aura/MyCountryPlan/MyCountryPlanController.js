({
    doInit : function(component, event, helper) {
        helper.setrecordIdOnInit(component, event, helper);
        helper.setDataOnInit(component, event, helper);  
        helper.setDependentPicklistsWRTBusinessSegment(component, event, helper,'Food & Beverages', 'Sub_Segment__c', helper.subSegmentsAttribute, helper.subSegmentsSelectedAttributeUI);
        helper.setDependentPicklistsWRTBusinessSegment(component, event, helper,'Food & Beverage', 'Market_Trends__c', helper.MarketTrendsAttribute, helper.MarketTrendsSelectedAttributeUI);
        
    },
    
    handleCancel : function(component, event, helper){
        window.history.back();
    },
    
    genericInfoExpand : function(component, event, helper) {
        var showGenericInfo = component.find('showGenericInfo');
        $A.util.toggleClass(showGenericInfo,'slds-is-open');
    },
    shareOfWalletExpand : function(component, event, helper) {
        var showShareOfWallet = component.find('shareOfWallet');
        $A.util.toggleClass(showShareOfWallet,'slds-is-open');
    },
    relatedCustLocExpand : function(component, event, helper) {
        var relatedCustLoc = component.find('relatedCustLocation');
        $A.util.toggleClass(relatedCustLoc,'slds-is-open');
    },
    strategyDistiExpand : function(component, event, helper) {
        var showStrategyDisti = component.find('strategyDisti');
        $A.util.toggleClass(showStrategyDisti,'slds-is-open');
    },
    wityExpand : function(component, event, helper) {
        var showWITY = component.find('WITYInfo');
        $A.util.toggleClass(showWITY,'slds-is-open');
    },
    
    addNewRow : function(component, event, helper) {
        helper.createPrincipalObjectData(component, event, helper);
    },
    
    removeDeletedRow : function(component, event, helper){
        
        var index = event.getParam("indexVar");
        var competitorToRemove = event.getParam("CompetitorInfoObj");
        var AllRowsList = component.get("v.otherPrincpalsList");
        if(AllRowsList.length == 1){
            helper.fireToastMessage(component, event, helper, 'Error', 'Cannot delete all Competitor records', 'warning');
        }else{
            AllRowsList.splice(index, 1); 
            component.set("v.otherPrincpalsList", AllRowsList);
            helper.addCompetitorIdsforDeletion(component, event, helper, competitorToRemove);
        }
    },
    
    //on change of Market Trends Options Single picklist value, sets it to the Market Trends Option Selected attribute
    onMarketTrendsChange : function(component, event, helper){

        var marketSegmentsVal = event.getParam("value");
        component.set(helper.MarketTrendsSelectedAttributeUI, marketSegmentsVal );
    },
    
    //on change of Business Segments Single picklist value, sets it to the Business Segment Selected attribute
    onBusinessSegmentChange : function(component, event, helper) {
    	
        
        helper.setSelectedPicklistValue(component, event, helper, 'businessSegmentsId', helper.businessSegmentOptionsSelectedAttribute);
        helper.setDependentPicklistsWRTBusinessSegment(component, event, helper, component.get(helper.businessSegmentOptionsSelectedAttribute), 'Market_Trends__c', helper.MarketTrendsAttribute, helper.MarketTrendsSelectedAttributeUI);
        helper.setDependentPicklistsWRTBusinessSegment(component, event, helper, component.get(helper.businessSegmentOptionsSelectedAttribute), 'Sub_Segment__c', helper.subSegmentsAttribute, helper.subSegmentsSelectedAttributeUI);
    },

    onFiscalYearChange : function(component, event, helper) {
        
        helper.setSelectedPicklistValue(component, event, helper, 'fiscalYearId', "v.FiscalYear");
    },
    
    //on change of Business Strategy Single picklist value, sets it to the Business Strategy Selected attribute
    onBusinessStrategyChange : function(component, event, helper) {
        helper.setSelectedPicklistValue(component, event, helper, 'businessStrategyId', helper.BusinessStrategyOptionSelectedAttribute);
        
    },
    
    onOtherPrincipalsChange : function(component, event, helper) {
        var otherPrincipalsValue = event.getParam("value");
        
        component.set(helper.OtherPrincipalOptionsSelectedAttributeUI, otherPrincipalsValue );
        helper.enableDisableOtherComments(component, event, helper, otherPrincipalsValue);
    },

    onSubSegmentChange : function(component, event, helper) {
        var subSegmentsVal = event.getParam("value");
        component.set(helper.subSegmentsSelectedAttributeUI, subSegmentsVal );
    },
    
    onAdditionalCountryChange : function(component, event, helper) {
        var addCountriesVal = event.getParam("value");
        component.set(helper.additionalCountriesSelectedAttributeUI, addCountriesVal );
    },
    
    onDistributorAndFCIBudgetVolChange : function(component, event, helper) {
        helper.setShareOfWalletPercent(component, event, helper, component.get("v.CountryWrapper.distributorVol"), component.get("v.CountryWrapper.FCIBudgetVol"));
    },
    
    //Handles all operation once user clicks on SAVE
    handleSave : function(component, event, helper){
        
        helper.matchDistiVolWithBudgetVolOrElseSave(component, event, helper,  component.get("v.CountryWrapper.distributorVol"), component.get("v.CountryWrapper.FCIBudgetVol"), component.get(helper.OtherPrincipalOptionsSelectedAttributeUI));
        
    },
    
    handleMouseOver : function(component, event, helper){
        var tooltipId = event.target.getAttribute("data-tooltipId");
        
        $A.util.removeClass(component.find(tooltipId), 'slds-fall-into-ground');
        $A.util.addClass(component.find(tooltipId), 'slds-rise-from-ground');
    },
    
    handleMouseOut : function(component, event, helper){
        
        var tooltipId = event.target.getAttribute("data-tooltipId");
        $A.util.removeClass(component.find(tooltipId), 'slds-rise-from-ground');
        $A.util.addClass(component.find(tooltipId), 'slds-fall-into-ground');
    },
    
    handleOnBlurCustLoc :function(component,event,helper){  
        
        helper.OnBlurCustLoc(component, event, helper);
    },
    
    handleOnfocusCustLoc : function(component,event,helper){
        var objName = component.get("v.objectAPIName");
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        helper.searchCustLocfromDB(component,event,'',objName);
    },
    
    handleCustLockeyPress : function(component, event, helper) {
        
        var getInputKey = component.get("v.customerLocSearchKey");
        if( getInputKey.length > 2 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchCustLocfromDB(component, event, component.get("v.customerLocSearchKey"), component.get('v.objectAPIName'));
        }
        else{  
            component.set("v.customerLocationRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    handleCustomerLocEvent : function(component, event, helper){
        helper.customerLocHelper(component, event, helper);
    },
    
    handlePillRemoval : function(component, event, helper){
        
        helper.removeSpecifiedBill(component, event, helper);
        
    }
})