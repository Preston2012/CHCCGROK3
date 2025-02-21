

task("impAndEx", "ipersonates an account, and executes one command")
  .addParam("impersonate")
  .setAction(async (args, hre, runSuper) => {
    const web3 = new Web3(hre.config.networks.devnet.url);
    const res = await new Promise(async (resolve, reject) => {
      web3.currentProvider.send({
        method: "hardhat_impersonateAccount",
        params: [args.impersonate],
        jsonrpc: "2.0",
        id: Date.now()
      }, (err, res) => {
        err ? reject(err) : resolve(res);
      });
    });

    if(res.result === true){
      try{
        console.log('ok');
      }
      catch(err){
        console.error({ err });
      }
      finally{
        const res = await new Promise(async (resolve, reject) => {
          web3.currentProvider.send({
            method: "hardhat_stopImpersonatingAccount",
            params: [args.impersonate],
            jsonrpc: "2.0",
            id: Date.now()
          }, (err, res) => {
            err ? reject(err) : resolve(res);
          });
        });
        console.log({ res });
      }
    }
  });


