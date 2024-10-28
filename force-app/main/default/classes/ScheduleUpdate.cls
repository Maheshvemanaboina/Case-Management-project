global without sharing class ScheduleUpdate implements Schedulable {
    global list<Case> updcaselist = new List<case>();
    global ScheduleUpdate(List<case> caselist)
    {
        updcaselist = caselist;
    }
   global void execute(SchedulableContext SC) {
      //mergeNumbers M = new mergeNumbers(); 
      //
      List<case> updlist = new List<case>();
      for(Case c : updcaselist)
      {
          if(c.checkbox__c == false){
          Case c1 = new case(id=c.id,checkbox__c=c.Checkbox__c);
          c1.checkbox__c = true;
          updlist.add(c1);
          }
      }
       if(!updlist.isempty()){
       update updlist;
       }
   }
}