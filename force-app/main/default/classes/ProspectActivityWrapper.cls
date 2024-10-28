public class ProspectActivityWrapper {
    public class Campaign {
        @AuraEnabled public String salesforceId;
    }
    @AuraEnabled public List<Values> values;
    @AuraEnabled public String nextPageToken;
    @AuraEnabled public DateTime createdDate;
    
    public class Values {
        @AuraEnabled public String Id;
        @AuraEnabled public Campaign campaign;
        @AuraEnabled public Integer campaignId;
        @AuraEnabled public String details;
        @AuraEnabled public Integer prospectId;
        @AuraEnabled public String typeName;
        @AuraEnabled public String updatedAt;
    }
    public ProspectActivityWrapper jsonToObject(String json) {
        return (ProspectActivityWrapper) System.JSON.deserialize(json, ProspectActivityWrapper.class);
    }
}