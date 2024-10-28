({
    init: function(component, event, helper){
        console.log('init called .. Pankaj');
        var actions = [
            { label: 'View', name: 'view' }
        ];
        component.set('v.mycolumns', [
                { label: 'Name name', fieldName: 'linkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
                            { label: 'Supplier Hub Number', fieldName: 'SupplierlinkName', type: 'url', sortable:true, typeAttributes: {label: { fieldName: 'SupplierNumber' }, target: '_blank'}},
	
            { label: 'Supplier Name', fieldName: 'Supplier_Name__c', type: 'text',sortable:true},
            { label: 'Origin', fieldName: 'native', type: 'text',sortable:true},
            	{ label: 'Start Date', fieldName: 'Start_Date__c', type: 'text',sortable:true},
                { label: 'End Date', fieldName: 'End_Date__c', type: 'text',sortable:true},
                { label: 'Contract type', fieldName: 'Contract_Type__c', type: 'text',sortable:true},
                { label: 'Bonus Clause', fieldName: 'Bonus_clause__c', type: 'text',sortable:true},
                { label: 'Volume Commitment Given', fieldName: 'Volume_commitment_given_by_FC__c', type: 'text',sortable:true},
                { type: 'action', typeAttributes: { rowActions: actions } }
            ]);
		helper.callAction(component, helper, "c.getContractdata", { recordId: component.get('v.recordId')}, function(result) {
            
			if (result) {
            result.forEach(function(record){
            record.linkName = '/'+record.Id;
                if(record.Supplier_Hub__c ==  component.get('v.recordId')){
                    record.native = 'Parent';
                }else{
                    record.native  = 'Child';
                }
                record.SupplierlinkName = '/'+record.Supplier_Hub__c;
                record.SupplierNumber = record.Supplier_Hub__r.Name;
            });
				component.set("v.mydata", result);			
            }else{
                component.set('v.renderTabset', true);
            }
        });
    },
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                helper.editRecord(cmp, event);
                break;
            case 'delete':
                helper.deleteRecord(cmp, event);
                break;
            case 'view':
                helper.viewRecord(cmp, event);
                break;
        }
    },
    updateSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    handleActive: function (cmp, event, helper) {
        console.log('handle active called.. Pankaj');
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];
         var tab = event.getSource();
        var selectedTab = tab.get('v.id');
        cmp.set('v.selectedTab', selectedTab);
        switch (tab.get('v.id')) {            
            case 'projects' :
                 helper.fetchProjectdata(cmp, event, helper);
                break;
            case 'claims' :
				helper.fetchClaimsData(cmp, event, helper);
                break;
            case 'complaints' :
			helper.fetchComplaintsData(cmp, event, helper);
            break;
            case 'cPlans' :
			helper.fetchCplansData(cmp, event, helper);
            break;
            case 'categories' :
			helper.fetchCategoryData(cmp, event, helper);
            break;
                 case 'meetingSummary' :
			helper.fetchMeetingSummaryData(cmp, event, helper);
            break;
                case 'meetingStructure' :
			helper.fetchMeetingStructureData(cmp, event, helper);
            break;
                case 'VendorBK' :
			helper.fetchVendorBKData(cmp, event, helper);
            break;
                case 'Risk' :
                helper.fetchRiskData(cmp, event, helper);
                break;
                
                
        }
    },
    
})