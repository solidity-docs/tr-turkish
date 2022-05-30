// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

   import "test.sol";
// ^^^^^^^^^^^^^^^^^^ @BadInclude

contract SomeContract
{
}
// ----
// bad_include: @BadInclude 6275
