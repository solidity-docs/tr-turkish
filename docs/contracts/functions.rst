.. index:: ! functions

.. _functions:

*************
Fonksiyonlar
*************

Fonksiyonlar akıllı sözleşmelerin içerisinde veya dışarısında tanımlanabilir.

Akıllı sözleşmelerin dışarısında tanımlanan fonksiyonlara "özgür fonksiyonlar" denir ve her zaman
``internal`` :ref:`görünürlüktedirler<visibility-and-getters>`. Kodları, o fonksiyonları
kullanan her bir akıllı sözleşmeye eklenir, tıpkı internal kütüphane fonksiyonları gibi.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    function sum(uint[] memory arr) pure returns (uint s) {
        for (uint i = 0; i < arr.length; i++)
            s += arr[i];
    }

    contract ArrayExample {
        bool found;
        function f(uint[] memory arr) public {
            // Burada özgür bir fonksiyon internal olarak çağrılıyor.
            // Derleyici `sum` fonksiyonunu bu akıllı sözleşmenin kodları arasına ekleyecek.
            uint s = sum(arr);
            require(s >= 10);
            found = true;
        }
    }

.. note::
    Akıllı sözleşme dışında tanımlanan bir fonksiyon her zaman o akıllı sözleşmenin içeriği ile birlikte
    çalıştırılırlar. Hâlâ diğer akıllı sözleşmeleri çağırabilir, onlara Ether gönderebilir ve kendilerini
    çağıran akıllı sözleşmeleri yok edebilirler. Akıllı sözleşme içerisinde tanımlanan bir fonksiyon ile özgür bir fonksiyonun arasındaki en temel farklar özgür fonksiyonların ``this`` değişkenine erişimi olmaması, ve de kendi alanlarında (scope) bulunmayan storage değişkenlerine ve fonksiyonlara direkt erişime sahip olmamalarıdır.

.. _function-parameters-return-variables:

Fonksiyon Parametreleri ve Return Parametreleri
================================================

Fonksiyonlar tipi belirtilmiş parametreler alabilir ve diğer birçok programlama
dilinin aksine keyfi sayıda değişkeni return edebilirler.

Fonksiyon Parametreleri
------------------------

Fonksiyon parametreleri değişkenlerle aynı şekilde tanımlanırlar.
Ayrıca kullanılmayan parametreler gözardı edilebilirler.

Örneğin, eğer akıllı sözleşmenizdeki bir fonksiyonun iki adet integer değişkeni
parametre olarak almasını isterseniz, aşağıdaki gibi bir yapı kullanabilirsiniz:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        uint sum;
        function taker(uint a, uint b) public {
            sum = a + b;
        }
    }

Fonksiyon parametreleri herhangi bir lokal değişken olarak kullanılaiblir ve ayrıca lokal
değişkenlere atanabilirler.

.. note::

  Bir :ref:`external fonksiyon<external-function-calls>` çok boyutlu bir
  diziyi parametre olarak alamazlar. Bu özelliği eğer ABI coder v2'yi
  kaynak kodunuzda ``pragma abicoder v2;`` bu şekilde aktifleştirdiyseniz
  kullanabilirsiniz.

  Bir :ref:`internal fonksiyon<external-function-calls>` o özelliği aktifleştirmeden
  de çok boyutlu bir diziyi parametre olarak alabilir.

.. index:: return array, return string, array, string, array of strings, dynamic array, variably sized array, return struct, struct

Return Değişkenleri
--------------------

Fonksiyon return değişkenleri aynı şekilde ``returns`` sözcüğünden sonra tanımlanır.

Örneğin, iki adet sonucu return etmek istediğinizi düşünün: fonksiyon parametresi olarak
verilmiş iki adet integer'ın toplamı ve çarpımı. Şu şekilde bir kod işinizi görecektir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        function arithmetic(uint a, uint b)
            public
            pure
            returns (uint sum, uint product)
        {
            sum = a + b;
            product = a * b;
        }
    }

Return değişkenlerinin tipleri gözardı edilebilirler. Return değişkenleri
herhangi bir lokal değişken olarak kullanılabilirler. Bu değişkenler direkt
olarak :ref:`default değerine <default-value>` eşitlenir ve değiştirilene
kadar bu değere eşit olurlar.

İsterseniz yukarıdaki gibi açık bir şekilde return değişkenlerinin değerlerini
verebilir veya aşağıdaki gibi direkt olarak ``return`` ifadesini kullanabilirsiniz
(ister tek, isterseniz de :ref:`çoklu return<multi-return>`):

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Simple {
        function arithmetic(uint a, uint b)
            public
            pure
            returns (uint sum, uint product)
        {
            return (a + b, a * b);
        }
    }

Eğer fonksiyondan çıkmak için erkenden ``return`` kullanmanak istiyorsanız,
bütün return değişkenlerini vermeniz gerekir.

.. note::
    Bazı tipleri internal olmayan fonksiyonlardan return edemezsiniz,
    örneğin, çok boyutlu dinamik boyutlu diziler ve structlar. Eğer
    ABI coder v2'yi ``pragma abicoder v2;`` şeklinde kodunuza eklerseniz
    daha fazla tip kullanılabilir olacaktır, ancak ``mapping`` tipi
    hâlâ bir akıllı sözleşme içerisinde sınırlıdır ve onları transfer edemezsiniz.

.. _multi-return:

Çoklu Değer Return Etme
-------------------------

Bir fonksiyonda birden fazla değişkeni return etmek istiyorsanız ``return (v0, v1, ..., vn)`` şeklinde
bir ifade kullanabilirsiniz. Return değişkeni sayısı ve tipleri, bir
:ref:`implicit dönüşümden <types-conversion-elementary-types>` sonra belirtilen değerlerle eşleşmelidir.

.. _state-mutability:

State Değişkenliği
===================

.. index:: ! view function, function;view

.. _view-functions:

View Fonksiyonlar
------------------

``view`` ile tanımlanan fonksiyonlar state'te herhangi bir değişikliği yapamaz, sadece
state'deki değerleri okuyabilirler.

.. note::
  Eğer derleyicinin EVM target kısmı Byzantium veya daha yenisi (default) ise ``view``
  fonksiyonlar çağrıldığında ``STATICCALL`` opcode'u kullanılır ve bu opcode state'i
  değişmemeye zorlar. Kütüphanelerdeki ``view`` fonksiyonlarında ise ``DELEGATECALL``
  kullanılır. Çünkü ``DELEGATECALL`` ve ``STATICCALL`` opcode'larından kombine edilmiş
  bir opcode bulunmamaktadır. Bu demek oluyor ki ``view`` fonksiyonlar state değişikliğini
  önlemek için run-time kontrollerine sahip değildirler. Bunun kötü bir güvenlik etkisi
  olmamalıdır. Çünkü kütüphane kodu genellikle derlenirken bilinir ve statik kontrol edici
  (static checker) compile-time kontrollerini gerçekleştirir.

Aşağıdaki ifadeler state değişikliğini temsil eder:

#. State değişkenlerine yazmak.
#. :ref:`Event yayınlama <events>`.
#. :ref:`Başka akıllı sözleşmeler oluşturma <creating-contracts>`.
#. ``selfdestruct`` kullanmak.
#. Ether göndermek.
#. ``view`` veya ``pure`` olarak belirtilmeyen bir fonksiyon çağırmak.
#. Low-level çağrılar kullanmak.
#. Belirli opcode'ları kullanan inline assembly kullanmak.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        function f(uint a, uint b) public view returns (uint) {
            return a * (b + 42) + block.timestamp;
        }
    }

.. note::
  Versiyon 0.5.0 öncesinde fonksiyonlarda ``constant`` sözcüğü şu anki ``view`` için kullanılırdı, ancak artık kullanılmıyor.

.. note::
  Getter fonksiyonlar otomatik olarak ``view`` görünürlüğüne sahip olur.

.. note::
  Versiyon 0.5.0 öncesinde derleyici ``view`` için ``STATICCALL`` opcode'unu
  kullanmazdı. Bu, ``view`` fonksiyonlarda yanlış explicit tip dönüşümlerini
  kullanarak state değişikliği yapılmasına izin verdi. ``STATICCALL`` opcode'unu
  ``view`` fonksiyonlar için kullanarak EVM seviyesinde state değişikliklerinin
  yapılmasının önüne geçildi.
  
.. index:: ! pure function, function;pure

.. _pure-functions:

Pure Fonksiyonlar
------------------

Fonksiyonlar ``pure`` olarak tanımlanabilir ve bu şekilde tanımlanan fonksiyonlar state'i okuyamaz ve
değişiklik yapamaz. Pure fonksiyonlar içerisinde ``immutable`` değişkenler okuyabilir durumdadır.

.. note::
  Eğer derleyicinin EVM target kısmı Byzantium veya daha yeni (default) ise, ``STATICCALL``
  opcode'u kullanılır. Bu opcode state'in okunmadığına dair garanti vermez ama en azından
  değiştirilmediğine dair bir garanti verir.
    
Yukarıda state'i değiştiren ifadeleri açıklamışken, state'i okuduğu düşünülen ifadeleri de aşağıda bulabilirsiniz:

#. State değişkenlerini okumak.
#. ``address(this).balance`` veya ``<address>.balance`` değişkenlerine erişmek.
#. ``block``, ``tx`` veya ``msg`` değişkenlerinin herhangi bir üyesine erişmek (``msg.sig`` ve ``msg.data`` istisnadır).
#. ``pure`` olmayan herhangi bir fonksiyonu çağırmak.
#.  Belirli opcode'ları kullanan inline assembly kullanmak.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        function f(uint a, uint b) public pure returns (uint) {
            return a * (b + 42);
        }
    }

Pure fonksiyonlar ``revert()`` ve ``require()`` ifadelerini kullanarak :ref:`hata oluşması <assert-and-require>`
durumunda potansiyel state değişikliğini engelleyebilirler.

State değişikliğini revert etmek bir "state değişikliği" olarak düşünülmez. 

Bir state değişikliğini revert etmek bir "state değişikliği" olarak kabul edilmez, çünkü yalnızca 
daha önce kodda ``view`` veya ``pure`` kısıtlamaya sahip olmayan state'de yapılan değişiklikler
revert edilir ve bu kodun ``revert``'i yakalama ve aktarmama seçeneği vardır.

Bu davranış ``STATICCALL`` için de geçerlidir.

.. warning::
  EVM seviyesinde fonksiyonların state'den okuma yapmasını engellemek mümkün değildir,
  sadece yazma engellenebilir (yani, EVM seviyesinde sadece ``view`` zorunlu kılınabilir, ``pure`` kılınamaz).

.. note::
  Versiyon 0.5.0 öncesinde derleyici ``pure`` için ``STATICCALL`` opcode'unu
  kullanmazdı. Bu, ``pure`` fonksiyonlarda yanlış explicit tip dönüşümlerini
  kullanarak state değişikliği yapılmasına izin verdi. ``STATICCALL`` opcode'unu
  ``pure`` fonksiyonlar için kullanarak EVM seviyesinde state değişikliklerinin
  yapılmasının önüne geçildi.

.. note::
  Versiyon 0.4.17 öncesinde derleyici ``pure`` fonksiyonların state'i okuması durumunda
  hata vermezdi. Bu, sözleşme türleri arasında geçersiz açık dönüşümler yaparak atlatılabilen ve bir 
  tür denetim olan derleme zamanı yüzünden kaynaklanmaktaydı. Çünkü derleyici, sözleşme 
  türünün durum değiştirme işlemleri yapmadığını doğrulayabilir, fakat çalışma zamanında
  çağrılacak olan sözleşmenin gerçekten bu türden olup olmadığını kontrol edemez.

.. _special-functions:

Özel Fonksiyonlar
=================

.. index:: ! receive ether function, function;receive ! receive

.. _receive-ether-function:

Receive Ether Fonksiyonu
-------------------------

Bİr akıllı sözleşme sadece bir adet ``receive`` fonksiyonuna sahip olabilir. Bu fonksiyon
şu şekilde tanımlanır: ``receive() external payable { ... }`` (function sözcüğü olmadan).
Bu fonksiyon parametre alamaz, hiçbir şey return edemez, görünürlüğü ``external``
olmalı ve ayrıca ``payable`` olarak tanımlanmalıdır. Bir receive fonksiyonu virtual olabilir, override edilebilir
ve modifier'lara sahip olabilir.

Receive fonksiyonu akıllı sözleşmemize gelen boş bir calldata'sı bulunan çağrılarda çalıştırılır.
Bu fonksiyon, akıllı sözleşmemize direkt Ether transferi gerçekleştirildiğinde (``.send()`` veya ``.transfer()``
kullanılarak) çalıştırılır. Eğer bu fonksiyon tanımlı değil ama payable bir :ref:`fallback fonksiyon <fallback-function>`
tanımlı ise, direkt Ether transferlerinde bu fallback fonksiyonu çalıştırılır. Eğer akıllı sözleşme ne bir receive
fonksiyonu, ne de bir payable fallback fonksiyonu tanımlamamışsa, akıllı sözleşmemiz direkt Ether transflerlerini
kabul edemez, kendisine ether gönderildiğinde bir hata verir.

En kötü durumda ``receive`` fonksiyonu 2300 adet gazın mevcut olduğunu varsayabilir 
(örneğin ``send`` veya ``transfer`` kullanımında), geriye ise sadece log işlemleri gibi basit işlemler için gaz kalır.
Aşağıdaki işlemler 2300 gazdan daha fazlasını harcar:

- Storage'e yazmak
- Akıllı sözleşme oluşturmak
- Yüksek miktarda gaz harcayan bir external fonksiyonun çağrılması
- Ether gönderimi

.. warning::
    Bir akıllı sözleşmede direkt olarak Ether gönderirken (bir fonksiyon çağrısı olmadan, yani gönderenin
    ``send`` veya ``transfer`` kullandığı durumda) eğer akıllı sözleşme bir receive fonksiyonu veya
    bir payable fallback fonksiyonu tanımlamamışsa, bir hata oluşur ve Etherler gönderene iade edilir
    (bu durum Solidity 0.4.0 öncesinde farklıydı). Eğer akıllı sözleşmenizin direkt Ether transferlerini kabul
    etmesini istiyorsanız, bir receive fonksiyonu tanımlayın (Ether kabulu için payable fallback fonksiyonunun
    kullanımını tavsiye etmiyoruz, çünkü fallback fonksiyonu interface karışıklığı yaşandığında kullanıcıya
    hata vermeyecektir).
  
.. warning::
    Bir akıllı sözleşme receive fonksiyonu olmadan da Ether kabul edebilir; 
    *coinbase transaction* (diğer adıyla *miner block reward*)
    veya ``selfdestruct`` kullanılırken hedef adres olarak verilmesi halinde
    akıllı sözleşme Etherleri kabul etmek zorundadır.

    Bir akıllı sözleşme bu gibi durumlardaki Ether transferlerine herhangi bir tepki
    veremez ve dolayısıyla bunları reddedemez. Bu EVM'in tasarım tercihlerinden
    biridir ve Solidity bunu es geçemez.

    Bu ayrıca demek oluyor ki ``address(this).balance`` değişkenindeki değer
    sizin kendi hesaplamanızla (örneğin, receive fonksiyonunda her gelen miktarı
    hesaplamanız halinde) farklı olabilir.

Aşağıdaki Sink akıllı sözleşmesi ``receive`` kullanımına bir örnektir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // Bu akıllı sözleşmeye gönderilen Etherleri geri almanın hiçbir
    // yolu yoktur.
    contract Sink {
        event Received(address, uint);
        receive() external payable {
            emit Received(msg.sender, msg.value);
        }
    }

.. index:: ! fallback function, function;fallback

.. _fallback-function:

Fallback Fonksiyonu
---------------------

Bir akıllı sözleşme sadece bir adet ``fallback`` fonksiyonuna sahip olabilir. Bu fonksiyon
şu iki şekilde tanımlanabilir: ``fallback () external [payable]`` veya 
``fallback (bytes calldata input) external [payable] returns (bytes memory output)``
(ikisi de ``function`` sözcüğü olmadan kullanılıyor). Bu fonksiyon ``external``
görünürlüğe sahip olmalıdır. Bir fallback fonksiyonu virtual olabilir, override edilebilir
ve modifier'lara sahip olabilir.

Fallback fonksiyonu bir çağrıda gönderilen fonksiyon imzasının (function signature) akıllı sözleşmedeki
herhangi bir fonksiyon ile eşleşmediği durumda çalıştırılır, yani, eğer kullanıcının çalıştırmak
istediği fonksiyon akıllı sözleşmede yoksa, fallback fonksiyonu çalıştırılır. Bir diğer kullanım alanı ise
direkt Ether gönderimlerinde eğer akıllı sözleşmede :ref:`receive Ether fonksiyonu <receive-ether-function>`
yoksa ve fallback fonksiyonumuz ``payable`` ise, fallback fonksiyonu çalıştırılır.

Eğer yukarıda gösterdiğimiz iki kullanım şeklinden ``input`` kullanılanı kullanmak isterseniz,
``input`` akıllı sözleşmeye gönderilen tüm data, ``msg.data``, olacaktır. Ayrıca ``output`` ile de
data return edebilir. Return edilen data ABI-encoded olmayacaktır, onun yerine herhangi bir
düzenleme olmadan (hatta padding bile olmadan) return edilecektir.

En kötü durumda, eğer bir payable fallback fonksiyonu receive fonksiyonun da yerine kullanıldıysa,
sadece 2300 adet gaz ile işlemini tamamlayabilir (:ref:`receive Ether fonksiyonu <receive-ether-function>`).

Diğer herhangi bir fonksiyon gibi fallback fonksiyonu da yeterli gaza sahip olduğu sürece
çok karmaşık işlemleri yürütebilir.

.. warning::
    Bir ``payable`` fallback fonksiyonu ayrıca direkt Ether transferlerinde
    de, eğer :ref:`receive Ether fonksiyonu <receive-ether-function>` kullanılmadıysa,
    çalıştırılabilir. Eğer payable fallback fonksiyonuna spesifik bir kullanım için
    ihtiyacınız yoksa, receive fonksiyonunu kullanmanızı tavsiye ederiz.

.. note::
    Eğer input verisini decode etmek istiyorsanız, ilk dört byte'ı fonksiyon
    imzası için kullanabilir ve kalan kısmı ``abi.decode`` kullanarak ABI-encoded
    veriyi decode edebilirsiniz: ``(c, d) = abi.decode(input[4:], (uint256, uint256));``
    Şunu unutmayın ki, bu bir son çaredir. Eğer yapabiliyorsanız daha uygun bir fonksiyon
    kullanmaya çalışın.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract Test {
        uint x;
        // Bu akıllı sözleşmeye gelen bütün mesaj çağrılarını
        // bu fonksiyon karşılar (akıllı sözleşmede başka bir
        // fonksiyon bulunmadığı için).
        // Fonksiyon payable olarak belirtilmediği için 
        // Ether gönderimlerinde hata alınacaktır.
        fallback() external { x = 1; }
    }

    contract TestPayable {
        uint x;
        uint y;
        // Bu akıllı sözleşmeye gelen direkt Ether gönderimleri dışındaki bütün mesajları
        // bu fonksiyon karşılayacaktır (receive dışında başka bir fonksiyon
        // bulunmamakta). Calldatası boş olmayan bütün çağrıları bu fonksiyon
        // karşılar (çağrı ile birlikte Ether gönderilse bile).
        fallback() external payable { x = 1; y = msg.value; }

        // Bu fonksiyon sadece direkt Ether gönderimleri için kullanılır, yani,
        // boş bir calldata ve Ether gönderilen çağrıları bu fonksiyon karşılar.
        receive() external payable { x = 2; y = msg.value; }
    }

    contract Caller {
        function callTest(Test test) public returns (bool) {
            (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // test.x'in == 1 olmasına neden olur.

            // address(test) direkt olarak ``send`` kullanımına izin vermez.
            // ``send`` fonksiyonunu çağırabilmek için bile ``address payable``
            // tipine dönüştürme gerekmektedir.
            address payable testPayable = payable(address(test));

            // Eğer biri burada da olduğu gibi payable fallback fonksiyonu olmayan bir
            // akıllı sözleşmeye ether göndermeye çalışırsa, hata alacaktır.
            // Dolayısıyla burada ``false`` return edilir.
            return testPayable.send(2 ether);
        }

        function callTestPayable(TestPayable test) public returns (bool) {
            (bool success,) = address(test).call(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // test.x == 1 olur ve test.y 0 olur.
            (success,) = address(test).call{value: 1}(abi.encodeWithSignature("nonExistingFunction()"));
            require(success);
            // test.x == 1 olur ve test.y 1 olur.

            // Eğer biri aşağıdaki gibi TestPayable akıllı sözleşmesine Ether gönderirse, receive fonksiyonu çalışır.
            // Yukarıda tanımladığımız receive fonksiyonu storage'e yazdığı için 2300'den daha fazla
            // gaz harcanmasına sebep olur. O yüzden ``send`` ve ``transfer`` kullanılamaz.
            // Onların yerine low-level call kullanmalıyız.
            (success,) = address(test).call{value: 2 ether}("");
            require(success);
            // test.x'in == 2 ve test.y'nin 2 Ether olmasıyla sonuçlanır.

            return true;
        }
    }

.. index:: ! overload

.. _overload-function:

Fonksiyon Overloading
=======================

Bir akıllı sözleşme aynı isimde fakat farklı parametre tiplerine sahip fonksiyonlara sahip olabilir.
Bu işlem "overloading" olarak adlandırılır ve ayrıca türetilen fonksiyonlar için de geçerlidir.
Aşağıdaki örnek ``A`` akıllı sözleşmesindeki ``f`` fonksiyonları ile overloading'i gösterir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract A {
        function f(uint value) public pure returns (uint out) {
            out = value;
        }

        function f(uint value, bool really) public pure returns (uint out) {
            if (really)
                out = value;
        }
    }

Overload edilmiş fonksiyonlar external interface'de de göründüğü için iki fonksiyonun
aldığı parametreler external tiplerine göre karşılaştırılır. Yani, örneğin aşağıdaki
fonksiyonlardan biri parametre olarak akıllı sözleşme aldığını belirtmiş. Ancak external
interface'de bu, bir akıllı sözleşme değil, adres olarak görünür. O yüzden bu akıllı sözleşme 
compile edilemez.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    // Compile edilemez
    contract A {
        function f(B value) public pure returns (B out) {
            out = value;
        }

        function f(address value) public pure returns (address out) {
            out = value;
        }
    }

    contract B {
    }

Yukarıdaki iki ``f`` fonksiyonu da ABI'leri aracılığı ile address tipinden bir parametre
kabul ediyor, her ne kadar Solidity içerisinde farklı tipler kabul etseler de.

Overload Ayrıştırma ve Parametre Eşleştirme
--------------------------------------------

Overload edilmiş fonksiyonlar, geçerli kapsamdaki fonksiyon tanımlamalarını fonksiyon çağrısında
sağlanan parametrelerle eşleştirerek seçilir. Tüm parametreler implicit olarak beklenen türlere
dönüştürülebiliyorsa, fonksiyon overload adayı olarak seçilir. Tam olarak bir aday yoksa,
çözümleme başarısız olur.

.. note::
    Overload ayrıştırma için return parametreleri dikkate alınmaz.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract A {
        function f(uint8 val) public pure returns (uint8 out) {
            out = val;
        }

        function f(uint256 val) public pure returns (uint256 out) {
            out = val;
        }
    }

``f(50)`` çağrısını yaptığımızda bir hata alırız. Bunun sebebi ``50`` sayısının hem ``uint8``
hem de ``uint256`` tipinde de kullanılabilmesidir. Ama eğer ``f(256)`` çağrısını gerçekleştirirsek
``256`` sayısı direkt olarak ``f(uint256)`` bu şekilde tanımlanan fonksiyona gönderilir. Çünkü 
``256`` ``uint8`` olarak gösterilemez.
