// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/*
补充完整 Caller 合约 的 delegateSetValue 方法，调用 Callee 的 setValue 方法用于设置 value 值。要求：
• 使用 delegatecall
• 如果发送失败，抛出“delegate call failed”异常并回滚交易。
*/
contract Callee {
    uint256 public value;

    function setValue(uint256 _newValue) public {
        value = _newValue;
    }
}

contract Caller {
    uint256 public value;

    function delegateSetValue(address callee, uint256 _newValue) public {
        // 构造calldata，调用 setValue(uint256)
        bytes memory payload = abi.encodeWithSignature("setValue(uint256)", _newValue);
        // delegatecall：在Caller的存储上下文，执行Callee的代码
        (bool success,) = callee.delegatecall(payload);
        require(success, "delegate call failed");

    }
}
