({
    
    //Stores Attribute values for Multi-picklist fields
    subSegmentsAttribute : "v.AllSubSegments",
    subSegmentsSelectedAttribute : "v.AllSubSegmentsSelected",
    subSegmentsSelectedAttributeUI : "v.AllSubSegmentsSelectedUI",

    additionalCountriesAttribute : "v.AllAdditionalCountries",
    additionalCountriesSelectedAttribute : "v.AllAdditionalCountriesSelected",
    additionalCountriesSelectedAttributeUI : "v.AllAdditionalCountriesSelectedUI",

    OtherPrincipalOptionsAttribute : "v.OtherPrincipalOptions",
    OtherPrincipalOptionsSelectedAttribute : "v.OtherPrincipalOptionsSelected",
    OtherPrincipalOptionsSelectedAttributeUI : "v.OtherPrincipalOptionsSelectedUI",

    MarketTrendsAttribute : "v.AllMarketTrends",
    MarketTrendsSelectedAttribute : "v.AllMarketTrendsSelected",
    MarketTrendsSelectedAttributeUI : "v.AllMarketTrendsSelectedUI",
    
    //Stores Attribute values for single picklist fields
    businessSegmentOptionsAttribute : "v.BusinessSegmentOptions",
    BusinessStrategyOptionsAttribute : "v.BusinessStrategyOptions",
    
    //Stores Attribute Values for single picklist Selected value
    businessSegmentOptionsSelectedAttribute : "v.CountryWrapper.businessSegmentSelected",
    MarketTrendsOptionSelectedAttribute : "v.CountryWrapper.marketTrendSelected",
    BusinessStrategyOptionSelectedAttribute : "v.CountryWrapper.businessStrategySelected",
    
    //Other Value
    OtherPrincipalOtherValue : "Others",
    
    setrecordIdOnInit : function(component , event, helper){
        const queryString = window.location.search;
        if(queryString.includes("Clone")){
			
            debugger;
            var urlSplit = queryString.split("&");
            var accplanIdString = urlSplit[urlSplit.length - 2];
            var typeString = urlSplit[urlSplit.length - 1];
            var accountplanIdVal = accplanIdString.substring(accplanIdString.length - 18, accplanIdString.length);
            component.set("v.recordId",accountplanIdVal);
            component.set("v.isCloned",true);
            //component.set('v.isButtonActive',false);
            
        }else if(queryString.includes("AccountPlanId")){
            
            const accountplanIdVal = queryString.substring(queryString.length - 18, queryString.length);
            component.set("v.recordId",accountplanIdVal);
            component.set("v.isCloned",false);
            
        }else if(queryString.includes("businessStrategyId=")){

            const businessStrategyIdVal = queryString.substring(queryString.length - 18, queryString.length);
            component.set("v.businessStrategyId",businessStrategyIdVal);
            component.set("v.isCloned",false);
        }
    },
    
    setDataOnInit : function(component, event , helper) {
        //sets spinner(loader) ON
        component.set("v.Spinner",true);
        
        
        var action = component.get("c.getDataOnInit");
        action.setParams({
            accPlanId : component.get("v.recordId"),
            sObjectName : 'Field_of_Play__c',
            businessStrategyId : component.get("v.businessStrategyId"),
            isClone : component.get("v.isCloned")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countryPlanWrapper = response.getReturnValue();
                
                
                
                //set the CountryWrapper to store entire data returned from server
                component.set("v.CountryWrapper",countryPlanWrapper);
                //console.log("Pending"+countryPlanWrapper.confirmedBySm);
                //console.log("Pending"+countryPlanWrapper.userRegion);
               //console.log("Pending"+component.get("v.CountryWrapper.existingCountryPlanObj.Confirmed_by_FCI_Sales_Manager__c"));
                //Set Fiscal year Values
                helper.setFiscalYearValues(component, event, helper, countryPlanWrapper.fiscalYearList, component.get("v.isCloned"));

                //Set Business Strategy and set the selected one in the record
                helper.setBusinessStrategy(component, event, helper, countryPlanWrapper.businessStrategies, countryPlanWrapper.businessStrategySelected);

                //Set Business Segments and set the selected one in the record
                helper.setBusinessSegments(component, event, helper, countryPlanWrapper.businessSegments, countryPlanWrapper.businessSegmentSelected);

                //Set Addtional Countries and set the selected ones in the record
                helper.setAdditionalCountries(component, event, helper, countryPlanWrapper.additionalCountries, countryPlanWrapper.additionalCountriesSelected);

                //Set Sub Segments and set the selected ones in the record
                helper.setSubSegments(component, event, helper, countryPlanWrapper.subSegments, countryPlanWrapper.subSegmentsSelected);
                
                //Set Other Principals and set the selected ones in the record
                helper.setOtherPrincipals(component, event, helper, countryPlanWrapper.otherPrincipals, countryPlanWrapper.otherPrincipalsSelected);

                //Set Market Trends and set the selected ones in the record
                helper.setMarketTrends(component, event, helper, countryPlanWrapper.marketTrends, countryPlanWrapper.marketTrendsSelected);

                //set dependency Matrix for Business Segment & Market Trends
                //helper.setAllBusinessSegmentMarketTrendsDependency(component, event, helper, countryPlanWrapper.controllingWithDependentValues);
                
                //Set Market Trends and Set the selected one as well
                //helper.setMarketTrends(component, event, helper, countryPlanWrapper.marketTrends, countryPlanWrapper.marketTrendSelected);
                
                //Set Business Segments and set the selected one in the record
                //helper.setBusinessSegmentsWithMarketTrends(component, event, helper, countryPlanWrapper.businessSegments, countryPlanWrapper.businessSegmentSelected, countryPlanWrapper.marketTrendSelected);
                
                //Set Competitor Info List if Exist
                helper.setCompetitorInfoList(component, event, helper, countryPlanWrapper.competitorInfoWrapList);
                
                //Set Customer Location Info List If Exist
                helper.setCustomerLocInfoList(component, event, helper, countryPlanWrapper.relatedCustLocInfoWrapList);
                
                //Set Share of Wallet Volume percentage on INIT
                helper.setShareOfWalletPercent(component, event, helper, countryPlanWrapper.distributorVol, countryPlanWrapper.FCIBudgetVol);
                if(component.get("v.CountryWrapper.confirmedBySm") == 'Yes' && component.get("v.isCloned") === false){
                    component.set('v.isButtonActive',true);
                }
                    
                //sets spinner(loader) OFF
                component.set("v.Spinner",false);
            }else if(status === "ERROR"){
              var errors = response.getError();
                //console.log("errors"+errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                }
          }
			            
        });
        $A.enqueueAction(action);
        component.set("v.Spinner",false);
    },

    setFiscalYearValues : function(component, event, helper, fiscalYearsList, isCloned){

        if(isCloned){

            var fiscalList = [];
            for(var i = 0; i < fiscalYearsList.length; i++){
                var eachFiscalYear = {
                    "label" : fiscalYearsList[i],
                    "value" : fiscalYearsList[i],
                    "selected" : false
                };
                fiscalList.push(eachFiscalYear);
            }

            fiscalList[0].selected = true;
            component.set("v.FiscalYearList",fiscalList);
            component.set("v.FiscalYear",fiscalList[0].value);
        }else{

            component.set("v.FiscalYear",fiscalYearsList[0]);
        }
    },

    setBusinessStrategy : function(component, event, helper, BusinessStrategyList, BusinessStrategySelected){
        
        var BusinessStrategies = [];
        for(var i = 0; i < BusinessStrategyList.length; i++){
            var eachBusinessStrategy = {
                "label" : BusinessStrategyList[i],
                "value" : BusinessStrategyList[i],
                "selected" : false
            };
            if(BusinessStrategyList[i] == BusinessStrategySelected){
                eachBusinessStrategy.selected = true;
            }
            BusinessStrategies.push(eachBusinessStrategy);
        }
        component.set(helper.BusinessStrategyOptionsAttribute,BusinessStrategies);
    },

    setBusinessSegments : function(component, event, helper, BusinessSegmentList, BusinessSegmentSelected){
        
        var BusinessSegments = [];
        for(var i = 0; i < BusinessSegmentList.length; i++){
            var eachBusinessSegment = {
                "label" : BusinessSegmentList[i],
                "value" : BusinessSegmentList[i],
                "selected" : false
            };
            if(BusinessSegmentList[i] == BusinessSegmentSelected){
                eachBusinessSegment.selected = true;
            }
            BusinessSegments.push(eachBusinessSegment);
        }
        component.set(helper.businessSegmentOptionsAttribute,BusinessSegments);
    },
    
    setAdditionalCountries : function(component, event, helper, additionalCountriesList, addtionalCountriesSelected){
        var addCountries = [];
        for (var i = 0; i < additionalCountriesList.length; i++) {
            var eachCountry = {
                "label": additionalCountriesList[i],
                "value": additionalCountriesList[i]
            };
            addCountries.push(eachCountry);
        }
        component.set(helper.additionalCountriesAttribute,addCountries);
        
        var addCountriesSelected = [];
        for(var j = 0; j < addtionalCountriesSelected.length; j++){
            addCountriesSelected.push(addtionalCountriesSelected[j]);
        }
        component.set(helper.additionalCountriesSelectedAttribute, addCountriesSelected);
        component.set(helper.additionalCountriesSelectedAttributeUI,addCountriesSelected);
    },

    setSubSegments : function(component, event, helper, SubSegmentsList, SubSegmentsSelected){
        var addSubSegments = [];
        for (var i = 0; i < SubSegmentsList.length; i++) {
            var eachSubSegment = {
                "label": SubSegmentsList[i],
                "value": SubSegmentsList[i]
            };
            addSubSegments.push(eachSubSegment);
        }
        component.set(helper.subSegmentsAttribute,addSubSegments);
        
        var addSubSegmentsSelected = [];
        for(var j = 0; j < SubSegmentsSelected.length; j++){
            addSubSegmentsSelected.push(SubSegmentsSelected[j]);
        }
        component.set(helper.subSegmentsSelectedAttribute, addSubSegmentsSelected);
        component.set(helper.subSegmentsSelectedAttributeUI,addSubSegmentsSelected);
    },
    
    setOtherPrincipals : function(component, event, helper, otherPrincipalsList, otherPrincipalsSelected){
        var allotherPrincipals = [];
        for (var i = 0; i < otherPrincipalsList.length; i++) {
            var eachPrincipal = {
                "label": otherPrincipalsList[i],
                "value": otherPrincipalsList[i]
            };
            allotherPrincipals.push(eachPrincipal);
        }
        component.set(helper.OtherPrincipalOptionsAttribute,allotherPrincipals);
        
        var otherPrincipalSelected = [];
        for(var j = 0; j < otherPrincipalsSelected.length; j++){
            otherPrincipalSelected.push(otherPrincipalsSelected[j]);
        }
        
        component.set(helper.OtherPrincipalOptionsSelectedAttribute, otherPrincipalSelected);
        component.set(helper.OtherPrincipalOptionsSelectedAttributeUI, otherPrincipalSelected);
        
        //set disable or enable Other Comments
        helper.enableDisableOtherComments(component, event, helper , otherPrincipalSelected);
    },

    setMarketTrends : function(component, event, helper, marketTrendsList, marketTrendsSelected){
        var allMarketTrends = [];
        for (var i = 0; i < marketTrendsList.length; i++) {
            var eachMarketTrend = {
                "label": marketTrendsList[i],
                "value": marketTrendsList[i]
            };
            allMarketTrends.push(eachMarketTrend);
        }
        component.set(helper.MarketTrendsAttribute,allMarketTrends);
        var marketTrSelected = [];
        for(var j = 0; j < marketTrendsSelected.length; j++){
            marketTrSelected.push(marketTrendsSelected[j]);
        }
        component.set(helper.MarketTrendsSelectedAttribute, marketTrSelected);
        component.set(helper.MarketTrendsSelectedAttributeUI, marketTrSelected);
    },

    setShareOfWalletPercent : function(component, event, helper, distributorVol, FCIBudgetVol){
        
        
        
        if(distributorVol == 0){
            
            //fire Toast message if distributor enters volume greater than FCI Budget Volume
            //helper.fireToastMessage(component, event, helper, 'Sorry!', 'Distributor Volume can never be greater than FCI Budget Volume', 'error');
            //component.set("v.CountryWrapper.distributorVol",0); 
            component.set("v.ShareOfWalletVolume",0);
        }else{
            
            //Else calculate the Share of Wallet volume percentage
            var shareOfWalPercent = FCIBudgetVol/distributorVol;
            component.set("v.ShareOfWalletVolume",shareOfWalPercent);
        }
    },
    
    setCompetitorInfoList : function(component, event, helper, competitorInfoWrapList){
        
        if(competitorInfoWrapList.length == 0){
            helper.createPrincipalObjectData(component, event, helper);
        }else{
            var RowItemList = [];
            
            for(var i = 0; i < competitorInfoWrapList.length; i++){
                RowItemList.push({
                    'recordObjId' : competitorInfoWrapList[i].recordObjId,
                    'Name' : competitorInfoWrapList[i].Name,
                    'CompetitorId' : competitorInfoWrapList[i].CompetitorId,
                    'distributorNames': competitorInfoWrapList[i].distributorNames,
                    'dirOrIndirVal': competitorInfoWrapList[i].dirOrIndirVal,
                    'recordName' : competitorInfoWrapList[i].recordName
                });
            }
            component.set("v.otherPrincpalsList", RowItemList); 
        }
        
    },
    
    setCustomerLocInfoList : function(component, event, helper, custLocInfoWrapList){
        
        if(custLocInfoWrapList.length != 0){
            var RowItemList = [];
            
            for(var i = 0; i < custLocInfoWrapList.length; i++){
                
                RowItemList.push({
                    type : custLocInfoWrapList[i].type,
                    recordObjId : custLocInfoWrapList[i].recordObjId,
                    CustLocId : custLocInfoWrapList[i].CustLocId,
                    label : custLocInfoWrapList[i].label,
                    iconName : custLocInfoWrapList[i].iconName,
                    alternativeText : custLocInfoWrapList[i].alternativeText
                });
            }
            component.set("v.customerLocPillItems", RowItemList); 
        }
    },
    
    
    createPrincipalObjectData : function(component, event, helper) {
        var RowItemList = component.get("v.otherPrincpalsList");
        RowItemList.push({
            'recordObjId' : '',
            'Name' : '',
            'CompetitorId' : '',
            'distributorNames': '',
            'dirOrIndirVal': '',
            'recordName' : ''
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.otherPrincpalsList", RowItemList); 
    },
    
    saveCountryPlan : function(component, event, helper) {
        
        //sets spinner(loader) ON
        component.set("v.Spinner",true);
        
        //checks if distributor volume is greater than FCI Budget Volumne

        var action = component.get("c.saveCountryPlanData");
        action.setParams({
            countryPlanId : component.get("v.recordId"),
            businessStratId : component.get("v.businessStrategyId"),
            otherPrincipalsData : JSON.stringify(component.get("v.otherPrincpalsList")),
            countryWrapperData : JSON.stringify(component.get("v.CountryWrapper")),
            otherPrincipalsChoosen : component.get("v.OtherPrincipalOptionsSelectedUI"),
            subSegmentsChoosen : component.get("v.AllSubSegmentsSelectedUI"),
            additionalCountriesChoosen : component.get("v.AllAdditionalCountriesSelectedUI"),
            marketTrendsChoosen : component.get("v.AllMarketTrendsSelectedUI"),
            relatedCustomerLocations : JSON.stringify(component.get("v.customerLocPillItems")),
            custLocDeleteIds : component.get("v.customerLocPillItemsRemoved"),
            competitorDeleteIds : component.get("v.otherPrincpalsRemoved"),
            fiscalYearChoosen : component.get("v.FiscalYear"),
            isClone : component.get("v.isCloned")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var countryId = response.getReturnValue();
                
                //fires success save toast message & redirects user to Country plan record
                helper.fireToastMessage(component, event, helper, 'WooHoo!', 'Your Country Plan is saved successfully.', 'success');
                helper.navigateToCountryPlan(component, event, helper, countryId);
                
                //sets spinner(loader) OFF
                component.set("v.Spinner",false);
                
            }else{
                var errors = response.getError();
                console.log('error message '+errors[0].message);
            }
        });
        $A.enqueueAction(action);
        component.set("v.Spinner",false);
    },
    
    fireToastMessage : function(component, event, helper, toastTitle, ToastMessage, ToastType){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : toastTitle,
            message: ToastMessage,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: ToastType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
    navigateToCountryPlan : function (component, event, helper, countryId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/field-of-play/'+countryId
        });
        urlEvent.fire();
    },
    
    //Sets Selected picklist value for all Single picklist Fields in the components
    setSelectedPicklistValue : function(component, event, helper, compAuraId, selectedAttributeValue){
        
        var selectedValue = component.find(compAuraId).get('v.value');
        component.set(selectedAttributeValue,selectedValue);
    },

    //get the Market Trends & Sub segments Dependent Data based on Business Segment from Backend
    setDependentPicklistsWRTBusinessSegment : function(component, event, helper, selectedBusinessSegment, dependentFieldAPIName, dependentAttributeToSet, dependentAttributeToSetUI){
        component.set("v.Spinner",true);
        var action = component.get("c.getDependentPickListValues");
        action.setParams({
            businessSegmentSelected : selectedBusinessSegment,
            dependentAPIName : dependentFieldAPIName
        });
        action.setCallback(this, function(response) {
            component.set("v.Spinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var allDependentValues = response.getReturnValue();
                var allDependentList = [];
                component.set(dependentAttributeToSetUI,allDependentList);

                for (var i = 0; i < allDependentValues.length; i++) {
                    var eachDependentPicklistVal = {
                        "label": allDependentValues[i],
                        "value": allDependentValues[i]
                    };
                    allDependentList.push(eachDependentPicklistVal);
                }
                component.set(dependentAttributeToSet,allDependentList);
            }
        });
        $A.enqueueAction(action);
    },
    
    OnBlurCustLoc : function(component, event, helper){
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    
    searchCustLocfromDB : function(component, event, getInputkeyWord,objName){
        var action = component.get("c.getCustomerLocsAccountsByName");
        action.setParams({
            'custLocSearchKey': getInputkeyWord,
            'sObjectName' : objName
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var custLocationRecords = response.getReturnValue();
                if (custLocationRecords.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.customerLocationRecords", custLocationRecords);
            }
        });
        $A.enqueueAction(action);
    },
    
    customerLocHelper : function(component, event, helper){
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //console.log('Selected Id '+selectedAccountGetFromEvent.Id);
        //console.log('Selected Name '+selectedAccountGetFromEvent.Name);
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var custLocItems = component.get("v.customerLocPillItems");
        var createCustomerLoc = true;
        for (var i = 0; i < custLocItems.length; i++) {
            
            if (custLocItems[i].CustLocId == selectedAccountGetFromEvent.Id) {
                createCustomerLoc = false;
                break;
            }
        }
        if(createCustomerLoc){
            custLocItems.push({
                type : 'icon',
                recordObjId : '',
                CustLocId : selectedAccountGetFromEvent.Id,
                label : selectedAccountGetFromEvent.Name,
                iconName : 'standard:account',
                alternativeText : 'Account',
            });
            component.set("v.customerLocPillItems",custLocItems);
        } else{
            helper.fireToastMessage(component, event, helper, 'Duplicate Detected!', 'Customer Location is already Selected', 'error');
        } 
    },
    
    removeSpecifiedBill : function(component, event, helper){
        
        var custLocPillsRemoved = component.get('v.customerLocPillItemsRemoved');
        var pillId = event.getParam('item').CustLocId;
        var pills = component.get('v.customerLocPillItems');
        for (var i = 0; i < pills.length; i++) {
            
            if (pillId == pills[i].CustLocId) {
                if(pills[i].recordObjId){
                    custLocPillsRemoved.push(pills[i].recordObjId);
                }
                pills.splice(i, 1);
                break;
            }
        }
        component.set('v.customerLocPillItems', pills);
        component.set('v.customerLocPillItemsRemoved', custLocPillsRemoved);
    },
    
    matchDistiVolWithBudgetVolOrElseSave : function(component, event, helper, distributorVol, FCIBudgetVol, otherPrincipalsValue){
        
        var distiVol = parseInt(distributorVol);
        var FCIBudget = parseInt(FCIBudgetVol);
        var otherPrincipalOthers = component.get("v.CountryWrapper.OtherComments");
        var confirmedSM = component.get("v.CountryWrapper.confirmedBySm");
        
            
        if(distiVol <= FCIBudget){
            helper.fireToastMessage(component, event, helper, 'Error', 'The distributor volume across principals can never be equal to or lower then the FCI mutually agreed budget.', 'error');
            
        }else if(otherPrincipalsValue.includes(helper.OtherPrincipalOtherValue) && !otherPrincipalOthers){
            
            helper.fireToastMessage(component, event, helper, 'Error', 'Please fill in Others Comments if "Others" is chosen in Other Principals.', 'error');
        }else if(confirmedSM == 'Pending'){
            helper.fireToastMessage(component, event, helper, 'Error', 'You cannot edit a country plan which is already submited for approval', 'error');
        }else{
            helper.saveCountryPlan(component, event, helper);
        }
    },
    
    enableDisableOtherComments : function(component, event, helper, otherPrincipalsValue){
        if(otherPrincipalsValue.includes(helper.OtherPrincipalOtherValue)){
            component.set("v.disableComments",false);
        }else{
            component.set("v.disableComments",true);
            component.set("v.CountryWrapper.OtherComments",'');
        }
    },
    
    addCompetitorIdsforDeletion : function(component, event, helper, competitorToRemove){
        
        if(competitorToRemove.recordObjId){
            var compeInfoIdList = component.get("v.otherPrincpalsRemoved");
            compeInfoIdList.push(competitorToRemove.recordObjId);
        }
    }
})