.. _security_considerations:

###################################
Güvenlikle İlgili Değerlendirmeler
###################################

Genellikle öngörüldüğü gibi çalışan bir yazılım oluşturmak oldukça kolay olsa da,
kimsenin bu yazılımı **öngörülmeyen** bir şekilde kullanamayacağını kontrol etmek oldukça zordur.

Solidity'de durum daha da önemlidir çünkü akıllı sözleşmeleri tokenları ya da muhtemelen
daha değerli şeyleri yönetmek için kullanabilirsiniz. Dahası, bir akıllı sözleşme her
yürütüldüğünde herkese görünür bir şekilde gerçekleşir ve buna ek olarak kaynak kodu
da genellikle erişilebilirdir.

Elbette her zaman ne kadar tehlikede olduğunu göz önünde bulundurmanız gerekir: Bir
akıllı sözleşmeyi halka (ve dolayısıyla kötü niyetli kişilere) açık ve hatta belki
de açık kaynaklı bir web hizmeti ile karşılaştırabilirsiniz. Bu web hizmetinde yalnızca
alışveriş listenizi saklıyorsanız, çok fazla dikkat etmeniz gerekmeyebilir, ancak banka
hesabınızı bu web hizmetini kullanarak yönetiyorsanız, daha dikkatli olmalısınız.

Bu bölüm bazı tuzakları ve genel güvenlik önerilerini listeleyecektir, ancak elbette
asla eksiksiz olamaz.  Ayrıca, akıllı sözleşme kodunuz hatasız olsa bile derleyicide
ya da platformun kendisinde bir hata bulunabileceğini unutmayın. Derleyicinin herkes tarafından
bilinen güvenlikle ilgili bazı hatalarının bir listesi, makine tarafından da okunabilen
:ref: `bilinen hataların listesi<known_bugs>` bölümünde bulunabilir. Solidity derleyicisinin
kod oluşturucusunu kapsayan bir hata ödül programı olduğunu unutmayın.

Her zaman olduğu gibi, açık kaynak belgelerinde, lütfen bu bölümü genişletmemize
yardımcı olun (özellikle, bazı örneklerin hiç kimseye zararı dokunmaz)!

NOT: Aşağıdaki listeye ek olarak, `Guy Lando'nun bilgi listesinde <https://github.com/guylando/KnowledgeLists/blob/master/EthereumSmartContracts.md>`_
ve `Consensys GitHub reposunda <https://consensys.github.io/smart-contract-best-practices/>`_ daha fazla güvenlik önerisi ve en iyi uygulamaları bulabilirsiniz.

********
Tuzaklar
********

Özel(Private) Bilgiler ve Rastgelelik
======================================

Bir akıllı sözleşmede kullandığınız her şey, yerel değişkenler ve ``private`` olarak
işaretlenmiş durum değişkenleri de dahil olmak üzere herkes tarafından görülebilir.

Madencilerin hile yapabilmesini istemiyorsanız, akıllı sözleşmelerde rastgele sayılar
kullanmak oldukça zordur.

Yeniden Giriş (Re-Entrancy)
===========================

Bir sözleşmeden (A) başka bir sözleşmeye (B) herhangi bir etkileşim ve herhangi
bir Ether transferi, kontrolü o sözleşmeye (B) devreder. Bu, B'nin bu etkileşim
tamamlanmadan önce A'yı geri çağırmasını mümkün kılar. Bir örnek vermek gerekirse,
aşağıdaki kod bir hata içermektedir (bu sadece bir kod parçacığıdır ve tam bir sözleşme değildir):

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    // BU SÖZLEŞME BUG İÇERİR: KULLANMAYIN
    contract Fund {
        /// @dev Sözleşmenin ether paylarının eşleştirilmesi.
        mapping(address => uint) shares;
        /// Payınızı geri çekin.
        function withdraw() public {
            if (payable(msg.sender).send(shares[msg.sender]))
                shares[msg.sender] = 0;
        }
    }

Burada sorun, ``send``in bir parçası olarak sınırlı gas miktarı nedeniyle çok ciddi
değildir, ancak yine de bir zafiyet ortaya çıkarmaktadır: Ether transferi her zaman
kod yürütmeyi içerebilir, bu nedenle alıcı ``withdraw``a geri çağıran bir sözleşme
olabilir. Bu, birden fazla geri ödeme almasına ve temelde sözleşmedeki tüm Ether'i geri
almasına izin verecektir. Özellikle, aşağıdaki sözleşme, varsayılan olarak kalan tüm
gazı ileten ``call`` kullandığı için bir saldırganın birden fazla kez geri ödeme
yapmasına izin verecektir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.2 <0.9.0;

    // BU SÖZLEŞME BUG İÇERİR: KULLANMAYIN
    contract Fund {
        /// @dev Sözleşmenin ether paylarının eşleştirilmesi.
        mapping(address => uint) shares;
        /// Payınızı geri çekin.
        function withdraw() public {
            (bool success,) = msg.sender.call{value: shares[msg.sender]}("");
            if (success)
                shares[msg.sender] = 0;
        }
    }

Yeniden Giriş'den(Re-entrancy) kaçınmak için, aşağıda daha ayrıntılı olarak açıklandığı gibi
Checks-Effects-Interactions kalıbını kullanabilirsiniz:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Fund {
        /// @dev Sözleşmenin ether paylarının eşleştirilmesi.
        mapping(address => uint) shares;
        /// Payınızı geri çekin.
        function withdraw() public {
            uint share = shares[msg.sender];
            shares[msg.sender] = 0;
            payable(msg.sender).transfer(share);
        }
    }

Yeniden girişin yalnızca Ether aktarımının değil, başka bir sözleşmedeki herhangi
bir fonksiyon çağrısının da bir etkisi olduğunu unutmayın. Ayrıca, çoklu sözleşme
içeren durumları da hesaba katmanız gerekmektedir. Çağrılan bir sözleşme, bağımlı
olduğunuz başka bir sözleşmenin yapısını değiştirebilir.

Gas Limiti ve Döngüler
=======================

Sabit sayıda iterasyona sahip olmayan döngüler, örneğin depolama değerine bağlı döngüler,
dikkatli bir şekilde kullanılmalıdır: Blok gas limiti nedeniyle, işlemler yalnızca belirli
bir miktarda gas tüketebilir. Ya açıkça ya da sadece normal çalışma nedeniyle, bir döngüdeki
yineleme sayısı blok gas limitinin ötesine geçebilir ve bu da tüm sözleşmenin belirli bir
noktada durmasına neden olabilir. Bu durum, yalnızca blok zincirinden veri okumak için
çalıştırılan ``view`` fonksiyonları için geçerli olmayabilir. Yine de, bu tür fonksiyonlar
zincir üzerindeki işlemlerin bir parçası olarak diğer sözleşmeler tarafından çağrılabilir
ve bunları durdurabilir. Lütfen sözleşmelerinizin dokümantasyonunda bu tür durumlar hakkında
açıkça bilgi verin.


Ether Gönderme ve Alma
===========================

- Ne sözleşmeler ne de "harici hesaplar" şu anda birinin onlara Ether göndermesini
  engelleyememektedir. Sözleşmeler normal bir transfere yanıt verebilir ve reddedebilir,
  ancak bir mesaj çağrısı oluşturmadan Ether'i taşımanın yolları vardır. Bir yol basitçe
  sözleşme adresine "mine to" yapmak, ikinci yol ise ``selfdestruct(x)`` kullanmaktır.

- Bir sözleşme Ether alırsa (bir fonksiyon çağrılmadan), ya :ref:`receive Ether <receive-ether-function>`
  ya da :ref:`fallback <fallback-function>` fonksiyonu çalıştırılır. Eğer bir receive ya da fallback fonksiyonu
  yoksa, Ether reddedilir (bir istisna gönderilerek). Bu fonksiyonlardan birinin yürütülmesi sırasında, sözleşme
  yalnızca o anda kendisine aktarılan "gas stipend "in (2300 gas) kullanılabilir olmasına güvenebilir. Ancak
  bu miktarı depolamayı değiştirmek için yeterli değildir (bunu kesin olarak kabul etmeyin, gelecekteki hard
  fork'larla miktar değişebilir). Sözleşmenizin bu şekilde Ether alabileceğinden emin olmak için, receive ve
  fallback fonksiyonlarının gas gereksinimlerini kontrol etmeyi unutmayın (örneğin Remix'teki "ayrıntılar" bölümünde).

- Daha fazla gas'ı ``addr.call{value: x}("")`` kullanarak alıcı sözleşmeye iletmenin
  bir yolu vardır. Bu aslında ``addr.transfer(x)`` ile aynıdır, sadece kalan tüm gas
  miktarını iletir ve alıcının daha pahalı eylemler gerçekleştirmesine olanak sağlar
  (ve hatayı otomatik olarak iletmek yerine bir hata kodu döndürür). Bu, gönderici
  sözleşmeyi geri çağırmayı veya aklınıza gelmemiş olabilecek diğer durum değişikliklerini
  içerebilir. Dolayısıyla güvenilir kullanıcılar için olduğu kadar kötü niyetli kullanıcılar
  için de büyük esneklik sağlar.

- Wei miktarını temsil etmek için mümkün olan en kesin birimleri kullanın, çünkü
  kesinlik eksikliği nedeniyle yuvarlanan her şeyi kaybedersiniz.

- Eğer ``address.transfer`` kullanarak Ether göndermek istiyorsanız, dikkat etmeniz gereken bazı detaylar var:

  1. Alıcı bir sözleşme ise, alıcı veya fallback fonksiyonunun yürütülmesine neden
     olur ve bu da gönderen sözleşmeyi geri çağırabilir.
  2. Ether gönderimi, çağrı derinliğinin 1024'ün üzerine çıkması nedeniyle başarısız
     olabilir. Çağrı derinliği tamamen çağıranın kontrolünde olduğundan, aktarımı
     başarısız olmaya zorlayabilirler; bu olasılığı göz önünde bulundurun veya ``send``
     kullanın ve dönüş değerini her zaman kontrol ettiğinizden emin olun. Daha da iyisi,
     sözleşmenizi alıcının Ether çekebileceği bir model kullanarak yazın.
  3. Ether göndermek, alıcı sözleşmenin yürütülmesi için tahsis edilen gas miktarından
     daha fazlası gerektiği için de başarısız olabilir (açıkça :ref:`require <assert-and-require>`,
     :ref:`assert <assert-and-require>`, :ref:`revert <assert-and-require>` kullanarak veya
     işlem çok pahalı olduğu için) - "gas biter" (OOG).  Dönüş değeri kontrolü ile ``transfer``
     veya ``send`` kullanırsanız, bu, alıcının gönderim sözleşmesindeki ilerlemeyi
     engellemesi için bir yöntem sağlayabilir. Burada da en iyi uygulama "send" pattern
     yerine bir :ref:`"withdraw" pattern <withdrawal_pattern>` kullanmaktır.

Çağrı Yığını Derinliği
=======================

External fonksiyon çağrıları, 1024 olan maksimum çağrı yığını boyutu sınırını aştıkları
için her an başarısız olabilirler. Bu gibi durumlarda Solidity bir istisna gönderir.
Kötü niyetli kişiler, sözleşmenizle etkileşime girmeden önce çağrı yığınını yüksek bir
değere zorlayabilir. Tangerine Whistle <https://eips.ethereum.org/EIPS/eip-608>`_ hardfork
olduğundan, `63/64 kuralı <https://eips.ethereum.org/EIPS/eip-150>`_ çağrı yığını derinliği
saldırısını kullanışsız hale getirir. Ayrıca, her ikisinin de 1024 yığın yuvası boyut
sınırına sahip olmasına rağmen, çağrı yığını ve ifade yığınının birbiriyle alakasız olduğunu unutmayın.

Eğer çağrı yığını tükenirse ``.send()`` fonksiyonunun **bir istisna göndermediğini**,
bu durumda ``false`` döndürdüğünü unutmayın. Düşük seviyeli fonksiyonlar ``.call()``,
``.delegatecall()`` ve ``.staticcall()`` da aynı şekilde davranırlar.


Yetkilendirilmiş Proxyler (Authorized Proxies)
===============================================

Sözleşmeniz bir proxy olarak hareket edebiliyorsa, yani kullanıcı tarafından
sağlanan verilerle rastgele sözleşmeleri çağırabiliyorsa, kullanıcı esasen proxy
sözleşmesinin kimliğini üstlenebilir. Başka koruyucu önlemleriniz olsa bile, sözleşme
sisteminizi proxy'nin herhangi bir izne sahip olmayacağı şekilde (kendisi için bile)
oluşturmak en iyisidir. Gerekirse bunu ikinci bir proxy kullanarak gerçekleştirebilirsiniz:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;
    contract ProxyWithMoreFunctionality {
        PermissionlessProxy proxy;

        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return proxy.callOther(addr, payload);
        }
        // Diğer fonksiyonlar ve diğer fonksiyonellikler
    }

    // Bu tam sözleşmedir, başka hiçbir fonksiyonu yoktur ve çalışması
    // için hiçbir ayrıcalık gerektirmez.
    contract PermissionlessProxy {
        function callOther(address addr, bytes memory payload) public
                returns (bool, bytes memory) {
            return addr.call(payload);
        }
    }

tx.origin
=========

Doğrulama için asla tx.origin kullanmayın. Diyelim ki şöyle bir cüzdan sözleşmeniz var:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    // BU SÖZLEŞME BUG İÇERİR : KULLANMAYIN
    contract TxUserWallet {
        address owner;

        constructor() {
            owner = msg.sender;
        }

        function transferTo(address payable dest, uint amount) public {
            // BUG burada, tx.origin yerine msg.sender kullanın
            require(tx.origin == owner);
            dest.transfer(amount);
        }
    }

Şimdi birisi sizi bu saldırı cüzdanının adresine Ether göndermeniz için kandırıyor:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    interface TxUserWallet {
        function transferTo(address payable dest, uint amount) external;
    }

    contract TxAttackWallet {
        address payable owner;

        constructor() {
            owner = payable(msg.sender);
        }

        receive() external payable {
            TxUserWallet(msg.sender).transferTo(owner, msg.sender.balance);
        }
    }

Cüzdanınız doğrulama için ``msg.sender`` adresini kontrol etseydi, sahibinin adresi
yerine saldırı cüzdanının adresini alırdı. Ancak ``tx.origin`` adresini kontrol ederek,
işlemi başlatan orijinal adresi, yani hala sahibinin adresini alır. Saldırgan cüzdan
anında tüm paranızı çeker.

.. _underflow-overflow:

Two's Complement / Underflows / Overflows
=========================================

Birçok programlama dilinde olduğu gibi, Solidity'nin integer türleri aslında tam
sayı değildir. Değerler küçük olduğunda tamsayılara benzerler, ancak keyfi olarak
büyük sayıları temsil edemezler.

Aşağıdaki kod bir taşmaya neden olur çünkü toplama işleminin sonucu ``uint8`` tipinde
saklanamayacak kadar büyüktür:

.. code-block:: solidity

  uint8 x = 255;
  uint8 y = 1;
  return x + y;

Solidity'nin bu taşmaları ele aldığı iki modu bulunmaktadır: Kontrollü ve Kontrolsüz veya "wrapping" modu.

Varsayılan kontrollü mod, taşmaları tespit eder ve başarısız bir doğrulamaya neden olur.
Bu kontrolü ``unchecked { ... }``  kullanarak bu kontrolü devre dışı bırakabilir ve
taşmanın sessizce göz ardı edilmesine neden olabilirsiniz. Yukarıdaki kod ``unchecked { … }``
içine sarılmış olsaydı ``0`` döndürürdü. .

Kontrollü modda bile, taşma hatalarından korunduğunuzu sanmayın. Bu modda, taşmalar her
zaman geri döndürülecektir. Eğer taşmadan kaçınmak mümkün değilse, bu durum akıllı sözleşmenin
belirli bir durumda takılı kalmasına neden olabilir.

Genel olarak, işaretli sayılar için bazı daha özel uç durumlara sahip olan ikiye tamamlayan sayı
gösteriminin sınırları hakkında bilgi edinmelisiniz.

Girdilerin boyutunu makul bir aralıkla sınırlamak için ``require`` kullanmayı deneyin ve olası
taşmaları bulmak için :ref:`SMT checker<smt_checker>` kullanın.

.. _clearing-mappings:

Mappingleri Temizleme
======================

Yalnızca depolama amaçlı bir anahtar-değer veri yapısı olan Solidity tipi ``mapping``
(bkz. :ref:`mapping-types`), sıfır olmayan bir değer atanmış anahtarların kaydını tutmaz.
Bu nedenle, yazılan anahtarlar hakkında ekstra bilgi olmadan bir mapping'i temizlemek mümkün
değildir. Bir dinamik depolama dizisinin temel türü olarak bir ``mapping`` kullanılıyorsa,
dizinin silinmesi veya boşaltılmasının ``mapping`` elemanları üzerinde hiçbir etkisi olmayacaktır.
Aynı durum, örneğin, bir dinamik depolama dizisinin temel türü olan bir ``struct``ın eleman
türünün bir ``mapping`` olması durumunda da geçerlidir.  Bir ``mapping`` içeren struct veya
dizilerin atamalarında da ``mapping`` göz ardı edilir.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    contract Map {
        mapping (uint => uint)[] array;

        function allocate(uint newMaps) public {
            for (uint i = 0; i < newMaps; i++)
                array.push();
        }

        function writeMap(uint map, uint key, uint value) public {
            array[map][key] = value;
        }

        function readMap(uint map, uint key) public view returns (uint) {
            return array[map][key];
        }

        function eraseMaps() public {
            delete array;
        }
    }

Yukarıdaki örneği ve aşağıdaki çağrı dizisini göz önünde bulundurun: ``allocate(10)``,
``writeMap(4, 128, 256)``. Bu noktada, ``readMap(4, 128)`` çağrısı 256 değerini döndürür.
Eğer ``eraseMaps`` çağrısı yaparsak, ``array`` durum değişkeninin uzunluğu sıfırlanır,
ancak ``mapping`` elemanları sıfırlanamadığından, bilgileri sözleşmenin deposunda canlı
kalır. Diziyi sildikten sonra, ``allocate(5)`` çağrısı ``array[4]`` öğesine tekrar erişmemizi
sağlar ve ``readMap(4, 128)`` çağrısı, başka bir ``writeMap`` çağrısı olmadan bile 256 döndürür.

Eğer ``mapping`` bilgilerinizin silinmesi gerekiyorsa, ``iterable mapping <https://github.com/ethereum/dapp-bin/blob/master/library/iterable_mapping.sol>`_
benzeri bir kütüphane kullanmayı düşünün, bu sayede anahtarlar arasında gezinebilir ve uygun
``mapping`` içindeki değerleri silebilirsiniz.


Küçük Detaylar
===============

- Tam 32 baytı kaplamayan türler "kirli yüksek dereceli bitler" içerebilir. Bu durum
  özellikle ``msg.data`` türüne eriştiğinizde önemlidir - bu bir değiştirilebilirlik
  riski oluşturur: Bir ``f(uint8 x)`` fonksiyonunu ``0xff000001`` ve ``0x00000001`` ham
  bayt argümanı ile çağıran işlemler oluşturabilirsiniz. Her ikisi de sözleşmeye gönderilir
  ve ``x`` söz konusu olduğunda her ikisi de ``1`` sayısı gibi görünecektir, ancak ``msg.data``
  farklı olacaktır, bu nedenle herhangi bir şey için ``keccak256(msg.data)`` kullanırsanız,
  farklı sonuçlar elde edersiniz.


***************
Öneriler
***************

Uyarıları Ciddiye Alın
=======================

Derleyici sizi bir konuda uyarıyorsa, bunu değiştirmelisiniz. Bu uyarının güvenlikle
ilgili olduğunu düşünmeseniz bile, altında başka bir sorun yatıyor olabilir. Verdiğimiz
herhangi bir derleyici uyarısı, kodda yapılacak küçük değişikliklerle giderilebilir.

Yeni eklenen tüm uyarılardan haberdar olmak için her zaman derleyicinin en son sürümünü
kullanın.

Derleyici tarafından verilen ``info`` türündeki mesajlar tehlikeli değildir ve sadece
derleyicinin kullanıcı için yararlı olabileceğini düşündüğü ekstra önerileri ve isteğe
bağlı bilgileri temsil eder.


Ether Miktarını Kısıtlayın
============================

Akıllı bir sözleşmede saklanabilecek Ether (veya diğer tokenler) miktarını kısıtlayın.
Kaynak kodunuzda, derleyicide veya platformda bir hata varsa, bu fonlar kaybolabilir.
Kaybınızı sınırlamak istiyorsanız, Ether miktarını sınırlayın.

Küçük ve Modüler Tutun
=========================

Sözleşmelerinizi küçük ve kolayca anlaşılabilir tutun. Diğer sözleşmelerdeki veya
kütüphanelerdeki ilgisiz fonksiyonları ayırın. Kaynak kod kalitesiyle ilgili genel
tavsiyeler elbette geçerlidir: Yerel değişkenlerin miktarını, fonksiyonların uzunluğunu
ve benzerlerini sınırlayın. Başkalarının niyetinizin ne olduğunu ve kodun yapıldığından
farklı olup olmadığını görebilmesi için fonksiyonlarınızı belgeleyin.

Kontroller-Etkiler-Etkileşimler Modelini Kullanın
===================================================

Çoğu fonksiyon önce bazı kontroller yapacaktır (fonksiyonu kim çağırdı, argümanlar
aralıkta mı, yeterince Ether gönderdiler mi, kişinin tokenleri var mı, vb.) Bu kontroller önce yapılmalıdır.

İkinci adım olarak, tüm kontroller geçerse, mevcut sözleşmenin durum değişkenlerine
etkiler yapılmalıdır. Diğer sözleşmelerle etkileşim herhangi bir fonksiyonda en son adım olmalıdır.

İlk sözleşmeler bazı etkileri geciktirir ve harici fonksiyon çağrılarının hatasız
bir durumda dönmesini beklerdi. Bu, yukarıda açıklanan yeniden giriş sorunu nedeniyle genellikle ciddi bir hatadır.

Ayrıca, bilinen sözleşmelere yapılan çağrıların da bilinmeyen sözleşmelere çağrı
yapılmasına neden olabileceğini unutmayın, bu nedenle bu kalıbı her zaman uygulamak her zaman daha iyidir.


Arızaya Karşı Güvenli Mod Ekleyin
==================================

Sisteminizi tamamen merkeziyetsiz hale getirmek herhangi bir aracıyı ortadan kaldıracak
olsa da, özellikle yeni kodlar için bir tür arıza güvenliği mekanizması eklemek iyi bir fikir olabilir:

Akıllı sözleşmenize "Herhangi bir Ether sızdı mı?", "Tokenların toplamı sözleşmenin
bakiyesine eşit mi?" gibi kendi kendine kontroller gerçekleştiren bir fonksiyon ekleyebilirsiniz.
Bunun için çok fazla gaz kullanamayacağınızı unutmayın, bu nedenle zincir dışı hesaplamalar yoluyla yardım gerekebilir.

Kendi kendine kontrol başarısız olursa, sözleşme otomatik olarak bir tür "arıza emniyetli"
moda geçer; örneğin, özelliklerin çoğunu devre dışı bırakır, kontrolü sabit ve güvenilir
bir üçüncü tarafa devreder veya sözleşmeyi basit bir "paramı geri ver" sözleşmesine dönüştürür.

Peer İncelemesi İsteyin
========================

Bir kod parçası ne kadar çok kişi tarafından incelenirse, o kadar çok sorun bulunur.
İnsanlardan kodunuzu incelemelerini istemek, kodunuzun kolay anlaşılır olup olmadığını
anlamak için bir çapraz kontrol olarak da yardımcı olur - iyi akıllı sözleşmeler için çok önemli bir kriterdir.
