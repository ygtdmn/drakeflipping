// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IERC1155CreatorCore } from "@manifoldxyz/creator-core-solidity/contracts/core/IERC1155CreatorCore.sol";
import { ICreatorExtensionTokenURI } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ICreatorExtensionTokenURI.sol";
import { IERC1155CreatorExtensionApproveTransfer } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ERC1155/IERC1155CreatorExtensionApproveTransfer.sol";
import { IERC165, ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { DrakeflippingRenderer } from "./DrakeflippingRenderer.sol";

/**
 * @title Drakeflipping
 * @notice An on-chain meme, established, rendered and lives on the world most secure decentralized computer forever.
 * Inspired by the iconic internet meme called Drakeposting.
 */
contract Drakeflipping is ICreatorExtensionTokenURI, IERC1155CreatorExtensionApproveTransfer, ERC165, Ownable {
    /// @notice Instance of the DrakeflippingRenderer contract for rendering SVGs
    DrakeflippingRenderer public renderer;

    /// @notice Address of the creator contract (ERC1155)
    address public creatorContractAddress;

    /// @notice Address of the previous token owner
    address public previousOwner;

    /// @notice Address of the current token owner
    address public currentOwner;

    /// @notice Constructor to initialize the contract
    /// @param _renderer Address of the DrakeflippingRenderer contract
    /// @param _creatorContractAddress Address of the creator contract
    constructor(address _renderer, address _creatorContractAddress) Ownable() {
        renderer = DrakeflippingRenderer(_renderer);
        creatorContractAddress = _creatorContractAddress;
    }

    /// @notice Set a new SVG renderer
    /// @param _renderer Address of the new DrakeflippingRenderer contract
    /// @dev Only callable by the contract owner
    function setRenderer(address _renderer) public onlyOwner {
        renderer = DrakeflippingRenderer(_renderer);
    }

    /// @notice Set the creator contract address
    /// @param _creatorContractAddress Address of the new creator contract
    /// @dev Only callable by the contract owner
    function setCreatorContractAddress(address _creatorContractAddress) public onlyOwner {
        creatorContractAddress = _creatorContractAddress;
    }

    /// @notice Generate the token URI for a given token
    /// @dev Implements ICreatorExtensionTokenURI.tokenURI
    /// @return Token URI as a string
    function tokenURI(address, uint256) external view override returns (string memory) {
        return renderer.generateTokenURI();
    }

    /// @notice Mint a new token
    /// @dev Only callable by the contract owner, and only once
    function mint() external onlyOwner {
        require(currentOwner == address(0), "Drakeflipping: already minted");
        string[] memory uris = new string[](0);
        uint256[] memory quantities = new uint256[](1);
        address[] memory to = new address[](1);
        to[0] = msg.sender;
        quantities[0] = 1;
        IERC1155CreatorCore(creatorContractAddress).mintExtensionNew(to, quantities, uris);
        currentOwner = msg.sender;
    }

    /// @notice Check if the contract supports a given interface
    /// @param interfaceId The interface identifier
    /// @return bool True if the contract supports the interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId
            || interfaceId == type(IERC1155CreatorExtensionApproveTransfer).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /// @notice Set approval for transfer extension
    /// @param creator Address of the creator contract
    /// @param enabled Boolean to enable or disable approval
    /// @dev Only the creator contract can call this function
    function setApproveTransfer(address creator, bool enabled) external override {
        require(
            ERC165Checker.supportsInterface(creator, type(IERC1155CreatorCore).interfaceId),
            "creator must implement IERC1155CreatorCore"
        );
        require(creator == creatorContractAddress, "creator must be the creator contract address");
        IERC1155CreatorCore(creator).setApproveTransferExtension(enabled);
    }

    /// @notice Approve token transfer and update owner information
    /// @param from Address of the sender
    /// @param to Address of the recipient
    /// @return bool Always returns true to approve the transfer
    function approveTransfer(
        address,
        address from,
        address to,
        uint256[] calldata,
        uint256[] calldata
    )
        external
        override
        returns (bool)
    {
        if (from != to) {
            previousOwner = from;
            currentOwner = to;
        }
        return true;
    }
}
