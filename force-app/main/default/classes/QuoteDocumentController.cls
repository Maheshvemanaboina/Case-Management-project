/*------------------------------------------------------------
Author:       Gianluca Calcagni
Company:      Waeg
Description:  Controller class for the VF page QuoteDocumentView

History
2019-11-05    Gianluca Calcagni    Created controller class
2020-02-27    Gianluca Calcagni    Edited class as per Jira bug SCPQ-794
2022-12-06    João Almeida         Added SBQQ__NetPrice__c and SBQQ__NetTotal__c to the quote line and quote line group query respectively
------------------------------------------------------------*/
public with sharing class QuoteDocumentController {



    // CONSTANTS //

    public final static Integer  MAX_SIZE              = 250;
    public final static String   QUOTE_ID_URL_PARAM    = 'qid';
    public final static String   FORMAT_NAME           = 'Default';
    public final static String   PRODUCT_MATERIAL_TYPE = 'SKU';
    //public final static List<Id> PRODUCT_RECORD_TYPES = new List<Id>{
    //    /*'01258000000gkKSAAY'*/Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'BGI_Product_SKU' ).getRecordTypeId()
    //};



    // VF PAGE ATTRIBUTES //

    public final List<SBQQ__QuoteLineGroup__c> groups         {get; private set;}
    public final Format_Detail__mdt            format         {get; private set;}
    public final String                        localeCurrency {get; private set;}
    public final String                        localeDate     {get; private set;}
    public List<LineGroupWrapper>              lineGroupWraps {get; private set;}



    // PROPERTIES //

    protected transient String quoteId;



    // CTORS //

    /*------------------------------------------------------------
    Author:       Gianluca Calcagni
    Company:      Waeg
    Description:  Initialises all the internal variables
    Returns:      this
    Test Class:   TestQuoteDocumentController

    History:
    2019-11-05    Gianluca Calcagni    Created method
    ------------------------------------------------------------*/
    public QuoteDocumentController() {
        // Retrieve the quote ID from the URL parameters of the current page //
        this.quoteId = (String) ApexPages.currentPage().getParameters().get( QUOTE_ID_URL_PARAM );

        // Query the quote line groups with their line items //
        this.groups  = [
            SELECT
                Id, Name, SBQQ__Number__c, SBQQ__Quote__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.CurrencyIsoCode, SBQQ__Quote__r.Show_FCA_Price__c, SBQQ__Quote__r.Show_Services__c,
                SBQQ__Account__c, SBQQ__Account__r.Name, SBQQ__Account__r.SAP_Number__c, SBQQ__Account__r.BillingStreet,
                SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingPostalCode, SBQQ__Account__r.BillingCountry,
                Ship_To_Customer__c, Ship_To_Customer__r.Name, Ship_To_Customer__r.SAP_Number__c, Ship_To_Customer__r.BillingStreet,
                Ship_To_Customer__r.BillingCity, Ship_To_Customer__r.BillingState, Ship_To_Customer__r.BillingPostalCode, Ship_To_Customer__r.BillingCountry,
                Agent_Account__c, Agent_Account__r.Name, Agent_Account__r.SAP_Number__c, Agent_Account__r.BillingStreet,
                Agent_Account__r.BillingCity, Agent_Account__r.BillingState, Agent_Account__r.BillingPostalCode, Agent_Account__r.BillingCountry,
                IncoTerms__c, IncoTermsDestination__c,SAP_Contract_Number__c, To_Country__c, toLabel(PaymentTerms__c), Total_Services__c, Total_FCA_Price__c,
                SBQQ__StartDate__c, SBQQ__EndDate__c, /*FORMAT(Customer_Offered_Price__c),*/ Customer_Offered_Price__c, SBQQ__NetTotal__c,
            (
                SELECT
                    Id, Name, ItemNumber__c, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.Commercial_Name__c, SBQQ__Product__r.Product_Code_SAP__c, SBQQ__Product__r.Description,
                    SBQQ__Quantity__c, Net_Weight__c, Net_Weight_Calc__c, Gross_Weight__c, Gross_Weight_Calc__c, Services__c, Unit_of_measure__c,  /*FORMAT(Ex_Works_Price__c),*/ Ex_Works_Price__c, SBQQ__NetPrice__c, PR_Offered_Customer_Price_Unit__c,
                    SBQQ__NetTotal__c, Last_Offered_Price__c
                FROM SBQQ__LineItems__r
                WHERE SBQQ__Product__r.Material_Type__c = :PRODUCT_MATERIAL_TYPE
                ORDER BY SBQQ__Number__c, Name
                LIMIT :MAX_SIZE
            )
            FROM SBQQ__QuoteLineGroup__c
            WHERE SBQQ__Quote__c = :quoteId
            ORDER BY SBQQ__Number__c, Name
            LIMIT :MAX_SIZE
        ];

        // Query the CSS format details that must be used for this page //
        this.format  = [
            SELECT
                Id, MasterLabel, DeveloperName, Table_Border__c, Table_Font_Family__c, Table_Font_Size__c,
                Table_Cell_Padding__c, Table_Text_Color__c, Table_Header_Text_Color__c,
                Table_Caption_Text_Color__c, Table_Caption_Font_Family__c, Table_Caption_Font_Size__c,
                Table_Header_Background_Color__c, Table_Row_Alternating_Background_Color_1__c, Table_Row_Alternating_Background_Color_2__c,
                Paragraph_Bottom_Margin__c, Block_Bottom_Margin__c, Section_Bottom_Margin__c, Inline_Right_Padding__c
            FROM Format_Detail__mdt
            WHERE DeveloperName = :FORMAT_NAME
        ];

        // Set the locale //
        this.localeCurrency = getLocale( groups == null || groups.isEmpty() ? 'EUR' : groups[ 0 ].SBQQ__Quote__r.CurrencyIsoCode );
        this.localeDate     = '{0,date,dd MMM yyyy}'; //= '{0,date,E\',\' dd MMM yyyy}';

        // Set the price rollups //
        this.lineGroupWraps = new List<LineGroupWrapper>();
        for ( SBQQ__QuoteLineGroup__c grp : groups ) {
            LineGroupWrapper wrap = new LineGroupWrapper( grp );
            this.lineGroupWraps.add( wrap);
            if ( grp.SBQQ__Quote__r.Show_Services__c ) {
                wrap.priceRollups.add( new PriceRollup(
                    Label.Total_Services, grp.Total_Services__c
                ));
            }
            if ( grp.SBQQ__Quote__r.Show_FCA_Price__c ) {
                wrap.priceRollups.add( new PriceRollup(
                    Label.Total_FCA_Price, grp.Total_FCA_Price__c
                ));
            }
        }

        // Loop over the groups to check if the data is valid //
        /*for ( SBQQ__QuoteLineGroup__c grp : groups ) {
            // Call a helper method //
            setRollupPrice( grp, grp.SBQQ__LineItems__r );
        }*/
    }



    // VF PAGE ACTIONS //

    /*public PageReference init() {
        try {
            //TODO

            // do this to replace all html tags in rich text fields (otherwise they won't be compliant with XSL:FO //
            richTextFieldValue = richTextFieldValue.replaceAll('<[^>]+>',' ');
        } catch ( Exception e ) {
            String errorMsg = 'There was an error getting Discount Schedules for our Quote. Exception Cause = ' + e.getCause() + ', Exception Message = ' + e.getMessage();
            ApexPages.addMessage(
                new ApexPages.Message( ApexPages.Severity.ERROR, errorMsg )
            );
        }
        return null;
    }*/



    // FUNCTIONS //

    public static String getLocale( String curr ) {
        Decimal value          = 1000.10;
        String  formattedValue = value.format();
        String  thousandSep    = ','; //formattedValue.substring(1,2);
        String  decimalSep     = '.'; //formattedValue.substring(5,6);
        return '{0,number,' + curr + ' #' + thousandSep + '###' + thousandSep + '###' + thousandSep + '###' + thousandSep + '###' + thousandSep + '##0' + decimalSep + '00}';
    }

    /*public static void setRollupPrice( SBQQ__QuoteLineGroup__c grp, SBQQ__QuoteLine__c[] lines ) {
        // Check if the price rollup is empty //
        if ( grp.Customer_Offered_Price__c == null || grp.Customer_Offered_Price__c == 0 ) {
            // In such a case, rollup the prices and temporarily populate the field //
            grp.Customer_Offered_Price__c = 0;
            for ( SBQQ__QuoteLine__c line : lines ) {
                if ( line.Ex_Works_Price__c != null ) {
                    grp.Customer_Offered_Price__c += line.Ex_Works_Price__c;
                }
            }
        }
    }*/



    // INNER CLASSES //

    public class PriceRollup {
        // PROPERTIES //
        public String                  label     {get; set;}
        public Decimal                 price     {get; set;}
        // CTOR //
        public PriceRollup( String label, Decimal price ) {
            this.label     = label;
            this.price     = price;
        }
    }
    public class LineGroupWrapper {
        // PROPERTIES //
        public SBQQ__QuoteLineGroup__c lineGroup    {get; set;}
        public List<PriceRollup>       priceRollups {get; set;}
        // CTOR //
        public LineGroupWrapper( SBQQ__QuoteLineGroup__c lineGroup ) {
            this.lineGroup    = lineGroup;
            this.priceRollups = new PriceRollup[]{};
        }
    }



}