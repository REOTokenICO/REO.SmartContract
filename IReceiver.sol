pragma solidity ^0.4.21;

contract ContractReceiver {
    struct TKN {
        address sender;
        uint value;
    }

    function tokenFallback(address _from, uint _value) public pure {
        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;

        /* tkn variable is analogue of msg variable of Ether transaction
        *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
        *  tkn.value the number of tokens that were sent   (analogue of msg.value)
        *  tkn.data is data of token transaction   (analogue of msg.data)
        *  tkn.sig is 4 bytes signature of function
        *  if data of token transaction is a function execution
        */
    }
}