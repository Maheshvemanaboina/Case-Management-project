/**
 * Created by krzys on 25/04/2019.
 * Updated by mohmmad Rafi to getting document Id from the apex on 08/07/2021 
 */
({
    setTemplatesIds : function(component, event, helper) {
        var action = component.get("c.getCsvTemplateIds");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isUndefinedOrNull(result)){
                    component.set("v.localCsvId", result.localId);
                    component.set("v.nonLocalCsvId", result.nonLocalId);
                    component.set("v.defaultCsvId", result.defaultId);
                    let accountInstructionDocumentId = result.accountInstructionDocumentId;
                    if(!$A.util.isUndefinedOrNull(accountInstructionDocumentId)){
                       let baseUrl = component.get('v.baseUrl');
                       let iframeUrl = baseUrl + '/servlet/servlet.FileDownload?file='+accountInstructionDocumentId;
                       component.set("v.iframUrl", iframeUrl);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    /*
        @Description : This method used for getting base url
        @param : component,event,helper
        @CreatedBy : Mohammad Rafi
        @CreatedDate : 08-07-2021
    */ 
    setBaseUrl :  function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("IngredientsMyDistributorcommunity/s"));
        baseURL = baseURL + 'IngredientsMyDistributorcommunity'
        component.set("v.baseUrl", baseURL);
     },
})