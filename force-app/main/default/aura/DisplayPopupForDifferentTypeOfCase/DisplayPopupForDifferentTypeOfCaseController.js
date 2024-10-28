({
    handleRecordUpdated : function(component, event, helper) {
        let objectRecord = component.get("v.caseRecord") ;  
        let typeOfEvent = event.getParams().changeType;
        let toastMesssage = $A.get("e.force:showToast");
        let currentDateTime = new Date();/*$A.localizationService.formatDateTimeUTC(new Date(),"yyyy-MM-ddTHH:mm:ss.SSSZ")*/
        let caseCreatedDateTime = new Date(objectRecord.fields.CreatedDate.value);/*$A.localizationService.formatDateTimeUTC(objectRecord.fields.CreatedDate.value,"yyyy-MM-ddTHH:mm:ss.SSSZ")*/
        let timeDiffernce = currentDateTime.getTime() - caseCreatedDateTime.getTime();
        let caseRecordType = objectRecord.recordTypeInfo;
        
    
       if(typeOfEvent == 'LOADED' && timeDiffernce< 15000  && caseRecordType != null){
               
        let recordTypeName = caseRecordType.name;
        let caseType = objectRecord.fields.Type.value;   
        let validate = false;
        let messageHeading ='';
        let message ='';  
           
        if(recordTypeName == 'Complaint Case' && caseType == 'Quality Make'){
            validate = true;
            messageHeading = 'Further information for investigation will follow';
            message = 'If we need a sample, we will provide the relevant shipping information.';
        }else if(recordTypeName == 'Complaint Case' && caseType == 'Logistics'){
            validate = true;
            messageHeading = 'Please upload a copy of the CMR to this case';
            message = 'In case of damages and/or losses upon receipt, a signed CMR including a written remark of the\n damage/loss is needed to hold the carrier liable.';
        }else if(recordTypeName == 'Complaint Case' && caseType == 'Sales'){
            validate = true;
            messageHeading = 'Please upload relevant evidence to this case';
            message = 'Relevant supporting documents are required for a quick settlement of the complaint.';
        }

        if(validate){
        toastMesssage.setParams({
             "title": messageHeading,
             "type" :"warning",
             "duration":'8000',   
             "message":message,
             "key": "info_alt",
             "mode": "dismissible"
            });
        toastMesssage.fire();
    }
       }

    },
    checkUserOnInit :function(component, event, helper) {
            window.setTimeout($A.getCallback(function(){
                helper.setEnablePopup(component, event, helper)
            }), 1000);
    }
})