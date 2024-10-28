({
    setLabel : function(component) {
       let setTypeOfNumber = component.get("v.setIsNumberIsUnique");
        console.log('tyepnumber:'+setTypeOfNumber);
        if(setTypeOfNumber){
            let fieldAPIName = component.get('v.fieldAPIName');
            let fieldAttributeName = 'v.record.'+fieldAPIName;
            let fieldvalue = component.get(fieldAttributeName);
            component.set("v.recordLabel", fieldvalue);
            console.log('record value:'+fieldvalue);
        }   
        else{
            let fieldAttributeName = 'v.record.RECORDFIELDVALUE';
            let fieldvalue = component.get(fieldAttributeName);
            component.set("v.recordLabel", fieldvalue);
        }
    },

    setMetaValues : function(component) {

        let subheading = '';
        let setTypeOfNumber = component.get("v.setIsNumberIsUnique");
        
        for(var i=0; i < component.get("v.metaFieldsAPI").length; i++ ){
           let metafieldAttributeName;   
            if(setTypeOfNumber) {
                let metafieldAPIName = component.get("v.metaFieldsAPI")[i];
                let metafieldAttributeName = 'v.record.'+metafieldAPIName;
                
            }   
            else{
                metafieldAttributeName = 'v.record.METAFIELDVALUE';
            }
            if(component.get(metafieldAttributeName)){
                    subheading = subheading + component.get(metafieldAttributeName) + ' - ';
            }
        }
        subheading = subheading.substring(0,subheading.lastIndexOf('-'));
        component.set("v.metaFieldValues", subheading);
    }
})