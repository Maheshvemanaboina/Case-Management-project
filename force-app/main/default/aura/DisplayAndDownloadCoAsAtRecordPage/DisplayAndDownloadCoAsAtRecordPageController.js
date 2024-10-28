({
	//On CLick of Fetch CoA button, it will call helper for fetching CoA
    fetchCoA :function(component, event, helper) {
        helper.fetchCoAHelper(component, event, helper)
    },
    //This method/function will show preview of the particular CoA, whenever user click eye icon
    filePreview: function(component, event, helper) {
    var contentId =event.currentTarget.id;
    var navService = component.find("navService");
    $A.get('e.lightning:openFiles').fire({
        recordIds: [contentId]
    });
    }
})