// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
}

// 扩展ERC20的回调接口（和之前我们写的BaseERC20对应）
interface IERC20TokensReceived {
    function tokensReceived(address from, uint256 value) external returns (bool);
}

contract TokenBank {
    mapping(address => uint256) public userDeposits;
    IERC20 public token;

    constructor(address _tokenAddr) {
        token = IERC20(_tokenAddr);
    }

    function deposit(uint256 amount) external virtual {
        require(amount > 0, "amount can not be zero");
        bool success = token.transferFrom(msg.sender, address(this), amount);
        require(success, "deposit failed");
        userDeposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "amount can not be zero");
        require(userDeposits[msg.sender] >= amount, "insufficient deposit");
        userDeposits[msg.sender] -= amount;
        bool success = token.transfer(msg.sender, amount);
        require(success, "withdraw failed");
    }
}

// TokenBankV2：继承TokenBank，实现tokensReceived，仅支持transferWithCallback存款
contract TokenBankV2 is TokenBank, IERC20TokensReceived {
    constructor(address _tokenAddr) TokenBank(_tokenAddr) {}

    // 屏蔽旧的deposit方法，不再支持approve+deposit模式
    function deposit(uint256 /*amount*/) external pure override {
        revert("TokenBankV2: please use transferWithCallback");
    }

    /**
     * @notice 由扩展ERC20的transferWithCallback自动回调
     * @param from 代币转账的发送者（存款用户）
     * @param value 转账金额
     * @return 返回true，通知ERC20回调校验通过
     */
    function tokensReceived(address from, uint256 value) external override returns (bool) {
        // 安全校验：只有我们绑定的token合约才允许调用这个回调！
        require(msg.sender == address(token), "TokenBankV2: only token contract can call");
        require(value > 0, "value can not be zero");

        // 记账：增加from用户的存款
        userDeposits[from] += value;

        return true;
    }
}
