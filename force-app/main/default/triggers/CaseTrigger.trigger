trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    CaseTriggerHandler CaseTrig = new CaseTriggerHandler();
    CaseTrig.process();
    if(trigger.isUpdate && Trigger.isAfter)
    {
        //create a map of open tasks related to the cases
        Map<Id, Task> taskMap = new Map<Id, Task>();
        
        //query open tasks related to cases and populate map
        for(Task t : [SELECT Id, WhatId FROM Task WHERE IsClosed=false AND WhatId IN :trigger.newMap.keySet()])
        {
            taskMap.put(t.WhatId, t);
            System.debug('@@@@@@'+taskMap);
        }
        
        //iterate through updated cases and add errors if open tasks exist
        for(Case c : Trigger.new)
        {
            //check if the case has any open tasks and has just been changed to closed
            if(taskMap.containsKey(c.Id) && c.IsClosed && c.IsClosed != Trigger.oldMap.get(c.Id).IsClosed)
                c.addError('Please complete your pending tasks');
        }
    }
    /*if(trigger.isInsert && Trigger.isAfter)
    {
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QA_SALES').getRecordTypeId();
        if(Trigger.new[0].recordtypeid == devRecordTypeId){
            Datetime dt = trigger.new[0].createdDate;
            String min = String.valueOf(dt.minute()+1);
            String hour = String.valueOf(dt.hour());
            String day = String.valueof(dt.day());
            String mon = String.valueOf(dt.month());
            String name = Trigger.new[0].CaseNumber;
            Datetime dt1 = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
            String dayOfWeek=dt1.format('EEEE').substring(0,3).toUpperCase();
            System.debug('Day : ' + dayOfWeek);
            ScheduleUpdate m = new ScheduleUpdate(trigger.new);
            String sch = '0 '+min+' '+hour+' '+day+' '+mon+' '+'?';
            System.debug('sch val '+sch);
            String jobID = system.schedule(name+system.now(), sch, m);
        }
    } */
}