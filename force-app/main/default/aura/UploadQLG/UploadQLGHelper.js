({
    handleGetCSV : function(cmp,csv,filename) {
        if(csv != null) {
            this.createCSVObject(cmp, csv,filename);
            console.log('createCSVObject Called');
        }
    }, 
    createCSVObject : function(cmp,csv,filename) {
        console.log('Create CSV OBj');
        var action = cmp.get('c.getCSVObject');        
        var recordId = cmp.get('v.recordId'); 
        action.setParams({
            csv_str : csv,
            quoteId : recordId,
            fname : filename
        });
        console.log('Create CSV OBj End');
        action.setCallback(this, function(response) {
            var state = response.getState();            
            console.log('response: '+response.getState());
            console.log('response: '+response.getReturnValue());
            if(state == "SUCCESS") {
                cmp.set("v.isLoading", false);
                console.log('response: '+response.getReturnValue());
                cmp.set("v.result", response.getReturnValue());            
                cmp.set("v.csvObject", response.getReturnValue());
                this.showToastMsg(cmp, event, response.getReturnValue());
            } else if(state == "ERROR"){
                cmp.set("v.isLoading", false);
                this.showToastMsg(cmp,event,'File Error');
            }                   
        }); 
        $A.enqueueAction(action); 
    },
    showToastMsg: function(cmp, event, message){
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "message": message
        });
        resultsToast.fire(); 
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
    
})