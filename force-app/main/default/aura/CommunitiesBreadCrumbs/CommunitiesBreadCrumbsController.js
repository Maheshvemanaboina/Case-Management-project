({
    doInit : function(component, event, helper) {

        console.log('Entered Do Init');
        //helper.setBaseUrl(component, event, helper);
        helper.setBreadCrumbsOnInit(component, event, helper);
        //window.setInterval(helper.setBreadCrumbsOnInit(component, event, helper), 3000);
    },

    gotoURL : function (component, event, helper) {

        var relURL = event.getSource().get("v.name").split("-");
        var navPageType = relURL[0];
        var objAPIorPgName = relURL[1];
        var recId = relURL[2];

        var nagigateLightning = component.find('navigateService');
        if(navPageType == 'standard__objectPage'){

            helper.standardObjPageReference(component, objAPIorPgName);
        }
        else if(navPageType == 'comm__namedPage'){

            helper.commNamedPageReference(component, objAPIorPgName);
        }
        else if(navPageType == 'standard__recordPage'){

            helper.standardRecordPageReference(component, recId, objAPIorPgName);
        }
    }
})