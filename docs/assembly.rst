.. _inline-assembly:

###############
Inline Assembly
###############

.. index:: ! assembly, ! asm, ! evmasm

Inline assembly ile Solidity ifadelerini Ethereum Sanal Makine'sinin dillerinden birine yakın dile çevirebilirsiniz.
Bu size özellikle dili kütüphaneler yazarak geliştiriyorsanız daha detaylı bir kontrol sağlar.

Inline assembly için kullanılan Solidity diline :ref:`Yul <yul>` deniyor ve dosyalarını kendi bölümünde bulabilirsiniz.
BU bölüm sadece inline assembly kodunun etrafındaki Solidity kodları ile nasıl bağlandığını anlatacak.

.. warning::
    Inline assembly Ethereum Sanal Makinesi'ne düşük seviyede erişişmin bir yoludur.
    Bu, Solidity'nin birçok güvenlik özelliklerini ve kontrollerini yok sayar.
    Yani inline assembly'i sadece gereken yerlerde ve nasıl kullanacağınızdan eminseniz kullanmalısınız.

Bir inline assembly bloğu ``assembly { ... }`` ile işaretlidir. 
Süslü parantez içerisindeki kod :ref:`Yul <yul>` dili içerisinde yer alır.

Bir inline assembly kodu yerel Solidity değişkenlerine aşağıda açıklandığı gibi erişebilir.

Farklı inline assembly blokları aynı yer adlarını paylaşmazlar. Yani farklı bir inline assembly 
bloğunda tanımlanmış olan bir Yul fonksiyonunu çağırmak ya da bir Yul değişkenine erişmek mümkün değldir.

Örnek
-------

Aşağıdaki örnek başka bir kontrat üzerindeki koda erişimi ve bir ``bytes`` değişkenine atımını sağlayan kütüphane kodunu verir.
Bu "düz Solidity" ile de ``<address>.code`` kullanarak mümkündür ama buradaki amaç tekrar kullanılabilir assembly kütüphanelerinin
bir compiler değişimi olmadan Solidity dilini geliştirebildiğini göstermektir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library GetCode {
        function at(address addr) public view returns (bytes memory code) {
            assembly {
                // kodun boyutunu döndürür, burası için assembly kullanılmalı
                let size := extcodesize(addr)
                // çıkış bit array'ini allocate() eder
                // burası assembly kullanmadan, 
                // code = new bytes(size) kullanarak da yapılabilir.
                code := mload(0x40)
                // padding'i içeren yeni "memory end" 
                mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
                // uzunluğu hafızada saklayın
                mstore(code, size)
                // kodun şu anki halini döndürür, burası için assembly kullanılmalı
                extcodecopy(addr, add(code, 0x20), 0, size)
            }
        }
    }

Inline assembly optimizer verimli kodlar üretemediği zamanlarda da yararlıdır, örneğin:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;


    library VectorSum {
        // Bu fonksiyon şu anda verimli değil 
        // çünkü optimizer array sınır erişim kontrolünü yaparken hata veriyor
        function sumSolidity(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i)
                sum += data[i];
        }

        // Array'e sadece sınırları içerisinde erişebileceğimizi biliyoruz, yani bu kontrolü atlayabiliriz.
        // 0x20'nin array'e eklenmesi gerekiyor çünkü array'in ilk slotu array uzunluğunu içerir.
        function sumAsm(uint[] memory data) public pure returns (uint sum) {
            for (uint i = 0; i < data.length; ++i) {
                assembly {
                    sum := add(sum, mload(add(add(data, 0x20), mul(i, 0x20))))
                }
            }
        }
        // Yukarıdaki gibi ama tüm kodu inline assembly kullanarak tamamlayın.
        function sumPureAsm(uint[] memory data) public pure returns (uint sum) {
            assembly {
                // uzunluğu yükleyin (önce 32 byte)
                let len := mload(data)
                
                // Uzunluk alanını atlayın.
                //
                // Geçici bir değişken tutun, böylece yer değiştikçe onu da arttırabilirsiniz.
                //
                // NOT: Bu assembly bloktan sonra arttırılan veri kullanılamayacak bir değişkene dönüşecek
                
                let dataElementLocation := add(data, 0x20)

                // Sınıra ulaşana kadar tekrarlayın.
                for
                    { let end := add(dataElementLocation, mul(len, 0x20)) }
                    lt(dataElementLocation, end)
                    { dataElementLocation := add(dataElementLocation, 0x20) }
                {
                    sum := add(sum, mload(dataElementLocation))
                }
            }
        }
    }


.. index:: selector; of a function

Dış(External) değişkenlere, fonksiyonlara ve kütüphanelere erişim
-------------------------------------------------------

Solidity değişkenlerine ve diğer tanımlayıcılara isimlerini kullanarak erişebilirsiniz.

Bir değer tipinin yerel değişkenleri inline assembly içinde kullanılabilir durumdadır.
Bu yerel değişkenler okunabilir de yazılabilir de.

Belleği kasteden yerel değişkenler değerin kendisini değil, değerin bellekteki adresini işaret eder.
Bu değişkenler aynı zamanda değiştirilebilir de ancak bu sadece bir pointer değişimi olur, veri değişimi olmaz.
Bu sebeple Solidity'nin hafıza yönetimini yapmak sizin yükümlülüğünüzdedir.
Bkz :ref:`Conventions in Solidity <conventions-in-solidity>`

Benzer şekilde, statik boyutlandırılmış calldata array'leri ya da struct'ları gösteren 
yerel değişkenler de değerin adresini işaret eder, değerini değil.
Bu değişken yeni bir offset'e de atanabilir fakat değişkenin ``calldatasize()`` çalıştırılması 
dışında bir yeri işaret edebileceğinin hiçbir garantisi yoktur.

Dış fonksiyon pointer'ları için adres ve fonksiyon seçiyiye ``x.address`` ve ``x.selector`` ile erişilebilir.
Seçici dört adet right-aligned bitten oluşur.
İki değer de atanbilir. Örneğin: 

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.10 <0.9.0;

    contract C {
        // @fun değerini dönmek için yeni bir seçici de adres atayın 
        function combineToFunctionPointer(address newAddress, uint newSelector) public pure returns (function() external fun) {
            assembly {
                fun.selector := newSelector
                fun.address  := newAddress
            }
        }
    }


Dinamik calldata array'leri üzerinde, ``x.offset`` ve ``x.length`` 
kullanarak -bit halinde- calldata offset'ine ve uzunluğuna erişebilirsiniz.
Her iki ifade aynı zamanda atanabilir de ama statik bir durum için dönecekleri sonucun 
``calldatasize()`` sınırları içerisinde olacağının bir garantisi yoktur.

Yerel depolama değişkenleri ya da durum değişkenleri için tek bir Yul tanımlayıcısı yeterli değildir.
Çünkü bu değişkenler her zaman tam bir depolama alanı kaplamazlar.
Bu sebeple onların 'adresleri' bir slottan ve o slot içerisindeki bir byte-offset'ten oluşur.
``x`` değişkeni tarafından işaret edilen slotu çağırmak için ``x.slot`` ,
byte-offset'i çağırmak için ise ``x.offset`` kullanılır. Sadece ``x`` kullanmak ise hata verecektir.

Bir yerel depolama değişkeninin pointer'ının ``.slot`` kısmı değiştirilebilir.
Bu değişkenler(struct, array, mapping) için ``.offset`` kısmı ise her zaman sıfırdır.
Fakat bir durum değişkeninin ``.slot`` ve ``.offset`` kısmını değiştirmek mümkün değildir.

Yerel Solidity değişkenleri görevler için hazırdır. Örneğin:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;

    contract C {
        uint b;
        function f(uint x) public view returns (uint r) {
            assembly {
                // Bu senaryoda depolama slotunun offset'ini değelendirmiyoruz.
                // Çünkü sıfır olduğunu biliyoruz.
                r := mul(x, sload(b.slot))
            }
        }
    }

.. warning::
    Eğer ``uint64``, ``address`` veya ``bytes16`` gibi 256 bitten daha az 
    yer kaplayan bir değişkene erişmeye çalışıyorsanız bu tipin parçası olmayan 
    bitler hakkında bir varsayımda bulunmayın. Özellikle de o bitleri sıfır kabul etmeyin.
    Her ihtimale karşı, ``uint32 x = f(); assembly { x := and(x, 0xffffffff) /* now use x */ }`` parçasının
    önemli olduğu yerlerde düzgün bir şekilde bu verileri temizleyin.
    Signed tipleri temizlemek için ``signextend`` kullanabilirsiniz. opcode:
    ``assembly { signextend(<num_bytes_of_x_minus_one>, x) }``

Solidity 0.6.0'dan beri bir inline assembly değişkeninin ismi inline assembly bloğundaki
kullanımını karşılamayabilir. (değişken, kontrat ve fonkisyon kullanımları dahil)

Soldity 0.7.0'dan beri inline assembly bloğunun içinde kullanılan değişken ve fonksiyonlar ``.`` içermeyebilir.
Fakat ``.`` kullanmak inline assembly bloğu dışındaki Solidity değişkenlerine ulaşmak için etkilidir.

Kaçınılacak Şeyler 
-------------------
Inline assembly high-level gözükebilir fakat aslında aşırı derecede low-level'dır.
Fonksiyon çağrıları, döngüler, if'ler ve switch'ler basit tekrar yazım kuralları ile çevrilir 
ve bundan sonra assembler'ın tek yaptığı iş blok sonuna erişildiğinde functional-style opcode'ları tekar ayarlamak, 
değişken erişimi için stack boyutunu saymak ve assembly içerisindeki değişkenleri için stack slotlarını kaldırmaktır. 

.. _Solidity-kuralları:

Solidity kuralları
---------------------

.. _assembly-typed-değişkenler:

Typed Değişkenlerin Değerleri
=============================
EVM assembly'nin aksine, Solidity 256 bitten daha küçük tiplere sahiptir (ör: ``uint24``). Verimlilik için
çoğu aritmetik işlem bazı tiplerin 256 bitten küçük olabileceğini yok sayar ve higher-order bitler 
gerekliyse (hafızaya yazılmadan hemen önce ya da herhangi bir karşılaştırma yapılmadan önce) temizlenir.
Burası şu yüzden önemlidir: Eğer inline assembly içerisinde böyle bir değişkene erişmek istiyorsanız önce higher-order
bitleri kendiniz temizlemeniz gerekebilir.

.. _assembly-bellek-yönetimi:

Hafıza Yönetimi
==================

Solidity Belleği şu şekilde yönetir. Hafızada ``0x40`` konumunda bir "boş bellek pointer"ı bulunur.
Eğer belleğe bir şey atamak isterseniz bu pointer'ın işaret ettiği yerden başlayıp güncelleyin.
Bu hafızanın daha önce kullanılmadığına dair herhangi bir kanıt bulunmadığı için tamamen sıfır olduğunu da varsayamazsınız.
Belleği boşaltacak ya da rahatlatacak herhangi bir hazır kurulu mekanizma yoktur.
Aşağıda belleği yukarıda anlatıldığı şekilde kullanabileceğiniz bir assembly kod parçası bulunuyor:

.. code-block:: yul

    function allocate(length) -> pos {
      pos := mload(0x40)
      mstore(0x40, add(pos, length))
    }


Hafızanın ilk 64 biti kısa dönem hafızası için "geçici alan" olarak kullanılabilir.
Boş bellek pointer'ından sonraki 32 bit (yani ``0x60`` tan başlayan alan) ise kalıcı olarak sıfır olmalıdır
ve bu alan boş dinamik bellek array'lerinin temel değeri olarak kullanılır.
Bunlar ise demektir ki kullanılabilir hafıza ``0x80`` den başlar ve bu değer ise boş bellek pointer'ının ilk değeridir.   
Solidity'deki hafıza array'lerinin tamamı 32 bitin katları olacak şekilde yer kaplar.(Bu kural ``bytes1[]`` için de geçerlidir
fakat ``bytes`` ve ``string`` için geçerli değildir.) Çok boyutlu hafıza array'leri ise başka hafıza array'lerine pointer'lardır.
Dinamik array'in uzunluğu array'in ilk slotunda saklanır ve diğer slotlara array'in elemanları gelir.

.. warning::
    Statik boyutlandırılmış hafıza array'leri herhangi bir uzunluk alanına sahip değildir fakat bu sonradan dinamik ve statik
    boyutlandırılmış array'ler arasında daha kolay çevrimi sağlamak için eklenmiş olabilir. 
    Yani bu kurala dayanarak ilerlememelisiniz.


Hafıza Güvenliği
================

Inline assembly kullanmadan; compiler, iyi tanımlanmış bir durumda kalmak için her zaman belleğe güvenir. Bu özellikle 
:ref:`Yul IR üzerinden yeni kod oluşturma hattı Yul IR <ir-breaking-changes>` ile ilgilidir. Bu kod parçası yerel değişkenleri 
stack üzerinden belleğe atarak stack-too-deep hatasından kaçınmayı sağlar ve eğer bazı kesin varsayımlara uyuyorsa ekstra 
bellek optimizasyonları uygulayabilir.


Biz her ne kadar Solidity'nin kendi bellek modeline saygı gösterilmesini önersek de 
Inline assembly belleği uyumsuz bir biçimde kullanmanızı sağlar. Bu nedenle stack değişkenlerini belleğe taşımak
ve diğer bellek optimizasyonları, bir bellek işlemi içeren ya da Solidity değişkenlerini belleğe yazan 
tüm inline assembly bloklarında varsayılan olarak devredışı haldedir.

Fakat bir assembly bloğuna aşağıdaki şekilde özel olarak ek açıklamalar ekleyerek 
Solidity'nin bellek modeline uyduğunu belirtebilirsiniz:

.. code-block:: solidity

    assembly ("memory-safe") {
        ...
    }

Bellek açısından güvenli bir assembly bloğu sadece aşağıdaki bellek bölümlerine erişebilir:
- Sizin tarafınızdan yukarıda anlatıldığı gibi ``allocate`` benzeri bir mekanizma kullanarak atanmış bir bellek.
- Solidity tarafından atanmış bellek, yani sizin referans verdiğiniz bellek array'inin sınırları içerisinde kalan alan.
- Yukarıda bahsedilen 0 ile 64 bellek offset'leri arasında kalan geçici alan.
- Assembly bloğunun başındaki boş bellek pointer'ının değerinden *sonra* konumlanmış geçici bellek, yani boş bellek pointer'ının güncellememiş hali için ayrılan bellek alanı. 

Bunlara ek olarak, eğer bir assembly bloğu bellekteki bir Solidity değişkenine atanırsa bu erişimin 
yukarıda belirtilen bellek sınırları içerisinde olduğundan emin olmalısınız.

Belirtilen işlemler genellikle optimizer ile ilgili olduğu için 
assembly bloğu hata verse de verilen kısıtlamalar takip edilmeli.
Bir örnek olarak aşağıda verilen assembly kod parçası bellek açısından güvenli değil. 
Sebebi ise ``returndatasize()`` fonksiyonunun değeri belirtilen 64 bitlik geçici bellek alanını aşabilir.

.. code-block:: solidity

    assembly {
      returndatacopy(0, 0, returndatasize())
      revert(0, returndatasize())
    }

Fakat aşağıdaki kod ise bellek açısından *güvenli*dir. 
Çünkü boş bellek pointer'ının gösterdiği yerden sonrası güvenli bir şekilde geçici alan olarak kullanılabilir.

.. code-block:: solidity

    assembly ("memory-safe") {
      let p := mload(0x40)
      returndatacopy(p, 0, returndatasize())
      revert(p, returndatasize())
    }

Unutmayın ki eğer bir atama yoksa boş bellek pointer'ını güncellemenize gerek yoktur 
ama belleği kullanmaya boş bellek pointer'ının verdiği offset'ten başlayabilirsiniz.

Eğer bellek işlemleri sıfır uzunluğunu kullanıyorsa -geçici alana düşmediği sürece- 
herhangi bir offset'i de kullanabilirsiniz.

.. code-block:: solidity

    assembly ("memory-safe") {
      revert(0, 0)
    }

Unutmayın ki inline assembly içerisindeki bellek işlemleri bellek için güvenli olmadığı gibi 
bellekte referans tipinde olan Solidity değişkenlerine olan atamalar da bellek için güvenli olmayabilir.
Aşağıdaki örnek bellek için güvenli değildir:

.. code-block:: solidity

    bytes memory x;
    assembly {
      x := 0x40
    }
    x[0x20] = 0x42;

Belleğe erişim istemeyen işlemlerden oluşan ve bellek üzerindeki Solidity değişkenlerine atama yapmayan inline assembly 
otomatik olarak bellek için güvenli sayılır ve ekstra olarak belirtilmesine gerek duyulmaz.

.. uyarı::
    Assembly'nin bellek modelini sağladığından emin olmak sizin sorumluluğunuzdadır. Eğer siz bir assembly bloğunu 
    bellek için güvenli olarak tanımlayıp herhangi bir bellek hatası yaparsanız bu **kesinlikle**, doğru olmayan ya da 
    tanımlanmamış bir davranışa sebep olur. Ve bu hata test yaparak kolay bir şekilde bulunamaz.

Eğer Solidity'nin farklı versiyonları ile uyumlu olacak şekilde bir kütüphane oluşturuyorsanız 
bir assembly bloğunun bellek için güvenli olduğunu özel bir komut ile belirtebilirsiniz:

.. code-block:: solidity

    /// @solidity memory-safe-assembly
    assembly {
        ...
    }

Unutmayın ki yorum satırları ile belirtmeyi gelecek bir sürümde kaldıracağız yani eğer geçmiş compiler sürümleri ile uyum konusunda 
yeterli bilgiye sahip değilseniz dialect string kullanmayı tercih edin.
