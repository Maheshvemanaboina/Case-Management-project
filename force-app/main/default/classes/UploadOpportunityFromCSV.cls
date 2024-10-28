/*************************************************************** KJM - 09/04/2019
 Name: UploadOpportunityFromCSV
 ======================================================
 Purpose: Class used for upload opportunities from csv
 ======================================================
***************************************************************/
public with sharing class UploadOpportunityFromCSV extends UploadObjectFromCSV{

    private final String objectName = Constants.OBJECT_NAME_OPPORTUNITY;

    // map of data values into csv file
    public static final Map<Integer, String> csvFileObjFieldMap = new Map<Integer,String> {
            0 => Opportunity.Name.getDescribe().getName(),
            1 => Opportunity.End_Customer__c.getDescribe().getName(),////Customer__c
            2 => Opportunity.OwnerId.getDescribe().getName(),
            3 => Opportunity.Distributor_Sales_Manager__c.getDescribe().getName(),
            4 => Opportunity.Business_Segment__c.getDescribe().getName(),
            5 => Opportunity.Sub_Segment__c.getDescribe().getName(),    
            6 => Opportunity.Opportunity_Application__c.getDescribe().getName(),
            7 => Opportunity.Customer_Need__c.getDescribe().getName(),    
            8 => Opportunity.Probability.getDescribe().getName(),
            9 => Opportunity.CloseDate.getDescribe().getName(),
            10 => Opportunity.CurrencyIsoCode.getDescribe().getName(),
            11 => Opportunity.Products_Description__c.getDescribe().getName(),
            12 => Opportunity.Total_volume_per_deal__c.getDescribe().getName()

    };

    // map of data values fetch into logic and insert to system
    public static final Map<Integer, String> csvIndexObjFieldMap = new Map<Integer,String>{
      
            0 => Opportunity.Name.getDescribe().getName(),
            1 => Opportunity.End_Customer__c.getDescribe().getName(),////Customer__c
            2 => Opportunity.OwnerId.getDescribe().getName(),
            3 => Opportunity.Distributor_Sales_Manager__c.getDescribe().getName(),
            4 => Opportunity.Business_Segment__c.getDescribe().getName(),
            5 => Opportunity.Sub_Segment__c.getDescribe().getName(),    
            6 => Opportunity.Opportunity_Application__c.getDescribe().getName(),
            7 => Opportunity.Customer_Need__c.getDescribe().getName(),    
            8 => Opportunity.Probability.getDescribe().getName(),
            9 => Opportunity.CloseDate.getDescribe().getName(),
            10 => Opportunity.CurrencyIsoCode.getDescribe().getName(),
            11=> Opportunity.Products_Description__c.getDescribe().getName(),
            12=> Opportunity.Total_volume_per_deal__c.getDescribe().getName(),
            13=> Opportunity.RecordTypeId.getDescribe().getName()    
      		
    };

    private final Set<String> mandatoryToValidate = new Set<String> {
            Opportunity.Name.getDescribe().getName(),
            Opportunity.End_Customer__c.getDescribe().getName(),//Customer__c
            Opportunity.OwnerId.getDescribe().getName(),
            Opportunity.Customer_Need__c.getDescribe().getName(),
            Opportunity.Description.getDescribe().getName(),
            Opportunity.CurrencyIsoCode.getDescribe().getName(),
            Opportunity.Products_Description__c.getDescribe().getName(),
            Opportunity.Total_volume_per_deal__c.getDescribe().getName(),
            Opportunity.RecordTypeId.getDescribe().getName(),
            Opportunity.Distributor_Sales_Manager__c.getDescribe().getName()
    };

    private final Set<String> datesToValidate = new Set<String>{
            Opportunity.CloseDate.getDescribe().getName()
    };
        
	private final Set<String> decimalToValidate = new Set<String>{
            Opportunity.Probability.getDescribe().getName()
    };
    private final Set<String> picklistToValidate = new Set<String>{
            Opportunity.Business_Segment__c.getDescribe().getName(),
            Opportunity.Sub_Segment__c.getDescribe().getName(),    
            Opportunity.Opportunity_Application__c.getDescribe().getName()
    };
    
    private final Set<String> stageNameToValidate = new Set<String>{
            Opportunity.StageName.getDescribe().getName()
    };    
        
    private final Map<String, String> fieldsForChangeFromNameToId = new Map<String, String> {
            Opportunity.End_Customer__c.getDescribe().getName() => Constants.OBJECT_NAME_ACCOUNT,//Customer__c
            Opportunity.RecordTypeId.getDescribe().getName() => Constants.OBJECT_NAME_RECORD_TYPE,
            Opportunity.OwnerId.getDescribe().getName() => Constants.OBJECT_NAME_USER,
            Opportunity.Distributor_Sales_Manager__c.getDescribe().getName() => Constants.OBJECT_NAME_CONTACT
    };

    private final Set<String> exceptionsForDisplayToUser = new Set<String> {
            Opportunity.RecordTypeId.getDescribe().getName()
    };
    
        
        
    public UploadOpportunityFromCSV(List<String> dataToProcess) {
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

    public override Set<String> getDatesToValidate() {
        return datesToValidate;
    }
    
    public override Set<String> getDecimalToValidate() {
        return decimalToValidate;
    }
     
    public override Set<String> getPicklistToValidate() {
        return picklistToValidate;
    }
    
     public override Set<String> getStageNameToValidate() {
        return stageNameToValidate;
    }

    public override Map<String, String> getFieldsForChangeFromNameToIds() {
        return fieldsForChangeFromNameToId;
    }
    

    public override Map<String, Set<String>> getFieldValuesToValidate() {
        Map<String, Set<String>> fieldValuesToValidate = new Map<String, Set<String>>();

        /*fieldValuesToValidate.put(Opportunity.StageName.getDescribe().getName(), new Set<String>());
        for (Schema.PicklistEntry pickListEnt : Opportunity.StageName.getDescribe().getPicklistValues()){
            fieldValuesToValidate.get(Opportunity.StageName.getDescribe().getName()).add(pickListEnt.getValue());
        }*/

        fieldValuesToValidate.put(Opportunity.CurrencyIsoCode.getDescribe().getName(), new Set<String>());
        for (Schema.PicklistEntry pickListEnt : Opportunity.CurrencyIsoCode.getDescribe().getPicklistValues()){
            fieldValuesToValidate.get(Opportunity.CurrencyIsoCode.getDescribe().getName()).add(pickListEnt.getValue());
        }

        return fieldValuesToValidate;
    }

    public override Set<Integer> getDuplicateObjectIndexes(List<SObject> objsToCheck) {
        Set<Integer> duplicatesIndexes = new Set<Integer>();
        Set<String> oppsNames = new Set<String>();
        for (Opportunity opp : (List<Opportunity>)objsToCheck){
            oppsNames.add(opp.Name);
        }

        List<Opportunity> opps = DAOUtilityWithoutShar.getAllOpportunitiesByNameForDuplicates(oppsNames, UserUtility.getCurrentUserContact().Parent_Account__c);
        if (opps.isEmpty()) {
            return new Set<Integer>();
        }

        Set<String> duplicatesName = new Set<String>();
        for (Opportunity opp : opps) {
            duplicatesName.add(String.valueOf(opp.Name).toLowerCase());
        }

        for (Integer i = 0; i < objsToCheck.size(); i++){
            if (duplicatesName.contains((String.valueOf(objsToCheck[i].get(Constants.NAME_FIELD_NAME))).toLowerCase())) {
                duplicatesIndexes.add(i);
            }
        }

        return duplicatesIndexes;
    }
}