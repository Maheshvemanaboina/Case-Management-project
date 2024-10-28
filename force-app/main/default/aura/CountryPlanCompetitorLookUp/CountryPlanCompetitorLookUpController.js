({
    doInit : function(component, event, helper){
        var competitorsObj = component.get("v.competitorObj");
        if(competitorsObj.Name){
            component.set("v.selectedRecord",competitorsObj);
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        }
    },
    
    onfocus : function(component,event,helper){
        var objName = component.get("v.objectAPIName");
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord,objName);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        var objName = component.get('v.objectAPIName');
        if( getInputkeyWord.length > 2 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component, event, getInputkeyWord, objName);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    // function for clear the Record Selaction 
    clear :function(component,event,heplper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );
        component.set("v.listOfSearchRecords",null);
        
        var competitorObjData = component.get("v.competitorObj");
        competitorObjData.CompetitorId = '';
        competitorObjData.Name = '';
        
    },
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        
        var uniqueCompetitorId = true;
        var allcompetitorInfoList = component.get("v.allCompetitorsObjsList");
        
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        
        for(var i = 0 ; i < allcompetitorInfoList.length ; i++){
            
            if(allcompetitorInfoList[i].Name != 'Unknown Competitor' && allcompetitorInfoList[i].CompetitorId == selectedAccountGetFromEvent.Id){
                helper.fireToastMessageforCompetitor(component, event, helper, 'Error', 'Competitor Account Already Selected', 'error');
                uniqueCompetitorId = false;
            }
        }
        if(uniqueCompetitorId){
            component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
            var competitorObjData = component.get("v.competitorObj");
            competitorObjData.CompetitorId = selectedAccountGetFromEvent.Id;
            competitorObjData.Name = selectedAccountGetFromEvent.Name;
            
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');
        }
                
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        
    }
})