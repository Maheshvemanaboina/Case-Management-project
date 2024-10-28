({
    newButtonLabel		: "New Account Plan",
    editButtonLabel 	: "Edit Account Plan",
    cloneButtonLabel 	: "Edit Account Plan",
    
    redirectToCountryPlanPage : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var url = baseURL + '/s/' + component.get("v.pageRedirect") + '?businessStrategyId='+component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    navigateToEditAccountPlanComponent : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var url = baseURL + '/s/' + component.get("v.pageRedirect") + '?AccountPlanId='+component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },

    navigateToCloneAccountPlanComponent : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var url = baseURL + '/s/' + component.get("v.pageRedirect") + '?AccountPlanId='+component.get("v.recordId") + '&type=Clone';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
})