// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./SubsCryptView.sol";

contract SubsCryptProvider is SubsCryptView{

    function registerNewService(
        uint price,
        uint renewalPeriod
    ) external {
        require(price > 0, "Price must be greater than zero");
        require(renewalPeriod > 0, "Renewal period must be greater than zero");
        Service storage newService = AllServices[totalServices];
        newService.provider = msg.sender;
        newService.price = price;
        newService.renewalPeriod = renewalPeriod;
        newService.isActive = true;
        MyServices[msg.sender].push(totalServices);
        emit ServiceRegistered(msg.sender, totalServices, price, renewalPeriod);
        totalServices++;
    }

    function deactivateService(
        uint serviceId
    ) external onlyProvider(serviceId) {
        Service storage service = AllServices[serviceId];
        require(service.isActive, "Service is not active");
        service.isActive = false;
    }

    function collectFundsFromMyService(
        uint serviceId
    ) external onlyProvider(serviceId) {
        Service memory service = AllServices[serviceId];
        require(service.isActive, "Service is active");
        uint totalFundsCollected;
        for(uint i=0; i<service.subscriptionIDs.length; i++){
            Subscription storage subscription = AllSubscriptions[service.subscriptionIDs[i]];
            if(subscription.isActive && subscription.nextRenewal < block.timestamp){
                totalFundsCollected += service.price;
                subscription.nextRenewal += service.renewalPeriod;
                IERC20(CURRENCY_TOKEN).transferFrom(subscription.subscriber, service.provider, service.price);
            }
        }
        emit FundsCollectedByProvider(serviceId, totalFundsCollected);
    }

}