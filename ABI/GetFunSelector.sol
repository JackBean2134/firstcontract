// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
contract FunctionSelector {
    uint256 private storedValue;

    function getValue()public view returns(uint) {
        return storedValue;

    }
    function setValue(uint value)public{
        storedValue = value;
    }

    function getFunctionSelector1() public pure returns (bytes4) {
        //return getValue().selector;函数名.selector 语法，只能用于 external 函数类型变量，不能直接写 getValue.selector 在函数体内直接引用本合约函数！
        return bytes4(keccak256(bytes("getValue")));

    }
    function getFunctionSelector2()public pure returns(bytes4)
    {
        //return setValue.selector; 同上
        return bytes4(keccak256(bytes("setValue(uint)")));
    }
    
}