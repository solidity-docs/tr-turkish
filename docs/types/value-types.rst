.. index:: ! value type, ! type;value
.. _value-types:

Değer Türleri
==============

Aşağıdaki türlere de değer türleri denir, çünkü bu türlerin değişkenleri her zaman değere göre iletilir, yani fonksiyon argümanları olarak veya atamalarda kullanıldıklarında her zaman kopyalanırlar.

.. index:: ! bool, ! true, ! false

Booleans
--------

``bool``: Olası değerler ``true`` ve ``false`` sabitleridir.

Operatörler:

*  ``!`` (Mantıksal olumsuzlama)
*  ``&&`` (Mantıksal bağlaç, "ve")
*  ``||`` (Mantıksal ayrılma, "veya")
*  ``==`` (Eşitlik)
*  ``!=`` (Eşitsizlik)

``||`` ve ``&&`` operatörleri ortak kısa devre kurallarını uygular. Bunun anlamı ``f(x) || g(y)``, eğer ``f(x)`` ``true`` (doğru) olarak değerlendirilirse, ``g(y)`` yan etkileri olsa bile değerlendirilmeyecektir.

.. index:: ! uint, ! int, ! integer
.. _integers:

Tamsayılar
-----------

``int`` / ``uint``: Çeşitli boyutlarda işaretli ve işaretsiz tam sayılar.
``8`` (8'den 256 bit'e kadar işaretsiz) ve ``uint8`` ila ``uint256`` adımlarında ``uint8`` ile ``uint256`` arasındaki anahtar kelimeler. ``uint`` ve ``int`` sırasıyla ``uint256`` ve ``int256`` için takma adlardır.

Operatörler:

* Karşılaştırmalar: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (``bool`` olarak değerlendir)
* Bit operatörleri: ``&``, ``|``, ``^`` (bit düzeyinde özel veya), ``~`` (bitsel olumsuzlama)
* Değiştirme (Shift) operatörleri: ``<<`` (sol shift), ``>>`` (sağ shift)
* Aritmetik operatörler: ``+``, ``-``, tekli ``-`` (sadece imzalı tamsayılar için), ``*``, ``/``, ``%`` (mod alma operatörü), ``**`` (ül alma operatörü)

Bir tamsayı türü olan ``X`` için, tür tarafından gösterilebilen minimum ve maksimum değere erişmek için ``type(X).min`` ve ``type(X).max`` ı kullanabilirsiniz.


.. warning::

 Solidity'deki tamsayılar belirli bir aralıkla sınırlıdır. Örneğin, ``uint32`` ile bu ``0``dan ``2**32 - 1``e kadardır. Bu türlerde aritmetiğin gerçekleştirildiği iki mod vardır: "wrapping" veya "unchecked" mod ve "checked" mod. Varsayılan olarak, aritmetik her zaman "checked" durumundadır, yani bir işlemin sonucu türün değer aralığının dışına çıkarsa, çağrı bir :ref:`başarısız onaylama<asset-and-require>` aracılığıyla geri döndürülür. ``unchecked { ... }`` kullanarak "unchecked" moda geçebilirsiniz. Daha fazla ayrıntı :ref:`unchecked <unchecked>` ile ilgili bölümde bulunabilir.


Karşılaştırmalar
^^^^^^^^^^^^^^^^^^^

Bir karşılaştırmanın değeri, tamsayı değeri karşılaştırılarak elde edilen değerdir.

Bit işlemleri
^^^^^^^^^^^^^^

Bit işlemleri, sayının ikisinin tümleyen gösterimi üzerinde gerçekleştirilir.
Bu, örneğin ``~int256(0) == int256(-1)`` anlamına gelir.


Shifts
^^^^^^

Bir kaydırma işleminin sonucu, sol işlenenin türüne sahiptir ve sonucu türle eşleşecek şekilde kısaltır.
Doğru işlenen imzasız türde olmalıdır, imzalı bir türle kaydırmaya çalışmak derleme hatası üretecektir.

Vardiyalar, aşağıdaki şekilde ikinin kuvvetleriyle çarpma kullanılarak "simüle edilebilir". Sol işlenenin türünün kesilmesinin her zaman sonunda gerçekleştirildiğini, ancak açıkça belirtilmediğini unutmayın.

- ``x << y``, ``x * 2**y`` matematiksel ifadesine eşdeğerdir.
- ``x >> y``, ``x / 2**y`` matematiksel ifadesine eşdeğerdir, negatif sonsuza yuvarlanır.

.. warning::

    ``0.5.0`` sürümünden önce, negatif ``x`` için bir sağa kaydırma ``x >> y`` sıfıra yuvarlanmış ``x / 2**y`` matematiksel ifadesine eşdeğerdi, yani sağa kaydırmalar, aşağı yuvarlama (negatif sonsuza doğru) yerine yukarı (sıfıra doğru) yuvarlama olarak kullanılır.

.. note::
    Aritmetik işlemlerde olduğu gibi kaydırma işlemleri için de taşma kontrolleri yapılmaz. Bunun yerine, sonuç her zaman kesilir.

Toplama, Çıkarma ve Çarpma
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Toplama, çıkarma ve çarpma, taşma ve alttan akışa ilişkin iki farklı mod ile olağan semantiklere sahiptir:

Varsayılan olarak, tüm aritmetik yetersiz veya taşma açısından kontrol edilir, ancak bu, :ref:`unchecked blok<unchecked>` kullanılarak devre dışı bırakılabilir, bu da sarma aritmetiğiyle sonuçlanır. Daha fazla ayrıntı o bölümde bulunabilir.

``-x`` ifadesi, ``(T(0) - x)`` ile eşdeğerdir; burada ``T``, ``x``in türüdür. Yalnızca imzalı türlere uygulanabilir. ``x`` negatifse ``-x`` in değeri pozitif olabilir. İkisinin tamamlayıcı temsilinden kaynaklanan başka bir uyarı daha var:

``int x = type(int).min;`` varsa, ``-x`` pozitif aralığa uymaz. ``unchecked { assert(-x == x); }`` çalışır ve işaretli modda kullanıldığında ``-x`` ifadesi başarısız bir onaylamaya neden olur.


Bölme
^^^^^^^^

Bir işlemin sonucunun türü her zaman işlenenlerden birinin türü olduğundan, tamsayılarda bölme her zaman bir tamsayı ile sonuçlanır. Solidity'de bölme sıfıra doğru yuvarlanır. Bu, ``int256(-5) / int256(2) == int256(-2)`` anlamına gelir.


Buna karşılık, :ref:`değişmezler (literals) <rational_literals>` üzerinde bölmenin keyfi kesinliğin kesirli değerleriyle sonuçlandığını unutmayın.

.. note::
    Sıfıra bölme bir :ref:`panik hatasına<assert-and-require>` neden olur. Bu kontrol, ``unckecked { ... }`` ile devre dışı **bırakılamaz**.

.. note::
  ``type(int).min / (-1)`` ifadesi, bölmenin taşmaya neden olduğu tek durumdur. Kontrollü aritmetik modda, bu başarısız bir onaylamaya neden olurken, sarma modunda değer ``type(int).min`` olacaktır.

Mod Alma
^^^^^^^^^^

Mod alma işlemi ``a % n``, ``a`` işleneninin ``n`` işlenenine bölünmesinden sonra kalan ``r``yi verir, burada ``q = int(a / n)`` ve ``r = a - (n * q)``. Bu, mod alma işleminin sol işleneni (veya sıfır) ile aynı işaretle sonuçlandığı ve ``a % n == -(-a % n)``nin negatif ``a`` için geçerli olduğu anlamına gelir:


* ``int256(5) % int256(2) == int256(1)``
* ``int256(5) % int256(-2) == int256(1)``
* ``int256(-5) % int256(2) == int256(-1)``
* ``int256(-5) % int256(-2) == int256(-1)``

.. note::
  Sıfırlı mod alma işlemi :ref:`Panik hatasına<assert-and-require>` neden oluyor. Bu kontrol, ``unckecked { ... }`` ile devre dışı **bırakılamaz**.

Üs Alma
^^^^^^^^^

Üs, yalnızca üsteki işaretsiz türler için kullanılabilir. Elde edilen bir üs türü her zaman tabanın türüne eşittir. Lütfen sonucu tutacak ve olası onaylama hatalarına veya sarma davranışına hazırlanacak kadar büyük olmasına dikkat edin.


.. note::
  İşaretli (checked) modda, üs alma yalnızca küçük tabanlar için nispeten ucuz ``exp`` işlem kodunu kullanır.
   ``x**3`` durumları için ``x*x*x`` ifadesi daha ucuz olabilir.
   Her durumda, gaz maliyeti testleri ve optimize edicinin kullanılması tavsiye edilir.


.. note::
  ``0**0``ın EVM tarafından ``1`` olarak tanımlandığını unutmayın.

.. index:: ! ufixed, ! fixed, ! fixed point number

Sabit Nokta Sayıları
---------------------

.. warning::
    Sabit nokta sayıları henüz Solidity tarafından tam olarak desteklenmemektedir. Bildirilebilirler, ancak atanamazlar veya atanamazlar.

``fixed`` / ``ufixed``: Çeşitli boyutlarda imzalı ve imzasız sabit nokta sayısı. 
Anahtar sözcükler ``ufixedMxN`` ve ``fixedMxN``, burada ``M`` türün aldığı bit sayısını ve ``N`` kaç ondalık noktanın mevcut olduğunu gösterir. ``M`` 8'e bölünebilir olmalı ve 8'den 256 bit'e kadar gider. ``N`` 0 ile 80 arasında olmalıdır. ``ufixed`` ve ``fixed`` sırasıyla ``ufixed128x18`` ve ``fixed128x18`` için takma adlardır.


Operatörler:

* Karşılaştırma: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (``bool`` olarak değerlendir)
* Aritmetik operatörler: ``+``, ``-``, tekil ``-``, ``*``, ``/``, ``%`` (mod alma)

.. note::
    Kayan nokta (birçok dilde ``float`` ve ``double``, daha doğrusu IEEE 754 sayıları) ile sabit nokta sayıları arasındaki temel fark, tamsayı ve kesirli kısım için kullanılan bit sayısının (birçok dilde ondalık nokta) birincisinde esnektir, ikincisinde ise kesin olarak tanımlanmıştır. Genel olarak, kayan noktada neredeyse tüm alan sayıyı temsil etmek için kullanılırken, ondalık noktanın nerede olduğunu yalnızca az sayıda bit tanımlar.


.. index:: address, balance, send, call, delegatecall, staticcall, transfer

.. _address:

Adresler
---------

Adres türü, büyük ölçüde aynı olan iki şekilde gelir:

- ``address``: 20 baytlık bir değer tutar (bir Ethereum adresinin boyutu).
- ``address payable``: ``address`` ile aynıdır, ek olarak ``transfer`` ve ``send`` bulundurur.

Bu ayrımın arkasındaki fikir, ``address payable`` in, Ether gönderebileceğiniz bir adres olduğu, ancak Ether'i düz bir ``address`` e göndermemeniz gerektiğidir, örneğin akıllı bir sözleşme olabileceği için. Ether'i kabul etmek için oluşturulmamıştır.


Tür dönüşümleri:

``address payable``den ``address``e örtülü dönüşümlere izin verilirken, ``address``den ``address payable``a dönüşümler ``payable(<address>)`` üzerinden açık olmalıdır.

``uint160``, tamsayı değişmezleri, ``bytes20`` ve sözleşme türleri için ``address`` e ve adresten açık dönüşümlere izin verilir.

Yalnızca ``address`` ve sözleşme türündeki ifadeler, açık dönüştürme ``payable(...)`` aracılığıyla ``address payable`` 
türüne dönüştürülebilir. Sözleşme türü için, bu dönüştürmeye yalnızca sözleşme Ether alabiliyorsa, yani sözleşmenin bir :ref:`alma <receive-ether-function>` veya ödenebilir yedek fonksiyonu varsa izin verilir. ``payable(0)`` ın geçerli olduğunu ve bu kuralın bir istisnası olduğunu unutmayın.

.. note::
    ``address`` türünde bir değişkene ihtiyacınız varsa ve buna Ether göndermeyi planlıyorsanız, bu gereksinimi görünür kılmak için türünü ``address payable`` olarak bildirin. Ayrıca, bu ayrımı veya dönüşümü mümkün olduğunca erken yapmaya çalışın.

<<<<<<< HEAD
Operatörler:
=======
    The distinction between ``address`` and ``address payable`` was introduced with version 0.5.0.
    Also starting from that version, contracts are not implicitly convertible to the ``address`` type, but can still be explicitly converted to
    ``address`` or to ``address payable``, if they have a receive or payable fallback function.


Operators:
>>>>>>> v0.8.17

* ``<=``, ``<``, ``==``, ``!=``, ``>=`` ve ``>``

.. warning::
<<<<<<< HEAD
    Daha büyük bir bayt boyutu kullanan bir türü bir ``address``e, örneğin ``bytes32``ye dönüştürürseniz, ``address`` kısaltılır. Dönüştürme belirsizliğini azaltmak için sürüm 0.4.24 ve derleyici kuvvetinin daha yüksek sürümü, dönüştürmede kesmeyi açık hale getirirsiniz.
     Örneğin, ``0x111122223333444455556666777788889999AAAABBBBCCCCDDDDEEEEFFFFCCC`` 32 bayt değerini alın.
=======
    If you convert a type that uses a larger byte size to an ``address``, for example ``bytes32``, then the ``address`` is truncated.
    To reduce conversion ambiguity, starting with version 0.4.24, the compiler will force you to make the truncation explicit in the conversion.
    Take for example the 32-byte value ``0x111122223333444455556666777788889999AAAABBBBCCCCDDDDEEEEFFFFCCCC``.
>>>>>>> v0.8.17

    ``address(uint160(bytes20(b)))`` kullanabilirsiniz, bu da ``0x111122223333444455556666777788889999aAaa`` ile sonuçlanır,
     veya ``0x777788889999AaAAbBbbCccccddDdeeeEfFFfCcCc`` ile sonuçlanan ``address(uint160(uint256(b)))`` i kullanabilirsiniz.

.. note::
<<<<<<< HEAD
    ``address`` ve ``address payable`` arasındaki ayrım, 0.5.0 sürümüyle tanıtıldı. Ayrıca bu versiyondan başlayarak, sözleşmeler adres türünden türetilmez, ancak yine de bir alma veya ödeme geri dönüş fonksiyonu varsa, açıkça ``address`` e veya ``address payable`` a dönüştürülebilir.
=======
    Mixed-case hexadecimal numbers conforming to `EIP-55 <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md>`_ are automatically treated as literals of the ``address`` type. See :ref:`Address Literals<address_literals>`.
>>>>>>> v0.8.17

.. _members-of-addresses:

Adres Üyeleri
^^^^^^^^^^^^^^^^^^^^

Adreslerin tüm üyelerine hızlıca göz atmak için, bkz.:ref:`address_related`.

* ``balance`` and ``transfer``

Bir adresin bakiyesini ``balance`` özelliğini kullanarak sorgulamak ve ``transfer`` fonksiyonunu kullanarak Ether'i (wei birimi cinsinden) bir ödenecek adrese göndermek mümkündür:

.. code-block:: solidity
    :force:

    address payable x = payable(0x123);
    address myAddress = address(this);
    if (x.balance < 10 && myAddress.balance >= 10) x.transfer(10);

Mevcut sözleşmenin bakiyesi yeterince büyük değilse veya Ether transferi alıcı hesap tarafından reddedilirse ``transfer`` fonksiyonu başarısız olur. ``transfer`` fonksiyonu başarısızlık üzerine geri döner.


.. note::
    ``x`` bir sözleşme (kontrat) adresiyse, kodu (daha spesifik olarak: varsa :ref:`receive-ether-function` veya varsa :ref:`fallback-function` yürütülür. ``transfer`` çağrısı ile birlikte (bu, EVM'nin bir özelliğidir ve engellenemez). Bu yürütmenin gazı biterse veya herhangi bir şekilde başarısız olursa, Ether transferi geri alınacak ve mevcut sözleşme bir istisna dışında durdurulacaktır.

* ``send``

Gönder, ``transfer``in alt düzey karşılığıdır. Yürütme (execution) başarısız olursa, mevcut sözleşme bir istisna dışında durmaz, ancak ``send``, ``false`` döndürür.

Send is the low-level counterpart of ``transfer``. If the execution fails, the current contract will not stop with an exception, but ``send`` will return ``false``.

.. warning::
    ``send`` kullanmanın bazı tehlikeleri vardır:
     Çağrı yığını derinliği 1024 ise aktarım başarısız olur (bu her zaman arayan tarafından zorlanabilir) ve ayrıca alıcının gazı biterse de başarısız olur. Bu nedenle, güvenli Ether transferleri yapmak için her zaman ``send`` in dönüş değerini kontrol edin, ``transfer`` i kullanın veya daha iyisi: 
     alıcının parayı çektiği bir kalıp kullanın.

* ``call``, ``delegatecall`` ve ``staticcall``

ABI'ye uymayan sözleşmelerle arayüz oluşturmak veya kodlama üzerinde daha doğrudan kontrol sağlamak için ``call``, ``delegatecall`` ve ``staticcall`` fonksiyonları sağlanmıştır.
Hepsi tek bir ``bytes memory`` parametresi alır ve başarı koşulunu (``bool`` olarak) ve döndürülen verileri (``bytes memory``) döndürür.
Yapılandırılmış verileri kodlamak için ``abi.encode``, ``abi.encodePacked``, ``abi.encodeWithSelector``
ve ``abi.encodeWithSignature`` fonksiyonları kullanılabilir.

Örnek:

.. code-block:: solidity

    bytes memory payload = abi.encodeWithSignature("register(string)", "MyName");
    (bool success, bytes memory returnData) = address(nameReg).call(payload);
    require(success);

.. warning::
    Tüm bu fonksiyonlar alt düzey fonksiyonlarıdır ve dikkatli kullanılmalıdır. Spesifik olarak, bilinmeyen herhangi bir sözleşme kötü niyetli olabilir ve onu çağırırsanız, kontrolü o sözleşmeye devredersiniz ve bu da sözleşmenize geri çağrı yapabilir, bu nedenle arama geri döndüğünde durum değişkenlerinizdeki değişikliklere hazır olun. Diğer sözleşmelerle etkileşime girmenin normal yolu, bir sözleşme nesnesi (``x.f()``) üzerindeki bir fonksiyonu çağırmaktır.


.. note::
    Solidity'nin önceki sürümleri, bu fonksiyonların rastgele argümanlar almasına izin veriyordu ve ayrıca ``bytes4`` türündeki ilk argümanı farklı şekilde ele alıyorlardı. Bu uç durumlar 0.5.0 sürümünde kaldırılmıştır.

Verilen gazı ``gas`` değiştiricisi ile ayarlamak mümkündür:

.. code-block:: solidity

    address(nameReg).call{gas: 1000000}(abi.encodeWithSignature("register(string)", "MyName"));

Benzer şekilde, sağlanan Ether değeri de kontrol edilebilir:

.. code-block:: solidity

    address(nameReg).call{value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));

Son olarak, bu değiştiriciler birleştirilebilir. Onların sırası önemli değil:

.. code-block:: solidity

    address(nameReg).call{gas: 1000000, value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));

Benzer şekilde, ``delegatecall`` fonksiyonu kullanılabilir: fark, yalnızca verilen adresin kodunun kullanılması, diğer tüm yönlerin (depolama, bakiye, ...) mevcut sözleşmeden alınmasıdır. ``delegatecall`` un amacı, başka bir sözleşmede saklanan kütüphane kodunu kullanmaktır. Kullanıcı, her iki sözleşmedeki depolama düzeninin, kullanılacak temsilci çağrısı için uygun olduğundan emin olmalıdır.


.. note::
    Homestead'den önce, orijinal ``msg.sender`` ve ``msg.value`` değerlerine erişim sağlamayan ``callcode`` adlı yalnızca sınırlı bir değişken mevcuttu. Bu fonksiyon 0.5.0 sürümünde kaldırılmıştır.


Bizans'tan (Byzantium) beri ``staticcall`` da kullanılabilir. Bu temelde ``call`` ile aynıdır, ancak çağrılan fonksiyon durumu herhangi bir şekilde değiştirirse geri döner.

Her üç fonksiyon, ``call``, ``delegatecall`` ve ``staticcall`` çok düşük düzeyli fonksiyonlardır ve Solidity'nin tür güvenliğini bozdukları için yalnızca *son çare* olarak kullanılmalıdır.

``Gas`` seçeneği her üç yöntemde de mevcuttur, ``value`` seçeneği ise yalnızca ``call`` da mevcuttur.


.. note::
    Durumun okunması veya yazılmasından bağımsız olarak akıllı sözleşme kodunuzdaki sabit kodlanmış gaz değerlerine güvenmekten kaçınmak en iyisidir, çünkü bunun birçok tuzağı olabilir. Ayrıca, gelecekte gaza erişim değişebilir.

* ``code`` and ``codehash``

<<<<<<< HEAD
Herhangi bir akıllı sözleşme için dağıtılan kodu sorgulayabilirsiniz. EVM bayt kodunu boş olabilecek bir ``bytes memory`` olarak almak için ``.code`` kullanın. ``.codehash`` kullanın, bu kodun Keccak-256 karmasını alın (``bytes32`` olarak). ``addr.codehash``in ``keccak256(addr.code)`` kullanmaktan daha ucuz olduğunu unutmayın.

=======
You can query the deployed code for any smart contract. Use ``.code`` to get the EVM bytecode as a
``bytes memory``, which might be empty. Use ``.codehash`` to get the Keccak-256 hash of that code
(as a ``bytes32``). Note that ``addr.codehash`` is cheaper than using ``keccak256(addr.code)``.
>>>>>>> v0.8.17

.. note::
    Tüm sözleşmeler ``address`` türüne dönüştürülebilir, bu nedenle ``address(this).balance`` kullanılarak mevcut sözleşmenin bakiyesini sorgulamak mümkündür.

.. index:: ! contract type, ! type; contract

.. _contract_types:

Sözleşme Türleri
-----------------

Her :ref:`sözleşme<contracts>` kendi türünü tanımlar. Sözleşmeleri dolaylı olarak miras aldıkları sözleşmelere dönüştürebilirsiniz. Sözleşmeler açıkça ``address`` türüne dönüştürülebilir.

``address payable`` türüne ve ``address payable`` türünden açık dönüştürme, yalnızca sözleşme türünün bir alacak veya ödenebilir yedek fonksiyonu varsa mümkündür. Dönüştürme hala ``address(x)`` kullanılarak gerçekleştirilir. Sözleşme türünün bir alma veya ödenebilir yedek fonksiyonu yoksa, ``address payable``a dönüştürme ``payable(address(x))`` kullanılarak yapılabilir.


:ref:`Adres türü <address>` ile ilgili bölümde daha fazla bilgi bulabilirsiniz.

.. note::
    0.5.0 sürümünden önce, sözleşmeler doğrudan adres türünden türetilir, ve ``address`` ve ``address payable`` arasında bir ayrım yoktu.

Sözleşme tipinde (``MyContract c``) yerel bir değişken bildirirseniz, o sözleşmedeki fonksiyonları çağırabilirsiniz. Aynı sözleşme türünden bir yerden atamaya özen gösterin.

Ayrıca sözleşmeleri somutlaştırabilirsiniz (bu, sözleşmelerin yeni oluşturuldukları anlamına gelir). Daha fazla ayrıntıyı :ref:`'Contracts via new' <creating-contracts>` bölümünde bulabilirsiniz.

Bir sözleşmenin veri temsili, ``address`` türününkiyle aynıdır ve bu tür aynı zamanda :ref:`ABI<ABI>` içinde kullanılır.

Sözleşmeler hiçbir operatörü desteklemez.

Sözleşme türlerinin üyeleri, ``public`` olarak işaretlenen tüm durum değişkenleri dahil olmak üzere sözleşmenin harici fonksiyonlarıdır.

Bir ``C`` sözleşmesi için, sözleşmeyle ilgili :ref:`tür bilgisine<meta-type>` erişmek için ``type(C)`` yi kullanabilirsiniz.

.. index:: byte array, bytes32

Sabit Boyutlu Bayt Dizileri
-----------------------------

``bytes1``, ``bytes2``, ``bytes3``, ..., ``bytes32`` değer türleri 1'den 32'ye kadar bir bayt dizisini tutar.

Operatörler:

* Karşılaştırmalar: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (``bool`` olarak değerlendir)
* Bit operatörleri: ``&``, ``|``, ``^`` (bit düzeyinde özel veya), ``~`` (bitsel olumsuzlama)
* Shift operatörleri: ``<<`` (sol shift), ``>>`` (sağ shift)
* Dizin erişimi: ``x``, ``bytesI`` türündeyse, ``0 <= k < I`` için ``x[k]``, ``k`` ıncı baytı (salt okunur) döndürür.


Kaydırma operatörü, sağ işlenen olarak işaretsiz tamsayı türüyle çalışır (ancak sol işlenenin türünü döndürür), bu, kaydırılacak bit sayısını belirtir. İmzalı bir türe göre kaydırma, bir derleme hatası üretecektir.

Üyeler:

* ``.length``, bayt dizisinin sabit uzunluğunu verir (salt okunur).

.. note::
    ``bytes1[]`` türü bir bayt dizisidir, ancak doldurma kuralları nedeniyle her öğe için (depolama dışında) 31 baytlık alan harcar. Bunun yerine ``bytes`` türünü kullanmak daha iyidir.

.. note::
    0.8.0 sürümünden önce, ``byte``, ``bytes1`` için bir takma addı.

Dinamik Olarak Boyutlandırılmış Bayt Dizisi
--------------------------------------------

``bytes``:
    Dinamik olarak boyutlandırılmış bayt dizisi, bkz. :ref:`arrays`. Bir değer türü değil!
``string``:
    Dinamik olarak boyutlandırılmış UTF-8 kodlu dize, bkz.:ref:`arrays`. Bir değer türü değil!

.. index:: address, literal;address

.. _address_literals:

Adres Değişmezleri
-------------------

Adres sağlama toplamı (checksum) testini geçen onaltılık sabit değerler, örneğin ``0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF``, ``address`` türündedir.

39 ila 41 basamak uzunluğunda olan ve sağlama toplamı (checksum) testini geçmeyen onaltılık değişmez değerler bir hata üretir. Hatayı kaldırmak için başa (tamsayı türleri için) veya sona(bytesNN türleri için) sıfırlar ekleyebilirsiniz.


.. note::
    Karışık büyük/küçük harfli adres sağlama toplamı biçimi, `EIP-55 <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md>`_ içinde tanımlanır.

.. index:: literal, literal;rational

.. _rational_literals:

Rasyonel ve Tamsayı Değişmezleri
---------------------------------

Tamsayı değişmezleri, 0-9 aralığında bir basamak dizisinden oluşturulur. Ondalık sayılar olarak yorumlanırlar. Örneğin, ``69`` altmış dokuz anlamına gelir. Solidity'de sekizlik değişmez değerler yoktur ve baştaki sıfırlar geçersizdir.

Ondalık kesirli değişmezler, ``.``'nın ardından en az bir sayı yerleştirilmesi ile oluşturulur. Örnekler arasında ``.1`` ve ``1.3`` bulunur (``1.`` geçersizdir).

Mantisin kesirli olabileceği ancak üssün bir tamsayı olması gereken ``2e10`` şeklindeki bilimsel gösterim de desteklenmektedir. ``MeE`` değişmez değeri, ``M * 10**E`` ile eşdeğerdir. Örnekler arasında ``2e10``, ``-2e10``, ``2e-10``, ``2.5e1`` yer alır.

Okunabilirliğe yardımcı olmak için sayısal bir hazır bilginin basamaklarını ayırmak için alt çizgiler kullanılabilir. Örneğin, ondalık (decimal) ``123_000``, onaltılık (hexadecimal) ``0x2eff_abde``, bilimsel ondalık gösterim ``1_2e345_678`` hepsi geçerlidir. Alt çizgiye yalnızca iki basamak arasında izin verilir ve yalnızca bir ardışık alt çizgiye izin verilir. Alt çizgi içeren bir sayı değişmezine ek bir anlamsal anlam eklenmez, alt çizgiler yoksayılır.


Sayı değişmezi ifadeleri, sabit olmayan bir türe dönüştürülene kadar (yani, bunları bir sayı değişmezi ifadesi (boolean değişmezleri gibi) dışında herhangi bir şeyle birlikte kullanarak veya açık dönüştürme yoluyla) isteğe bağlı kesinliği korur. Bu, hesaplamaların taşmadığı ve bölmelerin sayı değişmez ifadelerinde kesilmediği anlamına gelir.

Örneğin, ``(2**800 + 1) - 2**800``, ara sonuçlar makine kelime boyutuna bile sığmasa da ``1`` sabitiyle sonuçlanır (``uint8`` türünden). Ayrıca, ``.5 * 8``, ``4``  tamsayısıyla sonuçlanır (arada tamsayı olmayanlar kullanılmasına rağmen).


.. warning::
    Çoğu operatör, değişmez değerlere uygulandığında değişmez bir ifade üretirken, bu kalıbı takip etmeyen bazı operatörler vardır:

    - Üçlü operatör (``... ? ... : ...``),
    - Dizi alt simgesi (subscript) (``<array>[<index>]``).

    ``255 + (true ? 1 : 0)`` veya ``255 + [1, 2, 3][0]`` gibi ifadelerin doğrudan 256 değişmezini kullanmaya eşdeğer olmasını bekleyebilirsiniz, ancak aslında bunlar ``uint8`` türünde hesaplanır ve taşabilir.

Tamsayılara uygulanabilen herhangi bir operatör, işlenenler tamsayı olduğu sürece sayı değişmez ifadelerine de uygulanabilir. İkisinden herhangi biri kesirliyse, bit işlemlerine izin verilmez ve üs kesirliyse üs almaya izin verilmez (çünkü bu rasyonel olmayan bir sayıya neden olabilir).

Sol (veya taban) işlenen olarak değişmez sayılar ve sağ (üs) işlenen olarak tamsayı türleri ile kaydırmalar ve üs alma, her zaman "uint256" (negatif olmayan değişmezler için) veya sağ (üs) işlenenin türünden bağımsız olarak "int256" (negatif değişmezler için) içinde gerçekleştirilir.


.. warning::
    0.4.0 sürümünden önce Solidity'de tamsayı değişmezleri üzerinde bölme kullanılırdı, ancak şimdi rasyonel bir sayıya dönüştürülür, yani ``5 / 2``, ``2`` ye eşit değil, ``2.5`` e eşittir .

.. note::
    Solidity, her rasyonel sayı için bir sayı değişmez (literal) tipine sahiptir. Tamsayı değişmezleri ve rasyonel sayı değişmezleri, sayı değişmez türlerine aittir. Ayrıca, tüm sayı değişmez ifadeleri (yani yalnızca sayı değişmezlerini ve işleçlerini içeren ifadeler) sayı değişmez türlerine aittir. Dolayısıyla, ``1 + 2`` ve ``2 + 1`` sayı değişmez ifadelerinin her ikisi de üç rasyonel sayı için aynı sayı değişmez türüne aittir.


.. note::
    Sayı değişmez ifadeleri, değişmez olmayan ifadelerle birlikte kullanılır kullanılmaz, değişmez bir türe dönüştürülür. Türlerden bağımsız olarak, aşağıdaki ``b``ye atanan ifadenin değeri bir tamsayı olarak değerlendirilir. "a", "uint128" türünde olduğundan, "2.5 + a" ifadesinin uygun bir türe sahip olması gerekir. ``2.5`` ve ``uint128`` tipi için ortak bir tip olmadığı için Solidity derleyicisi bu kodu kabul etmez.

.. code-block:: solidity

    uint128 a = 1;
    uint128 b = 2.5 + a + 0.5;

.. index:: literal, literal;string, string
.. _string_literals:

Dize Değişmezleri ve Türleri
------------------------------

Dize değişmezleri ya çift ya da tek tırnak (``"foo"`` veya ``'bar'``) ile yazılır ve ayrıca uzun dizelerle uğraşırken yardımcı olabilecek şekilde birden çok ardışık parçaya bölünebilirler (``"foo" "bar"``, ``"foobar"`` ile eşdeğerdir). C'deki gibi sondaki sıfırları ima etmezler; ``"foo"`` dört değil, üç baytı temsil eder. Tamsayı değişmezlerinde olduğu gibi, türleri değişebilir, ancak sığarlarsa "bytes1", ..., "bytes32"ye örtük olarak "bytes" ve "string"e dönüştürülebilirler.

Örneğin, ``bytes32 samevar = "stringliteral"`` ile dize değişmezi, bir ``bytes32`` türüne atandığında ham bayt biçiminde yorumlanır.

Dize değişmezleri yalnızca yazdırılabilir ASCII karakterleri içerebilir; bu, 0x20 .. 0x7E arasındaki ve dahil olan karakterler anlamına gelir.

Ayrıca, dize değişmezleri aşağıdaki kaçış karakterlerini de destekler:


- ``\<newline>`` (gerçek bir yeni satırdan kaçar)
- ``\\`` (ters eğik çizgi)
- ``\'`` (tek alıntı)
- ``\"`` (çift alıntı)
- ``\n`` (Yeni satır)
- ``\r`` (satırbaşı)
- ``\t`` (etiket)
- ``\xNN`` (hex kaçış, aşağıya bakınız)
- ``\uNNNN`` (unicode kaçış, aşağıya bakınız)

``\xNN`` bir onaltılık değer alıp uygun baytı eklerken, ``\uNNNN`` bir Unicode kod noktası alır ve bir UTF-8 dizisi ekler.

.. note::
    0.8.0 sürümüne kadar üç ek kaçış dizisi vardı: ``\b``, ``\f`` ve ``\v``. Diğer dillerde yaygın olarak bulunurlar, ancak pratikte nadiren ihtiyaç duyulur. Bunlara ihtiyacınız varsa, yine de diğer ASCII karakterleri gibi, sırasıyla ``\x08``, ``\x0c`` ve ``\x0b`` gibi onaltılık çıkışlar yoluyla eklenebilirler.

Aşağıdaki örnekteki dizenin uzunluğu on bayttır. Yeni satır baytı ile başlar, ardından çift tırnak, tek tırnak, ters eğik çizgi ve ardından (ayırıcı olmadan) ``abcdef`` karakter dizisi gelir.


.. code-block:: solidity
    :force:

    "\n\"\'\\abc\
    def"

Yeni satır olmayan herhangi bir Unicode satır sonlandırıcı (yani LF, VF, FF, CR, NEL, LS, PS) dize değişmezini sonlandırdığı kabul edilir. Yeni satır, yalnızca önünde bir ``\`` yoksa dize değişmezini sonlandırır.


Unicode Değişmezler
--------------------

Normal dize değişmezleri yalnızca ASCII içerebilirken, Unicode değişmezleri ``unicode`` – anahtar kelimesiyle önek – herhangi bir geçerli UTF-8 dizisi içerebilir. Ayrıca, normal dize değişmezleri ile aynı kaçış dizilerini de desteklerler.


.. code-block:: solidity

    string memory a = unicode"Hello 😃";

.. index:: literal, bytes

Onaltılık (Hexadecimal) Değişmezler
-------------------------------------

Onaltılık değişmezlerin önüne ``hex`` anahtar kelimesi getirilir ve çift veya tek tırnak içine alınır (``hex"001122FF"`` , ``hex'0011_22_FF'`` ). İçerikleri, isteğe bağlı olarak bayt sınırları arasında ayırıcı olarak tek bir alt çizgi kullanabilen onaltılık basamaklar olmalıdır. Değişmez değerin değeri, onaltılık dizinin ikili gösterimi olacaktır.

Boşlukla ayrılmış birden çok onaltılık sabit değer, tek bir sabit değerde birleştirilir: ``hex"00112233" hex"44556677"`` , ``hex"0011223344556677"`` ye eşittir

Onaltılık değişmez değerler :ref:`string değişmezleri <string_literals>` gibi davranır ve aynı dönüştürülebilirlik kısıtlamalarına sahiptir.

.. index:: enum

.. _enums:

Numaralandırmalar (Enums)
--------------------------

Numaralandırmalar, Solidity'de kullanıcı tanımlı bir tür oluşturmanın bir yoludur. Tüm tamsayı türlerine açıkça dönüştürülebilirler, ancak örtük dönüştürmeye izin verilmez. Tamsayıdan yapılan açık dönüştürme, çalışma zamanında değerin numaralandırma aralığı içinde olup olmadığını kontrol eder ve aksi takdirde bir :ref:`Panik hatası<assert-and-require>` oluşmasına neden olur. Numaralandırmalar en az bir üye gerektirir ve bildirildiğinde varsayılan değeri ilk üyedir. Numaralandırmaların 256'dan fazla üyesi olamaz.

Veri gösterimi, C'deki numaralandırmalarla aynıdır: Seçenekler, ``0`` dan başlayan müteakip işaretsiz tamsayı değerleriyle temsil edilir.

``type(NameOfEnum).min`` ve ``type(NameOfEnum).max`` kullanarak verilen numaralandırmanın en küçük ve sırasıyla en büyük değerini alabilirsiniz.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.8;

    contract test {
        enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
        ActionChoices choice;
        ActionChoices constant defaultChoice = ActionChoices.GoStraight;

        function setGoStraight() public {
            choice = ActionChoices.GoStraight;
        }

        // Enum türleri ABI'nin bir parçası olmadığından, Solidity'nin dışındaki tüm konular için "getChoice" imzası otomatik olarak "getChoice() returns (uint8)" olarak değiştirilecektir.
        function getChoice() public view returns (ActionChoices) {
            return choice;
        }

        function getDefaultChoice() public pure returns (uint) {
            return uint(defaultChoice);
        }

        function getLargestValue() public pure returns (ActionChoices) {
            return type(ActionChoices).max;
        }

        function getSmallestValue() public pure returns (ActionChoices) {
            return type(ActionChoices).min;
        }
    }

.. note::
    Numaralandırmalar, sözleşme veya kitaplık tanımlarının dışında dosya düzeyinde de bildirilebilir.

.. index:: ! user defined value type, custom type

.. _user-defined-value-types:

Kullanıcı Tanımlı Değer Türleri
---------------------------------

Kullanıcı tanımlı bir değer türü, bir temel değer türü üzerinde sıfır maliyetli bir soyutlama oluşturmaya izin verir. Bu, takma ada benzer, ancak daha katı tür gereksinimleri vardır.

Kullanıcı tanımlı bir değer türü, ``type C is V`` kullanılarak tanımlanır; burada ``C`` yeni tanıtılan türün adıdır ve ``V`` yerleşik bir değer türü olmalıdır ("altta yatan tip"/ "underlying type"). ``C.wrap`` fonksiyonu, temeldeki türden özel türe dönüştürmek için kullanılır. Benzer şekilde, özel türden temel türe dönüştürmek için ``C.unwrap`` fonksiyonu kullanılır.


``C`` türünün herhangi bir işleci veya bağlı üye fonksiyonu yoktur. Özellikle, ``==`` operatörü bile tanımlanmamıştır. Diğer türlere ve diğer türlerden açık ve örtük dönüştürmelere izin verilmez.

Bu türlerin değerlerinin veri temsili, temeldeki türden devralınır ve temel alınan tür de ABI'da kullanılır.

Aşağıdaki örnek, 18 ondalık basamaklı bir ondalık sabit nokta türünü ve tür üzerinde aritmetik işlemler yapmak için bir minimum kitaplığı temsil eden özel bir ``UFixed256x18`` türünü gösterir.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.8;

    // Kullanıcı tanımlı bir değer türü kullanarak 18 ondalık, 256 bit genişliğinde sabit nokta türünü temsil eder.
    type UFixed256x18 is uint256;

    /// UFixed256x18 üzerinde sabit nokta işlemleri yapmak için minimal bir kütüphane.
    library FixedMath {
        uint constant multiplier = 10**18;

        ///İki UFixed256x18 sayısı ekler. uint256'da kontrol edilen aritmetiği temel alarak taşma durumunda geri döner.
        function add(UFixed256x18 a, UFixed256x18 b) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(UFixed256x18.unwrap(a) + UFixed256x18.unwrap(b));
        }
        /// UFixed256x18 ve uint256'yı çarpar. uint256'da kontrol edilen aritmetiği temel alarak taşma durumunda geri döner.
        function mul(UFixed256x18 a, uint256 b) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(UFixed256x18.unwrap(a) * b);
        }
        /// UFixed256x18 numarasının zeminini alın.
        /// "a"yı geçmeyen en büyük tamsayıyı döndürür.
        function floor(UFixed256x18 a) internal pure returns (uint256) {
            return UFixed256x18.unwrap(a) / multiplier;
        }
        /// Bir uint256'yı aynı değerde bir UFixed256x18'e dönüştürür.
        /// Tamsayı çok büyükse geri döner.
        function toUFixed256x18(uint256 a) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(a * multiplier);
        }
    }

``UFixed256x18.wrap`` ve ``FixedMath.toUFixed256x18`` öğelerinin nasıl aynı imzaya sahip olduğuna, ancak çok farklı iki işlem gerçekleştirdiğine dikkat edin: ``UFixed256x18.wrap`` işlevi, girişle aynı veri temsiline sahip bir ``UFixed256x18`` döndürürken, ``toUFixed256x18``, aynı sayısal değere sahip bir ``UFixed256x18`` döndürür.

.. index:: ! function type, ! type; function

.. _function_types:

Fonksiyon Tipleri
------------------

Fonksiyon türleri, kullanulan fonksiyonların türleridir. Fonksiyon tipinin değişkenleri fonksiyonlardan atanabilir ve fonksiyon tipinin fonksiyon parametreleri fonksiyon çağrılarına fonksiyon geçirmek ve fonksiyon çağrılarından fonksiyon döndürmek için kullanılabilir. Fonksiyon türleri iki şekilde gelir - *dahili* ve *harici* fonksiyonlar:


Dahili fonksiyonlar, yalnızca geçerli sözleşmenin içinde (daha spesifik olarak, dahili kitaplık fonksiyonları ve devralınan fonksiyonları da içeren geçerli kod biriminin içinde) çağrılabilir çünkü bunlar geçerli sözleşmenin bağlamı dışında yürütülemezler. Dahili bir fonkaiyonu çağırmak, tıpkı mevcut sözleşmenin bir fonksiyonunu dahili olarak çağırırken olduğu gibi, giriş etiketine atlanarak gerçekleştirilir.

Harici fonksiyonlar bir adres ve bir işlev imzasından oluşur ve bunlar
iletilebilir ve harici fonksiyon çağrılarından döndürülebilir.


Fonksiyon türleri aşağıdaki gibi not edilir:

.. code-block:: solidity
    :force:

    function (<parameter types>) {internal|external} [pure|view|payable] [returns (<return types>)]

Parametre türlerinin aksine, dönüş türleri boş olamaz - fonksiyonun türünün hiçbir şey döndürmemesi gerekiyorsa, ``returns (<return types>)`` bölümünün tamamı atlanmalıdır.

Varsayılan olarak, fonksiyon türleri dahilidir, bu nedenle ``internal`` anahtar sözcüğü atlanabilir. Bunun yalnızca fonksiyon türleri için geçerli olduğunu unutmayın. Sözleşmelerde tanımlanan fonksiyonlar için görünürlük açıkça belirtilmelidir,
varsayılan değer yoktur.

Dönüşümler:

``A`` fonksiyon türü, yalnızca ve yalnızca parametre türleri aynıysa, dönüş türleri aynıysa, dahili/harici özellikleri aynıysa ve ``A`` öğesinin durum değişkenliği aynıysa, dolaylı olarak ``B`` işlev türüne dönüştürülebilir. ``A``, ``B`` durum değişkenliğinden daha kısıtlayıcıdır. Özellikle:

- ``pure`` fonksiyonlar, ``view`` ve ``non-payable`` fonksiyonlara dönüştürülebilir
- ``view`` fonksiyonları ``non-payable`` fonksiyonlara dönüştürülebilir
- ``payable`` fonksiyonlar ``non-payable`` fonksiyonlara dönüştürülebilir

Fonksiyon türleri arasında başka hiçbir dönüşüm mümkün değildir.

``payable`` ve ``non-payable`` fonksiyonlarla alakalı kural biraz kafa karıştırıcı olabilir, ancak özünde, bir fonksiyon ``payable`` ise, bu aynı zamanda sıfır Ether ödemesini de kabul ettiği anlamına gelir, yani bu fonksiyon atrıca ``non-payable``dır. Öte yandan, bir ``non-payable`` fonksiyon kendisine gönderilen Ether'i reddedecektir, bu nedenle ``non-payable`` fonksiyonlar ``payable`` fonksiyonlara dönüştürülemez.

Bir fonksiyon türü değişkeni başlatılmazsa, onu çağırmak bir :ref:`Panik hatası<assert-and-require>` ile sonuçlanır. Aynısı, bir fonksiyon üzerinde ``delete`` kullandıktan sonra çağırırsanız da olur.

Harici fonksiyon türleri, Solidity bağlamı dışında kullanılırsa, adres ve ardından fonksiyon tanımlayıcısını birlikte tek bir ``bytes24`` türünde kodlayan ``function`` türü olarak kabul edilirler.

Mevcut sözleşmenin genel (public) fonksiyonlarının hem dahili hem de harici (external) bir fonksiyon olarak kullanılabileceğini unutmayın. ``f`` yi dahili bir fonksiyon olarak kullanmak için ``f`` yi kullanın, harici biçimini kullanmak istiyorsanız ``this.f`` yi kullanın.

Dahili tipte bir fonksiyon, nerede tanımlandığına bakılmaksızın dahili fonksiyon tipindeki bir değişkene atanabilir. Bu, hem sözleşmelerin hem de kütüphanelerin özel, dahili ve genel fonksiyonlarını ve ayrıca ücretsiz fonksiyonlarını içerir. harici fonksiyon türleri ise yalnızca genel (public) ve harici (external) sözleşme fonksiyonlarıyla uyumludur. Kitaplıklar, bir ``delegatecall`` gerektirdikleri ve :ref:`seçicileri için farklı bir ABI kuralı <library-selectors>` kullandıkları için hariç tutulur. Arayüzlerde bildirilen fonksiyonların tanımları yoktur, bu nedenle onlara işaret etmek de bir anlam ifade etmez.


Üyeler:

Harici (veya genel) fonksiyonlar aşağıdaki üyelere sahiptir:

* ``.address`` fonksiyonun sözleşmesinin adresini döndürür.
* ``.selector``, :ref:`BI işlev seçicisini <abi_function_selector>` döndürür

.. note::
    Harici (veya genel) fonksiyonlar, ``.gas(uint)`` ve ``.value(uint)`` ek üyelerine sahiptiler. Bunlar Solidity 0.6.2'de tartışmaya açıldı ve Solidity 0.7.0'da kaldırıldı. Bunun yerine, bir fonksiyona gönderilen gaz miktarını veya wei miktarını belirtmek için sırasıyla ``{gas: ...}`` ve ``{value: ...}`` kullanın. Daha fazla bilgi için bkz. :ref:`External Function Calls <external-function-calls>` .

Üyelerin nasıl kullanılacağını gösteren örnek:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.4 <0.9.0;

    contract Example {
        function f() public payable returns (bytes4) {
            assert(this.f.address == address(this));
            return this.f.selector;
        }

        function g() public {
            this.f{gas: 10, value: 800}();
        }
    }

Dahili fonksiyon türlerinin nasıl kullanılacağını gösteren örnek:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library ArrayUtils {
        // aynı kod bağlamının parçası olacakları için dahili fonksiyonlar dahili kütüphane fonksiyonlarında kullanılabilir
        function map(uint[] memory self, function (uint) pure returns (uint) f)
            internal
            pure
            returns (uint[] memory r)
        {
            r = new uint[](self.length);
            for (uint i = 0; i < self.length; i++) {
                r[i] = f(self[i]);
            }
        }

        function reduce(
            uint[] memory self,
            function (uint, uint) pure returns (uint) f
        )
            internal
            pure
            returns (uint r)
        {
            r = self[0];
            for (uint i = 1; i < self.length; i++) {
                r = f(r, self[i]);
            }
        }

        function range(uint length) internal pure returns (uint[] memory r) {
            r = new uint[](length);
            for (uint i = 0; i < r.length; i++) {
                r[i] = i;
            }
        }
    }


    contract Pyramid {
        using ArrayUtils for *;

        function pyramid(uint l) public pure returns (uint) {
            return ArrayUtils.range(l).map(square).reduce(sum);
        }

        function square(uint x) internal pure returns (uint) {
            return x * x;
        }

        function sum(uint x, uint y) internal pure returns (uint) {
            return x + y;
        }
    }

Harici işlev türlerini kullanan başka bir örnek:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;


    contract Oracle {
        struct Request {
            bytes data;
            function(uint) external callback;
        }

        Request[] private requests;
        event NewRequest(uint);

        function query(bytes memory data, function(uint) external callback) public {
            requests.push(Request(data, callback));
            emit NewRequest(requests.length - 1);
        }

        function reply(uint requestID, uint response) public {
            // Cevabın güvenilir bir kaynaktan gelip gelmediği kontrol edilir
            requests[requestID].callback(response);
        }
    }


    contract OracleUser {
        Oracle constant private ORACLE_CONST = Oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa)); // known contract
        uint private exchangeRate;

        function buySomething() public {
            ORACLE_CONST.query("USD", this.oracleResponse);
        }

        function oracleResponse(uint response) public {
            require(
                msg.sender == address(ORACLE_CONST),
                "Only oracle can call this."
            );
            exchangeRate = response;
        }
    }

.. note::
    Lambda veya satır içi işlevler planlanmıştır ancak henüz desteklenmemektedir.
