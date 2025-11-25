import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("Tenchat Ecosystem", function () {
  async function deployFixture() {
    const [owner, user1, user2] = await ethers.getSigners();

    // Deploy Token
    const TenchatToken = await ethers.getContractFactory("TenchatToken");
    const token = await TenchatToken.deploy();

    // Deploy Identity
    const TenchatIdentity = await ethers.getContractFactory("TenchatIdentity");
    const identity = await TenchatIdentity.deploy();

    // Deploy Subscription
    const TenchatSubscription = await ethers.getContractFactory("TenchatSubscription");
    const subscription = await TenchatSubscription.deploy(await token.getAddress());

    // Deploy Signaling
    const TenchatSignaling = await ethers.getContractFactory("TenchatSignaling");
    const signaling = await TenchatSignaling.deploy();

    // Deploy Prediction
    const TenchatPrediction = await ethers.getContractFactory("TenchatPrediction");
    const prediction = await TenchatPrediction.deploy(await token.getAddress());

    // Deploy MiniApp Registry
    const TenchatMiniAppRegistry = await ethers.getContractFactory("TenchatMiniAppRegistry");
    const registry = await TenchatMiniAppRegistry.deploy();

    // Distribute tokens
    await token.transfer(user1.address, ethers.parseEther("1000"));
    await token.transfer(user2.address, ethers.parseEther("1000"));

    return { token, identity, subscription, signaling, prediction, registry, owner, user1, user2 };
  }

  describe("TenchatToken", function () {
    it("Should mint initial supply to owner", async function () {
      const { token, owner } = await loadFixture(deployFixture);
      const balance = await token.balanceOf(owner.address);
      expect(balance).to.be.gt(0);
    });
  });

  describe("TenchatIdentity", function () {
    it("Should allow user to set profile", async function () {
      const { identity, user1 } = await loadFixture(deployFixture);
      await identity.connect(user1).setProfile("alice", "QmHash");
      const profile = await identity.getProfile(user1.address);
      expect(profile.username).to.equal("alice");
      expect(profile.ipfsHash).to.equal("QmHash");
    });
  });

  describe("TenchatSubscription", function () {
    it("Should allow subscription with tokens", async function () {
      const { subscription, token, user1 } = await loadFixture(deployFixture);
      
      // Create plan
      const price = ethers.parseEther("10");
      await subscription.createPlan(0, price, 30 * 24 * 60 * 60); // 30 days

      // Approve and subscribe
      await token.connect(user1).approve(await subscription.getAddress(), price);
      await subscription.connect(user1).subscribeWithToken(1);

      expect(await subscription.isSubscribed(user1.address)).to.be.true;
    });
  });

  describe("TenchatSignaling", function () {
    it("Should store public keys", async function () {
      const { signaling, user1 } = await loadFixture(deployFixture);
      await signaling.connect(user1).publishPublicKey("pubKey123");
      expect(await signaling.getPublicKey(user1.address)).to.equal("pubKey123");
    });
  });

  describe("TenchatPrediction", function () {
    it("Should execute a full prediction market cycle", async function () {
      const { prediction, token, user1, user2, owner } = await loadFixture(deployFixture);

      // Create market
      await prediction.createMarket("Will ETH hit 10k?", 3600);
      
      // Place bets
      const betAmount = ethers.parseEther("100");
      await token.connect(user1).approve(await prediction.getAddress(), betAmount);
      await prediction.connect(user1).placeBet(1, 1, betAmount); // Yes

      await token.connect(user2).approve(await prediction.getAddress(), betAmount);
      await prediction.connect(user2).placeBet(1, 2, betAmount); // No

      // Resolve market (Yes wins)
      await prediction.resolveMarket(1, 1);

      // Claim winnings
      const balanceBefore = await token.balanceOf(user1.address);
      await prediction.connect(user1).claimWinnings(1);
      const balanceAfter = await token.balanceOf(user1.address);

      // User1 should get their 100 + User2's 100 = 200
      expect(balanceAfter - balanceBefore).to.equal(ethers.parseEther("200"));
    });
  });

  describe("TenchatMiniAppRegistry", function () {
    it("Should register an app", async function () {
      const { registry, user1 } = await loadFixture(deployFixture);
      await registry.connect(user1).registerApp("Game", "A game", "ipfs://game");
      const app = await registry.getApp(1);
      expect(app.name).to.equal("Game");
      expect(app.developer).to.equal(user1.address);
    });
  });
});
