contract C {
    event Ev();
    function f() external {}

    bytes32 constant eventSelector = Ev.selector;        // Error: Initial value for constant variable has to be compile-time constant.
}
// ----
// TypeError 8349: (96-107): Initial value for constant variable has to be compile-time constant.
