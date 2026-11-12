// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HotelBooking {

    address public hotel;
    uint public roomCount;

    struct Room {
        uint price;
        bool exists;
    }
}