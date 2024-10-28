/*************************************************************** KJM - 09/04/2019
 Name: UploadObjectFromCSV
 ======================================================
 Purpose: Virtual class used for upload object from csv
 ======================================================
***************************************************************/
public virtual with sharing class UploadObjectFromCSV {
    public static String csvLineDelimiter = Constants.CSV_FIELD_DEFAULT_SEPARATOR;
    public static String csvPicklistDelimiter = Constants.CSV_PICKLIST_DEFAULT_SEPARATOR;
    public static String csvDateDelimiter = Constants.CSV_DATE_SEPARATOR_FILE;

    public String objectName;
    public Set<String> datesToValidate;
    public Set<String> decimalToValidate;
    public Set<String> picklistToValidate;
    public Set<String> stageNameToValidate;
    public Set<String> mandatoryToValidate;
    public Set<String> booleanToValidate;
    public Map<String, Set<String>> fieldValuesToValidate;
    public Map<String, String> fieldsForChangeFromNameToId;
    public Map<Integer, String> csvIndexObjFieldMap;
    public Set<String> exceptionsForDisplayToUser;
    public static Map<Object,String> businessSegmentMap = getPicklistValues( Opportunity.Business_Segment__c.getDescribe().getSObjectField());
    public static Map<Object,String> subSegmentMap = getPicklistValues( Opportunity.Sub_Segment__c.getDescribe().getSObjectField());
    public static Map<Object,String> applicationMap = getPicklistValues( Opportunity.Opportunity_Application__c.getDescribe().getSObjectField());
    public static Map<Object,String> accBusinessSegmentMap = getPicklistValues( Account.Business_Segment__c.getDescribe().getSObjectField());
    public static Map<Object,String> accSubSegmentMap = getPicklistValues( Account.Sub_Segment__c.getDescribe().getSObjectField());
    public static Map<Object,String> accApplicationMap = getPicklistValues( Account.Application__c.getDescribe().getSObjectField());
    

    private List<String> dataToProcess;
    private List<ProcessObjectWrapper> processObjectWrappers;

    private List<ErrorWrapper> validationErrors = new List<ErrorWrapper>();

    /*******************************************************************
    Purpose:
        Constructor class - used for setup data
    ********************************************************************/
    public UploadObjectFromCSV(List<String> dataToProcess) {
        this.dataToProcess = dataToProcess;
        this.objectName = getObjectName();
        this.csvIndexObjFieldMap = getCsvIndexObjFieldMap();
        this.exceptionsForDisplayToUser = getExceptionsForDisplayToUser();
        this.datesToValidate = getDatesToValidate();
        this.decimalToValidate = getDecimalToValidate();
        this.picklistToValidate = getPicklistToValidate();
        this.stageNameToValidate= getStageNameToValidate();
        this.booleanToValidate = getBooleanToValidate();
        this.fieldValuesToValidate = getFieldValuesToValidate();
        this.fieldsForChangeFromNameToId = getFieldsForChangeFromNameToIds();
        this.mandatoryToValidate = getMandatoryToValidate();
        this.processObjectWrappers = getProcessObjectWrappers();
       // this.businessSegmentMap = getBusinessSegmentMap();
       // this.subSegmentMap = getSubSegmentMap();
       // this.applicationMap = getApplicationMap();
        
        
    }

    /*******************************************************************
   Purpose:
       Return sobject API name
   Return:
       objectName
   ********************************************************************/
    public virtual String getObjectName() {
        return '';
    }

    /*******************************************************************
    Purpose:
        Return set of field names which will not be included into table displayed to user
    Return:
        Map<csvIndex, fieldName>
    ********************************************************************/
    public virtual Set<String> getExceptionsForDisplayToUser() {
        return new Set<String>();
    }


    /*******************************************************************
    Purpose:
        Return map with index from csv file and fieldName
    Return:
        Map<csvIndex, fieldName>
    ********************************************************************/
    public virtual Map<Integer, String> getCsvIndexObjFieldMap() {
        return new Map<Integer, String>();
    }

    /*******************************************************************
    Purpose:
        Return all fields to validate - if field can have specified value
    Return:
        Map<fieldName, Set<availableValue>>
    ********************************************************************/
    public virtual Map<String, Set<String>> getFieldValuesToValidate() {
        return new Map<String, Set<String>>();
    }

    /*******************************************************************
    Purpose:
        Return all date fields to validate and proper parse
    Return:
        Map<fieldName>
    ********************************************************************/
    public virtual Set<String> getDatesToValidate() {
        return new Set<String>();
    }
   
    /*******************************************************************
    Purpose:
        Return all date fields to validate and proper parse
    Return:
        Map<fieldName>
    ********************************************************************/
    public virtual Set<String> getStageNameToValidate(){
        return new Set<String>();
    }

    /*******************************************************************
    Purpose:
        Return all decimal fields to validate and proper parse
    Return:
        Map<fieldName>
    ********************************************************************/
    public virtual Set<String> getDecimalToValidate() {
        return new Set<String>();
    }
   
    
     /*******************************************************************
    Purpose:
        Return all picklist fields to validate and proper parse
    Return:
        Map<fieldName>
    ********************************************************************/
    public virtual Set<String> getPicklistToValidate() {
        return new Set<String>();
    }
    

    /*******************************************************************
       Purpose:
           Return all decimal fields to validate and proper parse
       Return:
           Map<fieldName>
       ********************************************************************/
    public virtual Set<String> getBooleanToValidate() {
        return new Set<String>();
    }

    /*******************************************************************
    Purpose:
        Return all fields required later change from Name to object Id - lookup
    Return:
        Map<fieldName, relatedObjectId>
    ********************************************************************/
    public virtual Map<String, String> getFieldsForChangeFromNameToIds() {
        return new Map<String, String>();
    }

    /*******************************************************************
    Purpose:
        Return all fields which needs to be fill in
    ********************************************************************/
    public virtual Set<String> getMandatoryToValidate() {
        return new Set<String>();
    }

    /*******************************************************************
    Purpose:
        Return duplicate object indexes
    Return:
        Set<index>
    ********************************************************************/
    public virtual Set<Integer> getDuplicateObjectIndexes(List<SObject> objsToCheck) {
        return new Set<Integer>();
    }

    /*******************************************************************
    Purpose:
        Return proper first error message part
    Return:
        firstMessagePart
    ********************************************************************/
    public virtual String getFirstPartOfErrorWrapper(ProcessObjectWrapper procObj) {
        return 'Error: ' + procObj.processObj.get(Constants.NAME_FIELD_NAME);
    }

    /*******************************************************************
   Purpose:
       First validation of upload objects:
       - if object is duplicate
       - if mandatory fields are filled
       - if field have allowed values
       - if FCI have lookup field
   ********************************************************************/
    public List<ErrorWrapper> validateData() {
        Map<String, SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		
        for (ProcessObjectWrapper procObj : processObjectWrappers) {

            if (procObj.isDuplicate) {
                validationErrors.add(new ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_DUPLICATE, String.format(Label.Info_object_have_duplicate, new List<String>{getFirstPartOfErrorWrapper(procObj)})));
            }

            for (ObjectFieldWrapper mp : procObj.fieldNameValueMap) {
                String fieldName = mp.fieldName;
                String fieldValue = String.valueOf(mp.fieldValue);

                if (mandatoryToValidate.contains(fieldName) && String.isBlank(fieldValue)) {
                    validationErrors.add(new ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_MANDATORY, getFirstPartOfErrorWrapper(procObj) + ' - Field [' + objectFieldMap.get(fieldName).getDescribe().getLabel() + '] cannot be empty'));
                }

                if (fieldValuesToValidate.containsKey(fieldName)){
                    for (String oneFieldValue : fieldValue.split(Constants.CSV_PICKLIST_SEPARATOR_SYSTEM)) {
                        if (!fieldValuesToValidate.get(fieldName).contains(oneFieldValue.trim())) {
                            validationErrors.add(new ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, getFirstPartOfErrorWrapper(procObj) + ' - Field [' + objectFieldMap.get(fieldName).getDescribe().getLabel() + '] cannot contains value \'' + oneFieldValue + '\''));
                        }
                    }
                }
            }
        }

        return validationErrors;
    }

    /*******************************************************************
   Purpose:
       Insert data with proper action:
       - insert all data from csv
       - insert new records and update duplicates
       - insert only new records without duplicates
   ********************************************************************/
    public List<ErrorWrapper> upsertData(String uploadOption) {
        List<SObject> objsToUpsert;
        if (uploadOption == Constants.CSV_UPSERT_OPTION_INSERT) {
            objsToUpsert = getObjectsToInsertForWithoutError();
        } else if (uploadOption == Constants.CSV_UPSERT_OPTION_WITH_OVERWRITE) {
            objsToUpsert = getObjectsToInsertForOverwrite();
        } else if (uploadOption == Constants.CSV_UPSERT_OPTION_ONLY_NEW) {
            objsToUpsert = getObjectsToInsertForOnlyNew();
        }

        replaceFieldsFromNameToId(processObjectWrappers);

        List<ErrorWrapper> insertionErrors = new List<ErrorWrapper>();
        List<Database.UpsertResult> result = DAOUtilityWithoutShar.dynamicUpsert(objsToUpsert, objectName);
        for (Database.UpsertResult saveRes : result) {
            if (!saveRes.success) {
                for (Database.Error err : saveRes.errors) {
                    insertionErrors.add(new ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_UPSERT, err.getStatusCode() + ' - ' + err.getMessage() + ' - ' + err.getFields()));
                }
            }
        }

        return insertionErrors;
    }

    /*******************************************************************
    Purpose:
        Prepare table wrapper which is used to display object information as table into FE
    ********************************************************************/
    public TableWrapper getDataForDisplayToFE() {
        List<OneTableRowWrapper> oneRowTableWrappers = new List<OneTableRowWrapper>();

        for (ProcessObjectWrapper procObj : processObjectWrappers) {
            List<ObjectFieldWrapper> objectFieldsWrap = new List<ObjectFieldWrapper>();
            for (ObjectFieldWrapper mp : procObj.fieldNameValueMap) {
                if (exceptionsForDisplayToUser.contains(mp.fieldName)) {
                    continue;
                }
                objectFieldsWrap.add(new ObjectFieldWrapper(mp.fieldName, mp.fieldValue));
            }

            oneRowTableWrappers.add(new OneTableRowWrapper(procObj.isDuplicate, objectFieldsWrap));
        }

        return new TableWrapper(objectName, getTableHeaderValues(), oneRowTableWrappers);
    }

    /*******************************************************************
    Purpose:
        Replace lookup fields - from name to id
    ********************************************************************/
    public virtual void replaceFieldsFromNameToId(List<ProcessObjectWrapper> processObjectWrappers) {

        String OWNER_ID_API_NAME = 'OwnerId';
        String DISTRIBUTOR_SALES_MANAGER_API_NAME = 'Distributor_Sales_Manager__c';
        //String DISTRIBUTOR_API_NAME = 'Distributor__c';
        String DISTRIBUTOR_LOCATION_API_NAME = 'Distributor_Location__c';
        String EMAIL_API_NAME = 'Email';
        Map<String, SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for(String fieldName : fieldsForChangeFromNameToId.keySet()) {
           
            List<String> fieldsValues = new List<String>();
            for (ProcessObjectWrapper obj : processObjectWrappers) {
                fieldsValues.add((String)obj.processObj.get(fieldName));
            }

            List<SObject> objsFromDB;
            if(fieldName == OWNER_ID_API_NAME || fieldName == DISTRIBUTOR_SALES_MANAGER_API_NAME){
                objsFromDB = DAOUtilityWithoutShar.getSObjectsEmailMatch(fieldsForChangeFromNameToId.get(fieldName), fieldsValues);
            }//else if(fieldName == DISTRIBUTOR_API_NAME){
                //objsFromDB = DAOUtilityWithoutShar.getH1andH5SObjects(fieldsForChangeFromNameToId.get(fieldName), fieldsValues, Constants.ACCOUNT_RECORD_TYPE_COMMERCIAL_CUSTOMER_ID);
            else if(fieldName == DISTRIBUTOR_LOCATION_API_NAME){
                objsFromDB = DAOUtilityWithoutShar.getH1andH5SObjects(fieldsForChangeFromNameToId.get(fieldName), fieldsValues, Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID);
            }else {
                objsFromDB = DAOUtilityWithoutShar.getSObjects(fieldsForChangeFromNameToId.get(fieldName), fieldsValues);
            }
                
            Map<String, SObject> objByFiledName = new Map<String, SObject>();
            for (SObject obj : objsFromDB) {
                if(objsFromDB.getSObjectType() == User.getSObjectType() || objsFromDB.getSObjectType() == Contact.getSObjectType()){
                    objByFiledName.put((String)obj.get(EMAIL_API_NAME), obj);
                }else if(objsFromDB.getSObjectType() == Account.getSObjectType() && 
                fieldName == Constants.END_CUSTOMER_FIELD_NAME ){
                    objByFiledName.put(String.valueOf(obj.get(Constants.NAME_FIELD_NAME)).toLowerCase(), obj);
                    
                }else {
                    objByFiledName.put((String)obj.get(Constants.NAME_FIELD_NAME), obj);
                }
            }
            
            
            if (fieldName == Constants.RECORD_TYPE_ID_FIELD_NAME) {
                Map<String, RecordTypeInfo> recTypesByName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName();
                for (ProcessObjectWrapper obj : processObjectWrappers) {
                    obj.processObj.put(Constants.RECORD_TYPE_ID_FIELD_NAME, recTypesByName.get((String)obj.processObj.get(Constants.RECORD_TYPE_ID_FIELD_NAME)).getRecordTypeId());
                }
                continue;
            }
            
           
            for (ProcessObjectWrapper obj : processObjectWrappers) {
                
                if(fieldName == Constants.END_CUSTOMER_FIELD_NAME && 
                objByFiledName.containsKey(String.valueOf(obj.processObj.get(fieldName)).toLowerCase())){

                    obj.processObj.put(fieldName, objByFiledName.get(String.valueOf(obj.processObj.get(fieldName)).toLowerCase()).Id);
                } 
                else if(objByFiledName.containsKey((String)obj.processObj.get(fieldName))) {
                    obj.processObj.put(fieldName, objByFiledName.get((String)obj.processObj.get(fieldName)).Id);
                } else {
                    throw new UploadObjectFromCSVException('Error: ' + (String)obj.processObj.get(Constants.NAME_FIELD_NAME) + ' - Cannot find [' + objectFieldMap.get(fieldName).getDescribe().getLabel() + '] \'' +(String)obj.processObj.get(fieldName) + '\' into FCI database.');
                }
            }
        }
    }

    /*******************************************************************
    Purpose:
        Setup process object wrapper - object with all object data to fetch
    ********************************************************************/
    private List<ProcessObjectWrapper> getProcessObjectWrappers() {
       
        List<ProcessObjectWrapper> processObjectWrappers = new List<ProcessObjectWrapper>();
        String businessSegFieldName =  Opportunity.Business_Segment__c.getDescribe().getName();
        String subSegFieldName =  Opportunity.Sub_Segment__c.getDescribe().getName();
        String appplicationFieldName =  Opportunity.Opportunity_Application__c.getDescribe().getName();
        Map<String,Account> oppNameEndCustMap = getOppNameEndCustMap(dataToProcess);
		
        User currUser = [Select ContactId,Contact.AccountId,Contact.Parent_Account__c FROM User WHere ContactId != Null AND Id =: UserInfo.getUserId()];
        for (String oneRow : dataToProcess) {

            List<ObjectFieldWrapper> objectFieldWrappers = new List<ObjectFieldWrapper>();

            List<String> csvOneObjValues = oneRow.split(csvLineDelimiter);
            SObject obj = Schema.getGlobalDescribe().get(objectName).newSObject();
			
            
            for (Integer index : csvIndexObjFieldMap.keySet()) {
                String fieldName = csvIndexObjFieldMap.get(index);
               
                Object fieldValueFormatted = getFieldValue(csvOneObjValues.get(index), fieldName, csvOneObjValues.get(0));
				
                
                obj.put(fieldName, fieldValueFormatted);
                
                
                if(objectName == Constants.OPPORTUNITY_API_NAME && 
                fieldName == Opportunity.Name.getDescribe().getName() && 
                oppNameEndCustMap.containsKey(String.valueOf(fieldValueFormatted)) &&
                oppNameEndCustMap.get(String.valueOf(fieldValueFormatted)) != Null ){

                
               
                    obj.put('AccountId',oppNameEndCustMap.get(String.valueOf(fieldValueFormatted)).Distributor_Location__c); 
                    obj.put('Parent_Account__c',oppNameEndCustMap.get(String.valueOf(fieldValueFormatted)).Distributor__c);
                
               }

                objectFieldWrappers.add(new ObjectFieldWrapper(fieldName, fieldValueFormatted));
              
            }

            if(objectName == Constants.OPPORTUNITY_API_NAME){
                obj.put('StageName','Prospecting');
               
               // obj.put('Distributor_Sales_Manager__c',currUser.ContactId);
                
            }
            if(objectName == Constants.ACCOUNT_API_NAME){
                obj.put('Distributor__c',currUser.Contact.Parent_Account__c);
                
                
            }
            
            processObjectWrappers.add(new ProcessObjectWrapper(false, obj, objectFieldWrappers));
        }

        setDuplicates(processObjectWrappers);

        return processObjectWrappers;
    }
    
    public static Map<Object,String> getPicklistValues(Schema.SObjectField fieldName){
        Map<Object,String> pickListValuesMap = new Map<Object,String>();
        Schema.DescribeFieldResult fldRes = fieldName.getDescribe();
        
        for(Schema.PicklistEntry eachPicklist :  fldRes.getPicklistValues()){
            if(eachPicklist.isActive()){
                pickListValuesMap.put(eachPicklist.getLabel(), eachPicklist.getValue()); 
            }
        }
        return pickListValuesMap;
    }
    private Map<String,Account> getOppNameEndCustMap(List<String> dataToProcess) {
        Integer customerIndex = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.End_Customer__c.getDescribe().getName());//Customer__c changed to End_Customer__c
        Integer customerIndexOppName = UploadCSVUtility.getValueIndex(UploadOpportunityFromCSV.csvFileObjFieldMap, Opportunity.Name.getDescribe().getName());

        Map<String,Account> endCustNameEndCustMap =  new Map<String,Account>();
        Map<String,Account> oppNameEndCustMap =  new Map<String,Account>();

        Set<String> accNamesFromCSV = new Set<String>();
        
        for (String dataRow : dataToProcess) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);
            accNamesFromCSV.add((String)rowValues.get(customerIndex));
        }
        List<Account> accs = DAOUtilityWithoutShar.getAllAccountsByName(accNamesFromCSV, Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID);
        for (Account ac : accs) {
            
            endCustNameEndCustMap.put(String.valueOf(ac.Name).toLowerCase(),ac);
        }
        for (String dataRow : dataToProcess) {
            List<String> rowValues = dataRow.split(UploadObjectFromCSV.csvLineDelimiter);

            oppNameEndCustMap.put((String)rowValues.get(customerIndexOppName),endCustNameEndCustMap.get(String.valueOf(rowValues.get(customerIndex)).toLowerCase()) );
        }
        system.debug('oppNameEndCustMap'+oppNameEndCustMap);
        return oppNameEndCustMap;
    }
    /*******************************************************************
    Purpose:
        Set duplicate flag into process object wrapper
    ********************************************************************/
    private void setDuplicates(List<ProcessObjectWrapper> processObjectWrappers) {
        List<SObject> objs = new List<SObject>();
        for (ProcessObjectWrapper procObj : processObjectWrappers) {
            objs.add(procObj.processObj);
        }

        Set<Integer> duplicatesIndexes = getDuplicateObjectIndexes(objs);
        for (Integer i = 0; i < processObjectWrappers.size(); i++) {
            if (duplicatesIndexes.contains(i)) {
                processObjectWrappers.get(i).isDuplicate = true;
            }
        }
    }

    /*******************************************************************
    Purpose:
        Parse date and decimal field
    ********************************************************************/
    private Object getFieldValue(String fieldValue, String fieldName, String objName) {
       
        if (datesToValidate.contains(fieldName)) {
            return validateAndFormatDateFromString(fieldValue, objName);
        } else if (decimalToValidate.contains(fieldName)) {
            return Decimal.valueOf(fieldValue.replace(Constants.CSV_DECIMAL_SEPARATOR_FILE , Constants.CSV_DECIMAL_SEPARATOR_SYSTEM));
        } else if (booleanToValidate.contains(fieldName)) {
            return Boolean.valueOf(fieldValue);
        } else if (picklistToValidate.contains(fieldName)){
            if(objName == Constants.ACCOUNT_API_NAME){
                if(accBusinessSegmentMap.containsKey(fieldValue)) return accBusinessSegmentMap.get(String.valueOf(fieldValue));
                if(accSubSegmentMap.containsKey(fieldValue)) return accSubSegmentMap.get(String.valueOf(fieldValue));
                if(accApplicationMap.containsKey(fieldValue)) return accApplicationMap.get(String.valueOf(fieldValue));
            }else{
                if(businessSegmentMap.containsKey(fieldValue)) return businessSegmentMap.get(String.valueOf(fieldValue));
                if(subSegmentMap.containsKey(fieldValue)) return subSegmentMap.get(String.valueOf(fieldValue));
                if(applicationMap.containsKey(fieldValue)) return applicationMap.get(String.valueOf(fieldValue));
            }
            
            
        }

        return fieldValue.replace(csvPicklistDelimiter, Constants.CSV_PICKLIST_SEPARATOR_SYSTEM);
    }

    /*******************************************************************
    Purpose:
        Return all objects from process object wrapper
    ********************************************************************/
    private List<SObject> getObjectsToInsertForWithoutError() {
        List<SObject> objsToUpsert = new List<SObject>();
        for (ProcessObjectWrapper obj : processObjectWrappers) {
            objsToUpsert.add(obj.processObj);
        }
        return objsToUpsert;
    }

    /*******************************************************************
    Purpose:
        Return all objects for insert and update
    ********************************************************************/
    private List<SObject> getObjectsToInsertForOverwrite() {
        addExistingObjIdForOverwrite(processObjectWrappers);

        List<SObject> objsToUpsert = new List<SObject>();
        for (ProcessObjectWrapper obj : processObjectWrappers) {
            objsToUpsert.add(obj.processObj);
        }
        return objsToUpsert;
    }

    /*******************************************************************
    Purpose:
        Return all objects without duplicates
    ********************************************************************/
    private List<SObject> getObjectsToInsertForOnlyNew() {
        List<SObject> objsToUpsert = new List<SObject>();

        for (ProcessObjectWrapper obj : processObjectWrappers) {
            if (!obj.isDuplicate) {
                objsToUpsert.add(obj.processObj);
            }
        }

        return objsToUpsert;
    }

    /*******************************************************************
    Purpose:
        Get table header values to display on FE
    ********************************************************************/
    private List<String> getTableHeaderValues() {
        List<String> tableHeaderValues = new List<String>();

        Map<String, SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for (String val : csvIndexObjFieldMap.values()) {
            if (exceptionsForDisplayToUser.contains(val)) {
                continue;
            }
            tableHeaderValues.add(objectFieldMap.get(val).getDescribe().getLabel());
        }

        return tableHeaderValues;
    }

    /*******************************************************************
    Purpose:
        Add object Id - required for update
    ********************************************************************/
    public virtual void addExistingObjIdForOverwrite(List<ProcessObjectWrapper> processObjectWrappers) {
        List<String> fieldsValues = new List<String>();
        for (ProcessObjectWrapper obj : processObjectWrappers) {
            fieldsValues.add((String)obj.processObj.get(Constants.NAME_FIELD_NAME));
        }

        List<SObject> objsFromDB = DAOUtilityWithoutShar.getSObjects(objectName, fieldsValues); 

        Map<String, SObject> objByFiledName = new Map<String, SObject>();
        for (SObject obj : objsFromDB) {
            objByFiledName.put((String)obj.get(Constants.NAME_FIELD_NAME), obj);
        }

        for (ProcessObjectWrapper obj : processObjectWrappers) {
            if (objByFiledName.containsKey((String) obj.processObj.get(Constants.NAME_FIELD_NAME))) {
                obj.processObj.put(Constants.ID_FIELD_NAME, objByFiledName.get((String) obj.processObj.get(Constants.NAME_FIELD_NAME)).Id);
            }
        }
    }

    /*******************************************************************
   Purpose:
       Validate and return proper date format
   ********************************************************************/
    private Date validateAndFormatDateFromString(String dateStrValue, String objName) {
        String[] dateSplited = dateStrValue.split(csvDateDelimiter);
        if (!dateValid(dateStrValue)) {
            validationErrors.add(new ErrorWrapper(Constants.ERROR_UPLOAD_TYPE_VALUE, 'Error: ' + objName + ' - Date format is not correct \'' + dateStrValue + '\'' + ' , please use date format dd/mm/yyyy'));
            return null;
        }
        return Date.valueOf(dateSplited[2] + Constants.CSV_DATE_SEPARATOR_SYSTEM + dateSplited[1] + Constants.CSV_DATE_SEPARATOR_SYSTEM + dateSplited[0]);
    }

    /*******************************************************************
    Purpose:
        Validate date value
    ********************************************************************/
    private Boolean dateValid(String dateValue) {
        
        String[] dateSplited = dateValue.split(csvDateDelimiter);
        
        if (dateSplited.size() != 3) {
            return false;
        }

        String day = dateSplited[0];
        String month = dateSplited[1];
        String year = dateSplited[2];
        if (    year.length() != 4 || Integer.valueOf(year) > 2100 || Integer.valueOf(year) < 1900 ||
                month.length() != 2 || Integer.valueOf(month) > 12 || Integer.valueOf(month) < 1 ||
                day.length() != 2 || Integer.valueOf(day) > 31 || Integer.valueOf(day) < 1) {
            return false;
        }

        return true;
    }

    /*******************************************************************
    Purpose:
        Store error information
    ********************************************************************/
    public class ErrorWrapper {
        @AuraEnabled public String type { get; private set; }
        @AuraEnabled public String message { get; private set; }

        public ErrorWrapper(String type, String message) {
            this.type = type;
            this.message = message;
        }
    }

    /*******************************************************************
    Purpose:
        Store information about table display on FE
    ********************************************************************/
    public class TableWrapper {
        @AuraEnabled public String objectName { get; set; }
        @AuraEnabled public List<String> headerValues { get; private set; }
        @AuraEnabled public List<OneTableRowWrapper> bodyValues { get; private set; }

        public TableWrapper(String objectName, List<String> headerValues, List<OneTableRowWrapper> bodyValues) {
            this.objectName = objectName;
            this.headerValues = headerValues;
            this.bodyValues = bodyValues;
        }
    }

    /*******************************************************************
    Purpose:
        Store information about one table row
    ********************************************************************/
    public class OneTableRowWrapper {
        @AuraEnabled public Boolean isDuplicate { get; private set; }
        @AuraEnabled public List<ObjectFieldWrapper> fieldValues { get; private set; }

        public OneTableRowWrapper(Boolean isDuplicate, List<ObjectFieldWrapper> fieldValues) {
            this.isDuplicate = isDuplicate;
            this.fieldValues = fieldValues;
        }
    }

    /*******************************************************************
    Purpose:
        Store information about one field
    ********************************************************************/
    public class ObjectFieldWrapper {
        @AuraEnabled public String fieldName { get; private set; }
        @AuraEnabled public Object fieldValue { get; private set; }

        public ObjectFieldWrapper(String fieldName, Object fieldvalue) {
            this.fieldName = fieldName;
            this.fieldValue = fieldValue;
        }
    }

    /*******************************************************************
    Purpose:
        Store information about one object to fetch
    ********************************************************************/
    public class ProcessObjectWrapper {
        public Boolean isDuplicate { get; set; }
        public SObject processObj { get; set; }
        public List<ObjectFieldWrapper> fieldNameValueMap { get; set; }

        public ProcessObjectWrapper(Boolean isDuplicate, SObject processObj, List<ObjectFieldWrapper> fieldNameValueMap) {
            this.isDuplicate = isDuplicate;
            this.processObj = processObj;
            this.fieldNameValueMap = fieldNameValueMap;
        }
    }

    /*******************************************************************
    Purpose:
       Exception class
    ********************************************************************/
    public class UploadObjectFromCSVException extends Exception{}
}