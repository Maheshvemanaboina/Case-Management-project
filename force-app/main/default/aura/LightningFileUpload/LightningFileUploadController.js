({
    doInit : function(component, event, helper){
        helper.getProperRecordIdentifier(component, event, helper);
        //helper.getUploadedFiles(component, event);
        
    },    
    previewFile : function(component, event, helper){  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [event.currentTarget.id]
        });  
    },    
    uploadFinished : function(component, event, helper) {
        helper.setFileCategory(component, event);
        helper.getUploadedFiles(component, event);
        var toastEvent = $A.get("e.force:showToast");
        // show toast on file uploaded successfully 
        toastEvent.setParams({
            "message": "Files have been uploaded successfully!",
            "type": "success",
            "duration" : 2000
        });
        toastEvent.fire();
    },    
    deleteFile : function(component, event, helper){
        if( confirm("Confirm deleting this file?")){
            component.set("v.showSpinner", true);
            helper.deleteUploadedFile(component, event);
        }
    },
    editCategory : function(component, event, helper){
        var target = component.get("v.files")[event.currentTarget.dataset.record];
        component.set("v.showModel", true);
        component.set('v.selectedCategory', target.ContentVersions[0].Category__c);
        component.set('v.contentVersionId', target.ContentVersions[0].Id);
        
    },
    saveCategory : function(component, event, helper){
        helper.setUpdatedFileCategory(component, event);
    },
    onChange: function (cmp, evt, helper) {
        cmp.set("v.category", cmp.find('fileCategory').get('v.value'));
    },
    onCancle: function (cmp, evt, helper) {
        cmp.set("v.showModel", false);
    },   
    
})