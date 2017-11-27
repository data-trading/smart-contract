pragma solidity ^0.4.11;

contract ERC20Interface {
    function totalSupply() public view returns (uint256 totalSupply);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}

contract DataTradingToken is owned, ERC20Interface {
    string public constant symbol = "DTT";
    string public constant name = "DataTradingToken";
    uint256 private _totalSupply;
    uint8 public constant decimals = 18;
    uint256 private _unmintedTokens = 360000000*10**decimals;
    
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function totalSupply() public view returns (uint256 totalSupply){
        totalSupply = _totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
  
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        assert(balances[_to] + _value >= balances[_to]);
        
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        assert(balances[_to] + _value >= balances[_to]);
        
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function mintToken(address target, uint256 _mintedAmount) public onlyOwner returns (bool success){
        require(_mintedAmount <= _unmintedTokens);
        balances[target] += _mintedAmount;
        _unmintedTokens -= _mintedAmount;
        _totalSupply += _mintedAmount;
        return true;
    }
    
    function stopTokenMinting() public onlyOwner returns (bool success){
        _unmintedTokens = 0;
        return true;
    }
}
