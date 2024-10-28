({
    doInit : function(component, event, helper){
        helper.getAllAdditionalCustomerLocationsHelper(component, event, helper);
        helper.isPortalUser(component, event, helper);
    },
    
    handleShowModal : function(component, event, helper){
		helper.handleShowModalHelper(component, event, helper, '');
	},
    
    handleEdit : function(component, event, helper){
        let custLoc = event.getSource().get('v.value');
        helper.handleShowModalHelper(component, event, helper, custLoc);
    },
    
    handleDelete : function(component, event, helper){
        helper.showSpinner(component, event, helper);
        component.set('v.isDelete', true);
        helper.hideSpinner(component, event, helper);
        component.set('v.selectedCustLocId', event.getSource().get('v.value'));
    },
    
    deleteCustLocation : function(component, event, helper){
        helper.showSpinner(component, event, helper);
        let action = component.get("c.deleteSelectedAdditionalCustomerLocation");
        action.setParams({
            "custLocId" : component.get('v.selectedCustLocId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                helper.hideSpinner(component, event, helper);
                helper.closeDeleteModalHelper(component, event, helper);
                helper.getAllAdditionalCustomerLocationsHelper(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Additional Customer Location has been deleted successfully.",
                    "type": "success"
                });
                toastEvent.fire();
            }else if(state === "ERROR"){
                helper.hideSpinner(component, event, helper);
                console.log('>>> ', JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    closeDeleteModal : function(component, event, helper){
        helper.closeDeleteModalHelper(component, event, helper);
    },
    
    navigateToAccount : function(component, event, helper){
        let accountId = event.currentTarget.dataset.value;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accountId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})