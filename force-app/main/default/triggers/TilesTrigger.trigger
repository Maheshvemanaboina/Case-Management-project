trigger TilesTrigger on Tile__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  		TilesTriggerHandler tilesTrig = new TilesTriggerHandler(); 
        tilesTrig.process();
}