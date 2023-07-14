// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Functions, FunctionsClient} from "./dev/functions/FunctionsClient.sol";
// import "@chainlink/contracts/src/v0.8/dev/functions/FunctionsClient.sol"; // Once published
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "./CredTag.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//import "hardhat/console.sol";

/**
 * @title Functions Consumer contract
 * @notice This contract is a demonstration of using Functions.
 * @notice NOT FOR PRODUCTION USE
 */
contract FunctionsConsumer is FunctionsClient, ConfirmedOwner {
  using Functions for Functions.Request;

  bytes32 public latestRequestId;
  bytes public latestResponse;
  bytes public latestError;

  mapping(address => uint256) public addressId;
  mapping(uint256 => address) public idAddress;
  uint256 public length;

  CredTag public credTagReference;

  event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

  event CredTagAddressUpdated(CredTag indexed credTagReference);

  event WalletAdded(address indexed walletAddress, uint256 indexed walletId);

  /**
   * @notice Executes once when a contract is created to initialize state variables
   *
   * @param oracle - The FunctionsOracle contract
   */
  // https://github.com/protofire/solhint/issues/242
  // solhint-disable-next-line no-empty-blocks
  constructor(address oracle) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {}

  /**
   * @notice Send a simple request
   *
   * @param source JavaScript source code
   * @param secrets Encrypted secrets payload
   * @param args List of arguments accessible from within the source code
   * @param subscriptionId Funtions billing subscription ID
   * @param gasLimit Maximum amount of gas used to call the client contract's `handleOracleFulfillment` function
   * @return Functions request ID
   */
  function executeRequest(
    string calldata source,
    bytes calldata secrets,
    string[] memory args,
    uint64 subscriptionId,
    uint32 gasLimit
  ) public onlyOwner returns (bytes32) {
    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
    if (secrets.length > 0) {
      req.addRemoteSecrets(secrets);
    }
    if (args.length > 0) req.addArgs(args);

    bytes32 assignedReqID = sendRequest(req, subscriptionId, gasLimit);
    latestRequestId = assignedReqID;
    return assignedReqID;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
    // convert the response to bytes
    uint256 num = uint256(bytes32(response));
    // extract first 10 bits - score
    uint256 score = num & 0x3FF;
    // extract the rest - wallet ID
    uint256 walletId = num >> 10;

    // get the address from the wallet ID
    address walletAddress = idAddress[walletId];

    // call the CredTag contract to update the cred score
    credTagReference.updateCredScore(score, walletAddress);

    latestResponse = response;
    latestError = err;
    emit OCRResponse(requestId, response, err);
  }

  /**
   * @notice Allows the Functions oracle address to be updated
   *
   * @param oracle New oracle address
   */
  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }

  /**
   * @notice Allows the CredTag contract address to be updated
   *
   * @param _credTagAddress New CredTag contract address
   */
  function updateCredTagAddress(CredTag _credTagAddress) public onlyOwner {
    credTagReference = _credTagAddress;
    emit CredTagAddressUpdated(credTagReference);
  }

  /**
   * @notice Adds a new address into the mappings
   *
   * @param _wallet The wallet address to be added
   */
  function addWalletInMappings(address _wallet) public onlyOwner {
    // check if the address is already in the mapping
    if (addressId[_wallet] == 0) {
      // add the args to the addressId mapping if not there already
      // ids start at 1
      length++;
      addressId[_wallet] = length;
      idAddress[length] = _wallet;

      emit WalletAdded(_wallet, length);
    } else {
      revert("Address already in mapping");
    }
  }

  function addSimulatedRequestId(address oracleAddress, bytes32 requestId) public onlyOwner {
    addExternalRequest(oracleAddress, requestId);
  }
}
