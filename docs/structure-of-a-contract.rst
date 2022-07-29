.. index:: contract, state variable, function, event, struct, enum, function;modifier

.. _contract_structure:

***********************
Bir Sözleşmenin Yapısı
***********************

Solidity'deki sözleşmeler, nesne yönelimli dillerdeki sınıflara benzer.
Her kontrat içerisinde şu beyanları bulundurabilir: :ref:`structure-state-variables`, :ref:`structure-functions`,
:ref:`structure-function-modifiers`, :ref:`structure-events`, :ref:`structure-errors`, :ref:`structure-struct-types` ve :ref:`structure-enum-types`.
Ayrıca, sözleşmeler bilgileri diğer sözleşmelerden miras alabilir.

Aynı zamanda :ref:`libraries<libraries>` ve :ref:`interfaces<interfaces>` adı verilen özel sözleşme türleri de vardır.

:ref:`contracts<contracts>` ile ilgili bölüm, bu bölümden daha fazla ayrıntı içerdiğinden
hızlı bir bakış açısı elde etmek adına faydalıdır.

.. _structure-state-variables:

Durum Değişkenleri
===============

Durum değişkenleri, değerleri sözleşmenin deposunda kalıcı olarak saklanan değişkenlerdir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract SimpleStorage {
        uint storedData; // Durum değişkeni
        // ...
    }

Geçerli durum değişkeni tiplerini görmek için :ref:`types` bölümüne ve 
görünürlük hakkındaki olası seçenekler için :ref:`visibility-and-getters` bölümüne bakabilirsiniz.

.. _structure-functions:

Fonksiyonlar
=========

Fonksiyonlar, yürütülebilir kod birimleridir. Fonksiyonlar genellikle 
bir sözleşme içinde tanımlanırlar, ancak sözleşmelerin dışında da tanımlanabilirler.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    contract SimpleAuction {
        function bid() public payable { // Fonksiyon
            // ...
        }
    }

    // Helper fonksiyonu sözleşmenin dışında tanımlı 
    function helper(uint x) pure returns (uint) {
        return x * 2;
    }

:ref:`function-calls` dahili veya harici olarak gerçekleşebilir ve diğer sözleşmelere göre farklı :ref:`visibility<visibility-and-getters>`
seviyelerine sahiptir. :ref:`Functions<functions>` parametre ve değişkenleri birbiri arasında geçirmek için
:ref:`parameters and return variables<function-parameters-return-variables>` kabul eder.

.. _structure-function-modifiers:

Fonksiyon Değiştiriciler
==================

Fonksiyon değiştiriciler fonksiyonların semantiğini bildirimsel bir şekilde değiştirmek için kullanılabilir.
(sözleşmeler bölümündeki :ref:`modifiers` kısmına bakın).

Aşırı yükleme (Overloading), yani aynı değiştirici adını farklı parametrelerle kullanma durumu 
mümkün değildir.


Fonksiyonlar gibi, değiştiriciler de :ref:`overridden <modifier-overriding>` olabilir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract Purchase {
        address public seller;

        modifier onlySeller() { // Değiştirici
            require(
                msg.sender == seller,
                "Only seller can call this."
            );
            _;
        }

        function abort() public view onlySeller { // Değiştirici kullanımı
            // ...
        }
    }

.. _structure-events:

Olaylar
======

Olaylar, EVM için yapılacak olan kayıt işlemlerine kolaylık sağlayan arayüzlerdir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.21 <0.9.0;

    contract SimpleAuction {
        event HighestBidIncreased(address bidder, uint amount); // Olay

        function bid() public payable {
            // ...
            emit HighestBidIncreased(msg.sender, msg.value); // Tetikleyici olay
        }
    }

Olayların nasıl bildirildiği ve bir dapp içinden nasıl kullanılabileceği hakkında bilgi almak için 
sözleşmeler bölümündeki :ref:`events`e bakabilirsiniz.

.. _structure-errors:

Hatalar
======

Hatalar, kodunuzdaki hatalı durumlar için açıklayıcı adlar ve veriler tanımlamanıza olanak sunar.
Hatalar :ref:`revert statements <revert-statement>` içerisinde kullanılabilir.
String tanımlamaları ile karşılaştırıldığında, hatalar çok daha zahmetsizdir 
ve ek verileri kodlamanıza olanak tanır. Hatayı kullanıcıya 
açıklamak için NatSpec'i kullanabilirsiniz.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Transfer için yeterli para yok. `requested` kadar miktar istendi,
    /// ancak sadece `available` miktarda var.
    error NotEnoughFunds(uint requested, uint available);

    contract Token {
        mapping(address => uint) balances;
        function transfer(address to, uint amount) public {
            uint balance = balances[msg.sender];
            if (balance < amount)
                revert NotEnoughFunds(amount, balance);
            balances[msg.sender] -= amount;
            balances[to] += amount;
            // ...
        }
    }

Daha fazla bilgi için sözleşmeler bölümündeki :ref:`errors`a bakın.

.. _structure-struct-types:

Yapı Tipleri
=============

Yapılar, birkaç değişkeni grup halinde bir arada bulunduran özel tanımlı türlerdir (tipler
bölümündeki :ref:`structs` kısmına bakın).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Ballot {
        struct Voter { // Yapı
            uint weight;
            bool voted;
            address delegate;
            uint vote;
        }
    }

.. _structure-enum-types:

Enum Tipleri
==========

Enum'lar 'sabit değerlerden' oluşan ve sınırlı sayıda setler halinde 
oluşturabileceğiniz özel tipler oluşturmanızı sağlar (tipler bölümündeki
:ref:`enums` kısmına bakın).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Purchase {
        enum State { Created, Locked, Inactive } // Enum
    }
