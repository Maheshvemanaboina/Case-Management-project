/**
 * Created by KJM on 11/04/2019.
 */
({

    actionOptionValidate : "validate",
    actionOptionUpload : "insert",

    csvFileVersionLocale : 'locale',
    csvFileVersionNonLocale : 'nonLocale',

    uploadOptionUpload : "insertWithoutErr",
    uploadOptionInsertWithOverwrite : "insertWithOverwrite",
    uploadOptionInsertOnlyNew : "insertOnlyNew",

    csvFileTemplateOption : "csvFileTemplate",
    csvReportExportOption : "csvReportExport",

    booleanTrueValue : "true",
    booleanFalseValue : "false",

    maxFileSize : 4500000, //Max file size 4.5 MB
    allowedFileExtension : "csv", //Only csv extension

    buttonValidateLabel : '',
    buttonUploadLabel : '',

    errorFileExtension : '',
    errorFileSize : '',
    errorNoFileFound : '',
    errorDuringProcessData : '',
    errorServer : '',
    errorDuplicated : '',

    successFileUploaded : '',
    successFileValidated : '',

    setLabelsOnInit : function(component, event, helper) {
        helper.buttonValidateLabel = $A.get("$Label.c.Button_Validate");
        helper.buttonUploadLabel = $A.get("$Label.c.Button_insert");

        helper.errorFileExtension = $A.get("$Label.c.Error_file_extenstion");
        helper.errorFileSize = $A.get("$Label.c.Error_file_size");
        helper.errorNoFileFound = $A.get("$Label.c.Error_no_file");
        helper.errorDuringProcessData = $A.get("$Label.c.Error_during_process_data");
        helper.errorServer = $A.get("$Label.c.Error_server_internal");
        helper.errorDuplicated = $A.get("$Label.c.Error_duplicates_found");

        helper.successFileUploaded = $A.get("$Label.c.Success_data_inserted");
        helper.successFileValidated = $A.get("$Label.c.Success_data_validated");
    },

    setBaseUrl :  function(component, event, helper) {
       var urlString = window.location.href;
       
       var baseURL = urlString.substring(0, urlString.indexOf("IngredientsMyDistributorcommunity/s"));
       baseURL = baseURL + 'IngredientsMyDistributorcommunity'
       console.log('baseURL'+baseURL);
       component.set("v.baseUrl", baseURL);
    },

    setRadioOptions :  function(component, event, helper) {
        component.set("v.fileCreationOptions", [
            {"label" : "CSV file template - file downloaded from this page and filled in manually.", "value": helper.csvFileTemplateOption},
            {"label" : "CSV report export - file exported from Salesforce report.", "value" : helper.csvReportExportOption}
          ]
        );
    },


    validateFileFEAndReturnStatus : function(component, event, helper) {
        var file = event.getSource().get("v.files")[0];
        if (file.size > 0) {
            if (file.size > helper.maxFileSize) {
                helper.showErrorMessage(component, true, helper.replaceIntoString(helper.errorFileSize, [helper.maxFileSize, file.size]));
                return false;
            }

            if (file.name.split('.').pop() !== helper.allowedFileExtension) {
                helper.showErrorMessage(component, true, helper.errorFileExtension);
                return false;
            }

            return true;
        }

        helper.showErrorMessage(component, true, helper.errorNoFileFound);
        return false;
    },

    setFileName : function(component, event, helper) {
        var fileName = event.getSource().get("v.files")[0]['name'];
        component.set("v.fileName", fileName);
    },

    getFileContentAndCallToBE : function(component, event, helper, actionType, uploadOption) {
        helper.clearMessages(component, event, helper);

        component.set("v.showLoadingSpinner", true);

        var fileInput = component.find("fileId").get("v.files");
        var file = fileInput[0];
        var self = this;

        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;

            fileContents = fileContents.substring(dataStart);
            self.validateFileBE(component, helper, file, fileContents, actionType, uploadOption);
        });

        objFileReader.readAsDataURL(file);
    },

    validateFileBE: function(component, helper, file, fileContents, actionType, uploadOption) {
        var action;
        if (actionType === helper.actionOptionValidate) {
            action = component.get("c.validateFileData");
        } else if (actionType === helper.actionOptionUpload) {
            action = component.get("c.uploadFileData");
        }
		console.log('encode file contents '+encodeURIComponent(fileContents));
        console.log('Object API '+component.get("v.objectAPIName"));
        console.log('uploadOption --> '+uploadOption);
        console.log('csvfiletype --> '+component.find("csvFileType").get("v.value"));
        console.log('csvcreationOption --> '+component.get("v.radioButtonValue"));
        console.log('waschangeonreport --> '+component.get("v.wasCsvChangeAfterExport"));
        action.setParams({
            base64Data: encodeURIComponent(fileContents),
            objectAPIName : component.get("v.objectAPIName"),
            uploadOption : uploadOption,
            csvFileType :  component.find("csvFileType").get("v.value"),
            csvCreationOption : component.get("v.radioButtonValue"),
            wasChangeOnReport : component.get("v.wasCsvChangeAfterExport")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var respVal = response.getReturnValue();
                if (respVal.errors.length > 0) {
                    helper.showErrorMessage(component, true, helper.replaceIntoString(helper.errorDuringProcessData, [actionType]));
                    if (actionType === helper.actionOptionUpload) {
                        helper.setOnUploadFail(component, event, helper);
                    }

                     if (respVal.onlyDuplicateErrors) {
                          helper.showErrorMessage(component, false, '');
                          helper.showSuccessMessage(component, true, helper.errorDuplicated);
                          component.set("v.duplicatedDetected", helper.booleanTrueValue);
                     }

                } else {
                    if (actionType === helper.actionOptionValidate) {
                        helper.setOnValidateSuccess(component, event, helper);
                    } else if (actionType === helper.actionOptionUpload) {
                        helper.setOnUploadSuccess(component, event, helper);
                    }
                }
                component.set("v.validationData", response.getReturnValue());

            } else if (state === "INCOMPLETE") {
                helper.showErrorMessage(component, true, helper.errorServer);
            } else if (state === "ERROR") {
                helper.showErrorMessage(component, true, helper.errorServer);
            }

            component.set("v.showLoadingSpinner", false);
        });
        $A.enqueueAction(action);
    },

    setOnUploadSuccess : function(component, event, helper) {
        helper.clearAllComponentData(component, event, helper);
        helper.showSuccessMessage(component, true, helper.successFileUploaded);
    },

    setOnUploadFail : function(component, event, helper) {
        component.set("v.buttonLabel", helper.buttonValidateLabel);
        component.set("v.dataValidated", helper.booleanFalseValue);
    },

    setOnValidateSuccess : function(component, event, helper) {
        helper.showSuccessMessage(component, true, helper.successFileValidated);
        component.set("v.buttonLabel", helper.buttonUploadLabel);
        component.set("v.dataValidated", helper.booleanTrueValue);
    },

    clearAllComponentData :  function(component, event, helper) {
        helper.clearMessages(component, event, helper);
        component.set("v.validationData", null);
        component.set("v.buttonLabel", helper.buttonValidateLabel);
        component.set("v.fileName", "");
        component.set("v.dataValidated", helper.booleanFalseValue);
        component.set("v.duplicatedDetected", helper.booleanFalseValue);
    },

    clearMessages :  function(component, event, helper) {
        helper.showErrorMessage(component, false, "");
        helper.showSuccessMessage(component, false, "");
    },

    showErrorMessage : function(component, show, errorMessage) {
        if (show) {
            component.set("v.errorMessage", errorMessage);
        } else {
            component.set("v.errorMessage", "");
        }
    },

    showSuccessMessage : function(component, show, successMessage) {
        if (show) {
            component.set("v.successMessage", successMessage);
        } else {
            component.set("v.successMessage", "");
        }
    },

    replaceIntoString : function(strg, args) {
          var a = strg;
          for (var k in args) {
            a = a.replace("{" + k + "}", args[k]);
          }
          return a;
    },

    setCsvFileType : function(component, event, helper) {
        debugger;
        component.set("v.csvType", component.find('csvFileType').get("v.value"));
        component.set("v.templateFileId", component.get("v.templateNonLocaleId"));
      /*  if (component.find("csvFileType").get("v.value") == helper.csvFileVersionLocale) {
            component.set("v.templateFileId", component.get("v.templateLocaleId"));
        } else {
            component.set("v.templateFileId", component.get("v.templateNonLocaleId"));
        }*/
    },

    setCsvChangeCheckboxValue : function(component, event, helper) {
       var checkElement = component.find("wasCsvChangeCheckbox");
       component.set("v.wasCsvChangeAfterExport", checkElement.get("v.value"));
    }

})