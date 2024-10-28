/**
 * Created by KJM on 17/04/2019.
 */
({
    setTable : function(component, event, helper) {
        var action = component.get("c.getTableData");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.locTableValues", result);
                component.set("v.locShowChatterMessageButtonForComm", result.showChatterMessageButton);
            } else {
                console.log(response.getError());
            }
        });

        $A.enqueueAction(action);
    }
})