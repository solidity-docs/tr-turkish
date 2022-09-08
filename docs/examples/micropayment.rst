********************
Mikro Ödeme Kanalı
********************

Bu bölümde bir ödeme kanalı örneğinin nasıl yapılacağını öğreneceğiz. 
Bu sistem belli kişiler arasındaki Ether transferini güvenli, anında
ve işlem masrafsız gerçekleştirmek için kriptografik imzaları kullanacak.
Bu örnek için, imzaların nasıl imzalandığını ve doğrulandığını anlamamız
gerekiyor.

İmza Oluşturma ve Doğrulama
=================================

Mesela Alice Bob'a bir miktar Ether göndermek istiyor.
Başka bir deyişle Alice gönderici Bob ise alıcı.

Alice'in Bob'a, çek yazmaya benzer bir şekilde, sadece
kriptografik olarak imzalanmış off-chain (zincir dışı)
bir mesaj göndermesi yeterli. 

Alice ve Bob bu imzaları ödemeleri yetkilendirmek için kullanabilirler ve bu Ethereum üzerindeki akıllı kontratlar
ile mümkün olan bir şey. Alice Ethere göndermek için basit bir akıllı kontrat yazacak ancak bu fonksiyonu kendi
çağırmak yerine Bob'un çağırmasını isteyecek böylece Bob işlem masraflarını da ödemiş olacak.

Kontrat aşağıdaki şekilde ilerleyecek.

    1. Alice içine ödeme için gerekli Ether'i de ekleyerek ``ReceiverPays`` kontratını yayınlayacak.
    2. Alice ödemeyi gizli anahtarı ile imzalayarak yetkilendirecek.
    3. Alice kriptografik olarak imzalanmış mesajı Bob'a gönderecek. Mesajın gizli tutulmasına 
       (daha sonra açıklanacak) gerek yok ve mesaj herhangi bir yöntem ile gönderilebilir.  
    4. Bob imzalanmış mesajı akıllı kontrata girerek ödemesini alabilir, akullı kontrat mesajın 
       gerçekliğini doğrular ve ödemeyi serbest bırakır.

İmza oluşturma
----------------------

Alice'in ödemeyi imzlamak için Ethereum ağı ile etkileşime
girmesine gerek yok, bu işlem tamamiyle çevrimdışı gerçekleştirilebilir.
Bu eğitimde, mesajları tarayıcıda  `web3.js <https://github.com/ethereum/web3.js>`_
ve `MetaMask <https://metamask.io>`_ kullanarak ve getirdiği güvenlik kazançları
için `EIP-712 <https://github.com/ethereum/EIPs/pull/712>`_
gösterilen metot ile imzalayacağız.

.. code-block:: javascript

    /// En başta "Hash"leme işleri daha kolay bir hale getirir 
    var hash = web3.utils.sha3("imzalanacak mesaj");
    web3.eth.personal.sign(hash, web3.eth.defaultAccount, function () { console.log("İmzalandı"); });

.. note::
  ``web3.eth.personal.sign`` mesajın uzunluğunu imzalanmış bilginin başına
  ekler. İlk olarak "hash"lediğimiz için, mesaj her zaman 32 bayt uzunluğunda
  olacak ve dolayısıyla bu uzunluk ön eki her zaman aynı olacak.

Ne İmzalanacak
------------

Ödeme gerçekleştiren bir kontrat için, imzalanmış bir mesaj aşağıdakiler içermeli:

    1. Alıcının adresi.
    2. Transfer edilecek miktar.
    3. Tekrarlama saldırılarına karşı önlem

Tekrarlama saldırısı, imzalanmış bir mesajın tekrar
yetkilendirme için kullanılmasıdır. Tekrarlama saldırılarını önlemek için
Ethereum işlemlerinden kullanan bir cüzdandan yapılan işlem sayısını, nonce,
kullanan tekniği kullanacğız. Akıllı kontrat bir `nonce`un bir kaç kez kullanılıp
kullanılmadığını kontrol edecek.

Başka bir tekrarlamma saldırısı açığı ödemeyi gönderen kişi ``ReceiverPays`` akıllı kontratını yayınlayıp
sonrasında yok edip sonra tekrar yayınladığında oluşur. Bunun sebebi tekrar yayınlanan kontrat önceki kontratta
kullanılan `nonce`ları bilemediğinden saldırgan eski mesajları tekrar kullanabilir.

Alice buna karşı korunmak için kontratın adresini de mesajın içerisine ekleyebilir.
Böylece sadece kontrat'ın adresini içeren mesajlar onaylanır. Bu örneği bu bölümün
sonundaki tam kontratın ``claimPayment()`` fonksiyonundaki ilk iki satırda görebilirsiniz.

Argümanları Paketleme
-----------------

Şimdi imzalanmış mesajımızda nelerin olacağına karar verdiğimize göre mesajı
mesajı oluşturup, hashleyip, imzalamaya hazırız. Basit olsun diye verileri art 
arda bağlayacağız. `ethereumjs-abi <https://github.com/ethereumjs/ethereumjs-abi>`_
kütüphanesi bize ``soliditySHA3`` adında Solidity'deki ``abi.encodePacked`` ile enkode 
edilmiş argümanlara ``keccak256`` fonksiyonu uygulanması  ile aynı işlevi gören bir
fonksiyon sağlıyor. Aşağıda ``ReceiverPays`` için düzgün bir imza sağlayan JavaScript
fonksiyonunu görebilirsiniz.

.. code-block:: javascript

    // recipient alıcı adres,
    // amount, wei cinsinden, ne kadar gönderilmesi gerektiği
    // nonce, tekrarlama saldırılarını önlemek için eşsiz bir sayı
    // contractAddress, kontratlar arası tekrarlama saldırısını engellemek için kontrat adresi
    function signPayment(recipient, amount, nonce, contractAddress, callback) {
        var hash = "0x" + abi.soliditySHA3(
            ["address", "uint256", "uint256", "address"],
            [recipient, amount, nonce, contractAddress]
        ).toString("hex");

        web3.eth.personal.sign(hash, web3.eth.defaultAccount, callback);
    }

Solidity'de İmzalayanı Bulma
-----------------------------------------

Genelde ECDSA imzaları iki parametreden oluşur, ``r`` 
ve ``s``. Ethereum'daki imzalar ``v`` denilen üçüncü bir
parametre daha içerir. ``v`` parametresi ile mesajı imzalamak
için kullanılmış cüzdanın gizli anahtarı doğrulanabiliyirsiniz.
Solidity :ref:`ecrecover <mathematical-and-cryptographic-functions>`
fonksiyonunu gömülü olarak sağlamaktadır. Bu fonksiyon mesajla birlikte
``r``, ``s`` ve ``v`` parametrelerini de alır ve mesajı imzalamak için
kullanılmış adresi verir.

İmza Parametrelerini Çıkartma
-----------------------------------

web3.js ile oluşturulmuş imzalar ``r``, ``s`` ve ``v``'in birleştirilmesi
ile oluşturulur, yani ilk adım bu parametreleri ayırmak. Bunu kullanıcı tarafında
da yapabilirsiniz ancak parametre ayırma işleminin akıllı kontratın içinde 
olması akıllı kontrata üç parametre yerine sadece bir parametre göndermemizi sağlar.
Bir bayt dizisini (byte array) bileşenlerine ayırmak biraz karışık dolayısıyla bu
işlemi ``splitSignature`` fonksiyonunda yapmak için :doc:`inline assembly <assembly>` 
kullanacağız. (Bu bölümün sonundaki tam kontrattaki üçüncü fonksiyon.)

Mesaj Hashini Hesaplama
--------------------------

Akıllı kontratın tam olarak hangi parametrelerin izalandığını bilmesi gerekiyor çünkü
kontratın imzzayı doğrulamak için mesajı parametrelerinden tekrar oluşturması lazım.
``claimPayment`` fonksiyonundaki ``prefixed`` ve ``recoverSigner`` fonksiyonları bu işlemi
gerçekleştiriyor.

Tam Kontrat
-----------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract ReceiverPays {
        address owner = msg.sender;

        mapping(uint256 => bool) usedNonces;

        constructor() payable {}

        function claimPayment(uint256 amount, uint256 nonce, bytes memory signature) external {
            require(!usedNonces[nonce]);
            usedNonces[nonce] = true;

            // istemcide imzalanmış mesajı tekrar oluşturur.
            bytes32 message = prefixed(keccak256(abi.encodePacked(msg.sender, amount, nonce, this)));

            require(recoverSigner(message, signature) == owner);

            payable(msg.sender).transfer(amount);
        }

        /// sözleşmeyi yok eder ve kalan parayı geri alır
        function shutdown() external {
            require(msg.sender == owner);
            selfdestruct(payable(msg.sender));
        }

        /// imza methodları
        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // uzunluk önekinden sonraki ilk 32 bayt.
                r := mload(add(sig, 32))
                // ikinci 32 bayt
                s := mload(add(sig, 64))
                // son bayt (gelecek 32 baytın son baytı)
                v := byte(0, mload(add(sig, 96)))
            }

            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

            return ecrecover(message, v, r, s);
        }

        /// eth_sign'i kopyalayan önüne eklenmiş hash oluşturur.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


Basit Bir Ödeme Kanalı Yazmak
================================

Alice şimdi ödeme basit ama tam işlevsel bir ödeme kanalı oluşturacak.
Ödeme kanalları anında ve masrafsız tekrarlayan Ether transferleri gerçekleştirmek
için kriptografik imzaları kullanırlar.

Ödeme Kanalı Nedir?
--------------------------

Ödeme kanalları katılımcıların herhangi bir işlem gerçekleştirmeden
tekrarlayan Ether transferleri gerçekleştirmelerini sağlar. Bu sayesede
ödemeyle ilgili gecikme ve masraflardan kurtulabilirsiniz. Şimdi iki kişi
(Alice ve Bob) arasında tek yönlü bir ödeme kanalı nasıl oluşturul onu göreceğiz.
Böyle bir sistemi 3 adımda oluşturabiliriz. Bunlar:

    1. Alice ödeme kanalına Ether yükler böylece ödeme kanali "açık" hale gelir.
    2. Alice ne kadar Ether'in ödenmesi gerektiğini bir mesajda belirtir. Bu adım her ödemede tekrar gerçekleştirilir.
    3. Bob Ether ödemesini alıp kalanı geri göndererek ödeme kanalını kapatır.

.. note::
  Sadece 1. ve 3. adımlar Ethereum işlemi gerektiriyor. 2. adımda gönderici
  kriptografik olarak imzalanmış mesajı alıcıya zincir dışı (off-chain) bir 
  şekilde (mesela e-posta) gönderebilir. Kısaca herhangi bir sayıda transfer için
  2 Ethereum işlemi gerekiyor.

Bob kesinlikle parasını alacak çünkü Ether bir akıllı kontratta tutuluyor ve
geçerli bir imzalı mesaj ile akıllı kontratlar her zaman işlemi gerçekleştirir.
Akıllı kontrat ayrıca zaman aşımını da zorunlu tutar, yani alıcı parası almazsa
Alice eninde sonunda parasını geri alabilir. Zaman aşımının süresine katılımcılar
kendi karar verir. İnternet kafedeki kullanım süresi gibi kısa süreli bir işlem için,
ödeme kanalı süreli bir şekilde oluşturulabilir. Diğer bir yandan, bir çalışana saatlik
maaşını ödemek gibi tekrarlayan bir ödeme için ödeme kanalı bir kaç ay ya da yıl açık kalabilir.

Ödeme Kanalını Açma
---------------------------

Ödeme kanalını açmak için Alice içine gerekli Ether'i ekleyip ve alıcının
kim olduğunu girerek akıllı kontratı yayınlar. Bu işlemi bölümün sonundaki kontratta
``SimplePaymentChannel`` fonksiyonu gerçekleştirir.

Ödeme Gerçekleştirme
---------------

Alice ödemeyi Bob'a imzalanmış mesajı göndererek yapar. Bu adım tamammiyle
Etherum ağının dışında gerçekeleşir. Mesaj gönderici tarafında kriptografik olarak imzalanır ve direkt
olarak alıcıya gönderilir.

Her mesaj aşağıdaki bilgileri içerir:

    * Akıllı kontratın adresi, kontratlar arası tekrarlama saldırılarını önlemek için.
    * Alıcıya borçlu olunan Ether miktarı.

Ödeme kanalı bütün transferler gerçekleştikten sonra sadece bir kez kapanır.
Bundan dolayı sadece bir mesajın ödemesi gerçekleşir. Bu yüzden her mesaj küçük ödemeler
yerine toplam gönderilmesi gereken Ether miktarını içerir. Alıcı doğal olarak en yüksek miktarı
alabilmek için en güncel mesajın ödemesini alır. Artık akıllı kontrat sadece bir mesaj okuduğunderstan
artık işlem sayısını (nonce) mesaja eklemeye gerek yok ancak akıllı kontratın adresine mesajın başka bir
ödeme kanalında kullanılmaması için hala ihtiyaç var.

Aşağıda önceki bölümdeki mesajın kriptografik imzalanmasını sağlayan JavaScript kodunun düzenlenmiş bir halini bulabilirsiniz.

.. code-block:: javascript

    function constructPaymentMessage(contractAddress, amount) {
        return abi.soliditySHA3(
            ["address", "uint256"],
            [contractAddress, amount]
        );
    }

    function signMessage(message, callback) {
        web3.eth.personal.sign(
            "0x" + message.toString("hex"),
            web3.eth.defaultAccount,
            callback
        );
    }

    // contractAddress, kontratlar arası tekrarlama saldırısını engellemek için kontrat adresi
    // amount, wei cinsinden, ne kadar gönderilmesi gerektiği

    function signPayment(contractAddress, amount, callback) {
        var message = constructPaymentMessage(contractAddress, amount);
        signMessage(message, callback);
    }


Ödeme Kanalını Kapatma
---------------------------

Bob ödemesini almaya hazır olduğunda ödeme kanalını da ``close`` fonksiyonunu
çağırarak kapatmanın vakti de gelmiş demektir. Kanal kapatıldığında alıcı kendine borçlu
olunan Ether miktarını alır ve kalan miktarı Alice'e geri göndererek kontratı yok eder.
Bob sadece Alice tarafında imzalanmış bir mesaj ile kanalı kapatabilir.

Akıllı kontratın göndericiden gelen geçerli bir mesajı doğrulaması gerekir. Bu doğrulama süreci
alıcının kullandığı süreç ile aynıdır. Solidity fonksiyonlarından ``isValidSignature`` ve ``recoverSigner`` (``ReceiverPays`` kontratından aldık)
önceki bölümdeki JavaScript hallerindekiyle aynı şekilde çalışır.

Sadece ödeme kanalının alıcısı ``close`` fonksiyonunu çağırabilir. Alıcı da doğal olarak en yüksek miktarı
taşığı için en güncel mesajı gönderir. Eğer gönderici bu mesajı çağırabiliyor olsaydı daha düşük bir miktar içeren bir mesaj
ile çağırıp, ödemeleri gerekenden daha düşük bir para göndererek hile yapabilirlerdi.

Fonksiyon verilen parametreler ile imzalanmış mesajı doğrular. Eğer her şey uygunsa, alıcıya kendi payına düşen
Ether miktraı gönderilir ve göndericiye kalan miktar ``selfdestruct`` ile gönderilir. Tam kontratta ``close`` fonksiyonunu görebilirsiniz.

Kanalın Zaman Aşımına Uğraması
-------------------

Bob istediği zaman ödeme kanalını kapatabilir anca kapatmazsa Alice'in bir 
şekilde parasını geri alması gerekiyor. Bunun için kontrata bir *zaman aşımı* 
süresi girilir. Süre dolduğun, Alice ``claimTimeout`` fonksiyonunu çağırarak
içerideki parasını geri alabilir. ``claimTimeout`` fonksyionunu tam kontratta görebilirsiniz.

Bu fonksiyon çağırıldıktan sonra Bob artık sistemden Ether alamaz dolayısıyla Bob'un zamman aşımına
uğramadan parasını alması oldukça önemli.

Tam Kontrat
-----------------

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract SimplePaymentChannel {
        address payable public sender;      // göndericinin adresi.
        address payable public recipient;   // alıcının adresi.
        uint256 public expiration;  // kapanmaması durumunda zaman aşımı süresi.

        constructor (address payable recipientAddress, uint256 duration)
            payable
        {
            sender = payable(msg.sender);
            recipient = recipientAddress;
            expiration = block.timestamp + duration;
        }

        /// alıcı, göndericinin imzalı mesajı ile istediği zaman kanalı kapatabilir.
        /// alıcı alacaklısı olduğu miktarı alıp
        /// kalanı göndericiye geri gönderir.
        function close(uint256 amount, bytes memory signature) external {
            require(msg.sender == recipient);
            require(isValidSignature(amount, signature));

            recipient.transfer(amount);
            selfdestruct(sender);
        }

        /// gönderici zaman aşımı süresini istediği zaman arttırabilir
        function extend(uint256 newExpiration) external {
            require(msg.sender == sender);
            require(newExpiration > expiration);

            expiration = newExpiration;
        }

        /// Eğer süre alıcı kanalı kapatmadan dolarsa
        /// Ether göndericiye geri döner
        function claimTimeout() external {
            require(block.timestamp >= expiration);
            selfdestruct(sender);
        }

        function isValidSignature(uint256 amount, bytes memory signature)
            internal
            view
            returns (bool)
        {
            bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));

            // imzanın göndericiden geldiğini kontrol et
            return recoverSigner(message, signature) == sender;
        }

        /// Aşağıdaki tüm konksyionlar 'imza oluşturma ve doğrulama'
        /// bölümünden alındı.

        function splitSignature(bytes memory sig)
            internal
            pure
            returns (uint8 v, bytes32 r, bytes32 s)
        {
            require(sig.length == 65);

            assembly {
                // uzunluk önekinden sonraki ilk 32 bayt.
                r := mload(add(sig, 32))
                // ikinci 32 bayt
                s := mload(add(sig, 64))
                // son bayt (gelecek 32 baytın son baytı)
                v := byte(0, mload(add(sig, 96)))
            }

            return (v, r, s);
        }

        function recoverSigner(bytes32 message, bytes memory sig)
            internal
            pure
            returns (address)
        {
            (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);

            return ecrecover(message, v, r, s);
        }

        /// eth_sign'i kopyalayan önüne eklenmiş hash oluşturur.
        function prefixed(bytes32 hash) internal pure returns (bytes32) {
            return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        }
    }


.. note::
  ``splitSignature`` fonksiyonu bütün güvenlik önlemlerini almıyor. Gerçek bir uygulamada
  openzeppelin'in `versionu  <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/ECDSA.sol>`_
  gibi daha iyi test edilmiş bir kütüphane kullanılmalı.

Ödemeleri Doğrulama
------------------

Önceki bölümlerdekinin aksine, ödeme kanalındaki mesajlar anında alınmamakta.
Alıcı mesajların takibini yapıp zamanı geldiğinde ödeme kanalını kapatır. Yani bu durumda 
alıcının mesajları kendisinin doğrulaması oldukça önemli. Yoksa alıcının ödemesini kesin alacğaının
bir garantisi yok. 

Alıcı her mesajı aşağıdaki işlemler ile doğrulamalı:

    1. Mesajdaki kontrat adresinin ödeme kanalı ile aynı olduğunu kontrol et
    2. Yeni toplam miktarın beklenen miktar ile aynı olduğunu kontrol et
    3. Yeni toplam miktarın kontrattakinden fazla olmadığını kontrol et
    4. Mesajın ödeme kanalının göndericisinden geldiğini kontrol et.

Bu doğrulamayı yazmak için `ethereumjs-util <https://github.com/ethereumjs/ethereumjs-util>`_
kütüphanesini kullanacağız. Son adım için bir çok farklı yol var ve biz JavaScript kullanacağuz.
Aşağıdaki kod  ``constructPaymentMessage`` fonksiyonunu yukarıdaki imzalama **JavaScript kodundan** ödünç alıyor:

.. code-block:: javascript

    // Bu eth_sign JSON-RPC metodunun ön ekleme özelliğini taklit eder.
    function prefixed(hash) {
        return ethereumjs.ABI.soliditySHA3(
            ["string", "bytes32"],
            ["\x19Ethereum Signed Message:\n32", hash]
        );
    }

    function recoverSigner(message, signature) {
        var split = ethereumjs.Util.fromRpcSig(signature);
        var publicKey = ethereumjs.Util.ecrecover(message, split.v, split.r, split.s);
        var signer = ethereumjs.Util.pubToAddress(publicKey).toString("hex");
        return signer;
    }

    function isValidSignature(contractAddress, amount, signature, expectedSigner) {
        var message = prefixed(constructPaymentMessage(contractAddress, amount));
        var signer = recoverSigner(message, signature);
        return signer.toLowerCase() ==
            ethereumjs.Util.stripHexPrefix(expectedSigner).toLowerCase();
    }
