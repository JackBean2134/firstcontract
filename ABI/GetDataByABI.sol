// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*补充完整getDataByABI，对getData函数签名及参数进行编码，调用成功后解码并返回数据
• 补充完整setDataByABI1，使用abi.encodeWithSignature()编码调用setData函数，确保调用能够成功
• 补充完整setDataByABI2，使用abi.encodeWithSelector()编码调用setData函数，确保调用能够成功
• 补充完整setDataByABI3，使用abi.encodeCall()编码调用setData函数，确保调用能够成功*/
contract DataStorage {
    
    string private data;
    function setData(string memory newData) public{
        data = newData;
    }
    function getData() public view returns (string memory){
        return data;
    }
}
contract DataConsumer {
    address private dataStorageAddress;
    constructor(address _dataStorageAddress) {
        //零地址校验
        require(_dataStorageAddress != address(0), "zero address not allowed");
        dataStorageAddress = _dataStorageAddress;
    }

    function getDataByABI()public returns (string memory) {
        bytes memory payload = abi.encodeWithSignature("getData()");
        (bool success, bytes memory data)=dataStorageAddress.call(payload);
        require(success, "call function failed");
        //校验合法ABI string返回数据长度
        require(data.length >= 64, "invalid return data");
        return abi.decode(data, (string));

    }
    function setDataByABI(string calldata newData) public returns(bool){
        //abi.encodeWithSignature :一步生成完整调用载荷
        bytes memory payload = abi.encodeWithSignature("setData(string)", newData);
        (bool success,) = dataStorageAddress.call(payload);
        return success;
    }
    function setDataByABI2(string calldata newData)public returns(bool){
        //使用abi.encodeWithSelector()编码调用setData函数
        bytes4 sel = bytes4(keccak256(bytes("setData(string)")));
        bytes memory payload = abi.encodeWithSelector(sel, newData);
        (bool success,)= dataStorageAddress.call(payload);
        return success;
    }
    function setDataByABI3(string calldata newData) public returns (bool){
        //使用abi.encodeCall()编码调用setData函数
       bytes memory payload = abi.encodeCall(DataStorage.setData,(newData));
       (bool success,) =dataStorageAddress.call(payload);
       return success;

    }
    
}