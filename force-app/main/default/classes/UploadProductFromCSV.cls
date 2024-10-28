/*************************************************************** KJM - 09/04/2019
 Name: UploadProductFromCSV
 ======================================================
 Purpose: Class used for upload opportunity product items from csv
 Class will be delete in the future, because of many changes related to upload functionality I decided to leave it for now.
 ======================================================
***************************************************************/
public with sharing class UploadProductFromCSV extends UploadObjectFromCSV {

    /* private final String objectName = Constants.OBJECT_NAME_OPPORTUNITY_LINE_ITEM;
     private static final Map<Integer, String> csvIndexObjFieldMap = new Map<Integer,String>{
         0 => OpportunityLineItem.OpportunityId.getDescribe().getName(),
         1 => OpportunityLineItem.Product2Id.getDescribe().getName(),
         2 => OpportunityLineItem.Quantity.getDescribe().getName(),
         3 => OpportunityLineItem.TotalPrice.getDescribe().getName()
     };

     public static Integer getObjectsToParseCount() {
         return csvIndexObjFieldMap.keySet().size();
     }

     private final Map<String, String> fieldsForChangeFromNameToId = new Map<String, String> {
             OpportunityLineItem.OpportunityId.getDescribe().getName() => Constants.OBJECT_NAME_OPPORTUNITY,
             OpportunityLineItem.Product2Id.getDescribe().getName() => Constants.OBJECT_NAME_PRODUCT
     };

     private final Set<String> mandatoryToValidate = new Set<String> {
             OpportunityLineItem.OpportunityId.getDescribe().getName(),
             OpportunityLineItem.Product2Id.getDescribe().getName(),
             OpportunityLineItem.Quantity.getDescribe().getName(),
             OpportunityLineItem.TotalPrice.getDescribe().getName()
     };

     private final Set<String> decimalToValidate = new Set<String> {
             OpportunityLineItem.Quantity.getDescribe().getName(),
             OpportunityLineItem.TotalPrice.getDescribe().getName()
     };
 */
    public UploadProductFromCSV(List<String> dataToProcess) {
        super(dataToProcess);
    }
/*
    public override String getObjectName() {
        return objectName;
    }

    public override Map<Integer, String> getCsvIndexObjFieldMap() {
        return csvIndexObjFieldMap;
    }

    public override Set<String> getDecimalToValidate() {
        return decimalToValidate;
    }

    public override Set<String> getMandatoryToValidate() {
        return mandatoryToValidate;
    }

    public override Map<String, String> getFieldsForChangeFromNameToIds() {
        return fieldsForChangeFromNameToId;
    }

    public override String getFirstPartOfErrorWrapper(UploadObjectFromCSV.ProcessObjectWrapper procObj) {
        return 'Product: ' + procObj.processObj.get(Constants.PRODUCT2_ID_FIELD_NAME) + ' Opportunity: ' + procObj.processObj.get(Constants.OPPORTUNITY_ID_FIELD_NAME) ;
    }

    public override Set<Integer> getDuplicateObjectIndexes(List<SObject> objsToCheck) {
        Set<Integer> duplicatesIndexes = new Set<Integer>();

        Set<String> oppsNames = new Set<String>();
        for (OpportunityLineItem oppLineItem : (List<OpportunityLineItem>)objsToCheck){
            oppsNames.add(oppLineItem.OpportunityId);
        }

        List<OpportunityLineItem> opps = DAOUtilityWithoutShar.getAllOppItemsByOppNameForDuplicates(oppsNames);
        if (opps.isEmpty()) {
            return new Set<Integer>();
        }

        Map<String, List<String>> duplicatesOppName = new Map<String, List<String>>();
        for (OpportunityLineItem opp : opps) {
            if (!duplicatesOppName.containsKey(opp.Opportunity.Name)) {
                duplicatesOppName.put(opp.Opportunity.Name, new List<String>());
            }
            duplicatesOppName.get(opp.Opportunity.Name).add(opp.Product2.Name);
        }

        for (Integer i = 0; i < objsToCheck.size(); i++){
            if (duplicatesOppName.containsKey((String)objsToCheck[i].get(Constants.OPPORTUNITY_ID_FIELD_NAME)) &&
                duplicatesOppName.get((String)objsToCheck[i].get(Constants.OPPORTUNITY_ID_FIELD_NAME)).contains((String)objsToCheck[i].get(Constants.PRODUCT2_ID_FIELD_NAME))) {
                duplicatesIndexes.add(i);
            }
        }

        return duplicatesIndexes;
    }

    public override void addExistingObjIdForOverwrite(List<ProcessObjectWrapper> processObjectWrappers) {
        Set<String> oppsNames = new Set<String>();
        for (ProcessObjectWrapper procObj : processObjectWrappers){
            oppsNames.add((String)procObj.processObj.get(Constants.OPPORTUNITY_ID_FIELD_NAME));
        }

        Map<String, Map<String, String>> duplicatesOppName = new Map<String, Map<String, String>>();
        for (OpportunityLineItem opp : DAOUtilityWithoutShar.getAllOppItemsByOppNameForDuplicates(oppsNames)) {
            if (!duplicatesOppName.containsKey(opp.Opportunity.Name)) {
                duplicatesOppName.put(opp.Opportunity.Name, new Map<String, String>());
            }
            duplicatesOppName.get(opp.Opportunity.Name).put(opp.Product2.Name, opp.Id);
        }

        for (Integer i = 0; i < processObjectWrappers.size(); i++){
            String opportunityName = (String)processObjectWrappers[i].processObj.get(Constants.OPPORTUNITY_ID_FIELD_NAME);
            String productName = (String)processObjectWrappers[i].processObj.get(Constants.PRODUCT2_ID_FIELD_NAME);
            if (duplicatesOppName.containsKey(opportunityName) &&
                duplicatesOppName.get(opportunityName).containsKey(productName)) {
                processObjectWrappers[i].processObj.put(Constants.ID_FIELD_NAME,  duplicatesOppName.get(opportunityName).get(productName));
            }
        }
    }

    public override void replaceFieldsFromNameToId(List<ProcessObjectWrapper> processObjectWrappers) {
        setPriceBookEntryId(processObjectWrappers);
        setOtherFieldsIds(processObjectWrappers);
    }

    private void setOtherFieldsIds(List<ProcessObjectWrapper> processObjectWrappers) {
        List<ProcessObjectWrapper> processObjectWrappersDupl = new List<ProcessObjectWrapper>();
        for (ProcessObjectWrapper obj : processObjectWrappers) {
            if (obj.isDuplicate) {
                continue;
            }

            processObjectWrappersDupl.add(obj);
        }

        super.replaceFieldsFromNameToId(processObjectWrappersDupl);
    }

    private void setPriceBookEntryId(List<ProcessObjectWrapper> processObjectWrappers) {
        Map<String, Opportunity> oppMap = getOpportunityMap(processObjectWrappers);
        Map<String, Map<String, Map<String, PricebookEntry>>> pricebookEntrieMap = getPricebookEntryMap(processObjectWrappers);

        for (ProcessObjectWrapper obj : processObjectWrappers) {
            OpportunityLineItem ltm = (OpportunityLineItem)obj.processObj;

            if (obj.isDuplicate) {
                continue;
            }

            String productName = ltm.Product2Id;
            String pricebookName = oppMap.get(ltm.OpportunityId).Pricebook2.Name;
            String currencyIsoCode = oppMap.get(ltm.OpportunityId).CurrencyIsoCode;

            if (pricebookEntrieMap.containsKey(productName) &&
                    pricebookEntrieMap.get(productName).containsKey(currencyIsoCode) &&
                    pricebookEntrieMap.get(productName).get(currencyIsoCode).containsKey(pricebookName)) {
                ltm.PricebookEntryId = pricebookEntrieMap.get(productName).get(currencyIsoCode).get(pricebookName).Id;
            } else {
                throw new UploadObjectFromCSV.UploadObjectFromCSVException(getFirstPartOfErrorWrapper(obj) + ' Cannot find Pricebook entry for productName: ' + pricebookName + ' and currency: ' + currencyIsoCode);
            }
        }
    }

    private Map<String, Opportunity> getOpportunityMap(List<ProcessObjectWrapper> processObjectWrappers) {
        Set<String> oppNames = new Set<String>();
        for (ProcessObjectWrapper obj : processObjectWrappers) {
            OpportunityLineItem ltm = (OpportunityLineItem)obj.processObj;
            oppNames.add(ltm.OpportunityId);
        }

        List<Opportunity> oppFromDB = [
                SELECT Id, Name, Pricebook2.Name, CurrencyIsoCode
                FROM Opportunity
                WHERE Name IN :oppNames
        ];

        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
        for (Opportunity opp : oppFromDB) {
            oppMap.put(opp.Name, opp);
        }

        return oppMap;
    }

    // product name , currencyIsoCode,  pricebook name
    private Map<String, Map<String, Map<String, PricebookEntry>>> getPricebookEntryMap(List<ProcessObjectWrapper> processObjectWrappers) {
        Set<String> prodNames = new Set<String>();
        for (ProcessObjectWrapper obj : processObjectWrappers) {
            OpportunityLineItem ltm = (OpportunityLineItem)obj.processObj;
            prodNames.add(ltm.Product2Id);
        }

        List<PricebookEntry> pricebookEntriesDB = [SELECT Id, Name, Product2.Name, Pricebook2.Name, CurrencyIsoCode FROM PricebookEntry WHERE Product2.Name IN :prodNames];

        Map<String, Map<String, Map<String, PricebookEntry>>> pricebookEntrieMap = new Map<String, Map<String, Map<String, PricebookEntry>>>(); // product name , currencyIsoCode,  pricebook name
        for (PricebookEntry prBook : pricebookEntriesDB) {
            if (!pricebookEntrieMap.containsKey(prBook.Product2.Name)) {
                pricebookEntrieMap.put(prBook.Product2.Name, new Map<String, Map<String, PricebookEntry>>());
            }

            if (!pricebookEntrieMap.get(prBook.Product2.name).containsKey(prBook.CurrencyIsoCode)) {
                pricebookEntrieMap.get(prBook.Product2.name).put(prBook.CurrencyIsoCode, new Map<String, PricebookEntry>());
            }

            pricebookEntrieMap.get(prBook.Product2.name).get(prBook.CurrencyIsoCode).put(prBook.Pricebook2.Name, prBook);
        }

        return pricebookEntrieMap;
    }*/
}