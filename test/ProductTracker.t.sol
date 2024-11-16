// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/ProductTracker.sol";

contract ProductTrackerTest is Test {
    ProductTracker public tracker;
    address public owner;
    address public newOwner;

    event ProductAdded(uint256 indexed id, string name, string manufacturer, address owner);
    event ProductUpdated(uint256 indexed id, string status, address updatedBy);
    event ProductSold(uint256 indexed id, address newOwner);

    function setUp() public {
        tracker = new ProductTracker();
        owner = address(this);
        newOwner = address(0x1);
    }

    // Test successful product addition
    function testAddProduct() public {
        // Expect the ProductAdded event to be emitted
        vm.expectEmit(true, false, false, true);
        emit ProductAdded(1, "Test Product", "Test Manufacturer", owner);

        tracker.addProduct("Test Product", "Test Manufacturer");

        // Verify product details
        (
            uint256 id,
            string memory name,
            string memory manufacturer,
            string memory status,
            address productOwner,
            uint256 timestamp
        ) = tracker.getProduct(1);

        assertEq(id, 1);
        assertEq(name, "Test Product");
        assertEq(manufacturer, "Test Manufacturer");
        assertEq(status, "Created");
        assertEq(productOwner, owner);
        assertGt(timestamp, 0);
        assertEq(tracker.productCount(), 1);
    }

    // Test product status update
    function testUpdateStatus() public {
        tracker.addProduct("Test Product", "Test Manufacturer");
        
        vm.expectEmit(true, false, false, true);
        emit ProductUpdated(1, "In Transit", owner);

        tracker.updateStatus(1, "In Transit");

        (, , , string memory status, , ) = tracker.getProduct(1);
        assertEq(status, "In Transit");
    }

    // Test product sale
    function testSellProduct() public {
        tracker.addProduct("Test Product", "Test Manufacturer");

        vm.expectEmit(true, false, false, true);
        emit ProductSold(1, newOwner);

        tracker.sellProduct(1, newOwner);

        (, , , string memory status, address currentOwner, ) = tracker.getProduct(1);
        assertEq(status, "Sold");
        assertEq(currentOwner, newOwner);
    }

    // Test failure when non-owner tries to update status
    function testFailUpdateStatusNonOwner() public {
        tracker.addProduct("Test Product", "Test Manufacturer");
        
        vm.prank(address(0x2));
        vm.expectRevert("Not the product owner");
        tracker.updateStatus(1, "In Transit");
    }

    // Test failure when updating non-existent product
    function testFailUpdateNonExistentProduct() public {
        vm.expectRevert("Product does not exist");
        tracker.updateStatus(1, "In Transit");
    }

    // Test failure when selling non-existent product
    function testFailSellNonExistentProduct() public {
        vm.expectRevert("Product does not exist");
        tracker.sellProduct(1, newOwner);
    }

    // Test failure when non-owner tries to sell product
    function testFailSellProductNonOwner() public {
        tracker.addProduct("Test Product", "Test Manufacturer");
        
        vm.prank(address(0x2));
        vm.expectRevert("Not the product owner");
        tracker.sellProduct(1, newOwner);
    }

    // Test getting non-existent product
    function testFailGetNonExistentProduct() public {
        vm.expectRevert("Product does not exist");
        tracker.getProduct(1);
    }

    // Test multiple products
    function testMultipleProducts() public {
        tracker.addProduct("Product 1", "Manufacturer 1");
        tracker.addProduct("Product 2", "Manufacturer 2");

        assertEq(tracker.productCount(), 2);

        (
            uint256 id1,
            string memory name1,
            ,,,
        ) = tracker.getProduct(1);

        (
            uint256 id2,
            string memory name2,
            ,,,
        ) = tracker.getProduct(2);

        assertEq(id1, 1);
        assertEq(name1, "Product 1");
        assertEq(id2, 2);
        assertEq(name2, "Product 2");
    }

    // Test product lifecycle
    function testProductLifecycle() public {
        // Add product
        tracker.addProduct("Test Product", "Test Manufacturer");
        
        // Update status
        tracker.updateStatus(1, "In Production");
        (, , , string memory status1, , ) = tracker.getProduct(1);
        assertEq(status1, "In Production");
        
        // Update status again
        tracker.updateStatus(1, "In Transit");
        (, , , string memory status2, , ) = tracker.getProduct(1);
        assertEq(status2, "In Transit");
        
        // Sell product
        tracker.sellProduct(1, newOwner);
        (, , , string memory status3, address finalOwner, ) = tracker.getProduct(1);
        assertEq(status3, "Sold");
        assertEq(finalOwner, newOwner);
    }
}
