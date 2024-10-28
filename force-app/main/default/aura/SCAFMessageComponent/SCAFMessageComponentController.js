({
    doInit : function(component, event, helper) {
        var action = component.get('c.getMessageCount');
        action.setParams({
            'recordId': component.get('v.recordId')
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state'+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result --> '+result[0].isTemplateDeviation);
                component.set('v.MsgCount',result[0].msgCount);
                component.set('v.ExclusiveOffTerms',result[0].ExclusiveOffTake);
                if(result.length > 0){
                    if(result[0].isTemplateDeviation){
                        component.set('v.hasNextInfo',true);
                        component.set('v.alert',result);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    showToastMessage : function(component, event, helper) {
        //var exclusiveOff = component.get('v.ExclusiveOffTerms');
        //var intialLSD = component.get('v.InitialTermsLSD');
        //console.log('showPopUpVal --> '+showPopUpVal);
        var action = component.get('c.getMessageCount');
        action.setParams({
            'recordId': component.get('v.recordId')
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.MsgCount',result.msgCount);
                component.set('v.ExclusiveOffTerms',result.ExclusiveOffTake);
                var msgct = component.get('v.MsgCount');
                if(component.get('v.ExclusiveOffTerms') == 'Yes' && component.get('v.InitialTermsLSD') >= 60 && msgct == 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: 'Please contact Corporate Legal to safeguard compliance with competition law',
                        //messageTemplate: 'Record {0} created! See it {1}!',
                        duration:'20000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            }
            //helper.handleLoad(component,event,helper);
        });
        $A.enqueueAction(action);
    },
    handleLoad : function(component, event, helper) {
        var recUi = event.getParam("recordUi");
        if(recUi.record.fields["Period_of_Exclusive_off_take_by_Customer__c"] != undefined){
            component.set('v.ExclusiveOffTerms', recUi.record.fields["Period_of_Exclusive_off_take_by_Customer__c"].value);
        }
        
        component.set('v.InitialTermsLSD', recUi.record.fields["Initial_Term_of_LSD_In_Months__c"].value);
    },
})