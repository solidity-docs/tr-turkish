.. index:: ! contract;interface, ! interface contract

.. _interfaces:

**********
Interface'ler
**********

Interface'ler abstract contractlara benzerler ama onlardan farklı olarak hiçbir
fonksiyonunun kodu yazılamaz. Daha fazla kısıtlama vardır:

- Diğer contractlardan miras alamazken, diğer interface'lerden alabilirler.
- Interface'deki bütün fonksiyonlar external olmalıdır, contractta public olsalar dahi.
- Constructor tanımlayamazlar.
- Durum değişkeni tanımlayamazlar.
- Modifier tanımlayamazlar.

Bu kısıtlamalardan bazıları ilerleyen zamanlarda kaldırılabilir.

Interface'ler kabaca Contract ABI'sinin temsil edebileciği ile kısıtlıdır. Bu yüzden
ABI ve interface arasındaki dönüşümler bilgi kaybı yaşanmadan gerçekleştirilebilmelidir.

Interface'ler kendi anahtar sözcükleri ile tanımlanırlar:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface Token {
        enum TokenType { Fungible, NonFungible }
        struct Coin { string obverse; string reverse; }
        function transfer(address recipient, uint amount) external;
    }

Contractlar diğer contractlardan miras alabildikleri gibi diğer interface'lerden de alabilirler.

Interface'lerdeki bütün fonksiyonlar gizlici ``virtual`` olarak işaretlenmiş haldedir ve
onları override ederken ``override`` kelimesine gerek yoktur. Bu, otomatik olarak override eden bir
fonksiyonun yeniden override edilebileceği anlamına gelmez - bu yalnızca override  
eden fonksiyon ``virtual`` olarak işaretlenmişse mümkündür.

Interface'ler diğer interfacelerden miras alabilirler, normal kalıtım kuralında olduğu gibi.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    interface ParentA {
        function test() external returns (uint256);
    }

    interface ParentB {
        function test() external returns (uint256);
    }

    interface SubInterface is ParentA, ParentB {
        // Ebeveny anlamlarının uyumlu olduğunu iddia
        // etmek için test yeniden tanımlanmalıdır.
        function test() external override(ParentA, ParentB) returns (uint256);
    }

Interface'lerde tanımlanan tiplere ve diğer contract benzeri yapılara diğer contractlardan 
erişilebilir: ``Token.TokenType`` veya ``Token.Coin``.

.. warning:

    Interfaces have supported ``enum`` types since :doc:`Solidity version 0.5.0 <050-breaking-changes>`, make
    sure the pragma version specifies this version as a minimum.
