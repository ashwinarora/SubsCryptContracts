// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SubsCryptSubscriber.sol";

contract SubsCrypt is SubsCryptSubscriber, Ownable {

    constructor(address _currencyToken) Ownable(msg.sender)  {
        CURRENCY_TOKEN = _currencyToken;
    }

    function processSubscriptionsByService(uint serviceId) public onlyOwner {
        Service memory service = AllServices[serviceId];
        require(service.isActive, "Service is active");
        uint totalFundsCollected;
        for(uint i=0; i<service.subscriptionIDs.length; i++){
            Subscription storage subscription = AllSubscriptions[service.subscriptionIDs[i]];
            if(subscription.isActive && subscription.nextRenewal < block.timestamp){
                uint periodsPassed = (block.timestamp - subscription.nextRenewal) / service.renewalPeriod;
                uint priceToAdd = service.price * periodsPassed;
                totalFundsCollected += priceToAdd;
                subscription.nextRenewal += periodsPassed * service.renewalPeriod;
                IERC20(CURRENCY_TOKEN).transferFrom(subscription.subscriber, address(this), priceToAdd);
            }
        }
        uint fee = totalFundsCollected / 100 ; 
        feeCollected += fee;
        IERC20(CURRENCY_TOKEN).transferFrom(address(this), service.provider, totalFundsCollected - fee);
        emit SubscriptionProcesses(serviceId, totalFundsCollected - fee, fee);
    }

    function withdrawFee(address _receiver) external onlyOwner {
        IERC20(CURRENCY_TOKEN).transferFrom(address(this), _receiver, feeCollected);
        feeCollected = 0;
    }

    function processMultipleServices(uint[] memory serviceIds) external onlyOwner {
        for(uint i=0; i < serviceIds.length ; i++) {
            processSubscriptionsByService(serviceIds[i]);
        }
    }

}