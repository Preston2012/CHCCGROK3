

task("transferFrom", "ipersonates an account, and executes one command")
  .addParam("contract")
  .addParam("to")
  .addParam("token")
  .setAction(async (args, hre, runSuper) => {
    try{
      const abi = require('./abi/erc721.json');
      const web3 = new Web3(hre.config.networks.devnet.url);
      const contract = new web3.eth.Contract(abi, args.contract);

      let owner;
      try{
        owner = await contract.methods.ownerOf(args.token).call();
      }
      catch(err){
        console.warn(22);
        console.warn({ err });
        console.warn(`Call Failed: ownerOf(${args.token})`);
        return;
      }


      try{
        const oneEth = Web3.utils.toWei('1');
        await new Promise(async (resolve, reject) => {
          web3.currentProvider.send({
            method: "hardhat_setBalance",
            params: [owner, '0x'+BigInt(oneEth).toString(16)],
            jsonrpc: "2.0",
            id: Date.now()
          }, (err, res) => {
            if(err)
              return reject(err);
              
            if(res.result)
              return resolve(res);

            return reject(res);
          });
        });
      }
      catch(err){
        console.error(34);
        console.error(err);
        return;
      }


      let impersonateRes;
      try{
        impersonateRes = await new Promise(async (resolve, reject) => {
          web3.currentProvider.send({
            method: "hardhat_impersonateAccount",
            params: [owner],
            jsonrpc: "2.0",
            id: Date.now()
          }, (err, res) => {
            if(err)
              return reject(err);
              
            if(res.result)
              return resolve(res);

            return reject(res);
          });
        });
      }
      catch(err){
        console.error(59);
        console.error({ err });
        return;
      }


      if(impersonateRes.result === true){
        try{
          const res = await contract.methods.transferFrom(owner, args.to, args.token).send({
            from: owner
          });
          console.log({ res });
        }
        catch(err){
          console.error(72);
          console.error({ err });
        }
        finally{
          const res = await new Promise(async (resolve, reject) => {
            web3.currentProvider.send({
              method: "hardhat_stopImpersonatingAccount",
              params: [owner],
              jsonrpc: "2.0",
              id: Date.now()
            }, (err, res) => {
              err ? reject(err) : resolve(res);
            });
          });
          console.log({ res });
        }
      }
      else{
        console.warn({ impersonateRes });
      }
    }
    catch(err){
      console.warn(84);
      console.warn({ err });
    }
  });
