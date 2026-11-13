from solcx import compile_source, install_solc
from web3 import Web3

#Mario Gerardo Cornejo Martinez 2024362
#Start the contract and open
install_solc("0.8.19")
code = open("contracts/HotelBooking.sol").read()
compiled = compile_source(code, output_values=["abi", "bin"],
                          solc_version="0.8.19", evm_version="paris")
_, contract = compiled.popitem()

# to make the conection with gatcha
w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545"))
hotel = w3.eth.accounts[0]    # first account will be the hotel
guest = w3.eth.accounts[1]    # second account is for the guest
other = w3.eth.accounts[2]    # third account another guest
PRICE = 100000000000000000    # 0.1 ETH per night in wei because ETH was not working

# send a transaction as 
def send(function, account, value=0):
    tx = function.transact({"from": account, "value": value})
    w3.eth.wait_for_transaction_receipt(tx)

#transcation reject by the contract
def must_fail(name, function, account, value=0):
    try:
        function.transact({"from": account, "value": value})
        print("ERROR:", name, "should fail")
    except Exception:
        print("OK:", name, "-> rejected")

# Deploy the contract
Hotel = w3.eth.contract(abi=contract["abi"], bytecode=contract["bin"])
tx = Hotel.constructor().transact({"from": hotel})
address = w3.eth.wait_for_transaction_receipt(tx).contractAddress
hb = w3.eth.contract(address=address, abi=contract["abi"])
print("Contract deployed at", address)

# only the hotel adds a room
send(hb.functions.addRoom(PRICE), hotel)
must_fail("guest adds a room", hb.functions.addRoom(PRICE), guest)

# The guest books 2 nights 
send(hb.functions.bookRoomt(1, 1, 3), guest, 2 * PRICE)
print("Booking 1:", hb.functions.bookings(1).call())

# These must fail
must_fail("double booking", hb.functions.bookRoomt(1, 2, 4), other, 2 * PRICE)
must_fail("wrong payment", hb.functions.bookRoomt(1, 5, 6), guest, 1)
must_fail("cancel someone  booking", hb.functions.cancelBooking(1), other)

#  Full stay data
before = w3.eth.get_balance(hotel)
send(hb.functions.checkIn(1), hotel)
send(hb.functions.checkOut(1), hotel)
after = w3.eth.get_balance(hotel)
print("Hotel received", after - before)

# Cancellation with refund
send(hb.functions.bookRoomt(1, 10, 11), guest, PRICE)
send(hb.functions.cancelBooking(2), guest)
print("Booking 2 status (3 = Cancell):", hb.functions.bookings(2).call()[5])
