// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    // 管理员地址
    address public immutable owner;

    // 记录每个用户存款金额
    mapping(address => uint256) public balances;

    // 存款前3名用户数组
    address[3] public top3Users;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(uint256 totalAmount);

    constructor() {
        owner = msg.sender;
    }

    // 接收ETH存款：用户直接转账到合约地址即可存款
    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    // 可选：deposit函数，也可以主动调用存款
    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    // 内部存款逻辑 + 更新排行榜
    function _deposit(address user, uint256 amount) internal {
        require(amount > 0, "Deposit amount must > 0");
        balances[user] += amount;
        emit Deposit(user, amount);

        // 更新Top3排行榜
        _updateTop3(user);
    }

    // 更新存款前3名
    function _updateTop3(address user) internal {
        uint256 userBalance = balances[user];
        // 取出当前top3
        address[3] memory temp = top3Users;

        // 如果用户已经在排行榜里，先移除旧位置
        for(uint i = 0; i < 3; i++){
            if(temp[i] == user){
                temp[i] = address(0);
                break;
            }
        }

        // 插入新排名，降序排序
        for(uint i = 0; i < 3; i++){
            if(temp[i] == address(0) || userBalance > balances[temp[i]]){
                // 后移腾出位置
                for(uint j = 2; j > i; j--){
                    temp[j] = temp[j-1];
                }
                temp[i] = user;
                break;
            }
        }

        // 写回状态
        top3Users = temp;
    }

    // 仅管理员提取合约全部资金
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds in bank");

        // 转账ETH给管理员
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdraw failed");

        emit Withdraw(balance);
    }

    // 获取前3名用户地址数组
    function getTop3() external view returns(address[3] memory){
        return top3Users;
    }

    // 获取合约当前总余额
    function getContractBalance() external view returns(uint256){
        return address(this).balance;
    }
}
