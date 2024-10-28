/**
 * Created by KJM on 11/04/2019.
 */

public with sharing class UploadObjectController {
    private static List<UploadObjectFromCSV.ErrorWrapper> uplObjContrValidationErrors = new List<UploadObjectFromCSV.ErrorWrapper>();

    

    @AuraEnabled
    public static ValidatedDataWrapper validateFileData(String base64Data, String objectAPIName, String csvFileType, String csvCreationOption, Boolean wasChangeOnReport) {
        try {
            setLineAndPicklistValueSeparator(csvFileType, csvCreationOption, wasChangeOnReport);

            if (objectAPIName == Constants.ACCOUNT_API_NAME) {
                return accountValidateFileData(getRowsToProcess(base64Data, csvCreationOption, wasChangeOnReport));
            } else if (objectAPIName == Constants.OPPORTUNITY_API_NAME) {
                return opportunityValidateFileData(getRowsToProcess(base64Data, csvCreationOption, wasChangeOnReport));
            }

            return null;
        } catch (Exception ex) {
            System.debug('ME: UploadObjectController.validateFileData ' + ex.getMessage() + ' - ' + ex.getStackTraceString());

            String exMessage = ex.getMessage();
            if (ex.getMessage().containsIgnoreCase('UTF-8')) {
                exMessage = 'System expect file into UTF-8 encoding. Please export Salesforce report with option \'Export File Encoding\' as Unicode (UTF-8) or go to excel and save file as \'CSV UTF-8\'.';
            }
            return new ValidatedDataWrapper(new List<UploadObjectFromCSV.ErrorWrapper>{new UploadObjectFromCSV.ErrorWrapper('EXCEPT', exMessage)}, null);
        }
    }

    @AuraEnabled
    public static ValidatedDataWrapper uploadFileData(String base64Data, String objectAPIName, String uploadOption, String csvFileType, String csvCreationOption, Boolean wasChangeOnReport) {
        Savepoint svPoint = Database.setSavepoint();

        try {
            setLineAndPicklistValueSeparator(csvFileType, csvCreationOption, wasChangeOnReport);

            List<UploadObjectFromCSV.ErrorWrapper> insertErrors = new List<UploadObjectFromCSV.ErrorWrapper>();

            if (objectAPIName == Constants.ACCOUNT_API_NAME) {
                insertErrors.addAll(accountUploadFileData(getRowsToProcess(base64Data, csvCreationOption, wasChangeOnReport), uploadOption));
            } else if (objectAPIName == Constants.OPPORTUNITY_API_NAME) {
                insertErrors.addAll(opportunityUploadFileData(getRowsToProcess(base64Data, csvCreationOption, wasChangeOnReport), uploadOption));
            }

            if (!insertErrors.isEmpty()) {
                Database.rollback(svPoint);
            }

            return new ValidatedDataWrapper(insertErrors, null);
        } catch (Exception ex) {
            Database.rollback(svPoint);
            System.debug('ME: UploadObjectController.uploadFileData ' + ex.getMessage() + ex.getLineNumber() + ' - ' + ex.getStackTraceString());
            return new ValidatedDataWrapper(new List<UploadObjectFromCSV.ErrorWrapper>{new UploadObjectFromCSV.ErrorWrapper('EXCEPT', ex.getMessage())}, null);
        }
    }

    private static ValidatedDataWrapper accountValidateFileData(List<String> rowsToProcess) {
        checkRowDataCountForAccount(rowsToProcess);
        validateAccountSegmentValues(rowsToProcess);
        //validateDistributorField(rowsToProcess);//Deleted 
        validateDistributorLocationField(rowsToProcess);
        validateAccountOwner(rowsToProcess);
        
        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadAccountFromCSV.csvFileObjFieldMap, Account.Distributor_Sales_Manager__c.getDescribe().getName());
        validateDistributorSalesManager(rowsToProcess,customerIndex);

        List<String> rowsToProc = rowsToProcess;
        rowsToProc = addValueToTheEndOfTheEveryLine(rowsToProc, Constants.DEFAULT_ACCOUNT_RECORD_TYPE_FROM_CSV_FILE);
        rowsToProc = addValueToTheEndOfTheEveryLine(rowsToProc, Constants.CSV_VALUE_TRUE);

        UploadAccountFromCSV uploadClass = new UploadAccountFromCSV(rowsToProc);
        List<UploadObjectFromCSV.ErrorWrapper> validationErrors = uploadClass.validateData();
        validationErrors.addAll(uplObjContrValidationErrors);
        List<UploadObjectFromCSV.TableWrapper> tableValues = new List<UploadObjectFromCSV.TableWrapper> {uploadClass.getDataForDisplayToFE()};

        return new ValidatedDataWrapper(validationErrors, tableValues);
    }

    private static ValidatedDataWrapper opportunityValidateFileData(List<String> rowsToProcess) {
        checkRowDataCountForOpportunity(rowsToProcess);
        validateIfAllAccountsAreEndCustomers(rowsToProcess);
        validateOpportunityOwner(rowsToProcess);
        validateSegmentValues(rowsToProcess);

        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.Distributor_Sales_Manager__c.getDescribe().getName());
        validateDistributorSalesManager(rowsToProcess,customerIndex);

      	
        
        List<String> rowsToProc = rowsToProcess;
            //replaceOpportunityStageWithFCIStages(rowsToProcess, true);
        
        rowsToProc = addValueToTheEndOfTheEveryLine(rowsToProc, Constants.DEFAULT_OPPORTUNITY_RECORD_TYPE_FROM_CSV_FILE);

        UploadOpportunityFromCSV uploadClass = new UploadOpportunityFromCSV(rowsToProc);
        List<UploadObjectFromCSV.ErrorWrapper> validationErrors = uploadClass.validateData();
        validationErrors.addAll(uplObjContrValidationErrors);
        List<UploadObjectFromCSV.TableWrapper> tableValues = new List<UploadObjectFromCSV.TableWrapper> {uploadClass.getDataForDisplayToFE()};

        return new ValidatedDataWrapper(validationErrors, tableValues);
    }

    private static List<UploadObjectFromCSV.ErrorWrapper> accountUploadFileData(List<String> rowsToProcess, String uploadOption) {
        List<String> rowsToProc = rowsToProcess;
        rowsToProc = addValueToTheEndOfTheEveryLine(rowsToProc, Constants.DEFAULT_ACCOUNT_RECORD_TYPE_FROM_CSV_FILE);
        rowsToProc = addValueToTheEndOfTheEveryLine(rowsToProc, Constants.CSV_VALUE_TRUE);

        UploadAccountFromCSV uploadClass = new UploadAccountFromCSV(rowsToProc);
        return new List<UploadObjectFromCSV.ErrorWrapper>(uploadClass.upsertData(uploadOption));
    }

    private static List<UploadObjectFromCSV.ErrorWrapper> opportunityUploadFileData(List<String> rowsToProcess, String uploadOption) {
        List<String> rowsToProc = rowsToProcess; //replaceOpportunityStageWithFCIStages(rowsToProcess, false);
        rowsToProc = addValueToTheEndOfTheEveryLine(rowsToProc, Constants.DEFAULT_OPPORTUNITY_RECORD_TYPE_FROM_CSV_FILE);

        UploadOpportunityFromCSV uploadClass = new UploadOpportunityFromCSV(rowsToProc);
        return new List<UploadObjectFromCSV.ErrorWrapper>(uploadClass.upsertData(uploadOption));
    }

    private static List<String> getRowsToProcess(String base64Data, String csvCreationOption, Boolean wasChangeInTheReport) {
        String bodyAsString = EncodingUtil.base64Decode(EncodingUtil.urlDecode(base64Data, Constants.CSV_FILE_CODDING)).toString();
        List<String> bodyByRows = bodyAsString.split(Constants.CSV_ROW_SPLIT);
        bodyByRows.remove(0);
        if (bodyByRows.isEmpty()) {
            throw new UploadObjectControllerException(Label.No_data_detected);
        }

        // remove all rows after empty line - validate if count of the rows is proper
        List<String> filteredRows = new List<String>();
        for (String row : bodyByRows) {
            List<String> lst = row.split(UploadObjectFromCSV.csvLineDelimiter);
            if (lst.isEmpty() || String.isBlank(lst.get(0))) { break; }
            filteredRows.add(row);
        }

        // remove end '"' char from direct from report option
        List<String> rowsToReturn = new List<String>();
        for (String row : filteredRows) {
            String currentRow = row.removeEndIgnoreCase(Constants.QUOTATION_MARK);
            currentRow = currentRow.removeStartIgnoreCase(Constants.QUOTATION_MARK);
            rowsToReturn.add(currentRow);
        }

        // add space char at the end of the line (bacause of empty last value)
        List<String> rowsToReturnWithSpace = new List<String>();
        for (String row : rowsToReturn) {
            String rowWithSpace = row + ' ';
            rowsToReturnWithSpace.add(rowWithSpace);
        }

        return rowsToReturnWithSpace;
    }

    private static void checkRowDataCountForAccount(List<String> rowsToProc) {
        checkRowDataCount(rowsToProc, UploadAccountFromCSV.csvFileObjFieldMap.keySet().size());
    }

    private static void checkRowDataCountForOpportunity(List<String> rowsToProc) {
        checkRowDataCount(rowsToProc, UploadOpportunityFromCSV.csvFileObjFieldMap.keySet().size());
    }

    private static void checkRowDataCount(List<String> rowsToProc, Integer shouldBeSize) {
        for (String row : rowsToProc) {
            Integer rowCount = row.split(UploadObjectFromCSV.csvLineDelimiter).size();
            // wrong split format chosen
            if (rowCount < 4) {
                throw new UploadObjectControllerException(
                        'The system detected the wrong file format. ' +
                                'Please check whether you had chosen proper \'CSV file locale\' and \'Way of file creation\'. ' +
                                'If you are not sure, please change the option and validate again. ' +
                                'If the problem occurs for every option please contact the administrator to validate file structure.');
            }

            // wrong count of column values
            if (rowCount != shouldBeSize) {
                throw new UploadObjectControllerException(
                        'For: ' + row.split(UploadObjectFromCSV.csvLineDelimiter).get(0) + ' the system detect wrong data format. ' +
                                'The System expect ' + shouldBeSize + ' columns, but detect ' + rowCount + ' columns. ' +
                                'Please check if description or any other value of the column do not include char ' + UploadObjectFromCSV.csvLineDelimiter + ' inside. ' +
                                'If yes, please remove or replace char from that field and try again. ' +
                                'If the problem will still occur please contact the administrator to validate file structure.');
            }
        }
    }

    private static List<String> addValueToTheEndOfTheEveryLine(List<String> rows, String defaultRecordType) {
        List<String> rowsToReturn = new List<String>();
        for (String row : rows) {
            rowsToReturn.add(row + UploadObjectFromCSV.csvLineDelimiter + defaultRecordType);
        }

        return rowsToReturn;
    }

   /* private static List<String> replaceOpportunityStageWithFCIStages(List<String> rowsFromCsvFile, Boolean isValidation) {
        Integer stageNameIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.StageName.getDescribe().getName());
        Integer probabilityDecimalIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.Probability.getDescribe().getName());
        String oppStageCompanyName = UserUtility.getCurrentUser().Account.Name;
        if (String.isBlank(oppStageCompanyName)) {
            throw new UploadObjectControllerException(
                    'The System does not detect an Account assigned to your community user. ' +
                    'The System uses related Account name to determine opportunity stage mapping. ' +
                    'If you are internal user, please log in as community user for which you want to upload the file. ' +
                    'If you are a community user, please contact the system administrator.');
        }

        //Map<String, Map<String, Opportunity_Stage_Mapping__mdt>> opportunityStageMappingList = OpportunityUtility.getOppStageMappingMapByProbabilityAndStageName(oppStageCompanyName);
        Map<String, Opportunity_Stage_Mapping__mdt> opportunityStageMappingList = OpportunityUtility.getOppStageMappingMapByProbabilityBrackets();

        List<String> dataRowsToReturn = new List<String>();
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            String stageName = rowValues.get(stageNameIndex);
            String probabilityDecimal = rowValues.get(probabilityDecimalIndex);
            String decimalSplitChar = probabilityDecimal.split(Constants.CSV_DECIMAL_SEPARATOR_FILE).size() > 1 ? Constants.CSV_DECIMAL_SEPARATOR_FILE : Constants.CSV_DECIMAL_SEPARATOR_SYSTEM;
            String probability = probabilityDecimal.split(decimalSplitChar)[0];

            String fCIStageName = OpportunityUtility.getFCIStageNameFromProbabilityBracketMap(opportunityStageMappingList, probability, stageName);
            if (String.isEmpty(fCIStageName)) {
                if (!isValidation) {
                    throw new UploadObjectControllerException(
                            'Error: ' + (String)rowValues.get(0) + ' - Cannot find [Opportunity Stage] mapping for values: Probability: \'' + probability + '\', Stage Name \'' + stageName + '\', Related Account: \'' + oppStageCompanyName + '\'');
                } else {
                    uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - Cannot find [Opportunity Stage] mapping for values: Probability: \'' + probability + '\', Stage Name \'' + stageName + '\', Related Account: \'' + oppStageCompanyName + '\''));
                    fCIStageName = ' ';
                }
            }

            String dataRowToRet = '';
            rowValues.remove(probabilityDecimalIndex);
            for (Integer index : UploadOpportunityFromCSV.csvIndexObjFieldMap.keySet()) {
                if (UploadOpportunityFromCSV.csvIndexObjFieldMap.get(index) == Opportunity.StageName.getDescribe().getName()) {
                    dataRowToRet += fCIStageName + UploadObjectFromCSV.csvLineDelimiter;
                } else if (UploadOpportunityFromCSV.csvIndexObjFieldMap.get(index) != Opportunity.RecordTypeId.getDescribe().getName()){
                    dataRowToRet += rowValues.get(index) + UploadObjectFromCSV.csvLineDelimiter;
                }
            }

            dataRowToRet = dataRowToRet.removeEnd(UploadObjectFromCSV.csvLineDelimiter);
            dataRowsToReturn.add(dataRowToRet);
        }

        return dataRowsToReturn;
    }*/

    private static void setLineAndPicklistValueSeparator(String csvFileType, String csvCreationOption, Boolean wasChangeInTheReport) {
        if (csvFileType == Constants.CSV_FILE_TYPE_LOCALE) {
            UploadObjectFromCSV.csvLineDelimiter = Constants.CSV_FIELD_SEPARATOR;
            UploadObjectFromCSV.csvPicklistDelimiter = Constants.CSV_PICKLIST_SEPARATOR;

            if (csvCreationOption == Constants.CSV_UPLOAD_FILE_CREATION_OPTION_REPORT && !wasChangeInTheReport) {
                UploadObjectFromCSV.csvLineDelimiter = Constants.CSV_FIELD_SEPARATOR_LOCALE_REPORT;
                UploadObjectFromCSV.csvPicklistDelimiter = Constants.CSV_PICKLIST_SEPARATOR;
                UploadObjectFromCSV.csvDateDelimiter = Constants.CSV_DATE_SEPARATOR_SYSTEM;
            }
        }

        if (csvFileType == Constants.CSV_FILE_TYPE_NON_LOCALE) {
            UploadObjectFromCSV.csvLineDelimiter = Constants.CSV_FIELD_SEPARATOR_NON_LOCALE;
            UploadObjectFromCSV.csvPicklistDelimiter = Constants.CSV_PICKLIST_SEPARATOR_NON_LOCALE;

            if (csvCreationOption == Constants.CSV_UPLOAD_FILE_CREATION_OPTION_REPORT && !wasChangeInTheReport) {
                UploadObjectFromCSV.csvLineDelimiter = Constants.CSV_FIELD_SEPARATOR_NON_LOCALE_REPORT;
                UploadObjectFromCSV.csvPicklistDelimiter = Constants.CSV_PICKLIST_SEPARATOR_NON_LOCALE;
                UploadObjectFromCSV.csvDateDelimiter = Constants.CSV_DATE_SEPARATOR_SYSTEM;
            }
        }
    }

    public class ValidatedDataWrapper {
        @AuraEnabled public Boolean onlyDuplicateErrors { get; private set; }
        @AuraEnabled public List<UploadObjectFromCSV.ErrorWrapper> errors { get; private set; }
        @AuraEnabled public List<UploadObjectFromCSV.TableWrapper> tableValues { get; private set; }

        public ValidatedDataWrapper(List<UploadObjectFromCSV.ErrorWrapper> errors, List<UploadObjectFromCSV.TableWrapper> tableValues) {
            this.errors = errors;
            this.tableValues = tableValues;
            this.onlyDuplicateErrors = checkIfOnlyDuplicateErrors();
        }

        private Boolean checkIfOnlyDuplicateErrors() {
            for (UploadObjectFromCSV.ErrorWrapper errWrap : errors) {
                if (errWrap.type != Constants.ERROR_UPLOAD_TYPE_DUPLICATE) {
                    return false;
                }
            }

            return true;
        }
    }

    public class UploadObjectControllerException extends Exception{}


    ////////////////////////////// VALIDATIONS
    private static void validateAccountOwner(List<String> rowsFromCsvFile) {
        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadAccountFromCSV.csvFileObjFieldMap, Account.OwnerId.getDescribe().getName());

        List<String> usrsFromCSV = new List<String>();
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            usrsFromCSV.add((String)rowValues.get(customerIndex));
        }

        //List<User> usrs = (List<User>)DAOUtilityWithoutShar.getSObjects('User', usrsFromCSV);
        List<User> usrs = (List<User>)DAOUtilityWithoutShar.getSObjectsEmailMatch('User', usrsFromCSV);
        Set<String> usersNameFromDB = new Set<String>();
        for (User usr : usrs) {
            //usersNameFromDB.add(usr.Name);
            usersNameFromDB.add(usr.Email);
        }

        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            if (!usersNameFromDB.contains(rowValues.get(customerIndex))) {
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - Cannot find [Email ID] \'' + (String)rowValues.get(customerIndex) + '\''));
            }
        }
    }

    private static void validateOpportunityOwner(List<String> rowsFromCsvFile) {
        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.OwnerId.getDescribe().getName());

        List<String> usrsFromCSV = new List<String>();
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            usrsFromCSV.add((String)rowValues.get(customerIndex));
        }

        //List<User> usrs = (List<User>)DAOUtilityWithoutShar.getSObjects('User', usrsFromCSV);
        List<User> usrs = (List<User>)DAOUtilityWithoutShar.getSObjectsEmailMatch('User', usrsFromCSV);
        Set<String> usersNameFromDB = new Set<String>();
        for (User usr : usrs) {
            //usersNameFromDB.add(usr.Name);
            usersNameFromDB.add(usr.Email);
        }

        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            if (!usersNameFromDB.contains(rowValues.get(customerIndex))) {
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - Cannot find [Email ID] \'' + (String)rowValues.get(customerIndex) + '\''));
            }
        }
    }

    private static void validateDistributorSalesManager(List<String> rowsFromCsvFile, Integer customerIndex) {

        
     
        List<String> contactsFromCSV = new List<String>();
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            contactsFromCSV.add((String)rowValues.get(customerIndex));
        }

        //List<Contact> conts = (List<Contact>)DAOUtilityWithoutShar.getSObjects('Contact', contactsFromCSV);
        List<Contact> conts = (List<Contact>)DAOUtilityWithoutShar.getSObjectsEmailMatch('Contact', contactsFromCSV);
        Set<String> contactsNameFromDB = new Set<String>();
        for (Contact con : conts) {
            //contactsNameFromDB.add(con.Name);
            contactsNameFromDB.add(con.Email);
        }

        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            if (!contactsNameFromDB.contains(rowValues.get(customerIndex)) && String.isNotBlank(rowValues.get(customerIndex))) {
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - Cannot find [Distributor Sales Manager having Email ID] \'' + (String)rowValues.get(customerIndex) + '\''));
            }
        }
    }

   /*  private static void validateDistributorField(List<String> rowsFromCsvFile) {
        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadAccountFromCSV.csvFileObjFieldMap, Account.Distributor__c.getDescribe().getName());

        Set<String> accNamesFromCSV = new Set<String>();
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            accNamesFromCSV.add((String)rowValues.get(customerIndex));
        }

        List<Account> accs = DAOUtilityWithoutShar.getAllAccountsByName(accNamesFromCSV, Constants.ACCOUNT_RECORD_TYPE_COMMERCIAL_CUSTOMER_ID);
        Set<String> accountNamesFromDB = new Set<String>();
        for (Account ac : accs) {
            accountNamesFromDB.add(ac.Name);
        }

        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            if (!accountNamesFromDB.contains(rowValues.get(customerIndex))) {
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - Cannot find [Distributor Account] \'' + (String)rowValues.get(customerIndex) + '\''));
            }
        }
    }*/

    private static void validateDistributorLocationField(List<String> rowsFromCsvFile) {
        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadAccountFromCSV.csvFileObjFieldMap, Account.Distributor_Location__c.getDescribe().getName());

        Set<String> accNamesFromCSV = new Set<String>();
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            accNamesFromCSV.add((String)rowValues.get(customerIndex));
        }

        List<Account> accs = DAOUtilityWithoutShar.getAllAccountsByName(accNamesFromCSV, Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID);
        Set<String> accountNamesFromDB = new Set<String>();
        for (Account ac : accs) {
            accountNamesFromDB.add(ac.Name);
        }

        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            if (!accountNamesFromDB.contains(rowValues.get(customerIndex))) {
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - Cannot find [Distributor Location Account] \'' + (String)rowValues.get(customerIndex) + '\''));
            }
        }
    }

    private static void validateIfAllAccountsAreEndCustomers(List<String> rowsFromCsvFile) {
        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.End_Customer__c.getDescribe().getName());//Customer__c changed to End_Customer__c

        Set<String> accNamesFromCSV = new Set<String>();
        
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            accNamesFromCSV.add((String)rowValues.get(customerIndex));
        }
        List<Account> accs = DAOUtilityWithoutShar.getAllAccountsByName(accNamesFromCSV, Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID);
        
        Set<String> accountNamesFromDB = new Set<String>();
        for (Account ac : accs) {
            accountNamesFromDB.add(String.valueOf(ac.Name).toLowerCase());
        }

        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
           
            if (!accountNamesFromDB.contains(String.valueOf(rowValues.get(customerIndex)).toLowerCase())) {
               
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - Cannot find [End Customer Account] \'' + (String)rowValues.get(customerIndex) + '\''));
            }
            
        }
        
    }
     private static void validateSegmentValues(List<String> rowsFromCsvFile) {
        Integer businessSegmentIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.Business_Segment__c.getDescribe().getName());
        Integer subSegmentIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.Sub_Segment__c.getDescribe().getName());
        Integer applicationIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.Opportunity_Application__c.getDescribe().getName());
         
         for (String dataRow : rowsFromCsvFile) {
             List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);

             if (!UploadObjectFromCSV.businessSegmentMap.containsKey(rowValues.get(businessSegmentIndex))) {
                 
                 if(String.isBlank((String.valueOf(rowValues.get(businessSegmentIndex))))){
                     
                     uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' Business Segment is mandatory to upload account sheet'));
                     
                 }
                 else{
                     
                     uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - The value [\'' + (String)rowValues.get(businessSegmentIndex) + '\'] is not valid. The label does not match with one of the values from template' ));
                     
                 }
             }
                
             else if (!UploadObjectFromCSV.subSegmentMap.containsKey(rowValues.get(subSegmentIndex)) && 
                        String.isNotBlank(String.valueOf(rowValues.get(subSegmentIndex))) ) {
                 uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - The value [\'' + (String)rowValues.get(subSegmentIndex) + '\'] is not valid. The label does not match with one of the values from template or it is not a valid value for the business segment [\'' + (String)rowValues.get(businessSegmentIndex) + '\']'));
             }
             else if (!UploadObjectFromCSV.applicationMap.containsKey(rowValues.get(applicationIndex)) &&
                        String.isNotBlank(String.valueOf(rowValues.get(applicationIndex)))) {
                 uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - The value [\'' + (String)rowValues.get(applicationIndex) + '\'] is not valid. The label does not match with one of the values from template or it is not a valid value for the sub segment [\'' + (String)rowValues.get(subSegmentIndex) + '\']'));
             }
             
        }

        
    }
    
    private static void validateAccountSegmentValues(List<String> rowsFromCsvFile) {
        Integer accBusinessSegmentIndex = UploadCSVUtility.getValueIndex(UploadAccountFromCSV.csvFileObjFieldMap, Account.Business_Segment__c.getDescribe().getName());
        Integer accSubSegmentIndex = UploadCSVUtility.getValueIndex(UploadAccountFromCSV.csvFileObjFieldMap, Account.Sub_Segment__c.getDescribe().getName());
        Integer accApplicationIndex = UploadCSVUtility.getValueIndex(UploadAccountFromCSV.csvFileObjFieldMap, Account.Application__c.getDescribe().getName());
         
        for (String dataRow : rowsFromCsvFile) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            
			
           
            if (!UploadObjectFromCSV.accBusinessSegmentMap.containsKey(rowValues.get(accBusinessSegmentIndex))) {
                
                if(String.isBlank((String.valueOf(rowValues.get(accBusinessSegmentIndex))))){
                    
                    uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' Business Segment is mandatory to upload account sheet'));
                    
                }
                else{
                    uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - The value [\'' + (String)rowValues.get(accBusinessSegmentIndex) + '\'] is not valid. The label does not match with one of the values from template' ));
                    
                }
                
            }
            else if (!UploadObjectFromCSV.accSubSegmentMap.containsKey(rowValues.get(accSubSegmentIndex)) && 
                       String.isNotBlank(String.valueOf(rowValues.get(accSubSegmentIndex))) ) {
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - The value [\'' + (String)rowValues.get(accSubSegmentIndex) + '\'] is not valid. The label does not match with one of the values from template or it is not a valid value for the business segment [\'' + (String)rowValues.get(accBusinessSegmentIndex) + '\']'));
            }
            else if (!UploadObjectFromCSV.accApplicationMap.containsKey(rowValues.get(accApplicationIndex)) &&
                       String.isNotBlank(String.valueOf(rowValues.get(accApplicationIndex)))) {
                uplObjContrValidationErrors.add(new UploadObjectFromCSV.ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + (String)rowValues.get(0) + ' - The value [\'' + (String)rowValues.get(accApplicationIndex) + '\'] is not valid. The label does not match with one of the values from template or it is not a valid value for the sub segment [\'' + (String)rowValues.get(accSubSegmentIndex) + '\']'));
            }
            
       }

        
    }
   
}