// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
/*
补充完整 Caller 合约的 callSetValue 方法，用于设置 Callee 合约的 value 值。要求：

使用 call 方法调用 Callee 的 setValue 方法，并附带 1 Ether
如果发送失败，抛出“call function failed”异常并回滚交易。
如果发送成功，则返回 true
*/
contract Callee {
    uint256 value;

    function getValue() public view returns (uint256) {
        return value;
    }

    function setValue(uint256 value_) public payable {
        require(msg.value > 0);
        value = value_;
    }
}

contract Caller {
    function callSetValue(address callee, uint256 value) public returns (bool) {
        // 校验Caller合约自身余额足够转出1 ETH，修正拼写 banlance → balance
        require(address(this).balance >= 1 ether,"caller balance not enough");
        // 编码calldata：调用 setValue(uint256)，传入参数value
        bytes memory payload = abi.encodeWithSignature("setValue(uint256)",value);
        (bool success,) = callee.call{value:1 ether}(payload);
        require(success,"call function failed");
        return success;
    }
    // 必须要有，让Caller合约可以接收ETH，才能转出1 ether
    receive() external payable {}

    // 余额查询，调试用
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
}
