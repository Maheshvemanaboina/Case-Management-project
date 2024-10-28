/*------------------------------------------------------------  
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Used to contain helper methods and functions for the apex class QuotationWebServiceClass

History
2019-08-29    Gianluca Calcagni    Created helper
------------------------------------------------------------*/
public without sharing class QuotationWebServiceHelper {



    // SINGLETONS //

     // Used to collect the IDs that have already been submitted via web-service //
    private static Set<Id> submittedIds;



    // GETTERS //

    public static Set<Id> getSubmittedIds() {
        // Check if the singleton has not been instantiated yet //
        if ( submittedIds == null ) {
            // Instantiate the singleton //
            submittedIds = new Set<Id>();
        }
        
        // Return the singleton //
        return submittedIds;
    }



}