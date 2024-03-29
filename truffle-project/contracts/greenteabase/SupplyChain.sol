pragma solidity ^0.4.24;

import "../greenteacore/Ownable.sol";
import "../greenteaaccesscontrol/ConsumerRole.sol";
import "../greenteaaccesscontrol/RetailerRole.sol";
import "../greenteaaccesscontrol/FarmerRole.sol";

// Define a contract 'Supplychain'
contract SupplyChain is ConsumerRole, FarmerRole, RetailerRole {

  // Define 'owner'
  address owner;

  // Define a variable called 'upc' for Universal Product Code (UPC)
  uint  upc;

  // Define a variable called 'sku' for Stock Keeping Unit (SKU)
  uint  sku;

  // Define a public mapping 'items' that maps the UPC to an Item.
  mapping (uint => Item) items;

  // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
  // that track its journey through the supply chain -- to be sent from DApp.
  mapping (uint => string[]) itemsHistory;
  
  // Define enum 'State' with the following values:
  enum State 
  { 
    Harvested,  // 0
    Steamed,  // 1
    DriedOut,     // 2
    ForSale,    // 3
    Sold,       // 4
    Shipped,    // 5
    Received,   // 6
    Purchased   // 7
  }

  State constant defaultState = State.Harvested;

  // Define a struct 'Item' with the following fields:
  struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC), generated by the Farmer, goes on the package, can be verified by the Consumer
    address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 8 stages
    address originFarmerID; // Metamask-Ethereum address of the Farmer
    string  originFarmName; // Farmer Name
    string  originFarmInformation;  // Farmer Information
    string  originFarmLatitude; // Farm Latitude
    string  originFarmLongitude;  // Farm Longitude
    uint    productID;  // Product ID potentially a combination of upc + sku
    string  productNotes; // Product Notes
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address distributorID;  // Metamask-Ethereum address of the Distributor
    address retailerID; // Metamask-Ethereum address of the Retailer
    address consumerID; // Metamask-Ethereum address of the Consumer
  }

  // Define 8 events with the same 8 state values and accept 'upc' as input argument
  event Harvested(uint upc);
  event Steamed(uint upc);
  event DriedOut(uint upc);
  event ForSale(uint upc);
  event Sold(uint upc);
  event Shipped(uint upc);
  event Received(uint upc);
  event Purchased(uint upc);

  // Define a modifer that checks to see if msg.sender == owner of the contract
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Define a modifer that verifies the Caller
  modifier verifyCaller (address _address) {
    require(msg.sender == _address); 
    _;
  }

  // Define a modifier that checks if the paid amount is sufficient to cover the price
  modifier paidEnough(uint _price) { 
    require(msg.value >= _price); 
    _;
  }
  
  // Define a modifier that checks the price and refunds the remaining balance
  modifier checkValue(uint _upc) {
    _;
    uint _price = items[_upc].productPrice;
    uint amountToReturn = msg.value - _price;
    items[_upc].consumerID.transfer(amountToReturn);
  }

  // Define a modifier that checks if an item.state of a upc is Harvested
  modifier harvested(uint _upc) {
    require(items[_upc].itemState == State.Harvested);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Processed
  modifier steamed(uint _upc) {
    require(items[_upc].itemState == State.Steamed);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Packed
  modifier driedOut(uint _upc) {
    require(items[_upc].itemState == State.DriedOut);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is ForSale
  modifier forSale(uint _upc) {
    require(items[_upc].itemState == State.ForSale, "forSale modifier");
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Sold
  modifier sold(uint _upc) {
    require(items[_upc].itemState == State.Sold);
    _;
  }
  
  // Define a modifier that checks if an item.state of a upc is Shipped
  modifier shipped(uint _upc) {
    require(items[_upc].itemState == State.Shipped);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Received
  modifier received(uint _upc) {
    require(items[_upc].itemState == State.Received);
    _;
  }

  // Define a modifier that checks if an item.state of a upc is Purchased
  modifier purchased(uint _upc) {
    require(items[_upc].itemState == State.Purchased);
    _;
  }

  // In the constructor set 'owner' to the address that instantiated the contract
  // and set 'sku' to 1
  // and set 'upc' to 1
  constructor() public payable {
    owner = msg.sender;
    sku = 1;
    upc = 1;
  }

  // Define a function 'kill' if required
  function kill() public {
    if (msg.sender == owner) {
      selfdestruct(owner);
    }
  }

  // Define a function 'harvestItem' that allows a farmer to mark an item 'Harvested'
  function harvestItem(uint _upc, address _originFarmerID, string _originFarmName, string _originFarmInformation,
    string  _originFarmLatitude, string  _originFarmLongitude, string  _productNotes) onlyFarmer public
  {
    // Add the new item as part of Harvest
    Item memory item;
    item.sku = sku;
    item.upc = _upc;
    item.ownerID = msg.sender;
    item.originFarmerID = _originFarmerID;
    item.originFarmName = _originFarmName;
    item.originFarmInformation = _originFarmInformation;
    item.originFarmLatitude = _originFarmLatitude;
    item.originFarmLongitude = _originFarmLongitude;
    item.productID = _upc + sku;
    item.productNotes = _productNotes;
    item.itemState = State.Harvested;
    item.distributorID = address(0);
    item.retailerID = address(0);
    item.consumerID = address(0);
    items[upc] = item;

    // Increment sku
    sku = sku + 1;
    // Emit the appropriate event
    emit Harvested(_upc);
  }

  // Define a function 'processtItem' that allows a farmer to mark an item 'Processed'
  function steamItem(uint _upc) onlyFarmer harvested(_upc) public
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[upc].itemState = State.Steamed;

    // Emit the appropriate event
    emit Steamed(_upc);
    
  }

  // Define a function 'packItem' that allows a farmer to mark an item 'Packed'
  function driedOutItem(uint _upc) onlyFarmer steamed(_upc) public
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    items[upc].itemState = State.DriedOut;

    // Emit the appropriate event
    emit DriedOut(_upc);
    
  }

  // Define a function 'sellItem' that allows a farmer to mark an item 'ForSale'
  function sellItem(uint _upc, uint _price) onlyFarmer driedOut(_upc) public
  // Call modifier to check if upc has passed previous supply chain stage
  
  // Call modifier to verify caller of this function
  
  {
    // Update the appropriate fields
    Item storage item = items[_upc];
    item.itemState = State.ForSale;
    item.productPrice = _price;

    // Emit the appropriate event
    emit ForSale(_upc);
  }

  // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
  // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
  // and any excess ether sent is refunded back to the buyer
  function buyItem(uint _upc) onlyRetailer forSale(_upc) payable public
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Call modifer to check if buyer has paid enough
    
    // Call modifer to send any excess ether back to buyer
    
    {
      // Update the appropriate fields - ID, distributorID, itemState
      Item storage item = items[_upc];
      address farmerID = address(item.ownerID);
      item.retailerID = msg.sender;
      item.itemState = State.Sold;

      // Transfer money to farmer
      farmerID.transfer(item.productPrice);

      // emit the appropriate event
      emit Sold(_upc);

    
  }

  // Define a function 'shipItem' that allows the distributor to mark an item 'Shipped'
  // Use the above modifers to check if the item is sold
  function shipItem(uint _upc) onlyFarmer sold(_upc) public
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Call modifier to verify caller of this function
    
    {
      // Update the appropriate fields
      Item storage item = items[_upc];
      item.itemState = State.Shipped;

      // Emit the appropriate event
      emit Shipped(_upc);
    
  }

  // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
  // Use the above modifiers to check if the item is shipped
  function receiveItem(uint _upc) onlyRetailer shipped(_upc) public
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Access Control List enforced by calling Smart Contract / DApp
    {
      // Update the appropriate fields - ownerID, retailerID, itemState
      Item storage item = items[_upc];
      item.ownerID = item.retailerID;
      item.itemState = State.Received;

      // Emit the appropriate event
      emit Received(_upc);
    
  }

  // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
  // Use the above modifiers to check if the item is received
  function purchaseItem(uint _upc) onlyConsumer received(_upc) public
    // Call modifier to check if upc has passed previous supply chain stage
    
    // Access Control List enforced by calling Smart Contract / DApp
    {
      // Update the appropriate fields - ownerID, consumerID, itemState
      Item storage item = items[_upc];
      item.ownerID = msg.sender;
      item.consumerID = msg.sender;
      item.itemState = State.Purchased;

      // TODO : price 지정 필요.
      // TODO : price을 retialer에게 송금

      // Emit the appropriate event
      emit Purchased(_upc);
  }

  // Define a function 'fetchItemBufferOne' that fetches the data
  function fetchItemBufferOne(uint _upc) public view returns 
  (
  uint    itemSKU,
  uint    itemUPC,
  address ownerID,
  address originFarmerID,
  string  originFarmName,
  string  originFarmInformation,
  string  originFarmLatitude,
  string  originFarmLongitude
  ) 
  {
    // Assign values to the 8 parameters
    Item memory item = items[_upc]; // TODO : not found exception.
    return
    (
    item.sku,
    item.upc,
    item.ownerID,
    item.originFarmerID,
    item.originFarmName,
    item.originFarmInformation,
    item.originFarmLatitude,
    item.originFarmLongitude
    );

  }

  // Define a function 'fetchItemBufferTwo' that fetches the data
  function fetchItemBufferTwo(uint _upc) public view returns 
  (
  uint    productID,
  string  productNotes,
  uint    productPrice,
  uint    itemState,
  address originFarmerID,
  address retailerID,
  address consumerID
  ) 
  {
    // Assign values to the 9 parameters
    // Assign values to the 9 parameters
    Item memory item = items[_upc]; // TODO : not found exception.
    return
    (
    item.productID,
    item.productNotes,
    item.productPrice,
    uint(item.itemState),
    item.originFarmerID,
    item.retailerID,
    item.consumerID
    );
  }
}
