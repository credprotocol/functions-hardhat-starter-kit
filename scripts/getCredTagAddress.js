const main = async () => {
  // const contractAddress = process.env.FUNCTIONS_CONTRACT_ADDRESS;
  const contractAddress = "0xA43c2DeA8b2891d14048CdD6E613d2ddC6080253"
  const contract = await hre.ethers.getContractAt("FunctionsConsumer", contractAddress)

  await contract.credTagReference().then((res) => {
    console.log(res)
  })
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
