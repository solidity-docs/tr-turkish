.. index:: style, coding style

#############
Style Guide
#############

************
Introduction
************

Bu kılavuz, Solidity kodu yazmak için kodlama kuralları sağlamayı amaçlamaktadır.
Bu kılavuz, yararlı kurallar bulundukça ve eski kurallar kullanılmaz hale geldikçe zaman içinde değişecek, gelişen bir belge olarak düşünülmelidir.

Birçok proje kendi stil kılavuzlarını uygulayacaktır.  Bu durumda çatışmalarda, projeye özel stil kılavuzları önceliklidir.

Bu stil kılavuzunun yapısı ve içerdiği önerilerin çoğu python'un
`pep8 style guide <https://www.python.org/dev/peps/pep-0008/>`_.
Bu kılavuzun amacı *Solidity kodu yazmanın doğru yolu veya en iyi yolu olmak değildir*.  Bu kılavuzun amacı *tutarlılıktır*.  Python'dan bir alıntı
`pep8 <https://www.python.org/dev/peps/pep-0008/#a-foolish-consistency-is-the-hobgoblin-of-little-minds>`_
bu konsepti iyi yakalıyor.

.. note::

    Bir stil rehberi tutarlılıkla ilgilidir. 
Bu stil rehberi ile tutarlılık önemlidir. Bir proje içindeki tutarlılık daha önemlidir. Bir modül veya fonksiyon içindeki tutarlılık en önemlisidir.

    Ama daha da önemlisi: **know when to be inconsistent** -- bazen stil kılavuzu geçerli olmayabilir. Şüpheye düştüğünüzde, en iyi kararınızı kullanın. Diğer örneklere bakın ve neyin en iyi göründüğüne karar verin. Ve sormaktan çekinmeyin!


***********
Kod Düzeni
***********


Girinti
===========

Girinti seviyesi başına 4 boşluk kullanın.

Sekmeler veya Boşluklar
==============

Boşluklar tercih edilen girinti yöntemidir.

Sekme ve boşlukları karıştırmaktan kaçınılmalıdır.

Boş Satırlar 
===========

Solidity kaynağındaki üst düzey bildirimleri iki boş satırla çevreleyin.

Evet:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }


    contract B {
        // ...
    }


    contract C {
        // ...
    }

No:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }
    contract B {
        // ...
    }

    contract C {
        // ...
    }

Bir sözleşme içinde fonksiyon bildirimlerini tek bir boş satırla çevreleyin.

Birbiriyle ilişkili tek satırlık gruplar arasında boş satırlar atlanabilir (soyut bir sözleşme için saplama işlevleri gibi)

Evet:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract A {
        function spam() public virtual pure;
        function ham() public virtual pure;
    }


    contract B is A {
        function spam() public pure override {
            // ...
        }

        function ham() public pure override {
            // ...
        }
    }

No:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract A {
        function spam() virtual pure public;
        function ham() public virtual pure;
    }


    contract B is A {
        function spam() public pure override {
            // ...
        }
        function ham() public pure override {
            // ...
        }
    }

.. _maximum_line_length:

Maksimum Satır Uzunluğu
===================

Satırların altında tutulması `PEP 8 recommendation <https://www.python.org/dev/peps/pep-0008/#maximum-line-length>`_ en fazla 79'a (veya 99'a) kadar
karakterleri okuyucuların kodu kolayca ayrıştırmasına yardımcı olur.

Sarılmış satırlar aşağıdaki yönergelere uygun olmalıdır.

1. İlk argüman açılış parantezine eklenmemelidir.
2. Tek ve yalnızca bir girinti kullanılmalıdır.
3. Her argüman kendi satırında yer almalıdır.
4. The terminating element, :code:`);`, should be placed on the final line by itself.

Fonksiyon Çağrıları

Evet:

.. code-block:: solidity

    thisFunctionCallIsReallyLong(
        longArgument1,
        longArgument2,
        longArgument3
    );

Hayır:

.. code-block:: solidity

    thisFunctionCallIsReallyLong(longArgument1,
                                  longArgument2,
                                  longArgument3
    );

    thisFunctionCallIsReallyLong(longArgument1,
        longArgument2,
        longArgument3
    );

    thisFunctionCallIsReallyLong(
        longArgument1, longArgument2,
        longArgument3
    );

    thisFunctionCallIsReallyLong(
    longArgument1,
    longArgument2,
    longArgument3
    );

    thisFunctionCallIsReallyLong(
        longArgument1,
        longArgument2,
        longArgument3);

Assignment Statements

Evet:

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(
        argument1,
        argument2,
        argument3,
        argument4
    );

Hayır:

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(argument1,
                                                                       argument2,
                                                                       argument3,
                                                                       argument4);

Event Definitions and Event Emitters

Evet:

.. code-block:: solidity

    event LongAndLotsOfArgs(
        address sender,
        address recipient,
        uint256 publicKey,
        uint256 amount,
        bytes32[] options
    );

    LongAndLotsOfArgs(
        sender,
        recipient,
        publicKey,
        amount,
        options
    );

Hayır:

.. code-block:: solidity

    event LongAndLotsOfArgs(address sender,
                            address recipient,
                            uint256 publicKey,
                            uint256 amount,
                            bytes32[] options);

    LongAndLotsOfArgs(sender,
                      recipient,
                      publicKey,
                      amount,
                      options);

Kaynak Dosya Kodlaması
====================

UTF-8 veya ASCII kodlaması tercih edilir.

İthalat
=======

İçe aktarma (import) ifadeleri her zaman dosyanın en üstüne yerleştirilmelidir.

Evet:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    import "./Owned.sol";

    contract A {
        // ...
    }


    contract B is Owned {
        // ...
    }

Hayır:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract A {
        // ...
    }


    import "./Owned.sol";


    contract B is Owned {
        // ...
    }

Fonksiyonların Sırası
==================

Sıralama, okuyucuların hangi fonksiyonları çağırabileceklerini belirlemelerine ve yapıcı ve geri dönüş tanımlarını daha kolay bulmalarına yardımcı olur.
Fonksiyonlar görünürlüklerine göre gruplandırılmalı ve sıralanmalıdır:

- Kurucu
- Alma fonksiyonu (eğer mevcutsa)
- Geri dönüş fonksiyonu (eğer mevcutsa)
- Dış
- halka açık
- İç
- Özel

Bir gruplama içinde, ``view`` ve ``pure`` fonksiyonlarını en sona yerleştirin.
Evet:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract A {
        constructor() {
            // ...
        }

        receive() external payable {
            // ...
        }

        fallback() external {
            // ...
        }

        // External functions
        // ...

        // External functions that are view
        // ...

        // External functions that are pure
        // ...

        // Public functions
        // ...

        // Internal functions
        // ...

        // Private functions
        // ...
    }

Hayır:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract A {

        // External functions
        // ...

        fallback() external {
            // ...
        }
        receive() external payable {
            // ...
        }

        // Private functions
        // ...

        // Public functions
        // ...

        constructor() {
            // ...
        }

        // Internal functions
        // ...
    }

İfadelerde Boşluk Bırakma
=========================
Aşağıdaki durumlarda gereksiz boşluklardan kaçının:

Tek satırlık fonksiyon bildirimleri hariç olmak üzere, parantez, köşeli parantez veya ayraçların hemen içinde.

Evet:

.. code-block:: solidity

    spam(ham[1], Coin({name: "ham"}));

Hayır:

.. code-block:: solidity

    spam( ham[ 1 ], Coin( { name: "ham" } ) );

İstisna:

.. code-block:: solidity

    function singleLine() public { spam(); }

Virgülden hemen önce, noktalı virgül:

Evet:

.. code-block:: solidity

    function spam(uint i, Coin coin) public;

Hayır:

.. code-block:: solidity

    function spam(uint i , Coin coin) public ;

Bir atama veya başka bir operatörün etrafında, diğeriyle hizalamak için birden fazla boşluk:

Evet:

.. code-block:: solidity

    x = 1;
    y = 2;
    longVariable = 3;

Hayır:

.. code-block:: solidity

    x            = 1;
    y            = 2;
    longVariable = 3;

Alma ve geri dönüş fonksiyonlarına boşluk eklemeyin:

Evet:

.. code-block:: solidity

    receive() external payable {
        ...
    }

    fallback() external {
        ...
    }

Hayır:

.. code-block:: solidity

    receive () external payable {
        ...
    }

    fallback () external {
        ...
    }


Kontrol Yapıları
==================

Bir sözleşmenin gövdesini, kütüphaneyi, fonksiyonları ve yapıları gösteren parantezler
gerekir:

* bildirimle aynı satırda açın
* kendi satırlarında, bildirimin başlangıcıyla aynı girinti seviyesinde kapanır.
* Açılış parantezinden önce tek bir boşluk bırakılmalıdır.

Evet:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Coin {
        struct Bank {
            address owner;
            uint balance;
        }
    }

Hayır:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Coin
    {
        struct Bank {
            address owner;
            uint balance;
        }
    }


Aynı öneriler ``if``, ``else``, ``while`` ve ``for`` kontrol yapıları için de geçerlidir.


Ayrıca kontrol yapıları arasında tek bir boşluk olmalıdır
``if``, ``while`` ve ``for`` ile parantez içindeki blok
koşullu ve koşullu parantez arasında tek bir boşluk
blok ve açılış desteği.

Evet:

.. code-block:: solidity

    if (...) {
        ...
    }

    for (...) {
        ...
    }

Hayır:

.. code-block:: solidity

    if (...)
    {
        ...
    }

    while(...){
    }

    for (...) {
        ...;}

Gövdesi tek bir ifade içeren kontrol yapıları için, parantezleri atlamak *eğer ifade tek bir satırda yer alıyorsa* uygundur.

Evet:

.. code-block:: solidity

    if (x < 10)
        x += 1;

Hayır:

.. code-block:: solidity

    if (x < 10)
        someArray.push(Coin({
            name: 'spam',
            value: 42
        }));

Bir ``else`` veya ``else if`` cümlesine sahip ``if`` blokları için, ``else``, ``if``in kapanış paranteziyle aynı satıra yerleştirilmelidir. Bu, diğer blok benzeri yapıların kurallarına kıyasla bir istisnadır.

Evet:

.. code-block:: solidity

    if (x < 3) {
        x += 1;
    } else if (x > 7) {
        x -= 1;
    } else {
        x = 5;
    }


    if (x < 3)
        x += 1;
    else
        x -= 1;

Hayır:

.. code-block:: solidity

    if (x < 3) {
        x += 1;
    }
    else {
        x -= 1;
    }

Fonksiyon Bildirimi
====================

Kısa fonksiyon bildirimleri için, açılış parantezinin fonksiyon gövdesi, fonksiyon bildirimi ile aynı satırda tutulmalıdır.
Kapanış parantezi, fonksiyon bildirimi ile aynı girinti seviyesinde olmalıdır.
Açılış parantezinden önce tek bir boşluk bırakılmalıdır.

Evet:

.. code-block:: solidity

    function increment(uint x) public pure returns (uint) {
        return x + 1;
    }

    function increment(uint x) public pure onlyOwner returns (uint) {
        return x + 1;
    }

Hayır:

.. code-block:: solidity

    function increment(uint x) public pure returns (uint)
    {
        return x + 1;
    }

    function increment(uint x) public pure returns (uint){
        return x + 1;
    }

    function increment(uint x) public pure returns (uint) {
        return x + 1;
        }

    function increment(uint x) public pure returns (uint) {
        return x + 1;}

Bir fonksiyon için değiştirici sırası şöyle olmalıdır:

1. Görünürlük
2. Değişkenlik
3. Sanal
4. Geçersiz kılma
5. Özel düzenleyiciler

Evet:

.. code-block:: solidity

    function balance(uint from) public view override returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() public onlyOwner {
        selfdestruct(owner);
    }

Hayır:

.. code-block:: solidity

    function balance(uint from) public override view returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() onlyOwner public {
        selfdestruct(owner);
    }

Uzun fonksiyon bildirimleri için, her bir argümanın fonksiyon gövdesi ile aynı girinti seviyesinde kendi satırını oluşturur.  Kapanış 'de parantez ve açılı ayraçlar da kendi satırlarına yerleştirilmelidir. fonksiyon bildirimi ile aynı girinti seviyesinde olmalıdır.

Evet:

.. code-block:: solidity

    function thisFunctionHasLotsOfArguments(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f
    )
        public
    {
        doSomething();
    }

Hayır:

.. code-block:: solidity

    function thisFunctionHasLotsOfArguments(address a, address b, address c,
        address d, address e, address f) public {
        doSomething();
    }

    function thisFunctionHasLotsOfArguments(address a,
                                            address b,
                                            address c,
                                            address d,
                                            address e,
                                            address f) public {
        doSomething();
    }

    function thisFunctionHasLotsOfArguments(
        address a,
        address b,
        address c,
        address d,
        address e,
        address f) public {
        doSomething();
    }

Bir uzun fonksiyon bildiriminin değiştiricileri varsa, her değiştirici kendi hattına düştü.

Evet:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public
        onlyOwner
        priced
        returns (address)
    {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(
        address x,
        address y,
        address z
    )
        public
        onlyOwner
        priced
        returns (address)
    {
        doSomething();
    }

Hayır:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(address x, address y, address z)
                                          public
                                          onlyOwner
                                          priced
                                          returns (address) {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public onlyOwner priced returns (address)
    {
        doSomething();
    }

    function thisFunctionNameIsReallyLong(address x, address y, address z)
        public
        onlyOwner
        priced
        returns (address) {
        doSomething();
    }

Çok satırlı çıktı parametreleri ve dönüş ifadeleri, :ref:`Maksimum Satır Uzunluğu <maximum_line_length>` bölümünde bulunan uzun satırları sarmak için önerilen aynı stili izlemelidir.

Evet:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(
        address a,
        address b,
        address c
    )
        public
        returns (
            address someAddressName,
            uint256 LongArgument,
            uint256 Argument
        )
    {
        doSomething()

        return (
            veryLongReturnArg1,
            veryLongReturnArg2,
            veryLongReturnArg3
        );
    }

Hayır:

.. code-block:: solidity

    function thisFunctionNameIsReallyLong(
        address a,
        address b,
        address c
    )
        public
        returns (address someAddressName,
                 uint256 LongArgument,
                 uint256 Argument)
    {
        doSomething()

        return (veryLongReturnArg1,
                veryLongReturnArg1,
                veryLongReturnArg1);
    }

Tabanları argüman gerektiren miras alınmış sözleşmelerdeki kurucu fonksiyonlar için, fonksiyon bildirimi uzunsa veya okunması zorsa, temel kurucuların değiştiricilerle aynı şekilde yeni satırlara bırakılması önerilir.

Evet:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // Base contracts just to make this compile
    contract B {
        constructor(uint) {
        }
    }


    contract C {
        constructor(uint, uint) {
        }
    }


    contract D {
        constructor(uint) {
        }
    }


    contract A is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
            B(param1)
            C(param2, param3)
            D(param4)
        {
            // do something with param5
            x = param5;
        }
    }

Hayır:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // Base contracts just to make this compile
    contract B {
        constructor(uint) {
        }
    }


    contract C {
        constructor(uint, uint) {
        }
    }


    contract D {
        constructor(uint) {
        }
    }


    contract A is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
        B(param1)
        C(param2, param3)
        D(param4) {
            x = param5;
        }
    }


    contract X is B, C, D {
        uint x;

        constructor(uint param1, uint param2, uint param3, uint param4, uint param5)
            B(param1)
            C(param2, param3)
            D(param4) {
                x = param5;
            }
    }


Kısa fonksiyonları tek bir deyimle bildirirken, bunu tek bir satırda yapmaya izin verilir.

İzin verilebilir:

.. code-block:: solidity

    function shortFunction() public { doSomething(); }

Fonksiyon bildirimleri için bu yönergeler okunabilirliği artırmayı amaçlamaktadır. Bu kılavuz fonksiyon bildirimleri için tüm olası permütasyonları kapsamaya çalışmadığından yazarlar en iyi kararlarını kullanmalıdır.

Eşlemeler
========


Değişken bildirimlerinde, ``mapping`` anahtar sözcüğünü türünden bir boşlukla ayırmayın. İç içe geçmiş ``mapping`` anahtar sözcüğünü türünden boşluk ile ayırmayın.
Evet:

.. code-block:: solidity

    mapping(uint => uint) map;
    mapping(address => bool) registeredAddresses;
    mapping(uint => mapping(bool => Data[])) public data;
    mapping(uint => mapping(uint => s)) data;

Hayır:

.. code-block:: solidity

    mapping (uint => uint) map;
    mapping( address => bool ) registeredAddresses;
    mapping (uint => mapping (bool => Data[])) public data;
    mapping(uint => mapping (uint => s)) data;

Değişken Bildirimleri
=====================

Dizi değişkenlerinin bildirimlerinde, tür ile parantezler arasında boşluk olmamalıdır.

Evet:

.. code-block:: solidity

    uint[] x;

Hayır:

.. code-block:: solidity

    uint [] x;


Diğer Öneriler
=====================

String tek tırnak yerine çift tırnak ile alıntılanmalıdır.

Evet:

.. code-block:: solidity

    str = "foo";
    str = "Hamlet says, 'To be or not to be...'";

Hayır:

.. code-block:: solidity

    str = 'bar';
    str = '"Be yourself; everyone else is already taken." -Oscar Wilde';

* Surround operators with a single space on either side.

Evet:

.. code-block:: solidity
    :force:

    x = 3;
    x = 100 / 10;
    x += 3 + 4;
    x |= y && z;

Hayır:

.. code-block:: solidity
    :force:

    x=3;
    x = 100/10;
    x += 3+4;
    x |= y&&z;

* Diğerlerinden daha yüksek önceliğe sahip operatörler, önceliği belirtmek için çevreleyen beyaz boşluğu hariç tutabilir.  Bunun amacı, karmaşık ifadeler için daha iyi okunabilirlik sağlamaktır. Bir işlecin her iki tarafında da her zaman aynı miktarda boşluk kullanmalısınız:

Evet:

.. code-block:: solidity

    x = 2**3 + 5;
    x = 2*y + 3*z;
    x = (a+b) * (a-b);

Hayır:

.. code-block:: solidity

    x = 2** 3 + 5;
    x = y+z;
    x +=1;

***************
Yerleşim Düzeni
***************
Sözleşme unsurlarını aşağıdaki sıraya göre düzenleyin:

1. Pragma ifadeleri
2. İçe aktarma ifadeleri
3. Arayüzler
4. Kütüphaneler
5. Sözleşmeler

Her bir sözleşme, kütüphane veya arayüzün içinde aşağıdaki sıralamayı kullanın:

1. Tip bildirimleri
2. Durum değişkenleri
3. Etkinlikler
4. Değiştiriciler
5. Fonksiyonlar

.. note::

Türleri, olaylarda veya durum değişkenlerinde kullanımlarına yakın bir yerde bildirmek daha açık olabilir.

******************
Adlandırma Kuralları
******************

Adlandırma kuralları benimsendiğinde ve geniş çapta kullanıldığında güçlüdür.  Farklı konvansiyonların kullanımı, aksi takdirde hemen elde edilemeyecek önemli *meta* bilgileri aktarabilir.
Burada verilen adlandırma önerileri okunabilirliği artırmaya yöneliktir ve bu nedenle kural değil, daha ziyade
çoğu bilgiyi nesnelerin isimleri aracılığıyla edinir.

Son olarak, bir kod tabanı içindeki tutarlılık her zaman bu belgede özetlenen kuralların yerine geçmelidir.

İsimlendirme Stilleri
=============

Karışıklığı önlemek için, farklı adlandırma stillerine atıfta bulunmak üzere aşağıdaki adlar kullanılacaktır.

* ``b`` (tek  küçük harf)
* ``B`` (tek büyük harf)
* ``lowercase``
* ``UPPERCASE``
* ``UPPER_CASE_WITH_UNDERSCORES``
* ``CapitalizedWords`` (veya CapWords)
* ``mixedCase`` (CapitalizedWords'den ilk küçük harf karakteri ile farklıdır!)

.. note:: CapWords'te baş harfleri kullanırken, baş harflerin tüm harflerini büyük yazın. Bu nedenle HTTPServerError, HttpServerError'dan daha iyidir. MixedCase'de baş harfleri kullanırken, baş harflerin tüm harflerini büyük yapın, ancak ismin başındaysa ilk harfi küçük tutun. Bu nedenle xmlHTTPRequest, XMLHTTPRequest'ten daha iyidir.


Kaçınılması Gereken İsimle
==============

* ``l`` - Küçük harf el
* ``O`` - Büyük harf oh
* ``I`` - Büyük harf eye

Tek harfli değişken adları için asla bunlardan birini kullanmayın.
bir ve sıfır rakamlarından ayırt edilemez.


Sözleşme ve Kütüphane İsimleri
==========================

* Sözleşmeler ve kütüphaneler CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``SimpleToken``, ``SmartBank``, ``CertificateHashRepository``, ``Player``, ``Congress``, ``Owned``.
* Sözleşme ve kütüphane adları da dosya adlarıyla eşleşmelidir.
* Bir sözleşme dosyası birden fazla sözleşme ve/veya kütüphane içeriyorsa, dosya adı *çekirdek sözleşme* ile eşleşmelidir. Ancak kaçınılması mümkünse bu önerilmez.

Aşağıdaki örnekte gösterildiği gibi, sözleşme adı ``Congress`` ve kütüphane adı ``Owned`` ise, ilişkili dosya adları ``Congress.sol`` ve ``Owned.sol`` olmalıdır.
Evet:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // Owned.sol
    contract Owned {
        address public owner;

        constructor() {
            owner = msg.sender;
        }

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address newOwner) public onlyOwner {
            owner = newOwner;
        }
    }

ve içinde ``Congress.sol``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    import "./Owned.sol";


    contract Congress is Owned, TokenRecipient {
        //...
    }

Hayır:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    // owned.sol
    contract owned {
        address public owner;

        constructor() {
            owner = msg.sender;
        }

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address newOwner) public onlyOwner {
            owner = newOwner;
        }
    }

ve içinde ``Congress.sol``:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.7.0;


    import "./owned.sol";


    contract Congress is owned, tokenRecipient {
        //...
    }

Struct İsimleri
==========================

Structs CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``MyCoin``, ``Position``, ``PositionXY``.


Event İsimleri
===========

Events CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``Deposit``, ``Transfer``, ``Approval``, ``BeforeTransfer``, ``AfterTransfer``.


Fonksiyon İsimleri
==============

Fonksiyonlar mixedCase kullanmalıdır. Örnekler: ``getBalance``, ``transfer``, ``verifyOwner``, ``addMember``, ``changeOwner``.


Fonksiyon Argüman Adları
=======================

Fonksiyon argümanları mixedCase kullanmalıdır. Örnekler: ``initialSupply``, ``account``, ``recipientAddress``, ``senderAddress``, ``newOwner``.
Özel bir struct üzerinde çalışan kütüphane işlevleri yazarken, struct ilk argüman olmalı ve her zaman ``self`` olarak adlandırılmalıdır.

YerSabitlerel ve Durum Değişken Adları
==============================

MixedCase kullanın. Örnekler: ``totalSupply``, ``remainingSupply``, ``balancesOf``, ``creatorAddress``, ``isPreSale``, ``tokenExchangeRate``.


Sabitler
=========

Sabitler, sözcükleri ayıran alt çizgiler ile tüm büyük harflerle adlandırılmalıdır. Örnekler: ``MAX_BLOCKS``, ``TOKEN_NAME``, ``TOKEN_TICKER``, ``CONTRACT_VERSION``.


Değiştirici İsimleri
==============

MixedCase kullanın. Örnekler: ``onlyBy``, ``onlyAfter``, ``onlyDuringThePreSale``.


Enumlar
=====

Enumlar, basit tip bildirimleri tarzında, CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``TokenGroup``, ``Frame``, ``HashStyle``, ``CharacterLocation``.


İsim Çakışmalarını Önleme
==========================

* ``singleTrailingUnderscore_``

Bu kural, istenen adın yerleşik veya başka şekilde ayrılmış bir adla çakışması durumunda önerilir.

.. _style_guide_natspec:

*******
NatSpec
*******

Solidity sözleşmeleri NatSpec yorumları da içerebilir. Bunlar üçlü eğik çizgi (``//``) veya çift yıldız bloğu (``/** ... */``) ile yazılır ve
doğrudan fonksiyon bildirimlerinin veya ifadelerinin üzerinde kullanılmalıdır.
Örneğin, :ref:`a simple smart contract <simple-smart-contract>` sözleşmesi yorumlar eklendiğinde aşağıdaki gibi görünür:
.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    /// @author The Solidity Team
    /// @title A simple storage example
    contract SimpleStorage {
        uint storedData;

        /// Store `x`.
        /// @param x the new value to store
        /// @dev stores the number in the state variable `storedData`
        function set(uint x) public {
            storedData = x;
        }

        /// Return the stored value.
        /// @dev retrieves the value of the state variable `storedData`
        /// @return the stored value
        function get() public view returns (uint) {
            return storedData;
        }
    }

Solidity sözleşmelerinin tüm genel arayüzler (ABI'deki her şey) için :ref:`NatSpec <natspec>` kullanılarak tam olarak açıklanması önerilir.

Ayrıntılı açıklama için lütfen :ref:`NatSpec <natspec>` ile ilgili bölüme bakın.
