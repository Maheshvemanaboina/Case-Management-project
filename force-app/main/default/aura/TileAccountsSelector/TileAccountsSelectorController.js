({
    doInit: function(component, event, helper) {
        helper.loadAccounts(component);
    },

    handleSearch: function(component, event, helper) {
        helper.search(component);
    },
    
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
        component.set("v.tempSelectedAccountsIds", component.get("v.selectedAccountsIds"));
        component.set("v.tempSelectedAccountsNames", component.get("v.selectedAccountsNames"));
        component.set("v.isSaveEnabled", false);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    handleAccountSelection: function(component, event, helper) {        
        // Retrieve component attributes
        var availableAccounts = component.get("v.searchAllAvailableAccounts");
        var allAvailableAccounts = component.get("v.allAvailableAccounts");
        var selectedValues = event.getParam("value");
        
        // Create the selected labels based on the selected values
        var selectedLabels = allAvailableAccounts
        .filter(option => selectedValues.indexOf(option.value) > -1)
        .map(option => option.label);
        
        // Update selectedAccountsIds and selectedAccountsNames with selectedValues and selectedLabels respectively
        component.set("v.selectedAccountsIds", selectedValues);
        component.set("v.selectedAccountsNames", selectedLabels);
        
        // Filter out accounts that are not selected for displaying available accounts
        var filteredAccounts = availableAccounts.filter(function(option) {
            return selectedValues.indexOf(option.value) === -1;
        });
        component.set("v.searchAllAvailableAccounts", filteredAccounts);
        //Save Button Enable
        var initialSelectedIds = component.get("v.tempSelectedAccountsIds");
        var hasChanges = JSON.stringify(initialSelectedIds) !== JSON.stringify(selectedValues);
        component.set("v.isSaveEnabled", hasChanges);
        
        // Adjust the count and handle addition/removal logic
        if (component.get("v.addRemCount") > selectedValues.length) {
            
            // Find and remove extra names from selectedLabels
            var extraNames = component.get("v.selectedAccountsNames").filter(function(name) {
                return !selectedLabels.includes(name);
            });
            
            selectedLabels = selectedLabels.filter(function(name) {
                return !extraNames.includes(name);
            });
            
        } else {
            console.log('Adding selected labels');
        }
        
        // Update the component attributes with the filtered labels
        component.set("v.selectedAccountsNames", selectedLabels);
        component.set("v.addRemCount", selectedLabels.length);
        
    },
    
    
    handleSave: function(component, event, helper) {
        helper.saveSelectedAccounts(component);
        component.set("v.isOpen", false);
       	component.set("v.searchTerm", '');
        component.set("v.isSaveEnabled", false);
    },

    handleCancel: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.searchTerm", '');
        component.set("v.selectedAccountsIds", component.get("v.tempSelectedAccountsIds"));
        component.set("v.selectedAccountsNames", component.get("v.tempSelectedAccountsNames"));
        component.set("v.isSaveEnabled", false);
    }
})