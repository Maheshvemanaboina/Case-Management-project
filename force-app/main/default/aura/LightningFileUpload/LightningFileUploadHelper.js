({
    getProperRecordIdentifier : function(component, event, helper) {
        var action = component.get("c.getProperRecordId");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.properRecordId", result);
                helper.getUploadedFiles(component,event);
                helper.getCategoryValues(component, event);
            }
        });
        $A.enqueueAction(action);

    },
    getUploadedFiles : function(component, event){
        var action = component.get("c.getFiles");  
        action.setParams({  
            "recordId": component.get("v.properRecordId")
        });

        action.setCallback(this,function(response){
            var state = response.getState();  
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();           
                component.set("v.files",result);
            }  
        });  
        $A.enqueueAction(action);  
    },

    getCategoryValues : function(component, event){
        var action = component.get("c.getCategoryOptions");

        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.categoryOptions",result);
            }
        });
        $A.enqueueAction(action);
    },
    setFileCategory : function(component){
            var action = component.get("c.updateFileCategory");
            action.setParams({
                "recordId": component.get("v.properRecordId"),
                "category": component.get("v.category")
            });
        $A.enqueueAction(action);
        },
    setUpdatedFileCategory : function(component){
        console.log('##### '+ component.get("v.selectedCategory"));
        console.log('##### '+ component.get("v.contentVersionId"));
        var action = component.get("c.updateExistingCategory");
            action.setParams({
                "recordId": component.get("v.contentVersionId"),
                "category": component.get("v.selectedCategory")
            });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){  
                this.getUploadedFiles(component);
                component.set("v.showSpinner", false);
                component.set("v.showModel", false);
                // show toast on file deleted successfully
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Category has been updated successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();                
            }  
        }); 
        
         $A.enqueueAction(action);
    },
    
    deleteUploadedFile : function(component, event) {
        var action = component.get("c.deleteThisFile");
        action.setParams({
            "contentDocumentId": event.currentTarget.id
        });  
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state=='SUCCESS'){  
                this.getUploadedFiles(component);
                component.set("v.showSpinner", false); 
                // show toast on file deleted successfully
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "File has been deleted successfully!",
                    "type": "success",
                    "duration" : 2000
                });
                toastEvent.fire();
            }  
        });  
        $A.enqueueAction(action);  
    },
    editCategoryFeild : function(component, event) {
        
    }
 })