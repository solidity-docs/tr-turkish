.. index:: ! type;reference, ! reference type, storage, memory, location, array, struct

.. _reference-types:

Referans Türleri
===============

Referans türünün değerleri, birden çok farklı adla değiştirilebilir. Bunu, bir değer türü değişkeni kullanıldığında bağımsız bir kopya aldığınız değer türleriyle karşılaştırın. Bu nedenle referans türleri, değer türlerinden daha dikkatli ele alınmalıdır. Şu anda referans türleri yapılar, diziler ve eşlemelerden oluşmaktadır. Bir referans türü kullanıyorsanız, her zaman türün depolandığı veri alanını açıkça sağlamanız gerekir: ``memory`` (ömrü, harici bir işlev çağrısıyla sınırlıdır), ``storage`` (durum değişkenlerinin ömrünün, bir sözleşmenin ömrüyle sınırlı olduğu durumlarda saklanır) veya ``calldata`` (işlev argümanlarını içeren özel veri konumu).

Veri konumunu değiştiren bir atama veya tür dönüştürme işlemi her zaman otomatik bir kopyalama işlemine neden olurken, aynı veri konumu içindeki atamalar yalnızca bazı durumlarda depolama türleri için kopyalanır.

.. _data-location:

Veri Konumu
-------------

Her referans türünün, nerede depolandığı hakkında "veri konumu" olan ek bir açıklaması vardır. Üç veri konumu vardır: ``memory``, ``storage`` ve ``calldata``. Çağrı verileri (calldata), işlev bağımsız değişkenlerinin depolandığı ve çoğunlukla bellek gibi davrandığı, değiştirilemeyen, kalıcı olmayan bir alandır.


.. not::
    Yapabiliyorsanız, veri konumu olarak ``calldata`` kullanmayı deneyin, çünkü bu kopyaları önler ve ayrıca verilerin değiştirilememesini sağlar. "calldata" veri konumuna sahip diziler ve yapılar da fonksiyonlarla döndürülebilir, ancak bu türlerin atanması mümkün değildir.

.. not::
    0.6.9 sürümünden önce, referans türü argümanlar için veri konumu, harici işlevlerde ``calldata``, genel işlevlerde ``memory`` ve dahili ve özel işlevlerde ``memory`` veya ``storage`` ile sınırlıydı. . Artık ``memory``e ve ``calldata``ya, görünürlüklerinden bağımsız olarak tüm işlevlerde izin verilir.
   
.. not::
    0.5.0 sürümünden önce, veri konumu atlanabilir ve değişkenin türüne, işlev türüne vb. bağlı olarak varsayılan olarak farklı konumlara atanırdı, ancak tüm karmaşık türler şimdi açık bir veri konumu vermelidir.

.. _data-location-assignment:

Veri Konumu ve Atama Davranışı
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Veri konumları yalnızca verilerin kalıcılığı için değil, aynı zamanda atamaların anlamı için de önemlidir:

Data locations are not only relevant for persistency of data, but also for the semantics of assignments:

* ``storage`` ve ``memory`` (veya ``calldata``) arasındaki atamalar her zaman bağımsız bir kopya oluşturur.
* ``memory``den ``memory``ye (bellekten belleğe) yapılan atamalar yalnızca referans oluşturur. Bu, bir bellek değişkeninde (``memory``) yapılan değişikliklerin aynı verilere atıfta bulunan diğer tüm bellek değişkenlerinde de görülebileceği anlamına gelir.
* ``storage``dan (depolamadan), **local** (yerel) depolama değişkenine yapılan atamalar da yalnızca bir referans atar.
*  Diğer tüm atamalar ``storage``a her zaman kopyalanır. Bu duruma örnek olarak, yerel değişkenin kendisi yalnızca bir başvuru olsa bile, durum değişkenlerine veya depolama yapısı türünün yerel değişkenlerinin üyelerine atamalar verilebilir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    contract C {
        // x'in veri konumu depolamadır.
        // Bu, veri konumunun atlanabileceği tek yerdir.
        uint[] x;

        // memoryArray öğesinin veri konumu bellektir.
        function f(uint[] memory memoryArray) public {
            x = memoryArray; // çalışır ve tüm diziyi depoya kopyalar
            uint[] storage y = x; // çalışır ve bir işaretçi atar. y'nin veri konumu depolamadır
            y[7]; // 8. öğeyi döndürür
            y.pop(); // x'i y ile değiştirir
            delete x; // diziyi temizler, ayrıca y'yi değiştirir
            // Aşağıdakiler çalışmıyor; depolamada yeni bir geçici adsız dizi oluşturması gerekir, ancak depolama "statik olarak" tahsis edilir: /
            // y = memoryArray;
            // İşaretçiyi "sıfırlayacağı" için bu da işe yaramaz, ancak işaret edebileceği mantıklı bir konum yoktur.
            // delete y;
            g(x); // g'yi çağırır, x'e bir referans verir
            h(x); // h'yi çağırır ve bellekte bağımsız, geçici bir kopya oluşturur
        }

        function g(uint[] storage) internal pure {}
        function h(uint[] memory) public pure {}
    }

.. index:: ! array

.. _arrays:

Diziler
------

Diziler, derleme zamanında sabit bir boyuta sahip olabilir veya dinamik bir boyuta sahip olabilir.

Sabit boyutlu bir dizinin türü ``k`` ve öğe türü ``T``, ``T[k]`` olarak yazılır ve dinamik boyut dizisi ``T[]`` olarak yazılır.

Örneğin, ``uint``in 5 dinamik dizisinden oluşan bir dizi ``uint[][5]`` olarak yazılır. Notasyon, diğer bazı dillere kıyasla tersine çevrilir. Solidity'de, ``X[3]`` her zaman ``X`` türünde üç öğe içeren bir dizidir, ``X``in kendisi bir dizi olsa bile. C gibi diğer dillerde durum böyle değildir.

Endeksler sıfır tabanlıdır ve erişim bildirimin tersi yönündedir.

Örneğin, bir ``uint[][5] memory x`` değişkeniniz varsa, ``x[2][6]`` kullanarak üçüncü dinamik dizi içerisindeki yedinci ``uint``'e erişirsiniz ve üçüncü dinamik diziye erişmek için ``x[2]`` kullanırsınız. Yine, aynı zamanda bir dizi de olabilen bir ``T`` türü için bir ``T[5] a`` diziniz varsa, o zaman ``a[2]`` her zaman ``T`` tipine sahiptir.

Dizi öğeleri, eşleme veya yapı dahil olmak üzere herhangi bir türde olabilir. Türler için genel kısıtlamalar geçerlidir, çünkü eşlemeler yalnızca "depolama" veri konumunda depolanabilir ve genel olarak görülebilen işlevler :ref:`ABI types <ABI>` olan parametrelere ihtiyaç duyar.

Durum değişkeni dizilerini ``public`` olarak işaretlemek ve Solidity'nin bir :ref:`alıcı <visibility-and-getters>` oluşturmasını sağlamak mümkündür. Sayısal dizin, alıcı için gerekli bir parametre haline gelir.

Sonunu aşan bir diziye erişmek, başarısız bir onaylamaya neden olur. ``.push()`` ve ``.push(value)`` yöntemleri dizinin sonuna yeni bir öğe eklemek için kullanılabilir; burada ``.push()`` sıfır başlatılmış bir öğe ekler ve ona bir referans döndürür.


.. index:: ! string, ! bytes

.. _strings:

.. _bytes:

Diziler olarak ``bytes`` ve ``string``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``bytes`` ve ``string`` türündeki değişkenler özel dizilerdir. ``bytes`` türü ``bytes1[]`` ile benzerdir, ancak çağrı verileri ve bellekte sıkıca paketlenmiştir. ``string``, ``bytes`` değerine eşittir ancak uzunluk veya dizin erişimine izin vermez.

Solidity'nin dize (string) işleme işlevleri yoktur, ancak üçüncü taraf dize (string) kitaplıkları vardır. Ayrıca,
``keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))`` 
kullanarak iki dizgiyi keccak256-hash ile karşılaştırabilir ve ``string.concat(s1, s2)`` kullanarak iki dizgiyi birleştirebilirsiniz.

``bytes1[]`` yerine ``bytes`` kullanmalısınız çünkü daha ucuzdur, çünkü ``memory``de ``bytes1[]`` kullanmak, öğeler arasında 31 dolgu bayt ekler. ``storage``"da, sıkı paketleme nedeniyle dolgu bulunmadığına dikkat edin, bkz. :ref:`bayt ve dize<bytes-and-string>`. Genel bir kural olarak, rastgele uzunluktaki ham bayt verileri için ``bytes`` ve rastgele uzunluktaki dize (UTF-8) verileri için ``string`` kullanın. Uzunluğu belirli bir bayt sayısıyla sınırlayabiliyorsanız, her zaman ``bytes1`` ile ``bytes32`` arasındaki değer türlerinden birini kullanın çünkü bunlar çok daha ucuzdur.


.. not::

    ``s`` dizesinin bayt temsiline erişmek istiyorsanız, ``bytes(s).length`` / ``bytes(s)[7] = 'x';`` yapısını kullanın. Tek tek karakterlere değil, UTF-8 temsilinin düşük seviyeli baytlarına eriştiğinizi unutmayın.

.. index:: ! bytes-concat, ! string-concat

.. _bytes-concat:
.. _string-concat:

``bytes.concat`` ve ``string.concat`` Fonksiyonları
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``string.concat`` kullanarak rastgele sayıda ``string`` değerini birleştirebilirsiniz. Fonksiyon, bağımsız değişkenlerin içeriğini doldurmadan içeren tek bir ``string memory`` dizisi döndürür. Örtülü olarak ``string``e dönüştürülemeyen diğer türlerin parametrelerini kullanmak istiyorsanız, önce bunları ``string``e dönüştürmeniz gerekir.

Benzer şekilde, ``bytes.concat`` fonksiyonu, rastgele sayıda ``bytes`` veya ``bytes1 ... bytes32`` değerlerini birleştirebilir. Fonksiyon, bağımsız değişkenlerin içeriğini doldurmadan içeren tek bir ``bytes memory`` dizisi döndürür. Dize parametreleri veya örtük olarak ``bytes``a dönüştürülemeyen diğer türleri kullanmak istiyorsanız, önce bunları ``bytes`` veya ``bytes1``/.../``bytes32``ye dönüştürmeniz gerekir.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.12;

    contract C {
        string s = "Storage";
        function f(bytes calldata bc, string memory sm, bytes16 b) public view {
            string memory concatString = string.concat(s, string(bc), "Literal", sm);
            assert((bytes(s).length + bc.length + 7 + bytes(sm).length) == bytes(concatString).length);

            bytes memory concatBytes = bytes.concat(bytes(s), bc, bc[:2], "Literal", bytes(sm), b);
            assert((bytes(s).length + bc.length + 2 + 7 + bytes(sm).length + b.length) == concatBytes.length);
        }
    }

``string.concat``ı veya ``bytes.concat``ı, argüman olmadan çağırırsanız, boş bir dizi döndürürler.

.. index:: ! array;allocating, new

Bellek Dizilerini Ayırma
^^^^^^^^^^^^^^^^^^^^^^^^

Dinamik uzunluktaki bellek dizileri ``new`` operatörü kullanılarak oluşturulabilir. Depolama dizilerinin aksine, bellek dizilerini yeniden boyutlandırmak **değildir** (ör. ``.push`` üye fonksiyonları kullanılamaz). Gereken boyutu önceden hesaplamanız veya yeni bir bellek dizisi oluşturmanız ve her öğeyi kopyalamanız gerekir.

Solidity'deki tüm değişkenler gibi, yeni tahsis edilen dizilerin öğeleri her zaman :ref:`varsayılan değer<varsayılan-değer>` ile başlatılır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        function f(uint len) public pure {
            uint[] memory a = new uint[](7);
            bytes memory b = new bytes(len);
            assert(a.length == 7);
            assert(b.length == len);
            a[6] = 8;
        }
    }

.. index:: ! array;literals, ! inline;arrays

Dizi Değişmezleri
^^^^^^^^^^^^^^

Bir dizi değişmezi, köşeli parantezler (``[...]``) içine alınmış bir veya daha fazla ifadenin virgülle ayrılmış bir listesidir. Örneğin ``[1, a, f(3)]``. Dizi değişmezinin türü şu şekilde belirlenir:

Her zaman uzunluğu ifade sayısı olan statik olarak boyutlandırılmış bir bellek dizisidir.

Dizinin temel türü, diğer tüm ifadelerin dolaylı olarak kendisine dönüştürülebileceği şekilde listedeki ilk ifadenin türüdür. Bu mümkün değilse bir tür hatasıdır.

Tüm öğelerin dönüştürülebileceği bir türün olması yeterli değildir. Öğelerden birinin bu türden olması gerekir.

Aşağıdaki örnekte, ``[1, 2, 3]`` türü ``uint8[3] memory``dir, çünkü bu sabitlerin her birinin türü ``uint8``dir. Sonucun ``uint[3] memory`` türünde olmasını istiyorsanız, ilk öğeyi ``uint``e dönüştürmeniz gerekir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        function f() public pure {
            g([uint(1), 2, 3]);
        }
        function g(uint[3] memory) public pure {
            // ...
        }
    }

Birinci ifadenin türü ``uint8`` iken ikincinin türü ``int8`` olduğundan ve bunlar örtük olarak birbirine dönüştürülemediğinden ``[1, -1]`` dizisi değişmezi geçersizdir. Çalışması için örneğin ``[int8(1), -1]`` kullanabilirsiniz.

Farklı türdeki sabit boyutlu bellek dizileri birbirine dönüştürülemediğinden (temel türler yapabilse bile), iki boyutlu dizi değişmezlerini kullanmak istiyorsanız, her zaman ortak bir temel türü açıkça belirtmeniz gerekir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        function f() public pure returns (uint24[2][4] memory) {
            uint24[2][4] memory x = [[uint24(0x1), 1], [0xffffff, 2], [uint24(0xff), 3], [uint24(0xffff), 4]];
            // Aşağıdakiler çalışmaz, çünkü bazı iç diziler doğru tipte değildir.
            // uint[2][4] memory x = [[0x1, 1], [0xffffff, 2], [0xff, 3], [0xffff, 4]];
            return x;
        }
    }

Sabit boyutlu bellek dizileri, dinamik olarak boyutlandırılmış bellek dizilerine atanamaz, yani aşağıdakiler mümkün değildir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    // Bu derleme gerçekleşmeyecek.
    contract C {
        function f() public {
            // Sonraki satır bir tür hatası oluşturur çünkü uint[3] belleği, uint[] belleğine dönüştürülemez.
            uint[] memory x = [uint(1), 3, 4];
        }
    }

İleride bu kısıtlamanın kaldırılması planlanıyor ancak dizilerin ABI'dan geçirilme şekli nedeniyle bazı komplikasyonlar yaratıyor.

Dinamik olarak boyutlandırılmış dizileri başlatmak istiyorsanız, tek tek öğeleri atamanız gerekir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        function f() public pure {
            uint[] memory x = new uint[](3);
            x[0] = 1;
            x[1] = 3;
            x[2] = 4;
        }
    }

.. index:: ! array;length, length, push, pop, !array;push, !array;pop

.. _array-members:

Dizi Üyeleri
^^^^^^^^^^^^^

**length**:
    Diziler, eleman sayısını içeren bir ``length`` (uzunluk) üyesine sahiptir.Bellek dizilerinin uzunluğu, oluşturulduktan sonra sabittir (ancak dinamiktir, yani çalışma zamanı parametrelerine bağlı olabilir).
**push()**:
    Dinamik depolama dizileri ve ``bytes`` (``string`` değil), dizinin sonuna sıfır başlatılmış bir öğe eklemek için kullanabileceğiniz ``push()`` adlı üye fonksiyonuna sahiptir.
    Öğeye bir başvuru döndürür, böylece ``x.push().t = 2`` veya ``x.push() = b`` gibi kullanılabilir.
**push(x)**:
    Dinamik depolama dizileri ve ``bytes`` (``string`` değil), dizinin sonuna belirli bir öğeyi eklemek için kullanabileceğiniz ``push(x)`` adlı bir üye fonksiyonuna sahiptir. Fonksiyon hiçbir şey döndürmez.
**pop()**:
    Dinamik depolama dizileri ve ``bytes`` (``string`` değil), dizinin sonundan bir öğeyi kaldırmak için kullanabileceğiniz ``pop()`` adlı bir üye fonksiyonuna sahiptir. Bu ayrıca kaldırılan öğede örtük olarak :ref:`delete<delete>` öğesini çağırır. Fonksiyon hiçbir şey döndürmez.

.. not::
    ``pop()`` kullanarak uzunluk azaltılırken kaldırılan öğenin "boyutuna" bağlı olarak bir ücreti varken, bir depolama dizisinin uzunluğunu ``push()`` çağırarak artırmanın sabit gaz maliyetleri vardır çünkü başlarken depolama sıfırdır. Kaldırılan öğe bir diziyse, çok maliyetli olabilir, çünkü :ref:`delete<delete>` çağrılmasına benzer şekilde kaldırılan öğelerin açıkça temizlenmesini içerir.

.. not::
    Dizi dizilerini harici (genel yerine) fonksiyonlarda kullanmak için ABI kodlayıcı v2'yi etkinleştirmeniz gerekir.

.. not::
    "Byzantium" öncesi EVM sürümlerinde fonksiyon çağrılarından dönen dinamik dizilere erişim mümkün değildi. Dinamik diziler döndüren işlevleri çağırırsanız, Byzantium moduna ayarlanmış bir EVM kullandığınızdan emin olun.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract ArrayContract {
        uint[2**20] aLotOfIntegers;
        // Aşağıdakilerin bir çift dinamik dizi değil, dinamik bir çift dizisi (yani, iki uzunluktaki sabit boyutlu diziler) olduğuna dikkat edin.
        // Bu nedenle, T[], T'nin kendisi bir dizi olsa bile, her zaman dinamik bir T dizisidir.
        // Tüm durum değişkenleri için veri konumu depolamadır.
        bool[2][] pairsOfFlags;

        // newPairs bellekte saklanır - tek olasılık
        // açık (public) sözleşme fonksiyonları argümanları için
        function setAllFlagPairs(bool[2][] memory newPairs) public {
            // bir depolama dizisine atama, "``newPairs``in bir kopyasını gerçekleştirir ve ``pairsOfFlags`` dizisinin tamamının yerini alır.
            pairsOfFlags = newPairs;
        }

        struct StructType {
            uint[] contents;
            uint moreInfo;
        }
        StructType s;

        function f(uint[] memory c) public {
            // ``g`` içindeki ``s`` referansını saklar
            StructType storage g = s;
            // ayrıca ``s.moreInfo``yu da değiştirir.
            g.moreInfo = 2;
            // ``g.contents`` yerel bir değişken değil, yerel bir değişkenin üyesi olduğu için bir kopya atar.
            g.contents = c;
        }

        function setFlagPair(uint index, bool flagA, bool flagB) public {
            // var olmayan bir dizine erişim bir istisna atar
            pairsOfFlags[index][0] = flagA;
            pairsOfFlags[index][1] = flagB;
        }

        function changeFlagArraySize(uint newSize) public {
            // bir dizinin uzunluğunu değiştirmenin tek yolu push ve pop kullanmaktır
            if (newSize < pairsOfFlags.length) {
                while (pairsOfFlags.length > newSize)
                    pairsOfFlags.pop();
            } else if (newSize > pairsOfFlags.length) {
                while (pairsOfFlags.length < newSize)
                    pairsOfFlags.push();
            }
        }

        function clear() public {
            // bunlar dizileri tamamen temizler
            delete pairsOfFlags;
            delete aLotOfIntegers;
            // identical effect here
            pairsOfFlags = new bool[2][](0);
        }

        bytes byteData;

        function byteArrays(bytes memory data) public {
            // bayt dizileri ("bayts"), dolgu olmadan depolandıkları için farklıdır, ancak "uint8[]" ile aynı şekilde ele alınabilirler.
            byteData = data;
            for (uint i = 0; i < 7; i++)
                byteData.push();
            byteData[3] = 0x08;
            delete byteData[2];
        }

        function addFlag(bool[2] memory flag) public returns (uint) {
            pairsOfFlags.push(flag);
            return pairsOfFlags.length;
        }

        function createMemoryArray(uint size) public pure returns (bytes memory) {
            // Dinamik bellek dizileri `new` kullanılarak oluşturulur:
            uint[2][] memory arrayOfPairs = new uint[2][](size);

            // Satır içi diziler her zaman statik olarak boyutlandırılmıştır ve yalnızca değişmez değerler kullanıyorsanız, en az bir tür sağlamanız gerekir.
            arrayOfPairs[0] = [uint(1), 2];

            // Dinamik bir bayt dizisi oluşturun:
            bytes memory b = new bytes(200);
            for (uint i = 0; i < b.length; i++)
                b[i] = bytes1(uint8(i));
            return b;
        }
    }

.. index:: ! array;dangling storage references

Depolama Dizisi Öğelerine Sarkan Referanslar
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Depolama dizileriyle çalışırken, sarkan referanslardan kaçınmaya özen göstermeniz gerekir. Sarkan referans, artık var olmayan veya referans güncellenmeden taşınmış bir şeye işaret eden bir referanstır. Örneğin, bir dizi öğesine bir başvuruyu yerel bir değişkende saklarsanız ve ardından içeren diziden ``.pop()`` depolarsanız, sarkan bir başvuru oluşabilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0 <0.9.0;

    contract C {
        uint[][] s;

        function f() public {
            // s öğesinin son dizi öğesine bir işaretçi depolar.
            uint[] storage ptr = s[s.length - 1];
            // s öğesinin son dizi öğesini kaldırır.
            s.pop();
            // Artık dizi içinde olmayan dizi öğesine yazar.
            ptr.push(0x42);
            // Şimdi ``s`` öğesine yeni bir öğe eklemek boş bir dizi eklemez, ancak öğe olarak ``0x42`` olan 1 uzunluğunda bir diziyle sonuçlanır.
            s.push();
            assert(s[s.length - 1][0] == 0x42);
        }
    }

``ptr.push(0x42)`` içindeki yazma, ``ptr``nin artık geçerli bir ``s`` öğesini ifade etmemesine rağmen **dönmeyecek**. Derleyici kullanılmayan depolamanın her zaman sıfırlandığını varsaydığından, sonraki bir ``s.push()``, depolamaya açıkça sıfır yazmaz, bu nedenle ``push()``dan sonraki ``s``nin son öğesi ``1`` uzunluğa sahip ve ilk öğesi olarak ``0x42`` içeriyor.

Solidity'nin, depolamadaki değer türlerine referansların bildirilmesine izin vermediğini unutmayın. Bu tür açık sarkan başvurular, iç içe geçmiş başvuru türleriyle sınırlıdır. Ancak, tanımlama grubu atamalarında karmaşık ifadeler kullanılırken geçici olarak sarkan referanslar da oluşabilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0 <0.9.0;

    contract C {
        uint[] s;
        uint[] t;
        constructor() {
            // Bazı başlangıç değerlerini depolama dizilerine aktarın.
            s.push(0x07);
            t.push(0x03);
        }

        function g() internal returns (uint[] storage) {
            s.pop();
            return t;
        }

        function f() public returns (uint[] memory) {
            // Aşağıdakiler ilk önce ``s.push()`` öğesini dizin 1'deki yeni bir öğeye yapılan bir başvuruya göre değerlendirecektir.
            // Daha sonra, ``g`` çağrısı bu yeni öğeyi açar ve en soldaki demet öğesinin sarkan bir referans haline gelmesine neden olur.
            // Atama hala devam ediyor ve ``s`` veri alanının dışına yazacak.
            (s.push(), g()[0]) = (0x42, 0x17);
            // Daha sonra ``s``ye basılması (push edilmesi/pushlanması), önceki ifade tarafından yazılan değeri ortaya çıkaracaktır, yani bu fonksiyonun sonunda "s"nin son elemanı "0x42" değerine sahip olacaktır.
            s.push();
            return s;
        }
    }

Her ifade için depolamaya yalnızca bir kez atama yapmak ve atamanın sol tarafında karmaşık ifadelerden kaçınmak her zaman daha güvenlidir.

Bir bayt dizisindeki bir ``.push()``, :ref:`depolamada kısa düzenden uzun düzene <bytes-and-string>` geçebileceğinden, ``bytes`` dizilerinin öğelerine yapılan başvurularla uğraşırken özellikle dikkatli olmanız gerekir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.0 <0.9.0;

    // Bu bir uyarı bildirir
    contract C {
        bytes x = "012345678901234567890123456789";

        function test() external returns(uint) {
            (x.push(), x.push()) = (0x01, 0x02);
            return x.length;
        }
    }

Burada, ilk ``x.push()`` değerlendirildiğinde, ``x`` hala kısa düzende saklanır, bu nedenle ``x.push()``, ``x``in ilk depolama yuvasındaki bir öğeye bir referans döndürür. Ancak, ikinci ``x.push()`` bayt dizisini büyük düzene geçirir. Şimdi ``x.push()`` öğesinin atıfta bulunduğu öğe dizinin veri alanındayken, başvuru hala uzunluk alanının bir parçası olan orijinal konumunu işaret eder ve atama, ``x`` dizisinin uzunluğunu etkin bir şekilde bozar.

To be safe, only enlarge bytes arrays by at most one element during a single
assignment and do not simultaneously index-access the array in the same statement.

While the above describes the behaviour of dangling storage references in the
current version of the compiler, any code with dangling references should be
considered to have *undefined behaviour*. In particular, this means that
any future version of the compiler may change the behaviour of code that
involves dangling references.

Be sure to avoid dangling references in your code!

.. index:: ! array;slice

.. _array-slices:

Array Slices
------------


Array slices are a view on a contiguous portion of an array.
They are written as ``x[start:end]``, where ``start`` and
``end`` are expressions resulting in a uint256 type (or
implicitly convertible to it). The first element of the
slice is ``x[start]`` and the last element is ``x[end - 1]``.

If ``start`` is greater than ``end`` or if ``end`` is greater
than the length of the array, an exception is thrown.

Both ``start`` and ``end`` are optional: ``start`` defaults
to ``0`` and ``end`` defaults to the length of the array.

Array slices do not have any members. They are implicitly
convertible to arrays of their underlying type
and support index access. Index access is not absolute
in the underlying array, but relative to the start of
the slice.

Array slices do not have a type name which means
no variable can have an array slices as type,
they only exist in intermediate expressions.

.. note::
    As of now, array slices are only implemented for calldata arrays.

Array slices are useful to ABI-decode secondary data passed in function parameters:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.5 <0.9.0;
    contract Proxy {
        /// @dev Address of the client contract managed by proxy i.e., this contract
        address client;

        constructor(address client_) {
            client = client_;
        }

        /// Forward call to "setOwner(address)" that is implemented by client
        /// after doing basic validation on the address argument.
        function forward(bytes calldata payload) external {
            bytes4 sig = bytes4(payload[:4]);
            // Due to truncating behaviour, bytes4(payload) performs identically.
            // bytes4 sig = bytes4(payload);
            if (sig == bytes4(keccak256("setOwner(address)"))) {
                address owner = abi.decode(payload[4:], (address));
                require(owner != address(0), "Address of owner cannot be zero.");
            }
            (bool status,) = client.delegatecall(payload);
            require(status, "Forwarded call failed.");
        }
    }



.. index:: ! struct, ! type;struct

.. _structs:

Structs
-------

Solidity provides a way to define new types in the form of structs, which is
shown in the following example:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // Defines a new type with two fields.
    // Declaring a struct outside of a contract allows
    // it to be shared by multiple contracts.
    // Here, this is not really needed.
    struct Funder {
        address addr;
        uint amount;
    }

    contract CrowdFunding {
        // Structs can also be defined inside contracts, which makes them
        // visible only there and in derived contracts.
        struct Campaign {
            address payable beneficiary;
            uint fundingGoal;
            uint numFunders;
            uint amount;
            mapping (uint => Funder) funders;
        }

        uint numCampaigns;
        mapping (uint => Campaign) campaigns;

        function newCampaign(address payable beneficiary, uint goal) public returns (uint campaignID) {
            campaignID = numCampaigns++; // campaignID is return variable
            // We cannot use "campaigns[campaignID] = Campaign(beneficiary, goal, 0, 0)"
            // because the right hand side creates a memory-struct "Campaign" that contains a mapping.
            Campaign storage c = campaigns[campaignID];
            c.beneficiary = beneficiary;
            c.fundingGoal = goal;
        }

        function contribute(uint campaignID) public payable {
            Campaign storage c = campaigns[campaignID];
            // Creates a new temporary memory struct, initialised with the given values
            // and copies it over to storage.
            // Note that you can also use Funder(msg.sender, msg.value) to initialise.
            c.funders[c.numFunders++] = Funder({addr: msg.sender, amount: msg.value});
            c.amount += msg.value;
        }

        function checkGoalReached(uint campaignID) public returns (bool reached) {
            Campaign storage c = campaigns[campaignID];
            if (c.amount < c.fundingGoal)
                return false;
            uint amount = c.amount;
            c.amount = 0;
            c.beneficiary.transfer(amount);
            return true;
        }
    }

The contract does not provide the full functionality of a crowdfunding
contract, but it contains the basic concepts necessary to understand structs.
Struct types can be used inside mappings and arrays and they can themselves
contain mappings and arrays.

It is not possible for a struct to contain a member of its own type,
although the struct itself can be the value type of a mapping member
or it can contain a dynamically-sized array of its type.
This restriction is necessary, as the size of the struct has to be finite.

Note how in all the functions, a struct type is assigned to a local variable
with data location ``storage``.
This does not copy the struct but only stores a reference so that assignments to
members of the local variable actually write to the state.

Of course, you can also directly access the members of the struct without
assigning it to a local variable, as in
``campaigns[campaignID].amount = 0``.

.. note::
    Until Solidity 0.7.0, memory-structs containing members of storage-only types (e.g. mappings)
    were allowed and assignments like ``campaigns[campaignID] = Campaign(beneficiary, goal, 0, 0)``
    in the example above would work and just silently skip those members.
