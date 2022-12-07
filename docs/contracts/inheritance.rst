.. index:: ! inheritance, ! base class, ! contract;base, ! deriving

***********
Kalıtım
***********

Solidity polimorfizm dahil birçok kalıtım yöntemini destekler.

Polimorfizm, bir fonksiyon çağrısının (dahili ve harici),
kalıtım hiyerarşisinde aynı fonksiyona sahip birden fazla
akıllı sözleşmenin olması durumunda, ilk türetilen akıllı sözleşmenin fonksiyonunun
çalıştırılmasına verilen isimdir.
Bu, ``virtual`` ve ``override`` anahtar sözcükleri kullanılarak hiyerarşideki
her işlevde açıkça etkinleştirilmelidir. Daha fazla ayrıntı için
:ref:`Function Overriding'e <function-overriding>` bakın.

Kalıtım hiyerarşisinden bir fonksiyonu çağırmak isterseniz;
``ContractName.functionName()`` bu şekilde çağırabilirsiniz. Veya
kalıtım hiyerarşisinde bir üst akıllı sözleşmede bulunan bir fonksiyonu
çağırmak isterseniz de; ``super.functionName()`` kullanabilirsiniz.

Bir akıllı sözleşme başka bir akıllı sözleşmeyi türettiğinde, blockchainde sadece bir adet
akıllı sözleşme oluşturulur ve tüm ana akıllı sözleşmelerden gelen kodlar oluşturulan
akıllı sözleşmeye eklenir. Bu demek oluyorki ana akıllı sözleşmelerin fonksiyonlarına
yapılan bütün internal çağrılar sadece internal fonksiyon çağrılarını
kullanırlar (``super.f(..)`` sadece JUMP opcode'unu kullanacaktır, mesaj çağrısı yapmayacaktır). 

Durum değişkeni gölgeleme bir hata olarak kabul edilir. Bir türetilen akıllı sözleşme
sadece ve sadece eğer türettiği akıllı sözleşmelerden hiçbiri ``x`` isminde bir değişkeni kullanmıyorsa
bu isimde bir değişken tanımlayabilir.

Genel kalıtım sistemi `Python'a <https://docs.python.org/3/tutorial/classes.html#inheritance>`_
oldukça benzer, özellikle de çoklu kalıtım konusunda, fakat ayrıca bazı :ref:`farklılıklar <multi-inheritance>` da bulunmaktadır

Aşağıdaki örnekte detaylar açıklanmıştır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;


    contract Owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }


    // `is` kullanarak başka bir akıllı sözleşmeyi türetebiliriz.
    // Türetilen akıllı sözleşmeler private olmayan bütün üyelere
    // erişebilir, internal fonksiyonlar ve durum değişkenleri
    // dahil. Bunlara external olarak `this` kullanılarak da erişilemez.
    contract Destructible is Owned {
        // `virtual` sözcüğü bu fonksiyonun, türetilen
        // akıllı sözleşmelerde değiştirilebileceğini belirtir ("overriding").
        function destroy() virtual public {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }


    // Abstract akıllı sözleşmeler sadece derleyiciye interface'i
    // bildirmek için kullanılır. Fonksiyonun kodlarının olmadığına
    // dikkat edin. Eğer bir akıllı sözleşme bütün fonksiyonlarının içeriğini
    // bulundurmazsa, sadece interface olarak da kullanılabilir.
    abstract contract Config {
        function lookup(uint id) public virtual returns (address adr);
    }


    abstract contract NameReg {
        function register(bytes32 name) public virtual;
        function unregister() public virtual;
    }


    // Çoklu türetim de mümkündür. `Owned` akıllı sözleşmesinin
    // ayrıca `Destructible` akıllı sözleşmesinin ana akıllı sözleşmelerinden
    // biri olduğunu unutmayın. Ancak `Owned` akıllı sözleşmesinin 
    // sadece bir adet örneği vardır (C++'daki sanal kalıtım gibi).
    contract Named is Owned, Destructible {
        constructor(bytes32 name) {
            Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
            NameReg(config.lookup(1)).register(name);
        }

        // Fonksiyonlar başka bir fonksiyon tarafından aynı isim ve aynı
        // sayıda/tipte girdi ile override edilebilir. Eğer override eden
        // fonksiyon farklı sayıda çıktı veriyorsa, bu ortaya bir hata çıkarır.
        // Hem yerel hem de mesaj-tabanlı fonksiyon çağrıları bu override işlemlerini
        // hesaba katar. Eğer bir fonksiyonu override etmek istiyorsanız
        // `override` sözcüğünü kullanmak zorundasınız. Ayrıca fonksiyonunuzun
        // tekrardan override edilebilir olmasını istiyorsanız, tekrardan
        // `virtual` olarak belirlemelisiniz.
        function destroy() public virtual override {
            if (msg.sender == owner) {
                Config config = Config(0xD5f9D8D94886E70b06E474c3fB14Fd43E2f23970);
                NameReg(config.lookup(1)).unregister();
                // Override edilmiş bir fonksiyonu spesifik olarak
                // çağırmak mümkündür.
                Destructible.destroy();
            }
        }
    }


    // Eğer bir constructor parametre alıyorsa, bu
    // başlıkta veya değiştirici-çağırma-stili ile
    // türetilen akıllı sözleşmesinin constructor'ında
    // verilmelidir (aşağıya bakın).
    contract PriceFeed is Owned, Destructible, Named("GoldFeed") {
        function updateInfo(uint newInfo) public {
            if (msg.sender == owner) info = newInfo;
        }

        // Burada sadece `override` yazıyoruz, `virtual` yazmıyoruz.
        // Bu, `PriceFeed` akıllı sözleşmesinden türetilen akıllı sözleşmelerin
        // artık `destroy` fonksiyonunu override edemeyecekleri anlamına geliyor.
        function destroy() public override(Destructible, Named) { Named.destroy(); }
        function get() public view returns(uint r) { return info; }

        uint info;
    }

Yukarıdaki ``Destructible.destroy()`` fonksiyon çağrımızın bazı problemlere
yol açtığını aşağıdaki örnekte görebilirsiniz.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }

    contract Destructible is owned {
        function destroy() public virtual {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }

    contract Base1 is Destructible {
        function destroy() public virtual override { /* do cleanup 1 */ Destructible.destroy(); }
    }

    contract Base2 is Destructible {
        function destroy() public virtual override { /* do cleanup 2 */ Destructible.destroy(); }
    }

    contract Final is Base1, Base2 {
        function destroy() public override(Base1, Base2) { Base2.destroy(); }
    }

``Final.destroy()`` çağrısı ``Base2.destroy`` fonksiyonunu çağıracak.
Çünkü yaptığımız son override'da böyle belirtti. Ancak bu fonksiyon
``Base1.destroy`` fonksiyonunu bypass eder. 

A call to ``Final.destroy()`` will call ``Base2.destroy`` because we specify it
explicitly in the final override, but this function will bypass
``Base1.destroy``. Bunu aşmanın yolu ``super`` kelimesini kullanmaktır:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;
    }

    contract Destructible is owned {
        function destroy() virtual public {
            if (msg.sender == owner) selfdestruct(owner);
        }
    }

    contract Base1 is Destructible {
        function destroy() public virtual override { /* do cleanup 1 */ super.destroy(); }
    }


    contract Base2 is Destructible {
        function destroy() public virtual override { /* do cleanup 2 */ super.destroy(); }
    }

    contract Final is Base1, Base2 {
        function destroy() public override(Base1, Base2) { super.destroy(); }
    }

``Base2`` , ``super`` işlevini çağırırsa, bu işlevi temel sözleşmelerinden
birinde çağırmaz. Bunun yerine, son kalıtım grafiğindeki bir sonraki temel 
sözleşmede bu işlevi çağırır, bu nedenle ``Base1.destroy()`` u çağırır 
(son kalıtım dizisinin -- en türetilmiş sözleşmeyle başlayarak şöyle 
olduğuna dikkat edin: Final, Base2, Base1, Destructible, owned). 
super kullanılırken çağrılan asıl işlev, türü bilinmesine rağmen kullanıldığı 
sınıf bağlamında bilinmemektedir. Bu, sıradan sanal yöntem araması için benzerdir.

.. index:: ! overriding;function

.. _function-overriding:

Fonksiyon Override Etme
========================

Temel fonksiyonlar ``virtual`` olarak işaretlenmişse, davranışlarını
değiştirmek için override edilebilirler. Override eden fonksiyon
``override`` olarak belirlenmelidir. Override edilen fonksiyonun
görünürlüğü ``external``'dan ``public``'e dönüştürülebilir.
Değişebilirlik ise daha fazla kısıtlandırılmış bir yapıya dönüştürülebilir:
``nonpayable``, ``view`` ve ``pure`` tarafından override edilebilir.
``view`` ise ``pure`` tarafından override edilebilir. ``payable`` bir istisna
olarak diğer değişebilirlik türlerine dönüştürülemez.

Aşağıdaki örnek değişebilirliği ve görünürlüğü değiştirmeyi açıklıyor:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base
    {
        function foo() virtual external view {}
    }

    contract Middle is Base {}

    contract Inherited is Middle
    {
        function foo() override public pure {}
    }

Çoklu kalıtım için, aynı işlevi tanımlayan en çok türetilmiş temel sözleşmeler,
``override`` anahtar sözcüğünden sonra açıkça belirtilmelidir. Başka bir deyişle, 
aynı işlevi tanımlayan ve henüz başka bir temel sözleşme tarafından geçersiz 
kılınmamış tüm temel sözleşmeleri belirtmeniz gerekir (miras grafiği boyunca bir yolda). 
Ek olarak, bir sözleşme aynı işlevi birden çok (ilgisiz) temelden devralırsa, 
bunu açıkça geçersiz kılması gerekir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base1
    {
        function foo() virtual public {}
    }

    contract Base2
    {
        function foo() virtual public {}
    }

    contract Inherited is Base1, Base2
    {
        // foo() fonksiyonuna sahip birden fazla temel akıllı sözleşmesi türetir.
        // Bu yüzden override etmek için açıkça belirtmeliyiz.
        function foo() public override(Base1, Base2) {}
    }

Fonksiyon, ortak bir temel sözleşmede tanımlanmışsa veya ortak 
bir temel sözleşmede diğer tüm işlevleri zaten override 
eden benzersiz bir işlev varsa, açık bir override 
belirteci gerekli değildir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract A { function f() public pure{} }
    contract B is A {}
    contract C is A {}
    // Açıkça override gerekmemektedir.
    contract D is B, C {}

Daha resmi olarak, imza için tüm override etme yollarının 
parçası olan bir temel sözleşme varsa, birden çok tabandan 
devralınan bir fonksiyonu (doğrudan veya dolaylı olarak) override 
etme gerekli değildir ve (1) bu taban fonksiyonu uygular ve mevcut
akıllı sözleşmeden tabana giden hiçbir yol bu imzaya sahip bir fonksiyondan bahsetmez
veya (2) bu taban fonksiyonu yerine getirmiyor ve mevcut akıllı sözleşmeden
o tabana kadar olan tüm yollarda fonksiyondan en fazla bir kez söz ediliyor.

Bu anlamda, bir imza için override etme yolu, söz konusu 
akıllı sözleşmede başlayan ve override etmeyen bu imzaya sahip bir 
işlevden bahseden bir akıllı sözleşmede sona eren miras grafiği boyunca bir yoldur.

Override eden bir fonksiyonu ``virtual`` olarak işaretlemezseniz,
türetilmiş sözleşmeler artık bu fonksiyonun davranışını değiştiremez.

.. note::

  ``private`` görünürlüğe sahip fonksiyonlar ``virtual`` olamaz.

.. note::

  Interface dışında olup da kodu olmayan fonksiyonlar ``virtual``
  olarak işaretlenmelidir. Interface içerisindeki bütün fonksiyonlar
  otomatikmen ``virtual`` olarak düşünülür.

.. note::

  Solidity 0.8.8 itibari ile bir interface fonksiyonunu override
  ederken ``override`` sözcüğünü kullanmanıza gerek kalmıyor,
  birden fazla temel akıllı sözleşmede tanımlanan fonksiyonlar dışında.

Public durum değişkenleri parametre ve dönüş tipleri uyuştuğu zaman
bir external fonksiyonu override edebilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract A
    {
        function f() external view virtual returns(uint) { return 5; }
    }

    contract B is A
    {
        uint public override f;
    }

.. note::

  Public durum değişkenleri external fonksiyonları override edebilirken,
  kendileri override edilemez.

.. index:: ! overriding;modifier

.. _modifier-overriding:

Modifier Override Etme
=======================

Fonksiyon modifier'ları birbirlerini override edebilirler. Bu aynı
:ref:`fonksiyon override etmedeki <function-overriding>` gibidir
(modifierlarda overload etme olmamakla istisnası ile). ``virtual`` sözcüğü
override edilecek modifier'da kullanılmalı ve override eden modifier'da ise
``override`` sözcüğü kullanılmalıdır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base
    {
        modifier foo() virtual {_;}
    }

    contract Inherited is Base
    {
        modifier foo() override {_;}
    }

Çoklu kalıtım durumumnda bütün temel akıllı sözleşmeler açıkça override edilme
durumunu belirtmelidir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Base1
    {
        modifier foo() virtual {_;}
    }

    contract Base2
    {
        modifier foo() virtual {_;}
    }

    contract Inherited is Base1, Base2
    {
        modifier foo() override(Base1, Base2) {_;}
    }



.. index:: ! constructor

.. _constructor:

Constructor'lar
================

Constructor isteğe bağlı olarak tanımlanan özel fonksiyonlardan biridir ve
``constructor`` sözcüğü ile tanımlanır. Bu fonksiyon akıllı sözleşme oluşumu sırasında
çalıştırılır ve akıllı sözleşme başlatma kodunuz burada bulunmaktadır.

Constructor kodu çalıştırılmadan önce durum değişkenleri eğer aynı satırda
tanımladıysanız gerekli değer atamalarını veya tanımlamadıysanız
:ref:`default değerlerini<default-value>` alırlar.

Constructor çalıştırıldıktan sonra kodun son hali blockchain'e yüklenir. Bu işlemin
ücreti ise lineer bir şekilde olup kodun uzunluğuna bağımlıdır. Bu kod dışarıdan
erişilebilecek ve bir fonksiyon tarafından erişilen bütün fonksiyonları içerir.
Constructor kodunu veya sadece constructor tarafından erişilen internal fonksiyonları
içermez.

Eğer constructor yoksa, default constructor çalıştırılır ``constructor() {}``.
Örneğin:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    abstract contract A {
        uint public a;

        constructor(uint a_) {
            a = a_;
        }
    }

    contract B is A(1) {
        constructor() {}
    }

Constructor'larda internal parametreleri kullanabilirsiniz (örneğin, storage pointer'ları).
Bu durumda akıllı sözleşme :ref:`abstract <abstract-contract>` olarak işaretlenmelidir. Çünkü bu
parametrelere dışarıdan geçerli değerler atanamaz, ancak yalnızca türetilmiş sözleşmelerin 
constructor'ları aracılığıyla atanır.

.. warning ::
    Versiyon 0.4.22 öncesinde constructor'lar akıllı sözleşme ile aynı isme sahip fonksiyonlar
    olarak kullanılırdı. Ancak bu yazılış biçiminin Versiyon 0.5.0 sonrasında kullanımına izin
    verilmemektedir.
    
.. warning ::
    Versiyon 0.7.0 öncesinde constructor'ların görünürlüğünü ``internal`` veya ``public``
    olarak belirtmek zorundaydınız.

.. index:: ! base;constructor, inheritance list, contract;abstract, abstract contract

Temel Constructor'lar için Argümanlar
======================================

Tüm temel akıllı sözleşmelerin constructor'ları, aşağıda açıklanan doğrusallaştırma kurallarına göre çağrılacaktır. 
Temel akıllı sözleşmelerin argümanları varsa, türetilmiş akıllı sözleşmelerin hepsini belirtmesi gerekir. 
Bu iki şekilde yapılabilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base {
        uint x;
        constructor(uint x_) { x = x_; }
    }

    // Direkt kalıtım listesinde belirtme...
    contract Derived1 is Base(7) {
        constructor() {}
    }

    // veya "modifier" stilinde belirtme...
    contract Derived2 is Base {
        constructor(uint y) Base(y * y) {}
    }

    // veya abstract olarak belirtin...
    abstract contract Derived3 is Base {
    }

    // ve bir sonraki contractın onu başlatmasını sağlayın.
    contract DerivedFromDerived is Derived3 {
        constructor() Base(10 + 10) {}
    }

Bir yol doğrudan kalıtım listesindedir (``is Base(7)``). Diğeri, türetilmiş constructor'ın 
bir parçası olarak bir modifier'ın çağrılma biçimindedir (``Base(y * y)``). 
Bunu yapmanın ilk yolu, constructor argümanının sabit olması ve akıllı sözleşmenin davranışını 
tanımlaması veya tanımlaması durumunda daha uygundur. Temel constructor argümanları 
türetilmiş akıllı sözleşmenin argümanlarına bağlıysa, ikinci yol kullanılmalıdır. 
Argümanlar ya kalıtım listesinde ya da türetilmiş constructor'da değiştirici-tarzda verilmelidir. 
Argümanları her iki yerde de belirtmek bir hatadır.

Türetilmiş bir akıllı sözleşme, temel akıllı sözleşmelerin tüm constructorları için argümanları belirtmiyorsa, 
özet olarak bildirilmelidir. Bu durumda, ondan başka bir akıllı sözleşme türetildiğinde, diğer 
akıllı sözleşmenin miras listesi veya constructor'ı, parametreleri belirtilmemiş tüm temel sınıflar 
için gerekli parametreleri sağlamalıdır (aksi takdirde, diğer akıllı sözleşme da soyut olarak bildirilmelidir). 
Örneğin, yukarıdaki kod parçacığında, bkz. ``Derived3`` ve ``DerivedFromDerived``.

.. index:: ! inheritance;multiple, ! linearization, ! C3 linearization

.. _multi-inheritance:

Çoklu Kalıtım ve Doğrusallaştırma
======================================

Çoklu kalıtıma izin veren diller birkaç problemle uğraşmak zorundadır. 
Bunlardan bir tanesi `Elmas Problemi'dir <https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem>`_.
Solidity Python'a benzer olarak "`C3 Linearization <https://en.wikipedia.org/wiki/C3_linearization>`_"
kullanarak directed acyclic graph'da (DAG) spesifik bir sırayı zorlar. Bu, istenen monotonluk özelliği 
ile sonuçlanır, ancak bazı kalıtım grafiklerine izin vermez. Özellikle ``is`` yönergesinde temel 
sınıfların veriliş sırası önemlidir: Doğrudan temel sözleşmeleri “en temele benzeyen”den 
“en çok türetilene” doğru sıralamalısınız. Bu sıralamanın Python'da kullanılanın tersi olduğuna dikkat edin.

Bunu açıklamanın bir başka basitleştirici yolu, farklı akıllı sözleşmelerde birden çok kez tanımlanan
bir fonksiyon çağrıldığında, verilen tabanların sağdan sola (Python'da soldan sağa) derinlemesine 
ilk olarak aranması ve ilk eşleşmede durdurulmasıdır. . Bir temel akıllı sözleşme zaten aranmışsa, atlanır.

Aşağıdaki kodda Solidity "Linearization of inheritance graph impossible" hatası verecektir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract X {}
    contract A is X {}
    // Bu derlenemez
    contract C is A, X {}

Bunun sebebi ``C`` akıllı sözleşmesinin ``X`` akıllı sözleşmesinin ``A`` akıllı sözleşmesini
override etmesini istemesidir (``A, X`` sırası ile bunu belirtiyor),
ancak ``A`` akıllı sözleşmesinin kendisi ``X`` akıllı sözleşmesini override etmeyi talep
eder ki bu çözülemeyecek bir çelişkidir.

Benzersiz bir override olmadan birden çok tabandan devralınan bir 
fonksiyonu açıkça override etmek gerektiğinden, pratikte C3 doğrusallaştırması çok önemli değildir.

Kalıtım doğrusallaştırmasının özellikle önemli olduğu ve belki de o kadar net olmadığı bir alan, 
miras hiyerarşisinde birden çok constructor olduğu zamandır. Constructor'lar, argümanlarının devralınan 
akıllı sözleşmenin constructor'ında sağlandığı sıraya bakılmaksızın her zaman doğrusallaştırılmış sırada 
yürütülür. Örneğin:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract Base1 {
        constructor() {}
    }

    contract Base2 {
        constructor() {}
    }

    // Constructor'lar aşağıdaki sıra ile çalışır:
    //  1 - Base1
    //  2 - Base2
    //  3 - Derived1
    contract Derived1 is Base1, Base2 {
        constructor() Base1() Base2() {}
    }

    // Constructor'lar aşağıdaki sıra ile çalışır:
    //  1 - Base2
    //  2 - Base1
    //  3 - Derived2
    contract Derived2 is Base2, Base1 {
        constructor() Base2() Base1() {}
    }

    // Constructors are still executed in the following order:
    //  1 - Base2
    //  2 - Base1
    //  3 - Derived3
    contract Derived3 is Base2, Base1 {
        constructor() Base1() Base2() {}
    }


Farklı Türden Aynı İsme Sahip Üyeleri Türetme
======================================================

Bir akıllı sözleşmede aşağıdaki çiftlerden herhangi birinin miras nedeniyle aynı ada sahip olması bir hatadır:
  - bir fonksiyon ve bir modifier
  - bir fonksiyon ve bir event
  - bir event ve bir modifier

İstisna olarak, bir durum değişkeninin getirici fonksiyonu bir external fonksiyonu override edebilir.
