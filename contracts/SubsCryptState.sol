// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// a provider should be able to register new service
// a subscriber should be able to subscribe to a service
// a subscriber should be able to unsubscribe from a service
// a subscriber should be able to get the list of services he/she is subscribed to
// a provider should be able to get the list of subscribers to his/her service
// a provider should be able to get the list of services he/she is providing
// a subscriber should be able to get the list of providers of a service he/she is subscribed to

import "@openzeppelin/contracts/interfaces/IERC20.sol";

abstract contract SubsCryptState {

    address public CURRENCY_TOKEN;

    mapping (uint => Service) public AllServices;
    mapping (uint => Subscription) public AllSubscriptions;
    uint public totalSubscriptions;
    uint public totalServices;
    uint public feeCollected;

    mapping (address => uint[]) public MyServices;
    mapping (address => uint[]) public MySubscriptions;

    struct Subscription {
        address subscriber;
        uint serviceId;
        uint nextRenewal;
        bool isActive;
    }

    struct Service {
        address provider;
        uint price;
        uint renewalPeriod;
        uint[] subscriptionIDs;
        bool isActive;
    }

    modifier onlyProvider(uint serviceId) {
        require(AllServices[serviceId].provider == msg.sender, "Only provider can call this function");
        _;
    }

    modifier onlySubscriber(uint subscriptionId) {
        require(AllSubscriptions[subscriptionId].subscriber == msg.sender, "Only subscriber can call this function");
        _;
    }


    event ServiceRegistered(address indexed provider, uint indexed serviceId, uint price, uint renewalPeriod);
    event Subscribed(address indexed subscriber, uint indexed serviceId, uint indexed subscriptionId);

    event FundsCollectedByProvider(uint indexed serviceId, uint indexed amount);
    event SubscriptionProcesses(uint indexed serviceId, uint indexed amount, uint indexed fee);

}