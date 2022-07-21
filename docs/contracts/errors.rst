.. index:: ! error, revert, ! selector; of an error
.. _errors:

*******************************
Hata ve Geri Alma Durumları
*******************************

Solidity'de hatalar gaz-verimli ve kullanışlı bir şekilde kullanıcılara bir işlemin
neden başarısız olduğunu söylemeyi sağlar. Contractın içerisinde veya dışarısında tanımlanabilirler
(interface ve kütüphaneler de dahil).

:ref:`Revert ifadesi <revert-statement>` ile kullanılmalıdır. Bu ifade anlık çağrıda yapılan
bütün değişiklikleri geri alır ve işlemi çağıran kişiye bir hata gönderir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    /// Transfer için yetersiz bakiye. `required` kadar bakiye
    /// olmalıyken, `available` kadar bakiye mevcuttur.
    /// @param available, kullanılabilir bakiye.
    /// @param required, transfer edilmek istenen miktar.
    error InsufficientBalance(uint256 available, uint256 required);

    contract TestToken {
        mapping(address => uint) balance;
        function transfer(address to, uint256 amount) public {
            if (amount > balance[msg.sender])
                revert InsufficientBalance({
                    available: balance[msg.sender],
                    required: amount
                });
            balance[msg.sender] -= amount;
            balance[to] += amount;
        }
        // ...
    }

Hatalar overload veya override edilemez ama türetilebilirler.
Alanları farklı olduğu sürece aynı hata birden fazla kere tanımlanabilir.
Hata örnekleri sadece ``revert`` ifadesi kullanılarak üretilebilir.

Hata, daha sonra zincir dışı bileşene geri dönmek veya onu :ref:`try/catch ifadesiyle <try-catch>`.
yakalamak için geri alma işlemiyle işlemi çağırana veri iletir. Bir hatanın
yalnızca harici bir aramadan geldiğinde yakalanabileceğini, dahili aramalarda veya 
aynı işlevin içinde gerçekleşen geri dönüşlerin yakalanamayacağını unutmayın.

Herhangi bir parametre sağlamazsanız, hata yalnızca dört bayt veriye ihtiyaç duyar
ve zincirde depolanmayan hatanın ardındaki nedenleri daha fazla açıklamak için
:ref:`NatSpec'i <natspec>` yukarıdaki gibi kullanabilirsiniz. Bu, bunu aynı zamanda çok ucuz ve 
kullanışlı bir hata raporlama özelliği yapar.

Daha spesifik olarak, bir hata örneği, aynı ad ve türdeki bir işleve yapılan bir işlev
çağrısıyla aynı şekilde ABI ile kodlanır ve daha sonra geri alma işlem kodunda dönüş
verileri olarak kullanılır. Bu, verilerin 4 baytlık bir fonksiyon selector'ünün ve ardından :ref:`ABI-encoded<abi>`
verilerden oluştuğu anlamına gelir. Selector, hata türünün imzasının keccak256 hash'inin
ilk dört baytından oluşur.

.. note::
    Bir sözleşmenin aynı adı taşıyan farklı hatalarla veya hatta işlemi çağıran tarafından ayırt edilemeyen 
    farklı yerlerde tanımlanan hatalarla geri dönmesi mümkündür. 
    Dışarıdan, yani ABI için, tanımlandığı sözleşme veya dosya değil, yalnızca hatanın adı önemlidir.



``require(condition, "description");`` ifadesi ile
``if (!condition) revert Error("description")`` ifadesi eğer hata
``error Error(string)`` bu şekilde tanımlanmışsa, aynı işi yapar.
``Error`` tipinin bir built-in tipi olduğunu ve kullanıcı tarafından tanımlanamayacağını unutmayın.

Benzer olarak bir ``assert`` ile tespit edilen bir başarısızlık, yine bir built-in
tipi olan ``Panic(uint256)`` ile geri alınacaktır.

.. note::
    Hata verileri sadece bir başarısızlığı işaret etmek için kullanılmalıdır,
    kontrol akışı için kullanılmamalıdır. Bunun nedeni, dahili çağrıların geri
    alınan verilerinin, varsayılan olarak harici çağrılar zinciri boyunca geri
    yayılmasıdır. Bu, bir iç çağrının, kendisini çağıran sözleşmeden gelmiş gibi
    görünen verileri "sahte" hale getirebileceği anlamına gelir.

Hataların Üyeleri
=================

- ``error.selector``: Hatanın selector'ünü içeren ``bytes4`` dört baytlık bir değer.
