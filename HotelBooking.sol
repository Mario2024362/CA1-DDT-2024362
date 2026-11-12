// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HotelBooking {

    address public hotel;
    uint public roomCount;

    struct Room {
        uint price;
        bool exists;
    }
     mapping(uint => Room) public rooms;

    constructor() {
        hotel = msg.sender;
    }

    modifier onlyHotel() {
        require(msg.sender == hotel, "Only the hotel can do this");
        _;
    }

    function addRoom(uint _price) public onlyHotel {
        require(_price > 0, "Price must be more than 0");
        roomCount++;
        rooms[roomCount] = Room(_price, true);
    }
}
