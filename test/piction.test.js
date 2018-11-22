const colors = require('colors/safe');

const PXL = artifacts.require("PXL");
const Piction = artifacts.require("PictionNetwork");
const Proxy = artifacts.require("Proxy");
const PixelDistributor = artifacts.require("PixelDistributor");
const Comic = artifacts.require("Comic");
const Episode = artifacts.require("Episode");

const BigNumber = web3.BigNumber;


require("chai")
    .use(require("chai-as-promised"))
    .use(require("chai-bignumber")(BigNumber))
    .should();

contract("Piction contract test", async function (accounts){
    const admin = accounts[0];
    const cd = accounts[1];
    const cp = accounts[2];
    const user = accounts[3];

    const DECIMALS = 10 ** 18;
    const cdRate = 0.15;

    const comicHash = "comicHash1234567";
    const episodeHash = "episodeHash1234567";
    const imageHash = "imageHash1234567";

    const price = 3;
    const releaseDate = 1542879000000;

    let pxl;
    let piction;
    let proxy;
    let distributor;
    let comic;
    let episode;
    let pictionProxy;

    let result;

    before("Deploy contract", async() => {
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Deploying contract start ====================\t"));
        console.log();
        
        pxl = await PXL.new({from: admin});
        console.log("\t" + colors.magenta(" PXL address: " + pxl.address));

        piction = await Piction.new(pxl.address, {from: admin});
        console.log("\t" + colors.magenta(" Piction Network address: " + piction.address));

        proxy = await Proxy.new({from: admin});
        console.log("\t" + colors.magenta(" Proxy address: " + proxy.address));

        distributor = await PixelDistributor.new(piction.address, {from: admin});
        console.log("\t" + colors.magenta(" Pixel Distributor address: " + distributor.address));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Deploying contract end =====================\t"));
        console.log();
    });

    it("Setting proxy contract.", async() =>{
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Setting proxy start ====================\t"));
        console.log();

        await proxy.setTargetAddress(piction.address, {from: admin});
        result = await proxy.getTargetAddress.call();
        result.should.be.equal(piction.address);
        console.log("\t" + colors.magenta(" Proxy target address: " + result));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Setting proxy end =====================\t"));
        console.log();
    });

    it("Initialze piction network contract(with Proxy).", async() => {
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Initialzing piction network start ====================\t"));
        console.log();

        pictionProxy = await Piction.at(proxy.address);

        await pictionProxy.addUser(user, {from:admin});
        result = await pictionProxy.validUser.call(user);
        result.should.be.equal(true);
        console.log("\t" + colors.magenta(" Add user: " + user));

        await pictionProxy.addContentsDistributors(cd, {from: admin});
        result = await pictionProxy.isContentsDistributor.call(cd);
        result.should.be.equal(true);
        console.log("\t" + colors.magenta(" Add contents distributor: " + cd));

        await pictionProxy.setConctentsDistributorRate(cdRate * DECIMALS, {from: admin});
        result = await pictionProxy.getCdRate.call();
        result.should.be.bignumber.equal(cdRate * DECIMALS);
        console.log("\t" + colors.magenta(" Set contents distributor rate(bignumber): " + (await pictionProxy.getCdRate()).toNumber()));

        await pictionProxy.setPixelDistributor(distributor.address, {from: admin});
        result = await pictionProxy.getPixelDistributor.call();
        result.should.be.equal(distributor.address);
        console.log("\t" + colors.magenta(" Set pixel distributor address: " + await pictionProxy.getPixelDistributor()));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Initialzing piction network end =====================\t"));
        console.log();
    });

    it("Register comics.", async () => {
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Deploying comic contract start ====================\t"));
        console.log();

        comic = await Comic.new(comicHash, {from: cp});
        console.log("\t" + colors.magenta(" Comic address: " + comic.address));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Deploying comic contract end =====================\t"));
        console.log();
        console.log();
        console.log();

        console.log("\t" + colors.bgWhite.black("\t==================== Register comic address in piction network start ====================\t"));
        console.log();

        result = await comic.isEqual.call(comicHash);
        result.should.be.equal(true);

        await pictionProxy.addContents(comic.address, {from: admin});
        result = await pictionProxy.validContents.call(comic.address, {from: admin});
        result.should.be.equal(true);
        console.log("\t" + colors.magenta(" Comic address: " + comic.address));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Register comic address in piction network end =====================\t"));
        console.log();
    });

    it("Add episode.", async() => {
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Deploying episode contract start ====================\t"));
        console.log();

        episode = await Episode.new(pictionProxy.address, episodeHash, [imageHash], price, releaseDate, {from: cp});
        console.log("\t" + colors.magenta(" Episode address: " + episode.address));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Deploying episode contract end =====================\t"));
        console.log();

        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Register episode address in comic contract start ====================\t"));
        console.log();

        await comic.addEpisode(episode.address, {from: cp});
        result = await comic.getEpisodes();
        result.length.should.be.equal(1);
        console.log("\t" + colors.magenta(" Episode address: " + result[0]));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Register episode address in comic contract end =====================\t"));
        console.log();
    });

    it("Episode validations.", async() => {
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Permission check start ====================\t"));
        console.log();

        console.log("\t" + colors.gray(" Owner address lookup..."));        
        result = await episode.getOwner.call();
        result.should.be.equal(cp);
        console.log("\t" + colors.magenta(" Owner addresss: " + result));

        

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Permission check end =====================\t"));
        console.log();
    });
});
