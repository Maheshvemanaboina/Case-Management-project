/*
@Author     : Rohit Kumar
@CreatedDate: 08-11-2021
@UsedBy     : ContentDocLinkTrigger (Trigger)
@Description: ContentDocumentLink Trigger Handler 

@History
  08-11-2021  Rohit Kumar : Created
*/
public class ContentDocLinkHandler extends TriggerHandler {

    public override void processBeforeInsert(){
        ContentDocLinkUpdateVisiblity.updateVisiblityOfLinkedContentToSObject((List<ContentDocumentLink>)trigger.new);
    }
}