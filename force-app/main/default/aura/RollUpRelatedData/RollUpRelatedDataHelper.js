({
	callAction: function(component, helper, actionName, params, callback) {
		var action = component.get(actionName);
		action.setParams(params);
		action.setCallback(this, response => {
			var state = response.getState();
            console.log('response '+ JSON.stringify(response.getReturnValue()));
			if (component.isValid() && state === "SUCCESS") {
				callback(response.getReturnValue());
			} else {
				if (state === "INCOMPLETE") {
					helper.showToast("Error!", "User is offline, device doesn't support drafts.", "error", "sticky");
				} else if (state === "ERROR") {
					helper.showToast(
						"Error!",
						"An error has occured  during loading related object record Id. Error: " + response.getError()[0].message,
						"error",
						"sticky"
					);
				} else {
					helper.showToast("Error!", "Unknown problem, state: " + state + ", error: " + response.getError()[0].message, "error", "sticky");
				}
				component.set("v.showSpinner", false);
			}
		});
		$A.enqueueAction(action);
	},
	showToast: function(toastTitle, toastMessage, toastType, toastMode) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title: toastTitle,
			message: toastMessage,
			type: toastType,
			mode: toastMode
		});
		toastEvent.fire();
	},
        removeBook: function (cmp, row) {
        var rows = cmp.get('v.data');
        var rowIndex = rows.indexOf(row);

        rows.splice(rowIndex, 1);
        cmp.set('v.data', rows);
    },
        editRecord : function(component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        $A.get("e.force:editRecord").setParams({"recordId": recordId}).fire();
    },
        viewRecord : function(cmp, event){
            var row = event.getParam('row');
        var recordId = row.Id;
             var viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + recordId
            });
            viewRecordEvent.fire();
        },
        deleteRecord : function(component, event) {
            var selectedTab = component.get('v.selectedTab');
            if(selectedTab == 'contracts'){
                var action = component.get("c.delContract");
            }else if(selectedTab == 'projects'){
                var action = component.get("c.delprojectRecord");
            }else if(selectedTab == 'claims'){
                var action = component.get("c.delClaim");
            }else if(selectedTab == 'complaints'){
                var action = component.get("c.delComplaint");
            }else if(selectedTab == 'cPlans'){
                var action = component.get("c.delCplan");
            }
        var recInContext = event.getParam('row');        
        
        action.setParams({
            "recordId": recInContext
        });
        action.setCallback(this, function(response) {     
            if (response.getState() === "SUCCESS" ) {
                if(selectedTab == 'contracts'){
               var rows = component.get('v.mydata');
                var rowIndex = rows.indexOf(recInContext);
                rows.splice(rowIndex, 1);
                component.set('v.mydata', rows);
            }else if(selectedTab == 'projects'){
                 var rows = component.get('v.mydataProj');
                var rowIndex = rows.indexOf(recInContext);
                rows.splice(rowIndex, 1);
                component.set('v.mydataProj', rows);
            }else if(selectedTab == 'claims'){
                 var rows = component.get('v.mydataClaims');
                var rowIndex = rows.indexOf(recInContext);
                rows.splice(rowIndex, 1);
                component.set('v.mydataClaims', rows);
            }else if(selectedTab == 'complaints'){
                 var rows = component.get('v.mydataComplaints');
                var rowIndex = rows.indexOf(recInContext);
                rows.splice(rowIndex, 1);
                component.set('v.mydataComplaints', rows);
            }else if(selectedTab == 'cPlans'){
                 var rows = component.get('v.mydataCplans');
                var rowIndex = rows.indexOf(recInContext);
                rows.splice(rowIndex, 1);
                component.set('v.mydataCplans', rows);
            }
                
                this.showToast("Success!","success","The record has been delete successfully.");
            }
            else{
                this.showToast("ERROR","error",JSON.stringify(response.getError())); 
            }
        });
        $A.enqueueAction(action);
    },
        sortData: function (cmp, fieldName, sortDirection) {
        var fname = fieldName;
             var selectedTab = cmp.get('v.selectedTab');
            if(selectedTab == 'contracts'){
               var data = cmp.get("v.mydata");
            }else if(selectedTab == 'projects'){
                var data = cmp.get("v.mydataProj");
                
            }else if(selectedTab == 'claims'){
                var data = cmp.get("v.mydataClaims");
            }else if(selectedTab == 'complaints'){
                var data = cmp.get("v.mydataComplaints");
            }else if(selectedTab == 'cPlans'){
                var data = cmp.get("v.mydataCplans");
            }else if(selectedTab == 'categories'){
                var data = cmp.get("v.mydataCategories");
            }else if(selectedTab == 'meetingSummary'){
                var data = cmp.get("v.mydataMeetingSummaries");
            }else if(selectedTab == 'meetingStructure'){
                var data = cmp.get("v.mydataMeetingStructures");
            }else if(selectedTab == 'VendorBK'){
                var data = cmp.get("v.mydataVendorBks");
            }else if(selectedTab == 'Risk'){
                var data = cmp.get("v.mydataRisks");
            }
        
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        if(selectedTab == 'contracts'){
              
            cmp.set("v.mydata", data);
            }else if(selectedTab == 'projects'){
                
                cmp.set("v.mydataProj", data);
            }else if(selectedTab == 'claims'){
                 cmp.set("v.mydataClaims", data);
                
            }else if(selectedTab == 'complaints'){
                 cmp.set("v.mydataComplaints", data);
                
            }else if(selectedTab == 'cPlans'){
                 cmp.set("v.mydataCplans", data);
                
            }else if(selectedTab == 'categories'){
                 cmp.set("v.mydataCategories", data);
                
            }else if(selectedTab == 'VendorBK'){
                 cmp.set("v.mydataVendorBks", data);
                
            }else if(selectedTab == 'meetingSummary'){
                 cmp.set("v.mydataMeetingSummaries", data);
                
            }else if(selectedTab == 'meetingStructure'){
                 cmp.set("v.mydataMeetingStructures", data);
                
            }else if(selectedTab == 'Risk'){
                 cmp.set("v.mydataRisks", data);
                
            }
        //cmp.set("v.mydata", data);
    },
    sortBy: function (field, reverse) {
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    fetchClaimsData : function(component, event, helper) {
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        component.set('v.mycolumnsClaims', [
                { label: 'Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                                         { label: 'Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
	
            { label: 'Supplier Name', fieldName: 'Supplier_Name__c', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
            	{ label: 'Cost', fieldName: 'Cost__c', type: 'text',sortable:true},
                { label: 'Comments', fieldName: 'Comments__c', type: 'text',sortable:true},
                { label: 'Deadline', fieldName: 'Deadline__c', type: 'text',sortable:true},
                { type: 'action', typeAttributes: { rowActions: actions } }
            ]);
		this.callAction(component, helper, "c.collateAllSupplierClaims", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('claimsdata####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                record.SupplierlinkName = '/'+record.Supplier__c;
                record.SupplierNumber = record.Supplier__r.Name;
            });
				component.set("v.mydataClaims", result);			
            }
        });
          
	},
        fetchProjectdata: function(cmp, event, helper){
            var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
         cmp.set('v.mycolumnsProj', [
                { label: 'Name name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                             { label: 'Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},

             	{ label: 'Supplier Name', fieldName: 'Supplier_Name__c', type: 'text',sortable:true},   
             { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
             	{ label: 'Phase', fieldName: 'Phase__c', type: 'text',sortable:true},                
                { label: 'Project Goal', fieldName: 'Project_Goal__c', type: 'text',sortable:true},
                { label: 'Status', fieldName: 'Status__c', type: 'text',sortable:true},
                { label: 'Location', fieldName: 'locationName', type: 'text',sortable:true},
             { label: 'Start Date', fieldName: 'Start_Date__c', type: 'text',sortable:true},
             { label: 'FYI approved', fieldName: 'FYI_approved__c', type: 'text',sortable:true},
                { type: 'action', typeAttributes: { rowActions: actions } }
            ]);
        this.callAction(cmp, helper, "c.collateAllSupplierProjects", { recordId: cmp.get('v.recordId')}, function(result) {
			if (result) {
                console.log('############### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier__c ==  cmp.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                if(record.Location__c !== undefined ){
                     record.locationName = record.Location__r.Name;
                }
               record.SupplierlinkName = '/'+record.Supplier__c;
                record.SupplierNumber = record.Supplier__r.Name;
                
            });
				cmp.set("v.mydataProj", result);			
            }
		});
    },
    
        fetchComplaintsData : function(component, event, helper) {
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        component.set('v.mycolumnsComplaints', [
                { label: 'Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                { label: 'Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},

            	{ label: 'Supplier Name', fieldName: 'Supplier_Name__c', type: 'text',sortable:true},   
             { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
            	{ label: 'Category Name', fieldName: 'Category_Name__c', type: 'text',sortable:true},
                { label: 'Category Group Name', fieldName: 'Category_Group_Name__c', type: 'text',sortable:true},
                { label: 'Category Subgroup', fieldName: 'categorySubGroup', type: 'text',sortable:true},
            	{ label: 'Description', fieldName: 'Description__c', type: 'text',sortable:true},
            	{ label: 'Current Age', fieldName: 'Current_Age__c', type: 'text',sortable:true},
                { type: 'action', typeAttributes: { rowActions: actions } }
            ]);
		this.callAction(component, helper, "c.collateAllSupplierComplaints", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('complaints####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                record.categorySubGroup = record.Category_Subgroup__r.Name;
                                if(record.Supplier__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                record.SupplierlinkName = '/'+record.Supplier__c;
                record.SupplierNumber = record.Supplier__r.Name;
               
            });
				component.set("v.mydataComplaints", result);			
            }
        });
          
	},
        fetchCplansData : function(component, event, helper) {
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
        component.set('v.mycolumnsCplans', [
                { label: 'Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            { label: 'Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
				{ label: 'Supplier Name', fieldName: 'Supplier_Name__c', type: 'text',sortable:true},
				{ label: 'Source', fieldName: 'Source__c', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
                { label: 'Material', fieldName: 'materialName', type: 'text',sortable:true},
                { label: 'Status', fieldName: 'Status__c', type: 'text',sortable:true},
            	{ label: 'Description Of Contingency Measure', fieldName: 'Description_Of_Contingency_Measure__c', type: 'text',sortable:true},
                { type: 'action', typeAttributes: { rowActions: actions } }
            ]);
		this.callAction(component, helper, "c.collateAllSupplierCPlans", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('mydataCplans####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier_Hub__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                if(record.Material__c !== undefined){
                    record.materialName = record.Material__r.Name;
                }
                record.SupplierlinkName = '/'+record.Supplier_Hub__c;
                record.SupplierNumber = record.Supplier_Hub__r.Name;
            });
				component.set("v.mydataCplans", result);			
            }
        });
          
	},
        fetchCategoryData : function(component, event, helper) {
        
        component.set('v.mycolumnsCategories', [
            { label: ' Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            { label: ' Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
            		{ label: 'Supplier Name', fieldName: 'supplierName', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
                { label: 'Combined Category Name', fieldName: 'Combined_Category_Name__c', type: 'text',sortable:true},
            	{ label: 'Combined Category Group Name', fieldName: 'Combined_Category_Group_Name__c', type: 'text',sortable:true},
                { label: 'Combined Category Subgroup', fieldName: 'subGroupName', type: 'text',sortable:true},
            { label: 'Subcategory slotting', fieldName: 'Subcategory_slotting__c', type: 'text',sortable:true}
            	
                
            ]);
		this.callAction(component, helper, "c.collateAllSupplierCategories", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('mydataCplans####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier_Hub_Number__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                if(record.Combined_Category_Subgroup__c !== undefined){
                    record.subGroupName = record.Combined_Category_Subgroup__r.Name;
                }
                if(record.Supplier_Hub_Number__r.Supplier_Name__c !== undefined){
                    record.SupplierlinkName = '/'+record.Supplier_Hub_Number__c;
                    record.supplierName = record.Supplier_Hub_Number__r.Supplier_Name__c;
                    record.SupplierNumber = record.Supplier_Hub_Number__r.Name;
                }
            });
				component.set("v.mydataCategories", result);			
            }
        });
          
	},
        fetchMeetingSummaryData : function(component, event, helper) {
        
        component.set('v.mycolumnsMeetingSummaries', [
            { label: ' Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            { label: ' Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
            		{ label: 'Supplier Name', fieldName: 'supplierName', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
                { label: 'Meeting Date', fieldName: 'Meeting_Date__c', type: 'text',sortable:true},
            	{ label: 'Visibility', fieldName: 'Type__c', type: 'text',sortable:true},
                { label: 'Meeting Type', fieldName: 'Meeting_Type__c', type: 'text',sortable:true}
            	
                
            ]);
		this.callAction(component, helper, "c.getMeetingSummarydata", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('mydataCplans####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier_Hub_Number__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                
                if(record.Supplier_Hub_Number__r.Supplier_Name__c !== undefined){
                    record.SupplierlinkName = '/'+record.Supplier_Hub_Number__c;
                    record.supplierName = record.Supplier_Hub_Number__r.Supplier_Name__c;
                    record.SupplierNumber = record.Supplier_Hub_Number__r.Name;
                }
            });
				component.set("v.mydataMeetingSummaries", result);			
            }
        });
          
	},
        fetchMeetingStructureData : function(component, event, helper) {
        
        component.set('v.mycolumnsMeetingStructures', [
            { label: ' Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            { label: ' Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
            		{ label: 'Supplier Name', fieldName: 'supplierName', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
                { label: 'Frequency of the Meeting', fieldName: 'Frequency_of_the_Meeting__c', type: 'text',sortable:true},
            	{ label: 'Visibility', fieldName: 'Type__c', type: 'text',sortable:true}
            	
                
            ]);
		this.callAction(component, helper, "c.getMeetingStructuredata", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('mydataCplans####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier_Hub_Number__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                
                if(record.Supplier_Hub_Number__r.Supplier_Name__c !== undefined){
                    record.SupplierlinkName = '/'+record.Supplier_Hub_Number__c;
                    record.supplierName = record.Supplier_Hub_Number__r.Supplier_Name__c;
                    record.SupplierNumber = record.Supplier_Hub_Number__r.Name;
                }
            });
				component.set("v.mydataMeetingStructures", result);			
            }
        });
          
	},
        fetchVendorBKData : function(component, event, helper) {
        
        component.set('v.mycolumnsVendorBks', [
            { label: ' Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            { label: ' Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
            		{ label: 'Supplier Name', fieldName: 'supplierName', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
                { label: 'Duns Sid', fieldName: 'Duns_Sid__c', type: 'text',sortable:true},
            { label: 'Vendor SAP Description', fieldName: 'Vendor_SAP_Description__c', type: 'text',sortable:true},
            { label: 'Vendor Sap Number', fieldName: 'Vendor_Sap_Number__c', type: 'text',sortable:true},
            { label: 'Vendor Source', fieldName: 'Vendor_Source__c', type: 'text',sortable:true},
            	{ label: 'Payment Term Code', fieldName: 'Payment_Term_Code__c', type: 'text',sortable:true},
            { label: 'Payment Term Description', fieldName: 'Payment_Term_Description__c', type: 'text',sortable:true} 
        ]);
		this.callAction(component, helper, "c.getVendorBkdata", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('mydataCplans####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier_Hub__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                
                if(record.Supplier_Hub__r.Supplier_Name__c  !== undefined){
                    record.SupplierlinkName = '/'+record.Supplier_Hub__c;
                    record.supplierName = record.Supplier_Hub__r.Supplier_Name__c;
                    record.SupplierNumber = record.Supplier_Hub__r.Name;
                }
            });
				component.set("v.mydataVendorBks", result);			
            }
        });
          
	},
        fetchRiskData : function(component, event, helper) {
        
        component.set('v.mycolumnsRisks', [
            { label: ' Name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            { label: ' Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
            		{ label: 'Supplier Name', fieldName: 'supplierName', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
             { label: 'Classification incident', fieldName: 'Classification_incident__c', type: 'text',sortable:true},
            { label: 'severity assessment date', fieldName: 'Severity_assessment_date__c', type: 'text',sortable:true}
        ]);
		this.callAction(component, helper, "c.getRisks", { recordId: component.get('v.recordId')}, function(result) {
			if (result) {
                console.log('risk details####### '+ JSON.stringify(result));
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                
                if(record.Supplier__r.Supplier_Name__c  !== undefined){
                    record.SupplierlinkName = '/'+record.Supplier__c;
                    record.supplierName = record.Supplier__r.Supplier_Name__c;
                    record.SupplierNumber = record.Supplier__r.Name;
                }
            });
				component.set("v.mydataRisks", result);			
            }
        });
          
	},
        
        
})