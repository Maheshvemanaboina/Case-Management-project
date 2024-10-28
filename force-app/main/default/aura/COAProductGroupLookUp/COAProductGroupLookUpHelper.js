({
    searchHelper : function(component,event,getInputkeyWord,parentRec) {
        var action = component.get("c.fetchMonthName");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'parentRecord' : parentRec
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        $A.enqueueAction(action);
    }
})