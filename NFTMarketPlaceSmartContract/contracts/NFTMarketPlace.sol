// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "./Counters.sol";
import {console} from "hardhat/console.sol";

contract NFTMarketPlace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;

    uint256 public listingPrice = 0.0025 ether;

    address payable owner;

    struct MarketItem {
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idMarketItem;

    event idMarketItemCreated(
        uint indexed tokenId,
        address payable seller,
        address payable owner,
        uint price,
        bool sold
    );

    constructor() ERC721("NFT Metaverse Token", "MyNFT") {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function updateListingPrice(
        uint256 _listingPrice
    ) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createToken(
        string memory tokenURI,
        uint price
    ) public payable returns (uint256) {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    function createMarketItem(uint tokenId, uint price) private {
        require(price > 0, "Price must be greater than zero");
        require(msg.value == listingPrice, "Listing fee required");

        MarketItem memory newMarketItem = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );

        idMarketItem[tokenId] = newMarketItem;

        _transfer(msg.sender, address(this), tokenId);

        emit idMarketItemCreated(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false
        );
    }

    // Function to resell an NFT
    function reSellNFT(uint256 tokenId, uint256 price) public payable {
        require(
            idMarketItem[tokenId].owner == msg.sender,
            "Only item owner can resell"
        );
        require(msg.value == listingPrice, "Listing fee required");

        idMarketItem[tokenId].price = price;
        idMarketItem[tokenId].sold = false;
        idMarketItem[tokenId].seller = payable(msg.sender);
        idMarketItem[tokenId].owner = payable(address(0));

        _itemsSold.decrement();

        _transfer(msg.sender, address(this), tokenId); // Transfer ownership to contract
    }

    function createMarketSale(uint tokenId) public payable {
        MarketItem storage item = idMarketItem[tokenId];
        require(
            msg.value == item.price,
            "Please submit the asking price to complete the purchase"
        );
        require(!item.sold, "This item is already sold");

        item.owner = payable(msg.sender);
        item.sold = true;
        _itemsSold.increment();

        _transfer(address(this), msg.sender, tokenId); // Transfer ownership to buyer
        payable(item.seller).transfer(msg.value); // Pay the seller
        owner.transfer(listingPrice); // Transfer listing fee to the marketplace owner
    }

    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemCount = _tokenIds.current();
        uint256 unsoldItemCount = itemCount - _itemsSold.current();
        uint256 currentIndex = 0;

        MarketItem[] memory items = new MarketItem[](unsoldItemCount);
        for (uint256 i = 0; i < itemCount; i++) {
            if (idMarketItem[i + 1].owner == address(0)) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Function to fetch items owned by a user
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Function to fetch items created by a user
    function fetchItemsListed() public view returns (MarketItem[] memory) {
        uint256 totalItemCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
