import "./contract.sol";

contract C {
  using Contract for address;
  using Contract for address payable;
  function f(address x) public returns (bytes memory) {
    if (x.codesize() != 0 && x.exists() && x.hasCode()) {
      return x.code();
    }
    address payable y = payable(x);
    y.transfer_(55);
  }
}
