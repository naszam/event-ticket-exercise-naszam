pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";

contract Proxy {

	// the proxied EventTicket contract
	EventTickets public eventTickets;

	/// @notice Create a Proxy
	/// @param _target the EventTicket to interact with
	constructor(EventTickets _target) public {
		eventTickets = _target;
	}

	/// Allow contract to receive ether
	function() external payable {}

	/// @notice Retrieve supplyChain contract
	/// @return the supplyChain contract
	function getTarget()
			public view
			returns (EventTickets)
		{
			return eventTickets;
		}
		/// @notice verify owner
		function isOwner()
			public
			returns (bool)
		{
			(bool success, ) = address(eventTickets).call(abi.encodeWithSignature("isOwner()"));
			return success;
		}

		/// @notice buy tickets
		/// @param tickets number of tickets to buy
		/// @param offer the price payed by the buyer
		function purchaseTickets(uint256 tickets, uint256 offer)
			public
			returns (bool)
		{
			// Use call.value to invoke 'supplyChain.buyItem(sku)'
			// with msg.sender set to the address of this proxy and value is set to 'offer'
			(bool success, ) = address(eventTickets).call.value(offer)(abi.encodeWithSignature("buyTickets(uint256)", tickets));
			return success;
		}

    /// @notice get refund
		function getRefund()
			public
			returns (bool)
		{
			(bool success, ) = address(eventTickets).call(abi.encodeWithSignature("getRefund()"));
			return success;
		}

		/// @notice close the ticket sale
		function endSale()
			public
			returns (bool)
		{
			(bool success, ) = address(eventTickets).call(abi.encodeWithSignature("endSale()"));
			return success;
		}
}
