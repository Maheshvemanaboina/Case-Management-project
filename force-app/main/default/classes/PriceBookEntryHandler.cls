/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Invocable class to create price books for the given products

History
2019-11-08    Gianluca Calcagni    Created handler class
------------------------------------------------------------*/
global with sharing class PriceBookEntryHandler {



    // PROPERTIES //
    @testVisible
    private static Boolean throwException = false;



    // CONSTANTS //

    public static final BGI_Salesforce_Settings__c BGI_SETTING = BGI_Salesforce_Settings__c.getInstance();

    public static final Id PRODUCT_PROTOTYPE_RECORD_TYPE_ID = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( DataFactoryTest.PRODUCT_PROTOTYPE_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId();

    public static final List<PriceBook2> PRICE_BOOKS = [
        SELECT Id, Name, IsStandard
        FROM PriceBook2
        WHERE ( IsStandard = TRUE OR Id = :BGI_SETTING.Prototype_Price_Book_Id__c ) AND IsActive = TRUE
        ORDER BY CreatedDate DESC
        LIMIT 2
    ];

    public static final List<CurrencyType> CURRENCY_TYPES = [
        SELECT Id, IsoCode
        FROM CurrencyType
        WHERE IsActive = TRUE
        ORDER BY IsoCode
        LIMIT 200
    ];



    // METHODS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  It creates empty price book entries for the given products
    Inputs:       none
    Returns:      void
    Test Class:   PriceBookEntryHandlerTest

    History:
    2019-11-08    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @InvocableMethod(
        label='Add Products to Pricebooks'
    )
    global static void createPriceBookEntries( List<Product2> products ) {
        // Check that some products are present //
        if ( products != null && !products.isEmpty() ) {
            // Collect the existing price book entries for the given products //
            /*Map<Id, Map<Id, Map<String, PriceBookEntry>>> productToPricebookToCurrencyToEntry = new Map<Id, Map<Id, Map<String, PriceBookEntry>>>();
            for ( PriceBookEntry entry : [
                SELECT Id, CurrencyIsoCode, Product2Id, Pricebook2Id, UnitPrice, IsActive
                FROM PriceBookEntry
                WHERE IsActive = TRUE AND Product2Id IN :products AND PriceBook2Id IN :PRICE_BOOKS
                ORDER BY CreatedDate DESC
                LIMIT 9500
            ] ) {
                if ( !productToPricebookToCurrencyToEntry.containsKey( entry.Product2Id ) ) {
                    productToPricebookToCurrencyToEntry.put(
                        entry.Product2Id,
                        new Map<Id, Map<String, PriceBookEntry>>()
                    );
                }

                Map<Id, Map<String, PriceBookEntry>> pricebookToCurrencyToEntry = productToPricebookToCurrencyToEntry.get( entry.Product2Id );
                if ( !pricebookToCurrencyToEntry.containsKey( entry.PriceBook2Id ) ) {
                    pricebookToCurrencyToEntry.put(
                        entry.PriceBook2Id,
                        new Map<String, PriceBookEntry>()
                    );
                }

                Map<String, PriceBookEntry> currentyToEntry = pricebookToCurrencyToEntry.get( entry.PriceBook2Id );
                currentyToEntry.put(
                    entry.CurrencyIsoCode,
                    entry
                );
            }*/

            // Initalise some lists of new price book entries to insert //
            List<PriceBookEntry> newStdPriceBookEntries = new List<PriceBookEntry>();
            List<PriceBookEntry> newCstPriceBookEntries = new List<PriceBookEntry>();

            // Loop over the product //
            for ( Product2 product : products ) {
                // Loop over the price books //
                for ( PriceBook2 priceBook : PRICE_BOOKS ) {
                    // Find out if the current price book is standard or not //
                    Boolean isStandardPriceBook = priceBook.IsStandard;

                    // Calculate if this product is compatible with this price book //
                    Boolean isCompatible = isStandardPriceBook || product.RecordTypeId == PRODUCT_PROTOTYPE_RECORD_TYPE_ID;

                    // Check if this product shall be handled or not //
                    if ( isCompatible ) {
                        // Loop over the currencies //
                        for ( CurrencyType currencyType : CURRENCY_TYPES ) {
                            // Find if an entry is already existing for this combination of product, price book, and currency //
                            //Map<Id, Map<String, PriceBookEntry>> pricebookToCurrencyToEntry = productToPricebookToCurrencyToEntry.get( product.Id );
                            //Map<String, PriceBookEntry>          currencyToEntry            = pricebookToCurrencyToEntry == null ? null : pricebookToCurrencyToEntry.get( priceBook.Id );
                            //PriceBookEntry                       entry                      = currencyToEntry == null ?            null : currencyToEntry.get( currencyType.IsoCode );

                            // If not already existing, create a mew (empty) price book entry for this combination of product, price book, and currency //
                            //if ( entry == null ) {
                                PriceBookEntry priceBookEntry = new PriceBookEntry(
                                    Product2Id      = product.Id,
                                    PriceBook2Id    = priceBook.Id,
                                    UnitPrice       = 0,
                                    IsActive        = true,
                                    CurrencyIsoCode = currencyType.IsoCode
                                );

                                // Include the new price book entry in the appropriate list //
                                if ( isStandardPriceBook ) {
                                    newStdPriceBookEntries.add( priceBookEntry );
                                } else {
                                    newCstPriceBookEntries.add( priceBookEntry );
                                }
                            //}
                        }
                    }
                }
            }

            // Insert the price book entries //
            if ( !newStdPriceBookEntries.isEmpty() ) {
                // Attempt a DML transaction in a try/catch //
                try {
                    Database.insert( /*records*/newStdPriceBookEntries, /*allOrNone*/true );
                    Database.insert( /*records*/newCstPriceBookEntries, /*allOrNone*/true );
                    if ( throwException ) throw new NullPointerException();
                } catch ( Exception stackedError ) {
                    // Log an error //
                    Boolean  isDmlException = stackedError.getTypeName() == 'System.DmlException' || stackedError.getTypeName() == 'System.EmailException';
                    String   dmlTypeName    = !isDmlException ? null : String.valueOf( stackedError.getDmlType( 0 ) );
                    String   dmlMessage     = !isDmlException ? null : stackedError.getDmlMessage( 0 );
                    String[] dmlFieldNames  = !isDmlException ? null : stackedError.getDmlFieldNames( 0 );
                    String   typeName       = stackedError.getTypeName();
                    String   message        = stackedError.getMessage();
                    DebugLog__c debugLog    = new DebugLog__c(
                        Severity__c         = 'Error',
                        Comments__c         = 'Failed while attempting to create price book entries for some new products',
                        Message__c          = dmlMessage    != null ? dmlMessage.left( 255 ) : null,
                        Cause__c            = message       != null ? message.left( 255 ) : null,
                        TypeName__c         = dmlTypeName   != null ? dmlTypeName.left( 255 ) : typeName != null ? typeName.left( 255 ) : null,
                        Fields__c           = dmlFieldNames != null ? String.valueOf( dmlFieldNames ).left( 32768 ) : null,
                        StackTraceString__c = stackedError.getStackTraceString().left( 32768 ),
                        Record__c           = JSON.serialize( newStdPriceBookEntries ).left( 32768 ),
                        DateTime__c         = System.now()
                    );
                    Database.insert( debugLog, false );
                }
            }
        }
    }



}