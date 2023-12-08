// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./SubsCryptState.sol";

contract SubsCryptView is SubsCryptState {
    function getTotalServicesOf(address _provider) external view returns (uint) {
        return MyServices[_provider].length;
    }

    function getTotalSubscriptionOf(address _subscriber) external view returns (uint) {
        return MySubscriptions[_subscriber].length;
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

    // function getCollectableFundsFor(uint serviceId) external view onlyProvider(serviceId) returns (uint) {
    //     Service storage service = AllServices[serviceId];
    //     require(!service.isActive, "Service is active");
    //     return service.totalSubscribers * service.price;
    // }

}