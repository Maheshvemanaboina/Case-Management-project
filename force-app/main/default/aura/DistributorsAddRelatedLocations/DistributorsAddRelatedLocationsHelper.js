({
    
    openModel: function(component, event, helper) {
        
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false); 
        $A.get('e.force:refreshView').fire();
        //component.find("select").set("v.value", "");
        
        
    },
    
    handleSObjectLookUpSelect : function(component, event, helper){
        
        var selectedCustomerLocId = event.getParam("recordId");
        var selectedCustomerName = event.getParam("recordLabel");
        component.set("v.custLocId", selectedCustomerLocId);
        component.set("v.custLocLabel", selectedCustomerName);
        
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        debugger;
        var action = component.get("c.createRelatedLocation");
        
        action.setParams({
            
            fiscalYear : component.find('select').get('v.value'),
            objectName : component.get("v.ObjectAPIName"),
            custLocId  : component.get("v.custLocId"),
            relatedLocationKPILookUpAPIName : component.get("v.relatedLocationKPIObjectLookupAPIName"),
            masterBucketInitial : component.get("v.masterBucketInitials")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                if(result){

                  helper.fireToastMessage('Success','Related Distributor Location added successfully','success');
                  component.set("v.isModalOpen", false);
                }else{
                  
                  helper.fireToastMessage('Error','Related Distributor Location cannot be added as there is no record present for the fiscal year chosen','error');
                }
            }else if(status === "ERROR"){
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire();
    },
    
    onChange : function(component, event, helper) {
        
        var action = component.get("c.fetchExistingRelatedLocations");
        
        action.setParams({
            fiscalYear : component.find('select').get('v.value'),
            ObjectAPIName : component.get("v.ObjectAPIName"),
            masterKPIInitial : component.get("v.masterBucketInitials"),
            relatedLocationKPILookUpRelationName : component.get("v.relatedLocationKPIObjectLookupRelationAPIName")
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.existingRelatedLocs", response.getReturnValue());
                console.log("res"+JSON.stringify(response.getReturnValue()));
            }else if(status === "ERROR"){
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
        //JSON.stringify(response.getReturnValue()))
        
        
    },
    
    removeRecord : function(component, event, helper) {
        var recordId = event.target.id;
        
        var action = component.get("c.deleteRecords");
        action.setParams({
            recordId : event.target.id
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                helper.fireToastMessage('Success','Related Distributor Location deleted successfully','success');
            }else if(status === "ERROR"){
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
        
        //$A.get('e.force:refreshView').fire();
        
    },

    fireToastMessage : function(toastTitle, ToastMessage, ToastType){

      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
          title : toastTitle,
          message: ToastMessage,
          messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
          duration: '5000',
          key: 'info_alt',
          type: ToastType,
          mode: 'dismissible'
      });
      toastEvent.fire();
  },
})