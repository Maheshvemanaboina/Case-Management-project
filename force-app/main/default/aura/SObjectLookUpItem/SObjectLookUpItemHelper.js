({
    setLabel : function(component) {

        var fieldAPIName = component.get('v.fieldAPIName');
        var fieldAttributeName = 'v.record.'+fieldAPIName;
        var fieldvalue = component.get(fieldAttributeName);
        component.set("v.recordLabel", fieldvalue);
    },

    setMetaValues : function(component) {

        var subheading = '';
        for(var i=0; i < component.get("v.metaFieldsAPI").length; i++ ){

            var metafieldAPIName = component.get("v.metaFieldsAPI")[i];
            var metafieldAttributeName = 'v.record.'+metafieldAPIName;
            if(component.get(metafieldAttributeName)){
                subheading = subheading + component.get(metafieldAttributeName) + ' - ';
            }
        }
        subheading = subheading.substring(0,subheading.lastIndexOf('-'));
        component.set("v.metaFieldValues", subheading);
    }
})