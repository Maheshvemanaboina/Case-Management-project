({
    //Content Message Display Variables
    ATreeSelected         : "v.contentPathLocationObj.isATreeSelected",
    ACorrectTreeSelected  : "v.contentPathLocationObj.isACorrectTreeSelected",
    ProductSpecCompatible : "v.isRelatedArticle",


    validCorrentContentSelection : function(component, helper, selectedTileId, validContentMap){

        var contentName = validContentMap[selectedTileId];
        if(contentName != '' && contentName != undefined){

            component.set("v.contentPathLocationObj.SelectedTileId",selectedTileId);
            component.set("v.contentPathLocationObj.contentStoragePath",contentName);
            helper.setCorrectContentMessage(component, helper, true, true, false);

        }else{

            component.set("v.contentPathLocationObj.SelectedTileId",'');
            component.set("v.contentPathLocationObj.contentStoragePath",'');
            helper.setCorrectContentMessage(component, helper, true, false, false);
        }
    },

    setCorrectContentMessage : function(component, helper, isATreeSelected, isACorrectTreeSelected, isRelatedArticle){

        if(isRelatedArticle){

            component.set(helper.ATreeSelected, false);
            component.set(helper.ACorrectTreeSelected, false);
        }else{

            if(!isATreeSelected && !isACorrectTreeSelected){

                component.set(helper.ATreeSelected, false);
                component.set(helper.ACorrectTreeSelected, false);

            }else if(isATreeSelected && !isACorrectTreeSelected){

                component.set(helper.ATreeSelected, true);
                component.set(helper.ACorrectTreeSelected, false);

            }else if(isATreeSelected && isACorrectTreeSelected){

                component.set(helper.ATreeSelected, true);
                component.set(helper.ACorrectTreeSelected, true);
            }
        }
    },

    validateLibrarySelection : function(component, selectedFolderId, folderLibraryMap, validLibraryMap){

        var libraryId = folderLibraryMap[selectedFolderId];
        var libraryPath = validLibraryMap[selectedFolderId];

        if(libraryId != '' && libraryId != undefined){

            component.set("v.contentLibraryLocationObj.SelectedLibraryFolder", selectedFolderId);
            component.set("v.contentLibraryLocationObj.SelectedFolderLibraryId", selectedFolderId + '-' +libraryId);
            component.set("v.contentLibraryLocationObj.LibraryStoragePath", libraryPath);
        }else{
            component.set("v.contentLibraryLocationObj.SelectedFolderLibraryId",'');
            component.set("v.contentLibraryLocationObj.LibraryStoragePath", '');
        }
    },

    toggleContentTreeMessage : function(component, isContentDisabled){

        if(isContentDisabled){

            component.set("v.isRelatedArticle", true);
            $A.util.addClass(component.find('contentTreeDiv'),"greyClass");
            $A.util.addClass(component.find('treeId'),"slds-hide");
            $A.util.removeClass(component.find('contentdisabledId'),"slds-hide");
            component.get("v.contentPathLocationObj").SelectedTileId = '';
        }else{

            component.set("v.isRelatedArticle", false);
            $A.util.removeClass(component.find('contentTreeDiv'),"greyClass");
            $A.util.removeClass(component.find('treeId'),"slds-hide");
            $A.util.addClass(component.find('contentdisabledId'),"slds-hide");
        }
    },

    addContentLibrarySection : function(component, event, helper){

        //if(isValidToAdd){
            component.getEvent("AddLibraryRowEvt").fire({"indexVar" : component.get("v.contentLibraryRowIndex")});   
        //}
    },

    deleteContentLibrarySection : function(component, event, helper){
        
        component.getEvent("DeleteLibraryRowEvt").setParams({"indexVar" : component.get("v.contentLibraryRowIndex"),
                                                    "recordObj" : component.get("v.contentLibraryLocationObj")}).fire();
    },

    addContentPathSection : function(component, event, helper){

        //if(isValidToAdd){
            component.getEvent("AddContentPathRowEvt").fire({"indexVar" : component.get("v.contentLibraryRowIndex")});   
        //}
    },

    deleteContentPathSection : function(component, event, helper){
        
        component.getEvent("DeleteContentPathRowEvt").setParams({"indexVar" : component.get("v.contentPathRowIndex"),
                                                    "recordObj" : component.get("v.contentPathLocationObj")}).fire();
    },

    validateNullOrUndefined : function(component, variableValue){

        return (component.get(variableValue) != '' && component.get(variableValue) != undefined) ? true : false;
    },

    setSectionHeaderName : function(component, isRelatedArticle){

        if(isRelatedArticle){

            component.get("v.contentVisibilityManagerObj").SectionHeaderName = 'Content sharing & path information for the "Related Article"';
        }else{
            component.get("v.contentVisibilityManagerObj").SectionHeaderName = 'Content sharing & path information ';
        }
    },

    // setContentVMBusinessSegments : function(component, helper){

    //     component.get("v.contentVisibilityManagerObj").businessSegmentsSelected = helper.validateNullOrUndefined(component, 'v.businessSegmentsSelected') ?
    //                                                                              component.get("v.businessSegmentsSelected") : 
    //                                                                              'This article\'s visibility will not be restricted by any Business Segment';
    // },

    // setContentVMSubSegments : function(component, helper){

    //     component.get("v.contentVisibilityManagerObj").subSegmentsSelected = helper.validateNullOrUndefined(component, 'v.subSegmentsSelected') ?
    //                                                                             component.get("v.subSegmentsSelected") : 
    //                                                                             'This article\'s visibility will not be restricted by any Sub Segment';
    // },

    // setContentVMSalesRegions : function(component, helper){

    //     component.get("v.contentVisibilityManagerObj").salesRegionsSelected = helper.validateNullOrUndefined(component, 'v.salesRegionsSelected') ?
    //                                                                             component.get("v.salesRegionsSelected") : 
    //                                                                             'This article\'s visibility will not be restricted by any Sales Region';
    // },
})