trigger TaskCaseUpdate on Task(before insert,before update) 
{
    for(Task s : Trigger.new)
    {
      String wId = s.WhatId;
     if(wId.startswith('500') && wId!=null){
        s.Case__c = s.whatid;
    }
    }
}