.. index:: ! event, ! event; anonymous, ! event; indexed, ! event; topic

.. _events:

*********
Eventler
*********

Solidity eventleri EVM'nin loglama işlevinin üzerine bir soyutlama verir. Uygulamalar
Ethereum clientlarının RPC arayüzüne abone olarak bu eventleri dinleyebilirler.

Eventler akıllı sözleşmelerin türetilebilen üyeleridir. Çağrıldıklarında işlemlerin log
kısmında - blok zincirindeki özel bir veri yapısı - depolanırlar. Bu eventler çağrıldıkları
akıllı sözleşmenin adresi ile özdeşleştirilir ve işlemin bulunduğu blok erişilebilir olduğu
sürece bu eventlere de erişilebilir (şu anda bu süre sonsuza kadardır ancak Serenity
ile bu değişebilir). Log ve event verisi akıllı sözleşme tarafından erişilebilir değildir
(eventi oluşturan akıllı sözleşme için bile bu geçerlidir).

Loglar için bir Merkle proof talep etmek mümkündür, bu nedenle external bir varlık
böyle bir kanıtla bir akıllı sözleşme sağlarsa, logun blok zinciri içinde gerçekten var
olup olmadığını kontrol edebilir. Sözleşme yalnızca son 256 blok hashini görebildiği
için blok başlıkları sağlamanız gerekir.

Logun veri kısmı yerine :ref:`"topics" <abi_events>` olarak bilinen özel bir veri yapısına ekleyen
en fazla üç parametreye ``indexed`` özniteliği ekleyebilirsiniz. Bir topic yalnızca tek
bir kelimeyi (32 byte) tutabilir, bu nedenle indekslenmiş bir argüman için bir referans 
tipi kullanırsanız, bunun yerine değerin Keccak-256 hashi topic olarak saklanır.

``indexed`` olmadan kullanılan bütün parametreler logun veri kısmına :ref:`ABI-encoded <ABI>` olarak
saklanır.

Topicler eventleri aramanıza izin verir, örneğin belirli eventler için bir blok dizisini filtrelerken.
Ayrıca eventleri yayınlandıkları akıllı sözleşmede göre de filtreleyebilirsiniz.

Örneğin aşağıdaki kod web3.js'in ``subscribe("logs")``
`methodunu <https://web3js.readthedocs.io/en/1.0/web3-eth-subscribe.html#subscribe-logs>`_ kullanarak
logları belirli bir adrese göre filtreleme işlemi yapmıştır:

.. code-block:: javascript

    var options = {
        fromBlock: 0,
        address: web3.eth.defaultAccount,
        topics: ["0x0000000000000000000000000000000000000000000000000000000000000000", null, null]
    };
    web3.eth.subscribe('logs', options, function (error, result) {
        if (!error)
            console.log(result);
    })
        .on("data", function (log) {
            console.log(log);
        })
        .on("changed", function (log) {
    });

Eventin imzasının hashi, etkinliği anonim belirteçle bildirmeniz dışında, 
topiclerden biridir. Bu, belirli anonim eventleri ada göre filtrelemenin mümkün 
olmadığı, yalnızca akıllı sözleşme adresine göre filtreleyebileceğiniz anlamına gelir. 
Anonim eventlerin avantajı, deploy etmenin ve çağırmanın daha ucuz olmasıdır. 
Ayrıca, üç yerine dört indexed değişken bildirmenize olanak tanır.

.. note::
    İşlem logları değişken türünü değil, yalnızca olay verilerini sakladığından, verileri 
    doğru bir şekilde yorumlamak için hangi parametrenin dizine eklendiği ve 
    eventin anonim olup olmadığı dahil olmak üzere olayın türünü bilmeniz gerekir. 
    Özellikle, anonim bir event kullanarak başka bir eventin imzasını "sahte" yapmak mümkündür.

.. index:: ! selector; of an event

Eventlerin Üyeleri
===================

- ``event.selector``: Anonim olmayan eventlerde ``bytes32`` tipindeki bir değerdir ve
  eventin imzasının hashini içerir ``keccak256``.


Örnek
=======

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.21 <0.9.0;

    contract ClientReceipt {
        event Deposit(
            address indexed from,
            bytes32 indexed id,
            uint value
        );

        function deposit(bytes32 id) public payable {
            // Eventler `emit` sözcüğü ve sonrasında
            // eventin ismi ve parametreleri (varsa) parantez
            // içerisine konularak yayınlanır.
            // Bu şekildeki herhangi bir çağırma işlemi
            // (iç içe olsa bile) `Deposit` ile filtreleme
            // yaparak JavaScript API tarafından yakalanabilir.
            emit Deposit(msg.sender, id, msg.value);
        }
    }

JavaScript API kullanımı ise şu şekildedir:

.. code-block:: javascript

    var abi = /* derleyici tarafından üretilen ABI */;
    var ClientReceipt = web3.eth.contract(abi);
    var clientReceipt = ClientReceipt.at("0x1234...ab67" /* adres */);

    var depositEvent = clientReceipt.Deposit();

    // değişiklikleri izle
    depositEvent.watch(function(error, result){
        // sonuç, `Deposit` çağrısına verilen indekslenmemiş
        // argümanları ve topicleri içerir.
        if (!error)
            console.log(result);
    });


    // veya bir callback fonksiyonu ile direkt olarak dinlemeye başlayabilirsiniz
    var depositEvent = clientReceipt.Deposit(function(error, result) {
        if (!error)
            console.log(result);
    });

Yukarıdaki kod şu şekilde bir çıktı verir (trim edilmiş hali ile):

.. code-block:: json

    {
       "returnValues": {
           "from": "0x1111…FFFFCCCC",
           "id": "0x50…sd5adb20",
           "value": "0x420042"
       },
       "raw": {
           "data": "0x7f…91385",
           "topics": ["0xfd4…b4ead7", "0x7f…1a91385"]
       }
    }

Eventleri Anlamak İçin Ekstra Kaynaklar
=============================================

- `Javascript documentation <https://github.com/ethereum/web3.js/blob/1.x/docs/web3-eth-contract.rst#events>`_
- `Example usage of events <https://github.com/ethchange/smart-exchange/blob/master/lib/contracts/SmartExchange.sol>`_
- `How to access them in js <https://github.com/ethchange/smart-exchange/blob/master/lib/exchange_transactions.js>`_
