// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProductTracker {
    // Structure to store product details
    struct Product {
        uint256 id;
        string name;
        string manufacturer;
        string status;
        address owner;
        uint256 timestamp;
    }

    // State variables
    mapping(uint256 => Product) public products; // Mapping from product ID to Product struct
    uint256 public productCount; // Counter for product IDs

    // Events
    event ProductAdded(uint256 indexed id, string name, string manufacturer, address owner);
    event ProductUpdated(uint256 indexed id, string status, address updatedBy);
    event ProductSold(uint256 indexed id, address newOwner);

    // Modifier to check if the sender is the product's owner
    modifier onlyOwner(uint256 productId) {
        require(products[productId].owner == msg.sender, "Not the product owner");
        _;
    }

    // Function to add a new product
    function addProduct(string memory _name, string memory _manufacturer) external {
        productCount++; // Increment product count to generate a new ID
        uint256 newProductId = productCount;

        // Create and store the new product
        products[newProductId] = Product({
            id: newProductId,
            name: _name,
            manufacturer: _manufacturer,
            status: "Created",
            owner: msg.sender,
            timestamp: block.timestamp
        });

        emit ProductAdded(newProductId, _name, _manufacturer, msg.sender);
    }

    // Function to update the status of a product (only the owner can update)
    function updateStatus(uint256 _productId, string memory _newStatus) external onlyOwner(_productId) {
        require(bytes(products[_productId].name).length != 0, "Product does not exist");
        products[_productId].status = _newStatus;
        products[_productId].timestamp = block.timestamp;

        emit ProductUpdated(_productId, _newStatus, msg.sender);
    }

    // Function to mark a product as sold to a new owner
    function sellProduct(uint256 _productId, address _newOwner) external onlyOwner(_productId) {
        require(bytes(products[_productId].name).length != 0, "Product does not exist");
        products[_productId].owner = _newOwner;
        products[_productId].status = "Sold";
        products[_productId].timestamp = block.timestamp;

        emit ProductSold(_productId, _newOwner);
    }

    // Function to fetch product details
    function getProduct(uint256 _productId) external view returns (
        uint256 id,
        string memory name,
        string memory manufacturer,
        string memory status,
        address owner,
        uint256 timestamp
    ) {
        Product memory product = products[_productId];
        require(bytes(product.name).length != 0, "Product does not exist");
        return (
            product.id,
            product.name,
            product.manufacturer,
            product.status,
            product.owner,
            product.timestamp
        );
    }
}
