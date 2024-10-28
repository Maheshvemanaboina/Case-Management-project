/**
 * Created by KJM on 11/04/2019.
 */
({
     doInit:  function(component, event, helper) {
        helper.setLabelsOnInit(component, event, helper);
        helper.clearMessages(component, event, helper);
        helper.setBaseUrl(component, event, helper);
        helper.setRadioOptions(component, event, helper);
    },

    handleFilesUploadChange: function(component, event, helper) {
        helper.clearAllComponentData(component, event, helper);

        var isFileValid = helper.validateFileFEAndReturnStatus(component, event, helper);
        if (isFileValid) {
            helper.setFileName(component, event, helper);
        }
    },

    handleActionButtonClick: function(component, event, helper) {
        helper.clearMessages(component, event, helper);
        console.log('datavalidated --> '+component.get("v.dataValidated"));
        if (component.get("v.dataValidated") == helper.booleanTrueValue) {
            helper.getFileContentAndCallToBE(component, event, helper, helper.actionOptionUpload, helper.uploadOptionUpload);
        } else {
            helper.getFileContentAndCallToBE(component, event, helper, helper.actionOptionValidate, '');
        }
    },

    handleOverwriteAndInsertButtonClick : function(component, event, helper) {
        helper.getFileContentAndCallToBE(component, event, helper, helper.actionOptionUpload, helper.uploadOptionInsertWithOverwrite);
    },

    handleOnlyInsertNewButtonClick : function(component, event, helper) {
        helper.getFileContentAndCallToBE(component, event, helper, helper.actionOptionUpload, helper.uploadOptionInsertOnlyNew);
    },

    handleChangeCsvFileType : function(component, event, helper) {
        helper.setCsvFileType(component, event, helper);
    },

    handleClickCSVChangeCheckbox : function(component, event, helper) {
        helper.setCsvChangeCheckboxValue(component, event, helper);
    }
})