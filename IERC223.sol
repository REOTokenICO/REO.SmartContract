pragma solidity ^0.4.21;

contract IERC223 {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);

    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);

    function transfer(address to, uint value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
}