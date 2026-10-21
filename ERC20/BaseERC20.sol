// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// 接收代币回调接口
interface IERC20TokensReceived {
    function tokensReceived(address from, uint256 value) external returns (bool);
}
contract BaseERC20 {
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply; 
    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowances; 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;  
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);  
        return true;   
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");
        
        allowances[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value); 
        return true; 
    }
    // function approve(address _spender, uint256 _value) public returns (bool success) {
    //     // write your code here
    //     allowances[msg.sender][_spender] = _value;
    //     emit Approval(msg.sender, _spender, _value); 
    //     return true; 
    // }存在授权重放竞争漏洞
     function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }
    // 增量授权，规避approve重放竞争漏洞
    function increaseAllowance(address _spender, uint256 _addedValue) public returns(bool){
        allowances[msg.sender][_spender] += _addedValue;
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns(bool){
        uint256 currentAllowance = allowances[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");
        allowances[msg.sender][_spender] -= _subtractedValue;
        emit Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here     
        return allowances[_owner][_spender];
    }
     function transferWithCallback(address _to,uint256 _value)external returns(bool) {
        //基础转账校验
        require(balances[msg.sender]>= _value,"ERC20: transfer amount exceeds balance");

        //执行转账
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);

        //判断目标是否为合约地址
        if(_to.code.length >0){
            //调用目标合约 tokensReceived
            bool ok = IERC20TokensReceived(_to).tokensReceived(msg.sender,_value);
            require(ok,"transferWithCallback: tokensReceived rejected");
        }
        //如果是EOA账户 直接结束 不调用回调
        return true;

    }
}
