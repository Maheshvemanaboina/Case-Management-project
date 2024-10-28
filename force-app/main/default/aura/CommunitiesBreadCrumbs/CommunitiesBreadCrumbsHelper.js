({
    setBaseUrl: function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s") + 2);
        component.set("v.baseUrl", baseURL);
     },

     setBreadCrumbsOnInit : function(component, event, helper) {

        var action = component.get("c.getBreadCrumbs");
        action.setParams({
            recordId : component.get("v.recordId"),
            designAttName : component.get("v.designAttributeName"),
            communityName : component.get("v.communityFullName")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.BreadCrumbsWrapper", result);
            }
        });
        $A.enqueueAction(action);
     },

    standardObjPageReference : function(component, objAPIorPgName){

        var nagigateLightning = component.find('navigateService');
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objAPIorPgName,
                actionName: 'list'
            },
        };
        
        nagigateLightning.navigate(pageReference);
    },

    commNamedPageReference : function(component, objAPIorPgName){

        var nagigateLightning = component.find('navigateService');
        var pageReference = {
            type: 'comm__namedPage',
            attributes: {
                name: objAPIorPgName
            },
        };
        nagigateLightning.navigate(pageReference);
    },

    standardRecordPageReference : function(component, recId, objAPIorPgName){

        var nagigateLightning = component.find('navigateService');
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": recId,
                "objectApiName": objAPIorPgName,
                "actionName": "view"
            },
        };
        nagigateLightning.navigate(pageReference);
    }
})