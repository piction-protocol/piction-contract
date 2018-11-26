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

    const mint = new BigNumber(1000000 * DECIMALS);
    const userToken = new BigNumber(100 * DECIMALS);

    const cdRate = 0.15;

    const comicHash = "comicHash1234567";
    const episodeHash = "episodeHash1234567";

    const imageHash = "imageHash1234567";
    const imageHashTwo = "imageHash1234568";

    const price = new BigNumber(3 * DECIMALS);
    const newPrice = new BigNumber(10 * DECIMALS);

    const releaseDate = 1542879000000;

    let pxl;
    let piction;
    let proxy;
    let distributor;
    let comic;
    let episode;
    let pictionProxy;

    let result;

    function convertToHex(str) {
        var hex = '';
        for(var i=0;i<str.length;i++) {
            hex += ''+str.charCodeAt(i).toString(16);
        }
        return "0x"+hex;
    }

    before("Deploy contract", async() => {
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Deploying contract start ====================\t"));
        console.log();
        
        pxl = await PXL.new({from: admin});
        console.log("\t" + colors.magenta(" PXL address: " + pxl.address));

        pxl.mint(mint, {from: admin});
        console.log("\t" + colors.magenta(" PXL mint: " + mint.toNumber()));

        await pxl.unlock({from: admin});
        console.log("\t" + colors.magenta(" PXL unlock "));

        await pxl.transfer(user, userToken, {from: admin});
        console.log("\t" + colors.magenta(" PXL transfer to user: "+userToken.toNumber()));

        piction = await Piction.new({from: admin});
        console.log("\t" + colors.magenta(" Piction Network address: " + piction.address));

        proxy = await Proxy.new({from: admin});
        console.log("\t" + colors.magenta(" Proxy address: " + proxy.address));

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
        
        await pictionProxy.setPxlAddress(pxl.address, {from:admin});
        result = await pictionProxy.getPxlAddress.call();
        result.should.be.equal(pxl.address);
        console.log("\t" + colors.magenta(" Add pxl"));

        console.log("\t" + colors.gray(" Pixel Distributor deploy..."));
        distributor = await PixelDistributor.new(proxy.address, {from: admin});
        console.log("\t" + colors.magenta(" Pixel Distributor address: " + distributor.address));

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

        comic = await Comic.new(comicHash, proxy.address, {from: cp});
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

        result = await episode.getPrice.call()
        result.should.be.bignumber.equal(price);
        console.log("\t" + colors.magenta(" Episode Price: " + result));

        await episode.setPrice(newPrice, {from: admin}).should.be.rejected;
        await episode.setPrice(newPrice, {from: cp}).should.be.fulfilled;
        result = await episode.getPrice.call()
        result.should.be.bignumber.equal(newPrice);
        console.log("\t" + colors.magenta(" Change episode Price: " + result));

        result = await episode.getPublishedTo.call();
        console.log("\t" + colors.magenta(" Origin episode Published To: " + result));

        let time = Date.now()+15000;
        console.log("\t" + colors.gray(" Time now: "+time));
        await episode.setPublishedTo(time, {from: admin}).should.be.rejected;
        await episode.setPublishedTo(time, {from: cp}).should.be.fulfilled;

        result = await episode.getPublishedTo.call();
        result.should.be.bignumber.equal(time);
        console.log("\t" + colors.magenta(" Change episode Published To: " + result));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Permission check end =====================\t"));
        console.log();

        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Episode Hash check start ====================\t"));
        console.log();

        result = await episode.isEqual.call(episodeHash);
        result.should.be.equal(true);
        console.log("\t" + colors.magenta(" Hash Equal: " + result));

        result = await episode.isEqual.call(comicHash);
        result.should.be.equal(false);
        console.log("\t" + colors.magenta(" Wrong Hash Equal: " + result));

        await episode.setHash(comicHash, {from: admin}).should.be.rejected;
        await episode.setHash(comicHash, {from: cp}).should.be.fulfilled;
        result = await episode.getHash.call();
        result.should.be.equal(comicHash);

        await episode.setHash(episodeHash, {from: cp}).should.be.fulfilled;
        console.log("\t" + colors.magenta(" Set Hash: " + true));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Episode Hash check end =====================\t"));
        console.log();

        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Episode Image check start ====================\t"));
        console.log();

        result = await episode.getImages.call({from: cp});
        result.length.should.be.equal(1);
        console.log("\t" + colors.magenta(" Images hash: " + result));
        
        result[0].should.be.equal(convertToHex(imageHash));
        console.log("\t" + colors.magenta(" Image Hash Equal: " + true));

        console.log("\t" + colors.gray(" Add imageHash..."));
        await episode.setImages([imageHash, imageHashTwo], {from: admin}).should.be.rejected;
        await episode.setImages([imageHash, imageHashTwo], {from: cp}).should.be.fulfilled;

        result = await episode.getImages.call({from: cp});
        console.log("\t" + colors.magenta(" Images hash Order: " + result));

        console.log("\t" + colors.gray(" Change imageHash 0-1"));
        await episode.changeImageOrder(0, 1, {from: admin}).should.be.rejected;
        await episode.changeImageOrder(0, 1, {from: cp}).should.be.fulfilled;
        
        result = await episode.getImages.call({from: cp});
        console.log("\t" + colors.magenta(" Images hash Order: " + result));

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Episode Image check end =====================\t"));
        console.log();
    });

    it("Episode Purchase.", async() => {
        console.log();
        console.log();
        console.log();
        console.log("\t" + colors.bgWhite.black("\t==================== Purchase check start ====================\t"));
        console.log();

        let userValue = await pxl.balanceOf.call(user, {from: user});
        console.log("\t" + colors.magenta(" Purchase befor user: " + userValue.toNumber()));
        let cdValue = await pxl.balanceOf.call(cd, {from: cd});
        console.log("\t" + colors.magenta(" Purchase befor cd:" + cdValue.toNumber()));
        let cpValue = await pxl.balanceOf.call(cp, {from: cp});
        console.log("\t" + colors.magenta(" Purchase befor cp: " + cpValue.toNumber()));

        console.log("\t" + colors.gray(" Purchase...:"+newPrice.toNumber()));
        await pxl.approveAndCall(
            distributor.address,
            newPrice,
            cd + episode.address.substr(2),
            {from: user}
        );

        result = await pxl.balanceOf.call(user, {from: user});
        result.should.be.bignumber.equal(userValue-newPrice);
        console.log("\t" + colors.magenta(" Purchase after user: " + result.toNumber()));
        result = await pxl.balanceOf.call(cd, {from: cd});
        result.should.be.bignumber.equal(newPrice * cdRate);
        console.log("\t" + colors.magenta(" Purchase after cd: " + result.toNumber()));
        result = await pxl.balanceOf.call(cp, {from: cp});
        result.should.be.bignumber.equal(newPrice - (newPrice * cdRate));
        console.log("\t" + colors.magenta(" Purchase after cp: " + result.toNumber()));
        
        console.log("")

        console.log();
        console.log("\t" + colors.bgWhite.black("\t===================== Purchase check end =====================\t"));
        console.log();
    });
});
