// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import {RGBColor as ThatColor} from "../goto/lib.sol";

contract C
{
    function other() public pure returns (ThatColor memory output)
                                                            // ^ @OutputDef
    {
        output.red = 50;
        // ^ @OutputWrite
        output.green = output.red;
        //     ^ @GreenWrite
        output.blue = output.green;
        //                   ^ @GreenUse
    }
}
// ----
// lib: @diagnostics 2072
// -> textDocument/documentHighlight {
//     "position": @OutputWrite
// }
// <- [
//     {
//         "kind": 3,
//         "range": {
//             "end": {
//                 "character": 65,
//                 "line": 7
//             },
//             "start": {
//                 "character": 59,
//                 "line": 7
//             }
//         }
//     },
//     {
//         "kind": 3,
//         "range": {
//             "end": {
//                 "character": 14,
//                 "line": 10
//             },
//             "start": {
//                 "character": 8,
//                 "line": 10
//             }
//         }
//     },
//     {
//         "kind": 3,
//         "range": {
//             "end": {
//                 "character": 14,
//                 "line": 12
//             },
//             "start": {
//                 "character": 8,
//                 "line": 12
//             }
//         }
//     },
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 29,
//                 "line": 12
//             },
//             "start": {
//                 "character": 23,
//                 "line": 12
//             }
//         }
//     },
//     {
//         "kind": 3,
//         "range": {
//             "end": {
//                 "character": 14,
//                 "line": 14
//             },
//             "start": {
//                 "character": 8,
//                 "line": 14
//             }
//         }
//     },
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 28,
//                 "line": 14
//             },
//             "start": {
//                 "character": 22,
//                 "line": 14
//             }
//         }
//     }
// ]
// -> textDocument/documentHighlight {
//     "position": @GreenWrite
// }
// <- [
//     {
//         "kind": 3,
//         "range": {
//             "end": {
//                 "character": 20,
//                 "line": 12
//             },
//             "start": {
//                 "character": 8,
//                 "line": 12
//             }
//         }
//     },
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 34,
//                 "line": 14
//             },
//             "start": {
//                 "character": 22,
//                 "line": 14
//             }
//         }
//     }
// ]
// -> textDocument/documentHighlight {
//     "position": @GreenUse
// }
// <- [
//     {
//         "kind": 3,
//         "range": {
//             "end": {
//                 "character": 20,
//                 "line": 12
//             },
//             "start": {
//                 "character": 8,
//                 "line": 12
//             }
//         }
//     },
//     {
//         "kind": 2,
//         "range": {
//             "end": {
//                 "character": 34,
//                 "line": 14
//             },
//             "start": {
//                 "character": 22,
//                 "line": 14
//             }
//         }
//     }
// ]
