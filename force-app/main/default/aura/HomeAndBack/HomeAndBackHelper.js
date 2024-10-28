({
    returnToHomePage : function(component, event, helper) {
        var currentURL = window.location.href;
        var communityURL = currentURL.substr(0, currentURL.indexOf('/s'));
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": communityURL + '/s'
        });
        urlEvent.fire();
    },
    returnToBackPage : function(component, event, helper) {
        window.history.back();
    }
})