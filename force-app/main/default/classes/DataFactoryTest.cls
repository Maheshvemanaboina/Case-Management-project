/*------------------------------------------------------------  
Author:        Author
Company:       Waeg
Description:   Data factory used for unit testing

History
2018-09-06     Gianluca Calcagni    Created class
2021-02-11     Sibananda Bhuyan     Updated Class to change AccountId as per new Account Design (Added method to return customer locations)
------------------------------------------------------------*/
@isTest
public class DataFactoryTest {



    // CONSTANTS //

    public static final String CPQ_STD_USERNAME                                       = 'sample.cpq.user@samplecompany.email.test';
    public static final String ACCOUNT_COMMERCIAL_CUSTOMER_RECORD_TYPE_DEVELOPER_NAME = 'BGI_Commercial_Customer';
    public static final String ACCOUNT_CUSTOMER_LOCATION_RECORD_TYPE_DEVELOPER_NAME   = 'BGI_Customer_Location';
    public static final String CONTACT_RECORD_TYPE_DEVELOPER_NAME                     = 'BGI_Contact';
    public static final String OPPORTUNITY_NEW_BUSINESS_RECORD_TYPE_DEVELOPER_NAME    = 'New_Business';
    public static final String PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME                 = 'BGI_Product_SKU';
    public static final String PRODUCT_PROTOTYPE_RECORD_TYPE_DEVELOPER_NAME           = 'BGI_Prototype_Product';
    public static final String QUOTE_DRAFT_RECORD_TYPE_DEVELOPER_NAME                 = 'Quote';
    public static final String QUOTE_SAP_RECORD_TYPE_DEVELOPER_NAME                   = 'SAP_Quote';
    public static final String QUOTE_PENDING_RECORD_TYPE_DEVELOPER_NAME               = 'Pending_Quote';
    public static final String OPPORTUNITY_FRAMEWORK_RECORD_TYPE_DEVELOPER_NAME       = 'FCI_Framework_Agreement';



    // SINGLETONS //

    private static Map<Schema.DescribeSObjectResult, Map<String, Schema.RecordTypeInfo>> recordTypeByDeveloperName;
    private static PermissionSet[] cpqPermissionSets;



    // SINGLETON GETTERS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns the map of account record types by developer name

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static Map<String, Schema.RecordTypeInfo> getRecordTypeByDeveloperName( Schema.DescribeSObjectResult entity ) {
        // Check if the property has not been initalised yet //
        if ( recordTypeByDeveloperName == null ) {
            // In such a case, initialise the property //
            recordTypeByDeveloperName = new Map<Schema.DescribeSObjectResult, Map<String, Schema.RecordTypeInfo>>();
        }

        // Check if the record types are missing //
        if ( !recordTypeByDeveloperName.containsKey( entity ) ) {
            // In such a case, include the missing record types //
            recordTypeByDeveloperName.put( entity, entity.getRecordTypeInfosByDeveloperName() );
        }

        // Return the record types //
        return recordTypeByDeveloperName.get( entity );
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns the CPQ permission sets

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static PermissionSet[] getCPQpermissions() {
        // Check if the property has not been initalised yet //
        if ( cpqPermissionSets == null ) {
            // In such a case, initialise the property //
            cpqPermissionSets = [SELECT Id FROM PermissionSet WHERE Name IN ('CPQ Sales Manager', 'Salesforce CPQ User') ORDER BY Name];
        }

        // Return the property //
        return cpqPermissionSets;
    }



    // FUNCTIONS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns a CPQ standard user

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static User getCPQstdUser() {
        return new User(
            //RoleId                   = UserInfo.getUserRoleId(),
            Alias                    = 'cpq9',
            DefaultCurrencyIsoCode   = 'EUR', //UserInfo.getDefaultCurrency(),
            LastName                 = 'Sample User',
            Profile                  = new Profile( Name = 'Standard CPQ User Profile' ),
            Email                    = CPQ_STD_USERNAME,
            Username                 = CPQ_STD_USERNAME,
            TimeZoneSidKey           = 'Europe/Amsterdam', //UserInfo.getTimeZone().toString(),
            LocaleSidKey             = 'nl_NL', //UserInfo.getLocale(),
            EmailEncodingKey         = 'ISO-8859-1',
            LanguageLocaleKey        = 'en_US', //UserInfo.getLanguage(),
            IsActive                 = true
        );
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns some commercial customer accounts

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static List<Account> getAccountCommercialCustomers( Integer size ) {
        List<Account> records = new List<Account>();
        for ( Integer index = 0; index < size; ++index ) {
            records.add( new Account(
                Name           = 'Sample Account ' + index,
                RecordTypeId   = getRecordTypeByDeveloperName( Schema.SObjectType.Account ).get( ACCOUNT_COMMERCIAL_CUSTOMER_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId(),
                BillingCountry = 'Netherlands',
                BillingCity    = 'Amsterdam'
            ));
        }
        return records;
    }

    /*------------------------------------------------------------
    Author:       Sibananda
    Company:      KVP
    Description:  Returns some Customer Location accounts

    History:
    2021-02-11    Sibananda Bhuyan    Created method
    ------------------------------------------------------------*/
    public static List<Account> getAccountCustomerLocations( Integer size ) {
        List<Account> records = new List<Account>();
        for ( Integer index = 0; index < size; ++index ) {
            records.add( new Account(
                Name           = 'Sample Customer Location Account ' + index,
                RecordTypeId   = getRecordTypeByDeveloperName( Schema.SObjectType.Account ).get( ACCOUNT_CUSTOMER_LOCATION_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId(),
                BillingCountry = 'Netherlands',
                BillingCity    = 'Amsterdam'
            ));
        }
        return records;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns some contacts

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static List<Contact> getContacts( Integer size ) {
        List<Contact> records = new List<Contact>();
        for ( Integer index = 0; index < size; ++index ) {
            records.add( new Contact(
                LastName       = 'Sample Contact ' + index,
                RecordTypeId   = getRecordTypeByDeveloperName( Schema.SObjectType.Contact ).get( CONTACT_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId(),
                Department__c  = 'Purchase',
                Job_Title__c   = 'Purchaser'
            ));
        }
        return records;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns some new business opportunities

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static List<Opportunity> getOpportunityNewBusinesses( Integer size ) {
        List<Opportunity> records = new List<Opportunity>();
        for ( Integer index = 0; index < size; ++index ) {
            records.add( new Opportunity(
                Name               = 'Sample Opportunity ' + index,
                RecordTypeId       = getRecordTypeByDeveloperName( Schema.SObjectType.Opportunity ).get( OPPORTUNITY_NEW_BUSINESS_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId(),
                CloseDate          = System.today(),
                StageName          = 'Closed Won',
                Reason_Won_Lost__c = 'Strong Relationship'
            ));
        }
        return records;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns some products

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static List<Product2> getProductSKUs( Integer size ) {
        List<Product2> records = new List<Product2>();
        for ( Integer index = 0; index < size; ++index ) {
            records.add( new Product2(
                Name               = 'Sample Product ' + index,
                RecordTypeId       = getRecordTypeByDeveloperName( Schema.SObjectType.Product2 ).get( PRODUCT_SKU_RECORD_TYPE_DEVELOPER_NAME ).getRecordTypeId(),
                ProductCode        = 'Pro-' + index,
                IsActive           = true
            ));
        }
        return records;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns some price book entries

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static List<PricebookEntry> getPriceBookEntries( Product2[] products ) {
        List<PricebookEntry> records = new List<PricebookEntry>();
        for ( Product2 product : products ) {
            records.add( new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id   = product.Id,
                UnitPrice    = 100.00,
                IsActive     = true
            ));
        }
        return records;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Returns some opportunity line items

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static List<OpportunityLineItem> getOpportunityLineItems( Opportunity opportunity, PricebookEntry[] entries ) {
        List<OpportunityLineItem> records = new List<OpportunityLineItem>();
        for ( PricebookEntry entry : entries ) {
            records.add( new OpportunityLineItem(
                OpportunityId    = opportunity.Id,
                Quantity         = 5,
                PricebookEntryId = entry.Id,
                TotalPrice       = 5*entry.UnitPrice
            ));
        }
        return records;
    }

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Creates and returns one quote with one group and some line items

    History:
    2019-09-06    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public static SBQQ__Quote__c createQuote( Opportunity opportunity, Product2[] products ) {
        Sales_Area__c salesArea = new Sales_Area__c(
            /*SALES_ORG__c          = '5953',*/
            Sales_Organization__c = '5953',
            Customer_Name__c = opportunity.AccountId,
            Active__c        = true
        );
        Database.insert( salesArea );
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            OwnerId                 = opportunity.OwnerId,
            SBQQ__Account__c        = opportunity.AccountId,
            SBQQ__Opportunity2__c   = opportunity.Id,
            SBQQ__PriceBook__c      = Test.getStandardPricebookId(),
            SBQQ__Primary__c        = true,
            SBQQ__PrimaryContact__c = opportunity.ContactId,
            Sales_Area__c           = salesArea.Id,
            EffectiveDate__c        = System.today(),
            SBQQ__ExpirationDate__c = System.today().addMonths( 1 ),
            SBQQ__StartDate__c      = System.today().addMonths( 2 ),
            SBQQ__EndDate__c        = System.today().addMonths( 3 )
        );
        Database.insert( quote );
        List<SBQQ__QuoteLineGroup__c> groups = new List<SBQQ__QuoteLineGroup__c>{
            new SBQQ__QuoteLineGroup__c(
                Name                    = 'Test Group 1',
                SBQQ__Quote__c          = quote.Id,
                SBQQ__Account__c        = opportunity.AccountId,
                Ship_To_Customer__c     = opportunity.AccountId,
                Mode_of_Transport__c    = 'Sea',
                IncoTerms__c            = 'CIP',
                IncoTermsDestination__c = 'Amsterdam Schiphol'
            )
        };
        Database.insert( groups );
        List<SBQQ__QuoteLine__c> lines = new List<SBQQ__QuoteLine__c>();
        for ( Product2 product : products ) {
            lines.add( new SBQQ__QuoteLine__c(
                SBQQ__Quote__c     = quote.Id,
                SBQQ__Group__c     = groups[ 0 ].Id,
                SBQQ__Product__c   = product.Id,
                SBQQ__Quantity__c  = 5,
                Unit_of_measure__c = 'KG',
                SBQQ__ListPrice__c = 1,
                ZVA0__c            = -0.17
            ));
        }
        system.debug(' lines : '+ lines);
        map<id,SBQQ__QuoteLine__c> quoteLinemap = new map<id,SBQQ__QuoteLine__c>();
        quoteLinemap.putall(lines);
        Database.insert( quoteLinemap.values());
        //Database.insert( lines );
        //quote.putSObjects( SBQQ__QuoteLineGroup__c.SBQQ__LineItemGroups__r, groups );
        //quote.putSObjects( SBQQ__QuoteLine__c.SBQQ__LineItems__r, lines );
        return quote;
    }

    /*------------------------------------------------------------
   Author:       Michal Kwika
   Company:      Waeg
   Description:  Creates and returns Partner Role

   History:
   2019-09-16    Michal Kwika   Created method
   ------------------------------------------------------------*/
    public static void insertPartnerRole(Id targetAccountId, Id sourceAccountId, String relationName){
        Partner_Role__c p = new Partner_Role__c();
        p.Target_Account__c = targetAccountId;
        p.Source_Account__c = sourceAccountId;
        p.Relation_Name__c = relationName;
        p.Name = targetAccountId + ' ' +  relationName +  ' ' + sourceAccountId;

        Database.insert(p);
    }


}