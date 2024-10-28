/*************************************************************** KJM - 09/04/2019
 Name: UploadAccountFromCSV
 ======================================================
 Purpose: Class used for upload accounts from csv
 ======================================================
***************************************************************/
public with sharing class UploadAccountFromCSV extends UploadObjectFromCSV {

    private final String objectName = Constants.OBJECT_NAME_ACCOUNT;

    // map of data values into csv file
    public static final Map<Integer, String> csvFileObjFieldMap = new Map<Integer,String> {
            0 => Account.Name.getDescribe().getName(),
            1 => Account.Distributor_Location__c.getDescribe().getName(),
            2 => Account.OwnerId.getDescribe().getName(),
            3 => Account.Distributor_Sales_Manager__c.getDescribe().getName(),
            4 => Account.Business_Segment__c.getDescribe().getName(),
            5 => Account.Sub_Segment__c.getDescribe().getName(),
            6 => Account.Application__c.getDescribe().getName(),
            7 => Account.BillingCountry.getDescribe().getName(),
            8 => Account.BillingStreet.getDescribe().getName(),
            9 => Account.BillingPostalCode.getDescribe().getName(),
            10 => Account.BillingCity.getDescribe().getName(),
            11 => Account.Description.getDescribe().getName()
    };

    // map of data values fetch into logic and insert to system
    private final Map<Integer, String> csvIndexObjFieldMap = new Map<Integer,String> {
            0 => Account.Name.getDescribe().getName(),
            1 => Account.Distributor_Location__c.getDescribe().getName(),
            2 => Account.OwnerId.getDescribe().getName(),
            3 => Account.Distributor_Sales_Manager__c.getDescribe().getName(),
            4 => Account.Business_Segment__c.getDescribe().getName(),
            5 => Account.Sub_Segment__c.getDescribe().getName(),
            6 => Account.Application__c.getDescribe().getName(),
            7 => Account.BillingCountry.getDescribe().getName(),
            8 => Account.BillingStreet.getDescribe().getName(),
            9 => Account.BillingPostalCode.getDescribe().getName(),
            10 => Account.BillingCity.getDescribe().getName(),
            11 => Account.Description.getDescribe().getName(),
            12 => Account.RecordTypeId.getDescribe().getName(),
            13 => Account.Skip_Distributor_Auto_Assignment__c.getDescribe().getName()
    };

    private final Set<String> mandatoryToValidate = new Set<String> {
            Account.Name.getDescribe().getName(),
            Account.Distributor__c.getDescribe().getName(),
            Account.Distributor_Location__c.getDescribe().getName(),
            Account.Distributor_Sales_Manager__c.getDescribe().getName(),
            Account.BillingCountry.getDescribe().getName(),
          //  Account.BillingStreet.getDescribe().getName(),
           // Account.BillingPostalCode.getDescribe().getName(),
          //  Account.BillingCity.getDescribe().getName(),
            Account.Skip_Distributor_Auto_Assignment__c.getDescribe().getName(),
            Account.OwnerId.getDescribe().getName()
    };

    private final Map<String, String> fieldsForChangeFromNameToId = new Map<String, String> {
           // Account.Distributor__c.getDescribe().getName() => Constants.OBJECT_NAME_ACCOUNT,
            Account.Distributor_Location__c.getDescribe().getName() => Constants.OBJECT_NAME_ACCOUNT,
            Account.Distributor_Sales_Manager__c.getDescribe().getName() => Constants.OBJECT_NAME_CONTACT,
            Account.RecordTypeId.getDescribe().getName() => Constants.OBJECT_NAME_RECORD_TYPE,
            Account.OwnerId.getDescribe().getName() => Constants.OBJECT_NAME_USER
    };

    private final Set<String> exceptionsForDisplayToUser = new Set<String> {
            Account.RecordTypeId.getDescribe().getName(),
            Account.Skip_Distributor_Auto_Assignment__c.getDescribe().getName()
    };

    private final Set<String> booleanToValidate = new Set<String> {
            Account.Skip_Distributor_Auto_Assignment__c.getDescribe().getName()
    };

    private final Set<String> picklistToValidate = new Set<String>{
        Account.Business_Segment__c.getDescribe().getName(),
        Account.Sub_Segment__c.getDescribe().getName(),    
        Account.Application__c.getDescribe().getName()
    };

    public override Set<String> getPicklistToValidate() {
        return picklistToValidate;
    }
    
    public UploadAccountFromCSV(List<String> dataToProcess) {
        super(dataToProcess);
    }

    public override Set<String> getExceptionsForDisplayToUser() {
        return exceptionsForDisplayToUser;
    }

    public override String getObjectName() {
        return objectName;
    }

    public override Map<Integer, String> getCsvIndexObjFieldMap() {
        return csvIndexObjFieldMap;
    }

    public override Set<String> getMandatoryToValidate() {
        return mandatoryToValidate;
    }

    public override Set<String> getBooleanToValidate() {
        return booleanToValidate;
    }

    public override Map<String, String> getFieldsForChangeFromNameToIds() {
        return fieldsForChangeFromNameToId;
    }

    public override Map<String, Set<String>> getFieldValuesToValidate() {
        return new Map<String, Set<String>>();
    }

    public override Set<Integer> getDuplicateObjectIndexes(List<SObject> objsToCheck) {
        Set<Integer> duplicatesIndexes = new Set<Integer>();

        Set<String> accNames = new Set<String>();
        for (SObject obj : objsToCheck){
            accNames.add((String)obj.get(Constants.NAME_FIELD_NAME));
        }

        List<Account> accsDB = DAOUtilityWithoutShar.getAllAccountsByNameForDuplicates(accNames, Constants.ACCOUNT_RECORD_TYPE_END_CUSTOMER_ID);
        if (accsDB.isEmpty()) {
            return new Set<Integer>();
        }

        Map<String, List<Account>> accsMap = new Map<String, List<Account>>();
        for (Account acc : accsDB) {
            if (!accsMap.containsKey(String.valueOf(acc.Name).toLowercase())) {
                accsMap.put (String.valueOf(acc.Name).toLowercase(), new List<Account>());
            }
            accsMap.get(String.valueOf(acc.Name).toLowercase()).add(acc);
        }
        System.debug('accsMap===>'+accsMap);
        for (Integer i = 0; i < objsToCheck.size(); i++) {
            String currentAccName = (String)objsToCheck[i].get(Constants.NAME_FIELD_NAME);
           currentAccName = currentAccName.toLowerCase();
            System.debug('Lower '+currentAccName.toLowercase());
            if (accsMap.containsKey(currentAccName)) {
                for (Account accWithThisSameName : accsMap.get(currentAccName)) {
                    if (
                            //String.valueOf(accWithThisSameName.Name.trim()).equalsIgnoreCase(String.valueOf(objsToCheck[i].get(Account.Name.getDescribe().getName())).trim()) &&
                            accWithThisSameName.BillingCountry.trim() == String.valueOf(objsToCheck[i].get(Account.BillingCountry.getDescribe().getName())).trim() &&
                            accWithThisSameName.Distributor_Location__r.Name.trim() == String.valueOf(objsToCheck[i].get(Account.Distributor_Location__c.getDescribe().getName())).trim()
                           /* accWithThisSameName.BillingStreet.trim() == String.valueOf(objsToCheck[i].get(Account.BillingStreet.getDescribe().getName())).trim() &&
                            accWithThisSameName.BillingPostalCode.trim() == String.valueOf(objsToCheck[i].get(Account.BillingPostalCode.getDescribe().getName())).trim() &&
                            accWithThisSameName.BillingCity.trim() == String.valueOf(objsToCheck[i].get(Account.BillingCity.getDescribe().getName())).trim()*/
                            ) {
                        duplicatesIndexes.add(i);
                        continue;
                    }
                }
           }
        }

        return duplicatesIndexes;
    }
}