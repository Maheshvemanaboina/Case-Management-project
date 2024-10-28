({
	fetchListOfRecordTypes : function(component, event, helper) {
		var action = component.get("c.fetchRecordTypeValues");
       	action.setCallback(this, function(response) {
            var returning = [];
            var recordTypes = response.getReturnValue();
            console.log('recordTypes -> ' + JSON.stringify(recordTypes));
            for(var key in recordTypes){
                    returning.push({label:key,
                                    value:recordTypes[key]});
                }
            console.log('returning -> ' + JSON.stringify(returning));
         	component.set("v.lstOfRecordType", returning);
      	});
        
      	$A.enqueueAction(action);
        component.set("v.isOpen", true);
	},
    
    closeModal: function(component, event, helper) {
      component.set("v.isOpen", false);
    },
    
    
    createRecord: function(component, event, helper) {
          component.set("v.isOpen", true);
    
          var action = component.get("c.getRecTypeId");
          var recordTypeLabel = component.find("mygroup").get("v.value");
        if(recordTypeLabel){
          console.log('recordTypeLabel '+recordTypeLabel);
          action.setParams({
             "recordTypeLabel": recordTypeLabel
          });
          action.setCallback(this, function(response) {
             var state = response.getState();
             if (state === "SUCCESS") {
                var createRecordEvent = $A.get("e.force:createRecord");
                var RecTypeID  = response.getReturnValue();
                createRecordEvent.setParams({
                   "entityApiName": 'Visit_Report__c',
                   "recordTypeId": RecTypeID
                });
                createRecordEvent.fire();
                 
             } else if (state == "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                   "title": "Oops!",
                   "message": "No Internet Connection"
                });
                toastEvent.fire();
                 
             } else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                   "title": "Error!",
                   "message": "Please contact your administrator"
                });
                toastEvent.fire();
             }
          });
          $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                   "title": "Error!",
                   "message": "Please select record type"
                });
                toastEvent.fire();
        }  
   },
})