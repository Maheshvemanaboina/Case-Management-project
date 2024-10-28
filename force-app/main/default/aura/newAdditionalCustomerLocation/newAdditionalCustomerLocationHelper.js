({
	showSpinnerHelper: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinnerHelper: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    handleSObjectLookUpSelect : function(component, event, helper){
        
        var selectedCustomerLocId = event.getParam("recordId");
        var selectedCustomerName = event.getParam("recordLabel");
        let primaryDistLocId = component.get('v.contactRecord.AccountId');
        if(primaryDistLocId === selectedCustomerLocId){
            console.log('inside if');
            helper.handleCloseModalHelper(component, event, helper);
            helper.showToast(component, event, helper,"Error!", "error", "You cannot choose this account : "+selectedCustomerName+" , since it is already selected as the primary account. Please pick a different account.")
        }else{
            component.set("v.accountId", selectedCustomerLocId);
            component.set("v.custLocLabel", selectedCustomerName);
            //component.set("v.disableSaveBtn", false);
        }
    },
    
    showToast : function(component, event, helper, title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    
    handleCloseModalHelper: function(component, event, helper) {
        //Close the Modal Window
        component.find("overlayLib").notifyClose();
    },
    
    handleSaveHelper : function(component, event, helper){
        let relatedCustlocObj = component.get('v.relatedCustLocation');
        //let custLocId = component.get('v.custLocId');
        //let insertOrUpdate = !$A.util.isEmpty(custLocId) ? 'Updated' : 'Created';
        //relatedCustlocObj.Id = !$A.util.isEmpty(custLocId) ? custLocId : null;
        relatedCustlocObj.Related_Contact__c = component.get('v.contactId');
        relatedCustlocObj.Additional_Customer_Location__c = component.get('v.accountId');
        //relatedCustlocObj.Related_Contact_Additonal_Cust_Loc__c = component.get('v.contactId')+component.get('v.accountId');
        let action = component.get("c.insertOrUpdateAdditionalCustomerLocation");
        action.setParams({
            custLocRecord : relatedCustlocObj
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                helper.hideSpinnerHelper(component);
                component.find("overlayLib").notifyClose();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Customer Location has been created successfully.",
                    "type": "success"
                });
                toastEvent.fire();
            }else if (state == "ERROR") {
                console.log(JSON.stringify(response.getError()));
                helper.hideSpinnerHelper(component);
                let errorMessage = '';
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMessage = errors[0].message;
                    }
                } else {
                    console.log("Unknown error");
                }

                helper.showToast(component, event, helper, "Error!", "error", errorMessage);
            }
        });
        $A.enqueueAction(action);
    }
})