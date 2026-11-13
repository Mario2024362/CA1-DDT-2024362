// SPDX-License-Identifier: MIT
//Mario Gerardo Cornejo Martinez 2024362
pragma solidity ^0.8.19;

//the Booking to paid in the hotel
contract HotelBooking {

//The hotel rooms were added
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
//only the hotel can modified something
    modifier onlyHotel() {
        require(msg.sender == hotel, "Only the hotel can do this");
        _;
    }

    function addRoom(uint _price) public onlyHotel {
        require(_price > 0, "Price must be more than 0");
        roomCount++;
        rooms[roomCount] = Room(_price, true);
    }


//the data for the reservation
enum Status{Booked, Checked, Complete, Cancell}

struct Booking {
uint roomId; //room id to know if was booked
address guest; // the guest who paid
uint checkI; // the check in of the room
uint checkO;  //the check out
uint totalPrice;
Status status;  // the information of the booking

}

uint public bookingCount; //count the bookings
mapping(uint => Booking) public bookings;
//this won't allow any double book for rooms
mapping(uint=> mapping(uint => bool)) public nightBooked;


//Pay and reservation
function bookRoomt(uint _roomId, uint _checkI, uint _checkO) public payable{
 require(rooms[_roomId].exists, "This room is not exist");
        require(_checkO > _checkI, "Check-out must be after check-in");

//total of the price 

uint nights = _checkO - _checkI;
require(msg.value ==rooms[_roomId].price*nights, "something wrong was with the payment");

for(uint day = _checkI; day< _checkO; day++){

require(!nightBooked[_roomId] [day], "This room is already book");

nightBooked[_roomId] [day] = true;

}

//save the money 
bookingCount++;
bookings[bookingCount] = Booking(_roomId, msg.sender, _checkI, _checkO, msg.value, Status.Booked);

}

//Cancel and Refund
function cancelBooking(uint _bookingId) public{
Booking storage b = bookings[_bookingId]; 

require(b.guest == msg.sender, "This is not the booking you made");
 require(b.status == Status.Booked, " The booking can not be cancel");

// Change for the status to add more security 
b.status = Status.Cancell;

//free the space of the nights for the guests

for(uint day = b.checkI; day<b.checkO;day++){
nightBooked[b.roomId][day] = false;

}

(bool success, ) = payable(msg.sender).call{value: b.totalPrice}("");
require(success, "Refund has failed");

}

//Confirmation for the guest
function checkIn(uint _bookingId) public onlyHotel{
Booking storage b = bookings[_bookingId];

//This show if there is any error in the booking like not existing booking
require(b.guest !=address(0), "This booking not exist");
require(b.status ==Status.Booked, "Booking is not in state");

b.status = Status.Checked;

}   
//The confirmation of the stay is finish
function checkOut(uint _bookingId) public onlyHotel{
Booking storage b = bookings[_bookingId];

require(b.guest != address(0), "Booking was not found");
require(b.status == Status.Checked, "Guest has not check in");

b.status = Status.Complete;

//The money goes to the hotel
(bool success, ) = payable(hotel).call{value: b.totalPrice}("");
    require(success, "Payment to hotel failed");
}
}   














