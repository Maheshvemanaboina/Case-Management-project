({
	doInit : function(component, event, helper) {
        helper.loadResources();
        // var pageBaseUrl = window.location.origin;
        // var reportUri = component.get('v.relativeReportUri');
        // var recordId = component.get('v.recordId');
        // console.log('render report page base url: ',pageBaseUrl);
        // console.log('render report uri: ',reportUri);
        // console.log('render report for record Id: ',recordId);
        // component.set('v.frameUrl',pageBaseUrl+reportUri);
        helper.getReportResponse(component);
	},
    toggleSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        var evt = spinner.get("e.toggle");
        
        if(!$A.util.hasClass(spinner, 'hideEl')) {
            evt.setParams({ isVisible : false });
        }
        else {
            evt.setParams({ isVisible : true });
        }
        evt.fire();
    },
    showSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        
        evt.fire();
    },
    hideSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        
        evt.fire();
    }
})