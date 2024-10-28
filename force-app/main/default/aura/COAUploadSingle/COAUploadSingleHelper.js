({
    yearVAL : "YEAR",
    monthVAL : "MONTH",
    productGroupVAL : "PRODUCTGROUP",
    shipToVAL : "SHIPTO",

    yearChilds : "MonthId:prdGroupId:shipToId",
    monthChilds : "prdGroupId:shipToId",
    productGroupChild : "shipToId",

    yearChildsParentRecords : "selectedRecord:ShipToSelectedRecord",
    monthChildsParentRecords : "MonthSelectedRecord:ShipToSelectedRecord",
    productGroupChildsParentRecords : "PrdGroupSelectedRecord:ShipToSelectedRecord",

    UploadAndSave : function(component,event,helper,typeOfSave) {
        
        var selectedRecord = component.get("v.selectedRecord");
        console.log('selectedRecord val --> '+selectedRecord);

        var monthRecord = component.get("v.MonthSelectedRecord");
        console.log('MonthSelectedRecord val --> '+monthRecord);

        var PrdGroupSelectedRecord = component.get("v.PrdGroupSelectedRecord");
        console.log('PrdGroupSelectedRecord val --> '+PrdGroupSelectedRecord);

        var ShipToSelectedRecord = component.get("v.ShipToSelectedRecord");
        console.log('ShipToSelectedRecord val --> '+ShipToSelectedRecord);

        if(component.get("v.selectedRecord") != null && component.get("v.MonthSelectedRecord") !=null && component.get("v.ShipToSelectedRecord") !=null && component.get("v.PrdGroupSelectedRecord") !=null && component.find("UiId").get("v.value") != null && component.find("UiId").get("v.value") != '' && component.get("v.fileName") != 'No File Selected..'){
            
            component.set("v.Spinner",true);
            var fileInput = component.find("fileId").get("v.files");
            var file = fileInput[0];
            
            if (file.size > 7500000) {
                alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
                      'Selected file size: ' + file.size);
                return;
            }
            
            var fr = new FileReader();
            
            var self = this;
            fr.onload = $A.getCallback(function() {
                var fileContents = fr.result;
                var base64Mark = 'base64,';
                var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                
                fileContents = fileContents.substring(dataStart);
                var yearTile = component.get("v.selectedRecord");
                var monthTile = component.get("v.MonthSelectedRecord");
                var prdGroupTile = component.get("v.PrdGroupSelectedRecord");
                var ShipToTile = component.get("v.ShipToSelectedRecord");
                
                self.uploadRecord(component, file, fileContents, yearTile, monthTile, prdGroupTile, ShipToTile, typeOfSave);
            });
            
            fr.readAsDataURL(file);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Year, Month, Product Group, Ship-To and COA Name are mandatory to Upload COA. Please Fill it and then Proceed.',
                messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
            
        }
    },
    
    uploadRecord: function(component, file, fileContents, yearTileId, monthTileId, prdGroupTile, ShipToTile, typeOfSave) {
        var action = component.get("c.saveRecord"); 
        var tileNm = component.find("UiId").get("v.value");
        
        action.setParams({
            yearId: yearTileId.Id,
            monthId: monthTileId.Id,
            prdGrpId: prdGroupTile.Id,
            shipToId: ShipToTile.Id,
            workLocId: component.get("v.recordId"),
            fileName: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type,
            TileName: tileNm
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            var result;
            if (status === "SUCCESS") {
                result = response.getReturnValue();
                console.log('saved Id'+component.get("v.SFUrl")+'/lightning/r/Tile__c/'+result.Id+'/view');
                component.set("v.Spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'COA Uploaded Successfully',
                    message: 'COA Uploaded',
                    messageTemplate: 'The COA is Uploaded Successfully.Click on the COA {1} created to access it',
                    messageTemplateData: ['Salesforce', {
                        url: 'https://'+component.get("v.SFUrl")+'/lightning/r/Tile__c/'+result.Id+'/view',
                        label: result.UI_Name__c,
                    }],
                    duration:'10000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                if(typeOfSave == 'save'){
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if(typeOfSave == 'SaveAndClone'){
                    var fileinfo = component.find("fileId").get("v.files");
                    console.log('file info at saveandclone --> '+fileinfo);
                    console.log('file info at saveandcloe [0] --> '+fileinfo[0]);
                    component.find("UiId").set("v.value", "");
                    component.find("fileId").set("v.files",[]);
                    /*var yearcomp = component.find('yearId');
                    yearcomp.clearValue();
                    var monthcomp = component.find('MonthId');
                    monthcomp.clearValue();
                    var prdGrpcomp = component.find('prdGroupId');
                    prdGrpcomp.clearValue();
                    var shipToComp = component.find('shipToId');
                    shipToComp.clearValue();*/
                    component.set("v.fileName",'No File Selected..');
                    /*component.set("v.selectedRecord",null);
                    component.set("v.MonthSelectedRecord",null);
                    component.set("v.PrdGroupSelectedRecord",null);
                    component.set("v.ShipToSelectedRecord",null);*/
                }
            }
        });
        
        $A.enqueueAction(action);
    },

    handleNullifyingChilds : function(component,event,helper,lookupVal){
        if(lookupVal == helper.yearVAL){
            console.log('Entered year');
            helper.handleLoopAndClearChildAndParent(component,helper,helper.yearChilds,helper.yearChildsParentRecords);
        }
        else if(lookupVal == helper.monthVAL){
            console.log('Entered Month');
            helper.handleLoopAndClearChildAndParent(component,helper,helper.monthChilds,helper.monthChildsParentRecords);
        }
        else if(lookupVal == helper.productGroupVAL){
            console.log('Entered Product Group');
            helper.handleLoopAndClearChildAndParent(component,helper,helper.productGroupChild,helper.productGroupChildsParentRecords);
        }
    },

    handleLoopAndClearChildAndParent : function(component,helper,childArrVal,parArrVal){
        console.log('Child Arr'+childArrVal);
        console.log('parArrVal Arr'+parArrVal);
        var childArr = childArrVal.split(":");
        var parValArr = parArrVal.split(":");
        //helper.clearParentRecords(component,parValArr[0]);
        for(var j = 0; j < parValArr.length; j++) {
            console.log('parValArr[i] --> '+parValArr[j]);
            helper.clearParentRecords(component,parValArr[j]);
        }
        for(var i = 0; i < childArr.length; i++) {
            console.log('childArr[i] --> '+childArr[i]);
            helper.removeAllChildDependency(component,childArr[i]);
        }
    },

    removeAllChildDependency : function(component, childVal){
        var childcomp = component.find(childVal);
        console.log('childcomp --> '+childcomp);
        childcomp.clearValue();
    },

    clearParentRecords : function(component, parVal){
        var pVal = 'v.'+parVal;
        console.log('pVAl--> '+pVal);
        component.set(pVal,null);
        component.set("v.ShipToSelectedRecord",null);
    }
})