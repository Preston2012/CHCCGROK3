

task("setBalance", "sends hardhat_setBalance to the devnet")
  .addParam("account")
  .addParam("amount")
  .setAction(async (args, hre, runSuper) => {
    if(!Web3.utils.isHexStrict(args.amount)){
      args.amount = '0x'+ BigInt(args.amount).toString(16);
    }

    try{
      const res = await new Promise(async (resolve, reject) => {
        const web3 = new Web3(hre.config.networks.devnet.url);
        web3.currentProvider.send({
          method: "hardhat_setBalance",
          params: [args.account, args.amount],
          jsonrpc: "2.0",
          id: Date.now()
        }, (err, res) => {
          err ? reject(err) : resolve(res);
        });
      });
      console.log(res);
    }
    catch(err){
      console.error(err);
    }    
  });


