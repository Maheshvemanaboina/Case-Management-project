/*      
@Name                  OpportunitySharingRecalculation
@Author                ?
@ModifiedBy            Carlo Volpi-carlo.volpi@kcsit.pt
@Version               1.1
@CreatedDate           ??-??-????
@UsedBy                Called directly from the anonymous window when needed by the Admin
@Description           Batch class to recalculate the opportunity sharing for partner users of all the partner record type opportunities
@Changes
UserId           | Author-Email                   | Date           | Comment
================|=======================|================|=========
XXXXXXXXXXXXXXX | Carlo Volpi-carlo.volpi@kcsit.pt | 01.02.2021 | Adjusted the OpportunitySharingUtility methods call
*/
global Without sharing class OpportunitySharingRecalculation implements Database.Batchable<SObject> {

    /* @Description

    Get all opportunities with Partner Opportunity record type Id to recalculate the sharing

    @param bc - Batch parameter

    @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        Id partnerOppRecordTypeId = Constants.OPPORTUNITY_RECORD_TYPE_PARTNER_OPPORTUNITY_ID;
        String Query = 'Select Id from Opportunity where RecordTypeId =: partnerOppRecordTypeId';
        return Database.getQueryLocator(Query);
    }

    /* @Description

    Delete the existing opportunity sharing records and recalculate the sharing

    @param bc - Batch parameter
    @param opportunityList - List of opportunities to consider

    @return void
    */
    global void execute(Database.BatchableContext bc, List<Opportunity> opportunityList){
        Set<Id> usersIds = (new Map<Id, User>(UserUtility.getAllCommunityUsers())).keySet();

        Set<Id> opportunitiesIds = (new Map<Id, Opportunity>(Opportunitylist)).keySet();

        OpportunitySharingUtility.deleteAllOpportunityRelatedSharing(usersIds, opportunitiesIds);
        OpportunitySharingUtility.createOpportunitySharing(opportunitiesIds);
    }

    /* @Description

    Send an email on finish

    @param bc - Batch parameter

    @return void
    */
    global void finish(Database.BatchableContext bc){
        Utilities.sendEmailOnBatchFinish('Opportunity Sharing Recalculation Batch', bc);
    }
}