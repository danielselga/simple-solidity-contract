const HDWalletProvider = require("@truffle/hdwallet-provider");
const Web3 = require("web3");
const { interface, bytecode } = require("./compile");

const provider = new HDWalletProvider(
  "scissors noble genuine warrior march foam manual unfold eyebrow try sketch run",
  "https://rinkeby.infura.io/v3/b75767ed07d749279c09acbfb691323d"
);

const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log("attempting to deploy account", accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode, arguments: ["Hi there!"] })
    .send({ gas: 1000000, from: accounts[0] });

  console.log("contract deployed to", result.options.address);
  provider.engine.stop();
};

deploy();