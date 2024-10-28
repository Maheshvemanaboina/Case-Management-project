/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Invokable class used in the process builder for Quotes to include a price book

History
2019-10-29    Gianluca Calcagni    Created class
------------------------------------------------------------*/
global with sharing class QuoteActionHandler {



    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Implements a method that can be called by any flow
    Inputs:       A list of quote IDs
    Returns:      void
    Test Class:   QuoteActionHandlerTest

    History:
    2019-10-29    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @InvocableMethod(
        label='Quote Price Book update'
    )
    global static void updatePriceBookOnQuote( List<String> quoteIds ) {
        // Check that the input is valid //
        if ( quoteIds != null && !quoteIds.isEmpty() ) {
            // Disable the CPQ triggers //
            SBQQ.TriggerControl.disable();

            // Query the quotes //
            List<SBQQ__Quote__c> quotes = [
                SELECT
                    Id, SBQQ__Account__c, SBQQ__Account__r.Name
                FROM
                    SBQQ__Quote__c
                WHERE
                    Id IN :quoteIds AND
                    SBQQ__Account__r.Name != null
            ];

            // Collect the account names //
            List<String> accountNames = new List<String>();
            for ( SBQQ__Quote__c quote : quotes ) {
                accountNames.add( quote.SBQQ__Account__r.Name );
            }

            // Create a map of the pricebooks based on the account names //
            Map<String, Id> accountNameToPricebookId = new Map<String, Id>();
            for ( PriceBook2 priceBook : [SELECT Id, Name FROM PriceBook2 WHERE Name IN :accountNames AND IsActive = TRUE ORDER BY CreatedDate LIMIT 200] ) {
                accountNameToPricebookId.put( pricebook.Name, pricebook.Id );
            }

            // Create a list of quotes to update //
            List<SBQQ__Quote__c> updateableQuotes = new List<SBQQ__Quote__c>();
 
            // Loop over the quotes //
            for ( SBQQ__Quote__c quote : quotes ) {
                // Find the corresponding pricebook ID //
                Id priceBookId = accountNameToPricebookId.get( quote.SBQQ__Account__r.Name );
                
                // Check that the ID has been found //
                if ( priceBookId != null ) {
                    // Set the pricebook ID //
                    quote.SBQQ__PriceBook__c = priceBookId;
                    
                    // Include the quote in the list //
                    updateableQuotes.add( quote );
                }
            }

            // Update the list of quotes with their pricebook //
            if ( !updateableQuotes.isEmpty() ) {
                Database.update( updateableQuotes, true );
            }
        }
    }



}