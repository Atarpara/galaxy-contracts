const { expect } = require('chai');
const { ethers } = require('hardhat');


describe('StartNFT', function () {
    let StarNFTV3;
    let addr1;
    let addr2;
    let addrs;

    beforeEach(async function () {
        // Get the ContractFactory and Signers here.
        StarNFTV3 = await ethers.getContractFactory('StarNFTV3');
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

        // To deploy our contract, we just have to call Token.deploy() and await
        // for it to be deployed(), which happens once its transaction has been
        // mined.

        this.StarNFTV3 = await StarNFTV3.deploy("Galaxy", "GXF");
        await this.StarNFTV3.addMinter(addr1.address);
    });

    it("Deploy the StarNFTV3 contract", async function () {
        console.log("StarNFTV3 address: " + this.StarNFTV3.address);
        expect(this.StarNFTV3.address).to.be.a('string');
    });

    describe("Minter Functionality Check", async function () {
        it("check the minter role", async function () {
            expect(await this.StarNFTV3.minters(addr1.address)).to.be.true;
        });

        it("Add the Duplicate Minter", async function () {
            await expect(this.StarNFTV3.addMinter(addr1.address)).to.be.revertedWith("Minter already added");
        })

    });

    describe("\n\nMinting Functionality check", async function () {
        it("Single NFT Mint", async function () {
            await this.StarNFTV3.connect(addr1).mint(addr1.address);
            await this.StarNFTV3.connect(addr1).mint(addr1.address);
            expect(await this.StarNFTV3.balanceOf(addr1.address)).to.equal(2);
            expect(await this.StarNFTV3.ownerOf(0)).to.equal(addr1.address);
        });

        it("Batch NFT Mint (1 NFTs)", async function () {
            await this.StarNFTV3.connect(addr1).mintBatch(addr2.address, 1);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(1);
        });

        it("Batch NFT Mint (2 NFTs)", async function () {
            await this.StarNFTV3.connect(addr1).mintBatch(addr2.address, 2);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(2);

        });

        it("Batch NFT Mint (5 NFTs)", async function () {
            await this.StarNFTV3.connect(addr1).mintBatch(addr2.address, 5);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(5);

        });

        it("Batch NFT Mint (10 NFTs)", async function () {
            await this.StarNFTV3.connect(addr1).mintBatch(addr2.address, 10);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(10);

        });

        it("Batch NFT Mint (50 NFTs)", async function () {
            await this.StarNFTV3.connect(addr1).mintBatch(addr2.address, 50);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(50);

        });

        it("Batch NFT Mint (100 NFTs)", async function () {
            await this.StarNFTV3.connect(addr1).mintBatch(addr2.address, 100);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(100);

        });
    });

    describe("\n\Burning Functionality check", async function () {
        it("Burn Single NFT", async function () {
            await this.StarNFTV3.connect(addr1).mint(addr2.address);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(1);
            await this.StarNFTV3.connect(addr2).burn(0);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(0);
        });

        it("Burn Batch NFT (5 NFT)", async function () {
            await this.StarNFTV3.connect(addr1).mintBatch(addr2.address, 5);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(5);
            await this.StarNFTV3.connect(addr2).burnBatch([0, 1, 2, 3, 4]);
            expect(await this.StarNFTV3.balanceOf(addr2.address)).to.equal(0);
        });
    });

});