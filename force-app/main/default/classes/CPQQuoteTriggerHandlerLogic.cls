/*------------------------------------------------------------  
Author:       João Almeida
Company:      Cognizant
Description:  handles CPQ quote trigger handler logic
Test Class: CPQQuoteTriggerHandlerTest

History
2023-03-23    João Almeida    Created class
2023-04-27    João Almeida    Added new methods for before update handling and after update handling - handle smart approval logic
------------------------------------------------------------*/
public without sharing class CPQQuoteTriggerHandlerLogic {
    Map<Id,SBQQ__Quote__c> oldTriggeredRecords;
    List<SBQQ__Quote__c> newTriggeredRecords;

    public void setOldTriggeredRecords(Map<Id,SBQQ__Quote__c> oldTriggeredRecords) {
        this.oldTriggeredRecords = oldTriggeredRecords;
    }

    public void setNewTriggeredRecords(List<SBQQ__Quote__c> newTriggeredRecords) {
        this.newTriggeredRecords = newTriggeredRecords;
    }

    /**
     * method to handle quote and related records mandatory fields validation
     *
     **/
    public void handleQuoteMandatoryFieldsValidation() {
        List<Schema.FieldSetMember> quoteMandatoryFields = SObjectType.SBQQ__Quote__c.FieldSets.Mandatory_Quote_Fields.getFields();
        Set<String> quoteIds = new Set<String>();

        for (SBQQ__Quote__c quoteRecord : this.newTriggeredRecords) {
            SBQQ__Quote__c oldQuoteRecord = this.oldTriggeredRecords.get(quoteRecord.Id);
            if (oldQuoteRecord.SBQQ__Status__c != quoteRecord.SBQQ__Status__c && oldQuoteRecord.SBQQ__Status__c == 'Draft' && quoteRecord.SBQQ__Status__c != 'Rejected by customer' && quoteRecord.SBQQ__Primary__c) {
                quoteIds.add('\''+ quoteRecord.Id + '\'');
            }
        }

        if (quoteIds.size() > 0) {
            Map<Id,String> quoteLineValidationErrorMap = validateRelatedQuoteMandatoryFields(quoteIds, 'SBQQ__QuoteLine__c', SObjectType.SBQQ__QuoteLine__c.FieldSets.Mandatory_Line_Fields.getFields(), 'Product_Type__c = \'Product SKU\'');
            Map<Id,String> quoteLineGroupValidationErrorMap = validateRelatedQuoteMandatoryFields(quoteIds, 'SBQQ__QuoteLineGroup__c', SObjectType.SBQQ__QuoteLineGroup__c.FieldSets.Mandatory_Line_Group_Fields.getFields(), '');
            String summaryError;
            String quoteError;
            String lineError;
            String lineGroupError;

            for (SBQQ__Quote__c quoteRecord : this.newTriggeredRecords) {
                List<String> invalidFields = validateRecordFieldSetValues(quoteMandatoryFields, quoteRecord);
                if (invalidFields.size() > 0) {
                    quoteError = 'It is mandatory to fill in the fields ' + string.join(invalidFields, ',') + ' on the Quote. Please fill these fields before moving to the next status.';
                } else {
                    quoteError = '';
                }
                lineError = quoteLineValidationErrorMap.get(quoteRecord.Id) == null ? '' : quoteLineValidationErrorMap.get(quoteRecord.Id);
                lineGroupError = quoteLineGroupValidationErrorMap.get(quoteRecord.Id) == null ? '' : quoteLineGroupValidationErrorMap.get(quoteRecord.Id);


                summaryError = String.format('{0}\n{1}\n{2}', new List<String>{
                        quoteError,
                        lineError,
                        lineGroupError
                });

                while (summaryError.startsWith('\n') || summaryError.endsWith('\n')){
                    summaryError = summaryError.removeStart('\n').removeEnd('\n');
                }

                if (!String.isBlank(quoteError) || !String.isBlank(lineError) || !String.isBlank(lineGroupError)){
                    quoteRecord.addError(new DmlException(summaryError));
                }
            }
        }
    }

    /**
     * method to handle quote before update logic
     *
     **/   
    public void handleBeforeUpdateActions() {
        for (SBQQ__Quote__c quoteRecord : this.newTriggeredRecords) {
            if (oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c && quoteRecord.SBQQ__Status__c == 'Draft') {
                quoteRecord.Framework_Agreement_Approved__c = false;
                quoteRecord.Framework_Agreement_Uploaded__c = false;
            }

            if (oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c) {
                this.processSmartApprovedLines(quoteRecord);
                this.processSmartApprovedLineGroups(quoteRecord);
            }

            if (oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c && quoteRecord.SBQQ__Status__c == 'Sent to Customer') {
                quoteRecord.ICF_Approved_Payment_Terms__c = quoteRecord.Payment_Terms__c;
                quoteRecord.ICF_Approved_Contract_End_Date__c = quoteRecord.SBQQ__EndDate__c;
            } 

            if (oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c == 'Commercial Approval' && quoteRecord.SBQQ__Status__c == 'CMO Validation') {
                quoteRecord.Approved_Validity_Count__c = quoteRecord.Current_Validity_Count__c;
            }
        }
    }

    /**
     * method to handle quote after update logic
     *
     **/
    public void handleAfterUpdateActions() {
        CpqDisableTriggers.cpqDisableTriggers();
        for (SBQQ__Quote__c quoteRecord : this.newTriggeredRecords) {
            if (quoteRecord.SBQQ__Status__c != 'Rejected by customer' && quoteRecord.SBQQ__Status__c != 'Accepted by customer' &&
                oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c) {
                this.processSmartApprovedLines(quoteRecord);
                this.processSmartApprovedLineGroups(quoteRecord);
            }
        }
        CpqEnableTriggers.cpqEnableTriggers();
    }

    /**
     * method to process smart approved lines logic
     *
     * @param  quoteRecord  the triggered new record
     **/
    private void processSmartApprovedLines(SBQQ__Quote__c quoteRecord) {
        if (Trigger.isBefore) {
            quoteRecord.Approved_Delta_Price__c = 0;
            quoteRecord.Approved_Delta_Quantity__c = 0;
        }
        Integer approvedLinesCount = 0;
        // apex processes in a bulk of 150 records in each iteration, reducing the heap size on the 'to update' list
        for (List<SBQQ__QuoteLine__c> quoteLinesBulk : [SELECT Id, ICF_Approved_FCA_Price__c, SBQQ__ListPrice__c, ICF_Approved_Quantity__c, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteRecord.Id]) {
            List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
            for (SBQQ__QuoteLine__c quoteLine : quoteLinesBulk) {
                if (Trigger.isBefore && quoteLine.ICF_Approved_FCA_Price__c != quoteLine.SBQQ__ListPrice__c) {
                    quoteRecord.Approved_Delta_Price__c++;
                }
                if (Trigger.isBefore && quoteLine.ICF_Approved_Quantity__c != quoteLine.SBQQ__Quantity__c) {
                    quoteRecord.Approved_Delta_Quantity__c++;
                }
                if (Trigger.isBefore && oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c && quoteRecord.SBQQ__Status__c == 'Sent to Customer') {
                    approvedLinesCount++;
                }
                if (Trigger.isAfter && oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c && quoteRecord.SBQQ__Status__c == 'Sent to Customer') {
                    quoteLine.ICF_Approved_FCA_Price__c = quoteLine.SBQQ__ListPrice__c;
                    quoteLine.ICF_Approved_Quantity__c = quoteLine.SBQQ__Quantity__c;
                    quoteLinesToUpdate.add(quoteLine);
                }
            }
            if (Trigger.isAfter && quoteLinesToUpdate.size() > 0) {
                update quoteLinesToUpdate;
            }
        }
        if (Trigger.isBefore && oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c && quoteRecord.SBQQ__Status__c == 'Sent to Customer') {
            quoteRecord.No_Approved_Quote_Lines__c = approvedLinesCount;
        }
    }

    /**
     * method to process smart approved line groups logic
     *
     * @param  quoteRecord  the triggered new record
     **/
    private void processSmartApprovedLineGroups(SBQQ__Quote__c quoteRecord) {
        if (Trigger.isBefore) {
            quoteRecord.Approved_Incoterms__c = 0;
        }
        // apex processes in a bulk of 150 records in each iteration, reducing the heap size on the 'to update' list
        for (List<SBQQ__QuoteLineGroup__c> quoteLineGroupsBulk : [SELECT Id, ICF_Approved_IncoTerms__c, IncoTerms__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c =:quoteRecord.Id]) {
            List<SBQQ__QuoteLineGroup__c> quoteLineGroupsToUpdate = new List<SBQQ__QuoteLineGroup__c>();
            for (SBQQ__QuoteLineGroup__c quoteLineGroup : quoteLineGroupsBulk) {
                if (Trigger.isBefore && quoteLineGroup.ICF_Approved_IncoTerms__c != quoteLineGroup.IncoTerms__c) {
                    quoteRecord.Approved_Incoterms__c++;
                }
                if (Trigger.isAfter && oldTriggeredRecords.get(quoteRecord.Id).SBQQ__Status__c != quoteRecord.SBQQ__Status__c && quoteRecord.SBQQ__Status__c == 'Sent to Customer') {
                    quoteLineGroup.ICF_Approved_IncoTerms__c = quoteLineGroup.IncoTerms__c;
                    quoteLineGroupsToUpdate.add(quoteLineGroup);
                }
            }
            if (Trigger.isAfter && quoteLineGroupsToUpdate.size() > 0) {
                update quoteLineGroupsToUpdate;
            }
        }
    }

    /**
     * method to evaluate if the related records have mandatory fields filled in
     *
     * @param  quoteIds  the set of quote ids to evaluate related records
     * @param  relatedObjectApiName  the related records object API name
     * @param  fieldSetMembers  the list of fields from a field set
     * @return  a map between quote Id and related record invalid fields message
     **/
    private Map<Id,String> validateRelatedQuoteMandatoryFields(Set<String> quoteIds, String relatedObjectApiName, List<Schema.FieldSetMember> fieldSetMembers, String additionalQueryconditions) {
        Map<Id,String> relatedQuoteRecordValidationErrorMap = new Map<Id,String>();
        List<String> selectableFields = new List<String>();
        if (!fieldSetMembers.isEmpty()) {
            for (Schema.FieldSetMember fsm : fieldSetMembers) {
                selectableFields.add(fsm.getFieldPath());
            }
            if (selectableFields.size() > 0) {
                String relatedObjectLabel = Schema.getGlobalDescribe().get(relatedObjectApiName).getDescribe().getLabel();
                String query = 'Select Id, Name, SBQQ__Quote__c, ' + String.join(selectableFields, ',') + ' FROM ' + relatedObjectApiName + ' WHERE SBQQ__Quote__c IN (' + String.join(new List<String>(quoteIds), ',') + ')' + (String.isNotBlank(additionalQueryconditions) ? ' AND ' + additionalQueryconditions : '');
                for (SObject relatedQuoteRecord : Database.query(query)) {
                    List<String> invalidFields = validateRecordFieldSetValues(fieldSetMembers, relatedQuoteRecord);
                    if (invalidFields.size() > 0) {
                        relatedQuoteRecordValidationErrorMap.put((Id)relatedQuoteRecord.get('SBQQ__Quote__c'), 'It is mandatory to fill in the fields ' + string.join(invalidFields, ',') + ' on the ' + relatedObjectLabel + ' named \'' + relatedQuoteRecord.get('Name') + '\'. Please fill these fields before moving to the next status.');
                    }
                }
            }
        }

        return relatedQuoteRecordValidationErrorMap;
    }

    /**
     * method to evaluate if the field set members have value on the record
     *
     * @param  fieldSetMembers  the list of fields from a field set
     * @param  recordToValidate  the record to evaluate the fields 
     * @return  a list with invalid field labels, empty list if all are valid
     **/
    private List<String> validateRecordFieldSetValues(List<Schema.FieldSetMember> fieldSetMembers, SObject recordToValidate) {
        List<String> invalidFields = new List<String>();

        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            String fieldName  = fsm.getFieldPath();
            String fieldLabel = fsm.getLabel();
            if (String.isBlank(String.valueOf(recordToValidate.get(fieldName)))) {
                invalidFields.add('\'' + fieldLabel + '\'');
            }
        }

        return invalidFields;
    }
}