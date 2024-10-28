({
	fetchData : function(component, event, helper) {
		var action = component.get("c.getWityDetails");
        action.setParams({
            wityId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if( state === "SUCCESS"){
                var rows = response.getReturnValue();
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    if (row.WITY_Key_Buying_Factors__c) row.wityName = row.WITY_Key_Buying_Factors__r.Name;
                }
                component.set("v.data", rows);
            }
        });
        $A.enqueueAction(action);
	},
    setURL : function(component, event, helper){
        var action = component.get("c.getVisitDataWrapper");
        action.setParams({
            wityId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if( state === "SUCCESS"){
                var result = response.getReturnValue();
                var currentURL = window.location.href;
                var urlString = currentURL.substring(0, currentURL.indexOf("/r/"));
                urlString = urlString + '/r/Visit_Report__c/' + result.visitId + '/view';
                console.log('urlString --> ', urlString);
                component.set("v.visitURL",urlString);
                component.set("v.visitName",result.visitName);
                component.set("v.visitDate",result.visitDate);
                
            }
        });
        $A.enqueueAction(action);
    }
})