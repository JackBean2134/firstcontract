// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
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
}
