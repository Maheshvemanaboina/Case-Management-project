/**
* Author: Paweł Iwanowicz
* Description: Class used as Action for the Flow to help out in searching and filtering LSDs
*/
public with sharing class LSDQueryAction {

    /**
     * Author: Paweł Iwanowicz
     * Description: Invocable method for getting all LSDs for given Quote
     * @param: quoteId - Id of a given quote (in form of a List)
     * @return List of List of LSDs (Invocable Method and Flow limitation)
    */
    @InvocableMethod(label='Get LSDs for given Quote' description='Returns the list of LSDs based on given Quote Id' category='Quote')
    public static List<List<Legal_Sales_Document__c>> getAllLSDs(List<String> quoteId) {

        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Account__c, SBQQ__Opportunity2__r.Business_Segment__c FROM SBQQ__Quote__c WHERE Id = :quoteId[0]];
        List<Legal_Sales_Document__c> lsdsToReturn;
        Set<Legal_Sales_Document__c> lsdsSet = new Set<Legal_Sales_Document__c>();

        lsdsSet.addAll(getLSDsFromAccount(quote));
        lsdsSet.addAll(getLSDsFromOtherRealtedCustomerLocations(quote));
        lsdsToReturn = new List<Legal_Sales_Document__c>(lsdsSet);

        if (lsdsToReturn.isEmpty()) {
            return null;
        }

        return new List<List<Legal_Sales_Document__c>>{lsdsToReturn};
    }

    /**
     * Author: Paweł Iwanowicz
     * Description: returns all filtered LSDs for specific Account
     * @param: quote - given quote
     * @return List of LSDs
    */
    private static List<Legal_Sales_Document__c> getLSDsFromAccount(SBQQ__Quote__c quote) {
        List<Legal_Sales_Document__c> lsdsToReturn = new List<Legal_Sales_Document__c>();

        for (Legal_Sales_Document__c lsd : [SELECT Id, Status_of_LSD__c, Leading_Business_Segment__c,
                                                    Other_Business_Segment__c, Name, Account_Name__c
                                            FROM
                                                    Legal_Sales_Document__c
                                            WHERE
                                                    Account_Name__c = :quote.SBQQ__Account__c
                                                    AND Expiry_Termination_Date_Reached__c=false
                                                    AND Status_of_LSD__c != 'Expired'
                                                    AND (Leading_Business_Segment__c = :quote.SBQQ__Opportunity2__r.Business_Segment__c
                                                    OR Other_Business_Segment__c INCLUDES (:quote.SBQQ__Opportunity2__r.Business_Segment__c))]) {

            lsdsToReturn.add(lsd);
        }
        return lsdsToReturn;
    }

    /**
     * Author: Paweł Iwanowicz
     * Description: returns all filtered LSDs for specific Other_Related_Customer_Location__c junction records
     * @param: quote - given quote
     * @return List of LSDs
    */
    private static List<Legal_Sales_Document__c> getLSDsFromOtherRealtedCustomerLocations(SBQQ__Quote__c quote) {
        Set<Id> lsdIds = new Set<Id>();

        for (Other_Related_Customer_Location__c orcl : [SELECT
                                                                Id, Legal_Sales_Document__r.Status_of_LSD__c,
                                                                Legal_Sales_Document__r.Leading_Business_Segment__c,
                                                                Legal_Sales_Document__r.Id, Legal_Sales_Document__r.Other_Business_Segment__c
                                                        FROM
                                                                Other_Related_Customer_Location__c
                                                        WHERE
                                                                Account_Name__c = :quote.SBQQ__Account__c
                                                                AND Legal_Sales_Document__r.Expiry_Termination_Date_Reached__c=false
                                                                AND Legal_Sales_Document__r.Status_of_LSD__c != 'Expired'
                                                                AND (Legal_Sales_Document__r.Leading_Business_Segment__c = :quote.SBQQ__Opportunity2__r.Business_Segment__c
                                                                OR Legal_Sales_Document__r.Other_Business_Segment__c INCLUDES (:quote.SBQQ__Opportunity2__r.Business_Segment__c))]) {

            lsdIds.add(orcl.Legal_Sales_Document__r.Id);
        }
        return [SELECT Name, Id, Status_of_LSD__c, Leading_Business_Segment__c, Other_Business_Segment__c, Account_Name__c FROM Legal_Sales_Document__c WHERE Id IN :lsdIds];
    }
}