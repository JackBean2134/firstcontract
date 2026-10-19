// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*编写一个 TokenBank 合约，可以将自己的 Token存入到 TokenBank， 和从 TokenBank 取出。 TokenBank 有两个方法：

1. deposit() : 需要记录每个地址的存入数量。

2. withdraw（）: 用户可以提取自己的之前存入的 token。*/

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
}

contract TokenBank {
    // 记录每个用户在银行里存放的代币数量
    mapping(address => uint256) public userDeposits;
    IERC20 public token;

    // 构造函数：传入ERC20代币合约地址
    constructor(address _tokenAddr) {
        token = IERC20(_tokenAddr);
    }

    // 1. 存入代币：用户必须先对TokenBank做approve授权
    function deposit(uint256 amount) external {
        require(amount > 0, "amount can not be zero");
        // 从调用者账户，把代币转到TokenBank合约
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "deposit failed");
        // 更新用户存款记录
        userDeposits[msg.sender] += amount;
    }

    // 2. 提取自己存入的代币
    function withdraw(uint256 amount) external {
        require(amount > 0, "amount can not be zero");
        require(userDeposits[msg.sender] >= amount, "insufficient deposit");
        // 扣减存款记录
        userDeposits[msg.sender] -= amount;
        // 合约把代币转回用户
        bool success = token.transfer(msg.sender, amount);
        require(success, "withdraw failed");
    }
}
