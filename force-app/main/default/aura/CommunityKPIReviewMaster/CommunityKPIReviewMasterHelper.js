({
    setTable : function(component, event, helper) {
        component.set("v.Spinner",true);
        var action = component.get("c.getTableData");
        action.setParams({
            masterKPIid : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.tableValues", result);
                //component.set("v.SMComment",result.SMComments); ENH-4586 - commented
                component.set("v.Spinner",false);
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    saveRecord : function(component, event, helper){

        var action = component.get("c.updateRecords");
        action.setParams({
            //listOfRelatedRecordIds : component.get("v.arrayValues"),
            masterKPIid : component.get("v.recordId"),
            //SMComments : component.get("v.SMComment"),
            kpiIdCommentsMap : component.get("v.kpiMap")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else if(status === "ERROR"){
               var errorMsg = response.getError()[0];
               let toastParams = {
                 title: "Error",
                 message: errorMsg.message, // Default error message
                 type: "error"
                };
               let toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams(toastParams);
               toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})