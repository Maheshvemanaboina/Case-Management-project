({
   
    
    closeModel: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/SBQQ__Quote__c/list?filterName=Recent"
        });
        urlEvent.fire();
    },
    
})