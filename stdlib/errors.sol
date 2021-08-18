// SPDX-License-Identifier: Apache-2.0

uint constant PanicGeneric = 0x00;
uint constant PanicAssert = 0x01;
uint constant PanicUnderOverflow = 0x11;
uint constant PanicDivisionByZero = 0x12;
uint constant PanicEnumConversionError = 0x21;
uint constant PanicStorageEncodingError = 0x22;
uint constant PanicEmptyArrayPop = 0x31;
uint constant PanicArrayOutOfBounds = 0x32;
uint constant PanicResourceError = 0x41;
uint constant PanicInvalidInternalFunction = 0x51;

error Panic(uint code);
error Error(string reason);

function revert() {
  assembly {
    revert(0, 0)
  }
}

function revert(string memory reason) {
  assembly {
    revert(add(reason, 32), mload(reason))
  }
}

function assert(bool condition) {
  if (!condition)
    assembly {
      invalid()
    }
}

function require(bool condition) {
  if (!condition)
    revert();
}

function require(bool condition, string memory reason) {
  if (!condition)
    revert(reason);
}
