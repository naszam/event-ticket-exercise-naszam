pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";
import "./Proxy.sol";

contract TestEventTicket {

  // test for failing conditions in those contracts:
  uint public initialBalance = 1 ether;

  EventTickets public chain;
  EventTicketsV2 public chain2;
  Proxy public ownerProxy;
  Proxy public buyerProxy;

  string description = "description";
  string url = "URL";
  uint256 ticketNumber = 100;
  uint256 ticketPrice = 100;

  // allow contract to receive ether
  function () external payable {}

  function beforeEach() public {

    // contract to test
    chain = new EventTickets(description, url, ticketNumber);
    ownerProxy = new Proxy(chain);
    buyerProxy = new Proxy(chain);

    // seed buyers with some funds (in WEI)
    uint256 seedValue = (ticketPrice + 1) * ticketNumber;
    address(buyerProxy).transfer(seedValue);
  }

  function getEventDetails()
    public view
    returns (string memory, string memory, uint256, uint256, bool)
  {
    string memory description;
    string memory website;
    uint256 totalTickets;
    uint256 sales;
    bool isOpen;

    (description, website, totalTickets, sales, isOpen) = chain.readEvent();
    return (description, website, totalTickets, sales, isOpen);
  }

  // buyTickets
  // test for purchasing a ticket when the event is open
  function testPurchasingTicketEventOpen()
    public
  {
      uint256 offer = ticketPrice*10;
      bool result = buyerProxy.purchaseTickets(10, offer);
      Assert.isTrue(result, "Paid the correct price");

      ( , , , uint256 sales, ) = getEventDetails();
      Assert.equal(sales, 10, "The ticket sales should be 10");
  }

  // buyTickets
  // test for failure is buyer does not send enough funds`
  function testForFailureIfBuyerDoesNotSendEnoughFunds()
    public
  {
      uint256 offer = ticketPrice - 1;
      bool result = buyerProxy.purchaseTickets(1, offer);
      Assert.isFalse(result, "Tickets should only be able to be purchased when the msg.value is grater than or equal to the ticket cost");
  }

  // buyTickets
  // test for failure if buyer try to buy more tickets than are available
  function testForFailureIfBuyerBuyMoreTicketsThanAvailable()
    public
  {
      uint256 offer = ticketPrice*101;
      bool result = buyerProxy.purchaseTickets(101, offer);
      Assert.isFalse(result, "Tickets should only be able to be purchased when there are enough remaining");
  }

  // getRefund
  // test for buyer receiving the right amount when submitting a refund
  function testForSuccessWhenBuyerSubmitRefund()
    public
  {
    uint256 offer = ticketPrice*10;
    bool result = buyerProxy.purchaseTickets(10, offer);
    Assert.isTrue(result, "Paid the correct price");

    result = buyerProxy.getRefund();
    Assert.isTrue(result, "Buyers should be refunded the appropriate value amount when submitting a refund");

    ( , , uint256 totalTickets, , ) = getEventDetails();
    Assert.equal(totalTickets,ticketNumber, "Total Tickets should be 100");
  }
/*
  // endSale
  // test for failure if buyer try to buy tickets when the event is not open
  function testForFailureIfBuyerBuyTicketsEndSale()
    public
  {
    bool result = ownerProxy.endSale();
    Assert.isTrue(result, "Only owner should be able to end the tickets sale");

    ( , , , , bool isOpen) = getEventDetails();
    Assert.notEqual(isOpen, true, "The event sale should be close");

    uint256 offer = ticketPrice*10;
    result = buyerProxy.purchaseTickets(10, offer);
    Assert.isFalse(result, "Buyer should not be able to buy tickets when the event is not open");
  }
 */

}
