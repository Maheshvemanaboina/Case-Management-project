global class CPQCustomProductSearch implements SBQQ.ProductSearchPlugin {

    global Boolean isFilterHidden(SObject quote, String fieldName){
        return false;
    }

    global String getFilterDefaultValue(SObject quote, String fieldName){
        System.debug('METHOD CALLED: getFilterDefaultValue');
        return null;
    }

    global Boolean isSearchCustom(SObject quote, Map<String, Object> fieldValuesMap){
        System.debug('METHOD CALLED: isSearchCustom');
        return false;
    }

    global String getAdditionalSearchFilters(SObject quote, Map<String, Object> fieldValuesMap){
        System.debug('METHOD CALLED: getAdditionalSearchFilters');

        String productIds = '';
        String productSAPCodes = '';
        String additionalFilter = null;
        SBQQ__Quote__c q = (SBQQ__Quote__c) quote;

        List<Listing__c> listings = [
                SELECT
                        Id, Product__c, Material__c
                FROM
                        Listing__c
                WHERE
                        Sold_To_Account_Id__c = :q.SBQQ__Account__c
                        AND Sales_Area__c = :q.Sales_Area__c
                        AND Active__c = TRUE
                        AND Material__c != NULL
        ];

        for (Listing__c lis : listings) {
            if (!productIds.contains(lis.Product__c)) {
                productIds += '\'' + lis.Product__c + '\' ,';
            }

            if (!productSAPCodes.contains(lis.Material__c) && lis.Material__c != null && lis.Material__c != '') {
                productSAPCodes += '\'' + lis.Material__c + '\' ,';
            }
        }

        if (listings.size() != 0) {
            //additionalFilter = 'Product2Id IN (' + productIds.removeEnd(' ,') + ')';
            additionalFilter = 'Product2.Product_Code_SAP__c IN (' + productSAPCodes.removeEnd(' ,') + ')';
        } else {
            // We need to do this unpleasant thing, because we don't want any values if there are no matching listings
            additionalFilter = 'Name = \'This name will never be used on a product\'';
        }

        return additionalFilter;
    }

    global List<PricebookEntry> search(SObject quote, Map<String, Object> fieldValuesMap){
        System.debug('METHOD CALLED: search');
        return null;
    }

    /******************** GUIDED SELLING ********************/

    global Boolean isInputHidden(SObject quote, String input){
        System.debug('METHOD CALLED: isInputHidden');
        return false;
    }

    global String getInputDefaultValue(SObject quote, String input){
        System.debug('METHOD CALLED: getInputDefaultValue');
        return null;
    }


    global Boolean isSuggestCustom(SObject quote, Map<String, Object> inputValuesMap){
        System.debug('METHOD CALLED: isSuggestCustom');
        return true;
    }

    global String getAdditionalSuggestFilters(SObject quote, Map<String, Object> inputValuesMap){
        System.debug('METHOD CALLED: getAdditionalSuggestFilters');
        return null;
    }

    global List<PricebookEntry> suggest(SObject quote, Map<String, Object> inputValuesMap){
        System.debug('METHOD CALLED: suggest');
        return null;
    }
}