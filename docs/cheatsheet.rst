**********
Kopya Kağıdı
**********

.. index:: operator; precedence

Operatörlerin Öncelik Sırası
================================
.. include:: types/operator-precedence-table.rst

.. index:: assert, block, coinbase, difficulty, number, block;number, timestamp, block;timestamp, msg, data, gas, sender, value, gas price, origin, revert, require, keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography, this, super, selfdestruct, balance, codehash, send

Global Değişkenlere
================

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: ABI formatında gönderilen verinin ayrıştırılması sırasında, tipler ikinci argüman olarak parantez içinde verilir. Örneğin: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: ABI verilen argümanları şifreler
- ``abi.encodePacked(...) returns (bytes memory)``: Verilen argümanların :ref:`paketlenmiş şifreleme <abi_packed_mode>` işlemini gerçekleştirir. Paketli şifrelemenin belirsiz olabileceğine dikkat edin!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: ABI, verilen bağımsız değişkenleri ikinciden başlayarak şifreler ve verilen dört baytlık seçicinin önüne ekler.
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Şuna eşdeğerdir ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)``
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI, ``functionPointer`` çağrısını veri grupları içinde bulunan argümanlarla şifreler. Tam bir tür denetimi gerçekleştirerek türlerin fonksiyon imzasıyla eşleşmesini sağlar. Sonuç ``abi.encodeWithSelector(functionPointer.selector, (...))`` değerine eşittir
- ``bytes.concat(...) returns (bytes memory)``: :ref:`Değişken sayıda bayt ve bytes1, ..., bytes32 argümanlarını bir bayt dizisine birleştirir<bytes-concat>`
- ``string.concat(...) returns (string memory)``: :ref:`Değişken sayıda string argümanını tek bir string dizisinde birleştirir<string-concat>`
- ``block.basefee`` (``uint``): mevcut bloğun baz ücreti (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ ve `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_)
- ``block.chainid`` (``uint``): mevcut bloğun zincir kimliği
- ``block.coinbase`` (``address payable``): mevcut blok madencisinin adresi
- ``block.difficulty`` (``uint``): mevcut blok zorluğu
- ``block.gaslimit`` (``uint``): mevcut blok gas sınırı
- ``block.number`` (``uint``): mevcut blok numarası
- ``block.timestamp`` (``uint``): unix döneminden bu yana saniye biçimindeki mevcut blok zaman bilgisi
- ``gasleft() returns (uint256)``: kalan gas
- ``msg.data`` (``bytes calldata``): bütün calldata
- ``msg.sender`` (``address``): mesajın göndericisi (mevcut çağırma için)
- ``msg.sig`` (``bytes4``): calldata'nın ilk 4 byte değeri (yani fonksiyon tanımlayıcısı)
- ``msg.value`` (``uint``): mesaj ile birlikte gönderilen wei miktarı
- ``tx.gasprice`` (``uint``): işlemin gas fiyatı
- ``tx.origin`` (``address``): işlemin göndericisi (tam çağrı zinciri)
- ``assert(bool condition)``: koşul "yanlış" ise yürütmeyi iptal edilir ve durum değişikliklerini geri alır (dahili hata için kullanın)
- ``require(bool condition)``: koşul "yanlış" ise yürütmeyi durdurur ve durum değişikliklerini geri alır (harici bileşende hatalı biçimlendirilmiş giriş veya hata için kullanın)
- ``require(bool condition, string memory message)``: koşul "yanlış" ise yürütmeyi iptal eder ve durum değişikliklerini geri alır (harici bileşende hatalı biçimlendirilmiş giriş veya hata için kullanın). Ayrıca hata mesajıda verir.
- ``revert()``: yürütmeyi iptal eder ve durum değişikliklerini geri alır
- ``revert(string memory message)``: açıklayıcı bir string sağlayarak yürütmeyi iptal eder ve durum değişikliklerini geri alır
- ``blockhash(uint blockNumber) returns (bytes32)``: verilen bloğun hash'i - yalnızca en son 256 blok için çalışır
- ``keccak256(bytes memory) returns (bytes32)``: girdinin Keccak-256 hash'ini hesaplar
- ``sha256(bytes memory) returns (bytes32)``: cgirdinin SHA-256 hash'ini hesaplar
- ``ripemd160(bytes memory) returns (bytes20)``: girdinin RIPEMD-160 hash'ini hesaplar
- ``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``: eliptik eğri imzasından açık anahtarla ilişkili adresi kurtarır veya hata durumunda sıfır döndürür.
- ``addmod(uint x, uint y, uint k) returns (uint)``: toplama işleminin isteğe bağlı kesinlikte gerçekleştirildiği ve ``2**256``da kapsamadığı ``(x + y) % k`` değerini hesaplar. Sürüm 0.5.0'den başlayarak "k!= 0" olduğunu iddia eder.
- ``mulmod(uint x, uint y, uint k) returns (uint)``: çarpmanın isteğe bağlı kesinlikte gerçekleştirildiği ve ``2**256`` değerinde kapsamadığı ``(x * y) % k`` değerini hesaplar. Sürüm 0.5.0'dan başlayarak ``k != 0`` olduğunu iddia eder.
- ``this`` (mevcut sözleşme tipi): mevcut sözleşme, açıkça "adres" veya "ödenecek adres"e dönüştürülebilir
- ``super``: kalıtım(miras) hiyerarşisinde bir seviye daha yüksek sözleşme
- ``selfdestruct(address payable recipient)``: mevcut sözleşmeyi imha edin, fonlarını verilen adrese gönderin
- ``<address>.balance`` (``uint256``): Wei biçimindeki :ref:`address` bakiyesi
- ``<address>.code`` (``bytes memory``): ref:`address` adresindeki kod (boş olabilir)
- ``<address>.codehash`` (``bytes32``): ref:`address` kod hash'i
- ``<address payable>.send(uint256 amount) returns (bool)``: verilen Wei miktarını :ref:`address` 'ine gönderir, başarısız olması durumunda ``false`` döndürür
- ``<address payable>.transfer(uint256 amount)``: verilen Wei miktarını :ref:`address` ‘ine gönderir, başarısız olması durumunda geri döner
- ``type(C).name`` (``string``): sözleşmenin ismi
- ``type(C).creationCode`` (``bytes memory``): verilen sözleşmenin bayt kodu oluşturma, bkz. :ref:`Type Information<meta-type>`.
- ``type(C).runtimeCode`` (``bytes memory``): verilen sözleşmenin çalışma zamanı bayt kodu, bkz. :ref:`Type Information<meta-type>`.
- ``type(I).interfaceId`` (``bytes4``): verilen arayüzün EIP-165 arayüz tanımlayıcısını içeren değer, bkz. :ref:`Type Information<meta-type>`.
- ``type(T).min`` (``T``): ``T`` tipi tarafından temsil edilebilen en küçük değer, bkz. :ref:`Type Information<meta-type>`.
- ``type(T).max`` (``T``): ``T`` tipi tarafından temsil edilebilen en büyük değer, bkz. :ref:`Type Information<meta-type>`.


.. index:: visibility, public, private, external, internal

Fonksiyon Görünürlük Belirteçleri
==============================

.. code-block:: solidity
    :force:

    function myFunction() <visibility specifier> returns (bool) {
        return true;
    }

- ``public``: harici ve dahili olarak görünür (depolama/durum değişkenleri için bir :ref:`alıcı fonksiyon<getter-functions>` oluşturur)
- ``private``: sadece mevcut sözleşmede görünür
- ``external``: yalnızca harici olarak görünür (yalnızca fonksiyonlar için) - yani yalnızca mesajla çağrılabilir (``this.func`` aracılığıyla)
- ``internal``: sadece dahili olarak görünür


.. index:: modifiers, pure, view, payable, constant, anonymous, indexed

Modifiers
=========

- ``pure`` fonksiyonlar için: Durumun değiştirilmesine veya erişime izin vermez.
- ``view`` fonksiyonlar için: Durum değişikliğine izin vermez.
- ``payable`` fonksiyonlar için: Bir çağrıyla birlikte Ether almalarını sağlar.
- ``constant`` durum değişkenleri için: Atamaya izin vermez (başlatma dışında), depolama yuvasını işgal etmez.
- ``immutable`` durum değişkenleri için: Başlatılma sırasında tam olarak bir atamaya izin verir ve daha sonra sabit bir şekilde kalır. Kodda saklanır.
- ``anonymous`` event'ler için: Event imzasını başlık olarak saklamaz
- ``indexed`` event parametreleri için: Parametreyi başlık olarak saklar
- ``virtual`` fonksiyonlar ve modifier'lar için: Türetilmiş sözleşmelerde modifier'ların fonksiyonlarının değiştirilmesine izin verir.
- ``override``: Bu fonksiyon, modifier veya genel durum değişkeninin, bir temel sözleşmedeki bir fonksiyonun veya modifier'ın davranışını değiştirdiğini ifade etmektedir.

Ayrılmış Anahtar Kelimeler
=================

Bu anahtar kelimeler Solidity'de ayrılmıştır. Gelecekte sözdiziminin(syntax) bir parçası olabilirler:

``after``, ``alias``, ``apply``, ``auto``, ``byte``, ``case``, ``copyof``, ``default``,
``define``, ``final``, ``implements``, ``in``, ``inline``, ``let``, ``macro``, ``match``,
``mutable``, ``null``, ``of``, ``partial``, ``promise``, ``reference``, ``relocatable``,
``sealed``, ``sizeof``, ``static``, ``supports``, ``switch``, ``typedef``, ``typeof``,
``var``.
