/**
 * Created by KJM on 08/04/2019.
 */
({
     redirectToUploadPage : function (component, event, helper) {
       
        var urlString = window.location.href;	
       // console.log("urlString"+urlString);
        var baseURL = urlString.substring(0, urlString.indexOf("IngredientsMyDistributorcommunity/s"));
        var url = baseURL + 'IngredientsMyDistributorcommunity/s/' + component.get("v.pageRedirect");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
           "url": url
        });
        urlEvent.fire();
     },
})