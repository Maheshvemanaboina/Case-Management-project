({
    handleRecordUpdated : function(component, event, helper) {
        var changeType = event.getParams().changeType; 
        var Msg = 'Great, you are maintaining your contact data, this will help us to improve data & keep it clean.\n';
        Msg += 'Please be aware that any change in the following fields business segment, sub-segment, application,\n';
        Msg += 'additional region and additional countries will impact what your contact will see in the Community.';
        if (changeType === "CHANGED") {
            var changedFields = event.getParams().changedFields;
            var str =JSON.stringify(changedFields);
             if(str.includes("Business_Segment__c") || str.includes("Sub_Segment__c") || str.includes("Application__c") || str.includes("Additional_Country_Responsibility__c") || str.includes("Additional_Region_Responsibility__c") ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Impact on Community Sharing',
                message: Msg,
                duration:' 8000',
                key: 'info_alt',
                type: 'Warning',
                mode: 'dismissible'
            });
            toastEvent.fire();
            }
        }
    }
})