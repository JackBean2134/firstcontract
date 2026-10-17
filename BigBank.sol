// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ========== IBank 接口 ==========
interface IBank {
    function deposit() external payable;
    function withdraw() external;
    function transferOwner(address newOwner) external;
    function owner() external view returns(address);
}

// ========== Bank 合约，实现 IBank ==========
contract Bank is IBank {
    address public override owner;
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(uint256 amount);
    event OwnerTransferred(address oldOwner, address newOwner);

    constructor() {
        owner = msg.sender;
    }

    // 存款入口
    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    function deposit() external payable override {
        _deposit(msg.sender, msg.value);
    }

    // 内部存款逻辑，virtual 供BigBank重写
    function _deposit(address user, uint256 amount) internal virtual {
        require(amount > 0, "amount >0");
        balances[user] += amount;
        emit Deposit(user, amount);
    }

    // 提款：只有owner可调用，资金转给owner
    function withdraw() external override {
        require(msg.sender == owner, "only owner");
        uint256 bal = address(this).balance;
        require(bal > 0, "no balance");
        (bool ok, ) = payable(owner).call{value: bal}("");
        require(ok, "transfer fail");
        emit Withdraw(bal);
    }

    // 转移管理员权限
    function transferOwner(address newOwner) external override {
        require(msg.sender == owner, "only owner");
        require(newOwner != address(0), "zero addr");
        address old = owner;
        owner = newOwner;
        emit OwnerTransferred(old, newOwner);
    }
}

// ========== BigBank 继承 Bank ==========
contract BigBank is Bank {
    // modifier：存款金额必须大于0.001 ether
    modifier minDeposit(uint256 amount) {
        require(amount > 0.001 ether, "deposit >0.001 ether");
        _;
    }

    // 重写内部_deposit，加上modifier校验
    function _deposit(address user, uint256 amount) internal override minDeposit(amount) {
        super._deposit(user, amount);
    }
}

// ========== Admin合约（Admin自身有owner，核心函数 adminWithdraw(IBank bank) ==========
contract Admin {
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    // 新增：接收ETH
    receive() external payable {}

    // 只有Admin合约自己的owner才能调用这个提款函数
    function adminWithdraw(IBank bank) external {
        require(msg.sender == owner, "only Admin owner");
        bank.withdraw();
    }
}

