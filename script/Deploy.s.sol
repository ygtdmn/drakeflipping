// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Drakeflipping } from "../src/Drakeflipping.sol";
import { DrakeflippingRenderer } from "../src/DrakeflippingRenderer.sol";

import { BaseScript } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (Drakeflipping drakeflipping, DrakeflippingRenderer renderer) {
        string memory metadata =
            unicode"\"name\": \"Drakeflipping\",\"description\": \"An on-chain meme, established, rendered and lives on the world most secure decentralized computer forever. Inspired by the iconic internet meme called Drakeposting.\"";
        renderer = new DrakeflippingRenderer(
            0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e, 0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb, metadata
        );
        drakeflipping = new Drakeflipping(address(renderer), address(0xCb337152b6181683010D07e3f00e7508cd348BC7));
        renderer.setDrakeflipping(address(drakeflipping));
    }

    function runSepolia() public broadcast returns (Drakeflipping drakeflipping, DrakeflippingRenderer renderer) {
        string memory metadata =
            unicode"\"name\": \"Drakeflipping\",\"description\": \"An on-chain meme, established, rendered and lives on the world most secure decentralized computer forever. Inspired by the iconic internet meme called Drakeposting.\"";
        renderer = new DrakeflippingRenderer(
            0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e, 0xA0a1AbcDAe1a2a4A2EF8e9113Ff0e02DD81DC0C6, metadata
        );
        drakeflipping = new Drakeflipping(address(renderer), address(0xBF6b69aF9a0f707A9004E85D2ce371Ceb665237B));
        renderer.setDrakeflipping(address(drakeflipping));
    }
}
