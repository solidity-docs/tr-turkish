.. index:: style, coding style

#############
Stil Klavuzu
#############

************
Giriş
************

Bu kılavuz, Solidity kodu yazmak için kodlama kuralları sağlamayı amaçlamaktadır.
Bu kılavuz, yararlı kurallar bulundukça ve eski kurallar kullanılmaz hale geldikçe zaman içinde değişen bir belge olarak düşünülmelidir.

Birçok proje kendi stil kılavuzlarını uygulayabilir.  Uyuşmazlık durumunda, projeye özgü stil kılavuzları önceliklidir.

Bu stil kılavuzunun yapısı ve içindeki önerilerin çoğu python'un `pep8 stil kılavuzundan <https://www.python.org/dev/peps/pep-0008/>`_ alınmıştır.

Bu kılavuzun amacı *Solidity kodu yazmanın doğru yolu ya da en iyi yolunu göstermek değildir*.  Bu kılavuzun amacı *tutarlılıktır*.  Python'un `pep8 <https://www.python.org/dev/peps/pep-0008/#a-foolish consistency-is-the-hobgoblin-of-little-minds>`_ adlı kitabından bir alıntı bu kavramı iyi özetlemektedir.

.. note::

    Stil rehberi tutarlılıkla ilgilidir. Bu stil rehberi ile tutarlılık önemlidir. Bir proje içindeki tutarlılık daha önemlidir. Bir modül veya fonksiyon içindeki tutarlılık ise en mühim olanıdır.

    Ama en önemlisi: **Ne zaman tutarsız olmanız gerektiğini bilmenizdir** — bazen bu stil kılavuzu geçerli olmayabilir. Şüpheye düştüğünüzde, en iyi kararınızı verip yolunuza devam edin. Diğer örneklere bakın ve neyin en iyi göründüğüne karar verin. Ayrıca soru sormaktan çekinmeyin!

***********
Kod Düzeni
***********


Girintiler
===========

Her girinti seviyesi için 4 boşluk kullanın.

Sekmeler(Tab) veya Boşluklar
============================

Boşluklar en çok tercih edilen girinti oluşturma yöntemidir.

Tablar ve boşlukları karıştırmaktan kaçınmalısınız.

Boş Satırlar
===========

Solidity kaynağındaki üst düzey bildirimleri iki boş satırla çevreleyin.

Yapın:

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

Yapmayın:

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

Bir sözleşme içinde fonksiyon tanımlarının etrafını tek bir boş satırla çevreleyin.

Birbiriyle ilişkili tek satırlık gruplar arasında boş satırlar atlanabilir ( abstract sözleşme için stub fonksiyonları gibi)

Yapın:

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

Yapmayın:

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
=========================

`PEP 8 önerisi <https://www.python.org/dev/peps/pep-0008/#maximum-line-length>`_ altındaki satırları en fazla 79 (veya 99) karakterde tutmak, okuyucuların kodu kolayca çözümlemelerine yardımcı olur.

Sarılmış(Wrapped) satırlar aşağıdaki yönergelere uygun olmalıdır.

1. İlk argüman açılış parantezine eklenmemelidir.
2. Bir ve yalnızca bir girinti kullanılmalıdır.
3. Her argüman kendi satırında yer almalıdır.
4. Sonlandırıcı öğe, :code:`);`, tek başına son satıra yerleştirilmelidir.

Fonksiyon Çağrıları

Yapın:

.. code-block:: solidity

    thisFunctionCallIsReallyLong(
        longArgument1,
        longArgument2,
        longArgument3
    );

Yapmayın:

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

Atama İfadeleri

Yapın:

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(
        argument1,
        argument2,
        argument3,
        argument4
    );

Yapmayın:

.. code-block:: solidity

    thisIsALongNestedMapping[being][set][toSomeValue] = someFunction(argument1,
                                                                       argument2,
                                                                       argument3,
                                                                       argument4);

Event Tanımları ve Event Emitterları

Yapın:

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

Yapmayın:

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

Kaynak Dosya Encoding
=====================

UTF-8 yada ASCII encoding tercih edilir.

Imports (İçe Aktarmalar)
============================

İçe aktarma ifadeleri her zaman dosyanın en üstüne yerleştirilmelidir.

Yapın:

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

Yapmayın:

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

Fonksiyonların Sıralaması
=========================

Sıralandırma, okuyucuların hangi fonksiyonları çağırabileceklerini belirlemelerine ve constructor ve fallback tanımlamalarını daha kolay bulmalarına yardımcı olur.

Fonksiyonlar görünürlük durumlarına göre gruplandırılmalı ve sıralanmalıdır:

- constructor
- receive fonksiyon (eğer mevcutsa)
- fallback fonksiyon (eğer mevcutsa)
- external
- public
- internal
- private

Bir gruplandırma yaparken, ``view`` ve ``pure`` fonksiyonlarını en sona yerleştirin.

Yapın:

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

Yapmayın:

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

Aşağıdaki durumlarda gereksiz boşluk bırakmaktan kaçının:

Tek satırlık fonksiyon tanımlamaları hariç olmak üzere, parantez, köşeli parantez veya ayraçların hemen içinde.

Yapın:

.. code-block:: solidity

    spam(ham[1], Coin({name: "ham"}));

Yapmayın:

.. code-block:: solidity

    spam( ham[ 1 ], Coin( { name: "ham" } ) );

İstisna:

.. code-block:: solidity

    function singleLine() public { spam(); }

Virgülden, noktalı virgülden hemen önce:

Yapın:

.. code-block:: solidity

    function spam(uint i, Coin coin) public;

Yapmayın:

.. code-block:: solidity

    function spam(uint i , Coin coin) public ;

Bir atama veya başka bir operatörün etrafında, diğeriyle hizalamak için birden fazla boşluk:

Yapın:

.. code-block:: solidity

    x = 1;
    y = 2;
    longVariable = 3;

Yapmayın:

.. code-block:: solidity

    x            = 1;
    y            = 2;
    longVariable = 3;

receive ve fallback fonksiyonlarına boşluk eklemeyin:

Yapın:

.. code-block:: solidity

    receive() external payable {
        ...
    }

    fallback() external {
        ...
    }

Yapmayın:

.. code-block:: solidity

    receive () external payable {
        ...
    }

    fallback () external {
        ...
    }


Kontrol Yapıları (Control Structures)
=====================================

Bir sözleşmenin, kütüphanenin, fonksiyonların ve struct'ların gövdelerini belirten parantezler:

* Bildirim (Declaration) ile aynı satırda açılmalıdır
* Bildirimin başlangıcıyla aynı girinti seviyesinde kendi satırlarında kapanmalıdır.
* Açılış parantezinden önce tek bir boşluk bırakılmalıdır.

Yapın:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Coin {
        struct Bank {
            address owner;
            uint balance;
        }
    }

Yapmayın:

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

Ayrıca, ``if``, ``while`` ve ``for`` kontrol yapıları ile koşulu temsil eden parantez bloğu arasında tek bir boşluk ve koşullu parantez bloğu ile açılış parantezi arasında tek bir boşluk olmalıdır.

Yapın:

.. code-block:: solidity

    if (...) {
        ...
    }

    for (...) {
        ...
    }

Yapmayın:

.. code-block:: solidity

    if (...)
    {
        ...
    }

    while(...){
    }

    for (...) {
        ...;}

Gövdesi tek bir ifade içeren kontrol yapıları için, parantezleri atlamak *eğer* ifade tek bir satırda yer alıyorsa uygundur.

Yapın:

.. code-block:: solidity

    if (x < 10)
        x += 1;

Yapmayın:

.. code-block:: solidity

    if (x < 10)
        someArray.push(Coin({
            name: 'spam',
            value: 42
        }));

Bir ``else`` veya ``else if`` ibaresi içeren ``if`` blokları için, ``else`` ibaresi ``if`` ibaresinin kapanış paranteziyle aynı satıra yerleştirilmelidir. Bu, diğer blok benzeri yapıların kurallarına kıyasla bir istisnadır.

Yapın:

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

Yapmayın:

.. code-block:: solidity

    if (x < 3) {
        x += 1;
    }
    else {
        x -= 1;
    }

Fonksiyon Tanımlamaları
=============================

Kısa fonksiyon bildirimleri için, fonksiyon gövdesinin açılış ayracının fonksiyon bildirimiyle aynı satırda tutulması önerilir.

Kapanış parantezi fonksiyon bildirimi ile aynı girinti seviyesinde olmalıdır.

Açılış ayracından önce tek bir boşluk bırakılmalıdır.

Yapın:

.. code-block:: solidity

    function increment(uint x) public pure returns (uint) {
        return x + 1;
    }

    function increment(uint x) public pure onlyOwner returns (uint) {
        return x + 1;
    }

Yapmayın:

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

Bir fonksiyon için modifier sırası şöyle olmalıdır:

1. Visibility
2. Mutability
3. Virtual
4. Override
5. Custom modifiers

Yapın:

.. code-block:: solidity

    function balance(uint from) public view override returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() public onlyOwner {
        selfdestruct(owner);
    }

Yapmayın:

.. code-block:: solidity

    function balance(uint from) public override view returns (uint)  {
        return balanceOf[from];
    }

    function shutdown() onlyOwner public {
        selfdestruct(owner);
    }

Uzun fonksiyon bildirimleri için, her argümanın fonksiyon gövdesiyle aynı girinti seviyesinde kendi satırına bırakılması önerilir.  Kapanış parantezi ve açılış parantezi de fonksiyon bildirimi ile aynı girinti seviyesinde kendi satırlarına yerleştirilmelidir.

Yapın:

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

Yapmayın:

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

Uzun bir fonksiyon bildiriminde modifier'lar varsa, her modifier kendi satırına bırakılmalıdır.

Yapın:

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

Yapmayın:

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

Çok satırlı çıktı parametreleri ve return ifadeleri, :ref:`Maximum Line Length <maximum_line_length>` bölümünde bulunan uzun satırları çevrelemek için önerilen aynı stili izlemelidir.

Yapın:

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

Yapmayın:

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

Tabanları argüman gerektiren inherited sözleşmelerdeki constructor fonksiyonları için, fonksiyon bildirimi uzunsa veya okunması zorsa, temel constructor'ların modifier'larla aynı şekilde yeni satırlara bırakılması önerilir.

Yapın:

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

Yapmayın:

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


Kısa fonksiyonları tek bir ifadeyle bildirirken, bunu tek bir satırda yapmaya izin verilir.

İzin verilebilir:

.. code-block:: solidity

    function shortFunction() public { doSomething(); }

Fonksiyon bildirimleri için bu kılavuzun amacı okunabilirliği artırmaktır. Bu kılavuz, fonksiyon bildirimleri için olası tüm olasılıkları kapsamaya çalışmadığından, yazarlar en iyi kararlarını vermelidir.

Mappingler
==========

Değişken bildirimlerinde, ``mapping`` anahtar sözcüğünü türünden bir boşlukla ayırmayın. İç içe geçmiş ``mapping`` anahtar sözcüğünü türünden boşluk ile ayırmayın.

Yapın:

.. code-block:: solidity

    mapping(uint => uint) map;
    mapping(address => bool) registeredAddresses;
    mapping(uint => mapping(bool => Data[])) public data;
    mapping(uint => mapping(uint => s)) data;

Yapmayın:

.. code-block:: solidity

    mapping (uint => uint) map;
    mapping( address => bool ) registeredAddresses;
    mapping (uint => mapping (bool => Data[])) public data;
    mapping(uint => mapping (uint => s)) data;

Değişken Bildirimleri
=====================

Dizi değişkenlerinin bildirimlerinde tür ile parantezler arasında boşluk olmamalıdır.

Yapın:

.. code-block:: solidity

    uint[] x;

Yapmayın:

.. code-block:: solidity

    uint [] x;


Diğer Öneriler 
=====================

* Stringler tek tırnak yerine çift tırnak ile alıntılanmalıdır.

Yapın:

.. code-block:: solidity

    str = "foo";
    str = "Hamlet says, 'To be or not to be...'";

Yapmayın:

.. code-block:: solidity

    str = 'bar';
    str = '"Be yourself; everyone else is already taken." -Oscar Wilde';

* Operatörleri her iki tarafta tek bir boşlukla çevrelendirmelisiniz.

Yapın:

.. code-block:: solidity
    :force:

    x = 3;
    x = 100 / 10;
    x += 3 + 4;
    x |= y && z;

Yapmayın:

.. code-block:: solidity
    :force:

    x=3;
    x = 100/10;
    x += 3+4;
    x |= y&&z;

* Diğerlerinden daha yüksek önceliğe sahip operatörler, önceliği belirtmek için çevreleyen beyaz boşluğu kaldırabilir.  Bunun amacı, karmaşık ifadeler için daha iyi okunabilirlik sağlamaktır. Bir operatörün her iki tarafında da her zaman aynı miktarda boşluk kullanmalısınız:

Yapın:

.. code-block:: solidity

    x = 2**3 + 5;
    x = 2*y + 3*z;
    x = (a+b) * (a-b);

Yapmayın:

.. code-block:: solidity

    x = 2** 3 + 5;
    x = y+z;
    x +=1;

***************
Yerleşim Sırası
***************

Sözleşme unsurlarını aşağıdaki sıraya göre düzenleyin:

1. Pragma ifadeleri
2. Import ifadeleri
3. Interface'ler
4. Library'ler
5. Sözleşmeler

Her bir sözleşme, kütüphane veya arayüzün içinde aşağıdaki sıralamayı kullanın:

1. Type bildirimleri
2. Durum değişkenleri
3. Event'ler
4. Modifier'lar
5. Fonksiyonlar

.. note::

    Türleri, event'lerde veya durum değişkenlerinde kullanımlarına yakın bir yerde bildirmek daha anlaşılır 
    olabilir.

********************
Adlandırma Kuralları
********************

Adlandırma kuralları benimsendiğinde ve geniş çapta kullanıldığında güçlüdür.  Farklı konvansiyonların kullanımı, aksi takdirde hemen elde edilemeyecek önemli *meta* bilgileri aktarabilir.

Burada verilen adlandırma önerileri okunabilirliği artırmayı amaçlamaktadır ve bu nedenle kural değil, daha ziyade nesnelerin adları aracılığıyla en fazla bilgiyi iletmeye yardımcı olacak kılavuzlardır.

Son olarak, bir kod tabanı içindeki tutarlılık her zaman bu belgede özetlenen kuralların yerine geçmelidir.


Adlandırma Stili
====================

Karışıklığı önlemek için, farklı adlandırma stillerine atıfta bulunmak üzere aşağıdaki adlar kullanılacaktır.

* ``b`` (tek küçük harf)
* ``B`` (tek büyük harf)
* ``lowercase``
* ``UPPERCASE``
* ``UPPER_CASE_WITH_UNDERSCORES``
* ``CapitalizedWords`` (veya CapWords)
* ``mixedCase`` (ilk küçük harf karakteri ile CapitalizedWords`den farklıdır!)

.. note:: CapWords'te baş harfleri kullanırken, baş harflerin tüm harflerini büyük yazın. Bu nedenle HTTPServerError, HttpServerError adlandırmasından daha iyidir. MixedCase'de baş harfleri kullanırken, baş harflerin tüm harflerini büyük yazın, ancak ismin başındaysa ilk harfi küçük tutun. Bu nedenle xmlHTTPRequest, XMLHTTPRequest adlandırmasından daha iyidir.


Uzak Durulması Gereken İsimler
===============================

* ``l`` - Küçük harf le
* ``O`` - Büyük harf o
* ``I`` - Büyük harf I

Bunlardan hiçbirini tek harfli değişken adları için kullanmayın.  Bunlar genellikle
bir ve sıfır rakamlarından ayırt edilemez.


Sözleşme ve Kütüphane Adları
================================

* Sözleşmeler ve kütüphaneler CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``SimpleToken``, ``SmartBank``, ``CertificateHashRepository``, ``Player``, ``Congress``, ``Owned``.
* Sözleşme ve kütüphane adları da dosya adlarıyla eşleşmelidir.
* Bir sözleşme dosyası birden fazla sözleşme ve/veya kütüphane içeriyorsa, dosya adı *çekirdek sözleşme* ile eşleşmelidir. Ancak kaçınılması mümkünse bu önerilmez.

Aşağıdaki örnekte gösterildiği gibi, sözleşme adı ``Congress`` ve kütüphane adı ``Owned`` ise, ilişkili dosya adları ``Congress.sol`` ve ``Owned.sol`` olmalıdır.

Yapın:

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

ve ``Congress.sol`` içinde:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    import "./Owned.sol";


    contract Congress is Owned, TokenRecipient {
        //...
    }

Yapmayın:

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

ve ``Congress.sol`` içinde:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.7.0;


    import "./owned.sol";


    contract Congress is owned, tokenRecipient {
        //...
    }

Struct Adları
==========================

Struct'lar CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``MyCoin``, ``Position``, ``PositionXY``.


Event Adları
==============

Event'ler CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``Deposit``, ``Transfer``, ``Approval``, ``BeforeTransfer``, ``AfterTransfer``.


Fonksiyon Adları
=================

Fonksiyonlar mixedCase kullanmalıdır. Örnekler: ``getBalance``, ``transfer``, ``verifyOwner``, ``addMember``, ``changeOwner``.


Fonksiyon Argüman Adları
==========================

Fonksiyon argümanları mixedCase kullanmalıdır. Örnekler: ``initialSupply``, ``account``, ``recipientAddress``, ``senderAddress``, ``newOwner``.

Özel bir struct üzerinde çalışan kütüphane fonksiyonları yazarken, struct ilk argüman olmalı ve her zaman ``self`` olarak adlandırılmalıdır.


Yerel ve Durum Değişkeni Adları
================================

MixedCase kullanın. Örnekler: ``totalSupply``, ``remainingSupply``, ``balancesOf``, ``creatorAddress``, ``isPreSale``, ``tokenExchangeRate``.


Constant'lar (Sabitler)
===========================

Constantlar, sözcükleri ayıran alt çizgiler ile tüm büyük harflerle adlandırılmalıdır. Örnekler: ``MAX_BLOCKS``, ``TOKEN_NAME``, ``TOKEN_TICKER``, ``CONTRACT_VERSION``.


Modifier Adları
================

MixedCase kullanın. Örnekler: ``onlyBy``, ``onlyAfter``, ``onlyDuringThePreSale``.


Enumlar
=======

Enumlar, basit tip bildirimleri tarzında, CapWords stili kullanılarak adlandırılmalıdır. Örnekler: ``TokenGroup``, ``Frame``, ``HashStyle``, ``CharacterLocation``.


Adlandırma Çakışmalarını Önleme
================================

* ``singleTrailingUnderscore_``

Bu kural, istenen adın yerleşik veya başka şekilde ayrılmış bir adla çakışması durumunda önerilir.

.. _style_guide_natspec:

*******
NatSpec
*******

Solidity sözleşmeleri NatSpec yorumları da içerebilir. Bunlar üçlü eğik çizgi (``///``) veya çift yıldız bloğu (``/** ... */``) ile yazılır ve doğrudan fonksiyon bildirimlerinin veya ifadelerin üzerinde kullanılmalıdır.

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
