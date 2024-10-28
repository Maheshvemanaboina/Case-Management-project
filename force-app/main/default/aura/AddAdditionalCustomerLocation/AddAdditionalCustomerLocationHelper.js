({
	handleShowModalHelper : function(component, event, helper, custLocRec) {
        console.log('handleShowModal => ');
		let contactId = component.get("v.recordId");
        let custLocId = !$A.util.isEmpty(custLocRec.Id) ? custLocRec.Id : null;
        let distiLocId = !$A.util.isEmpty(custLocRec.Additional_Customer_Location__c) ? custLocRec.Additional_Customer_Location__c : null;
        let conAccIdObj = component.get('v.conAccIdObj');
        console.log('contactId => ',contactId);
        console.log('custLocId => ',custLocId);
        console.log('distiLocId => ',distiLocId);
        $A.createComponent("c:newAdditionalCustomerLocation",
                           {
                               "contactId" : contactId,
                               //"custLocId" : custLocId,
                               "accountId" : distiLocId,
                               "conAccIdObj" : conAccIdObj
                           },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   console.log('inside success if');
                                   //helper.showSpinner(component);
                                   var modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       header: "Additional Customer Location",
                                       body: modalBody, 
                                       showCloseButton: true,
                                       closeCallback: function(ovl) {
                                           //console.log('Overlay is closing');
                                           //$A.get('e.force:refreshView').fire();
                                           //helper.hideSpinner(component);
                                           helper.getAllAdditionalCustomerLocationsHelper(component, event, helper);
                                       }
                                   }).then(function(overlay){
                                       //$A.get('e.force:refreshView').fire();
                                   });
                               }else{
                                   console.log('not success else, status = ',status+' content = ',content);
                               }
                           });
	},
    
    getAllAdditionalCustomerLocationsHelper : function(component, event, helper){
        let action = component.get("c.getAllAdditionalCustomerLocations");
        action.setParams({
            contactId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let responseVal = response.getReturnValue();
                component.set('v.additionalCustLocations', responseVal);
                component.set('v.numOfAdditionalCustLocations', responseVal.length);
                let conAccIdObj = [];
                if(!$A.util.isEmpty(responseVal) && responseVal.length > 0){
                    responseVal.forEach(element => {
                        conAccIdObj.push(element.Related_Contact__c+element.Additional_Customer_Location__c);
                    });
                }
                        component.set('v.conAccIdObj', conAccIdObj);
            }else if (state == "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please contact your administrator"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    closeDeleteModalHelper: function(component, event, helper){
        component.set('v.isDelete', false);
        component.set('v.selectedCustLocId', '');
    },
    
    isPortalUser : function(component, event, helper){
        let action = component.get("c.isContactEnabledAsPartner");
        action.setParams({
            contactId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === "SUCCESS"){
                let responseVal = response.getReturnValue();
                if(responseVal) component.set('v.displayComponentBody', true);
                else component.set('v.displayComponentBody', false);
            }else if(state === "ERROR"){
                
            }else{
                
            }
        });
        $A.enqueueAction(action);
    }
})