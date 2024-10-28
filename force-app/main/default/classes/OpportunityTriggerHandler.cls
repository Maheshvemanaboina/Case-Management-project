/*      
@Name                  OpportunityTriggerHandler
@Author                ?
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               1.1
@CreatedDate           ??-??-????
@UsedBy                OpportunityTrigger
@Description           Handler class to manage opportunity trigger developments run order
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 03.03.2021 | Adjusted to call the OpportunitySharingUtility methods with new signatures
*/
public with sharing class OpportunityTriggerHandler extends TriggerHandler {
	/* @Description

    Method to populate source opportunity on cloned opportunities

    @return void
    */
    public override void processBeforeInsert(){

        OpportunityClone.linkSourceOpportunity((List<Opportunity>)trigger.new);
    }

    
    /* @Description

    Method to manage developments order in after insert opportunity trigger

    @return void
    */
    public override void processAfterInsert(){

        OpportunitySharingUtility.recalculateOpportunitySharingOnCreate((List<Opportunity>)trigger.new);
        OpportunityClone.linkClonedOpportunity((List<Opportunity>)trigger.new);
    }

    /* @Description

    Method to manage developments order in after update opportunity trigger

    @return void
    */
    public override void processAfterUpdate(){

        OpportunitySharingUtility.recalculateOpportunitySharingOnUpdate((List<Opportunity>)trigger.new, UserUtility.getAllFilteredCommunityUsers((List<Opportunity>)trigger.new));
    }
    
    /* @Description

    Method to manage Campaigns in before update opportunity trigger

    @return void
    */
    public override void processBeforeUpdate(){
        OpportunityCampaign.updateCampaign((List<Opportunity>)trigger.new);
    }
}