// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./SubsCryptSubscriber.sol";

contract SubsCrypt is SubsCryptSubscriber, Ownable {

    
    constructor(address _currencyToken) Ownable(msg.sender)  {
        CURRENCY_TOKEN = _currencyToken;
    }

    function processSubscriptionsByService(uint serviceId) external onlyOwner {
        Service memory service = AllServices[serviceId];
        require(service.isActive, "Service is active");
        uint totalFundsCollected;
        for(uint i=0; i<service.subscriptionIDs.length; i++){
            Subscription storage subscription = AllSubscriptions[service.subscriptionIDs[i]];
            if(subscription.isActive && subscription.nextRenewal < block.timestamp){
                totalFundsCollected += service.price;
                subscription.nextRenewal += service.renewalPeriod;
                IERC20(CURRENCY_TOKEN).transferFrom(subscription.subscriber, address(this), service.price);
            }
        }
        uint fee = totalFundsCollected / 100 ; 
        feeCollected += fee;
        IERC20(CURRENCY_TOKEN).transferFrom(address(this), service.provider, totalFundsCollected - fee);
        emit SubscriptionProcesses(serviceId, totalFundsCollected - fee, fee);
    }

    function withdrawFee() external onlyOwner {
        IERC20(CURRENCY_TOKEN).transferFrom(address(this), msg.sender, feeCollected);
        feeCollected = 0;
    }

}