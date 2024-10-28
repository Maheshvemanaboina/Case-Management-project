({
  

    // onBusinessSegmentChange : function(component, event, helper) {

    //     helper.setSubSegments(component, event, helper, component.get("v.businessSegmentsSelected"), component.get("v.businessSegSubSegMap"));
    //     component.get("v.contentVisibilityManagerObj").businessSegmentsSelected = component.get("v.businessSegmentsSelected");
                                                                                 
    // },

    // onSubSegmentChange : function(component, event, helper){

    //     component.get("v.contentVisibilityManagerObj").subSegmentsSelected = component.get("v.subSegmentsSelected");
    // },

    // onSalesRegionChange : function(component, event, helper){
        
    //     component.get("v.contentVisibilityManagerObj").salesRegionsSelected = component.get("v.salesRegionsSelected");
    // },
   

    ontileTreeSelect : function(component, event, helper) {
        
        var selectedTileId = event.getParam('name');
        helper.validCorrentContentSelection(component, helper, selectedTileId, component.get("v.validContentMap"));
    },

    onLibraryTreeSelect : function(component, event, helper) {
        
        var selectedFolderId = event.getParam('name');
        helper.validateLibrarySelection(component, selectedFolderId, component.get("v.folderLibraryMap"), component.get("v.validLibraryMap"));
    },

    preventDefaultSubmission : function(component, event, helper){

        event.preventDefault();
    },

    onLibraryMenuItemSelect : function(component, event, helper){

        event.preventDefault();
        var selectedMenuItemValue = event.getParam("value");

        if(selectedMenuItemValue == 'AddLibrary'){

            helper.addContentLibrarySection(component, event, helper);
        }else if(selectedMenuItemValue == 'DeleteLibrary'){

            helper.deleteContentLibrarySection(component, event, helper);
        }
    },

    onContentPathMenuItemSelect : function(component, event, helper){

        event.preventDefault();
        var selectedMenuItemValue = event.getParam("value");

        if(selectedMenuItemValue == 'AddContentPath'){

            helper.addContentPathSection(component, event, helper);
        }else if(selectedMenuItemValue == 'DeleteContentPath'){

            helper.deleteContentPathSection(component, event, helper);
        }
    },

    toggleLibraryAccordianSection : function(component, event, helper){

        event.preventDefault();
        $A.util.toggleClass(component.find("libraryaccordianId"),'slds-is-open');
    },

    toggleContentPathAccordianSection : function(component, event, helper){

        event.preventDefault();
        $A.util.toggleClass(component.find("contentPathaccordianId"),'slds-is-open');
    },

    setContentTree : function(component, event, helper){

        var params = event.getParam('arguments');
        if (params) {
            //var contentTree = params.contentTree;
            component.set("v.contentTreeVM",params.contentTree);
            component.set("v.validContentMap", params.validContMap);
            helper.toggleContentTreeMessage(component, component.get("v.isRelatedArticle"));
            helper.setCorrectContentMessage(component, helper, false, false, component.get("v.isRelatedArticle"));
        }
    },

    handleRelatedArticleChange : function(component, event, helper){

        if(!component.get("v.isLibraryContent")){
            var isRelatedArticle = event.getParam("value");
            helper.toggleContentTreeMessage(component, isRelatedArticle);
            helper.setCorrectContentMessage(component, helper, false, false, isRelatedArticle);   
        }
        //helper.setSectionHeaderName(component, isRelatedArticle);
    },
})