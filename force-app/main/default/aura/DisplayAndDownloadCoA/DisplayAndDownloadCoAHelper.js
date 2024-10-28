({
    
    checkUserOnInit : function(component, event, helper) {
        var action = component.get("c.IsCommunityUserCheck");
        action.setCallback(this,function(response){
            let state = response.getState();
            
            if(state==='SUCCESS'){
                let result = response.getReturnValue();
                component.set("v.typeOfUser",result);
                console.log('user-->'+result);
                helper.setTypeOfNumberListOnLoad(component,helper,result);
                helper.setLookupAttributesValue(component,helper,event,component.get("v.enteredInfo.TypeOfNumber"),true,result);
                component.set("v.showSpinner",false);
            }
            else{
                console.log('State-->'+state);
                console.log('error-->'+response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    setTypeOfNumberListOnLoad :function(component,helper,result){
        
        let typeOfNumberList =["Batch Number","Delivery Number","Purchase Order Number","Sales Order Number"/*,"Child Batch Number"*/];
        let setTypeOfNumber = [];
        
        if(result === "INTERNAL_USER")  {
            component.set("v.enteredInfo.TypeOfNumber","Delivery Number");
           /* let setLookupValuesForShipTo= {'objectAPIName':'','fieldAPIName':'','metaFieldsAPI':[],'whereFieldAPIName':'','isEnteredNumberIsUnique':true};
            
            setLookupValuesForShipTo.objectAPIName = 'Partner_Role__c';
            setLookupValuesForShipTo.fieldAPIName ='Target_Account__r.SAP_Number__c';
            setLookupValuesForShipTo.metaFieldsAPI = ['Target_Account__r.Name'];
            setLookupValuesForShipTo.whereFieldAPIName = 'Target_Account__r.SAP_Number__c';
            setLookupValuesForShipTo.isEnteredNumberIsUnique = false;
            setLookupValuesForShipTo.typeOfNumber = 'SHIPTO_NUMBER';
            component.set("v.setLookupForShipTo",setLookupValuesForShipTo);*/
        }else{
            component.set("v.enteredInfo.TypeOfNumber","Purchase Order Number");
        }      
        
        for(let i=0;i<typeOfNumberList.length;i++){
            
            let typeOfNumber = {
                "label":typeOfNumberList[i],
                "value":typeOfNumberList[i]
            }
            setTypeOfNumber.push(typeOfNumber);

        }
        component.set("v.setTypeOfNumberValue",setTypeOfNumber);
        //component.set("v.showSpinner",false);
    },
    saveThisRecordThenFetchCoAs : function(component, event, helper,typeOfNumber,numberIsEntredOrSearched) {
        
        var action = component.get("c.validateAndFetchCertificateofAnalysis");
        var checkUpdate = component.get("v.tileObject");
        var baseURl = component.get("v.baseUrl");
        let removeCurrentFiles = component.get("v.allCoAFilesRelated");
        removeCurrentFiles =[];
        //component.set("v.noOfFiles1",0);
        
        component.set("v.allCoAFilesRelated",removeCurrentFiles);
        component.set("v.showSpinner",true);
        
        action.setParams({
            "tile":checkUpdate,
            "baseURLSFDC":baseURl,
            "typeOfNumberSelected":typeOfNumber,
            "isUserUsedSearchFunctionality":numberIsEntredOrSearched
        });
        action.setCallback(this,function(response){
            let state = response.getState();
            
            if(state==='SUCCESS'){
                
                let result = response.getReturnValue();
                let errors = result.errorsInfo;
                let files= result.fileRecord;
                let toastEvent = $A.get("e.force:showToast");
                
                if(errors!=null && errors!='' && !files.length > 0){
                    component.set("v.showSpinner",false);
                    
                    let filesData = component.get("v.allCoAFilesRelated");
                    filesData =[];
                    
                    toastEvent.setParams({
                        title : 'Error',
                        message: errors,
                        duration:'8000',
                        key: 'info_alt',
                        type: 'Error',
                        
                    });
                    toastEvent.fire();
                    
                }
                else if(files.length>0){
                    component.set("v.showSpinner",false);
                    
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Number of Files Found '+files.length,
                        duration:'5000',
                        key: 'info_alt',
                        type: 'Success',
                        
                    });
                    toastEvent.fire();
                    component.set("v.allCoAFilesRelated",files);
                    
                    if(errors!=null && errors!='' && (errors=='Some of the Certificates under this Sales Order Number had errors and were not received. The technical team has been notified.' || errors == 'Some of the Certificates under this Purchase Order Number had errors and were not received. The technical team has been notified.')){
                        let toastEventForExceptionCase = $A.get("e.force:showToast");
                        toastEventForExceptionCase.setParams({
                            title : 'Error',
                            message: errors,
                            duration:'8000',
                            key: 'info_alt',
                            type: 'Error',
                            
                        });
                        toastEventForExceptionCase.fire();
                        
                    }
                }
                    else if((errors==null || errors=='') && files.length == 0){
                        component.set("v.showSpinner",false);
                        
                        toastEvent.setParams({
                            title : 'Error',
                            message: 'No certificates were found for the given '+ component.get("v.enteredInfo.TypeOfNumber")+'!',
                            duration:'5000',
                            key: 'info_alt',
                            type: 'Error',
                            
                        });
                        toastEvent.fire();
                        
                        component.set("v.allCoAFilesRelated",files);
                        
                    }
                
            }
            else if(state==='ERROR'){
                component.set("v.showSpinner",false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Not able to connect to server, please try after some time',
                    duration:'5000',
                    key: 'info_alt',
                    type: 'Error',
                    
                });
                toastEvent.fire();
                
                var errors = response.getError();
                console.log('state-->'+state);
                console.log('error-->'+errors)
            }
        });
        $A.enqueueAction(action);
    },
   /* setSpinnerTextForDifferentConditions : function(component,event,helper,stopSpinner,messageOnLoad){
        
        if(stopSpinner){
            component.set("v.showSpinner",false);
        }
        else{
            component.set("v.spinnerText",messageOnLoad);
        }
    },*/
    setLookupAttributesValue : function(component,event,helper,selectValue,togglestatus,typeOfUser){
        
        
        let setLookupValues= {'objectAPIName':'','fieldAPIName':'','metaFieldsAPI':[],'whereFieldAPIName':'','isEnteredNumberIsUnique':true};
        
                if(selectValue === 'Sales Order Number'){
                    setLookupValues.objectAPIName = 'Order';
                    setLookupValues.fieldAPIName ='SAP_Sales_Order_Number__c';
                    setLookupValues.whereFieldAPIName = 'SAP_Sales_Order_Number__c';
                    setLookupValues.isEnteredNumberIsUnique = true;
                    setLookupValues.typeOfNumber = selectValue;
                    component.set("v.setLookupFields",setLookupValues);
                }
                else if(selectValue === 'Purchase Order Number'){
                    setLookupValues.objectAPIName = 'Order';
                    setLookupValues.fieldAPIName ='PoNumber';
                    setLookupValues.metaFieldsAPI = ['PoDate'];
                    setLookupValues.whereFieldAPIName = 'PoNumber';
                    setLookupValues.isEnteredNumberIsUnique = false;
                    setLookupValues.typeOfNumber = selectValue;
                    component.set("v.setLookupFields",setLookupValues);
                }
                else if(selectValue === 'Delivery Number'){
                    setLookupValues.objectAPIName = 'Delivery__c';
                    setLookupValues.fieldAPIName ='SAP_Delivery_Number__c';
                    setLookupValues.whereFieldAPIName = 'SAP_Delivery_Number__c';
                    setLookupValues.isEnteredNumberIsUnique = true;
                    setLookupValues.typeOfNumber = selectValue;
                    component.set("v.setLookupFields",setLookupValues);
                }
                else if(selectValue.includes('Batch')){
                    
                    let childOrMotherBatch = selectValue.includes('Child')?'SAP_Batch_Number__c':'Mother_Batch_Number__c';
                    
                    setLookupValues.objectAPIName = 'Delivery_Line_Item__c';
                    setLookupValues.fieldAPIName =childOrMotherBatch;
                    setLookupValues.metaFieldsAPI = [childOrMotherBatch];
                    setLookupValues.whereFieldAPIName = childOrMotherBatch;
                    setLookupValues.isEnteredNumberIsUnique = false;
                    setLookupValues.typeOfNumber = selectValue;
                    component.set("v.setLookupFields",setLookupValues);
                }
        		if(typeOfUser === "INTERNAL_USER")  {
                    
                    let setLookupValuesForShipTo= {'objectAPIName':'','fieldAPIName':'','metaFieldsAPI':[],'whereFieldAPIName':'','isEnteredNumberIsUnique':true};
                    
                    setLookupValuesForShipTo.objectAPIName = 'Partner_Role__c';
                    setLookupValuesForShipTo.fieldAPIName ='Target_Account__r.SAP_Number__c';
                    setLookupValuesForShipTo.metaFieldsAPI = ['Target_Account__r.Name'];
                    setLookupValuesForShipTo.whereFieldAPIName = 'Target_Account__r.SAP_Number__c';
                    setLookupValuesForShipTo.isEnteredNumberIsUnique = false;
                    setLookupValuesForShipTo.typeOfNumber = 'SHIPTO_NUMBER';
                    component.set("v.setLookupForShipTo",setLookupValuesForShipTo);
        		}
        
        		component.set("v.setToggleStatus",togglestatus);  
        
        
    },
    getCurrentUserDetailsAndCreateMissingCoACase : function (component, event, helper){
        
        var action = component.get("c.getRecordTypeAndCurrentUserDetails");
        var enteredInfo = component.get("v.enteredInfo");
        var enterdNumber = enteredInfo.EnterdNumber.trim();
        var typeOfNumber = enteredInfo.TypeOfNumber;
        var setEnteredNumber = {'Delivery_Number__c':'','Sales_Order_Number__c':'','Purchase_Order_Number__c':'','Batch_Number__c':''};
        
        if(typeOfNumber === 'Delivery Number'){
            setEnteredNumber.Delivery_Number__c = enterdNumber;
        }
        else if(typeOfNumber === 'Sales Order Number'){
            setEnteredNumber.Sales_Order_Number__c = enterdNumber;
        }
            else if(typeOfNumber === 'Purchase Order Number'){
                setEnteredNumber.Purchase_Order_Number__c = enterdNumber;
            }
                else if(typeOfNumber.includes('Batch')){
                    setEnteredNumber.Batch_Number__c = enterdNumber;
                }
        
        action.setCallback(this,function(response){
            let state = response.getState();
            
            if(state==='SUCCESS'){
                
                let result = response.getReturnValue();
                
                let cased={ /*Support_Type__c :"Missing COA",*/AccountId :result.customerLocation,OwnerId :result.caseOwnereId,ContactId : result.contactName, 
                           Description : "• Name supply point : "+"\n"+
                           "• PO Number : "+setEnteredNumber.Purchase_Order_Number__c+"\n"+
                           "• Sales Order Number : "+setEnteredNumber.Sales_Order_Number__c+"\n"+
                           "• Delivery Number : "+setEnteredNumber.Delivery_Number__c+"\n"+
                           "• Batch number : "+setEnteredNumber.Batch_Number__c+"\n"+
                           "• Article description : "+"\n"+
                           "• Comments : ",
                           Subject : "Missing COA",Parent_Account__c:result.accountName };
                
                let createRecordEvent = $A.get("event.force:createRecord");
                createRecordEvent.setParams({ 
                    "entityApiName": "Case",
                    "recordTypeId":result.missingCoARecordType,
                    'defaultFieldValues': cased,
                    "navigationLocation": "RELATED_LIST"
                });
                createRecordEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})