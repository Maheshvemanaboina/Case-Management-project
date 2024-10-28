public without sharing class TilesTriggerHandler  extends TriggerHandler {
	 
    public override void processAfterUpdate(){
        
        if(!RecursionHandler.isLeadTrigAfterUpdateRecursive){            
            RecursionHandler.isLeadTrigAfterUpdateRecursive = true;
            system.debug('sending emails');
            SendNotificationToPortalUsers.sendEmailOnTileUpdate((List<Tile__c>)trigger.new,(Map<Id,Tile__c>)trigger.oldMap);
        	RecursionHandler.isLeadTrigAfterUpdateRecursive = false;
        }
    }
    
     public override void processAfterInsert(){
         SendNotificationToPortalUsers.sendEmailOnTileCreate((List<Tile__c>)trigger.new);
     }
   /*B2B-315*/ 
    public override void processBeforeDelete() {
        RecursionHandler.isLeadTrigAfterUpdateRecursive = true;
        Id profileId=userinfo.getProfileId();
        String currentProfileName = [Select Id,Name from Profile where Id=:profileId].Name;  
        List<String> profileHasMassDeleteAccess = System.label.Delete_Tile_Access.split(',');
        if (!profileHasMassDeleteAccess.contains(currentProfileName) && Trigger.old.size() > 1) {
            for (Tile__c tile : (List<Tile__c>) Trigger.old) {
                tile.addError('You cannot delete more than 1 Tile record at a time.');
            }
        }
    }
	/*B2B-315*/
}