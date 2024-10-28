({
    doInit:function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        component.set("v.baseUrl",baseURL);
        helper.checkUserOnInit(component, event, helper);
        
    },
    
    createMissingCoACase:function(component, event, helper) {
        helper.getCurrentUserDetailsAndCreateMissingCoACase(component, event, helper);
    },
    
    moveToManualCOA:function(component, event, helper) {
        component.set("v.showManualUploadsCoA",true);
    },
    
    closeManualUpload :function(component, event, helper) {
        component.set("v.showManualUploadsCoA",false);
    },
    
    checkEnteredNoAndFetchCoA : function(component, event, helper) {
        var enteredInfo = component.get("v.enteredInfo");
        var enterdNumber = enteredInfo.EnterdNumber.trim();
        var typeOfNumber = enteredInfo.TypeOfNumber;
        var numberIsEntredOrSearched = enteredInfo.IsUserUseSearchFunctionality; 
        var toastEvent = $A.get("e.force:showToast");
        var resetTileObj = {'Delivery_Number__c':'','Sales_Order_Number__c':'','Purchase_Order_Number__c':'','Batch_Number__c':'','ShipToParty__c':''};
        component.set("v.tileObject",resetTileObj);
        component.set("v.enteredInfo.EnterdNumber",enterdNumber);
        
        if(enterdNumber === '' || enterdNumber === null || enterdNumber === undefined){
            
            toastEvent.setParams({
                title : 'Error',
                message: 'Please first Enter '+typeOfNumber,
                duration:'5000',
                key: 'info_alt',
                type: 'Error',
                
            });
            toastEvent.fire();
        }
        else if(enterdNumber != '' && enterdNumber != null && enterdNumber != undefined && numberIsEntredOrSearched){
            
            if(typeOfNumber === 'Delivery Number'){
                component.set("v.tileObject.Delivery_Number__c",enterdNumber);
            }
            else if(typeOfNumber === 'Sales Order Number'){
                component.set("v.tileObject.Sales_Order_Number__c",enterdNumber);
            }
                else if(typeOfNumber === 'Purchase Order Number'){
                    component.set("v.tileObject.Purchase_Order_Number__c",enterdNumber);
                }
                    else if(typeOfNumber.includes('Batch')){
                        let getShipToNumber = component.get("v.enteredInfo.ShipToNumber");
                        component.set("v.tileObject.ShipToParty__c",getShipToNumber);
                        component.set("v.tileObject.Batch_Number__c",enterdNumber);
                    }
            helper.saveThisRecordThenFetchCoAs(component, event, helper,typeOfNumber,numberIsEntredOrSearched);
        }
            else if(enterdNumber != '' && enterdNumber != null && enterdNumber != undefined && !numberIsEntredOrSearched){
                let validate = false;
                
                if(typeOfNumber === 'Delivery Number' && (enterdNumber.length>10 || enterdNumber.length<8 || isNaN(enterdNumber))){
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Please Enter valid Delivery Number',
                        duration:'5000',
                        key: 'info_alt',
                        type: 'Error',
                        
                    });
                    toastEvent.fire();
                }
                else if(typeOfNumber === 'Delivery Number' && enterdNumber.length<=10 && enterdNumber.length>=8 && !isNaN(enterdNumber)){
                    
                    if(enterdNumber.charAt(0)!=0 && enterdNumber.length<10){
                        enterdNumber ='0'+enterdNumber;
                        component.set("v.enteredInfo.EnterdNumber",enterdNumber);
                    }
                    component.set("v.tileObject.Delivery_Number__c",enterdNumber);
                    validate = true;
                }
                
                    else if((enterdNumber.length>10 || enterdNumber.length<8 ) && typeOfNumber === 'Sales Order Number'){
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'Please Enter valid Sales Order Number',
                            duration:'5000',
                            key: 'info_alt',
                            type: 'Error',
                            
                        });
                        toastEvent.fire();
                    }
                        else if(enterdNumber.length>=8 && enterdNumber.length<=10 && typeOfNumber === 'Sales Order Number'){
                            
                            if(enterdNumber.length == 8){
                                enterdNumber = '00'+enterdNumber;
                                component.set("v.enteredInfo.EnterdNumber",enterdNumber);
                            }
                            else if(enterdNumber.length == 9){
                                enterdNumber = '0'+enterdNumber;
                                component.set("v.enteredInfo.EnterdNumber",enterdNumber);
                            }
                            
                            component.set("v.tileObject.Sales_Order_Number__c",enterdNumber);
                            validate = true;
                        }
                
                            else if(enterdNumber.length>50 && typeOfNumber === 'Purchase Order Number'){
                                toastEvent.setParams({
                                    title : 'Error',
                                    message: 'Please Enter valid Sales Order Number',
                                    duration:'5000',
                                    key: 'info_alt',
                                    type: 'Error',
                                    
                                });
                                toastEvent.fire();
                            }
                                else if(enterdNumber.length<50 && typeOfNumber === 'Purchase Order Number'){
                                    component.set("v.tileObject.Purchase_Order_Number__c",enterdNumber);
                                    validate = true;
                                }
                                    else if((enterdNumber.length>10 || enterdNumber.length<6)   && (typeOfNumber === 'Batch Number' || typeOfNumber === 'Child Batch Number')){
                                        toastEvent.setParams({
                                            title : 'Error',
                                            message: 'Please Enter valid Batch Number',
                                            duration:'5000',
                                            key: 'info_alt',
                                            type: 'Error',
                                            
                                        });
                                        toastEvent.fire();
                                    }
                                        else if(enterdNumber.length <=10 && enterdNumber.length>=6 && (typeOfNumber === 'Batch Number' || typeOfNumber === 'Child Batch Number')){
                                            let currentUser = component.get("v.typeOfUser");
                                            let getShipToNumber = component.get("v.enteredInfo.ShipToNumber");
                                            let shipToNumber = getShipToNumber.trim();
                                            
                                            if(currentUser === "INTERNAL_USER" && shipToNumber!=null && shipToNumber!= undefined && shipToNumber!='' && shipToNumber.length<=10 && shipToNumber.length>=6){
                                                let shipToLength = shipToNumber.length;
                                                
                                                if(shipToLength === 6){
                                                    shipToNumber= '0000'+shipToNumber;
                                                }else if(shipToLength === 7){
                                                    shipToNumber= '000'+shipToNumber;
                                                }else if(shipToLength === 8){
                                                    shipToNumber= '00'+shipToNumber;
                                                }
                                                    else if(shipToLength === 9){
                                                        shipToNumber= '0'+shipToNumber;
                                                    }
                                                component.set("v.enteredInfo.ShipToNumber",shipToNumber);
                                                component.set("v.tileObject.ShipToParty__c",shipToNumber);
                                                component.set("v.tileObject.Batch_Number__c",enterdNumber);
                                                validate = true;
                                            }
                                            
                                            else{
                                                component.set("v.tileObject.Batch_Number__c",enterdNumber);
                                                validate = true;
                                            }   
                                        }
                
                if(validate){
                    
                    helper.saveThisRecordThenFetchCoAs(component, event, helper,typeOfNumber,numberIsEntredOrSearched);
                }    
            }
        
        
        
    },
    getToggleStatus : function(component, event, helper) {
        let togglestatus = component.find("toggleToSwitch");
        let getStatus = togglestatus.get("v.checked");
        let selectValue = component.get("v.enteredInfo.TypeOfNumber");
        let typeOfUser = component.get("v.enteredInfo.TypeOfNumber");
        component.set("v.enteredInfo.IsUserUseSearchFunctionality",false);
        if(getStatus){
            helper.setLookupAttributesValue(component, event, helper,selectValue,getStatus,typeOfUser);
        }
        else{
            component.set("v.setToggleStatus",getStatus);
            component.set("v.searchKey",'');
        }
        
        
    },
    setLookupAttributes : function(component, event, helper) {
        
        component.set("v.setToggleStatus",true);
        
        let selectValue = component.get("v.enteredInfo.TypeOfNumber");
        let togglestatus = component.get("v.setToggleStatus");
        let typrOfUser = component.get("v.typeOfUser");
        
        component.set("v.enteredInfo.EnterdNumber",'');
        component.set("v.enteredInfo.ShipToNumber",'');
        component.set("v.enteredInfo.IsUserUseSearchFunctionality",false);
        
        if(typrOfUser === 'INTERNAL_USER' && selectValue.includes('Batch')){
            component.set("v.enableShipToField",true);
        }else{
            component.set("v.enableShipToField",false);
        }
        
        if(togglestatus){
            let clearSelctedValue = component.find("SearchNumberInSF"); 
            clearSelctedValue.ClearSelection();  
            helper.setLookupAttributesValue(component, event, helper,selectValue,togglestatus);
        }
    },
    handleLookupSelectEvent : function(component, event, helper) {
        
        let selectedrecordLabel = event.getParam("recordLabel");
        let getTypeOfNumber = event.getParam("TypeOfNumber");
        
        if(getTypeOfNumber === 'SHIPTO_NUMBER'){
            component.set("v.enteredInfo.ShipToNumber",selectedrecordLabel);
            component.set("v.searchShipTo",'');
        }
        else{
            component.set("v.enteredInfo.EnterdNumber",selectedrecordLabel);
            component.set("v.enteredInfo.IsUserUseSearchFunctionality",true);
            component.set("v.searchKey",'');
        }
    },
    handleNotifierEvent : function(component, event, helper){
        
        let selectedrecordLabel = event.getParam("recordLabel");
        let getTypeOfNumber = event.getParam("TypeOfNumber");
        
        if(selectedrecordLabel === '' && getTypeOfNumber === 'SHIPTO_NUMBER'){
            component.set("v.enteredInfo.ShipToNumber",'');    
        }
        else if(selectedrecordLabel === '' && getTypeOfNumber !== 'SHIPTO_NUMBER'){
            component.set("v.enteredInfo.EnterdNumber",''); 
            component.set("v.enteredInfo.IsUserUseSearchFunctionality",false);
        }
        
    },
    filePreview: function(component, event, helper) {
        var contentId =event.currentTarget.id;
        var navService = component.find("navService");
        $A.get('e.lightning:openFiles').fire({
            recordIds: [contentId]
        });
        
        /*var pageReference  = ({
            type: 'standard__namedPage',
            attributes: {
            pageName: 'filePreview'
            },
            state : {
            selectedRecordId:contentId
            }
            });    
            event.preventDefault();
            navService.navigate(pageReference);*/
     }
                
                /*handleMouseOver : function(component, event, helper){
            var tooltipId = event.target.getAttribute("data-tooltipId");
            console.log(tooltipId);
            $A.util.removeClass(component.find(tooltipId), 'slds-fall-into-ground');
            $A.util.addClass(component.find(tooltipId), 'slds-rise-from-ground');
            },
            
            handleMouseOut : function(component, event, helper){
            
            var tooltipId = event.target.getAttribute("data-tooltipId");
            $A.util.removeClass(component.find(tooltipId), 'slds-rise-from-ground');
            $A.util.addClass(component.find(tooltipId), 'slds-fall-into-ground');
            }*/
})