**********************************************************
Birimler ve Global Olarak Kullanılabilir Değişkenler
**********************************************************

.. index:: wei, finney, szabo, gwei, ether

Ether Birimleri
================

Bir değişmez sayı, Ether'in bir alt para birimini belirtmek için ``wei``, ``gwei`` veya ``ether`` son ekini alabilir; burada son eki olmayan Ether sayılarının Wei olduğu varsayılır.

.. code-block:: solidity
    :force:

    assert(1 wei == 1);
    assert(1 gwei == 1e9);
    assert(1 ether == 1e18);

Alt isim ekinin("e") tek etkisi, onluk bir kuvvetle çarpmadır.
.. note::
    0.7.0 sürümünde "finney" ve "szabo" adları kaldırılmıştır.

.. index:: time, seconds, minutes, hours, days, weeks, years

Zaman Birimleri
================

Gerçek sayılardan sonra gelen ``saniye``, ``dakika``, ``saat``, ``gün`` ve
``hafta`` gibi son ekler, saniyelerin temel birim olduğu zaman birimlerini
belirtmek için kullanılabilir. Ve ayrıca birimler aşağıdaki şekilde olduğu
gibi basitçe ele alınır:

* ``1 == 1 saniye``
* ``1 dakika == 60 saniye``
* ``1 saat == 60 dakika``
* ``1 gün == 24 saat``
* ``1 hafta == 7 gün``

Bu birimleri kullanarak takvim hesaplamaları yapıyorsanız dikkatli olun, çünkü her
yıl 365 güne eşit değildir ve `"artık saniyeler" <https://en.wikipedia.org/wiki/Leap_second>`_
nedeniyle her gün bile 24 saat değildir. "Artık saniyelerin" tahmin edilememesi nedeniyle, tam
bir takvim kütüphanesinin harici bir oracle tarafından güncellenmesi gerekir.

.. note::
    Yukarıdaki nedenlerden dolayı ``years`` soneki 0.5.0 sürümünde kaldırılmıştır.

Bu son ekler değişkenlere uygulanamaz. Örneğin, bir fonksiyon parametresini gün olarak
yorumlamak istiyorsanız, aşağıdaki şekilde yapabilirsiniz:

.. code-block:: solidity

    function f(uint start, uint daysAfter) public {
        if (block.timestamp >= start + daysAfter * 1 days) {
          // ...
        }
    }

.. _special-variables-functions:

Özel Değişkenler ve Fonksiyonlar
=================================

Global ad alanında her zaman var olan özel değişkenler ve işlevler vardır ve bunlar
çoğunlukla blok zinciri hakkında bilgi sağlamak için kullanılır. Veya bunlara ek olarak
genel kullanım amaçlı yardımcı fonksiyonlar da bulunmaktadır.

.. index:: abi, block, coinbase, difficulty, encode, number, block;number, timestamp, block;timestamp, msg, data, gas, sender, value, gas price, origin


Blok ve İşlem Özellikleri
--------------------------------

- ``blockhash(uint blockNumber) returns (bytes32)``: ``blocknumber`` en son 256 bloktan biri olduğunda verilen bloğun hash`ini döndürür, aksi takdirde sıfır döndürür
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

.. note::
    ``msg.sender`` ve ``msg.value`` dahil olmak üzere ``msg`` öğesinin tüm üyelerinin değerleri
    her **harici** işlev çağrısı için değişebilir. Buna kütüphane fonksiyonlarına yapılan çağrılar
    da dahildir.

.. note::
    Sözleşmeler, bir bloğa dahil edilen bir işlem bağlamında değil de zincir dışı değerlendirildiğinde,
    "block.*" ve "tx.*" ifadelerinin herhangi bir belirli blok veya işlemden gelen değerleri ifade ettiğini
    varsaymamalısınız. Bu değerler, sözleşmeyi yürüten ESM uygulaması tarafından sağlanır ve isteğe bağlı olabilir.

.. note::
    Ne yaptığınızı bilmiyorsanız, rasgelelik kaynağı olarak ``block.timestamp`` veya ``blockhash``'e güvenmeyin.

    Hem zaman bilgisi hem de blok hash'i madenciler tarafından bir dereceye kadar etkilenebilir.
    Madencilik topluluğunda bulunan kötü aktörler, örneğin seçilen bir hash üzerinde bir kumarhane
    ödeme fonksiyonu çalıştırabilir ve herhangi bir para almazlarsa farklı bir hash'i çözmeyi yeniden deneyebilirler.

    Mevcut blok zaman bilgisi, son bloğun zaman bilgisinden kesinlikle daha büyük olmalıdır. Ancak kabul
    edilebilecek tek garanti zaman bilgisi, standart zincirdeki iki ardışık bloğun zaman bilgileri arasında
    bir yerde olmasıdır.

.. note::
    Ölçeklenebilirlik nedeniyle blok hash'leri tüm bloklar için mevcut değildir. Yalnızca en son 256 bloğun
    hash'lerine erişebilirsiniz, bunun dışındaki tüm değerler sıfır olacaktır.

.. note::
    Daha önce ``blockhash`` işlevi ``block.blockhash`` olarak biliniyordu, bu işlev 0.4.22 sürümünde kullanımdan
    kaldırılmış ve 0.5.0 sürümünde tamamen kaldırılmıştır.

.. note::
    Daha önce ``gasleft`` işlevi ``msg.gas`` olarak biliniyordu, bu işlev 0.4.21 sürümünde kullanımdan kaldırılmış
    ve 0.5.0 sürümünde tamamen kaldırılmıştır.

.. note::
    0.7.0 sürümünde ``now`` takma adı (``block.timestamp`` için) kaldırıldı.

.. index:: abi, encoding, packed

ABI Şifreleme ve Şifreyi Çözme Fonksiyonları
----------------------------------------------

- ``abi.decode(bytes memory encodedData, (...)) returns (...)``: ABI verilen verinin şifresini çözerken, tipler ikinci argüman olarak parantez içinde verilir. Örneğin: ``(uint a, uint[2] memory b, bytes memory c) = abi.decode(data, (uint, uint[2], bytes))``
- ``abi.encode(...) returns (bytes memory)``: ABI verilen argümanları şifreler
- ``abi.encodePacked(...) returns (bytes memory)``: Verilen argümanların :ref:`paketlenmiş şifreleme <abi_packed_mode>` işlemini gerçekleştirir. Paketli şifrelemenin belirsiz olabileceğine dikkat edin!
- ``abi.encodeWithSelector(bytes4 selector, ...) returns (bytes memory)``: ABI, verilen bağımsız değişkenleri ikinciden başlayarak şifreler ve verilen dört baytlık seçicinin önüne ekler.
- ``abi.encodeWithSignature(string memory signature, ...) returns (bytes memory)``: Şuna eşdeğerdir ``abi.encodeWithSelector(bytes4(keccak256(bytes(signature))), ...)``
- ``abi.encodeCall(function functionPointer, (...)) returns (bytes memory)``: ABI, ``functionPointer`` çağrısını veri grupları içinde bulunan argümanlarla şifreler. Tam bir tür denetimi gerçekleştirerek türlerin fonksiyon imzasıyla eşleşmesini sağlar. Sonuç ``abi.encodeWithSelector(functionPointer.selector, (...))`` değerine eşittir
.. note::
    Bu şifreleme fonksiyonları, harici bir fonksiyonu çağırmadan harici fonksiyon çağrıları
    için veri oluşturmak amacıyla kullanılabilir. Ayrıca, ``keccak256(abi.encodePacked(a, b))``
    yapılandırılmış verilerin hashini hesaplamanın bir yoludur (ancak farklı fonksiyon parametre
    türleri kullanarak bir "hash çakışması" oluşturmanın mümkün olduğunu unutmayın).

Şifreleme ile ilgili ayrıntılar için :ref:`ABI <ABI>` ve
:ref:`sıkıca paketlenmiş şifreleme <abi_packed_mode>` hakkındaki belgelere bakabilirsiniz.

.. index:: bytes members

Byte Üyeleri
----------------

- ``bytes.concat(...) returns (bytes memory)``: :ref:`Değişken sayıda bayt ve bytes1, ..., bytes32 argümanlarını bir bayt dizisine birleştirir<bytes-concat>`

.. index:: string members

String Üyeleri
-----------------

- ``string.concat(...) returns (string memory)``: :ref:`Değişken sayıda string argümanını tek bir string dizisinde birleştirir<string-concat>`


.. index:: assert, revert, require

Hata İşleme
--------------

Hata işleme ve hangi fonksiyonun ne zaman kullanılacağı hakkında daha fazla
bilgi için :ref:`assert ve require<assert-and-require>` bölümüne bakın.

``assert(bool condition)``
    Panik hatasına ve dolayısıyla koşul karşılanmazsa durum değişikliğinin tersine dönmesine neden olur - dahili hatalar için kullanılır.

``require(bool condition)``
    koşul karşılanmazsa geri döner - girişlerdeki veya harici bileşenlerdeki hatalar için kullanılır.

``require(bool condition, string memory message)``
    koşul karşılanmazsa geri döner - girişlerdeki veya harici bileşenlerdeki hatalar için kullanılır. Ayrıca bir hata mesajı da sağlar.

``revert()``
    yürütmeyi iptal eder ve durum değişikliklerini geri alır

``revert(string memory reason)``
    açıklayıcı bir string sağlayarak yürütmeyi iptal eder ve durum değişikliklerini geri alır

.. index:: keccak256, ripemd160, sha256, ecrecover, addmod, mulmod, cryptography,

.. _mathematical-and-cryptographic-functions:

Matematiksel ve Kriptografik Fonksiyonlar
------------------------------------------

``addmod(uint x, uint y, uint k) returns (uint)``
    toplama işleminin isteğe bağlı kesinlikte gerçekleştirildiği ve ``2**256``da kapsamadığı ``(x + y) % k`` değerini hesaplar. Sürüm 0.5.0'den başlayarak "k!= 0" olduğunu iddia eder.

``mulmod(uint x, uint y, uint k) returns (uint)``
    çarpmanın isteğe bağlı kesinlikte gerçekleştirildiği ve ``2**256`` değerinde kapsamadığı ``(x * y) % k`` değerini hesaplar. Sürüm 0.5.0'dan başlayarak ``k != 0`` olduğunu iddia eder.

``keccak256(bytes memory) returns (bytes32)``
    girdinin Keccak-256 hash'ini hesaplar

.. note::

    Eskiden ``keccak256`` için ``sha3`` adında bir takma ad vardı, ancak bu ad 0.5.0 sürümünde kaldırıldı.

``sha256(bytes memory) returns (bytes32)``
    girdinin SHA-256 hash'ini hesaplar

``ripemd160(bytes memory) returns (bytes20)``
    girdinin RIPEMD-160 hash'ini hesaplar

``ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)``
    eliptik eğri imzasından açık anahtarla ilişkili adresi kurtarır veya hata durumunda sıfır döndürür.
    Fonksiyon parametreleri imzanın ECDSA değerlerine karşılık gelir:

    * ``r`` = imzanın ilk 32 byte'ı
    * ``s`` = imzanın ikinci 32 byte'ı
    * ``v`` = imzanın son 1 byte'ı

    ``ecrecover`` yalnızca bir ``address`` döndürür, ``address payable`` döndürmez. Kurtarılan adrese para aktarmanız gerekirse,
    dönüştürme için :ref:`address payable<address>` bölümüne bakabilirsiniz.

    Daha fazla ayrıntı için `örnek kullanım <https://ethereum.stackexchange.com/questions/1777/workflow-on-signing-a-string-with-private-key-followed-by-signature-verificatio>`_ bölümünü okuyun.

.. warning::

    Eğer ``ecrecover`` kullanıyorsanız, geçerli bir imzanın ilgili özel anahtarın (private key) bilinmesini
    gerektirmeden farklı bir geçerli imzaya dönüştürülebileceğini unutmayın. Homestead hard fork'unda bu sorun
    _transaction_ signatures için düzeltildi (bkz. `EIP-2 <https://eips.ethereum.org/EIPS/eip-2#specification>`_),
    ancak ecrecover fonksiyonu değişmeden kaldı.

    İmzaların benzersiz olmasını istemediğiniz veya bunları öğeleri tanımlamak için kullanmadığınız sürece
    bu genellikle bir sorun değildir. OpenZeppelin, bu sorun olmadan ``ecrecover`` için bir wrapper olarak
    kullanabileceğiniz bir `ECDSA yardımcı kütüphanesine <https://docs.openzeppelin.com/contracts/2.x/api/cryptography#ECDSA>`_ sahiptir.

.. note::

    Bir *özel blok zincirinde* ``sha256``, ``ripemd160`` veya ``ecrecover`` çalıştırırken, Out-of-Gas (Bitmiş Gas) ile karşılaşabilirsiniz. Bunun nedeni, bu
    fonksiyonların "önceden derlenmiş sözleşmeler" olarak uygulanması ve yalnızca ilk mesajı aldıktan sonra gerçekten var olmalarıdır (sözleşme kodları sabit
    kodlanmış olsa da). Mevcut olmayan sözleşmelere gönderilen mesajlar daha pahalıdır ve bu nedenle yürütme sırasında Out-of-Gas (Bitmiş Gas) hatasıyla karşılaşabilir.
    Bu sorun için geçici bir çözüm, gerçek sözleşmelerinizde kullanmadan önce her bir sözleşmeye Wei (örneğin 1) göndermektir. Bu sorun, ana veya test ağında bir geçerli değildir.

.. index:: balance, codehash, send, transfer, call, callcode, delegatecall, staticcall

.. _address_related:

Adres Tipleri Üyeleri
------------------------

``<address>.balance`` (``uint256``)
    Wei biçimindeki :ref:`address` bakiyesi

``<address>.code`` (``bytes memory``)
    ref:`address` adresindeki kod (boş olabilir)

``<address>.codehash`` (``bytes32``)
    ref:`address` kod hash'i

``<address payable>.transfer(uint256 amount)``
    verilen Wei miktarını :ref:`address` ‘ine gönderir, başarısız olması durumunda geri döner, 2300 gas ücreti iletir, ayarlanabilir değildir

``<address payable>.send(uint256 amount) returns (bool)``
    verilen Wei miktarını :ref:`address` 'ine gönderir, başarısız olması durumunda ``false`` döndürür, 2300 gas ücreti iletir, ayarlanabilir değildir

``<address>.call(bytes memory) returns (bool, bytes memory)``
    verilen yük ile düşük seviyeli ``CALL`` yayınlar, başarı koşulu ve dönüş verisi döndürür, mevcut tüm gas'ı iletir, ayarlanabilirdir

``<address>.delegatecall(bytes memory) returns (bool, bytes memory)``
    verilen yük ile düşük seviyeli ``DELEGATECALL`` yayınlar, başarı koşulu ve dönüş verisi döndürür, mevcut tüm gazı iletir, ayarlanabilirdir

``<address>.staticcall(bytes memory) returns (bool, bytes memory)``
    verilen yük ile düşük seviyeli ``STATICCALL`` yayınlar, başarı koşulunu ve dönüş verilerini döndürür, mevcut tüm gazı iletir, ayarlanabilirdir

Daha fazla bilgi için :ref:`address` ile ilgili bölüme bakın.

.. warning::
    Başka bir sözleşme fonksiyonunu çalıştırırken mümkün olduğunca ``.call()`` kullanmaktan kaçınmalısınız,
    çünkü bu tür denetimi, fonksiyon varlığı denetimini ve argüman paketlemeyi atlar.

.. warning::
    ``send`` kullanmanın bazı tehlikeleri vardır: Çağrı yığını derinliği 1024 ise transfer  başarısız olur
    (bu her zaman çağıran kişi tarafından zorlanabilir) ve ayrıca alıcının gas'ı biterse de başarısız olur.
    Bu nedenle, güvenli Ether transferleri yapmak için, her zaman ``send`` dönüş değerini kontrol edin, ``transfer``
    kullanın veya daha da iyisi: Alıcının parayı çektiği bir model kullanın.

.. warning::
    ESM'nin mevcut olmayan bir sözleşmeye yapılan bir çağrının her zaman başarılı olacağını düşünmesi
    nedeniyle, Solidity harici çağrılar gerçekleştirirken ``extcodesize`` işlem kodunu kullanarak ekstra
    bir kontrol yapar. Bu, çağrılmak üzere olan sözleşmenin ya gerçekten var olmasını (kod içermesini)
    ya da bir istisnanın ortaya çıkmasını sağlar.

    Sözleşme örnekleri yerine adresler üzerinde çalışan düşük seviyeli çağrılar (yani ``.call()``, ``.delegatecall()``,
    ``.staticcall()``, ``.send()`` ve ``.transfer()``) Bu kontrolü **içermezler**, bu da onları gas açısından daha ucuz
    ama aynı zamanda daha az güvenli hale getirir.

.. note::
   0.5.0 sürümünden önce, Solidity adres üyelerine bir sözleşme örneği tarafından erişilmesine izin veriyordu,
   örnek vermek gerekirse ``this.balance``. Bu fonksiyon artık yasaklanmıştır ve adrese yönelik olarak açık bir dönüşüm yapılmalıdır: ``address(this).balance``.

.. note::
   Durum değişkenlerine düşük seviyeli bir "delegatecall" yoluyla erişiliyorsa eğer, çağrılan sözleşmenin
   çağıran sözleşme tarafından depolama değişkenlerine adıyla doğru şekilde erişebilmesi için iki sözleşmenin
   depolama düzeninin aynı hizada olması gerekir. Üst düzey kütüphanelerde olduğu gibi depolama işaretçilerinin(pointer)
   fonksiyon argümanları olarak aktarılması durumunda bu durum elbette geçerli değildir.

.. note::
    0.5.0 sürümünden önce, ``.call``, ``.delegatecall`` ve ``.staticcall`` yalnızca başarı koşulunu döndürüyordu,
    dönüş verisini döndürmüyordu.

.. note::
    0.5.0 sürümünden önce, ``delegatecall`` ile benzer ancak biraz farklı anlamlara sahip ``callcode`` adlı bir üye de bulunmaktaydı.


.. index:: this, selfdestruct

Sözleşme İle İlgili
---------------------

``this`` (mevcut sözleşmenin türü)
    mevcut sözleşme, açıkça :ref:`address`’ine dönüştürülebilir

``selfdestruct(ödenebilir alıcı adresi)``
    Mevcut sözleşmeyi yok eder, fonlarını verilen :ref:`address`e gönderir ve yürütür.
    ``selfdestruct``'ın ESM'den miras kalan bazı özelliklere sahip olduğunu unutmayın:

    - alıcı sözleşmenin alma(receive) fonksiyonu yürütülmez.
    - sözleşme sadece işlemin sonunda gerçekten yok edilir ve ``revert`` bu yok edilme işlemini "geri alabilir".




Ayrıca, geçerli sözleşmenin tüm fonksiyonları, geçerli fonksiyon da dahil olmak üzere doğrudan çağrılabilir.

.. note::
    0.5.0 sürümünden önce, ``selfdestruct`` ile aynı semantiğe sahip ``suicide`` adlı bir fonksiyon bulunmaktaydı.

.. index:: type, creationCode, runtimeCode

.. _meta-type:

Type Bilgileri
----------------

``type(X)`` ifadesi ``X`` türü hakkında bilgi almak için kullanılabilir. Şu anda,
bu özellik için sınırlı bir destek bulunmaktadır (``X`` bir sözleşme veya tamsayı türü olabilir),
ancak gelecekte genişletilebilir.

Aşağıdaki özellikler bir sözleşme tipi(type) ``C`` için kullanılabilir:

``type(C).name``
    Sözleşmenin ismi.

``type(C).creationCode``
    Sözleşmenin oluşturma bayt kodunu içeren bellek bayt dizisi. Bu, özellikle
    ``create2`` işlem kodu kullanılarak özel oluşturma rutinleri oluşturmak için
    satır içi derlemede kullanılabilir. Bu özelliğe sözleşmenin kendisinden veya
    türetilmiş herhangi bir sözleşmeden **erişilemez**. Bytecode'un çağrı bölgesisin
    bytecode'una dahil edilmesine neden olur ve bu nedenle bunun gibi döngüsel
    referanslar mümkün değildir.

``type(C).runtimeCode``
    Sözleşmenin çalışma zamanı bayt kodunu içeren bellek bayt dizisi. Bu, genellikle
    ``C`` yapıcısı tarafından dağıtılan koddur. Eğer ``C``nin inline assembly kullanan
    bir kurucusu varsa, bu gerçekte dağıtılan bytecode'dan farklı olabilir. Ayrıca,
    kütüphanelerin normal çağrılara karşı koruma sağlamak için dağıtım sırasında
    çalışma zamanı bayt kodlarını değiştirdiklerini unutmayın. Bu özellik için de
    ``.creationCode`` ile aynı kısıtlamalar geçerlidir.

Yukarıdaki özelliklere ek olarak, bir arayüz tipi ``I`` için aşağıdaki
özellikler kullanılabilir:

``type(I).interfaceId``:
    Verilen ``I`` arayüzünün ``EIP-165 <https://eips.ethereum.org/EIPS/eip-165>`_
    arayüz tanımlayıcısını içeren bir ``bytes4`` değeri. Bu tanımlayıcı, miras alınan
    tüm fonksiyonlar hariç olmak üzere, arayüzün kendi içinde tanımlanan tüm fonksiyon
    seçicilerinin ``XOR`` 'u olarak tanımlanır.

Aşağıdaki özellikler ``T`` tamsayı(integer) türü için kullanılabilir:

``type(T).min``
    ``T`` tipi tarafından temsil edilebilen en küçük değer.

``type(T).max``
<<<<<<< HEAD
    ``T`` tipi tarafından temsil edilebilen en büyük değer.
=======
    The largest value representable by type ``T``.

Reserved Keywords
=================

These keywords are reserved in Solidity. They might become part of the syntax in the future:

``after``, ``alias``, ``apply``, ``auto``, ``byte``, ``case``, ``copyof``, ``default``,
``define``, ``final``, ``implements``, ``in``, ``inline``, ``let``, ``macro``, ``match``,
``mutable``, ``null``, ``of``, ``partial``, ``promise``, ``reference``, ``relocatable``,
``sealed``, ``sizeof``, ``static``, ``supports``, ``switch``, ``typedef``, ``typeof``,
``var``.
>>>>>>> v0.8.16
