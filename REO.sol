pragma solidity ^0.4.21;

import 'https://github.com/REOTokenICO/REO.SmartContract/blob/master/IERC223.sol';
import 'https://github.com/REOTokenICO/REO.SmartContract/blob/master/IReceiver.sol';
import 'https://github.com/REOTokenICO/REO.SmartContract/blob/master/Ownable.sol';
import 'https://github.com/REOTokenICO/REO.SmartContract/blob/master/SafeMath.sol';


contract REOToken is IERC223, Ownable{
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint8 public decimals = 18;         // How many decimals to show. To be standard complicant keep it 18
    string public name;                 // Token name
    string public symbol;               // Identifier
    uint256 public totalAmount;         // Total Token for hold crowdsale time
    uint256 public totalSupply;         // Total Token was supplied
    uint64 public startTime;            // Time start crowdsale
    uint64 public stopTime;             // Time stop crowdsale
    address public fundsWallet;         // ETH wallet


    // constructor
    function REOToken (
        address _fundsWallet
    ) public {
        fundsWallet = _fundsWallet;

        totalAmount = 3 * (uint256(10)**9) * (uint256(10)**uint256(decimals));      // 3 billion tokens will be sale
        totalSupply = totalAmount * 20 / 100;                                       // 20% total amount was initial when deploy smart contract
                                                                                    // 80% will be mint in crowdsale time
        name = "REO Token";                                                         // Name of Token
        symbol = "REO";                                                             // Identifier of Token
        startTime = 1525471200;                                                     // Start time: May 05 0:00:00 AM GMT+2
        stopTime = 1533333599;                                                      // Stop time: June 30 11:59:59 PM GMT+2
        balances[fundsWallet] = totalSupply;                                        // The first supplied token be owned by fundsWallet
    }


    // minimum purchase: 0.5 ETH
    uint256 public minPurchaseInWei = 0.5 ether;

    function isMinimum() private view returns (bool) {
        return(msg.value >= minPurchaseInWei);
    }


    // calculate current rate
    // rate for crowdsale
    // use in fallback function
    function currentRate() private view returns (uint){
        // from May 05 0:00:00AM GMT+2 to May 18 23:59:59PM GMT+2 in Unix time
        if (now >= startTime && now < startTime + 14 days)
            return 125000;
        // from May 19 0:00:00AM GMT+2 to June 08 23:59:59PM GMT+2 in Unix time
        else if (now >= startTime + 14 days && now < startTime + 35 days)
            return 90909;
        // from June 09 0:00:00AM GMT+2 to June 29 23:59:59PM GMT+2 in Unix time
        else if (now >= startTime + 35 days && now < startTime + 56 days)
            return 71429;
        // from June 30 0:00:00AM GMT+2 to July 20 23:59:59PM GMT+2 in Unix time
        else if (now >= startTime + 56 days && now < startTime + 77 days)
            return 58824;
        // from July 21 0:00:00AM GMT+2 to August 04 23:59:59PM GMT+2 in Unix time
        else if (now >= startTime + 77 days && now <= stopTime)
            return 50000;
        else
            return 0;
    }


    // fallback function will be called when have someone send ether to this contract address
    function () public payable {
        require(crowdsaleRunning());
        require(isMinimum());
        uint _rate = currentRate();
        uint256 _amount = msg.value * _rate;
        mintToken(_amount);
    }


    // get function standard erc223 token
    // get name of token
    function name() public view returns (string) { return name; }
    // get symbol (identifier) of token
    function symbol() public view returns (string) { return symbol; }
    // how many decimals to show
    function decimals() public view returns (uint8) { return decimals; }
    // total token was supplied
    function totalSupply() public view returns (uint256) { return totalSupply; }
    // number of all token will be sale in crowdsale time
    function totalAmount() public view returns (uint256) { return totalAmount; }
    // time to start crowdsale
    function startTime() public view returns (uint256) { return startTime; }
    // time to stop crowdsale
    function stopTime() public view returns (uint256) { return stopTime; }
    // get balance of address (token)
    function balanceOf(address _address) public view returns (uint256) { return balances[_address]; }
    // get current rate
    function getRate() public view returns (uint256) { return currentRate(); }
    // get all rate in crowdsale time
    function getAllRates() public pure returns (string) {
        return "{1525471200:125000,1526680800:90909,1528495200:71429,1530309600:58824,1532124000:50000}";
    }
    // get fund raised, ether in contract
    function fundRaised() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }


    // transfer function
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    /* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(crowdsaleRunning());
        if (isContract(_to))
            return transferToContract(_to, _value);
        else
            return transferToAddress(_to, _value);
    }

    // Allow the owner to transfer tokens from the token contract
    function issueTokens(address _to, uint256 _amount) public onlyOwner {
        require(crowdsaleRunning());
        mintTokenExchange(_to, _amount);
    }

    // Allow the owner to manually transfer the collected ether
    // after the crowdsale has ended.
    function transferCollectedEther(address _to) public onlyOwner {
        require(_to != 0x0);
        require(!crowdsaleRunning());
        _to.transfer(address(this).balance);
    }    
    

    // Private function
    // crowdsaleRunning
    function crowdsaleRunning() private view returns (bool) {
        return (now >= startTime && now <= stopTime);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    /* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol */
    function isContract(address _addr) private view returns (bool) {
        uint length;
        assembly { let length := extcodesize(_addr) }
        return (length > 0);
    }


    // buy, mint token function, use in fallback function
    function mintToken(uint256 _amount) private {
        require(totalSupply + _amount <= totalAmount);
        totalSupply = totalSupply.add(_amount);
        balances[msg.sender] = balanceOf(msg.sender).add(_amount);
        emit Transfer(0x0, fundsWallet, _amount);
        emit Transfer(fundsWallet, msg.sender, _amount);
    }

    // Allow the owner to transfer tokens from the token contract
    function mintTokenExchange(address _to, uint256 _amount) private {
        require(_to != 0x0);
        assert(_amount > 0);
        require(totalSupply + _amount <= totalAmount);
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balanceOf(_to).add(_amount);
        emit Transfer(0x0, fundsWallet, _amount);
        emit Transfer(fundsWallet, _to, _amount);
    }


    //function that is called when transaction target is an address
    /* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol */
    function transferToAddress(address _to, uint256 _value) private returns (bool) {
        require(_to != 0x0);
        require(balanceOf(msg.sender) > _value);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    //function that is called when transaction target is a contract
    /* https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol */
    function transferToContract(address _to, uint256 _value) private returns (bool) {
        require(_to != 0x0);
        require(balanceOf(msg.sender) > _value);
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
        balances[_to] = balanceOf(_to).add(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}
