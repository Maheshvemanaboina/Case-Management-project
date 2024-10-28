/***************************************************************************************************************************************
* @Author : Shweta 
* @Date : 1st Sept 2021
* @Desc : Handler class for ListingAutomationBatch which updates the Listing on daily basis when 
          new listings are inserted from SAP to SF
* @Jira : SCPQ-1068
*History
*Sr No.   Modified By      Modified Date         Ticket  no.        Description
* 1       Shweta           01/09/2021            SCPQ-1068          Activating the Listings that are inserted into Salesforce from SAP
* 2       Shweta           01/09/2021            SCPQ-1130          Deleting the listings whose Valid Until date is in past

******************************************************************************************************************************************/
public with sharing class ListingAutomationBatchHandler {
    
    // PROPERTIES //
    @testVisible
    private static Boolean throwException = false;
    
/******************************************************************************
* Author : Shweta
* Date : 1st Sept 2021
* Description : This method is used to update all the listings that are inserted to the SF from SAP every morning as Active
* Parameters : List of Listing__c
* Return : NA
* *****************************************************************************/
    public static void updateListingsasActive(List<Listing__c> newLists){
        
		List<Listing__c> updateActiveListingList = new List<Listing__c>();
            for(Listing__c lst:newLists)
            {
               DateTime dt= lst.CreatedDate;
               
               if(dt.date() == Date.Today())
               {
                   lst.Active__c = true;
               }  
               updateActiveListingList.add(lst);   
            }
            
            if(updateActiveListingList.size()>0 && !updateActiveListingList.isEmpty())
            {
                try{
                    
                    Database.update(updateActiveListingList);
                    
                    // In case of testing, throw an exception //
                if ( throwException ){ throw new NullPointerException();}
                    
                }
                catch(Exception stackedError){
                    
                    String comment = 'Failed while attempting to update the Listing values';
                    Utilities.generateDebugLogsForErrorHandling(stackedError, updateActiveListingList, comment);
                }
            }
    }    

/******************************************************************************
* Author : Shweta
* Date : 1st Sept 2021
* Description : This method is used to delete the listings whose Valid Until date is in past
* Parameters : List of Listing__c
* Return : NA
* *****************************************************************************/
    public static void deleteListings(List<Listing__c> newLists){ 
           
      List<Listing__c> deleteListingsList = new List<Listing__c>();
           
        for(Listing__c lst:newLists)
            {
                if(lst.Valid_Until__c < Date.Today())
                {
                    deleteListingsList.add(lst);
                }
            }
            if(deleteListingsList.size()>0 && !deleteListingsList.isEmpty())
            {
                try{
                    
                    Database.delete(deleteListingsList);
                    // In case of testing, throw an exception //
                if ( throwException ) {throw new NullPointerException();}
                    
                }
                catch(Exception stackedError){
                    
                    String comment = 'Failed while attempting to delete the Listings';
                    Utilities.generateDebugLogsForErrorHandling(stackedError, deleteListingsList, comment);
                }
            }
    }
}