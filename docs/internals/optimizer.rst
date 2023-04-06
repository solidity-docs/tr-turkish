.. index:: optimizer, optimiser, common subexpression elimination, constant propagation
.. _optimizer:

****************
Optimize Edici
****************

Solidity derleyicisi iki farklı optimize edici modül kullanır: İşlem kodu düzeyinde çalışan "eski"
iyileştirici ve Yul IR kodunda çalışan "yeni" iyileştirici.

İşlem kodu tabanlı optimize edici, işlem kodlarına bir dizi `basitleştirme kuralı <https://github.com/ethereum/ solidity/
blob/develop/libevmasm/RuleList.h>`_ uygular. Ayrıca eşit kod kümelerini birleştirir ve kullanılmayan kodu kaldırır.

Yul tabanlı optimize edici, fonksiyon çağrıları arasında çalışabildiği için çok daha güçlüdür.
Örneğin, Yul'da arbitrary jumps yapmak mümkün değildir, bu nedenle her bir fonksiyonun yan etkilerini
hesaplamak mümkündür. İlkinin depolamayı değiştirmediği ve ikincisinin depolamayı değiştirdiği iki fonksiyon çağrısını düşünün.
Argümanları ve dönüş değerleri birbirine bağlı değilse, fonksiyon çağrılarını yeniden sıralayabiliriz. Benzer
şekilde, bir fonksiyon yan etkiden arındırılmışsa ve sonucu sıfırla çarpılırsa, fonksiyon çağrısını tamamen
kaldırabilirsiniz.

Şu anda, "--optimize" parametresi, oluşturulan bayt kodu için işlem kodu tabanlı iyileştiriciyi ve dahili
olarak Yul kodu için oluşturulan Yul iyileştiriciyi, örneğin ABI kodlayıcı v2'yi etkinleştirir.
Bir Solidity kaynağına özel olarak optimize edilmiş bir Yul IR üretmek için ``solc --ir-optimized --optimize`` kullanılabilir.
Benzer şekilde, bağımsız bir Yul modu için ``solc --strict-assembly --optimize`` kullanılabilir.

Aşağıda hem optimize edici modüller hem de optimizasyon adımları hakkında daha fazla ayrıntı bulabilirsiniz.

Solidity Kodunu Optimize Etmenin Faydaları
============================================

Genel olarak optimize ediciler, karmaşık ifadeleri sadeleştirmeye çalışır, bu da hem kod boyutunu hem de
çalıştırma(execution) maliyetini azaltır, yani sözleşmenin devreye alınmasını ve sözleşmeye yapılan harici çağrılar için gereken
gas miktarını azaltabilir.
Ayrıca, fonksiyonları uzmanlaştırır veya sıralar. Özellikle satır içi fonksiyonları oluşturma,
çok daha büyük kodlara neden olabilecek bir işlemdir, ancak daha fazla sadeleştirme fırsatlarına yol açtığı için sıklıkla yapılır.


Optimize Edilmiş ve Optimize Edilmemiş Kod Arasındaki Farklar
==============================================================

Genel olarak ikisi arasındaki en görünür fark, sabit ifadelerin derleme zamanındaki farklılıklardır.
ASM çıktısı söz konusu olduğunda, eşdeğer veya yinelenen kod bloklarındaki gas miktarında azalma da fark edilebilir (``--asm`` ve
``--asm --optimize`` işaretlerinin çıktısını karşılaştırın). Bununla birlikte, Yul/intermediate-representation söz konusu olduğunda,
önemli farklılıklar olabilir, örneğin, fonksiyonlar satır içine alınabilir, birleştirilebilir veya fazlalıkları ortadan kaldırmak
için yeniden yazılabilir, vb. (çıktıyı ``--ir`` ve ``--optimize --ir-optimized`` işaretleri ile birlikte karşılaştırabilirsiniz ).

.. _optimizer-parameter-runs:

Optimize Edici Parametre Çalıştırmaları
========================================

Çalıştırma sayısı ("--optimize-runs"), dağıtılan kodun her bir işlem kodunun sözleşmenin ömrü boyunca
yaklaşık olarak ne sıklıkta yürütüleceğini belirtir. Bu, kod boyutu (dağıtım maliyeti) ve kod yürütme
maliyeti (dağıtımdan sonraki maliyet) arasında bir değiş tokuş parametresi olduğu anlamına gelir.
"1" "runs" parametresi kısa ama pahalı olan bir kod üretecektir. Buna karşılık, daha büyük bir "runs"
parametresi daha uzun ancak daha fazla gaz verimli kod üretecektir. Parametrenin maksimum değeri
``2**32-1`` dir.

.. note::

    Yaygın bir yanlış anlama ise bu parametrenin optimize edicinin yineleme sayısını belirtmesidir.
    Ancak bu doğru değildir: Optimize edici her zaman kodu iyileştirebildiği kadar çalışır.

Opcode Tabanlı Optimize Edici Modülü
======================================

Opcode tabanlı optimize edici modül, assembly kodu üzerinde çalışır.
Komut dizisini "JUMPs" ve "JUMPDESTs"de temel bloklara böler.
Bu blokların içinde, optimize edici talimatları analiz eder ve yığında,
bellekte veya depolamada yapılan her değişikliği, bir talimattan ve diğer
ifadelere işaret eden bir argüman listesinden oluşan bir ifade olarak kaydeder.

Ek olarak, işlem kodu tabanlı optimize edici, diğer görevlerin yanı sıra (her girişte)
her zaman eşit olan ifadeleri bulan ve bunları bir ifade sınıfında
birleştiren "CommonSubexpressionEliminator" adlı bir bileşen kullanır. İlk önce her yeni ifadeyi
önceden bilinen ifadeler listesinde bulmaya çalışır. Böyle bir eşleşme bulunamazsa, ifadeyi
``constant + constant = sum_of_constants`` veya ``X * 1 = X`` gibi kurallara göre sadeleştirir.
Bu recursive(öz yinelemeli) bir süreç olduğundan, ikinci faktör her zaman bir olarak
değerlendirdiğini bildiğimiz daha karmaşık bir ifadeyse, ikinci kuralı da uygulayabiliriz.

Belirli optimize edici adımları, depolama ve bellek konumlarını sembolik olarak izler. Örneğin bu bilgi, derleme
sırasında değerlendirilebilecek Keccak-256 hashlerini hesaplamak için kullanılır.
Bu sıralamayı düşünebilirsiniz:

.. code-block:: none

    PUSH 32
    PUSH 0
    CALLDATALOAD
    PUSH 100
    DUP2
    MSTORE
    KECCAK256

veya eşdeğeri Yul

.. code-block:: yul

    let x := calldataload(0)
    mstore(x, 100)
    let value := keccak256(x, 32)

Bu durumda, optimize edici ``calldataload(0)`` bellek konumundaki değeri izler ve ardından Keccak-256
hash değerinin derleme zamanında değerlendirilebileceğini anlar. Bu, yalnızca ``mstore`` ve ``keccak256`` arasındaki
belleği değiştiren başka bir komut yoksa çalışır.  Yani belleğe (veya depolamaya) bilgi yazan bir talimat varsa, o zaman
mevcut bilginin bellek (veya depolama) bilgisini silmemiz gerekir. Ancak, talimatın belirli bir yere yazmadığını kolayca
görebildiğimizde, bu silme işleminin bir istisnası vardır.

Örneğin,

.. code-block:: yul

    let x := calldataload(0)
    mstore(x, 100)
    // Mevcut bilgi hafıza konumu x -> 100
    let y := add(x, 32)
    // y'nin [x, x + 32)'ye bilgi yazmaması nedeniyle x -> 100 olduğu bilgisi silinmez
    mstore(y, 200)
    // Bu Keccak-256 artık değerlendirilebilir
    let value := keccak256(x, 32)

Bu nedenle, depolama ve bellek konumlarında, örneğin ``l`` konumunda yapılan değişiklikler, ``l``ye eşit
olabilecek depolama veya bellek konumları hakkındaki bilgileri silmelidir. Daha spesifik olarak, depolama için,
optimize edicinin ``l``ye eşit olabilecek tüm sembolik konum bilgilerini silmesi gerekir ve bellek için optimize edicinin
en az 32 bayt uzakta olmayabilecek tüm sembolik konum bilgilerini silmesi gerekir. . Eğer ``m`` arbitarry lokasyonu gösteriyorsa,
o zaman bu silme kararı ``sub(l, m)`` değeri hesaplanarak yapılır. Depolama için, bu değer sıfırdan farklı bir hazır bilgi
olarak değerlendirilirse, o zaman ``m`` ile ilgili bilgi tutulacaktır. Bellek için, değer ``32`` ile ``2**256 - 32`` arasında bir
değer olarak değerlendirilirse, ``m`` ile ilgili bilgi korunur. Diğer tüm durumlarda, ``m`` hakkındaki bilgiler silinecektir.

Bu işlemden sonra, sonunda yığında(stack) hangi ifadelerin olması gerektiğini biliyoruz ve bellek
ve depolamada yapılan değişikliklerin bir listesine sahibiz. Bu bilgi, temel bloklarla birlikte saklanır
ve bunları birbirine bağlamak için kullanılır. Ayrıca yığın, depolama ve bellek yapılandırması
hakkındaki bilgiler sonraki bloğa/bloklara iletilir.

Tüm ``JUMP`` ve ``JUMPI`` komutlarının hedeflerini biliyorsak, programın tam
bir kontrol akış grafiğini oluşturabiliriz. Bilmediğimiz tek bir hedef varsa (bu prensipte
olduğu gibi olabilir, jump targets girdilerden hesaplanabilir), bilinmeyen ``JUMP`` değerinin hedefi
olabileceğinden bir bloğun girdi durumu hakkındaki tüm bilgileri silmemiz gerekir. İşlem kodu
tabanlı optimize edici modül, koşulu bir sabite göre değerlendirilen bir ``JUMPI`` bulursa,
bunu koşulsuz bir jump`a dönüştürür.

Son adım olarak, her bloktaki kod yeniden oluşturulur. Optimize edici, bloğun sonunda bulunan
yığındaki ifadelerden bir bağımlılık grafiği oluşturur ve bu grafiğin parçası olmayan her işlemi
bırakır. Değişiklikleri orijinal kodda yapıldıkları sırayla belleğe(memory) ve depolamaya(storage) uygulayan kod üretir
(gerekli olmadığı tespit edilen değişiklikleri bırakarak). Son olarak yığında olması gereken tüm
değerleri doğru yerde üretir.

Bu adımlar her temel bloğa uygulanır ve yeni oluşturulan kod daha küçükse yedek olarak
kullanılır. Temel bir blok bir ``JUMPI``'de bölünürse ve analiz sırasında koşul bir sabit olarak
değerlendirilirse, ``JUMPI`` sabitin değerine göre değiştirilir. Aşağıda bulunan kodda olduğu gibi

.. code-block:: solidity

    uint x = 7;
    data[7] = 9;
    if (data[x] != x + 2) // bu koşul asla doğru değildir
      return 2;
    else
      return 1;

bunu sadeleştirir:

.. code-block:: solidity

    data[7] = 9;
    return 1;

Basit Inlining
---------------

Solidity 0.8.2 sürümünden bu yana, “jump" ile biten “simple" talimatları
içeren bloklara yapılan belirli atlamaları bu talimatların bir kopyası
ile değiştiren başka bir optimizer adımı bulunmaktadır. Bu, basit, küçük
Solidity veya Yul fonksiyonlarının inlining'ine karşılık gelir. Özellikle,
``PUSHTAG(tag) JUMP`` dizisi, ``JUMP`` bir fonksiyona atlama olarak işaretlendiğinde
ve ``tag`` arkasında bir fonksiyondan "dışarı" atlama olarak işaretlenen başka
bir ``JUMP`` ile biten temel bir blok ("CommonSubexpressionEliminator" için yukarıda
açıklandığı gibi) olduğunda değiştirilebilir.

Özellikle, dahili bir Solidity fonksiyonuna yapılan bir çağrı için oluşturulan
aşağıdaki prototip assembly örneğini göz önünde bulundurun:

.. code-block:: text

      tag_return
      tag_f
      jump      // içeri
    tag_return:
      ...opcodes after call to f...

    tag_f:
      ...body of function f...
      jump      // dışarı

Fonksiyonun gövdesi sürekli bir temel blok olduğu sürece, "Inliner" ``tag_f jump``
yerine ``tag_f`` adresindeki blokla değiştirebilir ve sonuç olarak:

.. code-block:: text

      tag_return
      ...body of function f...
      jump
    tag_return:
      ...opcodes after call to f...

    tag_f:
      ...body of function f...
      jump      // out

Şimdi ideal olarak, yukarıda açıklanan diğer optimize edici adımlar, return
etiketi push'unun kalan jump'a doğru hareket ettirilmesiyle sonuçlanacaktır:

.. code-block:: text

      ...body of function f...
      tag_return
      jump
    tag_return:
      ...opcodes after call to f...

    tag_f:
      ...body of function f...
      jump      // out

Bu durumda "PeepholeOptimizer" return jump'ı kaldıracaktır. İdeal olarak,
tüm bunlar ``tag_f``'ye yapılan tüm referanslar için yapılabilir, kullanılmadan
bırakılabilir, s.t. kaldırılabilir, sonuç verir:

.. code-block:: text

    ...body of function f...
    ...opcodes after call to f...

Böylece ``f`` fonksiyonuna yapılan çağrı satır içine alınır ve ``f`` fonksiyonunun orijinal tanımı kaldırılabilir.

Bir buluşsal yöntem, bir sözleşmenin ömrü boyunca inlining yapmanın inlining yapmamaktan
daha ucuz olduğunu gösterdiğinde, bu durumdaki inlining denenir. Bu sezgisel yöntem, fonksiyon
gövdesinin boyutuna, etiketine yapılan diğer referansların sayısına (fonksiyona yapılan
çağrıların sayısına yaklaşık olarak) ve sözleşmenin beklenen yürütme sayısına (global
optimizer parametresi "runs") bağlıdır.


Yul Tabanlı Optimize Edici Modülü
==================================

Yul tabanlı optimize edici, tümü AST'yi anlamsal olarak eşdeğer bir şekilde dönüştüren birkaç aşamadan ve
bileşenden oluşur. Amaç, ya daha kısa ya da en azından marjinal olarak daha uzun olan ancak daha fazla
optimizasyon adımına izin verecek bir kodla sonuçlandırmaktır.

.. warning::

    Optimize edici yoğun bir geliştirme aşamasında olduğundan, buradaki bilgiler güncel olmayabilir.
    Belirli bir fonksiyonelliğe güveniyorsanız, lütfen doğrudan ekiple iletişime geçin.

Optimize edici şu anda tamamen greedy(metinsel olarak mümkün olduğunca fazla eşleşen)
bir strateji izliyor ve herhangi bir geri izleme yapmıyor.

Yul tabanlı optimizer modülünün tüm bileşenleri aşağıda açıklanmıştır.
Aşağıdaki dönüşüm adımları ana bileşenlerdir:

- SSA Transform
- Common Subexpression Eliminator
- Expression Simplifier
- Redundant Assign Eliminator
- Full Inliner

Optimize Edici Adımları
------------------------

Bu, Yul tabanlı optimize edicinin alfabetik olarak sıralanmış tüm adımlarının
bir listesidir. Her bir adım ve bunların sıralaması hakkında daha fazla bilgiyi
aşağıda bulabilirsiniz.

- :ref:`block-flattener`.
- :ref:`circular-reference-pruner`.
- :ref:`common-subexpression-eliminator`.
- :ref:`conditional-simplifier`.
- :ref:`conditional-unsimplifier`.
- :ref:`control-flow-simplifier`.
- :ref:`dead-code-eliminator`.
- :ref:`equal-store-eliminator`.
- :ref:`equivalent-function-combiner`.
- :ref:`expression-joiner`.
- :ref:`expression-simplifier`.
- :ref:`expression-splitter`.
- :ref:`for-loop-condition-into-body`.
- :ref:`for-loop-condition-out-of-body`.
- :ref:`for-loop-init-rewriter`.
- :ref:`expression-inliner`.
- :ref:`full-inliner`.
- :ref:`function-grouper`.
- :ref:`function-hoister`.
- :ref:`function-specializer`.
- :ref:`literal-rematerialiser`.
- :ref:`load-resolver`.
- :ref:`loop-invariant-code-motion`.
- :ref:`redundant-assign-eliminator`.
- :ref:`reasoning-based-simplifier`.
- :ref:`rematerialiser`.
- :ref:`SSA-reverser`.
- :ref:`SSA-transform`.
- :ref:`structural-simplifier`.
- :ref:`unused-function-parameter-pruner`.
- :ref:`unused-pruner`.
- :ref:`var-decl-initializer`.

Optimizasyonları Seçme
-----------------------

Varsayılan olarak optimizer, oluşturulan assembly'ye önceden tanımlanmış optimizasyon
adımları dizisini uygular. Bu diziyi geçersiz kılabilir ve ``--yul-optimizations``
seçeneğini kullanarak kendi dizinizi sağlayabilirsiniz:

.. code-block:: bash

    solc --optimize --ir-optimized --yul-optimizations 'dhfoD[xarrscLMcCTU]uljmul'

``[...]`` içinde yer alan dizi, Yul kodu değişmeden kalana kadar veya maksimum tur
sayısına (şu anda 12) ulaşılana kadar bir döngü içinde birden çok kez uygulanacaktır.

Mevcut kısaltmalar :ref:`Yul optimize edici dokümanları <optimization-step-sequence>` içinde listelenmiştir.

Ön İşleme (Preprocessing)
---------------------------

Ön işleme bileşenleri, programı üzerinde çalışılması daha kolay olan belirli normal
bir forma sokmak için gerekli dönüşümleri gerçekleştirir. Bu normal formu optimizasyon
sürecinin geri kalan bölümü boyunca muhafaza eder.

.. _disambiguator:

Disambiguator
^^^^^^^^^^^^^^^^

Anlam ayrıştırıcı bir AST alır ve tüm tanımlayıcıların girdi AST'sinde benzersiz
adlara sahip olduğu yeni bir kopya döndürür. Bu, diğer tüm optimize edici aşamalar
için bir ön koşuldur. Avantajlarından biri, tanımlayıcının aranmanın kapsamları
dikkate almasına gerek kalmamasıdır, bu da diğer adımlar için gereken analizi
basitleştirir.

Sonraki tüm aşamalar, tüm isimlerin benzersiz kalması özelliğine sahiptir. Bu,
herhangi bir yeni tanımlayıcı eklenmesi gerektiğinde yeni bir benzersiz isim
üretileceği anlamına gelir.

.. _function-hoister:

FunctionHoister
^^^^^^^^^^^^^^^^^^

Fonksiyon hoister, tüm fonksiyon tanımlarını en üstte bulunan bloğun sonuna taşır. Belirsizliği giderme aşamasından sonra
gerçekleştirildiği sürece bu anlamsal olarak eşdeğer bir dönüşümdür. Bunun nedeni, bir tanımın daha yüksek seviyeli
bir bloğa taşınmasının görünürlüğünü azaltamaması ve farklı bir fonksiyonda tanımlanan değişkenlere başvurmanın
imkansız olmasıdır.

Bu aşamanın faydası, fonksiyon tanımlarının daha kolay aranabilmesi ve fonksiyonların, AST'yi tamamen
geçmek zorunda kalmadan izole bir şekilde optimize edilebilmesidir.

.. _function-grouper:

FunctionGrouper
^^^^^^^^^^^^^^^^^^

Fonksiyon grouper, Disambiguator ve FunctionHoister sonra uygulanmalıdır.
Etkisi, işlev tanımları olmayan en üstteki tüm öğelerin, kök bloğun ilk
ifadesi olan tek bir bloğa taşınmasıdır.

Bu adımdan sonra, bir program aşağıdaki normal forma sahiptir:

.. code-block:: text

    { I F... }

Burada ``I`` herhangi bir fonksiyon tanımı içermeyen (rekürsif olarak bile)
(potansiyel olarak boş) bir bloktur ve ``F`` hiçbir fonksiyonun bir fonksiyon
tanımı içermediği bir fonksiyon tanımları listesidir.

Bu aşamanın faydası, fonksiyon listesinin nerede başladığını her zaman bilmemize
olanak sağlamasıdır.

.. _for-loop-condition-into-body:

ForLoopConditionIntoBody
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bu dönüşüm, bir for döngüsünün döngü yineleme koşulunu döngü gövdesine taşır.
Bu dönüşüme ihtiyacımız var çünkü :ref:`expression-splitter` yineleme koşulu
ifadelerine (aşağıdaki örnekte ``C``) uygulanmayacaktır.

.. code-block:: text

    for { Init... } C { Post... } {
        Body...
    }

dönüştürülür

.. code-block:: text

    for { Init... } 1 { Post... } {
        if iszero(C) { break }
        Body...
    }

Bu dönüşüm aynı zamanda ``LoopInvariantCodeMotion`` ile eşleştirildiğinde de faydalı olabilir, çünkü döngüde
değişmez koşullardaki invariant'lar daha sonra döngünün dışına alınabilir.

.. _for-loop-init-rewriter:

ForLoopInitRewriter
^^^^^^^^^^^^^^^^^^^

Bu dönüşüm, bir for-döngüsünün başlatma kısmını döngüden önceki kısmına taşır:

.. code-block:: text

    for { Init... } C { Post... } {
        Body...
    }

dönüştürülür

.. code-block:: text

    Init...
    for {} C { Post... } {
        Body...
    }

Bu, döngü başlatma(genesis) bloğunun karmaşık kapsam belirleme kurallarını göz ardı
edebileceğimiz için optimizasyon sürecinin geri kalanını kolaylaştırır.

.. _var-decl-initializer:

VarDeclInitializer
^^^^^^^^^^^^^^^^^^
Bu adım, değişken tanımlamalarını yeniden yazarak hepsinin başlatılmasını sağlar.
``let x, y`` gibi tanımlamalar birden fazla tanımlama (multiple declaration) ifadesine bölünür.

Şimdilik yalnızca sıfır literali ile başlatmayı destekliyor.

Pseudo-SSA Dönüşümü
-------------------------

Bu bileşenlerin amacı programı daha uzun bir forma sokmaktır, böylece diğer
bileşenler onunla daha kolay çalışabilir. Final gösterimi statik-tek-atama
(SSA) formuna benzer olacaktır, tek farkı kontrol akışının farklı kollarından(branch)
gelen değerleri birleştiren açık "phi" fonksiyonlarını kullanmamasıdır çünkü
böyle bir özellik Yul dilinde mevcut değildir. Bunun yerine, kontrol akışı
birleştiğinde, kollardan(branch) birinde bir değişken yeniden atanırsa, mevcut
değerini tutmak için yeni bir SSA değişkeni bildirilir, böylece aşağıdaki
ifadelerin hala yalnızca SSA değişkenlerine başvurması gerekir.

Örnek bir dönüşüm aşağıda verilmiştir:

.. code-block:: yul

    {
        let a := calldataload(0)
        let b := calldataload(0x20)
        if gt(a, 0) {
            b := mul(b, 0x20)
        }
        a := add(a, 1)
        sstore(a, add(b, 0x20))
    }


Aşağıdaki tüm dönüşüm adımları uygulandığında, program aşağıdaki gibi görünecektir:

.. code-block:: yul

    {
        let _1 := 0
        let a_9 := calldataload(_1)
        let a := a_9
        let _2 := 0x20
        let b_10 := calldataload(_2)
        let b := b_10
        let _3 := 0
        let _4 := gt(a_9, _3)
        if _4
        {
            let _5 := 0x20
            let b_11 := mul(b_10, _5)
            b := b_11
        }
        let b_12 := b
        let _6 := 1
        let a_13 := add(a_9, _6)
        let _7 := 0x20
        let _8 := add(b_12, _7)
        sstore(a_13, _8)
    }

Bu kod parçasında yeniden atanan tek değişkenin ``b`` olduğuna dikkat edin.
Bu yeniden atama işleminden kaçınılamaz çünkü ``b`` kontrol akışına bağlı
olarak farklı değerlere sahiptir. Diğer tüm değişkenler tanımlandıktan sonra
değerlerini asla değiştirmezler. Bu özelliğin avantajı, bu değerler yeni
bağlamda hala geçerli olduğu sürece, değişkenlerin serbestçe hareket
ettirilebilmesi ve bunlara yapılan referansların ilk değerleriyle (ve tersiyle)
değiştirilebilmesidir.

Elbette, buradaki kod optimize edilmekten oldukça uzaktır. Aksine, çok daha
uzundur. Buradaki beklentimiz, bu kodla çalışmanın daha kolay olacağı ve ayrıca,
bu değişiklikleri geri alan ve sonunda kodu tekrar daha kompakt hale getiren
optimize edici adımların var olmasıdır.

.. _expression-splitter:

ExpressionSplitter
^^^^^^^^^^^^^^^^^^

Expression splitter(İfade Ayırıcı), ``add(mload(0x123), mul(mload(0x456), 0x20))``
gibi ifadeleri, ilgili ifadenin alt ifadelerine atanan benzersiz değişkenleri
bildiren bir diziye dönüştürür, böylece her fonksiyon çağrısında argüman olarak
yalnızca değişkenler bulunur.

Yukarıdakiler şu şekle dönüştürülebilir:

.. code-block:: yul

    {
        let _1 := 0x20
        let _2 := 0x456
        let _3 := mload(_2)
        let _4 := mul(_3, _1)
        let _5 := 0x123
        let _6 := mload(_5)
        let z := add(_6, _4)
    }

Bu dönüşümün işlem kodlarının veya fonksiyon çağrılarının sırasını değiştirmediğini unutmayın.

Bu özellik döngü yineleme koşuluna(loop iteration-condition) uygulanmaz, çünkü döngü kontrol
akışı her durumda iç ifadelerin(inner expressions) bu şekilde “outlining" yapılmasına izin vermez.
Yineleme koşulunu döngü gövdesine taşımak için :ref:`for-loop-condition-into-body` uygulayarak
bu sınırlamayı ortadan kaldırabiliriz.

Final programı öyle bir formda olmalıdır ki fonksiyon çağrıları (döngü koşulları hariç) ifadelerin
içinde içiçe görünmemeli ve tüm fonksiyon çağrısı argümanları değişken olmalıdır.

Bu formun faydaları, işlem kodları dizisini yeniden sıralamanın çok daha kolay olması ve ayrıca
fonksiyon çağrısı inlining'i yapmanın daha kolay hale getirmesidir. Ayrıca, ifadelerin tek tek
parçalarını değiştirmek veya "expression tree”'yi yeniden düzenlemek daha kolaydır. Dezavantajı
ise bu tür kodların insanlar tarafından okunmasının çok daha zor olmasıdır.

.. _SSA-transform:

SSATransform
^^^^^^^^^^^^

Bu aşama, mevcut değişkenlere tekrarlanan atamaları mümkün olduğunca yeni değişkenlerin
tanımlamalarıyla değiştirmeye çalışır. Yeniden atamalar hala mevcuttur, ancak yeniden
atanan değişkenlere yapılan tüm referanslar yeni bildirilen değişkenlerle değiştirilir.

Örnek:

.. code-block:: yul

    {
        let a := 1
        mstore(a, 2)
        a := 3
    }

dönüştürülür

.. code-block:: yul

    {
        let a_1 := 1
        let a := a_1
        mstore(a_1, 2)
        let a_3 := 3
        a := a_3
    }

Tam Semantik:

Kodda herhangi bir yere atanan bir ``a`` değişkeni için (değerle tanımlanan ve asla
yeniden atanmayan değişkenler değiştirilmemektedir) aşağıdaki dönüşümleri gerçekleştirin:

- ``let a := v`` yerine ``let a_i := v let a := a_i`` yazın
- ``a := v`` yerine ``let a_i := v a := a_i`` yazın; buradaki ``i``, ``a_i`` henüz kullanılmamış türde bir sayıdır.

Ayrıca, ``a`` için kullanılan ``i`` geçerli değerini her zaman saklamalı ve ``a``
değişkenine yapılan her referansı ``a_i`` ile değiştirmelisiniz. Bir ``a`` değişkeni
için geçerli olan bir değer eşlemesi, atandığı her bloğun sonunda ve for döngü
gövdesi veya post bloğu içinde atanmışsa for döngüsü init(başlangıç) bloğunun
sonunda temizlenir. Bir değişkenin değeri yukarıdaki kurala göre temizlenirse
ve değişken blok dışında bildirilirse, kontrol akışının birleştiği yerde yeni
bir SSA değişkeni oluşturulur, buna döngü sonrası/gövde bloğunun başlangıcı ve
If/Switch/ForLoop/Block ifadesinden hemen sonra gelen konum dahildir.

Bu aşamadan sonra, gereksiz ara atamaları kaldırmak için Redundant Assign Eliminator
kullanılması önerilir.

Bu aşama, Expression Splitter (İfade Ayırıcı) ve Common Subexpression Eliminator
(Ortak Alt İfade Giderici) hemen öncesinde çalıştırılırsa en iyi sonuçları verir,
çünkü o zaman aşırı miktarda değişken üretmez. Öte yandan, Common Subexpression
Eliminator (Ortak Alt İfade Giderici) SSA dönüşümünden sonra çalıştırılırsa daha
verimli olabilir.

.. _redundant-assign-eliminator:

RedundantAssignEliminator
^^^^^^^^^^^^^^^^^^^^^^^^^

SSA dönüşümü her zaman ``a := a_i`` şeklinde bir atama üretir, ancak bunlar
aşağıdaki örnekte olduğu gibi birçok durumda gereksiz olabilir:

.. code-block:: yul

    {
        let a := 1
        a := mload(a)
        a := sload(a)
        sstore(a, 1)
    }

SSA dönüşümü bu parçacığı aşağıdaki parçacığa dönüştürür:

.. code-block:: yul

    {
        let a_1 := 1
        let a := a_1
        let a_2 := mload(a_1)
        a := a_2
        let a_3 := sload(a_2)
        a := a_3
        sstore(a_3, 1)
    }

Redundant Assign Eliminator, ``a`` değerinin kullanılmaması nedeniyle ``a`` değerine
yapılan üç atamayı da kaldırır ve böylece bu parçacığı strict SSA formuna dönüştürür:

.. code-block:: yul

    {
        let a_1 := 1
        let a_2 := mload(a_1)
        let a_3 := sload(a_2)
        sstore(a_3, 1)
    }

Elbette, bir atamanın gereksiz olup olmadığını belirlemenin karmaşık kısımları,
kontrol akışının birleştirilmesiyle bağlantılıdır.

Bileşen ayrıntılı olarak aşağıdaki gibi çalışır:

AST iki kez taranır: bilgi toplama adımında ve asıl kaldırma adımında. Bilgi toplama
sırasında, atama ifadelerinden “unused", "undecided" ve "used" olmak üzere üç duruma
yönelik bir eşleştirme tutarız, bu da atanan değerin daha sonra değişkene yapılan
bir referans tarafından kullanılıp kullanılmayacağını gösterir.

Bir atama işlemi gerçekleştirildiğinde, "undecided" durumdaki eşleştirmeye eklenir
(aşağıdaki for döngüleriyle ilgili açıklamaya bakın) ardından aynı değişkene yapılan
ve hala "kararsız" durumda olan diğer tüm atamalar "undecided" olarak değiştirilir.
Bir değişkene referans verildiği zaman, o değişkene yapılan ve hala "unused" durumda
olan tüm atamaların durumu "undecided" olarak değiştirilir.

Kontrol akışının bölündüğü noktalarda, eşleştirmenin bir kopyası her bir kola(branch)
aktarılır. Kontrol akışının birleştiği noktalarda, iki koldan gelen iki eşleme aşağıdaki
şekilde birleştirilir: Ve ayrıca Yalnızca bir eşlemede bulunan veya aynı duruma sahip
olan ifadeler değiştirilmeden kullanılır. Çakışan İfade değerleri de aşağıdaki şekilde
çözümlenir:

- "unused", "undecided" -> "undecided"
- "unused", "used" -> "used"
- "undecided, "used" -> "used"

For-döngüleri açısından koşul, gövde ve son bölüm, koşulda birleşen kontrol akışı dikkate
alınarak iki kez kontrol edilir. Başka bir ifadeyle, temel olarak üç kontrol akış yolu
oluşturulur: Döngünün sıfır çalıştırılması, tek çalıştırılması ve ardından iki kez
çalıştırılması ve sonunda birleştirilmesi.

Üçüncü bir çalıştırma ya da daha fazlasını simüle etmek gereksizdir, bu da şekilde
olduğu biçimde anlaşılabilir:

Yinelemenin başlangıcındaki bir atama durumu, deterministik olarak yinelemenin sonunda
o atamanın bir durumuyla sonuçlanacaktır. Bu durum eşleme fonksiyonu ``f`` olarak
adlandırılsın. Yukarıda açıklandığı gibi ``unused``, ``undecided`` ve ``used`` üç
farklı durum kombinasyonu, ``unused = 0``, ``undecided = 1`` ve ``used = 2`` olan
``max`` operasyondur.

Doğru yol döngüden

.. code-block:: none

    max(s, f(s), f(f(s)), f(f(f(s))), ...)

sonra hesaplamak olacaktır. ``f`` sadece üç farklı değer aralığına sahip olduğundan,
iterasyon en fazla üç iterasyondan sonra bir döngüye ulaşmalıdır ve bu nedenle
``f(f(f(s)))`` ``s``, ``f(s)`` veya ``f(f(s))`` değerlerinden birine eşit olmalıdır
ve böylece

.. code-block:: none

    max(s, f(s), f(f(s))) = max(s, f(s), f(f(s)), f(f(f(s))), ...).

Özetle, döngüyü en fazla iki kez çalıştırmak yeterlidir çünkü sadece üç farklı durum vardır.

"Varsayılan" duruma sahip switch ifadeleri için switch'i atlayan bir kontrol akışı parçası yoktur.

Bir değişken kapsam dışına çıktığında, değişken bir fonksiyonun geri dönüş parametresi olmadığı
sürece, hala "undecided" durumundaki tüm ifadeler "unused" olarak değiştirilir - bu durumda durum "used" olarak değişir.

İkinci çaprazlamada, "unused" durumunda olan tüm atamalar kaldırılır.

Bu adım genellikle SSA dönüşümünden hemen sonra çalıştırılarak pseudo-SSA'nın oluşturulması tamamlanır.

Araçlar
--------

Taşınabilirlik(Movability)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Taşınabilirlik(Movability) bir ifadenin özelliğidir. Kabaca, ifadenin yan etkisiz olduğu ve
değerlendirmesinin yalnızca değişkenlerin değerlerine ve ortamın çağrı sabit
durumuna bağlı olduğu anlamına gelir. Çoğu ifade taşınabilirdir. Aşağıdaki parçalar
bir ifadeyi taşınamaz yapar:

- fonksiyon çağrıları (eğer fonksiyondaki tüm ifadeler taşınabilirse gelecekte gevşetilebilir)
- yan etkileri olan (olabilen) işlem kodları (``call`` veya ``selfdestruct`` gibi)
- bellek, depolama veya harici durum bilgilerini okuyan veya yazan işlem kodları
- geçerli PC'ye, bellek boyutuna veya geri dönen veri boyutuna bağlı olan işlem kodları

DataflowAnalyzer
^^^^^^^^^^^^^^^^

Dataflow Analyzer kendi başına bir optimizer adımı değildir ancak diğer bileşenler
tarafından bir araç olarak kullanılır. AST'de gezinirken, bu değer hareketli bir
ifade olduğu sürece her değişkenin mevcut değerini izler. O anda her bir diğer
değişkene atanmış olan ifadenin parçası olan değişkenleri kaydeder. Bir ``a`` değişkenine
yapılan her atamada, ``a`` değişkeninin saklanan mevcut değeri güncellenir ve ``a``
değişkeni ``b`` için saklanan ifadenin bir parçası olduğunda ``b`` değişkeninin
saklanan tüm değerleri silinir.

Kontrol akışı birleşimlerinde, değişkenler hakkındaki bilgiler, kontrol akışı
yollarından herhangi birinde atanmışlarsa veya atanacaklarsa temizlenir. Örneğin,
bir for döngüsüne girildiğinde, gövde veya son blok sırasında atanacak tüm değişkenler
temizlenir.

İfade-Ölçekli Basitleştirmeler (Expression-Scale Simplifications)
-------------------------------------------------------------------

Bu sadeleştirme geçişleri ifadeleri değiştirir ve onları eşdeğer ve muhtemelen
daha basit ifadelerle değiştirir.

.. _common-subexpression-eliminator:

CommonSubexpressionEliminator
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bu adım Dataflow Analyzer'ı kullanır ve bir değişkenin mevcut değeriyle sözdizimsel
olarak eşleşen alt ifadeleri o değişkene bir referans yoluyla değiştirir. Bu bir
eşdeğerlik dönüşümüdür çünkü bu tür alt ifadelerin taşınabilir olması gerekir.

Kendileri tanımlayıcı olan tüm alt ifadeler, değer bir tanımlayıcıysa mevcut değerleriyle
değiştirilir.

Yukarıdaki iki kuralın kombinasyonu, yerel değer numaralandırmasının hesaplanmasına
izin verir; bu da iki değişken aynı değere sahipse, bunlardan birinin her zaman
kullanılmayacağı anlamına gelir. Unused Pruner veya Redundant Assign Eliminator
daha sonra bu tür değişkenleri tamamen ortadan kaldırabilecektir.

Bu adım özellikle ifade ayırıcı çalıştırıldığında etkilidir. Kod pseudo-SSA formundaysa,
değişkenlerin değerleri daha uzun bir süre için mevcuttur ve bu nedenle ifadelerin
değiştirilebilir olma şansı daha yüksektir.

İfade basitleştirici daha iyi değiştirmeler gerçekleştirebilecektir eğer ortak
alt ifade giderici kendisinden hemen önce çalıştırılmışsa.

.. _expression-simplifier:

İfade Basitleştirici (Expression Simplifier)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

İfade Basitleştirici, Dataflow Analyzer'ı kullanarak kodu basitleştirmek için
``X + 0 -> X`` gibi ifadeler üzerinde bir denklik dönüşümleri listesi kullanmaktadır.

Her alt ifadede ``X + 0`` gibi kalıpları eşleştirmeye çalışır. Eşleştirme prosedürü
sırasında, kod pseudo-SSA formunda olsa bile daha derin iç içe geçmiş kalıpları
eşleştirebilmek için değişkenleri o anda atanmış ifadelerine göre çözümler.

``X - X -> 0`` gibi bazı kalıplar yalnızca ``X`` ifadesi taşınabilir olduğu sürece
uygulanabilir, çünkü aksi takdirde potansiyel yan etkilerini ortadan kaldırır.
Değişken referansları, mevcut değerleri olmasa bile her zaman taşınabilir olduğundan,
İfade Basitleştirici bölünmüş veya pseudo-SSA formunda yine daha etkilidir.

.. _literal-rematerialiser:

LiteralRematerialiser
^^^^^^^^^^^^^^^^^^^^^

Belgelenmek üzere...

.. _load-resolver:

LoadResolver
^^^^^^^^^^^^

Eğer biliniyorsa, ``sload(x)`` ve ``mload(x)`` tipindeki ifadeleri o anda bellekte
depolanan değerle değiştiren optimizasyon aşamasıdır.

Kod SSA formundaysa en iyi şekilde çalışır.

Prerequisite: Disambiguator, ForLoopInitRewriter.

.. _reasoning-based-simplifier:

ReasoningBasedSimplifier
^^^^^^^^^^^^^^^^^^^^^^^^

Bu optimizer, ``if`` koşullarının sabit olup olmadığını kontrol etmek için SMT çözücülerini kullanır.

- Eğer ``constraints AND condition`` UNSAT ise, koşul hiçbir zaman doğru değildir ve tüm gövde kaldırılabilir.
- Eğer ``constraints AND NOT condition`` UNSAT ise, koşul her zaman doğrudur ve ``1`` ile değiştirilebilir.

Yukarıdaki basitleştirmeler yalnızca koşulun hareketli olması durumunda uygulanabilir.

Yalnızca EVM diyalektinde etkilidir, ancak diğer diyalektlerde kullanımı güvenlidir.

Prerequisite: Disambiguator, SSATransform.

İfade Ölçeğindeki Basitleştirmeler (Statement-Scale Simplifications)
---------------------------------------------------------------------

.. _circular-reference-pruner:

CircularReferencesPruner
^^^^^^^^^^^^^^^^^^^^^^^^

Bu aşama, birbirini çağıran ancak dışarıdan veya en dış bağlamdan referans verilmeyen
fonksiyonları kaldırır.

.. _conditional-simplifier:

ConditionalSimplifier
^^^^^^^^^^^^^^^^^^^^^

Koşullu Basitleştirici(ConditionalSimplifier), değer kontrol akışından itibaren belirlenebiliyorsa koşul
değişikliklerine atamalar ekler.

SSA formunu yok eder.

Şu anda, bu araç çok sınırlıdır, çünkü henüz boolean değişken türleri için desteğimiz
yoktur. Koşullar yalnızca ifadelerin sıfırdan farklı olup olmadığını kontrol ettiğinden,
belirli bir değer atayamayız.

Mevcut özellikler:

- switch cases: insert "<condition> := <caseLabel>"
- kontrol akışını sonlandıran if ifadesinden sonra "<condition> := 0" ekleyin

Future features:

- allow replacements by "1"
- take termination of user-defined functions into account

En iyi SSA formu ile ve ölü kod kaldırma işlemi daha önce çalıştırılmışsa çalışır.

Ön koşul: Anlam Ayrıştırıcı.

.. _conditional-unsimplifier:

ConditionalUnsimplifier
^^^^^^^^^^^^^^^^^^^^^^^

Koşullu Basitleştirici'nin(ConditionalSimplifier) tersi.

.. _control-flow-simplifier:

ControlFlowSimplifier
^^^^^^^^^^^^^^^^^^^^^

Çeşitli kontrol akışı yapılarını basitleştirir:

- if'i boş gövde ile pop(koşul) ile değiştirin
- boş varsayılan anahtar durumunu kaldırın
- varsayılan durum yoksa boş anahtar durumunu kaldırın
- switch'i no cases ile pop(expression) ile değiştirin
- tek durumlu anahtarı if'e dönüştürün
- switch'i pop(expression) ve body ile yalnızca varsayılan durumla değiştirin
- switch'i eşleşen case gövdesine sahip const expr ile değiştirin
- ``for`` yerine kontrol akışını sonlandıran ve diğer break/continue olmadan ``if`` yazın
- bir fonksiyonun sonundaki ``leave`` ifadesini kaldırın.

Bu işlemlerin hiçbiri veri akışına bağlı değildir. StructuralSimplifier, veri akışına
bağlı olan benzer görevleri yerine getirir.

ControlFlowSimplifier, çaprazlama sırasında ``break`` ve ``continue`` deyimlerinin
varlığını veya yokluğunu kaydeder.

Ön koşul: Disambiguator, FunctionHoister, ForLoopInitRewriter.
Önemli: EVM işlem kodlarını tanıtır ve bu nedenle şimdilik yalnızca EVM kodu üzerinde
kullanılabilir.

.. _dead-code-eliminator:

DeadCodeEliminator
^^^^^^^^^^^^^^^^^^

Bu optimizasyon aşaması ulaşılamayan kodu kaldırır.

Ulaşılamayan kod, bir blok içinde öncesinde leave, return, invalid, break, continue,
selfdestruct veya revert bulunan kodlardır.

Fonksiyon tanımları, daha önceki kodlar tarafından çağrılabilecekleri için korunur
ve bu nedenle ulaşılabilir olarak kabul edilir.

Bir for döngüsünün init(başlangıç) bloğunda bildirilen değişkenlerin kapsamı döngü
gövdesine genişletildiğinden, ForLoopInitRewriter'ın bu adımdan önce çalışmasını gerektirir.

Önkoşul: ForLoopInitRewriter, Function Hoister, Function Grouper

.. _equal-store-eliminator:

EqualStoreEliminator
^^^^^^^^^^^^^^^^^^^^

Bu adım, ``mstore(k, v)`` ve ``sstore(k, v)`` çağrılarını, daha önce ``mstore(k, v)``
/ ``sstore(k, v)`` çağrısı yapılmışsa, arada başka bir depo yoksa ve ``k`` ve ``v``
değerleri değişmemişse kaldırır.

Bu basit adım, SSA dönüşümü ve Common Subexpression Eliminator'den sonra çalıştırılırsa
etkili olur, çünkü SSA değişkenlerin değişmeyeceğinden emin olur ve Common Subexpression
Eliminator, değerin aynı olduğu biliniyorsa tam olarak aynı değişkeni yeniden kullanır.

Önkoşullar: Disambiguator, ForLoopInitRewriter

.. _unused-pruner:

UnusedPruner
^^^^^^^^^^^^

Bu adım, hiçbir zaman başvurulmayan tüm fonksiyonların tanımlarını kaldırır.

Ayrıca, hiçbir zaman başvurulmayan değişkenlerin tanımlarını da kaldırır. Tanımlama
taşınabilir olmayan bir değer atarsa, ifade korunur ancak değeri atılır.

Tüm taşınabilir ifade ifadeleri (atanmamış ifadeler) kaldırılır.

.. _structural-simplifier:

StructuralSimplifier
^^^^^^^^^^^^^^^^^^^^

Bu, yapısal düzeyde çeşitli basitleştirmeler gerçekleştiren genel bir adımdır:

- if ifadesini boş gövde ile ``pop(koşul)`` ile değiştirin
- if ifadesini gövdesine göre doğru koşulla değiştirin
- if deyimini yanlış koşulla kaldırın
- tek durumlu anahtarı if'e dönüştürün
- switch'i sadece varsayılan durumla ``pop(expression)`` ve gövde ile değiştirin
- case gövdesini eşleştirerek switch'i gerçek ifade ile değiştirin
- yanlış koşullu for döngüsünü başlatma kısmı ile değiştirin

Bu bileşen Dataflow Analyzer'ı kullanır.

.. _block-flattener:

BlockFlattener
^^^^^^^^^^^^^^

Bu aşama, iç bloktaki ifadeyi dış bloktaki uygun yere yerleştirerek iç içe geçmiş
blokları ortadan kaldırır. FunctionGrouper'a bağlıdır ve FunctionGrouper tarafından
üretilen formu korumak için en dıştaki bloğu düzleştirmez.

.. code-block:: yul

    {
        {
            let x := 2
            {
                let y := 3
                mstore(x, y)
            }
        }
    }

dönüştürülür

.. code-block:: yul

    {
        {
            let x := 2
            let y := 3
            mstore(x, y)
        }
    }

Kodda belirsizlikler giderildiği sürece bu bir soruna yol açmaz çünkü değişkenlerin
kapsamları yalnızca büyüyebilir.

.. _loop-invariant-code-motion:

LoopInvariantCodeMotion
^^^^^^^^^^^^^^^^^^^^^^^
Bu optimizasyon, taşınabilir SSA değişken tanımlamalarını döngünün dışına taşır.

Yalnızca bir döngünün gövdesindeki veya son bloğundaki en üst düzeydeki ifadeler
dikkate alınır, yani koşullu branşların(branch) içindeki değişken tanımlamaları
döngünün dışına taşınmaz.

Gereksinimler:

- Disambiguator, ForLoopInitRewriter ve FunctionHoister önceden çalıştırılmalıdır.
- İfade ayırıcı ve SSA dönüşümü daha iyi sonuç elde etmek için önceden çalıştırılmalıdır.


Fonksiyon Düzeyinde Optimizasyonlar
------------------------------------------

.. _function-specializer:

FunctionSpecializer
^^^^^^^^^^^^^^^^^^^

Bu adım, fonksiyonu gerçek argümanlarıyla özelleştirir.

Bir fonksiyon, örneğin ``fonksiyon f(a, b) { sstore (a, b) }``, literal argümanlarla
çağrılırsa, örneğin ``f(x, 5)``, burada ``x`` bir tanımlayıcıdır, sadece bir argüman
alan yeni bir ``f_1`` fonksiyonu oluşturularak özelleştirilebilir, yani,

.. code-block:: yul

    function f_1(a_1) {
        let b_1 := 5
        sstore(a_1, b_1)
    }

Diğer optimizasyon adımları fonksiyonda daha fazla basitleştirme yapabilecektir.
Optimizasyon adımı esas olarak inline edilmeyecek fonksiyonlar için kullanışlıdır.

Önkoşullar: Disambiguator, FunctionHoister

LiteralRematerialiser, doğruluk için gerekli olmasa da bir ön koşul olarak önerilir.

.. _unused-function-parameter-pruner:

UnusedFunctionParameterPruner
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bu adım, bir fonksiyondaki kullanılmayan parametreleri kaldırır.

Eğer bir parametre kullanılmıyorsa, ``fonksiyon f(a,b,c) -> x, y { x := div(a,b) }``
içindeki ``c`` ve ``y`` gibi, parametreyi kaldırırız ve aşağıdaki gibi yeni bir "bağlama"
fonksiyonu oluştururuz:

.. code-block:: yul

    function f(a,b) -> x { x := div(a,b) }
    function f2(a,b,c) -> x, y { x := f(a,b) }

ve ``f`` öğesine yapılan tüm referansları ``f2`` ile değiştirmelisiniz. Tüm ``f2``
referanslarının ``f`` ile değiştirildiğinden emin olmak için inliner daha sonra çalıştırılmalıdır.

Önkoşullar: Disambiguator, FunctionHoister, LiteralRematerialiser.

LiteralRematerialiser adımı doğruluk için gerekli değildir. Aşağıdaki gibi durumlarla
başa çıkmaya yardımcı olur: ``fonksiyon f(x) -> y { revert(y, y} }`` burada ``y``
değişmezi ``0`` değeri ile değiştirilecek ve fonksiyonu yeniden yazmamıza izin verecektir.

.. _equivalent-function-combiner:

EquivalentFunctionCombiner
^^^^^^^^^^^^^^^^^^^^^^^^^^

İki fonksiyon sözdizimsel(syntactically) olarak eşdeğerse, değişkenlerin yeniden
adlandırılmasına izin verirken herhangi bir yeniden sıralamaya izin vermiyorsa,
fonksiyonlardan birine yapılan herhangi bir referans diğeriyle değiştirilir.

Fonksiyonun asıl kaldırılma işlemi Unused Pruner tarafından gerçekleştirilir.


Fonksiyon Inlining (Function Inlining)
---------------------------------------

.. _expression-inliner:

ExpressionInliner
^^^^^^^^^^^^^^^^^

Optimize edicinin bu bileşeni, fonksiyonel ifadeler içinde inline edilebilen fonksiyonları,
yani tek bir değer döndüren fonksiyonları inline ederek kısıtlı fonksiyon inliningi
gerçekleştirir:

- tek bir değer döndüren.
- ``r := <fonksiyonel ifade>`` gibi bir gövdeye sahip olan.
- ne kendilerine ne de sağ taraftaki ``r`` ye referans verirler.

Ayrıca, tüm parametreler için aşağıdakilerin tümünün doğru olması gerekir:

- Bağımsız değişken taşınabilir.
- Parametreye ya fonksiyon gövdesinde iki kereden az referans verilir ya da argüman oldukça ucuzdur ("cost" en fazla 1, 0xff'ye kadar bir sabit gibi).

Örnek: Inline edilecek fonksiyon ``function f(...) -> r { r := E }`` biçimindedir;
burada ``E``, ``r`` ye referans vermeyen bir ifadedir ve fonksiyon çağrısındaki tüm
argümanlar taşınabilir ifadelerdir.

Bu inlining işleminin sonucu her zaman tek bir ifadedir.

Bu bileşen yalnızca benzersiz adlara sahip kaynaklarda kullanılabilir.

.. _full-inliner:

FullInliner
^^^^^^^^^^^

Full Inliner, belirli fonksiyonların belirli çağrılarını fonksiyonun gövdesi ile
değiştirir. Bu çoğu durumda çok yararlı değildir, çünkü kod boyutunu artırır ayrıca
bir faydası da yoktur. Genellikle kod çok pahalıdır ve daha verimli bir kod yerine
daha kısa bir kodu tercih ederiz. Yine de aynı durumlarda, bir fonksiyonun inlining
işleminin sonraki optimizer adımları üzerinde olumlu etkileri olabilir. Örneğin,
fonksiyon argümanlarından birinin sabit olması durumunda durum böyledir.

Inlining sırasında, fonksiyon çağrısının inline edilip edilmeyeceğini söylemek için
bir heuristic kullanılır. Mevcut heuristic, çağrılan fonksiyon küçük olmadığı sürece
"büyük" fonksiyonları inline etmez. Sadece bir kez kullanılan fonksiyonların yanı
sıra orta büyüklükteki fonksiyonlar da inline edilirken, sabit argümanlara sahip
fonksiyon çağrıları biraz daha büyük fonksiyonlara izin verir.


Gelecekte, bir fonksiyonu hemen inline etmek yerine sadece uzmanlaştıran bir geri
izleme bileşeni ekleyebiliriz, bu da belirli bir parametrenin her zaman bir sabitle
değiştirildiği fonksiyonun bir kopyasının oluşturulacağı anlamına gelir. Bundan sonra,
optimize ediciyi bu özelleştirilmiş fonksiyon üzerinde çalıştırabiliriz. Eğer büyük
kazançlar elde edilirse, özelleştirilmiş fonksiyon korunur, aksi takdirde orijinal
fonksiyon kullanılır.

Temizlik (Cleanup)
---------------------

Temizleme, optimizer çalışmasının sonunda gerçekleştirilir. Bölünmüş ifadeleri
tekrar derin iç içe geçmiş ifadelerle birleştirmeye çalışır ve ayrıca değişkenleri
mümkün olduğunca ortadan kaldırarak yığın(stack) makineleri için "derlenebilirliği" iyileştirir.

.. _expression-joiner:

ExpressionJoiner
^^^^^^^^^^^^^^^^

Bu işlem, ifade ayırıcının(expression splitter) tersidir. Tam olarak bir referansı
olan bir dizi değişken tanımlamasını karmaşık bir ifadeye dönüştürür. Bu aşama,
fonksiyon çağrılarının ve işlem kodu yürütmelerinin sırasını tamamen korur. İşlem
kodlarının değişebilirliğine ilişkin herhangi bir bilgi kullanmaz; bir değişkenin
değerini kullanım yerine taşımak herhangi bir işlev çağrısının veya işlem kodu
yürütmesinin sırasını değiştirecekse, dönüşüm gerçekleştirilmez.

Bileşenin, bir değişken atamasının atanmış değerini veya birden fazla kez başvurulan
bir değişkeni taşımayacağını unutmayın.

``let x := add(0, 2) let y := mul(x, mload(2))`` kod parçacığı dönüştürülmez, çünkü
``add`` ve ``mload`` işlem kodlarına yapılan çağrıların sırasının değiştirilmesine
neden olur - ancak ``add`` taşınabilir olduğu için bu bir fark yaratmaz.

İşlem kodlarını bu şekilde yeniden sıralarken, değişken referansları ve literaller
göz ardı edilir. Bu nedenle, ``let x := add(0, 2) let y := mul(x, 3)`` kod parçacığı,
``add`` işlem kodu ``3`` literalinin değerlendirilmesinden sonra çalıştırılacak
olsa bile, ``let y := mul(add(0, 2), 3)`` olarak dönüştürülür.

.. _SSA-reverser:

SSAReverser
^^^^^^^^^^^

Bu, Common Subexpression Eliminator ve Unused Pruner ile birleştirildiğinde SSA
dönüşümünün etkilerini tersine çevirmeye yardımcı olan küçük bir adımdır.

Ürettiğimiz SSA formu EVM ve WebAssembly'de kod üretimi için zararlıdır çünkü çok
sayıda yerel değişken üretir. Yeni değişken bildirimleri yerine mevcut değişkenleri
atamalarla yeniden kullanmak daha iyi sonuç verecektir.

SSA dönüşümleri şu şekilde

.. code-block:: yul

    let a := calldataload(0)
    mstore(a, 1)

yeniden yazılır

.. code-block:: yul

    let a_1 := calldataload(0)
    let a := a_1
    mstore(a_1, 1)
    let a_2 := calldataload(0x20)
    a := a_2

Sorun, ``a`` değişkenine her başvurulduğunda ``a`` yerine ``a_1`` değişkeninin
kullanılmasıdır. SSA dönüşümü bu formdaki ifadeleri sadece tanımlama ve atamayı
değiştirerek değiştirir. Yukarıdaki kod parçacığı şu şekle dönüşür

.. code-block:: yul

    let a := calldataload(0)
    let a_1 := a
    mstore(a_1, 1)
    a := calldataload(0x20)
    let a_2 := a

Bu çok basit bir denklik dönüşümüdür, ancak şimdi Common Subexpression Eliminator'ü
çalıştırdığımızda, ``a_1`` değişkeninin tüm kullanımlarını ``a`` ile değiştirecektir
(``a`` yeniden atanana kadar). Unused Pruner daha sonra ``a_1`` değişkenini tamamen
ortadan kaldıracak ve böylece SSA dönüşümünü tamamen tersine çevirecektir.

.. _stack-compressor:

StackCompressor
^^^^^^^^^^^^^^^

Ethereum Sanal Makinesi için kod oluşturmayı zorlaştıran bir sorun, ifade yığınına
ulaşmak için 16 slotluk katı bir sınır olmasıdır. Bu da aşağı yukarı 16 yerel değişken
sınırı anlamına gelmektedir. Yığın sıkıştırıcı Yul kodunu alır ve EVM bayt koduna derler.
Yığın farkı çok büyük olduğunda, bunun hangi fonksiyonda gerçekleştiğini kaydeder.

Böyle bir soruna neden olan her bir fonksiyon için, değerlerinin maliyetine göre
sıralanan belirli değişkenleri agresif bir şekilde ortadan kaldırmak için özel bir
taleple Rematerialiser çağrılır.

Başarısızlık durumunda, bu prosedür birden çok kez tekrarlanır.

.. _rematerialiser:

Rematerialiser
^^^^^^^^^^^^^^

Rematerialisation aşaması, değişken referanslarını değişkene en son atanan ifade
ile değiştirmeye çalışır. Bu elbette yalnızca bu ifadenin değerlendirilmesi nispeten
daha ucuzsa faydalıdır. Ayrıca, yalnızca ifadenin değeri atama noktası ile kullanım
noktası arasında değişmediyse anlamsal olarak denktir. Bu aşamanın ana faydası,
bir değişkenin tamamen ortadan kaldırılmasına yol açarsa yığın yuvalarından tasarruf
edebilmesidir (aşağıya bakın), ancak ifade çok ucuzsa EVM'de bir DUP işlem kodundan
da tasarruf edebilir.

Rematerialiser, her zaman hareketli olan değişkenlerin mevcut değerlerini izlemek
için Dataflow Analyzer'ı kullanır. Değer çok ucuzsa veya değişkenin ortadan kaldırılması
açıkça istenmişse, değişken referansı geçerli değeriyle değiştirilir.

.. _for-loop-condition-out-of-body:

ForLoopConditionOutOfBody
^^^^^^^^^^^^^^^^^^^^^^^^^

ForLoopConditionIntoBody dönüşümünü tersine çevirir.

Herhangi bir taşınabilir ``c`` için,

.. code-block:: none

    for { ... } 1 { ... } {
    if iszero(c) { break }
    ...
    }

dönüşür

.. code-block:: none

    for { ... } c { ... } {
    ...
    }

ve döner

.. code-block:: none

    for { ... } 1 { ... } {
    if c { break }
    ...
    }

dönüşür

.. code-block:: none

    for { ... } iszero(c) { ... } {
    ...
    }

LiteralRematerialiser bu adımdan önce çalıştırılmalıdır.


WebAssembly'a özgü
--------------------

Ana Fonksiyon(MainFunction)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

En üstteki bloğu, girdisi veya çıktısı olmayan belirli bir ada ("main") sahip bir
fonksiyon olarak değiştirir.

Fonksiyon Gruplayıcısına bağlıdır.
