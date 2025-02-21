
const {assert, ethers, Web3, web3} = require("hardhat");
const log4js = require("log4js");
const {getABI, setBalance} = require('./lib/helpers');
const Merkle = require("./lib/merkle");

// const Provider = require("./lib/provider");

const hardhatProvider = ethers.provider._hardhatProvider;
const web3client = new Web3(hardhatProvider);
// const ethersClient = new ethers.providers.Web3Provider(hardhatProvider);
const merkle = new Merkle();

let logging = console;

contract("Contract Name", (accts) => {
  let owner, ownerSigner;
  const accounts = [];
  const signers = [];

  it("configures logging", async () => {
    log4js.configure({
      disableClustering: true,
      appenders: {
        console: {
          type: "console",
          layout: { type: "colored" }
        },
        // dateFile: {
        //   type: "dateFile",
        //   filename: logPath,
        //   keepFileExt: true,
        // },
      },
      categories: {
        default: {
          appenders: ["console"], //,"dateFile"],
          level: "info",
          // enable line numbers in output
          // enableCallStack: true
        },
      },
    });

    logging = log4js.getLogger("test-contract.js");
  });

  it("loads accounts", async () => {
    owner = accts.shift();
    //logging.info({ owner });
  
    accounts.push( ...accts );
    //logging.info({ accounts });

    signers.push( ...(await ethers.getSigners()) );
    ownerSigner = signers.shift();
  });

  it("loads merkle tree", () => {
    merkle.load(accounts.slice(0,9));
  });

  let street;
  it("deploys ContractName", async () => {
    try{
      const ContractName = await ethers.getContractFactory("ContractName");
      street = await ContractName.deploy();
      logging.info('\tINFO: ContractName.address', street.address);

      const rcpt = await street.deployTransaction.wait();
      // logging.warn( rcpt.events );
    }
    catch(err){
      console.warn({err});
    }
  });

  after(() => {
    if(!street)
      assert.fail("ContractName ($SYBL) not deployed");


    describe("test transfers", function(){
      it("test transfers", async () => {
        // await setBalance(web3client.currentProvider, '0xa83665bBa3672d7B324041180FC6bddc772a7088', 1);
        // const impersonatedSigner = await ethers.getImpersonatedSigner('0xa83665bBa3672d7B324041180FC6bddc772a7088');
        // const txn = await street.connect(impersonatedSigner).transfer(accounts[11], value1ether);
      });
    });
  });
});
