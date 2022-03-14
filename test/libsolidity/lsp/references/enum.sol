// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

enum Color {
//   ^ @EnumDef
    Red,
//  ^ @EnumValue
    Green
}

contract MyContract
{
    Color lastColor = Color.Red;
    //        ^ @lastCursorDef

    function sum(Color a) public view returns (Color)
    {
        Color result = Color(a);
        if (a != lastColor)
            result = Color.Green;
        return result;
    }
}

// ----
// -> textDocument/documentHighlight {
//     "position": @EnumDef
// }
// <- [
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 10,
//                 "line": 3
//             },
//             "start": {
//                 "character": 5,
//                 "line": 3
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 9,
//                 "line": 12
//             },
//             "start": {
//                 "character": 4,
//                 "line": 12
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 27,
//                 "line": 12
//             },
//             "start": {
//                 "character": 22,
//                 "line": 12
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 22,
//                 "line": 15
//             },
//             "start": {
//                 "character": 17,
//                 "line": 15
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 52,
//                 "line": 15
//             },
//             "start": {
//                 "character": 47,
//                 "line": 15
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 13,
//                 "line": 17
//             },
//             "start": {
//                 "character": 8,
//                 "line": 17
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 28,
//                 "line": 17
//             },
//             "start": {
//                 "character": 23,
//                 "line": 17
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 26,
//                 "line": 19
//             },
//             "start": {
//                 "character": 21,
//                 "line": 19
//             }
//         }
//     }
// ]
// -> textDocument/documentHighlight {
//     "position": @EnumValue
// }
// <- [
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 7,
//                 "line": 5
//             },
//             "start": {
//                 "character": 4,
//                 "line": 5
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 31,
//                 "line": 12
//             },
//             "start": {
//                 "character": 22,
//                 "line": 12
//             }
//         }
//     }
// ]
// -> textDocument/documentHighlight {
//     "position": @lastCursorDef
// }
// <- [
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 19,
//                 "line": 12
//             },
//             "start": {
//                 "character": 10,
//                 "line": 12
//             }
//         }
//     },
//     {
//         "kind": 1,
//         "range": {
//             "end": {
//                 "character": 26,
//                 "line": 18
//             },
//             "start": {
//                 "character": 17,
//                 "line": 18
//             }
//         }
//     }
// ]
