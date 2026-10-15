// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.20;

contract Counter {
    //1.状态变量 counter
    uint256  counter;

    //2.get() 获取counter的值
    function get() public view returns (uint256){
        return counter;
    }
    //3.add(x) 加上x
    function add(uint256 x) public{
        counter += x;
    }

    
}