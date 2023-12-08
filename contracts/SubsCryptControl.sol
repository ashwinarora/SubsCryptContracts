// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./SubsCryptView.sol";

contract SubsCryptControl is SubsCryptView{

    function registerNewService(
        uint price,
        uint renewalPeriod
    ) external {
        require(price > 0, "Price must be greater than zero");
        require(renewalPeriod > 0, "Renewal period must be greater than zero");
        AllServices[totalServices] = Service({
            provider: msg.sender,
            price: price,
            renewalPeriod: renewalPeriod,
            totalSubscribers: 0,
            isActive: true
        });
        totalServices++;
        MyServices[msg.sender].push(totalServices);
        emit ServiceRegistered(msg.sender, totalServices, price, renewalPeriod);
    }

    function subscribeTo (
        uint serviceId
    ) external payable {
        Service storage service = AllServices[serviceId];
        require(service.isActive, "Service is not active");
        IERC20(CURRENCY_TOKEN).transferFrom(msg.sender, service.provider, service.price);
        AllSubscriptions[totalSubscriptions] = Subscription({
            serviceId: serviceId,
            nextRenewal: block.timestamp + service.renewalPeriod,
            isActive: true
        });
        totalSubscriptions++;
        MySubscriptions[msg.sender].push(totalSubscriptions);
        service.totalSubscribers++;
        emit Subscribed(msg.sender, serviceId, totalSubscriptions);
    }
}