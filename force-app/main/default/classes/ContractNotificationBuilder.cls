public with sharing class ContractNotificationBuilder {

    public static ContractNotification__e buildNotification(SalesAgreement agreement) {
        ContractNotification__e contractEvent = new ContractNotification__e();
        contractEvent.Account_ID__c = agreement.AccountId;
        contractEvent.CurrencyISOCode__c = agreement.CurrencyIsoCode;
        // We are using PO_Number__c and not PO_Number2__c, because during creation we don't need to do additional queries
        // Later in the process only PO_Number2__c should be used
        contractEvent.PO_Number__c = agreement.PO_Number__c;
        contractEvent.Sales_Agreement_Name__c = agreement.Agreement_Number__c;
        contractEvent.Quote_Name__c = agreement.Quote__r.Name;
        contractEvent.Sales_Area_ID__c = agreement.Sales_Area__c;
        contractEvent.Ship_To_ID__c = agreement.Quote_Line_Group__r.Ship_To_Customer__c;
        contractEvent.Start_Date__c = agreement.Start_Date__c;
        contractEvent.End_Date__c = agreement.EndDate;
        contractEvent.Account_SAP_Number__c = agreement.Account.SAP_Number__c;
        contractEvent.Ship_To_SAP_Number__c = agreement.Quote_Line_Group__r.Ship_To_Customer__r.SAP_Number__c;
        contractEvent.Distribution_Channel__c = agreement.Sales_Area__r.DISTR_CHAN__c;
        contractEvent.Division__c = agreement.Sales_Area__r.DIVISION__c;
        contractEvent.Sales_Org__c = agreement.Sales_Area__r.SALES_ORG__c;
        contractEvent.Sales_Agreement_ID__c = agreement.Id;
        contractEvent.Quotation_Type__c = agreement.Quotation_Type__c;
        contractEvent.Payment_Terms__c = agreement.Payment_Terms__c;
        contractEvent.IncoTerms__c = agreement.IncoTerms__c;
        contractEvent.IncoTerms_Destination__c = agreement.IncoTerms_Destination__c;
        contractEvent.Agent_SAP_Number__c = agreement.Quote_Line_Group__r.Agent_Account__r.SAP_Number__c;

        return contractEvent;
    }
}