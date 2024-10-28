({

    doInit : function(component, event, helper) {

        helper.checkKnowledgeUserAndSetData(component, event, helper);
        helper.setLabelsOnInit();
    },
   	
   	handleEvent1 : function(component, event, helper){
        component.set("v.onchange111",true);
    },
    
    //B2B-325
    handleEvtFromTileAccountSelection : function(component, event, helper){
        var selectedNames= event.getParam("selectedAccountsNames");
        var selectedIds= event.getParam("selectedAccountsIds");
        var isH1Account = event.getParam("isH1Account")
        var isH5Account = event.getParam("isH5Account")
        var isSaveEnabled = event.getParam("isSaveEnabled")
		component.set("v.isSaveEnabled",isSaveEnabled);

        if(isH1Account){
            component.set("v.selectedH1AccountsNames",selectedNames);
            component.set("v.selectedH1Accounts",selectedIds);
        }
        if(isH5Account){
            component.set("v.selectedH5AccountsNames",selectedNames);
            component.set("v.selectedH5Accounts",selectedIds);
        }
    },


    onContentTypeChange : function(component, event, helper) {
        
        var selectedContentType = event.getParam("value");

        if(selectedContentType != helper.relatedArticleValue){

            component.set("v.isRelatedArticle", false);
            //helper.setContentTree(component, helper, helper.communityNameMap[component.get("v.communityNameSelected")]);
            helper.setContentTree(component, helper, helper.getSFCommunityNames(helper, component.get("v.communityNameSelected").toString()));
            
        }else if(selectedContentType == helper.relatedArticleValue){
			helper.setContentTree(component, helper, helper.getSFCommunityNames(helper, component.get("v.communityNameSelected").toString()));
            component.set("v.isRelatedArticle", true);
            helper.adjustContentPathList(component, helper);
        }
        helper.toggleContentCategoriesMessage(component, component.get("v.isRelatedArticle"));
        helper.resetContentCategories(component, helper);
        
    },

    onCommunityNameChange : function(component, event, helper) {
        
        helper.setContentTypes(component, component.get("v.communityNameSelected").toString(), component.get("v.contentWrapper").nameContentTypeMap);
        component.set("v.contentPathLocationList", []);
        helper.createContentPathLocationObj(component, helper);
        if(component.get("v.communityNameSelected").toString()){
            helper.setContentTree(component, helper, helper.getSFCommunityNames(helper, component.get("v.communityNameSelected").toString()));
        }
        component.set("v.isRelatedArticle", false);
        helper.toggleContentCategoriesMessage(component, component.get("v.isRelatedArticle"));
        helper.resetContentCategories(component, helper);
    },

    handleFilesChange : function(component, event, helper) {
        
        var isFileValid = helper.validateFileAndReturnStatus(component, event, helper);
        if (isFileValid) {
            helper.setFileName(component, event, helper);
        }
    },

    onKnowledgeArticleNameChange : function(component, event, helper) {
        
        helper.setKnowledgeURL(component, component.get("v.knowledgeArticleName"));
    },

    onKnowledgeArticleNameChangeEdit : function(component, event, helper) {
        
        helper.setKnowledgeURL(component, component.find("knowIdEdit").get("v.value"));
    },
	//B2B-326
    handleArrayEvent: function(component, event) {
        var items = event.getParam("contentCategoryList");
        component.set("v.contentManagentCategryList",items);
    },
   //B2B-326
    openReviewContent : function(component, event, helper){
        
        var isMainInfoValid = helper.validateAllInput(component, event, helper, 'Insert');
        var isContentLibrariesValid = false;
        var isContentPathsValid = false;
        
        if(isMainInfoValid){

            isContentLibrariesValid = helper.isContentLibrarySelectionValid(component, helper);

            if(isContentLibrariesValid){

                isContentPathsValid = helper.isContentPathSelectionValid(component, helper);
            }
        }
        if(isMainInfoValid && isContentLibrariesValid && isContentPathsValid){

            //component.set("v.showModal",true);
            helper.toggleModalVisibility(component);
        }
    },

    handleCreate : function(component, event, helper){

        helper.saveNewArticle(component, event, helper);
    },

    handleUpdate : function(component, event, helper){

        event.preventDefault();       // stop the form from submitting
        var editedTileObj = event.getParam('fields');
        editedTileObj.OwnerId = component.get('v.selectedContentOwner');//ENH-4370
        
        var originalTileObj = component.get("v.originalValueEditForm");

        let isChangeDoneByUserRequiresKnowledgePublish = helper.isAnyChangeDoneByUserRequiresKnowledgePublish(component, helper, editedTileObj);
        let isChangeDoneByUserRequiresTileUpdate = helper.isChangeDoneByUserRequiresTileUpdate(component, helper, editedTileObj);
        let isChangeDoneByUserContentPath = helper.isAnyChangeDoneInContent(component);
        let isChangeDoneByUserLibraryPath = helper.isAnyChangeDoneInLibrary(component);
        let isNewFileChosen = helper.isAnyNewFileisChosen(component);
        let isChangeDoneByUserContentCategories = component.get("v.onchange111");
        let isSaveEnabled = component.get("v.isSaveEnabled");

        if(!isChangeDoneByUserRequiresKnowledgePublish && 
            !isChangeDoneByUserRequiresTileUpdate &&
            !isChangeDoneByUserContentPath && 
            !isChangeDoneByUserLibraryPath && 
            !isNewFileChosen &&
            !isChangeDoneByUserContentCategories &&
        	!isSaveEnabled) 
        { helper.fireToastMessage('Error', 'No changes done', 'error'); return; }    

        if(!helper.isContentLibrarySelectionValid(component, helper) || 
            !helper.isContentPathSelectionValid(component, helper)) { return; }

        let typeOfOperation = helper.getTypeOfOperationOnEditSave(
            isChangeDoneByUserRequiresKnowledgePublish,
            isChangeDoneByUserContentPath,
            isChangeDoneByUserLibraryPath,
            isChangeDoneByUserRequiresTileUpdate,
            isNewFileChosen);

        var params = {
            
            isNewFileChosen         : (component.get("v.fileName")) ? true : false,
            tileObj                 : editedTileObj,
            knowledgeURL            : component.get("v.knowledgeURL"),
            UIName                  : editedTileObj['UI_Name__c'],
            articleId               : editedTileObj['Article_Name__c'],
            isUINameChanged         : editedTileObj['UI_Name__c'] != originalTileObj['UI_Name__c'],
            allOperations           : typeOfOperation,
            isRelatedArticleChanged : isChangeDoneByUserContentCategories,
            categoryObjArrayData    : JSON.stringify(component.get("v.contentManagentCategryList")) //B2B-326
        };
        
        //Validate Content Owner field while updating the article - ENH-4370
        var isMainInfoValid = helper.validateAllInput(component, event, helper, 'Update');
        if(isMainInfoValid){
            helper.saveEditedArticle(component, helper, params);
            
            //B2B-325
            helper.updateTileAccounts(component, helper, params);   
        }

        /*if(isOnlyTileUpdateRequired || (component.get("v.fileName")) || isOnlyKnowledgeUpdateRequired){

            helper.checkValidationMessageOnEditAndCallBE(component, helper, fields, isOnlyTileUpdateRequired, ((component.get("v.fileName")) ? true : false), isOnlyKnowledgeUpdateRequired, isUINameChaged);
        }*/
    },

    handleDelete : function(component, event, helper){
        helper.deleteAllArticles(component, helper);
    },

    closeModal : function(component, event, helper){

        //component.set("v.showModal",false);
        helper.toggleModalVisibility(component);
    },
	
    
    // B2B-154 Add relation button
    handleAddRelation: function(component, event, helper) {
        component.set("v.isModalOpen1", true);
    },
    handleSave: function(component, event, helper) {
        // Get selected categories and related articles from the modal
        var selectedCategories = component.get("v.selectedCategoriesInModal");
        var selectedRelatedArticles = component.get("v.selectedRelatedArticlesInModal");
    
        // Set the selected data in the parent component's attributes
        component.set("v.selectedCategories", selectedCategories);
        component.set("v.selectedRelatedArticles", selectedRelatedArticles);
    
        // Update the child component with the new data
        var childComponent = component.find("contentManagementCategories"); // Make sure this aura:id is correct
        if (childComponent) {
            childComponent.set("v.selectedCategories", selectedCategories);
            childComponent.set("v.selectedRelatedArticles", selectedRelatedArticles);
        }
    
        // Optionally, you may want to refresh or handle any additional logic
        // to ensure the child component is properly updated
        // e.g., calling a method in the child component if needed
    },

    
    

    // Handle changes in the combobox
    onContentCategoryChange: function(component, event, helper) {
        var selectedValue = event.getSource().get("v.value");
        component.set("v.contentCategoryObj.contentCategorySelected", selectedValue);
    },

    // Handle cancel button
    cancelModal1: function(component, event, helper) {
        component.set("v.isModalOpen1", false);
    },

    // Handle save button
    confirSave: function(component, event, helper) {
        // Implement your save logic here
        console.log("Save button clicked.");
        component.set("v.isModalOpen1", false);
    },
    // B2B-154 Add relation button

    handleAddNewCategoryRow : function(component, event, helper) {

        var index = event.getParam("indexVar");
        helper.createContentCategoryObj(component, index);
    },

    handleReOrderRelatedContents : function(component, event, helper) {

        var index = event.getParam("itemIndex");
        var eventType = event.getParam("eventType");
        (eventType == 'moveUp') ? helper.reOrderRelatedContents(component, index, index-1) : helper.reOrderRelatedContents(component, index, index+1);
    },
    handleDeleteCategoryRow : function(component, event, helper){
        
        var index = event.getParam("indexVar");
        var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
        if(contentCategoriesObjList.length == 1){
            helper.fireToastMessage('Error', 'Cannot delete all related knowledge Records', 'warning');
        }else{
            contentCategoriesObjList.splice(index, 1); 
            component.set("v.contentCategoriesObjList", contentCategoriesObjList);
        }
    },

    handleAddNewLibrary : function(component, event, helper) {

        var isValidToAddNewLibrary = helper.isContentLibrarySelectionValid(component, helper);
        if(isValidToAddNewLibrary){
            helper.createContentLibraryLocationObj(component, helper);
        }
    },

    handleDeleteLibrary : function(component, event, helper){
        
        var index = event.getParam("indexVar");
        var contentLibraryLocationList = component.get("v.contentLibraryLocationList");
        if(contentLibraryLocationList.length == 1){
            helper.fireToastMessage('Error', 'There should atleast be one selection for Library. All cannot be deleted', 'error');
        }else{
            contentLibraryLocationList.splice(index, 1); 
            component.set("v.contentLibraryLocationList", contentLibraryLocationList);
        }
    },

    handleAddNewContentPath : function(component, event, helper) {

        var isValidToAddNewContentPath = helper.isContentPathSelectionValid(component, helper);
        if(isValidToAddNewContentPath){
            helper.createContentPathLocationObj(component, helper);
        }
    },

    handleDeleteContentPath : function(component, event, helper){
        
        var index = event.getParam("indexVar");
        var contentPathLocationList = component.get("v.contentPathLocationList");
        if(contentPathLocationList.length == 1){
            helper.fireToastMessage('Error', 'There should atleast be one selection for Content Path. All cannot be deleted', 'error');
        }else{
            contentPathLocationList.splice(index, 1); 
            component.set("v.contentPathLocationList", contentPathLocationList);
        }
    },

    onBusinessSegmentChange : function(component, event, helper) {

        helper.setSubSegments(component, event, helper, component.get("v.businessSegmentsSelected"), component.get("v.contentWrapper").businessSegSubSegMap);
                                                                                 
    },

    setUpdateOrCreate : function(component, event, helper){

        //helper.resetContentLibraries(component, event, helper);
        var isUpdateCreateDelete = event.currentTarget.getAttribute("data-visual-picker");
        helper.setPageNavigation(component, helper, isUpdateCreateDelete); 
    },

    handlePageBack : function(component, event, helper){

        helper.resetContentPathAndLibraries(component, helper);
        component.set("v.editRecordId", '');
        component.set("v.fileName", '');
        //helper.resetContentLibraries(component, helper);
        //helper.resetContentPaths(component, helper);
        helper.setPageNavigation(component, helper, 'back');
    },

    handleSObjectLookUpSelect : function(component, event, helper){

        var selectedRecordId = event.getParam("recordId");
        //component.set("v.tileSelectedID", selectedRecordId);
        var updateAuraId = event.getSource().getLocalId();
        
        if(updateAuraId == helper.updateContentOwnerLookUpAuraId) { component.set("v.selectedContentOwner", selectedRecordId); }//ENH-4370

        if(component.get("v.isUpdatePage") && updateAuraId == helper.updateLookUpAuraId){

            component.set("v.editRecordId", selectedRecordId);
            if(selectedRecordId){ helper.setEditForm(component, helper, selectedRecordId); }

        } else if(component.get("v.isDeletePage") && selectedRecordId){

            if(!helper.isTileDeletionSelectionValid(component, helper, selectedRecordId)) {

                helper.fireToastMessage('Duplicate detected', 'Article already selected for deletion', 'error');
                helper.clearTileSelectionLookUp(component, helper.deleteLookUpAuraId); 
            }else{

                helper.handleSObjectDeletion(component, helper, selectedRecordId);
            }
        } else{

            var auraId = event.getSource().getLocalId();
            // B2B-326
            //if(auraId == helper.createH1LookUpAuraId) { component.set("v.selectedH1", selectedRecordId); }
            //if(auraId == helper.createH5LookUpAuraId) { component.set("v.selectedH5", selectedRecordId); }
            // B2B-326            
            if(auraId == helper.createContentOwnerLookUpAuraId) { component.set("v.selectedContentOwner", selectedRecordId); }//ENH-4370
        }
    },

    onEditLoad : function(component, event, helper){

        component.set("v.Spinner", true);
        var recUi = event.getParam("recordUi");
        helper.preserveValuesOnUpdateBeforeChange(component, helper, recUi);
        helper.setKnowledgeURL(component, recUi.record.fields["UI_Name__c"].value);
        helper.setContentOwnerName(component, helper, recUi.record.fields["OwnerId"].value);//ENH-4370
        component.set("v.Spinner", false);
    },

    handleDeselect : function(component, event, helper){

        var rowIndex = event.target.getAttribute("data-delete-index");
        helper.removeFromDeleteList(component, rowIndex);
    },

})