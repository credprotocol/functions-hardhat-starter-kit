const main = async () => {
  // const contractAddress = process.env.FUNCTIONS_CONTRACT_ADDRESS;
  const contractAddress = "0xA43c2DeA8b2891d14048CdD6E613d2ddC6080253"
  const contract = await hre.ethers.getContractAt("FunctionsConsumer", contractAddress)

  const desiredAddress = "0x185767847fd8f7B3309d78Cf28BD4Dd7b3a0f304"

  await contract.addressId(desiredAddress).then((res) => {
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
