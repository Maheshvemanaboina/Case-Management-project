({
	doInit : function(component, event, helper) {
		helper.setBreadCrumbsOnInit(component, event, helper);
        helper.setBaseUrl(component, event, helper);
	},
    
    handleBreadCrumbHomeClick : function(component, event, helper){
        var url = component.get("v.baseUrl") + '/s';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    handleBreadCrumbClick : function(component, event, helper){
        var name = event.getSource().get('v.name');
        helper.setBreadCrumbData(component, event, helper, name);
    },
    
    handleFCIClick : function(component, event, helper){
        var currtarget = event.currentTarget;
        var linkName = currtarget.getAttribute("data-val");
        helper.displayIFrameOnClick(component,linkName);
        helper.setBreadCrumbsOnChange(component, linkName);
    }
})