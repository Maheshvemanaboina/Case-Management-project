/**
 * Created by krzys on 25/04/2019.
 */
({
    doInit:  function(component, event, helper) {
        helper.setTemplatesIds(component, event, helper);
        // Calling helper method for getting base url
        helper.setBaseUrl(component, event, helper);
    }
})