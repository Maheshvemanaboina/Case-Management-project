/**
 * Created by KJM on 26/08/2019.
 */

public with sharing class TileAutoCreationPageController {

    private static Set<String> months = new Set<String>{
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
    };

    @AuraEnabled
    public static ResponseWrapper runOrderAndDeliveryScriptOption(String commercialCustomer, String customLocations, String year, String communityName) {
        ResponseWrapper resp = new ResponseWrapper();
        resp.Success = true;

        commercialCustomer = commercialCustomer.trim();
        customLocations = customLocations.trim();
        year = year.trim();
        communityName = communityName.trim();

        /////////////////////// VALIDATION
        if (String.isBlank(commercialCustomer) || String.isBlank(customLocations) || String.isBlank(year) || String.isBlank(communityName)) {
            return getErrorResponse('Fill in all required data');
        }

        ////// COMMERCIAL CUSTOMER
        List<Account> commCust = [SELECT Id, (SELECT Id, Name FROM ChildAccounts) FROM Account WHERE Name = :commercialCustomer AND RecordTypeId = :Constants.ACCOUNT_RECORD_TYPE_COMMERCIAL_CUSTOMER_ID];
        if (commCust.isEmpty()) {
            return getErrorResponse('Cannot find Commercial Customer: ' + commercialCustomer);
        }

        ////// CUSTOMER LOCATION
        Map<Id, Account> customerLocations;
        List<String> customerLocationsList = new List<String>();
        if (customLocations != 'All') {
            for (String oneCust : customLocations.split(';')) {
                customerLocationsList.add(oneCust.trim());
            }

            List<Account> customerLocs = [SELECT Id, Name FROM Account WHERE Name IN :customerLocationsList AND RecordTypeId = :Constants.ACCOUNT_RECORD_TYPE_CUSTOMER_LOCATION_ID];
            for (String customerLoc : customerLocationsList) {
                Boolean haveValue = false;
                for (Account acc : customerLocs) {
                    if (customerLoc.containsIgnoreCase(acc.Name)) {
                        haveValue = true;
                        continue;
                    }
                }

                if (!haveValue) {
                    return getErrorResponse('Cannot find Customer Location: ' + customerLoc);
                }
            }

            customerLocations = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Name IN : customerLocationsList]);
        } else {
            customerLocations = new Map<Id, Account>();
            for (Account acc : commCust.get(0).ChildAccounts) {
                customerLocations.put(acc.Id, acc);
            }
        }

        ////// YEAR
        Pattern yearPattern = Pattern.compile('^\\d{4}$');
        Matcher pm = yearPattern.matcher( year );
        if (!pm.matches()) {
            return getErrorResponse('Cannot process with year: ' + year);
        }

        ////// COMMUNITY NAME
        List<String> communityNames = new List<String>();
        for (Schema.PicklistEntry pckl: Tile__c.Community_Name__c.getDescribe().getPicklistValues()) {
            communityNames.add(pckl.getValue());
        }

        Boolean haveValue = false;
        for (String commName : communityNames) {
            if (commName.containsIgnoreCase(communityName)) {
                haveValue = true;
                continue;
            }
        }

        if (!haveValue) {
            return getErrorResponse('Cannot find Community Name: ' + communityName);
        }

        ///////////////// TILES CREATION
        Savepoint sp = Database.setSavepoint();
        try {

            Tile__c rootTile = new Tile__c();
            rootTile.Name = commercialCustomer + ' - ' + year;
            rootTile.UI_Name__c = year;
            rootTile.Community_Name__c = communityName;
            rootTile.Child_Display_Option__c = 'List';
            rootTile.Child_Order_Option__c = Constants.TILE_CHILD_ORDER_OPTION_BY_ORDER_NUMBER;
            insert rootTile;

            List<Tile__c> tilesToInsert = new List<Tile__c>();
            for (Id custLocId : customerLocations.keySet()) {
                Integer index = 1;
                for (String month : months) {
                    Tile__c tl = new Tile__c();
                    tl.Name = commercialCustomer + ' - ' + customerLocations.get(custLocId).Name + ' - ' + year + ' - ' + month;
                    tl.UI_Name__c = month;
                    tl.Community_Name__c = communityName;
                    tl.Work_Location__c = custLocId;
                    tl.Parent_Tile__c = rootTile.Id;
                    tl.Order_Number__c = index;
                    tl.Redirect_To_Details__c = true;
                    tilesToInsert.add(tl);
                    index++;
                }
            }

            insert tilesToInsert;

        } catch (Exception ex) {
            Database.rollback(sp);
            return getErrorResponse('Exception: ' + ex.getMessage() + ' ');
        }

        return resp;
    }

    private static ResponseWrapper getErrorResponse(String errorMessage) {
        ResponseWrapper resp = new ResponseWrapper();
        resp.Success = false;
        resp.ErrorMessage = errorMessage;
        return resp;
    }

    public class ResponseWrapper {
        @AuraEnabled public Boolean Success { get; set; }
        @AuraEnabled public String ErrorMessage { get; set; }

        public ResponseWrapper() {}
    }
}