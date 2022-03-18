const { ethers } = require("hardhat");
const { WHITELIST_CONTRACT_ADDRESS, METADATA_URL } = require("../constants");

async function main() {
    const whitelistAddress = WHITELIST_CONTRACT_ADDRESS;
    const metadataURL = METADATA_URL;

    const contractFactory = await ethers.getContractFactory("CryptoDevs");
    const contract = await contractFactory.deploy(
        metadataURL,
        whitelistAddress);
    await contract.deployed();

    console.log("address", contract.address);

}

main()
    .then(
        () => process.exit(0)
    )
    .catch(err => {
        console.log(err);
        process.exit(1)
    });

    // 0x36f815A9806909A69E41eB1d128063adcd616556