const main = async () => {
  // const contractAddress = process.env.FUNCTIONS_CONTRACT_ADDRESS;
  const contractAddress = "0xA43c2DeA8b2891d14048CdD6E613d2ddC6080253"
  const contract = await hre.ethers.getContractAt("FunctionsConsumer", contractAddress)

  // let txn = await contract.updateCredTagAddress(process.env.CRED_TAG_CONTRACT_ADDRESS);
  let txn = await contract.updateCredTagAddress("0x05Da84CC36C95C8A067B3FBaF6ddc0e2b0F86880")
  console.log("oracle address update complete")
  console.log("(txn hash:", txn.hash, ")")
}

const runMain = async () => {
  try {
    await main()
    process.exit(0)
  } catch (error) {
    console.log(error)
    process.exit(1)
  }
}

runMain()
