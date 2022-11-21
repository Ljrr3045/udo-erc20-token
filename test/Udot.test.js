const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UDOT", function () {
    let UDOT, udot, owner, user1, user2;

    before(async ()=> {

        [owner, user1, user2] = await ethers.getSigners();

        UDOT = await ethers.getContractFactory("UDOT");
        udot = await UDOT.deploy();

        await network.provider.send("hardhat_setBalance", [
            user2.address,
            ethers.utils.formatBytes32String("1000000000000000000000000"),
        ]);
    });

    describe("Mint Function", async ()=> {

        it("Error: If the user does not support the minted with MATIC, do not mint", async ()=> {

            await expect(udot.connect(user1).mint()).to.be.revertedWith(
                "UDOT: The amount must be greater than 0"
            );
        });

        it("User should be able to mint", async ()=> {

            await udot.connect(user1).mint({ value: ethers.utils.parseEther("500") });

            expect(await udot.connect(user1).balanceOf(user1.address)).to.equal(ethers.utils.parseEther("500"));
        });

        it("Each UDOT must be backed by a MATIC", async ()=> {

            expect(await ethers.provider.getBalance(udot.address)).to.equal(ethers.utils.parseEther("500"));
            expect(await udot.connect(user1).totalSupply()).to.equal(ethers.utils.parseEther("500"));
        });

        it("Error: Cannot minted more than the maximum capital", async ()=> {
            await expect(udot.connect(user2).mint(
                { value: ethers.utils.parseEther("1000000") }
            )).to.be.revertedWith("UDOT: Maximum capital exceeded");
        });
    });

    describe("Burn Function", async ()=> {

        it("Error: A user without tokens cannot burn", async ()=> {
            await expect(udot.connect(user2).burn(
                ethers.utils.parseEther("500")
            )).to.be.revertedWith("ERC20: burn amount exceeds balance");
        });

        it("Error: Burn amount cannot be 0", async ()=> {
            await expect(udot.connect(user1).burn(
                0
            )).to.be.revertedWith("UDOT: The amount must be greater than 0");
        });

        it("User should burn and receive MATIC", async ()=> {

            let _balanceBefore = await ethers.provider.getBalance(user1.address);
            await udot.connect(user1).burn(ethers.utils.parseEther("500"));
            let _balanceAfter = await ethers.provider.getBalance(user1.address);

            expect(_balanceAfter).to.be.above(_balanceBefore);
            expect(await udot.connect(user1).balanceOf(user1.address)).to.equal(0);
        });

        it("The contract should not have MATIC and the supplement should be 0", async ()=> {

            expect(await ethers.provider.getBalance(udot.address)).to.equal(0);
            expect(await udot.connect(user1).totalSupply()).to.equal(0);
        });
    });

    describe("Transfer Function", async ()=> {

        it("Fee Wallet should receive transaction taxes", async ()=> {

            await udot.connect(user1).mint({ value: ethers.utils.parseEther("500") });
            await udot.connect(user1).transfer(user2.address, ethers.utils.parseEther("200"));

            expect(await udot.connect(owner).balanceOf(owner.address)).to.equal("4000000000000000000");
        });

        it("If users are whitelisted, they do not pay taxes", async ()=> {
            await udot.connect(owner).whiteList(user1.address, true);
            await udot.connect(owner).whiteList(user2.address, true);

            await udot.connect(user1).transfer(user2.address, ethers.utils.parseEther("200"));
            expect(await udot.connect(owner).balanceOf(owner.address)).to.equal("4000000000000000000");
        });

        it("If the contract is paused, transfers cannot be made", async ()=> {
            await udot.connect(owner).pause();

            await expect(udot.connect(user1).transfer(
                user2.address, 
                ethers.utils.parseEther("100"))
            ).to.be.revertedWith("Pausable: paused");
        });
    });

    describe("Only Owner Functions", async ()=> {

        it("Error: only the owner can access certain functions", async ()=> {

            await expect(udot.connect(user1).pause()).to.be.revertedWith("Ownable: caller is not the owner");
            await expect(udot.connect(user1).unpause()).to.be.revertedWith("Ownable: caller is not the owner");

            await expect(udot.connect(user1).whiteList(
                owner.address,
                true
            )).to.be.revertedWith("Ownable: caller is not the owner");

            await expect(udot.connect(user1).setFeeWallet(
                user1.address
            )).to.be.revertedWith("Ownable: caller is not the owner");

            await expect(udot.connect(user1).setSellTax(
                300
            )).to.be.revertedWith("Ownable: caller is not the owner");

            await expect(udot.connect(user1).setBuyTax(
                300
            )).to.be.revertedWith("Ownable: caller is not the owner");

            await expect(udot.connect(user1).rescueStuckToken(
                owner.address,
                user1.address
            )).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Valid data must be provided", async ()=> {

            await expect(udot.connect(owner).whiteList(
                "0x0000000000000000000000000000000000000000",
                true
            )).to.be.revertedWith("UDOT: User is zero address");
            await expect(udot.connect(owner).setFeeWallet(
                "0x0000000000000000000000000000000000000000"
            )).to.be.revertedWith("UDOT: FeeWallet is zero address");

            await expect(udot.connect(owner).setSellTax(
                0
            )).to.be.revertedWith("UDOT: Taxes cannot be higher than 20%");
            await expect(udot.connect(owner).setSellTax(
                3000
            )).to.be.revertedWith("UDOT: Taxes cannot be higher than 20%");

            await expect(udot.connect(owner).setBuyTax(
                0
            )).to.be.revertedWith("UDOT: Taxes cannot be higher than 20%");
            await expect(udot.connect(owner).setBuyTax(
                3000
            )).to.be.revertedWith("UDOT: Taxes cannot be higher than 20%");
        });

        it("Owner must be able to change data", async ()=> {

            await udot.connect(owner).whiteList(user1.address, false);
            await udot.connect(owner).setFeeWallet(user2.address);
            await udot.connect(owner).setSellTax(1500);
            await udot.connect(owner).setBuyTax(1500);

            expect(await udot.connect(owner).whitelisted(user1.address)).to.equal(false);
            expect(await udot.connect(owner).feeWallet()).to.equal(user2.address);
            expect(await udot.connect(owner).sellTax()).to.equal(1500);
            expect(await udot.connect(owner).buyTax()).to.equal(1500);
        });
    });
});
