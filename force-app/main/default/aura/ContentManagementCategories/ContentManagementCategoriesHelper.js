({
    
    maxFileSize                 : 4500000, //Max file size 4.5 MB,
    CHUNK_SIZE                  : 750000,  // Chunk size 750KB,
    errorFileSize               : 'File size cannot exceed {0} MB. Selected file size: {1} MB',
    fieldsToValidate            : {},
    communityNameMap            : {},
    allFieldsForKnowledge       : [],
    allFieldsForTile            : [],
    relatedArticleValue         : 'Related Article',
    createKnowledge             : 'createKnowledge',
    editKnowledge               : 'editKnowledge',
    deleteLookUpAuraId          : 'sobjectDeleteLookup',
    updateLookUpAuraId          : 'sObjectUpdateLookup',
    createH5LookUpAuraId        : 'sobjectH5Lookup',
    createH1LookUpAuraId        : 'sobjectH1Lookup',
    createContentOwnerLookUpAuraId : 'sobjectContentOwnerCreateLookup',
    updateContentOwnerLookUpAuraId : 'sObjectContentOwnerUpdateLookup',
    fieldsToValidateDuringUpdate : {},

    checkKnowledgeUserAndSetData : function(component, event, helper) {

        component.set("v.Spinner", true);
        /*var action = component.get("c.checkKnowledgeUser");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var isKnowledgeUser = response.getReturnValue();

                isKnowledgeUser ? helper.setDataforKnowledgeUser(component, helper) : component.set("v.isKnowledgeUser", false);
 
                if(!isKnowledgeUser) component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);*/

        helper.callApexMethod(component, 'checkKnowledgeUser', {})
        .then($A.getCallback(function(isKnowledgeUser){

            isKnowledgeUser ? helper.setDataforKnowledgeUser(component, helper) : component.set("v.isKnowledgeUser", false);
            if(!isKnowledgeUser) component.set("v.Spinner", false);
        }))
        .catch(function(error){

            component.set("v.Spinner", false);
            if(error != undefined && error != '') helper.fireToastMessage('Error', error[0].message, 'error');
        });
    },
    //B2B-326
    showErrorPopup: function(message) {
        // Assuming you have a method to show popups, e.g., using a toast or custom modal
        const toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": "Error",
                "message": message,
                "type": "error"
            });
            toastEvent.fire();
        } else {
            // Fallback if toast event is not available
            alert(message); // Use alert as a simple alternative
        }
    },
    //B2B-326

    setDataforKnowledgeUser : function(component, helper) {
        //helper.setContentTree(component,helper);
        helper.setLibraryTree(component, helper);
        helper.setContentInfoOnInit(component, helper);
        component.set("v.isKnowledgeUser", true);
    },

    setKnowledgeURL : function(component, knowledgeArticleName){

        var outputst =  knowledgeArticleName.replace(/[^a-z0-9]+/gi, '-').replace(/^-+/, '').replace(/-+$/, '');
        component.set("v.knowledgeURL", outputst);
    },

    setContentInfoOnInit : function(component, helper) {

        component.set("v.Spinner", true);

        var action = component.get("c.initializeContentData");

        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.contentWrapper", result);
     
                //Set Community Names
                helper.setCommunityNames(component, helper, result.names);

                //Set ContentType based on Community Selected, By default it is always FCI Distributor Community
                helper.setContentTypes(component, /* result.names[0] */ '', result.nameContentTypeMap);

                //Sets Business Segment
                helper.setBusinessSegments(component, helper, result.businessSegSubSegMap);

                //Set Sales Region
                helper.setSalesRegion(component, helper, result.salesRegions);

                //Set Content Categories
                helper.setContentCategories(component, helper, result.contentCategories);

                //helper.createContentCategoryObj(component, 0);
                //Set SubSegment (Not needed now as Sub-segment will always be blank)
                //helper.setSubSegments(component, helper, '', result.businessSegSubSegMap);

                helper.createContentLibraryLocationObj(component, helper);

                helper.createContentPathLocationObj(component, helper);

                component.set("v.Spinner", false);
            }else{
            }
        });
        $A.enqueueAction(action);
    },

    setLabelsOnInit : function() {
        
        // this.errorFileSize = $A.get("$Label.c.Error_file_size");
        this.fieldsToValidate = {
            "v.communityNameSelected"   : 'Community not selected',
            "v.contentTypeSelected"     : 'Content type not selected',
            "v.knowledgeArticleName"    : 'Knowledge Article Name not entered',
            "v.knowledgeURL"            : 'Knowledge URL cannot be generated, please enter proper knowledge article name',
            "v.knowledgeDescription"    : 'Knowledge description is not entered',
            "v.reviewOrEndDate"         : 'Plese enter Review/End Date',
            "v.fileName"                : 'Please select an article to proceed',
            "v.selectedContentOwner"	: 'Please select Content Owner'
        };
        
        this.fieldsToValidateDuringUpdate = {
            "v.selectedContentOwner"	: 'Please select Content Owner'
        }

        this.communityNameMap = {
            "FCI Distributor Connect"   : 'FCI Distributor Community',
            "FCI Customer Connect"      : 'FCI Customer Community',
            "FC Employee Connect"		: 'FC Employee Community'//ENH-5684 - Added Employee Community as an option in the Content Management Tool
        };

        this.allFieldsForKnowledge = [
            "UI_Name__c",
            "UI_Description__c",
            "Review_End_Date__c",
            "Business_Segment__c",
            "Sub_Segment__c",
            "OwnerId"
        ];

        this.allFieldsForTile = [

            //"Work_Location__c",
            //"Parent_Account__c",
            "Application__c",
            "Community_Name__c",
            "Sales_Region__c",
            "OwnerId"
        ];

    },

    preserveValuesOnUpdateBeforeChange : function(component, helper, recUi){

        var originalObj = component.get("v.originalValueEditForm");
        let allUpdateFields = [...helper.allFieldsForTile, ...helper.allFieldsForKnowledge];
        for(let i = 0; i < allUpdateFields.length; i++){

            originalObj[allUpdateFields[i]] = recUi.record.fields[allUpdateFields[i]].value;
        }
    },

    isAnyChangeDoneByUserRequiresKnowledgePublish : function(component, helper, fields){

        var originalObj = component.get("v.originalValueEditForm");
        for(let i = 0; i < helper.allFieldsForKnowledge.length; i++){

            if(originalObj[helper.allFieldsForKnowledge[i]] != fields[helper.allFieldsForKnowledge[i]]){

                return true;
            }
        }

        return false;
    },

    isChangeDoneByUserRequiresTileUpdate : function(component, helper, fields){

        var originalObj = component.get("v.originalValueEditForm");
        for(let i = 0; i < helper.allFieldsForTile.length; i++){

            if(originalObj[helper.allFieldsForTile[i]] != fields[helper.allFieldsForTile[i]]){
                return true;
            }
        }
        return false;
    },

    isAnyChangeDoneInContent : function(component){

        let contentPathList = component.get("v.contentPathLocationList");
        let existingTileIds = component.get("v.existingTileIds");

        if(component.get("v.isRelatedArticle")) return false;

        let filteredTileIds = contentPathList.filter(function isIncludedinExistingTileIds(eachContentPath) {

            return existingTileIds.includes(eachContentPath.SelectedTileId)
        });

        if(filteredTileIds.length != existingTileIds.length) return true;

        return false;
    },

    isAnyChangeDoneInLibrary : function(component){

        let contentLibraryList = component.get("v.contentLibraryLocationList");
        let existingFolderLibraryIds = component.get("v.existingFolderLibraryIds");

        let filteredFolderLibraryIds = contentLibraryList.filter(function isIncludedinExistingFolderLibraryIds(eachContentLibrary) {

            return existingFolderLibraryIds.includes(eachContentLibrary.SelectedFolderLibraryId)
        });

        if(filteredFolderLibraryIds.length != existingFolderLibraryIds.length) return true;

        return false;
    },

    isAnyNewFileisChosen : function(component){

        if(component.find("fileId").get("v.files") == undefined) return false;
        
        return true;
    },

    isAnyChangeInContentCategories : function(component){

        let contentCategoriesObjList = component.get("v.contentCategoriesObjList");
        let existingContentCategories = component.get("v.existingContentCategories");

        if(contentCategoriesObjList.length != existingContentCategories.length) return true;

        for(var i = 0; i < contentCategoriesObjList.length; i++){

            if(contentCategoriesObjList[i].contentCategorySelected != existingContentCategories[i].contentCategorySelected 
                || contentCategoriesObjList[i].tileKnowledgeId != existingContentCategories[i].tileKnowledgeId){

                    return true;
            }   
        }
        
        return false;
    },

    getSFCommunityNames : function(helper, communityNames){

        var commSplit = communityNames.split(",");
        var sfcommunityNames = '';
        for(var eachCMSCommunityLabelName in commSplit){
            
            var eachSFCommunityName = commSplit[eachCMSCommunityLabelName];
            sfcommunityNames = sfcommunityNames + helper.communityNameMap[eachSFCommunityName] + ';';
        }

        return sfcommunityNames;
    },

    setContentTree : function(component, helper, communityNames){

        component.set("v.Spinner", true);
        var action = component.get("c.getContentTree");
        action.setParams({
            contentfirstTileName    : component.get("v.contentTypeSelected"),
            tileCommunityName       : communityNames
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.contentTree", result.contentTree);
                component.set("v.validContentMap", result.validContentMap);
                component.set("v.Spinner", false);
                helper.resetContentLocationsContentTree(component, helper);
            }
        });
        $A.enqueueAction(action);
    },

    resetContentLocationsContentTree : function(component, helper){
        
        var contentLocations = component.find("contentLocationId");
        
        if(contentLocations != undefined){

            if(Array.isArray(contentLocations)){

                for(var i = 0; i < contentLocations.length; i++){

                    contentLocations[i].setContentTreeforContentVM(
                        component.get("v.contentTree"), 
                        component.get("v.validContentMap"));
                }
            }else{
                contentLocations.setContentTreeforContentVM(
                    component.get("v.contentTree"),
                    component.get("v.validContentMap"));
            }
        }
    },

    adjustContentPathList : function(component, helper){

        var contentPathLocationList = component.get("v.contentPathLocationList");
        for(var i = 1; i < contentPathLocationList.length; i++){

            contentPathLocationList.splice(i, 1); 
        }
        component.set("v.contentPathLocationList", contentPathLocationList);
    },

    setLibraryTree : function(component, helper){

        component.set("v.Spinner", true);
        var action = component.get("c.getLibraryTree");
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.libraryTree", result.libraryTree);
                component.set("v.folderLibraryMap", result.folderLibraryMap);
                component.set("v.validLibraryMap", result.validLibraryMap);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    setContentCategories : function(component, helper, contentCategories){
        
        var contentCats = [];
        for(var i = 0; i < contentCategories.length; i++){
            var eachCategoryName = {
                "label" : contentCategories[i].split('-')[0].trim(),
                "value" : contentCategories[i].split('-')[1].trim(),
            };
            contentCats.push(eachCategoryName);
        }
        component.set("v.contentCategories",contentCats);
    },

    setCommunityNames : function(component, helper, commNames){
        
        var communityNames = [];
        for(var i = 0; i < commNames.length; i++){
            var eachCommunityName = {
                "label" : commNames[i],
                "value" : commNames[i]
            };
            communityNames.push(eachCommunityName);
        }
        component.set("v.communityNames",communityNames);
    },

    setContentTypes : function(component, communityNames, contentTypeMap){
        
        var dependentValues = [];

        if(communityNames.split(",") != undefined && communityNames.split(",") != ''){

            var commSplit = communityNames.split(",");
            for(var eachCommunityName in commSplit){
                
                var dependentValuesList = contentTypeMap[commSplit[eachCommunityName]];
                for (var j = 0; j < dependentValuesList.length; j++) {

                    var eachDependentValue = {
                        "label" : dependentValuesList[j].split('-')[0].trim(),
                        "value" : dependentValuesList[j].split('-')[1].trim(),
                    };

                    if(j == 0){
        
                        component.set("v.contentTypeSelected", eachDependentValue.value);
                    }

                    dependentValues.push(eachDependentValue);
                }
            }

            //Adding Related Article value to Content Types, it will be present for all the communities
            var relatedArticleValue = {
                "label" : this.relatedArticleValue,
                "value" : this.relatedArticleValue,
            };

            dependentValues.push(relatedArticleValue);
        }
        /*else{

            //Adding Related Article value to Content Types, it will be present for all the communities
            var noneValue = {
                "label" : 'None',
                "value" : 'None',
            };

            dependentValues.push(noneValue);
        }*/

        if(dependentValues.length == 1 ){
            component.set("v.contentTypesDisabled", true);
        }else if(dependentValues.length > 1){
            component.set("v.contentTypesDisabled", false);
        }
        
        //ENH-5684 - Remove duplicates from the array "dependentValues" - This is added in order to remove the duplicate values that were appearing in the content type field in the content management tool
        let uniqueDependentValues = Array.from(new Set(dependentValues.map(JSON.stringify)), JSON.parse);
        component.set("v.contentTypes", uniqueDependentValues);
    },

    setBusinessSegments : function(component, helper, businessSegSubSegMap){

        var businessSegments = [];
        for (var eachBusinessSeg in businessSegSubSegMap) {
            var eachBusinessSegment = {
                "label": eachBusinessSeg,
                "value": eachBusinessSeg
            };
            businessSegments.push(eachBusinessSegment);
        }
        component.set("v.businessSegments",businessSegments);
    },

    setSubSegments : function(component, event, helper, businessSegmentsSelected, businessSegSubSegMap){

        var subSegments = [];
        for(var i = 0; i < businessSegmentsSelected.length; i++){

            for(var j = 0; j < businessSegSubSegMap[businessSegmentsSelected[i]].length; j++){

                var eachSubSegment = {
                    "label": businessSegSubSegMap[businessSegmentsSelected[i]][j],
                    "value": businessSegSubSegMap[businessSegmentsSelected[i]][j]
                };
                subSegments.push(eachSubSegment);
            }
        }

        if(subSegments.length > 0){

            component.set("v.subSegments", subSegments);
            component.set("v.subSegmentDisabled", false);
        }else{

            component.set("v.subSegments", []);
            component.set("v.subSegmentDisabled", true);
        }
    },

    setSalesRegion : function(component, helper, allsalesRegions){

        var salesRegions = [];
        for(var i = 0; i < allsalesRegions.length; i++){
            var eachSalesRegion = {
                "label" : allsalesRegions[i].split('-')[0].trim(),
                "value" : allsalesRegions[i].split('-')[1].trim(),
            };
            salesRegions.push(eachSalesRegion);
        }
        component.set("v.salesRegions",salesRegions);
    },

    validateFileAndReturnStatus : function(component, event, helper){

        var file = event.getSource().get("v.files")[0];
        if (file.size > 0) {
            if (file.size > helper.maxFileSize) {
                helper.fireToastMessage('File Size Exceeded', helper.replaceIntoString(helper.errorFileSize, [(helper.maxFileSize/1000000), (file.size/1000000)]), 'error');
                return false;
            }
			
            if (file.name.split('.').pop() !== 'pdf' ) {
                helper.fireToastMessage('Wrong File Type', 'Only .pdf file is accepted', 'error');
                return false;
            }

            return true;
        }
    },

    setFileName : function(component, event, helper) {
        var fileName = event.getSource().get("v.files")[0]['name'];
        component.set("v.fileName", fileName);
    },

    replaceIntoString : function(strg, args) {
        var a = strg;
        for (var k in args) {
          a = a.replace("{" + k + "}", args[k]);
        }
        return a;
    },

    fireToastMessage : function(toastTitle, ToastMessage, ToastType){

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : toastTitle,
            message: ToastMessage,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration: '5000',
            key: 'info_alt',
            type: ToastType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    
    stickyToastMessage : function(toastTitle, ToastMessage, ToastType){

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : toastTitle,
            message: ToastMessage,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration: '30000',
            key: 'info_alt',
            type: ToastType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },

    validateAllInput : function(component, event, helper, isInsertOrUpdate){

        let fieldsToBeValidated = isInsertOrUpdate === 'Insert' ? this.fieldsToValidate : (isInsertOrUpdate === 'Update') ? this.fieldsToValidateDuringUpdate : {};
        
        for(var attributeName in fieldsToBeValidated){

            if(!helper.validateNullOrUndefined(component, attributeName)){

                if(attributeName == 'v.SelectedTileId' && component.get("v.isRelatedArticle")){
                    
                    continue;
                }
                helper.fireToastMessage('Fields Missing', this.fieldsToValidate[attributeName], 'error');
                return false;
            }
        }
        return true;
    },

    isContentLibrarySelectionValid : function(component, helper){

        var contentLibraryLocationList = component.get("v.contentLibraryLocationList");

        if(contentLibraryLocationList.some(eachContentLibraryObj => eachContentLibraryObj.SelectedFolderLibraryId == '')) { 
            helper.fireToastMessage('Library not selected','One/more Library section(s) are not having their libraries selected. Please choose all required library path before proceeding','error'); 
            return false;
        }

        const contentLibrarySet = new Set(contentLibraryLocationList.map(eachContentLibraryObj => eachContentLibraryObj.SelectedFolderLibraryId));
        if(contentLibrarySet.size !== contentLibraryLocationList.length){
            helper.fireToastMessage('Duplicate Library Path Selected','Library path should be unique across all Library sections','error');
            return false;
        }

        /*if(contentLibraryLocationList.some(eachContentLibraryObj => eachContentLibraryObj.SelectedFolderLibraryId != '') && !component.find("fileId").get("v.files")) { 
            helper.fireToastMessage('File not selected','Library path & file have to be selected in order to proceed','error'); 
            return false;
        }*/

        return true;
    },

    isContentPathSelectionValid : function(component, helper){

        var contentPathLocationList = component.get("v.contentPathLocationList");

        if(contentPathLocationList.some(eachContentPathObj => eachContentPathObj.SelectedTileId == '')
            && !component.get("v.isRelatedArticle")) { 

            helper.fireToastMessage('Content Path not selected','One/more Content Path section(s) are not having their paths selected. Please choose all required content path before proceeding','error');
            return false;
        }

        const contentPathSet = new Set(contentPathLocationList.map(eachContentPathObj => eachContentPathObj.SelectedTileId));
        if(contentPathSet.size !== contentPathLocationList.length){

            helper.fireToastMessage('Duplicate Content Path Selected','Content path should be unique across all Content path sections','error');
            return false;
        }

        return true;
    },

    validateNullOrUndefined : function(component, variableValue){

        return (component.get(variableValue) != '' && component.get(variableValue) != undefined) ? true : false;
    },

    toggleContentTypeDisabled : function(component, isContentDisabled, contentTypeSize){

        if(contentTypeSize == 1){

            component.set("v.contentTypesDisabled", true);
            return;
        }
        isContentDisabled ? component.set("v.contentTypesDisabled", true) : component.set("v.contentTypesDisabled", false);
    },

    createContentCategoryObj : function(component, index) {
        var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
		var contentType = component.get("v.contentTypes");
        let eachContentCategoryObj = {
            'contentCategorySelected' : '',
            'tileKnowledgeId' : '',
        };

        contentCategoriesObjList.splice(index, 0, eachContentCategoryObj);
        
        component.set("v.contentCategoriesObjList", contentCategoriesObjList); 
    },

    createContentLibraryLocationObj : function(component, helper) {
        var contentLibraryLocationList = component.get("v.contentLibraryLocationList");
        contentLibraryLocationList.push({
            'SelectedFolderLibraryId' : '',
            'LibraryStoragePath' : '',
            'SelectedLibraryFolder' : ''
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.contentLibraryLocationList", contentLibraryLocationList);
    },

    createContentPathLocationObj : function(component, helper) {
        var contentPathLocationList = component.get("v.contentPathLocationList");
        contentPathLocationList.push({
            'SelectedTileId' : '',
            'contentStoragePath' : '',
            'isATreeSelected' : false,
            'isACorrectTreeSelected' : false
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.contentPathLocationList", contentPathLocationList);
    },

    clearContentCategories : function(component){

        var contentCategoriesObjList = component.get("v.contentCategoriesObjList");
        for(var i = 0; i < contentCategoriesObjList.length; i++){

            contentCategoriesObjList.splice(i, 1); 
        }
        component.set("v.contentCategoriesObjList", contentCategoriesObjList);
    },

    resetContentCategories : function(component, helper){

        helper.clearContentCategories(component);
        helper.createContentCategoryObj(component, 0);
    },

    resetContentLibraries : function(component, helper){

        var contentLibraryLocationList = component.get("v.contentLibraryLocationList");
        for(var i = 0; i <= contentLibraryLocationList.length; i++){

            contentLibraryLocationList.splice(0,1); 
        }
        component.set("v.contentLibraryLocationList", contentLibraryLocationList);
        helper.createContentLibraryLocationObj(component, helper);
    },

    resetContentPaths : function(component, helper){

        var contentPathLocationList = component.get("v.contentPathLocationList");
        for(var i = 0; i <= contentPathLocationList.length; i++){

            contentPathLocationList.splice(0,1); 
        }
        component.set("v.contentPathLocationList", contentPathLocationList);
        helper.createContentPathLocationObj(component, helper);
    },

    toggleContentCategoriesMessage : function(component, isContentDisabled){
        
        if(isContentDisabled){

            $A.util.addClass(component.find('relatedInfogrid'),"greyClass");
            $A.util.addClass(component.find('relatedArticleInfo'),"slds-hide");
            $A.util.removeClass(component.find('noRelatedArticleInfo'),"slds-hide");

        }else{

            $A.util.removeClass(component.find('relatedInfogrid'),"greyClass");
            $A.util.removeClass(component.find('relatedArticleInfo'),"slds-hide");
            $A.util.addClass(component.find('noRelatedArticleInfo'),"slds-hide");
        }
    },

    saveNewArticle : function(component, event, helper){
        component.set("v.Spinner", true);
        let params = ({
            selectArticleTileName   : component.get("v.knowledgeArticleName"),
            knowledgeURL            : component.get("v.knowledgeURL")
        });
        helper.callApexMethod(component, 'checkValidationAndSendMessage', params)
        .then(validationMessage => {
            helper.toggleModalVisibility(component);
            if(validationMessage != '' && validationMessage != undefined) {
                component.set("v.Spinner", false);
                helper.fireToastMessage(validationMessage.split('-')[0], validationMessage.split('-')[1],'error');
                return Promise.reject();
            }else{
                helper.fireToastMessage('Validation Successful', 'This article is valid, Article Upload in Progress. Please wait for article to be uploaded','success');
                return helper.readFileData(component);
            }
        }).then(fileContents => {
            var startPosition = 0;
            let endPositon = parseInt(Math.min(parseInt(fileContents.length), parseInt(startPosition)+parseInt(helper.CHUNK_SIZE)));
            helper.uploadFileInChunk(component,helper,fileContents,parseInt(startPosition),parseInt(endPositon), '','');
       }) .catch( error => {
            component.set("v.Spinner", false);
            if(error != undefined && error != '') helper.fireToastMessage('Error', error[0].message, 'error');
        })
    },

    getApexParamsOnSaveNew : function(component, helper, cvId) {
		/*B2B-326*/
		var contentType = component.get("v.contentTypes");
        /*B2B-326*/
        let params = ({
            selectedCommunityNames      : helper.getSFCommunityNames(helper, component.get("v.communityNameSelected").toString()),
            knowledgeArticleName        : component.get("v.knowledgeArticleName"),
            knowledgeDescription        : component.get("v.knowledgeDescription"),
            reviewOrEndDate             : component.get("v.reviewOrEndDate"),
            contentCategoriesObjList    : JSON.stringify(component.get("v.contentCategoriesObjList")),
            businessSegments            : component.get("v.businessSegmentsSelected"),
            subSegments                 : component.get("v.subSegmentsSelected"),
            salesRegions                : component.get("v.salesRegionsSelected"),
            fileName                    : component.get("v.fileName"),
            contenVersionId             : cvId,
            knowledgeArticleURL         : component.get("v.knowledgeURL"),
            contentPathLocationList     : JSON.stringify(component.get("v.contentPathLocationList")),
            contentLibraryLocationList  : JSON.stringify(component.get("v.contentLibraryLocationList")),
            selectedContentOwner		: component.get("v.selectedContentOwner"),
            selectedH1Accounts          : component.get("v.selectedH1Accounts"),
            selectedH5Accounts          : component.get("v.selectedH5Accounts"),
			/*B2B-326*/
            categoryObjArrayData: 		JSON.stringify({
            									contentType: contentType,
            									categoryList: component.get("v.contentManagentCategryList")
            
        								})
         /*B2B-326*/
        });

        return params;
    },

    toggleModalVisibility : function(component){

        component.set("v.showModal", !component.get("v.showModal"));
    },

    setPageNavigation : function(component, helper, isUpdateCreateDelete){

        if(isUpdateCreateDelete == 'Update'){

            component.set("v.isSelectionPage", false);
            component.set("v.isUpdatePage", true);

        }else if(isUpdateCreateDelete == 'Insert'){

            component.set("v.isSelectionPage", false);
            component.set("v.isCreationPage", true);

            helper.resetContentCategories(component, helper);
            helper.setSelectedLookupValues(component, event, helper, component.get('v.contentWrapper').contentOwnerId, component.get('v.contentWrapper').contentOwnerName, 'Insert');

        }else if(isUpdateCreateDelete == 'Delete'){
            
            component.set("v.isSelectionPage", false);
            component.set("v.isDeletePage", true);

            helper.clearContentCategories(component);
        }else{

            component.set("v.isSelectionPage", true);
            component.set("v.isUpdatePage", false);
            component.set("v.isCreationPage", false);
            component.set("v.isDeletePage", false);

            helper.clearContentCategories(component);
        }
    },

    setEditForm : function(component, helper, selectedRecordId){

        component.set("v.Spinner", true);
        let communityName = '';
        var rootTileName = '';
        let tileName = '';
        let articleId = '';
        let params = ({tileId : selectedRecordId});

        helper.callApexMethod(component, 'getATileInfo', params)
        .then($A.getCallback(function(tileObject){

            component.set("v.Spinner", false);
            if(helper.checkFileContentDocumentIdValidity(helper, tileObject.File_ContentDocumentId__c)){

                /*if(tileObject.Parent_Tile__c == '' || tileObject.Parent_Tile__c == undefined){

                    component.set("v.isRelatedArticle", true);
                    //helper.fireToastMessage('Related Article', 'You cannot select content path for Related Articles', 'warning');
                    //return Promise.resolve('');

                }else{*/

                    component.set("v.isRelatedArticle", false);
                    tileName = tileObject.Name;
                    articleId = tileObject.Article_Name__c;
                    communityName = tileObject.Community_Name__c;

                    let params = ({tileObj : tileObject, rootTileName : ''});
                    return helper.callApexMethod(component, 'getRootTileName', params);
                
            }else{

                helper.clearTileSelectionLookUp(component, helper.updateLookUpAuraId);
                var errorLabel = $A.get("$Label.c.CMSErrorMesage");
                helper.stickyToastMessage('Article Issue', errorLabel, 'error');
                return Promise.reject('');
            }

        }))
        .then($A.getCallback(function(rootTile){
            
            if(component.get("v.isRelatedArticle")) { return Promise.resolve(''); }
            component.set("v.Spinner", false);
            rootTileName = rootTile;
            let params = ({ contentfirstTileName : rootTile, tileCommunityName : communityName});
            return helper.callApexMethod(component, 'getContentTree', params);
        }))
        .then($A.getCallback(function(result){

            if(component.get("v.isRelatedArticle")) { return Promise.resolve(''); }
            component.set("v.Spinner", false);
            component.set("v.contentTree", result.contentTree);
            component.set("v.validContentMap", result.validContentMap);
            component.set("v.Spinner", false);
            helper.resetContentLocationsContentTree(component, helper); //reset content tree in child, calls child method

            let params = {
                tileName        : tileName,
                articleId       : articleId
            }

            return helper.callApexMethod(component, 'getExistingContentPath', params);
        }))
        .then($A.getCallback(function(tileIds){

            if(!component.get("v.isRelatedArticle")) { 

                let validContentMap = component.get("v.validContentMap");
                helper.resetContentPathAndLibraries(component, helper); //reset path and libraries
                let contentPathLocationList = component.get("v.contentPathLocationList");
                contentPathLocationList.splice(0, contentPathLocationList.length);
                component.set("v.existingTileIds", tileIds);

                for(var i = 0; i < tileIds.length; i++){

                    contentPathLocationList.push({
                        'SelectedTileId' : tileIds[i],
                        'contentStoragePath' : validContentMap[tileIds[i]],
                        'isATreeSelected' : true,
                        'isACorrectTreeSelected' : true
                    }); 
                }
                component.set("v.contentPathLocationList", contentPathLocationList);
                }
                // B2B-325 
            let tileParams = { tileIds: component.get("v.editRecordId") };
            return helper.callApexMethod(component, 'getH5AndH1Accounts', tileParams);
        }))
        .then($A.getCallback(function(result) {
            if (component.get("v.isRelatedArticle")) { return Promise.resolve(''); }
            
            //B2B-325
            let existingH5Accounts = result.existingH5Accounts || [];
            let existingH1Accounts = result.existingH1Accounts || [];
            let existingH5AccountsIds = existingH5Accounts.map(account => account.Id);
            let existingH1AccountsIds = existingH1Accounts.map(account => account.Id);
            let existingH5AccountsNames = existingH5Accounts.map(account => account.Name);
        	let existingH1AccountsNames = existingH1Accounts.map(account => account.Name);

            component.set("v.existingH5AccountsIds", existingH5AccountsIds);
            component.set("v.selectedH5AccountsNames", existingH5AccountsNames.join(', '));
            component.set("v.existingH1AccountsIds", existingH1AccountsIds);
            component.set("v.selectedH1AccountsNames", existingH1AccountsNames.join(', '));
            component.set("v.existingH5AccountsIdsOld", existingH5AccountsIds);
            component.set("v.existingH1AccountsIdsOld", existingH1AccountsIds);
            

            let params = { tileId: selectedRecordId };
            return helper.callApexMethod(component, 'getExistingLibraryPaths', params);
        }))
        .then($A.getCallback(function(folderLibraryIds){

            let validLibraryMap = component.get("v.validLibraryMap");

            let contentLibraryLocationList = component.get("v.contentLibraryLocationList");
            contentLibraryLocationList.splice(0, contentLibraryLocationList.length);
            component.set("v.existingFolderLibraryIds", folderLibraryIds);

            for(var i = 0; i < folderLibraryIds.length; i++){

                let eachFolderId = folderLibraryIds[i].split('-')[0];
                var libraryPath = validLibraryMap[eachFolderId];
                contentLibraryLocationList.push({
                    'SelectedFolderLibraryId' : folderLibraryIds[i],
                    'LibraryStoragePath' : libraryPath,
                    'SelectedLibraryFolder' : eachFolderId
                }); 
            }
            component.set("v.contentLibraryLocationList", contentLibraryLocationList);

            let params = ({tileId : selectedRecordId});
            return helper.callApexMethod(component, 'getExistingRelatedArticles', params);
        }))
        .then($A.getCallback(function(contentCategories){

            if(component.get("v.isRelatedArticle")) { 
                
                helper.toggleContentCategoriesMessage(component, component.get("v.isRelatedArticle"));
              //  return Promise.resolve(''); 
            }
            let contentCategoriesObjList = [];
            for(var i = 0; i < contentCategories.length; i++){

                contentCategoriesObjList.push({
                    'contentCategorySelected' : contentCategories[i].split('-')[0],
                    'tileKnowledgeId' : contentCategories[i].split('-')[1],
                    'tileKnowledgeName' : contentCategories[i].split('-')[2]
                });
            }
            
			// set the updated list to attribute (contactList) again 
            component.set("v.existingContentCategories", JSON.parse(JSON.stringify(component.get("v.contentCategoriesObjList"))));
            component.set("v.contentCategoriesObjList", contentCategoriesObjList);
            
            if(contentCategories.length == 0){

                helper.createContentCategoryObj(component, 0);
            }
            //contentCategoriesObjList.splice(index, 0, eachContentCategoryObj);
            
        }))
        .catch(function(error){

            component.set("v.Spinner", false);
            if(error != 'RETAIN'){
                component.set("v.editRecordId", '');
            }
            if(error != undefined && error != '' && error[0] != undefined) helper.fireToastMessage('Error', error[0].message, 'error');
            if(error[0] == undefined) helper.fireToastMessage('Error', error.message, 'error');
        });
    },

    checkFileContentDocumentIdValidity : function(helper, contentDocumentId){

        if(contentDocumentId != '' && contentDocumentId != undefined && contentDocumentId != null){

            return true;
        }
        return false;
    },

    saveEditedArticle : function(component, helper, params){

        let pr;
        component.set("v.Spinner", true);

        if(params.isUINameChanged){

            let validationparams = {
                selectArticleTileName   : params.UIName,
                knowledgeURL            : params.knowledgeURL
            };

            pr = helper.callApexMethod(component, 'checkValidationAndSendMessage', validationparams);
        }else {

            pr = new Promise(function(resolve, reject){

                resolve('');
            });
        }
        pr
        .then(validationMessage => {

            if(validationMessage != '' && validationMessage != undefined) {
                
                helper.fireToastMessage(validationMessage.split('-')[0], validationMessage.split('-')[1],'error');
                component.set("v.Spinner", false);
                return Promise.reject();
            }else{

                if(params.isNewFileChosen) return helper.readFileData(component);
                else return Promise.resolve('');
            }
        })
        .then(fileContents =>{
            if(fileContents !=='' && !$A.util.isUndefinedOrNull(fileContents)){
                var startPosition = 0;
                let endPositon = parseInt(Math.min(parseInt(fileContents.length), parseInt(startPosition)+parseInt(helper.CHUNK_SIZE)));
                helper.uploadFileInChunk(component,helper,fileContents,parseInt(startPosition),parseInt(endPositon), '', params);
            }else{
                //let saveParams = helper.getApexParamsOnSaveEdit(component, fileContents, params);
                //return helper.callApexMethod(component, 'saveEditedArticleData', saveParams);
              helper.saveEditMethod(component,helper,fileContents,'saveEditedArticleData',params);
        		
            } 
        })
        .catch(function(error){

            component.set("v.Spinner", false);
            if(error != undefined && error != '') helper.fireToastMessage('Error', error[0].message, 'error');
            helper.resetContentPathAndLibraries(component, helper);
            helper.clearTileSelectionLookUp(component, helper.updateLookUpAuraId);
        });
    },

    getTypeOfOperationOnEditSave : function(
        isChangeDoneByUserRequiresKnowledgePublish,
        isChangeDoneByUserContentPath,
        isChangeDoneByUserLibraryPath,
        isChangeDoneByUserRequiresTileUpdate,
        isNewFileChosen){
			
            //A
            if(isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && !isNewFileChosen)
            return 'onlyKnowledgeFields';  
            
             //B2B-152
        	if(!isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && !isNewFileChosen && isChangeDoneByUserRequiresTileUpdate)
            return 'onlyKnowledgeFields';
        
            //B
            if(!isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && !isNewFileChosen)
            return 'onlyContentPaths';

            //C
            if(!isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && !isNewFileChosen)
            return 'onlyLibraryPaths';

            //D
            if(!isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'onlyNewFileChosen';

            //A-B
            if(isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && !isNewFileChosen)
            return 'knowledgeFields_contentPaths';

            //A-C
            if(isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && !isNewFileChosen)
            return 'knowledgeFields_libraryPaths';

            //A-D
            if(isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'knowledgeFields_newFileChosen';

            //B-C
            if(!isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && !isNewFileChosen)
            return 'contentPaths_libraryPaths';

            //B-D
            if(!isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'contentPaths_newFileChosen';

            //C-D
            if(!isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'libraryPaths_newFileChosen';

            //A-B-C
            if(isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && !isNewFileChosen)
            return 'knowledgeFields_contentPaths_libraryPaths';

            //A-B-D
            if(isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && !isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'knowledgeFields_contentPaths_newFileChosen';

            //A-C-D
            if(isChangeDoneByUserRequiresKnowledgePublish && !isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'knowledgeFields_libraryPaths_newFileChosen';

            //B-C-D
            if(!isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'contentPaths_libraryPaths_newFileChosen';

            //A-B-C-D
            if(isChangeDoneByUserRequiresKnowledgePublish && isChangeDoneByUserContentPath && isChangeDoneByUserLibraryPath && isNewFileChosen)
            return 'knowledgeFields_contentPaths_libraryPaths_newFileChosen';
    },

    getApexParamsOnSaveEdit : function(component, cvId, params){

        let saveParams = ({
            tileObj                     : JSON.stringify(params.tileObj),
            contentVersionId            : cvId != '' ? cvId : '',
            fileName                    : component.get("v.fileName"),
            knowledgeURL                : component.get("v.knowledgeURL"),
            contentLibraryLocationList  : JSON.stringify(component.get("v.contentLibraryLocationList")),
            contentPathLocationList     : JSON.stringify(component.get("v.contentPathLocationList")),
            operation                   : params.allOperations,
            contentCategoriesObjList    : (params.isRelatedArticleChanged && !component.get("v.isRelatedArticle")) ? JSON.stringify(component.get("v.contentCategoriesObjList")) : '',
            selectedContentOwnerId		: component.get("v.selectedContentOwner"),
			/*B2B-326*/
             categoryObjArrayData: 		JSON.stringify({
                        					contentType: contentType,
                        					categoryList: component.get("v.contentCategoriesObjList")
                    					})
            /*B2B-326*/
        });

        return saveParams;
    },
    
    readFileData : function(component){

        var file = component.find("fileId").get("v.files")[0];
        var objFileReader = new FileReader();

        return new Promise((resolve, reject) => {
            
            objFileReader.onerror = () => {
                objFileReader.abort();
                reject(new DOMException("Problem parsing input file."));
            };

            objFileReader.onload = () => {
                var fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
    
                fileContents = fileContents.substring(dataStart);
                
                resolve(fileContents);
            };
            objFileReader.readAsDataURL(file);
        });
    },

    saveKnowledgeArticleEdit : function(component, helper, tileObj, fileContents){

        component.set("v.Spinner", true);
        let params = ({
            tileObj                     : JSON.stringify(tileObj),
            base64Data                  : fileContents != '' ? encodeURIComponent(fileContents) : '',
            folderLibMap                : component.get("v.folderLibraryMap"),
            fileName                    : component.get("v.fileName"),
            knowledgeURL                : component.get("v.knowledgeURL"),
            contentLibraryLocationList  : JSON.stringify(component.get("v.contentLibraryLocationList")),
            contentPathLocationList     : JSON.stringify(component.get("v.contentPathLocationList"))
        });

        helper.callApexMethod(component, 'saveEditedArticleData', params)
        .then($A.getCallback(function(response){

            component.set("v.Spinner", false);
            component.set("v.fileName", '');
            helper.fireToastMessage('Success', 'Knowledge Article synced properly', 'success');   
            helper.clearTileSelectionLookUp(component, helper.updateLookUpAuraId);
        }))
        .catch(function(error){

            component.set("v.Spinner", false);
            if(error != undefined && error != '') helper.fireToastMessage('Error', error[0].message, 'error');
        });
    },

    isTileDeletionSelectionValid : function(component, helper, selectedRecordId){

        var deletionList = component.get("v.artilesToDelete");

        const articleIds = new Set(deletionList.map(eachArticleToDelete => eachArticleToDelete.Id));
        if(articleIds.has(selectedRecordId)) { return false; }
        return true;
        
    },

    handleSObjectDeletion : function(component, helper, selectedRecordId){

        component.set("v.Spinner", true);
        let params = ({tileId : selectedRecordId});

        helper.callApexMethod(component, 'getATileInfo', params)
        .then($A.getCallback(function(tileObject){

            component.set("v.Spinner", false);
            if(helper.checkFileContentDocumentIdValidity(helper, tileObject.File_ContentDocumentId__c)){

                var artsToDelete = component.get("v.artilesToDelete");
                artsToDelete.push(tileObject);
                component.set("v.artilesToDelete",artsToDelete);
            }else{

                helper.fireToastMessage('Article Issue', 'Article data not correct. Cannot proceed with delete operation. Please contact Admin', 'error');
            }
            helper.clearTileSelectionLookUp(component, helper.deleteLookUpAuraId);

        }))
        .catch(function(error){

            component.set("v.Spinner", false);
            helper.fireToastMessage('Error', error[0].message, 'error');
        });
    },

    clearTileSelectionLookUp : function(component, lookupAuraId){

        var sobjectLookupComp = component.find(lookupAuraId);
        sobjectLookupComp.clearLookUp();
    },

    removeFromDeleteList : function(component, rowIndex){

        var artilesToDelete = component.get("v.artilesToDelete");        
        artilesToDelete.splice(rowIndex, 1);
        component.set("v.artilesToDelete", artilesToDelete);
    },

    resetDeleteList : function(component){

        var artilesToDelete = component.get("v.artilesToDelete");
        for(var i = 0; i <= artilesToDelete.length; i++){

            artilesToDelete.splice(0,1); 
        }
        component.set("v.artilesToDelete", artilesToDelete);

    },

    deleteAllArticles : function(component, helper){

        var deletionListIds = [];
        var deletionList = component.get("v.artilesToDelete");
        for (const eachTile of deletionList) {
            
            deletionListIds.push(eachTile.Id);
        }

        component.set("v.Spinner", true);

        let params = ({tileIds : deletionListIds});

        helper.callApexMethod(component, 'deleteAllArticlesFromDB', params)
        .then($A.getCallback(function(response){

            component.set("v.Spinner", false);
            helper.fireToastMessage('Deletion Successful', 'All articles & files related to the selected articles are deleted', 'success');
            helper.resetDeleteList(component);

        }))
        .catch(function(error){

            component.set("v.Spinner", false);
            helper.fireToastMessage('Error', error[0].message, 'error');
        });
    },

    callApexMethod : function(component, apexMethodName, params){

        return new Promise($A.getCallback(function(resolve, reject){

            let action = component.get("c."+apexMethodName);
            action.setParams(params);
            action.setCallback(this, function(response){

                let state = response.getState();
                if(state == 'SUCCESS'){

                    resolve(response.getReturnValue());
                }else{
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action);
        }));
    },

    reOrderRelatedContents : function(component, fromIndex, toIndex){

        var contentCatList = component.get("v.contentCategoriesObjList");
        var element = contentCatList[fromIndex];
        contentCatList.splice(fromIndex, 1);
        contentCatList.splice(toIndex, 0, element);
        component.set("v.contentCategoriesObjList",contentCatList);
    },

    resetContentPathAndLibraries : function(component, helper){

        helper.resetContentPaths(component, helper);
        helper.resetContentLibraries(component, helper);
    },

    /* Commenting this part of the code as this will upload the file in chunks, Keeping it because it might be required later */
    /*processUpload : function(component, file, fileContents) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
 
        // start with the initial chunk, and set the attachId(last parameter)is null in beginning
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },

    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachmentFileId) {
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.createKnowTileWithAttachment");
        action.setParams({
            selectedKnowledgeTileId     : component.get("v.SelectedTileId"),
            selectedCommunityName       : component.get("v.communityNameSelected"),
            knowledgeArticleName        : component.get("v.knowledgeArticleName"),
            knowledgeDescription        : component.get("v.knowledgeDescription"),
            reviewOrEndDate             : component.get("v.reviewOrEndDate"),
            contentCategoriesObjList    : JSON.stringify(component.get("v.contentCategoriesObjList")),
            businessSegments            : component.get("v.businessSegmentsSelected"),
            subSegments                 : component.get("v.subSegmentsSelected"),
            salesRegions                : component.get("v.salesRegionsSelected"),
            fileName                    : component.get("v.fileName"),
            base64Data                  : encodeURIComponent(getchunk),
            contentType                 : file.type,
            attachmentId                : attachmentFileId
        });
 
        // set call back 
        action.setCallback(this, function(response) {
            // store the response / Attachment Id   
            attachmentFileId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {

                this.appendChunkToAttachment(component, fileContents, startPosition, endPosition, attachmentFileId);
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                    }
                } else {
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    appendChunkToAttachment : function(component, fileContents, startPosition, endPosition, attachmentFileId){
        
        // update the start position with end postion
        startPosition = endPosition;
        endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        if (startPosition < endPosition) {

            var getchunk = fileContents.substring(startPosition, endPosition);
            this.appendChunkCallBE(component, fileContents, startPosition, endPosition, attachmentFileId, getchunk);
        } else {

            //component.set("v.disableSaveButton", false);
            component.set("v.Spinner", false);
            this.createfileFromAttachment(component, attachmentFileId);
            this.fireToastMessage('Success', 'Article Uploaded Successfully, Please wait for sometime before your content gets uploaded', 'success');
        }

    },

    appendChunkCallBE : function(component, fileContents, startPosition, endPosition, attachmentFileId, getchunk){

        var action = component.get("c.appendToExistingKnowledgeAttachment");
        action.setParams({
            attachmentId    : attachmentFileId,
            base64Data      : encodeURIComponent(getchunk)
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if(status === "SUCCESS") {
                var attachId = response.getReturnValue();
                this.appendChunkToAttachment(component, fileContents, startPosition, endPosition, attachId);
            }
        });
        $A.enqueueAction(action);
    },

    createfileFromAttachment : function(component, attachmentFileId){

        var action = component.get("c.createfileOutofAttachment");
        action.setParams({
            attachmentId        : attachmentFileId,
            knowledgeArticleURL : component.get("v.knowledgeURL")
        });
        $A.enqueueAction(action);
    }*/




   
/*
   @CreatedDate             : 03-12-2021
   @CreatedBy               : Mohammad Rafi
   @Prams                   :
       @fileContents        : File content it is coming from the readAsFile method in base64 format.
       @startPosition       : Start position of the file.
       @endPosition         : End position of the file chunck.
       @contentVersionId    : In the first chunk this it will be blank after inserting first id will return from apex method.
  @Descrittion              : This method used to upload file in chunck once chuck will be insert then saveMethod will be call to create/update artile
  @ApexMethod               : saveTheChunkFile

*/
uploadFileInChunk:function(component, helper,fileContents,startPosition,endPosition, contentVersionId,parameteronEdit){
    return new Promise(function(resolve, reject) {
        	var getchunk = fileContents.substring(parseInt(startPosition), parseInt(endPosition));
        	var params = helper.setPramsuploadFile(component,helper,getchunk,contentVersionId);
            var action = component.get("c.saveTheChunkFile");
            action.setParams(params);
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    startPosition = parseInt(endPosition);
                    endPosition = parseInt(Math.min(parseInt(fileContents.length), parseInt(startPosition)+parseInt(helper.CHUNK_SIZE)));
                    if (startPosition < endPosition) {
                        helper.uploadFileInChunk(component,helper,fileContents,parseInt(startPosition), parseInt(endPosition), response.getReturnValue(),parameteronEdit);
                    }else{
                      if(parameteronEdit === ''){
                         helper.saveNewMethod(component,helper,response.getReturnValue(),'createfinalKnowledgeData');
                      }else{
                         helper.saveEditMethod(component,helper,response.getReturnValue(),'saveEditedArticleData',parameteronEdit);
                      }
                      component.set("v.Spinner", false);
                      return Promise.resolve(true);
                    }
                }else{ 
                   return Promise.resolve(false);
                }
        });
        $A.enqueueAction(action);    
   });     
},

setPramsuploadFile : function(component, helper, getchunk,contentVersionId) {
    let params = ({
        fileName      : component.get("v.fileName"),
        base64Data    : encodeURIComponent(getchunk),
        fileId        : contentVersionId
    });  
    return  params;
},

/*
   @CreatedDate             : 03-12-2021
   @CreatedBy               : Mohammad Rafi
   @ApexMethod              : createfinalKnowledgeData
   @Descritption            : This method used for creating artile      
*/

saveNewMethod : function(component,helper,cvId,apexMethodName){
    let saveParams = helper.getApexParamsOnSaveNew(component, helper, cvId);
    let action = component.get("c."+apexMethodName);
       action.setParams(saveParams);
       action.setCallback(this, function(response){
           let state = response.getState();
           if(state == 'SUCCESS'){
              let res =  response.getReturnValue();
              component.set("v.Spinner", false);
              helper.fireToastMessage('Success', 'Article Uploaded Successfully', 'success');
           }else if (state === "ERROR") {
               let error = response.getError();
               component.set("v.Spinner", false);
               if(error != undefined && error != '') helper.fireToastMessage('Error', error[0].message, 'error');
           }
       });
   $A.enqueueAction(action);
},

/*
   @CreatedDate             : 03-12-2021
   @CreatedBy               : Mohammad Rafi
   @ApexMethod              : createfinalKnowledgeData
   @Descritption            : This method used for update artile      
*/
saveEditMethod : function(component,helper,cvId,apexMethodName,parameteronEdit){
     let saveParams = helper.getApexParamsOnSaveEdit(component, cvId, parameteronEdit);
     let action = component.get("c."+apexMethodName);
        action.setParams(saveParams);
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state == 'SUCCESS'){
               let res =  response.getReturnValue();
               component.set("v.Spinner", false);
               component.set("v.fileName", '');
               component.set("v.existingTileIds",[]);
               component.set("v.existingFolderLibraryIds",[]);
               helper.fireToastMessage('Success', 'Knowledge Article synced properly', 'success');   
               helper.resetContentPathAndLibraries(component, helper);
               helper.resetContentCategories(component, helper);
               helper.clearTileSelectionLookUp(component, helper.updateLookUpAuraId);
            }else if (state === "ERROR") {
                let error = response.getError();
                component.set("v.Spinner", false);
                if(error != undefined && error != '') helper.fireToastMessage('Error', error[0].message, 'error');
                helper.resetContentPathAndLibraries(component, helper);
                helper.clearTileSelectionLookUp(component, helper.updateLookUpAuraId);
            }
        });
    $A.enqueueAction(action);
},
            /*
       		@CreatedDate             : 19-12-2021
       		@CreatedBy               : Mahendra Kumar
       		@Descritption            : Method to pre-populate custom Lookup (Content Owner) value while creating/updating the article
            @JIRA #					 : ENH-4370
    		*/
            setSelectedLookupValues : function(component, event, helper, selectedLookupRecordId, selectedLookupRecordLabel, isInsertOrUpdate){
                var sObjLookUpCmp = isInsertOrUpdate === 'Insert' ? component.find(helper.createContentOwnerLookUpAuraId) : (isInsertOrUpdate === 'Update') ? component.find(helper.updateContentOwnerLookUpAuraId) : '';
                //var sObjLookUpCmp = component.find('sobjectContentOwnerCreateLookup');
                sObjLookUpCmp.setLookup(selectedLookupRecordId, selectedLookupRecordLabel);
            },
             
            /*
       		@CreatedDate             : 19-12-2021
       		@CreatedBy               : Mahendra Kumar
       		@ApexMethod              : getContentOwnerName
       		@Descritption            : Method to display the existing content owner name in the Content Owner field in CMS Tool
            @JIRA #					 : ENH-4370
    		*/
            setContentOwnerName : function(component, helper, contentOwnerId){
                component.set("v.selectedContentOwner", contentOwnerId);
                let action = component.get("c.getContentOwnerName");
                action.setParams({
                    contentOwnerId : component.get("v.selectedContentOwner")
                });
                action.setCallback(this, function(response){
                    let state = response.getState();
                    let responseVal = response.getReturnValue();
                    if(state === 'SUCCESS'){
                        helper.setSelectedLookupValues(component, event, helper, component.get('v.selectedContentOwner'), responseVal, 'Update');
                    }else{
                    }
                });
                $A.enqueueAction(action);
            },

    //B2B-325
    updateTileAccounts: function(component, helper, params) {
        var selectedH5Accounts = component.get("v.selectedH5Accounts");
        var selectedH1Accounts = component.get("v.selectedH1Accounts");
        var existingH5AccountsIds = component.get("v.existingH5AccountsIdsOld");
        var existingH1AccountsIds = component.get("v.existingH1AccountsIdsOld");
        var tileSelectedID = component.get("v.editRecordId");
        var accountsToDelete = [];
        var accountsToInsert = [];
        
        // Identify accounts to delete (those not in the updated list)
        if (selectedH5Accounts.length > 0) {
        existingH5AccountsIds.forEach(function(accountId) {
            if (!selectedH5Accounts.includes(accountId)) {
                accountsToDelete.push(accountId);
            }
        });
        }
        if (selectedH1Accounts.length > 0) {   
        existingH1AccountsIds.forEach(function(accountId) {
            if (!selectedH1Accounts.includes(accountId)) {
                accountsToDelete.push(accountId);
            }
        });
        }
    
        // Identify accounts to insert (those in the updated list but not in the existing list)
        selectedH5Accounts.forEach(function(accountId) {
            if (!existingH5AccountsIds.includes(accountId)) {
                accountsToInsert.push(accountId);
            }
        });
        
        selectedH1Accounts.forEach(function(accountId) {
            if (!existingH1AccountsIds.includes(accountId)) {
                accountsToInsert.push(accountId);
            }
        });
    
        // Apex call to update the Tile_Account__c records
        var params = {
            tileId: tileSelectedID,
            accountsToDelete: accountsToDelete,
            accountsToInsert: accountsToInsert
        };
        
        helper.callApexMethod(component, 'updateTileAccounts', params)
            .then($A.getCallback(function(result) {
                if (result) {
                    helper.fireToastMessage('Success', 'Tile Account records updated successfully', 'success');
                }
            }))
            .catch(function(error) {
                helper.fireToastMessage('Error', 'Failed to update Tile Account records', 'error');
            });
    }
            

})