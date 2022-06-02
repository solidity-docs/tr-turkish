function suffix(uint x) pure returns (uint) { return x; }

contract C {
    function f() public pure {
        0.0 suffix;    // TODO: Treated as integer
        0.00 suffix;   // TODO: Treated as integer
        // 0.1 suffix; // TODO: Unimplemented
        // 0.99999999999999999999999999999999999999999999999999999999999999999999999999999999999 suffix; // TODO: Causes an ICE

        1_000.0 suffix;                  // TODO: Treated as integer
        //1_000.1234 suffix;             // TODO: Unimplemented
        //1_000.123_456 suffix;          // TODO: Unimplemented
        //1_000_000.123 suffix;          // TODO: Unimplemented
        //1_000_000.123_456_789 suffix;  // TODO: Unimplemented
    }
}
