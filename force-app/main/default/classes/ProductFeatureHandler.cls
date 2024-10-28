/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Invocable class to create product features for the given products

History
2019-11-14    Gianluca Calcagni    Created handler class
------------------------------------------------------------*/
global with sharing class ProductFeatureHandler {



    // PROPERTIES //
    @testVisible
    private static Boolean throwException = false;



    // CONSTANTS //

    //public static final String PRODUCT_RULE_NAME                = CPQUtility.PRODUCT_RULE_NAME;
    //public static final String PRODUCT_FEATURE_NAME             = CPQUtility.PRODUCT_FEATURE_NAME;
    //public static final String PRODUCT_FEATURE_CATEGORY         = CPQUtility.PRODUCT_FEATURE_CATEGORY;
    //public static final String PRODUCT_FEATURE_SELECTION_METHOD = CPQUtility.PRODUCT_FEATURE_SELECTION_METHOD;



    // METHODS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  It creates product features (and related configuration rules) for the given products
    Inputs:       none
    Returns:      void
    Test Class:   ProductFeatureHandlerTest

    History:
    2019-11-14    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    @InvocableMethod(
        label='Create CPQ Product Features'
    )
    global static void createProductFeatures( List<Product2> products ) {
        // Find the latest product rule to filter services //
        List<SBQQ__ProductRule__c> productRules = [
            SELECT Id
            FROM SBQQ__ProductRule__c
            WHERE Name = :CPQUtility.PRODUCT_RULE_NAME AND SBQQ__Active__c = TRUE
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        List<Product2> serviceProducts = [SELECT Id, Name, Product_Code__c, ProductCode, Product_Record_Type__c, Family, 
                                          SBQQ__DefaultQuantity__c, SBQQ__PriceEditable__c, SBQQ__ConfigurationType__c FROM Product2 
                                          WHERE Product_Record_Type__c = 'Services' AND Family = 'Services'];

        // Check if any product and any product rule was found //
        if ( !productRules.isEmpty() && products != null && !products.isEmpty() ) {
            // Disable the CPQ triggers //
            CpqDisableTriggers.cpqDisableTriggers();

            // Initalise some lists to insert //
            List<SBQQ__ProductFeature__c>    newFeatures = new List<SBQQ__ProductFeature__c>();
            List<SBQQ__ConfigurationRule__c> newConfigs  = new List<SBQQ__ConfigurationRule__c>();
            List<SBQQ__ProductFeature__c>    servicesList = new List<SBQQ__ProductFeature__c>();
            List<SBQQ__ProductOption__c>     newProductOptions = new List<SBQQ__ProductOption__c>();
            
            integer i = 0;
            // Loop over the product //
            for ( Product2 product : products ) {
                newFeatures.add(new SBQQ__ProductFeature__c(
                    Name                           = CPQUtility.PRODUCT_FEATURE_NAME,
                    SBQQ__MinOptionCount__c        = 0,
                    SBQQ__Category__c              = CPQUtility.PRODUCT_FEATURE_CATEGORY,
                    SBQQ__Number__c                = CPQUtility.PRODUCT_FEATURE_NUMBER,
                    SBQQ__ConfiguredSKU__c         = product.Id,
                    SBQQ__OptionSelectionMethod__c = CPQUtility.PRODUCT_FEATURE_SELECTION_METHOD_CLICK
                ));
            }

            // Insert the product fetures and their dependencies //
            if ( !newFeatures.isEmpty() ) {
                // Attempt some DML transactions //
                SavePoint savedPoint = Database.setSavePoint();
                try {
                    // Insert the new product features //
                    Database.insert( /*records*/newFeatures, /*allOrNone*/true );

                    // Insert some new configuration rules after initialising them //
                    for ( SBQQ__ProductFeature__c newFeature : newFeatures ) {
                        newConfigs.add(new SBQQ__ConfigurationRule__c(
                            SBQQ__Active__c         = true,
                            SBQQ__Product__c        = newFeature.SBQQ__ConfiguredSKU__c,
                            SBQQ__ProductRule__c    = productRules[ 0 ].Id,
                            SBQQ__ProductFeature__c = newFeature.Id
                        ));
                    }
                    Database.insert( /*records*/newConfigs, /*allOrNone*/true );
                    
    /*------------------------------------------------------------
    Author:       Shweta
    Description:  It creates product options for the given products for SCPQ-957 user story.
    History:
    2021-05-12    Shweta    	Extended the logic
    ------------------------------------------------------------*/

                if (!serviceProducts.isEmpty() && !newFeatures.isEmpty()) {
                    for ( SBQQ__ProductFeature__c newFeature : newFeatures ) {
                        for ( Product2 product : serviceProducts){
                           
                            i = i + 10;
                            newProductOptions.add(new SBQQ__ProductOption__c(
                                SBQQ__ConfiguredSKU__c   = newFeature.SBQQ__ConfiguredSKU__c,
                                SBQQ__OptionalSKU__c     = product.Id,
                                SBQQ__Feature__c         = newFeature.Id,
                                SBQQ__Type__c            = 'Component',
                                SBQQ__Number__c          = i,
                                SBQQ__Quantity__c        = product.SBQQ__DefaultQuantity__c
                            
                            ));
                            
                        }
                        i = 0;
                    }
                    
                }
                    Database.insert( /*records*/newProductOptions, /*allOrNone*/true );
                    
                    

                    // In case of testing, throw an exception //
                    if ( throwException ) throw new NullPointerException();
                } catch ( Exception stackedError ) {
                    // Rollback the database //
                    Database.rollback( savedPoint );

                    // Create a list of sObjects to debug //
                    List<SObject> records = new List<SObject>();
                    records.addAll( newFeatures );
                    records.addAll( newConfigs  );
                    records.addAll(newProductOptions);

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
                        Record__c           = JSON.serialize( records ).left( 32768 ),
                        DateTime__c         = System.now()
                    );
                    Database.insert( debugLog, false );
                } finally {
                    // Re-enable the CPQ triggers //
                    CpqEnableTriggers.cpqEnableTriggers();
                }
            }
        }
    }
}