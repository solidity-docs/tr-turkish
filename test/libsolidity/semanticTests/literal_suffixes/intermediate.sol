type Length is uint;

function km(uint x) pure returns (Length) { return Length.wrap(x * 1000); }

struct Float {
    uint mantissa;
    int exponent;
}

function f(uint mat, int exp) pure returns (Float memory) {
  return Float(mat, exp);
}
contract C {
  Length public length = 1000 km;
  Float public factor = 1.23 f;
}
// ====
// compileViaYul: also
// ----
// length() -> 1000000
// factor() -> 0x7b, 2
