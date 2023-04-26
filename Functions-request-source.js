// Arguments can be provided when a request is initated on-chain and used in the request source code as shown below
const address = args[0]

if (
  !secrets.apiKey ||
  secrets.apiKey === "Your Cred API key (get a free one: https://beta.credprotocol.com/)"
) {
  throw Error(
    "CRED_API_KEY environment variable not set for Cred API.  Get a free key from https://beta.credprotocol.com/"
  )
}

// build HTTP request object
const credRequest = Functions.makeHttpRequest({
  url: `https://beta.credprotocol.com/api/score/address/`+address+`/`,
  headers: {
    'Content-Type': 'application/json',
    Authorization: ' Token ' + secrets.apiKey,
  },
})

// Make the HTTP request
const credResponse = await credRequest

if (credResponse.error) {
  throw new Error("Cred Error: " + credResponse.response.status)
}

// fetch the score
const score = credResponse.data.value

// Math.round() to round to the nearest integer - in case the return value is a float
// Functions.encodeUint256() helper function to encode the result from uint256 to bytes
return Functions.encodeUint256(Math.round(score))