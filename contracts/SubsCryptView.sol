// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./SubsCryptState.sol";

contract SubsCryptView is SubsCryptState {
    function getTotalServicesOf(address _provider) external view returns (uint) {
        return MyServices[_provider].length;
    }

    function getTotalSubscriptionsOf(address _subscriber) external view returns (uint) {
        return MySubscriptions[_subscriber].length;
    }

    function getTotalSubscribersOf(uint serviceId) external view returns (uint) {
        return AllServices[serviceId].subscriptionIDs.length;
    }

    function getAllMyServiceIds(address _provider) external view returns (uint[] memory) {
        return MyServices[_provider];
    }

    function getAllMySubscriptionIds(address _subscriber) external view returns (uint[] memory) {
        return MySubscriptions[_subscriber];
    }

    function getSubscription(address subscriber, uint serviceId) external view returns(
        uint subscriptionId,
        uint nextRenewal,
        bool isActive
    ) {
        uint[] memory mySubscriptions = MySubscriptions[subscriber];
        for (uint i = 0; i < mySubscriptions.length; i++) {
            if (serviceId == AllSubscriptions[mySubscriptions[i]].serviceId) {
                Subscription memory subscription = AllSubscriptions[mySubscriptions[i]];
                return (mySubscriptions[i], subscription.nextRenewal, subscription.isActive);
            }
        }
    }

    function isSubscribedTo(uint serviceId, address subscriber) public view returns (bool) {
        uint[] memory mySubscriptions = MySubscriptions[subscriber];
        for (uint i = 0; i < mySubscriptions.length; i++) {
            if (serviceId == mySubscriptions[i]) {
                return true;
            }
        }
        return false;
    }

    function getActiveSubscribersOf(uint serviceId) external view returns (address[] memory) {
        Service memory service = AllServices[serviceId];
        address[] memory activeSubscribers = new address[](service.subscriptionIDs.length);
        uint activeSubscribersCount = 0;
        for (uint i = 0; i < service.subscriptionIDs.length; i++) {
            Subscription memory subscription = AllSubscriptions[service.subscriptionIDs[i]];
            if (subscription.isActive) {
                activeSubscribers[activeSubscribersCount] = subscription.subscriber;
                activeSubscribersCount++;
            }
        }
        address[] memory result = new address[](activeSubscribersCount);
        for (uint i = 0; i < activeSubscribersCount; i++) {
            result[i] = activeSubscribers[i];
        }
        return result;
    }

    function getActiveSubscriberCount(uint serviceId) external view returns (uint count) {
        Service memory service = AllServices[serviceId];
        for(uint i = 0; i < service.subscriptionIDs.length ; i++) {
            Subscription memory subscription = AllSubscriptions[service.subscriptionIDs[i]];
            if(subscription.isActive) {
                count++;
            }
        }
    }

    function getCollectableFundsOf(uint serviceId) external view returns (uint collectableFunds) {
        Service memory service = AllServices[serviceId];
        for(uint i = 0; i < service.subscriptionIDs.length ; i++) {
            Subscription memory subscription = AllSubscriptions[service.subscriptionIDs[i]];
            if(subscription.isActive && subscription.nextRenewal < block.timestamp){
                uint periodsPassed = (block.timestamp - subscription.nextRenewal) / service.renewalPeriod;
                collectableFunds += service.price * periodsPassed;
            }
        }
    }

}