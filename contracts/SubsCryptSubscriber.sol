// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./SubsCryptProvider.sol";

contract SubsCryptSubscriber is SubsCryptProvider{

    function subscribeTo (
        uint serviceId
    ) external payable {
        Service storage service = AllServices[serviceId];
        require(service.isActive, "Service is not active");
        require(!isSubscribedTo(serviceId, msg.sender), "Already subscribed");
        IERC20(CURRENCY_TOKEN).transferFrom(msg.sender, service.provider, service.price);
        AllSubscriptions[totalSubscriptions] = Subscription({
            subscriber: msg.sender,
            serviceId: serviceId,
            nextRenewal: block.timestamp + service.renewalPeriod,
            isActive: true
        });
        MySubscriptions[msg.sender].push(totalSubscriptions);
        AllServices[serviceId].subscriptionIDs.push(totalSubscriptions);
        totalSubscriptions++;
        emit Subscribed(msg.sender, serviceId, totalSubscriptions);
    }

    function deactivateSubscription (
        uint subscriptionId
    ) external onlySubscriber(subscriptionId) {
        Subscription storage subscription = AllSubscriptions[subscriptionId];
        require(subscription.isActive, "Subscription is not active");
        subscription.isActive = false;
    }

    function activateSubscription (
        uint subscriptionId
    ) external onlySubscriber(subscriptionId) {
        Subscription storage subscription = AllSubscriptions[subscriptionId];
        Service storage service = AllServices[subscription.serviceId];
        require(!subscription.isActive, "Subscription is already active");
        require(service.isActive, "Service is not active");
        subscription.isActive = true;
    }
}