({
    setDataOnInit: function(component, event, helper) {
        var action = component.get("c.getDataOnInit");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var result = response.getReturnValue();
                for(var x in result){
                    result[x]['index'] = x;
                    result[x]['readOnly'] = true;
                    result[x]['quesReadOnly'] = true;
                }
                result.push({'readOnly': false, 'quesReadOnly': false, 'index': result.length, 'quesName': 'Other', 'ratingone': '1', 'ratingtwo': '1', 'comments': ''});
                component.set("v.keyAreaList", result);
                const getWityRelatedDataAction = component.get("c.getVisitReportWityRelatedData");
                getWityRelatedDataAction.setParams({
                    visitReportId : component.get("v.recordId")
                });
                getWityRelatedDataAction.setCallback(this, function(getRelatedWityResponse) {
                    const getWityRelatedStatus = getRelatedWityResponse.getState();
                    let relatedWityData = [];
                    if (getWityRelatedStatus === "SUCCESS") {
                        relatedWityData = getRelatedWityResponse.getReturnValue();
                    }
                    console.log('relatedWityData: ', relatedWityData);
                    if (relatedWityData && relatedWityData.length > 0) {
                        component.set("v.metaDatalist", relatedWityData);
                        component.set("v.metaDataLength",relatedWityData.length);
                    }
                    else {
                        let addRow = {};
                        addRow['readOnly'] = false;
                        addRow['quesReadOnly'] = false;
                        addRow['index'] = 0;
                        addRow['quesName'] = result[0]['quesName'];
                        addRow['ratingone'] = '1';
                        addRow['ratingtwo'] = '1';
                        addRow['comments'] = '';
                        component.set("v.metaDatalist", [addRow]);
                        component.set("v.metaDataLength",1);
                    }
                });
                $A.enqueueAction(getWityRelatedDataAction);
                //B2B144
                var getAccPlanWityRelDataAction = component.get("c.getWityAccPlanWityRelatedData");
                getAccPlanWityRelDataAction.setParams({ accRecId: component.get("v.recordId") });
                
                getAccPlanWityRelDataAction.setCallback(this, function(response) {
                    const getWityRelatedStatus = getAccPlanWityRelDataAction.getState();
                    let relatedAccPlanWityData = [];
                    if (getWityRelatedStatus === "SUCCESS") {
                        relatedAccPlanWityData = getAccPlanWityRelDataAction.getReturnValue();
                    }
                    console.log('relatedAccPlanWityData: ', relatedAccPlanWityData);
                    if (relatedAccPlanWityData && relatedAccPlanWityData.length > 0) {
                        component.set("v.accPlanMetaDatalist", relatedAccPlanWityData);
                        component.set("v.accPlanMetaDataLength",relatedAccPlanWityData.length);
                    }
                });
                
                $A.enqueueAction(getAccPlanWityRelDataAction);
                //B2B144
                //B2B173
                var getOpportunityStage = component.get("c.getOpportunityStage");
                getOpportunityStage.setParams({ recordId: component.get("v.recordId") });
                getOpportunityStage.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var oppStage = response.getReturnValue();
                        component.set("v.oppStage", oppStage);
                        if(oppStage === "Transfer To Running Business"){
                            var getOppStageWITYData = component.get("c.getOppStageWITYData");
                            getOppStageWITYData.setParams({ recordId: component.get("v.recordId") });
                            getOppStageWITYData.setCallback(this, function(response) {
                                const getWityRelatedStatus = getOppStageWITYData.getState();
                                let relatedOppWityData = [];
                                if (getWityRelatedStatus === "SUCCESS") {
                                    relatedOppWityData = getOppStageWITYData.getReturnValue();
                                }
                                console.log('relatedOppWityData: ', relatedOppWityData);
                                if (relatedOppWityData && relatedOppWityData.length > 0) {
                                    component.set("v.oppStageMetaDatalist", relatedOppWityData);
                                }
                            });
                            $A.enqueueAction(getOppStageWITYData);

                        }
                    }
                });
                $A.enqueueAction(getOpportunityStage);
                //B2B173
            }
        });
        $A.enqueueAction(action);
        let importantToCustomerList = [{'label': '1', 'value' : 1},{'label': '2', 'value' : 2},{'label': '3', 'value' : 3},{'label': '4', 'value' : 4},{'label': '5', 'value' : 5}];
        component.set("v.importantToCustomerList", importantToCustomerList);
        let currentPerformanceList = [{'label': '1', 'value' : 1},{'label': '2', 'value' : 2},{'label': '3', 'value' : 3},{'label': '4', 'value' : 4},{'label': '5', 'value' : 5},{'label': '6', 'value' : 6},{'label': '7', 'value' : 7},{'label': '8', 'value' : 8},{'label': '9', 'value' : 9},{'label': '10', 'value' : 10}];
        component.set("v.currentPerformanceList", currentPerformanceList);
    },
    saveData : function(component, event, helper){
        var allValid = component.find("dataVal").reduce(function(validSoFar , inputCmp){
           inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        },true);
        if(allValid){
            console.log(component.get("v.metaDatalist"));
            console.log(component.get("v.recordId"));
            var action = component.get("c.saveRecords");
            action.setParams({
                recordList : JSON.stringify(component.get("v.metaDatalist")),
                vReportId : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var addRow = {};
                    addRow['readOnly'] = false;
                    addRow['quesReadOnly'] = false;
                    addRow['index'] = 0;
                    addRow['quesName'] = result[0]['quesName'];
                    addRow['ratingone'] = '1';
                    addRow['ratingtwo'] = '1';
                    addRow['comments'] = '';
                    component.set("v.metaDatalist", [addRow]);
                    var result = response.getReturnValue();
                    // helper.closeModal(component, event, helper);
                }
            });
            $A.enqueueAction(action);  
        }
        else{
            //alert("Please fill the mandatory fields in order to save the record!");
            var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
            title : 'Error',
            message: 'Please provide proper values in the field to save the record!!',
            duration:' 5000',
            key: 'utility:error',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
        }
        
    },
    upsertData : function(component, event, helper){
        let componentsExist = component.find("dataVal");
        console.log('allValid: ', componentsExist);
        var allValid = componentsExist ? componentsExist.reduce(function(validSoFar , inputCmp){
           inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get("v.validity").valid;
        },true) : true;
        console.log('allValid: ', allValid);
        if(allValid){
            let wityRecIdsToDelete = [];
            let toDeleteList = component.get("v.linesToDeleteList");
            if (toDeleteList && toDeleteList.length > 0) {
                toDeleteList.forEach((deleteItem => {
                    wityRecIdsToDelete.push(deleteItem.itemId);
                }));
            }
            console.log('wityRecIdsToDelete: ', wityRecIdsToDelete);
            if (wityRecIdsToDelete.length > 0) {
                let deleteWityScoringAction = component.get("c.deleteWityScoringRecords");
                deleteWityScoringAction.setParams({
                    wityScoringIds : wityRecIdsToDelete
                });
                deleteWityScoringAction.setCallback(this, function(response) {
                    var status = response.getState();
                    if (status === "SUCCESS") {
                        component.set("v.linesToDeleteList",[]);
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                            title : 'Success',
                            message: 'Successfully deleted WITY records.',
                            duration:' 5000',
                            key: 'utility:success',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        if (componentsExist) {
                            this.upsertRecordsAction(component, event, helper);  
                        }
                    }
                    else {
                        var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                            title : 'Error',
                            message: 'Failed to delete WITY Scoring records. Please try again.',
                            duration:' 5000',
                            key: 'utility:error',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(deleteWityScoringAction);
            }
            else {
                if (componentsExist) {
                    this.upsertRecordsAction(component, event, helper);  
                } 
            } 
             
        }
        else{
            //alert("Please fill the mandatory fields in order to save the record!");
            var toastEvent = $A.get("e.force:showToast");
        	toastEvent.setParams({
            title : 'Error',
            message: 'Please provide proper values in the field to save the record!!',
            duration:' 5000',
            key: 'utility:error',
            type: 'error',
            mode: 'dismissible'
        });
        toastEvent.fire();
        }
        
    },
    upsertRecordsAction: function(component, event, helper) {
        console.log(component.get("v.metaDatalist"));
        console.log(component.get("v.recordId"));
        var action = component.get("c.upsertRecords");
        let selectedAccountPlanId = component.get("v.selectedAccountPlanId");//B2B144
        let accountId = selectedAccountPlanId ? selectedAccountPlanId : '';//B2B144
        let curOppStageVal = component.get("v.oppStage");//B2B173
        let curOppStage = curOppStageVal ? curOppStageVal : '';//B2B173
        action.setParams({
            recordList : JSON.stringify(component.get("v.metaDatalist")),
            vReportId : component.get("v.recordId"),
            accountId : accountId,
            curOppStage : curOppStage
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                let upsertedWityData = response.getReturnValue();
                console.log('upserted wity: ', upsertedWityData);
                component.set("v.metaDatalist", upsertedWityData);
                component.set("v.metaDataLength",upsertedWityData.length);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    title : 'Success',
                    message: 'Successfully stored WITY details.',
                    duration:' 5000',
                    key: 'utility:success',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    title : 'WITY Error',
                    message: 'Error happened while storing WITY details. Please try again.',
                    duration:' 5000',
                    key: 'utility:error',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action); 
    },
    closeModal : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    checkAllRows : function(component, event, helper){
        var data = component.get("v.metaDatalist");
        const cmps = component.find("checkId");
        
        if(event.getSource().get('v.checked')){
            for(var x in data){
                data[x]['readOnly'] = false;
            }
            if ($A.util.isArray(cmps)) {
            cmps.forEach(cmp => {
                cmp.set("v.checked", true);
            })
            }
        }
        if(!event.getSource().get('v.checked')){
            for(var x in data){
                data[x]['readOnly'] = true;
            }
                if ($A.util.isArray(cmps)) {
            cmps.forEach(cmp => {
                cmp.set("v.checked", false);
            })
            }
        }
        component.set("v.metaDatalist",data);
    },
    deleteRow : function(component, event, helper){
        var lastIndex=event.currentTarget.getAttribute("data-index");
        var itemId=event.currentTarget.getAttribute("data-itemid");
        console.log(lastIndex, itemId);
        var toDeleteList = component.get("v.linesToDeleteList");
        let questions = component.get("v.keyAreaList");
        console.log('toDeleteList before: ', toDeleteList);
        if (itemId && itemId != '') {
            if (toDeleteList && toDeleteList.length > 0) {
                toDeleteList.push({"lastIndex": lastIndex, "itemId": itemId});
            }
            else {
                toDeleteList = [{"lastIndex": lastIndex, "itemId": itemId}];
            }
            component.set("v.linesToDeleteList",toDeleteList);  
            console.log('toDeleteList after: ', toDeleteList);
            // var action = component.get("c.deleteWityScoringRecord");
            // action.setParams({
            //     wityScoringId : itemId
            // });
            // action.setCallback(this, function(response) {
            //     var status = response.getState();
            //     if (status === "SUCCESS") {
            //         var data = component.get("v.metaDatalist");
            //         component.set("v.metaDataLength",data.length-1);
            //         data.splice(lastIndex,1);
            //         component.set("v.metaDatalist",data);  
            //     }
            //     else {
            //         var toastEvent = $A.get("e.force:showToast");
            //             toastEvent.setParams({
            //             title : 'Error',
            //             message: 'Failed to delete WITY Scoring records. Please try again.',
            //             duration:' 5000',
            //             key: 'utility:error',
            //             type: 'error',
            //             mode: 'dismissible'
            //         });
            //         toastEvent.fire();
            //     }
            // });
            // $A.enqueueAction(action); 
        }
        var data = component.get("v.metaDatalist");
        component.set("v.metaDataLength",data.length-1);
        data.splice(lastIndex,1);
        component.set("v.metaDatalist",data); 
        // if (data.length === 0) {
        //     let addRow = {};
        //     addRow['readOnly'] = false;
        //     addRow['quesReadOnly'] = false;
        //     addRow['index'] = 0;
        //     addRow['quesName'] = questions[0]['quesName'];
        //     addRow['ratingone'] = '1';
        //     addRow['ratingtwo'] = '1';
        //     addRow['comments'] = '';
        //     component.set("v.metaDatalist", [addRow]);
        //     component.set("v.metaDataLength",1);
        // }
    },
    addRow : function(component, event, helper){
        var keyAreaList = component.get("v.keyAreaList");
        var temp = component.get("v.metaDatalist");
        var addRow = {};
        addRow['readOnly'] = false;
        addRow['quesReadOnly'] = false;
        addRow['index'] = temp.length;
        addRow['quesName'] = keyAreaList[0]['quesName'];
        addRow['ratingone'] = '1';
        addRow['ratingtwo'] = '1';
        addRow['comments'] = '';
        if(temp.length > 0 ){
            temp.push(addRow);
        }
        component.set("v.metaDatalist", temp);
        component.set("v.metaDataLength",temp.length);
    },
    //B2B144           
    fetchRecordTypeName: function(component) {
        var action = component.get("c.getRecordTypeName");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                component.set("v.recordTypeName", response.getReturnValue());
            } else {
                console.error("Failed to get record type name with state: " + status);
            }
        });
        $A.enqueueAction(action);
    },

    searchAccountPlans : function(component, searchTerm) {
        var action = component.get("c.getAccountPlans");
        action.setParams({
            searchTerm: searchTerm,
            recordId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.searchResults", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    //B2B144 
});