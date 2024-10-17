// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Drakeflipping } from "./Drakeflipping.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { LibString } from "solady/src/utils/LibString.sol";
import { ENS } from "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import { IReverseRegistrar } from "@ensdomains/ens-contracts/contracts/reverseRegistrar/IReverseRegistrar.sol";
import { INameResolver } from "@ensdomains/ens-contracts/contracts/resolvers/profiles/INameResolver.sol";
import { Base64 } from "solady/src/utils/Base64.sol";

/**
 * @title DrakeflippingRenderer
 * @notice A contract for rendering Drakeflipping images with owner information.
 */
contract DrakeflippingRenderer is Ownable {
    Drakeflipping public drakeflipping;
    ENS public ens = ENS(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    IReverseRegistrar public reverseRegistrar = IReverseRegistrar(0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb);

    /// @notice Metadata string to be included in the token URI
    string public metadata;

    /**
     * @notice Constructor function.
     * @param _ens The address of the ENS contract.
     * @param _reverseRegistrar The address of the ReverseRegistrar contract.
     * @param _metadata Metadata string to be included in the token URI
     */
    constructor(address _ens, address _reverseRegistrar, string memory _metadata) Ownable() {
        ens = ENS(_ens);
        reverseRegistrar = IReverseRegistrar(_reverseRegistrar);
        metadata = _metadata;
    }

    /**
     * @notice Sets the Drakeflipping contract address.
     * @param _drakeflipping The address of the Drakeflipping contract.
     */
    function setDrakeflipping(address _drakeflipping) external onlyOwner {
        drakeflipping = Drakeflipping(_drakeflipping);
    }

    /**
     * @notice Sets the ENS contract address.
     * @param _ens The address of the ENS contract.
     */
    function setENS(address _ens) external onlyOwner {
        ens = ENS(_ens);
    }

    /**
     * @notice Sets the ReverseRegistrar contract address.
     * @param _reverseRegistrar The address of the ReverseRegistrar contract.
     */
    function setReverseRegistrar(address _reverseRegistrar) external onlyOwner {
        reverseRegistrar = IReverseRegistrar(_reverseRegistrar);
    }

    /**
     * @notice Set new metadata
     * @param _metadata New metadata string
     * @dev Only callable by the contract owner
     */
    function setMetadata(string memory _metadata) public onlyOwner {
        metadata = _metadata;
    }

    /**
     * @notice Renders the Drakeflipping image with owner information.
     * @return The rendered image as a base64-encoded SVG string.
     */
    function renderImage() public view returns (string memory) {
        if (address(drakeflipping) == address(0)) {
            revert("Drakeflipping not set");
        }

        string memory previousOwnerName = getENSOrAddress(drakeflipping.previousOwner());
        string memory currentOwnerName = getENSOrAddress(drakeflipping.currentOwner());

        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="924" height="924"><image width="924" height="924" style="stroke-width:.5;image-rendering:pixelated" xlink:href="data:image/png;base64,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" /><foreignObject x="55%" y="20%" width="40%" height="20%" style="overflow:visible"><div xmlns="http://www.w3.org/1999/xhtml" style="height:100%;width:100%;display:flex;align-items:center;justify-content:center;"><div style="font-size:30px;width:100%;font-family:impact;color:#fff;word-wrap:break-word;text-align:center;text-shadow:0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000">',
                previousOwnerName,
                '</div></div></foreignObject><foreignObject x="55%" y="65%" width="40%" height="20%" style="overflow:visible"><div xmlns="http://www.w3.org/1999/xhtml" style="height:100%;width:100%;display:flex;align-items:center;justify-content:center;"><div style="font-size:30px;width:100%;font-family:impact;color:#fff;word-wrap:break-word;text-align:center;text-shadow:0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000,0 0 5px #000">',
                currentOwnerName,
                "</div></div></foreignObject></svg>"
            )
        );

        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(svg))));
    }

    /**
     * @notice Generates the complete token URI
     * @return token The complete token URI as a string
     */
    function generateTokenURI() external view returns (string memory token) {
        token = string(abi.encodePacked("data:application/json;utf8,{", metadata, ', "image": "', renderImage(), '"}'));
    }

    /**
     * @notice Retrieves the ENS name or checksummed address for a given address.
     * @param addr The address to retrieve the ENS name or checksummed address for.
     * @return The ENS name if available, otherwise the checksummed address.
     */
    function getENSOrAddress(address addr) internal view returns (string memory) {
        bytes32 node = reverseRegistrar.node(addr);
        address resolverAddress = ens.resolver(node);

        if (resolverAddress != address(0)) {
            // If the resolver is not the zero address, try to get the name from the resolver
            try INameResolver(resolverAddress).name(node) returns (string memory name) {
                // If a name is found and it's not empty, return it
                if (bytes(name).length > 0) {
                    return name;
                }
            } catch { }
        }

        // If no valid name is found, return the address as a string
        return LibString.toHexStringChecksummed(addr);
    }
}
