({
    handleUploadFinished : function(component, event, helper) {
        component.set("v.isLoading", true);
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        let fileExt = file.name.split('.');
        var filename = file.name;
        console.log('File Name '+file.name);
        if(Array.isArray(fileExt) && fileExt.length==2){
            if(fileExt[fileExt.length-1] && fileExt[fileExt.length-1] == 'csv'){
                console.log('ok');
            }else{
                //alert (fileExt[1]+ ' format not allowed');
                ///helper.showToastMsg(cmp,event,alrt);
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    "type":"error",
                    "title": "Error!",
                    "message": fileExt[fileExt.length-1]+ ' format not allowed'
                });
                showToast.fire();
                component.set("v.isLoading", false);
                return true;
            }
        }
        if(file) {
            console.log("UPLOADED")
            var reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = function(evt) {
                var csv = evt.target.result;
                console.log(csv);
                component.set("v.csvString", csv);
                window.setTimeout($A.getCallback(function(){
                    helper.handleGetCSV(component,csv,filename);
                }), 5);
            }
        }
        console.log('Completed Upload');
    },   
})