// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*补充完整 Caller 合约 的 sendEther 方法，用于向指定地址发送 Ether。
要求：
使用 call 方法发送 Ether
如果发送失败，抛出“sendEther failed”异常并回滚交易。
如果发送成功，则返回 true
*/

contract Caller {

    // 加上 payable！部署的时候可以附带ETH转入合约
    constructor() payable {}
    function sendEther(address to, uint256 value) public returns (bool) {
        // 使用 call 发送 ether
        require(address(this).balance >= value, "contract insufficient balance");
        require(to != address(0), "cannot send to zero address");
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success,"sendEther failed");
        return success;
    }
    // 查看合约余额，方便调试
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    receive() external payable {}
}