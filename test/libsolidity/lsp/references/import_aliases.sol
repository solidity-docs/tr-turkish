// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "../goto/lib.sol" as Imported;
//                          ^ @ImportedDef

contract C
{
    function one(uint lhs, uint rhs) public pure returns (uint result)
    {
        result = Imported.Lib.add(lhs, rhs + 123);
        //       ^ @ImportedUse
    }
    function two(uint lhs, uint rhs) public pure returns (uint result)
    {
        result = one(Imported.Lib.add(lhs, rhs), rhs);
        //                    ^ @LibRef
    }
}
// ----
// lib: @diagnostics 2072
// -> textDocument/documentHighlight {
//     "position": @ImportedDef
// }
// <- [
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 25,
//                 "line": 10
//             },
//             "start": {
//                 "character": 17,
//                 "line": 10
//             }
//         }
//     },
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 29,
//                 "line": 15
//             },
//             "start": {
//                 "character": 21,
//                 "line": 15
//             }
//         }
//     }
// ]
// -> textDocument/documentHighlight {
//     "position": @ImportedUse
// }
// <- [
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 25,
//                 "line": 10
//             },
//             "start": {
//                 "character": 17,
//                 "line": 10
//             }
//         }
//     },
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 29,
//                 "line": 15
//             },
//             "start": {
//                 "character": 21,
//                 "line": 15
//             }
//         }
//     }
// ]
// -> textDocument/documentHighlight {
//     "position": @LibRef
// }
// <- [
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 29,
//                 "line": 10
//             },
//             "start": {
//                 "character": 17,
//                 "line": 10
//             }
//         }
//     },
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 33,
//                 "line": 15
//             },
//             "start": {
//                 "character": 21,
//                 "line": 15
//             }
//         }
//     }
// ]
