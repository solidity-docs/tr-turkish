function e(uint x) pure returns (uint) { return x; }

contract C {
    function f() public pure {
        // Zero
        0.0 e;         // TODO: Treated as integer
        0.00 e;        // TODO: Treated as integer

        // Integer in decimal notation
        1.0000 e;      // TODO: Treated as integer
        9999.0 e;      // TODO: Treated as integer

        // Actual decimal
        // 0.1 e;      // TODO: Unimplemented
        // 0.100000 e; // TODO: Unimplemented
        // 0.123456 e; // TODO: Unimplemented
        // 0.99999999999999999999999999999999999999999999999999999999999999999999999999999999999 e; // TODO: Causes an ICE

        // Number with separators
        // 1_2_3_4_5_6_7_8_9_0.1_2_3_4_5_6_7_8_9_0 e; // TODO: Unimplemented
        1_000.0 e;                                    // TODO: Treated as integer
        1_000.000_000 e;                              // TODO: Treated as integer
        //1_000.1234 e;                               // TODO: Unimplemented
        //1_000.123_456 e;                            // TODO: Unimplemented
        //1_000_000.123 e;                            // TODO: Unimplemented
        //1_000_000.123_456_789 e;                    // TODO: Unimplemented

        // Scientific notation
        //1e-01 e;                                    // TODO: Unimplemented
        //1e-1 e                                      // TODO: Unimplemented
        //1e-10 e;                                    // TODO: Unimplemented
        //1234e-10 e;                                 // TODO: Unimplemented

        // Scientific notation with decimals
        //0.1e0 e;                                    // TODO: Unimplemented
        //0.1e-0 e;                                   // TODO: Unimplemented
        //0.1e-1 e;                                   // TODO: Unimplemented
        //0.1e-10 e;                                  // TODO: Unimplemented
        //1.1e0 e;                                    // TODO: Unimplemented
        //10.1e0 e;                                   // TODO: Unimplemented
        //100.1_111e-2 e;                             // TODO: Unimplemented
        //10.000000000000111e10 e;                    // TODO: Unimplemented
        //10.00000000001111111111222222222233333333334444444444555555555566666666667777777777e76 e; // TODO: Causes an ICE

        //1.23e0 e;                                   // TODO: Unimplemented
        //1.23e1 e;                                   // TODO: Unimplemented
        //1.23e-1 e;                                  // TODO: Unimplemented
        //10.1e-1 e;                                  // TODO: Unimplemented
        //1000.1e-0003 e;                             // TODO: Unimplemented
        //1200.1e-2 e;

        // Scientific notation with separators
        //1_2_34e-10 e;                               // TODO: Unimplemented
        //1_0.123456789123e1_0 e;                     // TODO: Unimplemented
        //1.123_456e3 e;                              // TODO: Unimplemented
        //10_000_000_000.123456789123e1_0 e;          // TODO: Unimplemented
        //10_000_000_000.1_234_56789_123e1_0 e;       // TODO: Unimplemented
        //10_000_000_000.1e-0_0_0_1_0 e;              // TODO: Unimplemented
    }
}
