// CredTag score update CF script

// Arguments can be provided when a request is initated on-chain and used in the request source code as shown below
const id = args[0]

console.log("passed in args:", id)

if (!secrets.apiKey || secrets.apiKey === "Your Cred API key (get a free one: https://beta.credprotocol.com/)") {
  throw Error(
    "CRED_API_KEY environment variable not set for Cred API.  Get a free key from https://beta.credprotocol.com/"
  )
}

// build HTTP request object - Cred
const credRequest = Functions.makeHttpRequest({
  // url: `https://beta.credprotocol.com/api/score/address/`+address+`/`,
  // TODO: change to an endpoint that takes in the ID and returns the score
  url: `https://beta.credprotocol.com/api/score/address/0x00000000219ab540356cbb839cbe05303d7705fa/`,
  headers: {
    "Content-Type": "application/json",
    Authorization: " Token " + secrets.apiKey,
  },
})

// Make the HTTP requests
const credResponse = await credRequest

if (credResponse.error) {
  throw new Error("Cred Error: " + credResponse.response.status)
}

// encode the score and the id into one value
const scoreBinary = (credResponse.data.value >>> 0).toString(2)
console.log("scoreBinary", scoreBinary)
const indexBinary = (id >>> 0).toString(2)
console.log("indexBinary", indexBinary)
console.log("pre-parse result", indexBinary + scoreBinary)
const result = parseInt(indexBinary + scoreBinary, 2)
console.log(result)

// Convert JSON object to a string using JSON.stringify()
// Then encode it to a a bytes using the helper Functions.encodeString
return Functions.encodeUint256(result)
