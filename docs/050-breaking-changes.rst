*********************************************
Solidity v0.5.0 İşleyişi Bozan Değişiklikler
*********************************************

Bu bölüm, Solidity 0.5.0 sürümünde getirilen değişikliklerin, eski sürümlerdeki ana işleyişi bozan kısımlarını
değişikliklerin arkasındaki gerekçeleri ve etkilenen kodun nasıl güncelleneceğini
vurgular. Tam liste için `sürüm değişiklik günlüğü <https://github.com/ethereum/solidity/releases/tag/v0.5.0>`_
adresini kontrol edin.

.. note::
   Solidity v0.5.0 ile derlenen sözleşmeler, eski sürümlerle derlenen sözleşmelerle
   ve hatta kütüphanelerle yeniden derlenmeden veya yeniden dağıtılmadan arayüz
   oluşturmaya devam edebilir.  Arayüzleri veri konumlarını, görünürlük ve değişebilirlik
   belirleyicilerini içerecek şekilde değiştirmek yeterlidir. Aşağıdaki :ref:`Interoperability With Older Contracts <interoperability>`
   bölümüne bakınız.

Yalnızca Anlamsal (Semantik) Değişiklikleri
============================================

Bu bölümde yalnızca semantik olan, dolayısıyla mevcut kodda yeni ve farklı davranışları gizleme potansiyeli olan değişiklikler listelenmektedir.

* İşaretli sağa kaydırma artık uygun aritmetik kaydırma kullanır, yani sıfıra doğru yuvarlamak yerine negatif sonsuza doğru yuvarlar.  İşaretli ve işaretsiz kaydırma Constantinople'da özel işlem kodlarına sahip olacak ve şu an için Solidity tarafından taklit edilmektedir.

* Bir ``do...while`` döngüsündeki ``continue`` deyimi artık bu tür durumlarda yaygın davranış olan koşula atlıyor. Eskiden döngü gövdesine atlıyordu. Böylece, koşul yanlışsa, döngü sonlandırılır.

* ``.call()``, ``.delegatecall()`` ve ``.staticcall()`` fonksiyonları, tek bir ``bytes`` parametresi verildiğinde artık dolgu yapmıyor.

* Pure ve view fonksiyonları artık EVM sürümü Byzantium veya üstü ise ``CALL`` yerine ``STATICCALL`` opcode`u kullanılarak çağrılmaktadır. Bu, EVM düzeyinde durum değişikliklerine izin vermez.

* ABI kodlayıcı artık harici fonksiyon çağrılarında ve ``abi.encode`` içinde kullanıldığında çağrı verilerinden (``msg.data`` ve harici fonksiyon parametreleri) bayt dizilerini ve dizeleri düzgün bir şekilde doldurur. Dolgusuz kodlama için ``abi.encodePacked`` kullanın.

* ABI dekoderi, fonksiyonların başında ve ``abi.decode()`` içinde, aktarılan calldata çok kısaysa veya sınırların dışına işaret ediyorsa geri döner. Yüksek dereceli kirli bitlerin hala basitçe göz ardı edildiğini unutmayın.

* Tangerine Whistle'dan başlayarak harici fonksiyon çağrıları ile mevcut tüm gazı iletin.

Semantik ve Sentaktik Değişiklikler
====================================

Bu bölümde sözdizimi ve anlambilimi etkileyen değişiklikler vurgulanmaktadır.

* ``.call()``, ``.delegatecall()``, ``staticcall()``, ``keccak256()``, ``sha256()`` ve ``ripemd160()`` fonksiyonları artık sadece tek bir ``bytes`` argümanı kabul etmektedir. Ayrıca, argüman doldurulmamıştır. Bu, argümanların nasıl birleştirildiğini daha açık ve net hale getirmek için değiştirildi. Her ``.call()`` (ve ailesi) ``.call("")`` olarak ve her ``.call(signature, a, b, c)`` ``.call(abi.encodeWithSignature(signature, a, b, c))`` olarak değiştirildi (sonuncusu yalnızca değer türleri için çalışır).  Her ``keccak256(a, b, c)`` ifadesini ``keccak256(abi.encodePacked(a, b, c))`` olarak değiştirin. İşleyişi bozan bir değişiklik olmasa da, geliştiricilerin ``x.call(bytes4(keccak256("f(uint256)"), a, b)`` öğesini ``x.call(abi.encodeWithSignature("f(uint256)", a, b))`` olarak değiştirmeleri önerilir.

* Geri dönüş verilerine erişim sağlamak için ``.call()``, ``.delegatecall()`` ve ``.staticcall()`` fonksiyonları artık ``(bool, bytes memory)`` döndürmektedir.  ``bool success = otherContract.call("f")`` ifadesini ``(bool success, bytes memory data) = otherContract.call("f")`` olarak değiştirin.

* Solidity artık fonksiyon yerel değişkenleri için C99 tarzı kapsam kurallarını uygulamaktadır, yani değişkenler yalnızca bildirildikten sonra ve yalnızca aynı veya iç içe kapsamlarda kullanılabilir. Bir ``for`` döngüsünün başlatma bloğunda bildirilen değişkenler, döngü içindeki herhangi bir noktada geçerlidir.

Açıklık Gereksinimleri
=========================

Bu bölüm, kodun artık daha açık olması gereken değişiklikleri listeler.
Konuların çoğu için derleyici öneriler sağlayacaktır.

* Açık fonksiyon görünürlüğü artık zorunludur.  Her fonksiyona ve constructor'a ``public`` ve görünürlüğünü zaten belirtmeyen her fallback veya arayüz fonksiyonuna ``external`` ekleyin.

* struct, array veya mapping türlerindeki tüm değişkenler için açık veri konumu artık zorunludur. Bu aynı zamanda fonksiyon parametrelerine ve dönüş değişkenlerine de uygulanır.  Örneğin, ``uint[] x = z`` ifadesini ``uint[] storage x = z`` olarak ve ``function f(uint[][] x)`` ifadesini ``function f(uint[][] memory x)`` olarak değiştirin; burada ``memory`` veri konumudur ve uygun şekilde ``storage`` veya ``calldata`` ile değiştirilebilir.  ``external`` fonksiyonlarının ``calldata`` veri konumuna sahip parametreler gerektirdiğini unutmayın.

* Sözleşme türleri, isim alanlarını ayırmak için artık ``address`` üyelerini içermemektedir.  Bu nedenle, artık bir ``address`` üyesini kullanmadan önce sözleşme türünün değerlerini açıkça adreslere dönüştürmek gerekmektedir.  Örnek: ``c`` bir sözleşme ise, ``c.transfer(...)`` değerini ``address(c).transfer(...)`` olarak ve ``c.balance`` değerini ``address(c).balance`` olarak değiştirin.

* İlişkisiz sözleşme türleri arasında açık dönüşümlere artık izin verilmemektedir. Bir sözleşme türünden yalnızca temel veya ata türlerinden birine dönüştürebilirsiniz. Bir sözleşmenin, miras almamasına rağmen dönüştürmek istediğiniz sözleşme türüyle uyumlu olduğundan eminseniz, önce ``address`` türüne dönüştürerek bunu aşabilirsiniz. Örnek: ``A`` ve ``B`` sözleşme türleriyse, ``B`` ``A`` türünden miras almıyorsa ve ``b`` ``B`` türünde bir sözleşmeyse, ``A(adres(b))`` kullanarak ``b`` türünü ``A`` türüne dönüştürebilirsiniz. Aşağıda açıklandığı gibi, eşleşen payable fallback fonksiyonlarına dikkat etmeniz gerektiğini unutmayın.

* ``address`` türü ``address`` ve ``address payable`` olarak ikiye ayrılmıştır, burada sadece ``address payable`` ``transfer`` fonksiyonunu sağlamaktadır.  Bir ``address payable`` doğrudan bir ``address`` e dönüştürülebilir, ancak bunun tersine izin verilmez. ``address``'i ``address payable``'a dönüştürmek ``uint160`` vasıtasıyla dönüşüm yoluyla mümkündür. Eğer ``c`` bir sözleşme ise, ``address(c)`` sadece ``c`` bir payable fallback fonksiyonuna sahipse ``address payable`` ile sonuçlanır. Eğer :ref:`withdraw pattern<withdrawal_pattern>` kullanıyorsanız, büyük olasılıkla kodunuzu değiştirmeniz gerekmez çünkü ``transfer`` saklanan adresler yerine sadece ``msg.sender`` üzerinde kullanılır ve ``msg.sender`` bir ``address payable`` dır.

* Farklı boyuttaki ``bytesX`` ve ``uintY`` arasındaki dönüşümler, sağdaki ``bytesX`` dolgusu ve soldaki ``uintY`` dolgusu nedeniyle artık izin verilmiyor ve bu da beklenmedik dönüşüm sonuçlarına neden olabilir.  Boyut artık dönüştürmeden önce tür içinde ayarlanmalıdır.  Örneğin, ``bytes4`` (4 bayt) değişkenini önce ``bytes8`` değişkenine ve ardından ``uint64`` değişkenine dönüştürerek bir ``bytes4`` (4 bayt) değişkenini bir ``uint64`` (8 bayt) değişkenine dönüştürebilirsiniz. ``uint32`` üzerinden dönüştürme yaparken ters dolgu elde edersiniz. v0.5.0`dan önce ``bytesX`` ve ``uintY`` arasındaki herhangi bir dönüşüm ``uint8X`` üzerinden giderdi. Örneğin ``uint8(bytes3(0x291807))``, ``uint8(uint24(bytes3(0x291807)))``'e dönüştürülürdü (sonuç ``0x07``dir).

* Payable olmayan fonksiyonlarda ``msg.value`` kullanımına (veya bir modifier aracılığıyla tanıtılmasına) güvenlik özelliği olarak izin verilmez. Fonksiyonu ``payable`` haline getirin veya ``msg.value`` kullanan program mantığı için yeni bir dahili fonksiyon oluşturun.

* Anlaşılabilirlik nedeniyle, standart girdi kaynak olarak kullanıldığında komut satırı arayüzü artık ``-`` gerektirmektedir. Translated with www.DeepL.com/Translator (free version)

Kullanımdan Kaldırılan Öğeler
===================

Bu bölümde, önceki özellikleri veya sözdizimini kullanımdan kaldıran değişiklikler listelenmektedir.  Bu değişikliklerin çoğunun ``v0.5.0`` deneysel modunda zaten etkin olduğunu unutmayın.

Komut Satırı ve JSON Arayüzleri
--------------------------------

* Komut satırı seçeneği ``--formal`` (daha fazla biçimsel doğrulama için Why3 çıktısı oluşturmak için kullanılır) kullanımdan kaldırılmıştır ve artık silinmektedir.  Yeni bir biçimsel doğrulama modülü olan SMTChecker, ``pragma experimental SMTChecker;`` ile etkinleştirilmiştir.

* Komut satırı seçeneği ``--julia``, ara dil ``Julia``nın ``Yul`` olarak yeniden adlandırılması nedeniyle ``--yul`` olarak yeniden adlandırıldı.

* ``--clone-bin`` ve ``--combined-json clone-bin`` komut satırı seçenekleri kaldırıldı.

* Boş önek içeren yeniden eşlemelere izin verilmiyor.

* JSON AST alanları ``constant`` ve ``payable`` kaldırıldı. Bu bilgiler artık ``stateMutability`` alanında bulunmaktadır.

* ``FunctionDefinition`` node'unun JSON AST alanı ``isConstructor``, ``"constructor"``, ``"fallback"`` veya ``"function"`` değerine sahip olabilen ``kind`` adlı bir alanla değiştirildi.

* Bağlantısız ikili hex dosyalarında, kütüphane adres yer tutucuları artık ``$...$`` ile çevrelenmiş tam nitelikli kütüphane adının keccak256 hash'inin ilk 36 hex karakteridir. Önceden, sadece tam nitelikli kütüphane adı kullanılıyordu. Bu, özellikle uzun yollar kullanıldığında çakışma olasılığını azaltır. Binary dosyalar artık bu yer tutuculardan tam nitelikli adlara bir eşleme listesi de içeriyor.

Constructor'lar
------------

* Constructor'lar artık ``constructor`` anahtar sözcüğü kullanılarak tanımlanmalıdır.

* Temel constructor'ların parantezler olmadan çağrılmasına artık izin verilmemektedir.

* Aynı kalıtım hiyerarşisinde temel constructor argümanlarının birden fazla kez belirtilmesine artık izin verilmemektedir.

* Argümanları olan ancak argüman sayısı yanlış olan bir constructor çağrılmasına artık izin verilmemektedir.  Argüman vermeden yalnızca bir kalıtım ilişkisi belirtmek istiyorsanız, parantezleri hiç sağlamayın.

Fonksiyonlar
---------

* Fonksiyon ``callcode`` artık izin verilmiyor (``delegatecall`` lehine). Inline assembly ile kullanmak hala mümkündür.

* ``suicide`` artık izin verilmiyor (``selfdestruct`` lehine).

* ``sha3`` artık izin verilmiyor (``keccak256`` lehine).

* ``throw`` artık izin verilmiyor (``revert``, ``require`` ve ``assert`` lehine).

Dönüşümler
-----------

* Ondalık değişmezlerden ``bytesXX`` türlerine açık ve örtük dönüşümlere artık izin verilmiyor.

* Onaltılık değişmezlerden farklı boyuttaki ``bytesXX`` türlerine açık ve örtük dönüşümlere artık izin verilmiyor.

Literaller ve Sonekler
---------------------

* Artık yıllarla ilgili karmaşıklıklar ve karışıklıklar nedeniyle ``years`` birim gösterimine artık izin verilmemektedir.

* Bir sayı tarafından takip edilmeyen sondaki noktalara artık izin verilmemektedir.

* Onaltılık sayıların birim değerleriyle birleştirilmesine (örneğin ``0x1e wei``) artık izin verilmemektedir.

* Onaltılık sayılar için ``0X`` önekine izin verilmez, sadece ``0x`` mümkündür.

Değişkenler
---------

* Anlaşılabilirlik için boş structların tanımlanmasına artık izin verilmiyor.

* ``var`` anahtar sözcüğüne artık netlik için izin verilmiyor.

* Farklı sayıda bileşene sahip tuple'lar arasındaki atamalara artık izin verilmiyor.

* Derleme zamanı sabitleri olmayan sabitler için değerlere izin verilmez.

* Uyumsuz sayıda değere sahip çok değişkenli bildirimlere artık izin verilmemektedir.

* Başlatılmamış depolama değişkenlerine artık izin verilmemektedir.

* Boş tuple bileşenlerine artık izin verilmiyor.

* Değişkenler ve struct'lardaki döngüsel bağımlılıkların algılanması özyinelemede 256 ile sınırlandırılmıştır.

* Uzunluğu sıfır olan sabit boyutlu dizilere artık izin verilmemektedir.

Sözdizimi
------

* Fonksiyon durumu değişebilirlik değiştiricisi olarak ``constant`` kullanımına artık izin verilmemektedir.

* Boolean ifadeler aritmetik işlemler kullanamaz.

* Unary ``+`` operatörüne artık izin verilmiyor.

* Harfler artık önceden açık bir türe dönüştürülmeden ``abi.encodePacked`` ile kullanılamaz.

* Bir veya daha fazla dönüş değeri olan fonksiyonlar için boş dönüş ifadelerine artık izin verilmemektedir.

* " loose assembly" sözdizimine artık tamamen izin verilmiyor, yani atlama etiketleri, atlamalar ve işlevsel olmayan talimatlar artık kullanılamaz. Bunun yerine yeni ``while``, ``switch`` ve ``if`` yapılarını kullanın.

* Uygulaması olmayan fonksiyonlar artık modifier kullanamaz.

* Adlandırılmış dönüş değerlerine sahip fonksiyon tiplerine artık izin verilmemektedir.

* Blok olmayan if/while/for gövdeleri içindeki tek deyimli değişken bildirimlerine artık izin verilmiyor.

* Yeni anahtar kelimeler: ``calldata`` ve ``constructor``.

* Yeni ayrılmış anahtar sözcükler: ``alias``, ``apply``, ``auto``, ``copyof``,
  ``define``, ``immutable``, ``implements``, ``macro``, ``mutable``,
  ``override``, ``partial``, ``promise``, ``reference``, ``sealed``,
  ``sizeof``, ``supports``, ``typedef`` ve ``unchecked``.


.. _interoperability:

Eski Sözleşmelerle Birlikte Çalışabilirlik
=====================================

Solidity'nin v0.5.0'dan önceki sürümleri için yazılmış sözleşmeler için arayüzler
tanımlayarak (veya tam tersi şekilde) arayüz oluşturmak hala mümkündür. Aşağıdaki
0.5.0 öncesi sözleşmenin zaten dağıtılmış olduğunu düşünün:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.4.25;
    // Bu, derleyicinin 0.4.25 sürümüne kadar bir uyarı bildirecektir
    // Bu 0.5.0'dan sonra derlenmeyecektir
    contract OldContract {
        function someOldFunction(uint8 a) {
            //...
        }
        function anotherOldFunction() constant returns (bool) {
            //...
        }
        // ...
    }

Bu artık Solidity v0.5.0 ile derlenmeyecektir. Ancak, bunun için uyumlu bir arayüz tanımlayabilirsiniz:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;
    interface OldContract {
        function someOldFunction(uint8 a) external;
        function anotherOldFunction() external returns (bool);
    }

Orijinal sözleşmede ``constant`` olarak tanımlanmasına rağmen ``anotherOldFunction``
fonksiyonunu ``view`` olarak tanımlamadığımıza dikkat edin. Bunun nedeni Solidity v0.5.0`dan
itibaren ``view`` fonksiyonlarını çağırmak için ``staticcall`` kullanılmasıdır. v0.5.0 öncesinde
``constant`` anahtar sözcüğü zorunlu değildi, bu nedenle ``constant`` olarak bildirilen bir
fonksiyonu ``staticcall`` ile çağırmak yine de geri dönebilir, çünkü ``constant`` fonksiyonu
hala depolamayı değiştirmeye çalışabilir. Sonuç olarak, eski sözleşmeler için bir arayüz
tanımlarken, ``constant`` yerine sadece fonksiyonun ``staticcall`` ile çalışacağından kesinlikle
emin olduğunuz durumlarda ``view`` kullanmalısınız.

Yukarıda tanımlanan arayüz göz önüne alındığında, artık halihazırda dağıtılmış olan 0.5.0 öncesi sözleşmeyi kolayca kullanabilirsiniz:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    interface OldContract {
        function someOldFunction(uint8 a) external;
        function anotherOldFunction() external returns (bool);
    }

    contract NewContract {
        function doSomething(OldContract a) public returns (bool) {
            a.someOldFunction(0x42);
            return a.anotherOldFunction();
        }
    }

Benzer şekilde, 0.5.0 öncesi kütüphaneler, kütüphanenin fonksiyonları uygulanmadan tanımlanarak ve linking sırasında 0.5.0 öncesi kütüphanenin adresi verilerek kullanılabilir (linking için komut satırı derleyicisinin nasıl kullanılacağını öğrenmek için :ref:`commandline-compiler` bölümüne bakınız):

.. code-block:: solidity

    // This will not compile after 0.6.0
    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.5.0;

    library OldLibrary {
        function someFunction(uint8 a) public returns(bool);
    }

    contract NewContract {
        function f(uint8 a) public returns (bool) {
            return OldLibrary.someFunction(a);
        }
    }


Örnek
=======

Aşağıdaki örnekte bir sözleşme ve bu bölümde listelenen bazı değişikliklerle Solidity v0.5.0 için güncellenmiş sürümü gösterilmektedir.

Eski versiyon:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.4.25;
    // Bu 0.5.0'dan sonra derlenmeyecektir

    contract OtherContract {
        uint x;
        function f(uint y) external {
            x = y;
        }
        function() payable external {}
    }

    contract Old {
        OtherContract other;
        uint myNumber;

        // Fonksiyon değişebilirliği sağlanmadı, hata değil.
        function someInteger() internal returns (uint) { return 2; }

        // Fonksiyon görünürlüğü sağlanmadı, hata değil.
        // Fonksiyon değişebilirliği sağlanmadı, hata değil.
        function f(uint x) returns (bytes) {
            // Var bu versiyonda sorunsuz çalışıyor.
            var z = someInteger();
            x += z;
            // Throw bu versiyonda sorunsuz çalışıyor.
            if (x > 100)
                throw;
            bytes memory b = new bytes(x);
            y = -3 >> 1;
            // y == -1 (yanlış, -2 olmalı)
            do {
                x += 1;
                if (x > 10) continue;
                // 'Continue' sonsuz döngüye neden olur.
            } while (x < 11);
            // Çağrı yalnızca bir Bool döndürür.
            bool success = address(other).call("f");
            if (!success)
                revert();
            else {
                // Yerel değişkenler kullanımlarından sonra bildirilebilir.
                int y;
            }
            return b;
        }

        // 'arr' için açık bir veri konumuna gerek yok
        function g(uint[] arr, bytes8 x, OtherContract otherContract) public {
            otherContract.transfer(1 ether);

            // uint32 (4 bayt) bytes8'den (8 bayt) daha küçük olduğundan,
            // x'in ilk 4 baytı kaybolacaktır. Bu durum, bytesX sağa doğru
            // doldurulduğundan beklenmedik davranışlara yol açabilir.
            uint32 y = uint32(x);
            myNumber += y + msg.value;
        }
    }

Yeni versiyon:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.5.0;
    // Bu 0.6.0'dan sonra derlenmeyecektir

    contract OtherContract {
        uint x;
        function f(uint y) external {
            x = y;
        }
        function() payable external {}
    }

    contract New {
        OtherContract other;
        uint myNumber;

        // Fonksiyon değişebilirliği belirtilmelidir.
        function someInteger() internal pure returns (uint) { return 2; }

        // Fonksiyon görünürlüğü belirtilmelidir.
        // Fonksiyon değişebilirliği belirtilmelidir.
        function f(uint x) public returns (bytes memory) {
            // Tür şimdi açıkça verilmelidir.
            uint z = someInteger();
            x += z;
            // Throw'a artık izin verilmiyor.
            require(x <= 100);
            int y = -3 >> 1;
            require(y == -2);
            do {
                x += 1;
                if (x > 10) continue;
                // 'Continue' ile aşağıdaki koşula atlanır.
            } while (x < 11);

            // Çağrı (bool, bayt) döndürür.
            // Veri konumu belirtilmelidir.
            (bool success, bytes memory data) = address(other).call("f");
            if (!success)
                revert();
            return data;
        }

        using AddressMakePayable for address;
        // 'arr' için veri konumu belirtilmelidir
        function g(uint[] memory /* arr */, bytes8 x, OtherContract otherContract, address unknownContract) public payable {
            // 'otherContract.transfer' sağlanmamıştır.
            // 'OtherContract' kodu bilindiğinden ve fallback fonksiyonuna sahip olduğundan,
            // address(otherContract) 'address payable' tipine sahiptir.
            address(otherContract).transfer(1 ether);

            // 'unknownContract.transfer' sağlanmadı.
            // 'address(unknownContract).transfer',
            // 'address(unknownContract)' 'address payable' olmadığı için sağlanmamıştır.
            // Fonksiyon para göndermek istediğiniz bir 'address' alırsa,
            // bunu 'uint160' aracılığıyla 'address payable'a dönüştürebilirsiniz.
            // Not: Bu tavsiye edilmez ve mümkün olduğunda açık
            // 'address payable' türü kullanılmalıdır.
            // Anlaşılabilirliği artırmak için, dönüşüm işleminde bir
            // kütüphane kullanılmasını öneriyoruz (bu örnekte sözleşmeden sonra verilmiştir).
            address payable addr = unknownContract.makePayable();
            require(addr.send(1 ether));

            // uint32 (4 bayt), bytes8'den (8 bayt) daha küçük
            // olduğu için dönüştürmeye izin verilmez.
            // Önce ortak bir boyuta dönüştürmemiz gerekiyor:
            bytes4 x4 = bytes4(x); // Dolgu sağ tarafta gerçekleşir
            uint32 y = uint32(x4); // Dönüşüm tutarlıdır
            // 'msg.value' bir 'non-payable' fonksiyonunda kullanılamaz.
            // Fonksiyonu ödenebilir hale getirmemiz gerekiyor
            myNumber += y + msg.value;
        }
    }

    // Geçici bir çözüm olarak ``address`` i açıkça
    // ``address payable`` a dönüştürmek için bir kütüphane tanımlayabiliriz.
    library AddressMakePayable {
        function makePayable(address x) internal pure returns (address payable) {
            return address(uint160(x));
        }
    }
