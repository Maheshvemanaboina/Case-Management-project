({
	callAction: function(component, helper, actionName, params, callback) {
		var action = component.get(actionName);
		action.setParams(params);
		action.setCallback(this, response => {
			var state = response.getState();
			if (component.isValid() && state === "SUCCESS") {
				callback(response.getReturnValue());
			} else {
				if (state === "INCOMPLETE") {
					helper.showToast("Error!", "User is offline, device doesn't support drafts.", "error", "sticky");
				} else if (state === "ERROR") {
                    alert('error code '+ response.getError()[0].message);
					
				} else {
					//helper.showToast("Error!", "Unknown problem, state: " + state + ", error: " + response.getError()[0].message, "error", "sticky");
				}
				component.set("v.showSpinner", false);
			}
		});
		$A.enqueueAction(action);
	}
})