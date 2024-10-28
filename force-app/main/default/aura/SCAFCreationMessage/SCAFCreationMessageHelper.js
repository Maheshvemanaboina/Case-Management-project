({
    AmendmentofOtherConditions : function(component, event, helper) {
        var action = component.get('c.SCAFCeation');
        action.setParams({
            'recordId': component.get('v.recordId')
        })
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.alert',result);
                
                /*alert(result.length);
                for(var x in result){
                    alert(result[x]['TemplateDeviationMSG']);
                }*/
                //console.log('result.length -->'+result.length);
                if(result.length > 0){
                    if(result[0].isTemplateDeviation) {
                        //console.log('result[0].showPopUpMsg value in IF --> '+result[0].showPopUpMsg);
                        //console.log('result is isTemplateDeviation'+result[0].StatusValue);
                        //console.log('result is isTemplateDeviation'+result[0].TemplateDeviationMSG);
                        component.set('v.hasNextInfo', true);
                        //alert(component.get('v.hasNextInfo'));
                        component.set('v.templateDeviation', result[0].TemplateDeviationMSG);
                        component.set('v.StatusValue',result[0].StatusValue);
                        component.set('v.ScafMessage',result[0].TemplateDeviationMSG);
                        var recId = component.get('v.recordId');
                        //console.log(recId);
                    }
                }/* else if(result[0].isAgreementWithCustomer) {
                    console.log('result is agreement'+result[0].StatusValue);
                    console.log('result is agreement'+result[0].AgreementWithCustomerMSG);
                    component.set('v.hasNextInfo', true);
                    component.set('v.StatusValue',result[0].StatusValue);
                    component.set('v.ScafMessage', result[0].AgreementWithCustomerMSG);
                    var recId = component.get('v.recordId');
                    console.log(recId);
                } else if(result[0].isLSDInPlace) {
                    console.log('result is isLSDInPlace'+result[0].StatusValue);
                    console.log('result is isLSDInPlace'+result[0].LSDInPlaceMSG);
                    component.set('v.hasNextInfo', true);
                    component.set('v.StatusValue',result[0].StatusValue);
                    component.set('v.ScafMessage', result[0].LSDInPlaceMSG);
                    var recId = component.get('v.recordId');
                    console.log(recId);
                } else if(result.isLSDInPlaceWithDev) {
                    console.log('result is isLSDInPlaceWithDev'+result[0].StatusValue);
                    console.log('result is isLSDInPlaceWithDev'+result[0].LSDInPlaceWithDevMSG);
                    component.set('v.hasNextInfo', true);
                    component.set('v.StatusValue',result[0].StatusValue);
                    component.set('v.ScafMessage', result[0].LSDInPlaceWithDevMSG);
                    var recId = component.get('v.recordId');
                    console.log(recId);
                }   else if(result.isExtensionType) {
                    console.log('result is isExtensionType'+result[0].StatusValue);
                    console.log('result is isExtensionType'+result[0].ExtensionTypeMSG);
                    component.set('v.hasNextInfo', true);
                    component.set('v.StatusValue',result[0].StatusValue);
                    component.set('v.ScafMessage', result[0].ExtensionTypeMSG);
                    var recId = component.get('v.recordId');
                    console.log(recId);
                }else if(result[0].isAgreementWithCustomerSCAF) {
                    console.log('result is isExtensionType'+result[0].StatusValue);
                    console.log('result is isExtensionType'+result[0].AgreementWithCustomerSCAFMSG);
                    component.set('v.hasNextInfo', true);
                    component.set('v.StatusValue',result[0].StatusValue);
                    component.set('v.ScafMessage', result[0].AgreementWithCustomerSCAFMSG);
                    var recId = component.get('v.recordId');
                    console.log(recId);
                }else if(result[0].isExclusivity) {
                    console.log('result is isExclusivity'+result[0].StatusValue);
                    console.log('result is isExclusivity'+result[0].ExclusivityMSG);
                    component.set('v.hasNextInfo', true);
                    component.set('v.StatusValue',result[0].StatusValue);
                    component.set('v.ScafMessage', result[0].ExclusivityMSG);
                    var recId = component.get('v.recordId');
                    console.log(recId);
                }*/
                else {
                    //console.log('result[0].showPopUpMsg value --> '+result[0].showPopUpMsg);
                    component.set('v.hasNextInfo', false);
                    if(result.length > 0){
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    showMessage : function(component, event, helper,totsales,intialLSD,termper,tempdev){
        
    }
})