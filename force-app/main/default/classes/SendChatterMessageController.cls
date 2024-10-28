/**
 * Created by KJM on 27/06/2019.
 */

public with sharing class SendChatterMessageController {

    @AuraEnabled
    public static String sendDirectChatterMessage(String personName, String subject, String message) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = message;

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;

        User usr = getUserToWhichSend(personName);
        if (usr == null) {
            throw new SendChatterMessageControllerException('Cannot send message to this user');
        }

        List<String> memberIds = new List<String>{
            usr.Id
        };

        ConnectApi.DirectMessageCapabilityInput dmInput = new ConnectApi.DirectMessageCapabilityInput();
        dmInput.subject = subject;
        dmInput.membersToAdd = memberIds;

        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        feedElementCapabilitiesInput.directMessage = dmInput;

        feedItemInput.capabilities = feedElementCapabilitiesInput;

        if (Test.isRunningTest()) {
            ConnectApi.ChatterFeeds.postFeedElement([SELECT Id FROM Network WHERE Name = 'FC Distributor Community'].get(0).Id, feedItemInput);
        } else {
            ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        }

        return '';
    }

    @AuraEnabled
    public static Boolean isChatterAvailableForUser(String personName) {
        return getUserToWhichSend(personName) != null ? true : false;
    }

    public static User getUserToWhichSend(String personName) {
        Id networkId = Network.getNetworkId();
        if (Test.isRunningTest()) { networkId = [SELECT Id FROM Network WHERE Name = 'FC Distributor Community'].get(0).Id; }

        List<NetworkMember> networkMembers = [SELECT Id, NetworkId, MemberId, Member.Name FROM NetworkMember WHERE NetworkId = :networkId AND Member.Name = :personName];
        if (networkMembers.isEmpty()) {
            return null;
        }

        List<User> users = [SELECT Id FROM User WHERE Id = :networkMembers.get(0).MemberId];
        if (users.isEmpty()) {
            return null;
        }

        return users.get(0);
    }

    private class SendChatterMessageControllerException extends Exception {}
}