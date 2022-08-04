##################################
İfadeler ve Kontrol Yapıları
##################################

.. index:: ! parameter, parameter;input, parameter;output, function parameter, parameter;function, return variable, variable;return, return


.. index:: if, else, while, do/while, for, break, continue, return, switch, goto

Kontrol Yapıları
===================

Süslü parantez dillerinden(C, C++, Java, ya da C# gibi) bilinen kontrol yapılarının çoğu Solidity'de mevcuttur:

C veya JavaScript'te kullanılan standart semantik ile ``if``, ``else``, ``while``, ``do``, ``for``, ``break``, ``continue``, ``return`` yapıları vardır. 

Solidity ayrıca ``try``/``catch``-ifadeleri biçiminde hata yakalamayı da destekler,
ancak yalnızca :ref:`harici fonksiyon çağrıları <external-function-calls>` ve 
sözleşme oluşturma çağrıları için geçerlidir. Hatalar :ref:`revert ifadesi <revert-statement>` kullanılarak oluştutulabilir.

Parantezler koşul ifadelerinde gözardı *edilemez*, ancak tek-durumlu gövdelerin etrafında küme parantezleri 
gözardı edilebilir.

C ve JavaScript'te olduğu gibi bool olmayan türlerden bool türlerine tür dönüşümü olmadığını unutmayın,
yani ``if (1) { ... }`` ifadesi Solidity için geçerli *değildir*.

.. index:: ! function;call, function;internal, function;external

.. _function-calls:

Fonksiyon Çağrıları
==============

.. _internal-function-calls:

Dahili Fonksiyon Çağrıları
-----------------------

Mevcut sözleşmenin fonksiyonları, bu örnekte görüldüğü gibi, doğrudan ("dahili") olarak,
aynı zamanda yinelemeli olarak çağrılabilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    // Bu bir uyarı bildirir
    contract C {
        function g(uint a) public pure returns (uint ret) { return a + f(); }
        function f() internal pure returns (uint ret) { return g(7) + f(); }
    }

Bu fonksiyon çağrıları ESM (Ethereum Sanal Makinası) içinde basit geçişlere dönüştürülür. Bu,
mevcut belleğin silinmemesini sağlar, yani dahili olarak çağrılan fonksiyonlara bellek 
referanslarını iletmek çok verimlidir. Yalnızca aynı sözleşme örneğinin fonksiyonları dahili olarak çağrılabilir.

Yine de aşırı özyinelemeden kaçınmalısınız, çünkü her dahili fonksiyon çağrısı
en az bir yığın yuvası kullanır ve yalnızca 1024 yuva mevcuttur.

.. _external-function-calls:

Harici Fonksiyon Çağrıları
-----------------------

Fonksiyonlar ayrıca ``this.g(8);`` ve ``c.g(2);`` notasyonu kullanılarak da çağrılabilir, 
burada ``c`` bir sözleşme örneğidir ve ``g``, ``c`` ye ait bir fonksiyondur.
``g`` fonksiyonunu her iki şekilde çağırmak, yani doğrudan atlamalar yoluyla değil, bir mesaj 
kullanılarak çağrılması "harici" çağrı olarak adlandırılır.
Lütfen ``this`` üzerindeki fonksiyon çağrılarının constructorda kullanılamayacağını unutmayın,
çünkü asıl sözleşme henüz oluşturulmamıştır.

Diğer sözleşmelerin fonksiyonları harici olarak çağrılmalıdır. Harici bir çağrı için,
tüm fonksiyon argümanlarının belleğe kopyalanması gerekir.

.. not::
    Bir sözleşmeden diğerine yapılan fonksiyon çağrısı kendi işlemini oluşturmaz,
    Bu çağrı, genel işlemin parçası olan bir mesaj çağrısıdır.

Diğer sözleşmelerin fonksiyonlarını çağırırken, çağrı ile gönderilen Wei veya gaz miktarını, ``{value: 10, gas: 10000}`` 
şeklinde, belirleyebilirsiniz. İşlem kodlarının(opcodes) gaz maliyetleri gelecekte değişebileceğinden, gaz değerlerini 
açıkça belirtmenin önerilmediğini unutmayın. Sözleşmeye gönderdiğiniz herhangi bir Wei, o sözleşmenin toplam bakiyesine eklenir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    contract InfoFeed {
        function info() public payable returns (uint ret) { return 42; }
    }

    contract Consumer {
        InfoFeed feed;
        function setFeed(InfoFeed addr) public { feed = addr; }
        function callFeed() public { feed.info{value: 10, gas: 800}(); }
    }

``info`` fonksiyonu ile ``payable`` modifier'ını kullanmanız gerekir, çünkü
aksi takdirde, ``value`` seçeneği kullanılamaz.

.. uyarı::
  ``feed.info{value: 10, gas: 800}`` ifadesinin sadece yerel olarak fonksiyon çağrısı ile gönderilen
  ``value`` ve ``gas`` miktarını ayarladığına, ve sondaki parantezlerin asıl çağrıyı yaptığına dikkat edin. 
  Yani ``feed.info{value: 10, gas: 800}`` ifadesi fonksiyonu çağırmaz, ``value`` ve ``gas`` ayarları kaybolur, yalnızca
  ``feed.info{value: 10, gas: 800}()`` fonksiyon çağrısını gerçekleştirir.

ESM'nin var olmayan bir sözleşmeye yapılan bir çağrıyı her zaman başarılı olarak 
kabul etmesi nedeniyle, Solidity çağrılacak olan sözleşmenin gerçekten var olup 
olmadığını (kod içermesini) kontrol etmek için ``extcodesize`` işlem kodunu kullanır,
eğer sözleşme yoksa hata verir.  Çağrıdan sonra dönüş verilerinin kodu çözülecekse
bu aşama atlanır ve böylece ABI kod çözücüsü mevcut olmayan bir sözleşme durumunu yakalar.

Bu kontrolün, sözleşme örnekleri yerine adresler üzerinde çalışan :ref:`düşük seviyeli çağrılar <address_related>` 
olması durumunda gerçekleştirilmediğini unutmayın.

.. not::
    :ref:`önceden derlenmiş sözleşmeler <precompiledContracts>`de,
    üst düzey çağrılar kullanırken dikkatli olun, çünkü derleyici, 
    kodu çalıştırsalar ve veri döndürebilseler bile bunları mevcut saymaz.

Fonksiyon çağrıları, çağrılan sözleşmenin kendisi bir hata döndürürse veya gazı tükenirse,
hatalara da neden olur.

.. uyarı::
    Başka bir sözleşme ile herhangi bir etkileşim, özellikle sözleşmenin kaynak 
    kodu önceden bilinmiyorsa, potansiyel bir tehlike oluşturur. Mevcut sözleşme, 
    kontrolü, çağrılan sözleşmeye devreder ve bu, potansiyel olarak hemen hemen 
    her şeyi yapabilir. Çağrılan sözleşme bilinen bir ana sözleşmeden miras kalsa bile,
    miras sözleşmesinin yalnızca doğru bir arayüze sahip olması gerekir. Ancak sözleşmenin
    uygulanması tamamen keyfi olabilir ve bu nedenle tehlike oluşturabilir. Ayrıca, ilk çağrı 
    sisteminizin diğer sözleşmelerine çağrı yapması veya hatta çağrı yapan sözleşmeye geri
    dönmesi ihtimaline karşı hazırlıklı olun. Bu, çağrılan sözleşmenin,fonksiyonları 
    aracılığıyla çağrı yapan sözleşmesinin durum değişkenlerini değiştirebileceği anlamına gelir. 
    Fonksiyonlarınızı, örneğin sözleşmenizdeki durum değişkenlerinde yapılan herhangi bir 
    değişiklikten sonra harici fonksiyonlara yapılan çağrıların gerçekleşeceği şekilde yazın, 
    böylece sözleşmeniz yeniden giriş istismarına karşı savunmasız kalmaz.


.. not::
    Solidity 0.6.2'den önce, değeri ve gazı belirtmenin önerilen yolu
    ``f.value(x).gas(g)()`` kullanmaktı. Bu, Solidity 0.6.2'de kullanımdan 
    kaldırıldı ve Solidity 0.7.0'dan beri kullanımı artık mümkün değil.

Adlandırılmış Çağrılar ve Anonim Fonksiyon Parametreleri
---------------------------------------------

Aşağıdaki örnekte görüldüğü gibi, ``{ }`` içine alınmışlarsa, fonksiyon 
çağrısı argümanları herhangi bir sırayla ve tercihe bağlı isimle adlandırılabilir. 
Argüman listesi, fonksiyon bildirimindeki parametre listesiyle ve adıyla 
örtüşmelidir, ancak isteğe bağlı olarak sıralanabilir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract C {
        mapping(uint => uint) data;

        function f() public {
            set({value: 2, key: 3});
        }

        function set(uint key, uint value) public {
            data[key] = value;
        }

    }

Dikkate Alınmayan Fonksiyon Parametre Adları
--------------------------------

Kullanılmayan parametrelerin adları (özellikle dönüş parametreleri) atlanabilir.
Bu parametreler yığında bulunmaya devam eder, fakat erişilemezler.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        // parametre için atlanan ad
        function func(uint k, uint) public pure returns(uint) {
            return k;
        }
    }


.. index:: ! new, contracts;creating

.. _creating-contracts:

``new`` Yoluyla Sözleşmeler Oluşturma
==============================

Bir sözleşme, ``new`` anahtar sözcüğünü kullanarak başka sözleşmeler oluşturabilir.
Oluşturulan sözleşmenin tam kodu, oluşturulan sözleşme derlendiğinde bilinmelidir,
bu nedenle özyinelemeli oluşturma bağımlılıkları imkansızdır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract D {
        uint public x;
        constructor(uint a) payable {
            x = a;
        }
    }

    contract C {
        D d = new D(4); // C'nin constructor'ının bir parçası olarak yürütülecek

        function createD(uint arg) public {
            D newD = new D(arg);
            newD.x();
        }

        function createAndEndowD(uint arg, uint amount) public payable {
            // Oluşturulmasıyla beraber ether gönder
            D newD = new D{value: amount}(arg);
            newD.x();
        }
    }

Örnekte görüldüğü gibi, ``value`` seçeneği kullanılarak bir ``D`` örneği oluştururken 
Ether göndermek mümkündür, ancak gaz miktarını sınırlamak mümkün değildir.
Oluşturma başarısız olursa (yığın olmaması, yeterli bakiye olmaması veya diğer problemler nedeniyle),
bir hata döndürülür.

Saltlı sözleşme kreasyonları / create2
-----------------------------------

Bir sözleşme oluştururken, sözleşmenin adresi, oluşturulan sözleşmenin adresinden ve her sözleşmede artan 
bir sayaçtan hesaplanır.

``salt`` (bir bytes32 değeri) seçeneğini belirlerseniz, sözleşme kreasyonu yeni sözleşmenin adresini bulmak
için farklı bir mekanizma kullanır:

Oluşturan sözleşmenin adresinden adresi, verilen salt değeri, oluşturulan sözleşmenin (kreasyon) bayt kodu
ve constructor argümanlarını hesaplayacaktır. 

Özellikle sayaç ("nonce") kullanılmaz. Bu, sözleşmeler oluştururken daha fazla esneklik sağlar:
Sözleşme oluşturulmadan önce yeni sözleşmenin adresini öğrenebilirsiniz.
Üstelik, bu adrese güvenebilirsiniz ayrıca sözleşmelerin oluşturulması durumunda
başka sözleşmeler oluşturur.

Buradaki ana kullanım durumu, sadece bir anlaşmazlık varsa yaratılması gereken, zincir dışı 
etkileşimler için yargıç görevi gören sözleşmelerdir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    contract D {
        uint public x;
        constructor(uint a) {
            x = a;
        }
    }

    contract C {
        function createDSalted(bytes32 salt, uint arg) public {
            // Bu karmaşık ifade size sadece adresin 
            // nasıl önceden hesaplanabileceğini söyler. O sadece örnekleme için oradadır.
            // İhtiyacınız olan aslında sadece ``new D{salt: salt}(arg)``.
            address predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(
                    type(D).creationCode,
                    abi.encode(arg)
                ))
            )))));

            D d = new D{salt: salt}(arg);
            require(address(d) == predictedAddress);
        }
    }

.. warning::
    Saltlı kreasyonların alışılmadık bazı özellikleri vardır. Bir sözleşme, 
    yok edildikten sonra aynı adreste yeniden oluşturulabilir. Yine de, 
    bu yeni oluşturulan sözleşmenin kreasyon bayt kodu aynı olmasına rağmen 
    (bu bir gerekliliktir çünkü aksi takdirde adres değişir) farklı bir dağıtılmış 
    bayt koduna sahip olması bile mümkündür. Bunun nedeni, constructorın iki kreasyon 
    arasında değişmiş olabilecek dış durumu sorgulayabilmesi ve depolanmadan önce 
    bunu deploy edilmiş bayt koduna dahil edebilmesidir.



İfadelerin Değerlendirme Sırası
==================================

İfadelerin değerlendirme sırası belirtilmez (daha resmi olarak, ifade
ğacındaki bir düğümün çocuklarının değerlendirildiği sıra belirtilmez, 
ancak elbette düğümün kendisinden önce değerlendirilirler.). Bu sadece
ifadelerin sırayla yürütülmesini garanti eder ve boolean ifadeler
için kısa devre yapılır.

.. index:: ! assignment

Atama
==========

.. index:: ! assignment;destructuring

Atamaları Yok Etme ve Birden Çok Değer Döndürme
-------------------------------------------------------

Solidity dahili olarak tuple türlerine, yani derleme zamanında
sayısı sabit olan potansiyel olarak farklı türdeki nesnelerin bir 
listesine izin verir. Bu tuple'lar aynı anda birden çok değer döndürmek 
için kullanılabilir. Bunlar daha sonra yeni bildirilen değişkenlere
veya önceden var olan değişkenlere (veya genel olarak LDeğerlere) atanabilir.

Tuple'lar, Solidity'de uygun tipler değildir, sadece sözdizimsel 
ifade grupları oluşturmak için kullanılabilirler. 

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        uint index;

        function f() public pure returns (uint, bool, uint) {
            return (7, true, 2);
        }

        function g() public {
            // Type ile bildirilen ve döndürülen tupledan atanan değişkenler,
            // tüm öğelerin belirtilmesi gerekmez (ancak sayı eşleşmelidir).
            (uint x, , uint y) = f();
            // Değerleri değiştirmek için yaygın bir numara -- değer olmayan depolama türleri için çalışmaz.
            (x, y) = (y, x);
            // Bileşenler dışarıda bırakılabilir (ayrıca değişken bildirimleri için).
            (index, , ) = f(); // index'i  7'ye ayarlar.
        }
    }

Değişken bildirimlerini ve bildirim dışı atamaları karıştırmak mümkün değildir,
yani bu geçerli değildir: ``(x, uint y) = (1, 2);``

.. note::
    0.5.0 sürümünden önce, ya solda ya da sağda doldurulan (hangisi boşsa) 
    daha küçük boyutlu tuplelara atamak mümkündü. Buna artık izin verilmiyor, 
    bu nedenle her iki tarafın da aynı sayıda bileşene sahip olması gerekiyor.

.. warning::
    Referans türleri söz konusu olduğunda, Aynı anda birden fazla 
    değişkene atama yaparken dikkatli olun, çünkü bu, beklenmedik 
    kopyalama davranışına yol açabilir.

Diziler ve Structlar için Komplikasyonlar
------------------------------------

Atamaların anlamı, diziler ve structlar gibi değer olmayan türler için daha karmaşıktır.
``bytelar`` ve ``string`` dahil, ayrıntılar için :ref:`Data location and assignment behaviour <data-location-assignment>` bölümüne bakın.

Aşağıdaki örnekte, ``g(x)`` çağrısının ``x`` üzerinde hiçbir etkisi yoktur. Çünkü
bellekteki depolama değerinin bağımsız bir kopyasını oluşturur. Ancak, ``h(x)`` 
``x`` öğesini başarıyla değiştirir çünkü bir kopya değil, yalnızca bir referans iletilir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract C {
        uint[20] x;

        function f() public {
            g(x);
            h(x);
        }

        function g(uint[20] memory y) internal pure {
            y[2] = 3;
        }

        function h(uint[20] storage y) internal {
            y[3] = 4;
        }
    }

.. index:: ! scoping, declarations, default value

.. _default-value:

Kapsam Belirleme ve Beyanlar
========================

Bildirilen bir değişken, bayt temsilinin tümü sıfır olan 
bir başlangıç ​​varsayılan değerine sahip olacaktır.
Değişkenlerin "varsayılan değerleri", türü ne olursa olsun tipik 
"sıfır durumu"dur. Örneğin, bir ``bool`` için varsayılan değer 
``false`` tur. ``uint`` veya ``int`` türleri için varsayılan değer 
``0`` dır. Statik olarak boyutlandırılmış diziler ve ``bytes1`` den
``bytes32``ye kadar olan her bir öğe, kendi türüne karşılık gelen 
varsayılan değere göre başlatılacaktır. Dinamik olarak boyutlandırılmış 
diziler ve ``bytelar`` ve ``string`` için, varsayılan değer boş bir 
dizi veya dizedir. ``enum`` türü için varsayılan değer kendisinin ilk üyesidir.

Solidity'de kapsam belirleme, C99'un yaygın kapsam belirleme kurallarına uyar
(ve diğer birçok dil): Değişkenler, bildirimlerinden hemen sonraki noktadan
bildirimi içeren en küçük ``{ }`` bloğunun sonuna kadar görülebilir.
Bu kuralın bir istisnası olarak, for döngüsünün başlatma parçasında tanımlanan değişkenler
yalnızca for döngüsünün sonuna kadar görünür.

Parametre benzeri değişkenler (fonksiyon parametreleri, modifier parametreleri,
catch parametreleri, ...) bir fonksiyon için fonksiyon/modifier'ın gövdesi 
ve modifier parametresi ve bir catch parametresi için catch bloğunu 
takip eden kod bloğunun içinde görünürdür.

Değişkenler ve diğer öğeler bir kod bloğunun dışında bildirilir, örneğin 
fonksiyonlar, sözleşmeler, kullanıcı tanımlı türler, vb. beyan edilmeden önce 
bile görülebilir. Bu, durum değişkenlerini bildirilmeden önce kullanabileceğiniz 
ve fonksiyonları yinelemeli olarak çağırabileceğiniz anlamına gelir.

Sonuç olarak, aşağıdaki örnekler uyarı olmadan derlenecektir, çünkü
iki değişken aynı ada ancak ayrık kapsamlara sahiptir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    contract C {
        function minimalScoping() pure public {
            {
                uint same;
                same = 1;
            }

            {
                uint same;
                same = 3;
            }
        }
    }

C99 kapsam belirleme kurallarına özel bir örnek olarak, aşağıdakilere dikkat edin,
``x``e yapılan ilk atama aslında iç değişkeni değil dış değişkeni atayacaktır.
Her durumda, gölgelenen dış değişken hakkında bir uyarı alacaksınız.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // Bu bir uyarı bildirir
    contract C {
        function f() pure public returns (uint) {
            uint x = 1;
            {
                x = 2; // bu dış değişkene atayacaktır
                uint x;
            }
            return x; // x değeri 2'dir
        }
    }

.. warning::
    
    0.5.0 sürümünden önce Solidity, JavaScript ile aynı kapsam kurallarını 
    takip ediyordu;  yani, bir fonksiyon içinde herhangi bir yerde bildirilen
    bir değişken, nerede bildirildiğine bakılmaksızın tüm fonksiyonun 
    kapsamında olurdu. Aşağıdaki örnek, derleme için kullanılan ancak 0.5.0 
    sürümünden başlayarak bir hataya yol açan bir kod parçacığını göstermektedir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    // Bu derlenmeyecektir
    contract C {
        function f() pure public returns (uint) {
            x = 2;
            uint x;
            return x;
        }
    }

.. index:: ! safe math, safemath, checked, unchecked
.. _unchecked:

Checked veya Unchecked Matematiksel İşlemler
===============================

Bir overflow veya underflow durumu, aritmetik bir işlemin sınırsız 
bir tamsayı üzerinde işlem yaptığında sonuç türünün aralığı
normalin dışında kalması durumudur.

Solidity 0.8.0'dan önce, aritmetik işlemler, ek kontroller getiren
kitaplıkların yaygın kullanımına yol açan underflow veya overflow 
durumunu her zaman kapsardı.

Solidity 0.8.0'dan bu yana, tüm aritmetik işlemler varsayılan olarak 
overflow ve underflow'u engeller, böylece bu, kitaplıkların kullanımını 
gereksiz hale getirir.

Önceki davranışı elde etmek için bir ``unchecked`` bloğu kullanılabilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract C {
        function f(uint a, uint b) pure public returns (uint) {
            // Bu çıkarma underflow'a sebep olur.
            unchecked { return a - b; }
        }
        function g(uint a, uint b) pure public returns (uint) {
            // Bu çıkarma underflow'u engeller.
            return a - b;
        }
    }

``f(2, 3)`` çağrısı ``2**256-1`` döndürürken, ``g(2, 3)`` başarısız bir
assertion'a neden olur.

``unchecked`` blok, bir blok içinde her yerde kullanılabilir, ama bir
bloğu değiştirmek için. Ayrıca nested olamaz.

Ayar yalnızca sözdizimsel olarak bloğun içindeki ifadeleri etkiler.
Bir ``unchecked`` blok içinden çağrılan fonksiyonlar özelliği miras almaz.

.. note::
    Belirsizliği önlemek için, bir ``unchecked`` blok içinde ``_;`` kullanamazsınız.

Aşağıdaki operatörler, overflow veya underflow durumunda başarısız bir assertion'a neden olur
ve unchecked bir blok içinde kullanılırsa hatasız kalır:

``++``, ``--``, ``+``, binary ``-``, unary ``-``, ``*``, ``/``, ``%``, ``**``

``+=``, ``-=``, ``*=``, ``/=``, ``%=``

.. warning::
    Unchecked blok kullanılarak sıfıra bölme veya mod alma işleminin 
    kontrolünü devre dışı bırakmak mümkün değildir.

.. note::
   Bitsel operatörler overflow veya underflow kontrolleri yapmaz.
   Bu, özellikle bitsel değiştirmeler (``<<``, ``>>``, ``<<=``, ``>>=``) 
   kullanılırken tamsayı bölme ve 2'nin kuvvetiyle çarpma işleminde görülebilir,  
   Örneğin ``type(uint256).max * 8`` revert edilse bile ``type(uint256).max << 3`` 
   revert edilmez.

.. note::
    ``int x = type(int).min; -x;`` içindeki ikinci ifade overflow ile sonuçlanacak.
    çünkü negatif aralık, pozitif aralıktan bir değer daha fazla tutabilir.

Açık tür dönüşümleri her zaman sekteye uğrar ve integer'dan enum türüne 
dönüştürme dışında asla başarısız bir assertion'a neden olmaz.

.. index:: ! exception, ! throw, ! assert, ! require, ! revert, ! errors

.. _assert-and-require:

Hata İşleme: Assert, Require, Revert ve Exceptionlar
======================================================

Solidity, hataları işlemek için durumu geri döndüren
exceptionlar kullanır. Böyle bir exception, geçerli çağrıdaki 
(ve tüm alt çağrılarındaki) durumda yapılan tüm değişiklikleri
geri alır ve çağırana bir hata bildirir.

Bir alt aramada exceptionlar meydana geldiğinde,
``try/catch`` ifadesiyle yakalanmadıkları sürece 
otomatik olarak yeniden atılırlar. Bu kuralın istisnaları ``send``
ve düşük seviyeli fonksiyonlar ``call``, ``delegatecall`` ve
``staticcall``: bir exception olması durumunda onu yeniden atmak 
yerine ``false`` değerini ilk dönüş değerleri olarak döndürürler.

.. warning::
    Düşük seviyeli fonksiyonlar ``call``, ``delegatecall`` ve
    ``staticcall`` ESM tasarımının bir parçası olarak, çağrılan 
    hesap mevcut değilse, ilk dönüş değeri olarak ``true`` döndürür.
    Gerekirse çağrıdan önce hesabın varlığı kontrol edilmelidir.

Exceptionlar çağırana :ref:`hata örnekleri <errors>` şeklinde 
geri iletilen hata verilerini içerebilir.
``Error(string)`` ve ``Panic(uint256)`` yerleşik hataları
aşağıda açıklandığı gibi özel işlevler tarafından kullanılır.
aşağıda açıklandığı gibi özel fonksiyonlar tarafından kullanılır. 
``Panic`` hatasız kodda olmaması gereken hatalar için kullanılırken
``Error`` "normal" hata koşulları için kullanılır. 

``assert`` ile Panic ve ``require`` ile Hata
----------------------------------------------

``assert`` ve ``require`` uygunluk fonksiyonları şu amaçlarla kullanılabilir:
koşulları kontrol etmek ve koşul karşılanmazsa bir hata fırlatmak.

``assert`` fonksiyonu ``Panic(uint256)`` türünde bir hata oluşturur.
Aynı hata, derleyici tarafından aşağıda listelendiği gibi belirli durumlarda oluşturulur.

Assert yalnızca dahili hataları test etmek ve değişken olmayanları
kontrol etmek için kullanılmalıdır. Düzgün çalışan kod, geçersiz 
harici girişte bile asla Panik oluşturmamalıdır. Eğer bu olursa, 
o zaman sözleşmenizde düzeltmeniz gereken bir hata olur. Dil analiz
araçları, koşulları ve Paniğe neden olacak fonksiyon çağrıları belirlemek 
için sözleşmenizi değerlendirebilir.

Aşağıdaki durumlarda bir Panik exception'ı oluşturulur.
Hata verileriyle birlikte verilen hata kodu, panik türünü belirtir.

#. 0x00: Jenerik derleyici yerleştirilmiş panikler için kullanılır.
#. 0x01: Yanlış olarak değerlendirilen bir argümanla ``assert``ü çağırırsanız.
#. 0x11: Bir aritmetik işlem, ``unchecked { ... }`` bir bloğun dışında underflow veya overflow ie sonuçlanırsa.
#. 0x12; Sıfıra bölerseniz veya mod alma işlemi yaparsanız (ör. ``5 / 0`` ya da ``23 % 0``).
#. 0x21: Çok büyük veya negatif bir değeri bir enum türüne dönüştürürseniz.
#. 0x22: Yanlış kodlanmış bir depolama bayt dizisine erişirseniz.
#. 0x31: Boş bir dizide ``.pop()`` çağırırsanız.
#. 0x32: Bir diziye, ``bytesN``ye veya sınır dışı veya negatif bir dizindeki bir dizi dilimine erişirseniz (ör. ``x[i]`` i, ``i >= x.length`` veya ``i < 0`` olduğunda).
#. 0x41: Çok fazla bellek ayırırsanız veya çok büyük bir dizi oluşturursanız.
#. 0x51: Dahili fonksiyon türünün hiç başlatılmamış bir değişkenini çağırırsanız.

The ``require`` fonksiyonu, ya herhangi bir veri içermeyen bir hata ya da 
``Error(string)`` türünde bir hata oluşturur. Yürütme zamanına kadar 
tespit edilemeyen geçerli koşulları sağlamak için kullanılmalıdır.
Bu, çağrılardan harici sözleşmelere yapılan girdiler veya dönüş 
değerleri üzerindeki koşulları içerir.

.. note::
    Şu anda özel hataları ``require`` ile birlikte kullanmak mümkün değildir.
    Lütfen bunun yerine ``if (!condition) revert CustomError();`` kullanın.

Bir ``Error(string)`` exceptionı (veya veri içermeyen bir exception) derleyici
tarafından aşağıdaki durumlarda oluşturulur:

#. ``x``in ``false`` olarak değerlendirildiği durumlarda ``require(x)`` çağrılır.
#. ``revert()`` veya ``revert("description")`` kullanırsanız.
#. Kod içermeyen bir sözleşmeyi hedefleyen harici bir fonksiyon çağrısı gerçekleştirirseniz.
#. Sözleşmeniz Ether'i ``payable`` modifier (constructor ve geri dönüş fonksiyonu dahil)
   içermeyen public bir fonksiyon aracılığıyla alırsa
#. Sözleşmeniz Ether'i bir public getter fonksiyonu aracılığıyla alıyorsa.

Aşağıdaki durumlarda, harici çağrılardan gelen hata verileri
(varsa) iletilir. Bu, bir `Error` veya `Panic` (veya başka ne verildiyse)'e 
neden olabileceği anlamına gelir:

#. Bir ``.transfer()`` başarısız olursa.
#. Mesaj çağrısı yoluyla bir fonksiyonu çağırırsanız ancak işlem 
   uygun şekilde tamamlanmazsa (ör. gazının bitmesi, eşleşen bir foksiyonunun
   olmaması, veya bir exception atması), düşük seviyeli bir işlem
   ``call``, ``send``, ``delegatecall``, ``callcode`` ya da ``staticcall``
   kullanılması bunun dışındadır. Düşük seviyeli işlemler hiçbir zaman exception oluşturmaz, 
   ancak ``false`` döndürerek hataları belirtir. 
#. ``new`` anahtar sözcüğünü kullanarak bir sözleşme oluşturursanız ancak sözleşme
   oluşturma :ref:`düzgün bitmezse<creating-contracts>`.

İsteğe bağlı olarak ``require`` için bir string mesajı sağlayabilirsiniz, ancak ``assert`` için değil. 

.. note::
    ``require`` için bir dize argümanı sağlamazsanız, 
    hata seçiciyi içermeden bile boş hata verileriyle geri dönecektir.

Aşağıdaki örnek, girdilerdeki koşulları kontrol etmek için ``require``
ve dahili hata kontrolü için ``assert``i nasıl kullanabileceğinizi gösterir.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract Sharer {
        function sendHalf(address payable addr) public payable returns (uint balance) {
            require(msg.value % 2 == 0, "Çift değerler isteniyor");
            uint balanceBeforeTransfer = address(this).balance;
            addr.transfer(msg.value / 2);
            // Transfer, başarısızlık durumunda bir exception oluşturduğundan ve
            // buradan geri çağırma yapamadığı için, hala paranın yarısına sahip olmak için
            //bir yol olmaması gerekiyor
            assert(address(this).balance == balanceBeforeTransfer - msg.value / 2);
            return address(this).balance;
        }
    }

Dahili olarak, Solidity bir geri alma işlemi gerçekleştirir (talimat
``0xfd``). Bu, ESM'nin duruma yapılan tüm değişiklikleri geri almasına
neden olur. Geri dönüş nedeni yürütmeye devam etmenin güvenli bir yolunun
olmamasıdır, çünkü beklenen etki gerçekleşmez. İşlemlerin atomikliğini 
korumak istediğimiz için, en güvenli eylem, tüm değişiklikleri geri almak 
ve etkisi olmadan tüm işlemi (veya en azından çağrıyı) yapmaktır.

Her iki durumda da çağıran bu tür hatalara ``try``/``catch`` kullanarak tepki verebilir, ancak
çağrılandaki değişiklikler her zaman geri alınır.

.. note::
    Solidity 0.8.0'dan önce, panik exceptionları, çağrı için mevcut tüm gazı tüketen
    ``geçersiz`` işlem kodu kullanırdı.
    ``require`` ifadesini kullanan exceptionlar Metropolis'in piyasaya sürülmesinden önce
    tüm gazı tüketmek için kullanırlardı.
    
.. _revert-statement:

``revert``
----------

``revert`` ifadesi ve ``revert`` fonksiyonu kullanılarak doğrudan bir geri alma tetiklenebilir.

``revert`` ifadesi, parantez olmadan doğrudan argüman olarak özel bir hata alır:

    revert CustomError(arg1, arg2);

Geriye dönük uyumluluk nedenleriyle, parantez kullanan ``revert()`` fonksiyonu da vardır.
ve bir string kabul eder:

    revert();
    revert("açıklama");

Hata verileri çağırana geri gönderilir ve orada yakalanabilir.
``revert()`` kullanmak, herhangi bir hata verisi olmadan geri döndürmeye 
neden olurken, ``revert("açıklama")``, bir ``Error(string)`` hatası yaratacaktır.

Özel bir hata örneği kullanmak, genellikle bir metin açıklamasından çok daha ucuz olacaktır,
çünkü sadece 4 baytta kodlanmış olan hatayı tanımlamak için hatanın adını kullanabilirsiniz.
Herhangi bir maliyete maruz kalmadan NatSpec aracılığıyla daha uzun bir açıklama sağlanabilir.

Aşağıdaki örnek, ``revert`` ve eşdeğer ``require`` ile birlikte bir hata metni ve özel bir 
hata örneğinin nasıl kullanılacağını gösterir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract VendingMachine {
        address owner;
        error Unauthorized();
        function buy(uint amount) public payable {
            if (amount > msg.value / 2 ether)
                revert("Yeterli Eter sağlanmadı.");
            // Bunu yapmanın alternatif yolu:
            require(
                amount <= msg.value / 2 ether,
                "Yeterli Eter sağlanmadı."
            );
            // Satın alma işlemini gerçekleştirin.
        }
        function withdraw() public {
            if (msg.sender != owner)
                revert Unauthorized();

            payable(msg.sender).transfer(address(this).balance);
        }
    }

``revert`` ve ``require`` argümanlarının yan etkileri olmadığı sürece 
örneğin argümanlar sadece stringse ``if (!condition) revert(...);`` ve 
``require(condition, ...);`` eşdeğerdir.

.. note::
    ``require`` fonksiyonu diğer herhangi bir fonksiyon gibi değerlendirilir.
    Bu, fonksiyonun kendisi yürütülmeden önce tüm argümanların değerlendirildiği anlamına gelir.
    Özellikle, ``require(condition, f())`` içinde, ``f`` fonksiyonu ``condition``
    doğru olduğunda bile yürütülür.

Elde edilen string, fonksiyonuna yapılan bir çağrıymış gibi :ref:`abi-encoded <ABI>` şeklindedir.
Yukarıdaki örnekte, ``revert("Yeterli Eter sağlanmadı..");`` hata dönüş verisi olarak aşağıdaki hexadecimal değeri döndürür:

.. code::

    0x08c379a0                                                         // Error(string) için fonksiyon seçici
    0x0000000000000000000000000000000000000000000000000000000000000020 // veri ofseti
    0x000000000000000000000000000000000000000000000000000000000000001a // String uzunluğu
    0x4e6f7420656e6f7567682045746865722070726f76696465642e000000000000 // String verisi

Elde edilen mesaj, çağıran tarafından aşağıda gösterildiği gibi ``try``/``catch`` kullanılarak alınabilir.

.. note::
    Eskiden 0.4.13 sürümünde kullanımdan kaldırılan ve 0.5.0 sürümünde kaldırılan 
    ``revert()`` ile aynı semantiğe sahip ``throw`` adında bir anahtar kelime vardı.


.. _try-catch:

``try``/``catch``
-----------------

Harici aramadaki bir hata, aşağıdaki gibi bir try/catch ifadesi kullanılarak yakalanabilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.1;

    interface DataFeed { function getData(address token) external returns (uint value); }

    contract FeedConsumer {
        DataFeed feed;
        uint errorCount;
        function rate(address token) public returns (uint value, bool success) {
            // 10'dan fazla hata varsa mekanizmayı 
            // kalıcı olarak devre dışı bırakır.
            require(errorCount < 10);
            try feed.getData(token) returns (uint v) {
                return (v, true);
            } catch Error(string memory /*reason*/) {
                // Bu, getData içinde 
                // revertün çağrılması durumunda 
                // ve bir stringin sağlanması durumunda yürütülür.
                errorCount++;
                return (0, false);
            } catch Panic(uint /*errorCode*/) {
                // Bu panik durumunda yürütülür,
                // ör. sıfıra bölme veya taşma gibi ciddi bir hata
                // ya da overflow varsa. Hata kodu
                // hatanın türünü belirlemek için kullanılır.
                errorCount++;
                return (0, false);
            } catch (bytes memory /*lowLevelData*/) {
                // Bu revert() kullanıldığında yürütülür.
                errorCount++;
                return (0, false);
            }
        }
    }

``try`` anahtar sözcüğünü, harici bir fonksiyon çağrısını veya bir sözleşme oluşturmayı temsil 
eden bir ifade takip etmelidir (``new ContractName()``).
İfade içindeki hatalar yakalanmaz (örneğin fonksiyon çağrılarını içeren
karmaşık bir ifade ise), harici fonksiyonun içinde sadece bir geri dönüş oluşur.
Aşağıdaki ``returns`` kısmı (isteğe bağlıdır) harici arama tarafından döndürülen türlerle eşleşen 
dönüş değişkenlerini bildirir. Hata olmaması durumunda,bu değişkenler atanır ve sözleşmenin 
yürütülmesi ilk başarı bloğu içinde devam eder. Başarı bloğunun sonuna ulaşılırsa, ``catch`` bloklarından sonra yürütme devam eder.

Solidity, duruma bağlı olarak farklı türde catch bloklarını destekler.
hata türü:

- ``catch Error(string memory reason) { ... }``: Bu catch yan tümcesi eğer hata ``revert("reasonString")`` ya da 
  ``require(false, "reasonString")`` nedeniyle oluyorsa (veya böyle bir istisnaya neden olan dahili bir hata) çalıştırılır.

- ``catch Panic(uint errorCode) { ... }``: If the error was caused by a panic, i.e. by a failing ``assert``, division by zero,
  invalid array access, arithmetic overflow and others, this catch clause will be run.

- ``catch (bytes memory lowLevelData) { ... }``: Bu yan tümce  hata imzası başka bir maddeyle eşleşmezse,
  hata mesajının kodu çözülürken bir hata oluştuysa veya exception dışında hiçbir hata verisi sağlanmadıysa
  yürütülür. Bildirilen değişken, bu durumda düşük seviyeli hata verilerine erişim sağlar.

- ``catch { ... }``: Hata verileriyle ilgilenmiyorsanız, 
  ``catch { ... }`` (tek catch maddesi olarak bile) önceki madde yerine sadece kullanabilirsiniz.

Gelecekte başka türdeki hata verilerinin de desteklemesi planlanmaktadır.
``Error`` ve ``Panic`` stringleri şu anda olduğu gibi ayrıştırılıyor ve tanımlayıcı olarak kabul edilmiyor.

Tüm hata durumlarını yakalamak için, en azından ``catch { ...}`` veya 
``catch (bytes memory lowLevelData) { ... }`` yan tümcesine sahip olmalısınız.

``returns`` ve ``catch`` yan tümcesinde belirtilen değişkenler yalnızca
takip eden blok kapsamındadır.

.. note::

    ``catch Error(string memory reason)`` kodunun çözülmesi sırasında bir hata 
    varsa ve düşük seviyeli bir catch cümlesi varsa, bu hata orada yakalanır.

.. note::

    Yürütme bir catch bloğuna ulaşırsa, harici çağrının durum değiştiren 
    etkilerine geri dönülür. Yürütme başarı bloğuna ulaşırsa, etkiler geri 
    alınmaz. Etkiler geri alındıysa, yürütme ya bir catch bloğunda devam eder 
    ya da try/catch ifadesinin yürütülmesi kendisine geri döner (örneğin, yukarıda belirtildiği 
    gibi kod çözme hataları veya düşük seviyeli bir yakalama maddesi sağlamama nedeniyle).

.. note::

    Başarısız bir çağrının arkasındaki sebep çok çeşitli olabilir. Hata 
    mesajının doğrudan çağrılan sözleşmeden geldiğini varsaymayın:
    Hata, çağrı zincirinde daha derinlerde meydana gelmiş olabilir ve 
    çağrılan sözleşme onu iletmiş olabilir. Ayrıca, kasıtlı bir hata 
    durumu değil, gazın bitmesi durumundan kaynaklanabilir:
    Çağıran, bir aramada her zaman gazın en az 1/64'ünü elinde tutar ve böylece
    çağrılan sözleşmenin gazı bitse bile, çağıranın hala biraz gazı vardır.
