({
    recordUpdated: function(cmp, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            cmp.set('v.meetingStructureId', cmp.get("v.meetingSummary.Meeting_Structure__c"));
            var action = cmp.get('c.getMeetingParticipates');
            action.setParams({ recordId : cmp.get("v.meetingStructureId"), meetingSummaryRecordId: cmp.get('v.recordId') });
            action.setCallback(this, $A.getCallback(function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                     console.log('data '+ $A.util.isEmpty(rows) + JSON.stringify(response.getReturnValue()));
                    if($A.util.isEmpty(rows)){
                        cmp.set('v.noRecordsFound', true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'No Existing records Found.Please add new participants',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    for (var i = 0; i < rows.length; i++) { 
                        var row = rows[i];
                        if(row.User__r){
                            row.userName = row.User__r.Name;
                        }
                    }
                    console.log('data '+ JSON.stringify(response.getReturnValue()));
                    cmp.set('v.mydata', rows);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            }));
            $A.enqueueAction(action);
        }
    },
    
    init : function(cmp, event, helper) {
        cmp.set('v.mycolumns', [            
            { label: 'Participate Name', fieldName: 'userName', type: 'text'},
            { label: 'Participate Email', fieldName: 'Email__c', type: 'text'}
        ]);
        console.log('inside inti '+ cmp.get('v.meetingStructureId'));
    },
    getSelectedName: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
      console.log('selectedrows '+ JSON.stringify(selectedRows));
        cmp.set('v.selectedRows', selectedRows);
    },
     handleSubmit : function(cmp, event, helper) {
          var action = cmp.get('c.createParticipants');
         action.setParams({ records : cmp.get('v.selectedRows'), recordId: cmp.get('v.recordId') });
            action.setCallback(this, $A.getCallback(function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var rows = response.getReturnValue();
                    console.log('returnvalue '+ response.getReturnValue());
                   $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Participant added Successfully!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                   $A.get('e.force:refreshView').fire(); 
                    
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                }
            }));
            $A.enqueueAction(action);
    },     
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
    },
    handleSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        var apiName = record.apiName;
        var myRecordId = record.id; // ID of updated or created record
        
        if(myRecordId){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Participant added Successfully!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
            toastEvent.fire();
                  
            $A.get("e.force:closeQuickAction").fire() ;
             $A.get('e.force:refreshView').fire(); 
        }
    },
    handleSectionToggle: function (cmp, event) {
         var openSections = event.getParam('openSections');
        if(openSections == 'A'){
             cmp.set('v.showSubmitButton', false);
        }else if(openSections == 'B'){
            cmp.set('v.showSubmitButton', true);
        }
    }
})