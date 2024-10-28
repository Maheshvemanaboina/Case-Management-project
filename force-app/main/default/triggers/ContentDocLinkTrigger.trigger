trigger ContentDocLinkTrigger on ContentDocumentLink (before insert) {

  /*  if(Trigger.IsBefore && Trigger.isInsert){  // Moved this code to Handler class
        for(ContentDocumentLink cnt : Trigger.New)
        {
            cnt.Visibility = 'AllUsers';
        }
        
    }*/
    
    ContentDocLinkHandler contentLink = new ContentDocLinkHandler();
    contentLink.process();
}