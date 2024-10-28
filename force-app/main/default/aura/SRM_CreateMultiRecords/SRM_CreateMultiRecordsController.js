({
	handleSubmit : function(cmp, event, helper) {
         var radioGrpValue = cmp.get("v.value");
        
        if(radioGrpValue == 'Meeting Sumary'){
            //cmp.set('v.openAnalytics', true);
            var createRecordEvent = $A.get("e.force:createRecord");
           	createRecordEvent.setParams({
				"entityApiName": "Meeting_Notes__c"
            });
            createRecordEvent.fire();
        }
        if(radioGrpValue == 'option3'){
            var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "https://frieslandcampinaconnect.my.salesforce.com/analytics/wave/dashboard?assetId=0FK4H000000Lan1WAC&orgId=00D58000000ZNVx&loginHost=um3.salesforce.com&urlType=sharing&pageId=23ad7ede-8f6a-4c64-98e9-7e9ad9e449cf&savedViewId=8wk4H0000000272QAA&analyticsContext=analyticsTab"
    });
    urlEvent.fire();
        }
        if(radioGrpValue == 'Supplier KPI New'){
            var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": "https://frieslandcampinaconnect.my.salesforce.com/analytics/wave/dashboard?assetId=0FK4H000000LamwWAC&orgId=00D58000000ZNVx&loginHost=um3.salesforce.com&urlType=sharing&pageId=e0c5f409-8d12-4f11-9913-765504b12b91&savedViewId=8wk4H000000026nQAA&analyticsContext=analyticsTab"
    });
    urlEvent.fire();
        }
        if(radioGrpValue == 'task'){
            //cmp.set('v.openAnalytics', true);
            var createRecordEvent = $A.get("e.force:createRecord");
           	createRecordEvent.setParams({
				"entityApiName": "Task",
                 "recordTypeId": "0124H0000002WTfQAM"
            });
            createRecordEvent.fire();
        }
        if(radioGrpValue == 'Supplier Hub'){
            cmp.set('v.isModalOpen', true);
            
        }
        if(radioGrpValue == 'track KPI'){
            cmp.set('v.openKpiModel', true);
        }
    	console.log('radioGrpValue',radioGrpValue);
     },
     
    handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
    },
    
    closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
         component.set("v.openKpiModel", false);
       
   },
    handleClick: function(cmp, event, helper){
        //alert(cmp.get('v.supplierName'));
        var parm = '';
        var selectedType = cmp.get('v.selectedType');
        if(selectedType == 'Supplier Name'){
            parm = cmp.get('v.supplierName');
        }else if (selectedType == 'Duns Number'){
             parm = cmp.get('v.dunsNumber');
        }else if (selectedType == 'Vendor BK Number'){
             parm = cmp.get('v.vendorNumber');
        }
         
        /*cmp.set('v.mycolumns', [
            { label: 'Supplier name', fieldName: 'Supplier_Name__c', type: 'text'},
             { label: 'Duns Number', fieldName: 'DUNS_Number__c', type: 'text'}
            
        ]);*/

        var action = cmp.get("c.getSUpplier"); // calling the server side action using c notifier 
        action.setParams({ "searchText" : parm , "searchType": selectedType}); // setting the arguments of server action 
    action.setCallback(this, function(response) { 
        var state = response.getState(); 
        if (state === "SUCCESS") { 
            console.log(JSON.stringify(response.getReturnValue()));
            cmp.set('v.mycolumns', [
            { label: 'Supplier name', fieldName: 'Supplier_Name__c', type: 'text'},
             { label: 'Duns Number', fieldName: 'DUNS_Number__c', type: 'text'},
                 { label: 'Segment', fieldName: 'Segment__c', type: 'text'}
            
        ]);
             cmp.set('v.mydata', response.getReturnValue());
        } 
        else { 
            console.log(state); 
        } 
    }); 
    $A.enqueueAction(action); 
    },
    onChangeSelect : function(cmp, event, helper) {
        var selectedItem = event.getSource().get("v.value");
       cmp.set('v.selectedType',selectedItem );
        //alert(selectedItem);
        if(selectedItem == 'Supplier Name'){
            cmp.set('v.ShownameSelect', true);
             cmp.set('v.showVersionSelect', false);
             cmp.set('v.ShowVendorSelect', false);
        }else if (selectedItem == 'Duns Number'){
             cmp.set('v.showVersionSelect', true);
             cmp.set('v.ShownameSelect', false);
             cmp.set('v.ShowVendorSelect', false);
        }else if (selectedItem == 'Vendor BK Number'){
             cmp.set('v.ShowVendorSelect', true);
            cmp.set('v.showVersionSelect', false);
             cmp.set('v.ShownameSelect', false);
        }
    },
    getSelectedName: function(cmp, event, helper){
           var selectedRows = event.getParam('selectedRows');
        //alert(JSON.stringify(selectedRows));
        for (var i = 0; i < selectedRows.length; i++){
            //alert("You selected: " + selectedRows[i].Id);
            var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
        "recordId":  selectedRows[i].Id
    });
    navEvt.fire();
        }
		/*var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
        "recordId": oppId
    });
    navEvt.fire();*/
    },
    
    onPicklistChange: function(cmp, event, helper){
        var myAttri = cmp.find("picklistField").get("v.value");
        if(myAttri == 'Amount'){
            cmp.set('v.showAmountValue', true);
            cmp.set('v.showNumberValue', false);
            cmp.set('v.showPercentageValue', false);
        }else if(myAttri == 'Number'){
             cmp.set('v.showAmountValue', false);
            cmp.set('v.showNumberValue', true);
            cmp.set('v.showPercentageValue', false);
        }else if (myAttri == 'Percentage'){
            cmp.set('v.showAmountValue', false);
            cmp.set('v.showNumberValue', false);
            cmp.set('v.showPercentageValue', true);
        }
    },
    handleSuccess : function(component, event, helper) {
    var payload = event.getParams().response;
    var navService = component.find("navService");

    var pageReference = {
        type: 'standard__recordPage',
        attributes: {
            "recordId": payload.id,
            "objectApiName": "Supplier_KPI__c",
            "actionName": "view"
        }
    }
    event.preventDefault();
    navService.navigate(pageReference);  
    }    
})