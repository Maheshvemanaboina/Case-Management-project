({
    loadAccounts: function(component) {
        var items = [];
        var action = component.get("c.getAvailableAccounts");
        action.setParams({ 
            isH1Account: component.get("v.isH1Account"), 
            isH5Account: component.get("v.isH5Account") 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var parsedData = Object.entries(response.getReturnValue()).map(entry => entry[1]);
                
                parsedData.forEach(obj => {
                    items.push({
                        "label": obj.Name,
                        "value": obj.Id
                    });
                });

                component.set("v.allAvailableAccounts", items);
                component.set("v.searchAllAvailableAccounts", items);
                component.set("v.availableAccounts", items);
            } else {
                console.error("Failed to load accounts");
            }
        });
        $A.enqueueAction(action);
    },
    
    search: function(component) {
        var term = component.get("v.searchTerm").toLowerCase();
        var availableAccounts = component.get("v.allAvailableAccounts");
        var selectedAccountIds = component.get("v.selectedAccountsIds");

        // Always include selected accounts in the search results
        var selectedAccounts = availableAccounts.filter(item => selectedAccountIds.indexOf(item.value) > -1);

        if (!term) {
            // If the search term is empty, show all available accounts (excluding the selected ones)
            var filteredAccounts = availableAccounts.filter(function(option) {
                return selectedAccountIds.indexOf(option.value) === -1;
            });
            component.set("v.availableAccounts", filteredAccounts.concat(selectedAccounts));
        } else {
            // Filter the available accounts based on the search term, excluding selected accounts
            var filteredAccounts = availableAccounts
                .filter(item => selectedAccountIds.indexOf(item.value) === -1)
                .filter(item => item.value.toLowerCase().includes(term) || 
                                item.label.toLowerCase().includes(term));

            component.set("v.availableAccounts", filteredAccounts.concat(selectedAccounts));
        }
    },

    saveSelectedAccounts: function(component) {
        var componentEvent = component.getEvent("sendAccountEvt");
        var selectedAccountNames = component.get("v.selectedAccountsNames").join(', ');
        componentEvent.setParams({
            "selectedAccountsIds" : component.get("v.selectedAccountsIds"),
            "selectedAccountsNames" : selectedAccountNames,
            "isH1Account" : component.get("v.isH1Account"),
            "selectedAccounts": component.get("v.selectedAccounts"),
            "isH5Account" : component.get("v.isH5Account"),
            "isSaveEnabled" : component.get("v.isSaveEnabled")});
        componentEvent.fire();
    },   
})