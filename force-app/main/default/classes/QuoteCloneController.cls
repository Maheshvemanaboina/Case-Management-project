public class QuoteCloneController {

    private static Boolean isAmendmentType = false;
    public static String reasonForAmendment = '';

    public static List<Id> amendmentQuote(List<String> ids) {
        isAmendmentType = true;
        return deepClone(ids);
    }
    @InvocableMethod(Label='Clone Quote')
    public static List<Id> deepClone(List<String> stringOfIds) {
        String quoteId = '';
        String opportunityId = '';
        List<SBQQ__Quote__c> clonedQuote = new List<SBQQ__Quote__c>();
        List<SBQQ__QuoteLine__c> clonedQuoteLineItem = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLineGroup__c> clonedQuoteLineGroup = new List<SBQQ__QuoteLineGroup__c>();
        Map<String, String> mapOf_QLG = new Map<String, String>();
        List<Id> newQuoteId = new List<Id>();

        //Separate stringOfIds into Opportunity Id and Quote Id
        List<String> listOfIds = stringOfIds[0].split(',');
        for (Id recordId : listOfIds) {
            if (recordId.getSobjectType().getDescribe().getName() == 'Opportunity') {
                opportunityId = recordId;
            } else {
                quoteId = recordId;
            }
        }
        //Quote Cloning starts here
        //Create dynamic query with all fields of Quote
        String quoteQuery = '';
        String quoteFieldString = '';
        Map<String, Schema.SObjectField> quoteFieldMap = Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().fields.getMap();
        for (String fieldName : quoteFieldMap.keySet()) {
            if (quoteFieldString == null || quoteFieldString == '') {
                quoteFieldString = fieldName;
            } else {
                quoteFieldString = quoteFieldString + ' , ' + fieldName;
            }
        }
        quoteFieldString = quoteFieldString +',SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingCountry, SBQQ__Account__r.Name, ' +
                'SBQQ__Account__r.BillingPostalCode, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingStreet, CMO__r.IsActive';
        quoteQuery = 'SELECT ' + quoteFieldString + ' FROM SBQQ__Quote__c WHERE Id =:quoteId';
        SBQQ__Quote__c existingQuote = Database.query(quoteQuery);
        //Create new Quote
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        Opportunity opptyObj;
        newQuote = existingQuote.clone(false, false, false, false);
        if (String.isNotBlank(opportunityId)) {
            newQuote.SBQQ__Opportunity2__c = opportunityId;
            opptyObj = new Opportunity();
            opptyObj = [SELECT Id,Name FROM Opportunity WHERE Id=:opportunityId];
        }

        if (isAmendmentType) {
            newQuote.SBQQ__Type__c = 'Amendment';
        } else {
            newQuote.SBQQ__Type__c = 'Quote';
        }

        //Clear and pre populate fields on the new quote
        if (String.isNotBlank(opportunityId)) {
            newQuote.Quote_Name__c = opptyObj.Name;
        }
        if (existingQuote.CMO__r.IsActive) {
            newQuote.CMO__c = existingQuote.CMO__c;
        } else {
            newQuote.CMO__c = null;
        }
        if (!isAmendmentType) {
            newQuote.SBQQ__StartDate__c = Date.today();
            newQuote.SBQQ__EndDate__c = Date.today().addMonths(2);
            newQuote.Current_Floor_Price_Count__c =0;
            newQuote.Current_Walkaway_Price_Count__c = 0;
            newQuote.Approved_Floor_Price_Count__c = 0;
            newQuote.Approved_Walkaway_Price_Count__c = 0;
            newQuote.Approved_Contract_Duration__c =0;
            newQuote.SBQQ__BillingCity__c= newQuote.SBQQ__Account__r.BillingCity;
            newQuote.SBQQ__BillingCountry__c= newQuote.SBQQ__Account__r.BillingCountry;
            newQuote.SBQQ__BillingName__c= newQuote.SBQQ__Account__r.Name;
            newQuote.SBQQ__BillingPostalCode__c= newQuote.SBQQ__Account__r.BillingPostalCode;
            newQuote.SBQQ__BillingState__c= newQuote.SBQQ__Account__r.BillingState;
            newQuote.SBQQ__BillingStreet__c= newQuote.SBQQ__Account__r.BillingStreet;
            newQuote.OwnerId = UserInfo.getUserId();
            newQuote.SBQQ__SalesRep__c = UserInfo.getUserId();
            newQuote.Pricing_Model__c = 'Commercial Manual';
        }
        newQuote.SBQQ__Primary__c = true;
        newQuote.SBQQ__Source__c = existingQuote.Id;
        newQuote.ApprovalStatus__c = '';
        newQuote.Approved_Date__c = null;
        newQuote.Approval_Submitted_Date__c = null;
        newQuote.Approved_Delta_Price__c = null;
        newQuote.Approved_Delta_Quantity__c = null;
        newQuote.Approved_Incoterms__c = null;
        newQuote.Commercial_Approval__c = false;
        newQuote.SBQQ__Notes__c = '';
        newQuote.Commercial_Approval_Comment__c = '';
        newQuote.Details_Reason_Won_Lost__c = '';
        newQuote.EffectiveDate__c = Date.today();
        newQuote.Framework_Agreement_Approved__c = false;
        newQuote.Framework_Agreement_Uploaded__c = false;
        newQuote.ICF_Approval_Comment__c = '';
        newQuote.ICF_Approved_Payment_Terms__c = '';
        newQuote.ICF_Approved_Contract_End_Date__c = null;
        newQuote.ICF_Smart_Approved__c = false;
        newQuote.SBQQ__ExpirationDate__c = Date.today().addDays(30);
        newQuote.Reason_Opportunity_Won_Loss__c = '';
        newQuote.SBQQ__Status__c = 'Draft';
        newQuote.Status_Change_Date__c = null;
        newQuote.SubmittedDate__c = null;
        newQuote.CMO_Validation_Completed__c = false;
        newQuote.Sync_To_Agreement__c = null;
        newQuote.Sync_Agreement_Status__c = null;
        newQuote.Approval_Comment__c = null;
        newQuote.No_Approved_Quote_Lines__c = null;
        newQuote.Summary_Delta_Price__c = null;
        newQuote.Summary_Delta_Quantity__c = null;
        newQuote.Summary_Incoterms__c = null;
        newQuote.Reason_for_Amendment__c = reasonForAmendment;

        clonedQuote.add(newQuote);
        insert clonedQuote;
        newQuoteId.add(newQuote.Id);
        system.debug('###SP Is_New_Amendment_Quote__c should be TRUE'+clonedQuote);

        //Quote Line Group Cloning starts here
        //Create dynamic query with all fields of Quote Line Group
        String quoteLineGroupQuery = '';
        Map<String, Schema.SObjectField> quoteLineGroupFieldMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLineGroup__c').getDescribe().fields.getMap();
        String quoteLineGroupFieldString = '';
        for (String fieldName : quoteLineGroupFieldMap.keySet()) {
            if (quoteLineGroupFieldString == null || quoteLineGroupFieldString == '') {
                quoteLineGroupFieldString = fieldName;
            } else {
                quoteLineGroupFieldString = quoteLineGroupFieldString + ' , ' + fieldName;
            }
        }
        quoteLineGroupQuery = 'SELECT ' + quoteLineGroupFieldString + ' FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c =:quoteId';
        //Create new Quote Line Group
        for (SBQQ__QuoteLineGroup__c qlg : Database.query(quoteLineGroupQuery)) {
            SBQQ__QuoteLineGroup__c newQuoteLineGroup = qlg.clone(false, true, false, false);
            newQuoteLineGroup.SBQQ__Quote__c = newQuote.Id;
            newQuoteLineGroup.SBQQ__Source__c = qlg.Id;
            newQuoteLineGroup.Sync_To_Agreement__c = null;
            mapOf_QLG.put(qlg.Name, qlg.Id);
            if (!isAmendmentType) {
                newQuoteLineGroup.SBQQ__StartDate__c = newQuote.SBQQ__StartDate__c;
                newQuoteLineGroup.SBQQ__EndDate__c = newQuote.SBQQ__EndDate__c;
                newQuoteLineGroup.Override_Freight__c = false;
                newQuoteLineGroup.Override_Incoterms__c = false;
                newQuoteLineGroup.IncoTermsDestination__c = null;
                newQuoteLineGroup.SAP_Contract_Number__c='';
            }
            else {
                newQuoteLineGroup.Override_Freight__c=true;
            }
            clonedQuoteLineGroup.add(newQuoteLineGroup);
        }
        insert clonedQuoteLineGroup;
        // Map is used to Link new Quote Line Group to new Quote line
        for (SBQQ__QuoteLineGroup__c newQLG : clonedQuoteLineGroup) {
            mapOf_QLG.put(mapOf_QLG.get(newQLG.Name), newQLG.Id);
        }
        //Quote Line Cloning starts here
        Map<String, Schema.SObjectField> quoteLineFieldMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        String quoteLineFieldString = '';
        for (String fieldName : quoteLineFieldMap.keySet()) {
            if (quoteLineFieldString == null || quoteLineFieldString == '') {
                quoteLineFieldString = fieldName;
            } else {
                quoteLineFieldString = quoteLineFieldString + ' , ' + fieldName;
            }
        }
        quoteLineGroupQuery = 'SELECT ' + quoteLineFieldString + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:quoteId';
        for (SBQQ__QuoteLine__c qli : Database.query(quoteLineGroupQuery)) {
            SBQQ__QuoteLine__c newQuoteLineItem = qli.clone(false, true, false, false);
            newQuoteLineItem.SBQQ__Quote__c = newQuote.Id;
            newQuoteLineItem.SBQQ__Group__c = mapOf_QLG.get(qli.SBQQ__Group__c);
            newQuoteLineItem.SBQQ__Source__c = qli.Id;
            newQuoteLineItem.Sync_To_Agreement__c = null;
            newQuoteLineItem.Rejected__c = false;
            newQuoteLineItem.Rejection_Reason__c = null;

            if (!isAmendmentType) {
                newQuoteLineItem.Override_Freight__c = false;
                newQuoteLineItem.Floor_Price_Count__c = 0;
                newQuoteLineItem.Walkaway_Price_Count__c = 0;
            }
            clonedQuoteLineItem.add(newQuoteLineItem);
        }
        insert clonedQuoteLineItem;

        setNewClonedQuoteLineRequiredBy(clonedQuoteLineItem);

        return newQuoteId;
    }

    private static void setNewClonedQuoteLineRequiredBy(List<SBQQ__QuoteLine__c> clonedQuoteLineItem) {
        List<SBQQ__QuoteLine__c> clonedQuoteLineItemsToUpdate = new List<SBQQ__QuoteLine__c>();
        Map<Id,Id> mapOldQliToClonedQli = new Map<Id,Id>();
        // String clonedQuoteLinesQuery = 'SELECT ' + quoteLineFieldString + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =:newQuoteId';
        for (SBQQ__QuoteLine__c clonedQli : clonedQuoteLineItem) {
            mapOldQliToClonedQli.put(clonedQli.SBQQ__Source__c, clonedQli.Id);
            if (String.isNotBlank(clonedQli.SBQQ__RequiredBy__c)) {
                clonedQuoteLineItemsToUpdate.add(clonedQli);
            }
        }
        for (SBQQ__QuoteLine__c clonedQli : clonedQuoteLineItemsToUpdate) {
            if (String.isNotBlank(clonedQli.SBQQ__RequiredBy__c)) {
                clonedQli.SBQQ__RequiredBy__c = mapOldQliToClonedQli.get(clonedQli.SBQQ__RequiredBy__c);
            }
        }
        update clonedQuoteLineItemsToUpdate;
    }
}