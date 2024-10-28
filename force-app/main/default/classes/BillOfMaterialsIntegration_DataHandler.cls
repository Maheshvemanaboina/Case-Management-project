/*------------------------------------------------------------
Author:       Hugo Costa
Company:      waeg
Description:  Batch process Handler that will set the CPQ data having the SAP BW Forecast as original data

History
v1.0       2019-10-29    Hugo Costa          Created batch class
v1.1       2019-11-15    Gianluca Calcagni   Edited product options
v1.2       2019-12-03    Gianluca Calcagni   Edited to create missing components
v1.3       2021-06-22    Mohan               Updated based on Jira SCPQ-1037


------------------------------------------------------------*/

public without sharing class BillOfMaterialsIntegration_DataHandler{



    // CONSTANTS //

    public static final String  PRODUCT_OPTION_TYPE       = 'Accessory';
    public static final String  PRODUCT_OPTION_VISIBILITY = 'Never'; //'Editor Only';
    public static final String  HASHTAG_IDENTIFIER        = '#';
    public static final String  CONVERSION_COST_PROD_CODE = '999999999999999999';
    public static final String  RAW_IDENTIFIER            = 'RAW-';
    public static final String  FEATURE_NAME              = 'Raw Materials';
    public static final String  KEY_IDENTIFIER            = '-';
    public static final Id      PRODUCT_RT_ID_RAW         = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get( 'Product_Material' ).getRecordTypeId();
    public static final Boolean SKIP_HASHTAG              = true;



    // PROPERTIES //

    private static List<CPQ_Bill_Of_Material_SAP__c> thisBOMDataList;
    private static Set<CPQ_Bill_Of_Material_SAP__c> bomListTreated;
    private static Set<String> materialStringSet;
    private static Set<Material_Pricing__c> materialList;
    private static Set<SBQQ__ProductOption__c> productOptionList;
    private static Set<SBQQ__ProductFeature__c> productFeatureList;
    private static Set<String> reprocessOrderList;
    private static Map<String,Product2> productMap;
    private static Map<String,SBQQ__ProductFeature__c> featureMap;
    private static Set<String> skusStringSet;
    private static Map<String,List<CPQ_Bill_Of_Material_SAP__c>> productOptionPricingMap;



    // STATIC FUNCTIONS //

    // Method called from the Batch as an Iterrator - this method will retreive the BoM data as an aggregated list - 
    //    with this we avoid the global query on the batch with the risc of getting same material in different treads
    public static List<AggregateResult> getBoMReady(){
        List<AggregateResult> groupedResults = [
            SELECT Material__c
            FROM CPQ_Bill_Of_Material_SAP__c
            WHERE TECH_ToProcess__c = TRUE
            GROUP BY Material__c
        ];
        return groupedResults;
    }

    // Method called from the Batch execute method having the scope as parameter
    public static void setBOMData(List<AggregateResult> bomList){
        if(!bomList.isEmpty()){
            materialStringSet = new Set<String> ();
            for(AggregateResult thisMaterial : bomList){
                materialStringSet.add(String.valueOf(thisMaterial.get('Material__c')));
            }

            getBOMInfo();
            setProductOptionInfo();
            if(reprocessOrderList != null && !reprocessOrderList.isEmpty()){
                reorderProductOptionSequence();
            }
            setMaterialPricing();

            if(!bomListTreated.isEmpty()){
                List<CPQ_Bill_Of_Material_SAP__c> newUniqueList = new List<CPQ_Bill_Of_Material_SAP__c>();
                newUniqueList.addAll(bomListTreated);
                update newUniqueList;
            }
        }
    }

    private static void setMaterialPricing(){
        
        materialList = new Set<Material_Pricing__c>();
        Set<String> keySet = new Set<String>();

        for(String thisMaterial : productOptionPricingMap.keySet()){
            for(CPQ_Bill_Of_Material_SAP__c thisBOM : productOptionPricingMap.get(thisMaterial)){
                Material_Pricing__c material = prepearPricingOject(thisBOM);
                if(material != null && !keySet.contains(material.External_Key__c)){
                    materialList.add(material);
                    keySet.add(material.External_Key__c);
                }
            }
        }

        if(!materialList.isEmpty()){
            List<Material_Pricing__c> newUniqueList = new List<Material_Pricing__c>();
            newUniqueList.addAll(materialList);
            upsert newUniqueList External_Key__c;
        }
    }

    private static Material_Pricing__c prepearPricingOject(CPQ_Bill_Of_Material_SAP__c thisProductOption){
        Material_Pricing__c materialP = new Material_Pricing__c();
        Product2 thisProductToUse;
        Product2 thisProductSKUToUse = new Product2();
        
        
        if ( 
            thisProductOption.Component__c != HASHTAG_IDENTIFIER &&
            thisProductOption.Component__c != CONVERSION_COST_PROD_CODE &&
            thisProductOption.Material__c != thisProductOption.Component__c &&
            productMap.containsKey(thisProductOption.Component__c)
        ) {
            thisProductToUse = productMap.get(thisProductOption.Component__c);
            if(productMap.get(thisProductOption.Material__c) != null){
                 thisProductSKUToUse = productMap.get(thisProductOption.Material__c);
            }
           
            thisProductOption.TECH_QuantityChanged__c = false;
            thisProductOption.TECH_ToProcess__c = false;
            bomListTreated.add(thisProductOption);

        } else if(
            ( thisProductOption.Component__c == HASHTAG_IDENTIFIER || thisProductOption.Component__c == CONVERSION_COST_PROD_CODE || thisProductOption.Material__c == thisProductOption.Component__c ) &&
            productMap.containsKey(thisProductOption.Material__c)
        ) {
            thisProductToUse = productMap.get(thisProductOption.Component__c);
            thisProductToUse = thisProductToUse == null ? productMap.get(thisProductOption.Material__c) : thisProductToUse;
            thisProductSKUToUse = productMap.get(thisProductOption.Material__c);
            thisProductSKUToUse = thisProductSKUToUse ==null ? productMap.get(thisProductOption.Component__c) : thisProductSKUToUse;

            thisProductOption.TECH_QuantityChanged__c = false;
            thisProductOption.TECH_ToProcess__c = false;
            bomListTreated.add(thisProductOption);
        } else {
            return null;
        }
        materialP.Material__c           = thisProductSKUToUse.Id;
        materialP.Product__c            = thisProductToUse.Id;
        //materialP.External_Key__c       = String.valueOf(thisProductToUse.Id) +KEY_IDENTIFIER+ thisProductOption.Plant__c;
        materialP.External_Key__c       = thisProductOption.External_Key__c;
        materialP.Market_Price_M00__c   = thisProductOption.Market_Price_M00__c;
        materialP.Market_Price_M01__c   = thisProductOption.Market_Price_M01__c;
        materialP.Market_Price_M02__c   = thisProductOption.Market_Price_M02__c;
        materialP.Market_Price_M03__c   = thisProductOption.Market_Price_M03__c;
        materialP.Market_Price_M04__c   = thisProductOption.Market_Price_M04__c;
        materialP.Market_Price_M05__c   = thisProductOption.Market_Price_M05__c;
        materialP.Market_Price_M06__c   = thisProductOption.Market_Price_M06__c;
        materialP.Market_Price_M07__c   = thisProductOption.Market_Price_M07__c;
        materialP.Market_Price_M08__c   = thisProductOption.Market_Price_M08__c;
        materialP.Market_Price_M09__c   = thisProductOption.Market_Price_M09__c;
        materialP.Market_Price_M10__c   = thisProductOption.Market_Price_M10__c;
        materialP.Market_Price_M11__c   = thisProductOption.Market_Price_M11__c;
        materialP.Purchase_Price_P00__c = thisProductOption.Purchase_Price_P00__c;
        materialP.Purchase_Price_P01__c = thisProductOption.Purchase_Price_P01__c;
        materialP.Purchase_Price_P02__c = thisProductOption.Purchase_Price_P02__c;
        materialP.Purchase_Price_P03__c = thisProductOption.Purchase_Price_P03__c;
        materialP.Purchase_Price_P04__c = thisProductOption.Purchase_Price_P04__c;
        materialP.Purchase_Price_P05__c = thisProductOption.Purchase_Price_P05__c;
        materialP.Purchase_Price_P06__c = thisProductOption.Purchase_Price_P06__c;
        materialP.Purchase_Price_P07__c = thisProductOption.Purchase_Price_P07__c;
        materialP.Purchase_Price_P08__c = thisProductOption.Purchase_Price_P08__c;
        materialP.Purchase_Price_P09__c = thisProductOption.Purchase_Price_P09__c;
        materialP.Purchase_Price_P10__c = thisProductOption.Purchase_Price_P10__c;
        materialP.Purchase_Price_P11__c = thisProductOption.Purchase_Price_P11__c;
        materialP.Plant__c              = thisProductOption.Plant__c;   
        materialP.Plant_Name__c         = thisProductOption.Plant_Name__c;
        materialP.Quantity__c           = thisProductOption.Quantity__c;
        materialP.Quantity_UoM__c       = thisProductOption.Quantity_UoM__c;
        materialP.Origin_Group__c       = thisProductOption.Origin_Group__c;
        materialP.Period_Year__c        = thisProductOption.Period_Year__c;   


        return materialP;
    }

    private static void reorderProductOptionSequence(){
        List<SBQQ__ProductOption__c> thisProductOptions = [
            SELECT Id, SBQQ__Quantity__c, SBQQ__Number__c, SBQQ__ConfiguredSKU__r.Product_Code__c, External_Key__c
            FROM SBQQ__ProductOption__c 
            WHERE SBQQ__ConfiguredSKU__r.Product_Code__c IN :reprocessOrderList
            ORDER BY SBQQ__Quantity__c DESC
        ];

        Map<String,List<SBQQ__ProductOption__c>> productOptionQuantityMap = new Map<String,List<SBQQ__ProductOption__c>>();
        for(SBQQ__ProductOption__c thisOption : thisProductOptions){
            List<SBQQ__ProductOption__c> tempList = productOptionQuantityMap.containsKey(thisOption.SBQQ__ConfiguredSKU__r.Product_Code__c) ? productOptionQuantityMap.get(thisOption.SBQQ__ConfiguredSKU__r.Product_Code__c) : new List<SBQQ__ProductOption__c>();         
            tempList.add(thisOption);
            productOptionQuantityMap.put(thisOption.SBQQ__ConfiguredSKU__r.Product_Code__c,tempList);
        }

        List<SBQQ__ProductOption__c> thisProductOptionsToUpdate = new List<SBQQ__ProductOption__c>();
        for(String thisProductOption : productOptionQuantityMap.keySet()){
            Integer sequence = 0;
            for(SBQQ__ProductOption__c thisOption : productOptionQuantityMap.get(thisProductOption)){
                sequence++;
                if(thisOption.SBQQ__Number__c != sequence){
                    thisOption.SBQQ__Number__c = sequence;
                    thisProductOptionsToUpdate.add(thisOption);
                }
            }
        }
        if ( !thisProductOptionsToUpdate.isEmpty() ) {
            update thisProductOptionsToUpdate;
        }
    }

    private static void setProductOptionInfo(){
        productFeatureList = new Set<SBQQ__ProductFeature__c>();
        productOptionList = new Set<SBQQ__ProductOption__c>();
        bomListTreated = new Set<CPQ_Bill_Of_Material_SAP__c>();
        reprocessOrderList = new Set<String>();

        //Product2 configuredSKU;
        Product2 optionalSKU;


        for(CPQ_Bill_Of_Material_SAP__c thisBoM  : thisBOMDataList){

            if ( 
                /*( SKIP_HASHTAG || thisBoM.Component__c != HASHTAG_IDENTIFIER ) &&
                ( SKIP_HASHTAG || thisBoM.Component__c != CONVERSION_COST_PROD_CODE ) &&*/
                thisBoM.Component__c != thisBoM.Material__c &&
                productMap.containsKey(thisBoM.Component__c) &&
                productMap.containsKey(thisBoM.Material__c)
            ) {
                optionalSKU = productMap.get(thisBoM.Component__c);
                //configuredSKU = productMap.get(thisBoM.Material__c);

            } else {
                continue;
            }

            SBQQ__ProductFeature__c newProductFeature = new SBQQ__ProductFeature__c();

            String featureKey = thisBoM.Material__c + KEY_IDENTIFIER + FEATURE_NAME;

            if(!featureMap.containsKey(featureKey)){
                newProductFeature = new SBQQ__ProductFeature__c(
                    Name                    = FEATURE_NAME,
                    External_Key__c         = featureKey,
                    SBQQ__ConfiguredSKU__r  = new Product2( Product_Code__c = thisBom.Material__c ), //configuredSKU.Id,
                    SBQQ__MinOptionCount__c = 0,
                    SBQQ__Number__c         = 20,
                    SBQQ__Category__c       = 'Bill of Materials'
                    //SBQQ__OptionSelectionMethod__c = 'Click'
                );
                productFeatureList.add(newProductFeature);
            }

            SBQQ__ProductOption__c newProductOption = new SBQQ__ProductOption__c();
            newProductOption.External_Key__c = thisBoM.External_Key__c;
            newProductOption.SBQQ__ConfiguredSKU__r = new Product2( Product_Code__c = thisBom.Material__c ); //configuredSKU.Id;
            newProductOption.SBQQ__OptionalSKU__c = optionalSKU.Id;
            newProductOption.SBQQ__Quantity__c = thisBoM.Quantity__c;
            newProductOption.SBQQ__Feature__r = new SBQQ__ProductFeature__c(External_Key__c = featureKey);
            newProductOption.SBQQ__Number__c = 1;
            // 
            newProductOption.SBQQ__QuantityEditable__c = false;
            newProductOption.SBQQ__Selected__c = true;
            newProductOption.SBQQ__Required__c = true;
            newProductOption.SBQQ__MinQuantity__c = -99999;
            newProductOption.SBQQ__Bundled__c = true;
            newProductOption.SBQQ__Type__c = PRODUCT_OPTION_TYPE;
            newProductOption.SBQQ__QuoteLineVisibility__c = PRODUCT_OPTION_VISIBILITY;
            newProductOption.SBQQ__System__c = true;
            newProductOption.Delete__c = thisBoM.Delete__c;


            productOptionList.add(newProductOption);

            if(thisBoM.TECH_QuantityChanged__c){
                reprocessOrderList.add(thisBoM.Material__c);
            }

            thisBoM.TECH_QuantityChanged__c = false;
            thisBoM.TECH_ToProcess__c = false;
            bomListTreated.add(thisBoM);
        }

        if(!productFeatureList.isEmpty()){
            List<SBQQ__ProductFeature__c> newUniqueList = new List<SBQQ__ProductFeature__c>();
            newUniqueList.addAll(productFeatureList);
            insert newUniqueList;
        }

        if(!productOptionList.isEmpty()){
            List<SBQQ__ProductOption__c> newUniqueList2 = new List<SBQQ__ProductOption__c>();
            newUniqueList2.addAll(productOptionList);
            upsert newUniqueList2 External_Key__c;
        }
    }

    private static void getBOMInfo(){
        productMap = new Map<String,Product2>();
        skusStringSet = new Set<String>();
        featureMap = new Map<String,SBQQ__ProductFeature__c>();
        productOptionPricingMap = new Map<String,List<CPQ_Bill_Of_Material_SAP__c>>();

        thisBOMDataList = [
            SELECT
                Id,Component__c,
                Component_Price__c,External_Key__c,
                Market_Price_M00__c,Market_Price_M01__c,
                Market_Price_M02__c,Market_Price_M03__c,
                Market_Price_M04__c,Market_Price_M05__c,
                Market_Price_M06__c,Market_Price_M07__c,
                Market_Price_M08__c,Market_Price_M09__c,
                Market_Price_M10__c,Market_Price_M11__c,
                Material__c,Origin_Group__c,
                Period_Year__c,Plant__c,
                Plant_Name__c,Price_Unit_for_Cost_Price__c,
                Price_Unit_UoM__c,Purchase_Price_P00__c,
                Purchase_Price_P01__c,Purchase_Price_P02__c,
                Purchase_Price_P03__c,Purchase_Price_P04__c,
                Purchase_Price_P05__c,Purchase_Price_P06__c,
                Purchase_Price_P07__c,Purchase_Price_P08__c,
                Purchase_Price_P09__c,Purchase_Price_P10__c,
                Purchase_Price_P11__c,Quantity__c,
                Quantity_UoM__c,Standard_Price__c,
                Standard_Qty__c,Standard_Qty_UoM__c,
                CurrencyIsoCode,TECH_QuantityChanged__c,
                Delete__c
            FROM CPQ_Bill_Of_Material_SAP__c
            WHERE
                TECH_ToProcess__c = TRUE AND
                Material__c IN :materialStringSet
        ];

        for(CPQ_Bill_Of_Material_SAP__c thisBoMInfo : thisBOMDataList){
            List<CPQ_Bill_Of_Material_SAP__c> tempList = new List<CPQ_Bill_Of_Material_SAP__c>();
            if(productOptionPricingMap.containsKey(thisBoMInfo.Material__c)){
                tempList = productOptionPricingMap.get(thisBoMInfo.Material__c);
            }

            tempList.add(thisBoMInfo);
            productOptionPricingMap.put(thisBoMInfo.Material__c,tempList);


            skusStringSet.add(String.valueOf(thisBoMInfo.Material__c));
            skusStringSet.add(String.valueOf(thisBoMInfo.Component__c));
            /* BEGIN EDITED BY GC ON 2019-12-03 */
            if ( thisBoMInfo.Component__c != null && !thisBoMInfo.Component__c.equals(HASHTAG_IDENTIFIER) && !thisBoMInfo.Component__c.equals(CONVERSION_COST_PROD_CODE) && thisBomInfo.Component__c.length() < 22 ) {
                skusStringSet.add( RAW_IDENTIFIER + String.valueOf(thisBoMInfo.Component__c) );
            }
            /* END EDITED BY GC ON 2019-12-03 */
        }

        List<Product2> product2ActiveList = [
            SELECT id, Name, Product_Code__c, RecordTypeId, IsActive, Gross_Weight__c, Net_Weight__c, Product_Hierarchy_Code__c, Hierarchy_1__c, Hierarchy_2__c, Hierarchy_3__c, Hierarchy_4__c, Hierarchy_5__c, Hierarchy_6__c, Min_Remaining_Shelf_Live__c, Total_Shelf_Live__c,
                Material_Type__c, Base_Unit_of_Measure__c, Product_EAN_Code__c, Product_Segment_4__c, Product_Segment_3__c, Product_Segment_2__c, Product_Segment_1__c, Commercial_Name__c, Product_Group_Lookup__c, Sales_Organization_Number__c, Business_Segment_Non_Restricted__c
            FROM Product2 
            WHERE Product_Code__c IN :skusStringSet AND IsActive = TRUE
            ORDER BY Product_Code__c /* REMARK FROM GC 2019-12-03: the ordering is necessary so to not overwrite in productMap the product codes starting with RAW_IDENTIFIER */
        ];

        for(Product2 thisProduct : product2ActiveList){
            /* BEGIN EDITED BY GC ON 2019-12-03 */
            String productCode = thisProduct.Product_Code__c.removeStart( RAW_IDENTIFIER );
            productMap.put( productCode, thisProduct );
            /* END EDITED BY GC ON 2019-12-03 */
        }

        /* BEGIN EDITED BY GC ON 2019-12-03 */
        // Find if any component is actually not a raw material; in such a case, create the missing raw material and include it in productMap  //
        Map<String, Product2> codeToMissingProduct = new Map<String, Product2>();
        //Map<String, SBQQ__ProductOption__c> externalKeyToOption = new Map<String, SBQQ__ProductOption__c>();
        for ( CPQ_Bill_Of_Material_SAP__c thisBoMInfo : thisBOMDataList ) {
            Product2 foundProduct = productMap.get( thisBomInfo.Component__c );
            if ( foundProduct != null && foundProduct.RecordTypeId != PRODUCT_RT_ID_RAW ) {
                Product2 missingProduct = new Product2(
                    RecordtypeId                       = PRODUCT_RT_ID_RAW,
                    Name                               = foundProduct.Name,
                    Product_Code__c                    = RAW_IDENTIFIER + thisBomInfo.Component__c,
                    ProductCode                        = RAW_IDENTIFIER + thisBomInfo.Component__c,
                    IsActive                           = foundProduct.IsActive,
                    Gross_Weight__c                    = foundProduct.Gross_Weight__c,
                    Net_Weight__c                      = foundProduct.Net_Weight__c,
                    Product_Hierarchy_Code__c          = foundProduct.Product_Hierarchy_Code__c,
                    Hierarchy_1__c                     = foundProduct.Hierarchy_1__c,
                    Hierarchy_2__c                     = foundProduct.Hierarchy_2__c,
                    Hierarchy_3__c                     = foundProduct.Hierarchy_3__c,
                    Hierarchy_4__c                     = foundProduct.Hierarchy_4__c,
                    Hierarchy_5__c                     = foundProduct.Hierarchy_5__c,
                    Hierarchy_6__c                     = foundProduct.Hierarchy_6__c,
                    Material_Type__c                   = foundProduct.Material_Type__c,
                    Base_Unit_of_Measure__c            = foundProduct.Base_Unit_of_Measure__c,
                    Product_EAN_Code__c                = foundProduct.Product_EAN_Code__c,
                    Product_Segment_4__c               = foundProduct.Product_Segment_4__c,
                    Product_Segment_3__c               = foundProduct.Product_Segment_3__c,
                    Product_Segment_2__c               = foundProduct.Product_Segment_2__c,
                    Product_Segment_1__c               = foundProduct.Product_Segment_1__c,
                    Commercial_Name__c                 = foundProduct.Commercial_Name__c,
                    Product_Group_Lookup__c            = foundProduct.Product_Group_Lookup__c,
                    Sales_Organization_Number__c       = foundProduct.Sales_Organization_Number__c,
                    Business_Segment_Non_Restricted__c = foundProduct.Business_Segment_Non_Restricted__c,
                    Min_Remaining_Shelf_Live__c        = foundProduct.Min_Remaining_Shelf_Live__c,
                    Total_Shelf_Live__c                = foundProduct.Total_Shelf_Live__c
                );
                codeToMissingProduct.put( thisBomInfo.Component__c, missingProduct );
                productMap.put( thisBomInfo.Component__c, missingProduct );
            }
        }
        if ( !codeToMissingProduct.isEmpty() ) {
            Database.upsert( codeToMissingProduct.values(), Product2.Product_Code__c, true );
        }
        /* END EDITED BY GC ON 2019-12-03 */

        List<SBQQ__ProductFeature__c> featureList = [
            SELECT id, External_Key__c
            FROM SBQQ__ProductFeature__c 
            WHERE SBQQ__ConfiguredSKU__r.Product_Code__c IN :skusStringSet AND SBQQ__ConfiguredSKU__r.IsActive = TRUE
            ORDER BY External_Key__c
        ];
        
        for(SBQQ__ProductFeature__c thisFeature : featureList){
            featureMap.put(thisFeature.External_Key__c,thisFeature);
        }
    }



}