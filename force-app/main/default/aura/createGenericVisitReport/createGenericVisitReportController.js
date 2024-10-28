({
	createNew : function(component, event, helper) {
        let contactId = '';
        
        /* Get Contact Id when the Call Notes is created from the Contact record starts here */
        let pageRef = component.get("v.pageReference");
        let state = pageRef.state;
        let base64Context = state.inContextOfRef;
        
        //string starts with "1\."
        if (base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        
        let addressableContext = JSON.parse(window.atob(base64Context));
        contactId = addressableContext.attributes.recordId;
        /* Get Contact Id when the Call Notes is created from the Contact record ends here */
        
        //Load the Call Note creation form and create the call notes based on the values entered by the user
        let recordType = $A.get("$Label.c.Lead_Call_Note_Record_Type_ID");
        var createRecordEvent = $A.get("e.force:createRecord");
        //B2B851
        let objectName = '';
        objectName = addressableContext.attributes.objectApiName;// Fetch object name
        let defaultFieldValues = {}; // Set defaultFieldValues dynamically based on the object name
        if (objectName === 'Account') {
            defaultFieldValues = { 'Customer_Name__c': contactId };
        } else {
            defaultFieldValues = { 'Contact__c': contactId };
        } 
        //B2B851
        createRecordEvent.setParams({
            "entityApiName": "Call_Notes__c",
            "recordTypeId": recordType,
            "defaultFieldValues": defaultFieldValues 
        });
    createRecordEvent.fire();
    }
})