function suffix(string memory s, string memory) pure returns (string memory) { return s; }

contract C {
    // TODO: This should produce a different error
    string s = "abcd" "" suffix;
}
// ----
// TypeError 8838: (171-187): The type of the literal cannot be converted to the parameter of the suffix function.
