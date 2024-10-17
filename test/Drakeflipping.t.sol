// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { Drakeflipping } from "../src/Drakeflipping.sol";
import { DrakeflippingRenderer } from "../src/DrakeflippingRenderer.sol";
import { ENS } from "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import { IReverseRegistrar } from "@ensdomains/ens-contracts/contracts/reverseRegistrar/IReverseRegistrar.sol";
import { ICreatorExtensionTokenURI } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ICreatorExtensionTokenURI.sol";
import { IERC1155CreatorExtensionApproveTransfer } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ERC1155/IERC1155CreatorExtensionApproveTransfer.sol";
import { ICreatorCore } from "@manifoldxyz/creator-core-solidity/contracts/core/ICreatorCore.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

contract DrakeflippingTest is Test {
    Drakeflipping drakeflipping;
    DrakeflippingRenderer renderer;
    ENS ens;
    IReverseRegistrar reverseRegistrar;

    function setUp() public {
        ens = ENS(address(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e));
        reverseRegistrar = IReverseRegistrar(address(0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb));
        string memory metadata =
            unicode"\"name\": \"Drakeflipping\",\"description\": \"An on-chain meme, established, rendered and lives on the world most secure decentralized computer forever. Inspired by the iconic internet meme called Drakeposting.\"";
        renderer = new DrakeflippingRenderer(
            0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e, 0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb, metadata
        );
        drakeflipping = new Drakeflipping(address(renderer), address(0xCb337152b6181683010D07e3f00e7508cd348BC7));
        renderer.setDrakeflipping(address(drakeflipping));
    }

    function testSetRenderer() public {
        DrakeflippingRenderer newRenderer = new DrakeflippingRenderer(address(0), address(0), "");
        drakeflipping.setRenderer(address(newRenderer));
        assertEq(address(drakeflipping.renderer()), address(newRenderer));
    }

    function testSetMetadata() public {
        string memory newMetadata = "new metadata";
        renderer.setMetadata(newMetadata);
        assertEq(renderer.metadata(), newMetadata);
    }

    function testSetDrakeflipping() public {
        Drakeflipping newDrakeflipping = new Drakeflipping(address(renderer), address(0));
        renderer.setDrakeflipping(address(newDrakeflipping));
        assertEq(address(renderer.drakeflipping()), address(newDrakeflipping));
    }

    function testSetENS() public {
        ENS newENS = ENS(address(1));
        renderer.setENS(address(newENS));
        assertEq(address(renderer.ens()), address(newENS));
    }

    function testSetReverseRegistrar() public {
        IReverseRegistrar newReverseRegistrar = IReverseRegistrar(address(1));
        renderer.setReverseRegistrar(address(newReverseRegistrar));
        assertEq(address(renderer.reverseRegistrar()), address(newReverseRegistrar));
    }

    function testRenderFork() external {
        // Silently pass this test if there is no API key.
        string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
        if (bytes(alchemyApiKey).length == 0) {
            return;
        }

        // Otherwise, run the test against the mainnet fork.
        vm.createSelectFork({ urlOrAlias: "mainnet" });
        vm.startPrank(0x28996f7DECe7E058EBfC56dFa9371825fBfa515A);
        renderer = new DrakeflippingRenderer(address(ens), address(reverseRegistrar), "");
        drakeflipping = new Drakeflipping(address(renderer), address(0xCb337152b6181683010D07e3f00e7508cd348BC7));
        renderer.setDrakeflipping(address(drakeflipping));
        ICreatorCore(0xCb337152b6181683010D07e3f00e7508cd348BC7).registerExtension(address(drakeflipping), "");
        drakeflipping.mint();
        IERC1155(0xCb337152b6181683010D07e3f00e7508cd348BC7).safeTransferFrom(
            0x28996f7DECe7E058EBfC56dFa9371825fBfa515A, 0x077be47506ABa13F54b20850fd47d1Cea69d84A5, 3, 1, ""
        );
        console2.logString(renderer.renderImage());
    }
}
