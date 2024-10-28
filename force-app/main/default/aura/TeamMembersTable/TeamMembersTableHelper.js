/**
 * Created by KJM on 03/07/2019.
 */

({
    showMessageComponent : function(component, event, helper) {
       component.set("v.messagePersonName", event.currentTarget.getAttribute('data-personName'));
       component.set("v.renderSendMessageComponent", true);
    },
    
    sortData : function(component,fieldPosition,sortdirection){
        var data = component.get("v.tableValues.bodyValues");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldPosition]; }
        var reverse = sortdirection == 'asc' ? 1: -1;
        // to handel text type fields 
        data.sort(function(a,b){
            var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
            var b = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a>b) - (b>a));
        });    
        //set sorted data to accountData attribute
        component.set("v.tableValues.bodyValues",data);
    }
});