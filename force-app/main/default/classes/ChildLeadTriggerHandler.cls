public class ChildLeadTriggerHandler extends TriggerHandler {
	public override void processAfterInsert(){
        for(Child_Lead__c currentRecord : ((map<ID,Child_Lead__c>)trigger.newMap).values()){
            
              if(currentRecord.Sub_Segment__c == Constants.CHILD_LEAD_SUB_SEGMENT){
                ChildLeadRouting.assignLeadOwner((map<ID,Child_Lead__c>)trigger.newMap,null);
            } else {
                ChildLeadRouting.assignLeadOwner((map<ID,Child_Lead__c>)trigger.newMap);
            }
        }
        
        BulkUploadChildLeads.addLeadOrContactToTheCampaign((List<Child_Lead__c>)trigger.new);
        ChildLeadSharingUtility.recalculateChildLeadSharingOnInsert((List<Child_Lead__c>)trigger.new);
    }
    
    public override void processBeforeInsert(){
        BulkUploadChildLeads.duplicateCheck((List<Child_Lead__c>)trigger.new);
    }
    
    public override void processAfterUpdate(){
        ChildLeadRouting.assignLeadOwner((map<ID,Child_Lead__c>)trigger.newMap,(map<ID,Child_Lead__c>)trigger.oldMap);
        ChildLeadSharingUtility.recalculateChildLeadSharingOnUpdate((List<Child_Lead__c>)trigger.new);
    }
}