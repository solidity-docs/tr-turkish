.. index:: abi, application binary interface

.. _ABI:

*****************************
Sözleşme ABI Spesifikasyonu
*****************************

Temel Tasarım
===============

Sözleşme Uygulama Binary Arayüzü (ABI), Ethereum ekosistemindeki sözleşmelerle hem
blok zinciri dışından hem de sözleşmeler arası etkileşimde bulunmanın standart yoludur.
Veriler, bu spesifikasyonda açıklandığı gibi türlerine göre kodlanır. Şifreleme kendi
kendini tanımlamaz ve bu nedenle şifreyi çözmek için bir şema gerekir.

Bir sözleşmenin arayüz fonksiyonlarının güçlü bir şekilde yazıldığını, derleme zamanında
bilindiğini ve statik olduğunu varsayıyoruz. Tüm sözleşmelerin, çağırdıkları sözleşmelerin
arayüz tanımlamalarına derleme zamanında sahip olacağını varsayıyoruz.

Bu spesifikasyon, arayüzü dinamik olan veya başka bir şekilde yalnızca çalışma zamanında
bilinen sözleşmeleri ele almaz.

.. _abi_function_selector:
.. index:: ! selector; of a function

Function Selector (Function Selector)
===========================================

Bir fonksiyon çağrısı için çağrı verisinin(call data) ilk dört baytı çağrılacak
fonksiyonu belirtmektedir. Bu, fonksiyonun imzasının Keccak-256 hash'inin ilk (sol,
büyük endian'da yüksek dereceden) dört baytıdır. İmza, veri konumu belirteci olmadan
temel prototipin kanonik ifadesi, yani parametre türlerinin parantezli listesiyle
birlikte fonksiyon adı olarak tanımlanır. Parametre tipleri tek bir virgülle ayrılır -
boşluk kullanılmaz.

.. note::
    Bir fonksiyonun geri dönüş tipi bu imzanın bir parçası değildir. ref:`Solidity'nin
    fonksiyon aşırı yüklemesinde(overloading) <overload-function>` dönüş tipleri dikkate
    alınmaz. Bunun nedeni, fonksiyon çağrısı çözümlemesini içerikten bağımsız tutmaktır.
    Ancak :ref:`JSON ABI<abi_json>` tanımı hem girdileri hem de çıktıları içerir.

Argüman Şifreleme
=================

Beşinci bayttan başlayarak şifrelenmiş tüm argümanları takip eder. Bu şifreleme
başka yerlerde de kullanılır, örneğin geri dönüş değerleri ve event argümanları,
fonksiyonu belirten dört bayt olmadan aynı şekilde şifrelenir.

Tipler (Types)
==================

Aşağıdaki ana tipler mevcuttur:

- ``uint<M>``: ``M`` bitlik işaretsiz tamsayı (unsigned) türü, ``0 < M <= 256``, ``M % 8 == 0``. e.g. ``uint32``, ``uint8``, ``uint256``.

- ``int<M>``: ``M`` bitlik ikiye tamamlayıcı işaretli tamsayı (signed integer) türü, ``0 < M <= 256``, ``M % 8 == 0``.

- ``address``: varsayılan değerlendirme ve dil yazımı dışında ``uint160`` ile eşdeğerdir.  Fonksiyon seçicisini hesaplarken ``address`` kullanılır.

- ``uint``, ``int``: sırasıyla ``uint256``, ``int256`` için eş anlamlı terimlerdir. Fonksiyon seçicisini hesaplamak için ``uint256`` ve ``int256`` kullanılmalıdır.

- ``bool``: 0 ve 1 değerleriyle sınırlandırılmış ``uint8`` ile eşdeğerdir. Fonksiyon seçicisini hesaplamak için ``bool`` kullanılır.

- ``fixed<M>x<N>``: ``M`` bitlerinin işaretli(signed) fixed-point ondalık sayısı, ``8 <= M <= 256``,
  ``M % 8 == 0`` ve ``0 < N <= 80``, ``v`` değerini ``v / (10 ** N)`` olarak gösterir.

- ``ufixed<M>x<N>``: ``fixed<M>x<N>`` öğesinin işaretsiz(unsigned) varyantı.

- ``fixed``, ``ufixed``: sırasıyla ``fixed128x18``, ``ufixed128x18`` için eş anlamlı terimlerdir. Fonksiyon seçiciyi hesaplamak için ``fixed128x18`` ve ``ufixed128x18`` kullanılmalıdır.

- ``bytes<M>``: ``M`` baytlarının binary tipi, ``0 < M <= 32``.

- ``function``: bir adres (20 bayt) ve ardından bir fonksiyon seçici (4 bayt). ``bytes24`` ile aynı biçimde şifrelenir.

Aşağıdaki (sabit boyutlu) dizi türü bulunmaktadır:

- ``<tip>[M]``: verilen tipte bulunan ``M`` elemanlı, ``M >= 0``, sabit uzunlukta bir dizidir.

  .. note::

      Bu ABI spesifikasyonu sıfır elemanlı sabit uzunluklu dizileri ifade edebilse de, bunlar derleyici tarafından desteklenmez.

Aşağıdaki sabit boyutlu olmayan tipler de mevcuttur:

- ``bytes``: dinamik boyutlu bayt sırası.

- ``string``: UTF-8 şifrelenmiş olduğu varsayılan dinamik boyutlu unicode bir dizedir.

- ``<type>[]``: belirtilen tipteki elemanlardan oluşan değişkenlik gösterebilen uzunlukta bir dizidir.

Tipler, virgülle ayrılmış parantezler içine alınarak bir tuple olarak birleştirilebilir:

- ``(T1,T2,...,Tn)``: ``T1``, ..., ``Tn`` tiplerinden oluşan bir tuple, ``n >= 0``

Tuple'ların tuple'larını, tuple'ların dizilerini ve benzerlerini oluşturmak mümkündür. Sıfır tuple oluşturmak da mümkündür ( genellikle ``n == 0``).

Solidity'yi ABI Tipleriyle Eşleştirme
--------------------------------------

Solidity, tuple'lar haricinde yukarıda aynı adlandırmalarla sunulan tüm tipleri
destekler. Öte yandan, bazı Solidity tipleri ABI tarafından desteklenmez. Aşağıdaki
tabloda sol sütunda bulunan ve ABI'nin bir parçası olmayan Solidity tipleri ve sağ
sütunda ise bunları temsil eden ABI tipleri verilmiştir.

+-------------------------------+-----------------------------------------------------------------------------+
|      Solidity                 |                                           ABI                               |
+===============================+=============================================================================+
|:ref:`address payable<address>`|``address``                                                                  |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`contract<contracts>`     |``address``                                                                  |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`enum<enums>`             |``uint8``                                                                    |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`kullanıcı tanımlı        |temel değer tipi                                                             |
|değişken tipleri               |                                                                             |
|<user-defined-value-types>`    |                                                                             |
+-------------------------------+-----------------------------------------------------------------------------+
|:ref:`struct<structs>`         |``tuple``                                                                    |
+-------------------------------+-----------------------------------------------------------------------------+

.. warning::
    ``0.8.0`` sürümünden önce enumlar 256`dan fazla elemana sahip olabiliyordu ve
    herhangi bir elemanın değerini tutmaya yetebilecek büyüklükteki en küçük tamsayı tipiyle ifade ediliyordu.

Şifreleme için Tasarım Kriterleri
=============================================

Şifreleme aşağıdaki özelliklere sahip olacak şekilde tasarlanmıştır; bu özellikler özellikle bazı bağımsız değişkenlerin iç içe diziler olması halinde kullanışlıdır:

1. Bir değere erişmek için gereken okuma sayısı en büyük değerin argüman dizi yapısı
   içinde sahip olduğu derinlik kadardır, yani ``a_i[k][l][r]`` öğesini almak için dört
   okuma gerekir. ABI'nin önceki bir sürümünde, okuma sayısı en kötü senaryoda toplam
   dinamik parametre sayısı ile doğrusal olarak ölçeklenmekteydi.

2. Bir değişken veya dizi elemanının verileri diğer verilerle iç içe geçmez ve yeniden
   konumlandırılabilir, yani yalnızca ilişkili "adresler" kullanabilirler.


Şifrelemenin Formal Spesifikasyonu
====================================

Statik ve dinamik türleri birbirinden ayırırız. Statik tipler yerinde şifrelenirken,
dinamik tipler mevcut bloktan sonra ayrı olarak atanmış bir konumda şifrelenir.

**Tanım:** Aşağıdaki tipler "dinamik" olarak adlandırılır:

* ``bytes``
* ``string``
* Herhangi bir ``T`` için ``T[]``
* Herhangi bir dinamik ``T`` ve herhangi bir ``k >= 0`` için ``T[k]``
* ``(T1,...,Tk)`` eğer ``Ti`` bazı ``1 <= i <= k`` için dinamik yapıda ise

Diğer tüm türler "statik" olarak adlandırılır.

**Tanım:** ``len(a)``, ``a`` binary dizesinde bulunan bayt sayısıdır.
Ayrıca ``len(a)`` türünün ``uint256`` olduğu varsayılır.

Gerçek şifreleme olan ``enc``i, ABI tiplerindeki değerlerin binary stringlere eşlenmesi
olarak tanımlıyoruz, öyle ki ``len(enc(X))`` ancak ve ancak ``X`` tipi dinamik olduğu
durumlarda ``X`` değerine bağlı olacaktır.

**Tanım:** For any ABI value ``X``, we recursively define ``enc(X)``, depending
on the type of ``X`` being

- ``(T1,...,Tk)`` için ``k >= 0`` ve herhangi bir ``T1``, ..., ``Tk`` tipi

  ``enc(X) = head(X(1)) ... head(X(k)) tail(X(1)) ... tail(X(k))``

  Burada ``X = (X(1), ..., X(k))`` ve ``head`` ve ``tail`` ``Ti`` için aşağıdaki gibi tanımlanır:

  eğer ``Ti`` statik ise:

    ``head(X(i)) = enc(X(i))`` ve ``tail(X(i)) = ""`` (boş dize)

  Aksi takdirde, yani ``Ti`` dinamik ise:

    ``head(X(i)) = enc(len( head(X(1)) ... head(X(k)) tail(X(1)) ... tail(X(i-1)) ))``
    ``tail(X(i)) = enc(X(i))`` 

    Dinamik durumlarda, ``head(X(i))`` ifadesi iyi tanımlanmıştır çünkü başlık parçalarının
    uzunlukları değerlere değil sadece tiplere bağlıdır. ``head(X(i))`` değeri, ``enc(X)``
    öğesinin başlangıç noktasına göre ``tail(X(i))`` öğesinin başlangıç noktasındaki ofset değeridir.

- Herhangi bir ``T`` ve ``k`` için ``T[k]``:

  ``enc(X) = enc((X[0], ..., X[k-1]))``

  Yani, aynı tipte ``k`` elemanlı bir tuple gibi şifrelenir.

- Herhangi bir ``T`` ve ``k`` için ``T[k]``:

  ``enc(X) = enc((X[0], ..., X[k-1]))``

  Yani, aynı tipte ``k`` elemanlı bir tuple gibi şifrelenir.

- k`` uzunluğunda ``bytes`` (``uint256`` tipinde olduğu varsayılır):

  ``enc(X) = enc(k) pad_right(X)``, yani bayt sayısı bir ``uint256`` olarak şifrelenir,
  ardından bayt sırası olarak ``X``in gerçek değeri ve sonrasında ``len(enc(X))``
  32'nin katı olacak uzunlukta minimum sıfır bayt sayısı gelir.

- ``string``:

  ``enc(X) = enc(enc_utf8(X))``, yani ``X`` UTF-8 biçiminde şifrelenir ve bu değer
  ``bytes`` türünde olarak değerlendirilir ve ardından şifreli hale getirilir. Bu
  sonraki şifreleme işleminde kullanılan uzunluğun karakter sayısı değil, UTF-8 kodlu
  stringin bayt sayısı olduğuna dikkat edin.

- ``uint<M>``: ``enc(X)``, ``X``'in big-endian biçimindeki şifrelemesi olup, uzunluğu 32 bayt olacak şekilde yüksek dereceden (sol) tarafı sıfır bayt ile doldurulmuştur.
- ``address``: ``uint160`` örneğinde olduğu gibi
- ``int<M>``: ``enc(X)``, negatif ``X`` için ``0xff`` baytları ile ve negatif olmayan ``X`` değerleri için sıfır baytları ile doldurulmuş ve uzunluğu 32 bayt olacak şekilde ``X``'in big-endian ikiye tamamlayıcı şifrelemesidir.
- ``bool``: ``uint8`` örneğinde olduğu gibi, ``true`` için ``1`` ve ``false`` için ``0`` değerini kullanır.
- ``fixed<M>x<N>``: ``enc(X)``, ``enc(X * 10**N)``dir; burada ``X * 10**N`` bir ``int256`` olarak yorumlanmaktadır..
- ``fixed``: ``fixed128x18`` örneğinde olduğu gibi
- ``ufixed<M>x<N>``: ``enc(X)``, ``enc(X * 10**N)``dir; burada ``X * 10**N`` bir ``uint256`` olarak yorumlanmaktadır.
- ``ufixed``: ``ufixed128x18`` örneğinde olduğu gibi
- ``bytes<M>``: ``enc(X)``, ``X`` içindeki baytların sondaki sıfır baytlarla beraber 32 bayt uzunluğa kadar doldurulmuş bir sırasıdır.

Herhangi bir ``X`` için ``len(enc(X))`` değerinin 32’nin bir katı olduğuna dikkat edin.

Fonksiyon Seçicisi ve Argüman Şifrelemesi
====================================================

Sonuç olarak, ``f`` fonksiyonuna ``a_1, ..., a_n`` parametreleri ile yapılan bir çağrı şu şekilde şifrelenir

``function_selector(f) enc((a_1, ..., a_n))``

ve ``f``nin ``v_1, ..., v_k`` dönüş değerleri şu şekilde şifrelenmektedir.

  ``enc((v_1, ..., v_k))``

yani değerler bir tuple halinde birleştirilir ve kodlanır.

Örnekler
========

Sözleşmeye göre:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract Foo {
        function bar(bytes3[2] memory) public pure {}
        function baz(uint32 x, bool y) public pure returns (bool r) { r = x > 32 || y; }
        function sam(bytes memory, bool, uint[] memory) public pure {}
    }


Böylece ``Foo`` örneğimiz için ``69`` ve ``true`` parametreleriyle ``baz`` ı çağırmak istersek, toplam 68 bayt iletiriz, bu da şu şekilde ayrılabilir:

- ``0xcdcd77c0``: Method ID. Bu, ``baz(uint32,bool)`` imzasının ASCII formunun Keccak hash'inin ilk 4 baytı olacak şekilde türetilecektir.
- ``0x000000000000000000000000000000000000000000000045``: ilk parametre, 32 bayta doldurulmuş bir uint32 değeri ``69``
- ``0x00000000000000000000000000000000000000000001``: ikinci parametre - boolean ``true``, 32 bayta kadar doldurulur

Toplam olarak:

.. code-block:: none

    0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001

Tek bir ``bool`` döndürür. Örneğin, ``false`` döndürürse, çıktısı tek bir bool olan
``0x0000000000000000000000000000000000000000000000000000000000000000`` tek bayt dizisi olacaktır.

Eğer ``bar`` argümanını ``["abc", "def"]`` ile çağırmak isteseydik, toplam 68 bayt aktarmamız gerekirdi:

- ``0xfce353f6``: Method ID. Bu, ``bar(bytes3[2])`` imzasından türetilmiştir.
- ``0x6162630000000000000000000000000000000000000000000000000000000000``: ilk parametrenin ilk kısmı, bir ``bytes3`` değeri olan ``"abc"`` (sola hizalı).
- ``0x6465660000000000000000000000000000000000000000000000000000000000``: ilk parametrenin ikinci kısmı, bir ``bytes3`` değeri olan ``"def"`` (sola hizalı).

Toplam olarak:

.. code-block:: none

    0xfce353f661626300000000000000000000000000000000000000000000000000000000006465660000000000000000000000000000000000000000000000000000000000

Eğer ``sam``ı ``"dave"``, ``true`` ve ``[1,2,3]`` argümanlarıyla çağırmak isteseydik, toplam 292 bayt aktarmamız gerekirdi:

- ``0xa5643bf2``: Method ID. Bu, ``sam(bytes,bool,uint256[])`` imzasından türetilmiştir. Burada ``uint`` yerine onun kanonik bir gösterimi olan ``uint256``’nın kullanıldığını unutmayın.
- ``0x0000000000000000000000000000000000000000000000000000000000000060``: argüman bloğunun başlangıcından itibaren bayt cinsinden ölçülen ilk parametrelerinin (dinamik tipteki) veri bölümünün konumu. Bu örnekte, ``0x60`` tır.
- ``0x0000000000000000000000000000000000000000000000000000000000000001``: ikinci parametre: boolean true.
- ``0x00000000000000000000000000000000000000000000000000000000000000a0``: üçüncü parametrenin (dinamik tipteki) veri parçasının bayt cinsinden belirlenen konumu. Bu durumda, ``0xa0`` dır.
- ``0x0000000000000000000000000000000000000000000000000000000000000004``: ilk argümanın veri parçası, bayt dizisinin elemanlar cinsinden uzunluğu ile başlar, bu örnekte 4'tür.
- ``0x6461766500000000000000000000000000000000000000000000000000000000``: ilk argümanın içeriği: ``"dave"`` ifadesinin UTF-8 (bu durumda ASCII'ye eşittir) şifrelenmesi, sağdan 32 bayt olacak kadar uzunlukta doldurulur.
- ``0x0000000000000000000000000000000000000000000000000000000000000003``: üçüncü bağımsız değişkenin veri bölümü, dizinin eleman cinsinden uzunluğu ile başlar, bu durumda 3'tür.
- ``0x0000000000000000000000000000000000000000000000000000000000000001``: üçüncü parametrenin ilk giriş değeri.
- ``0x0000000000000000000000000000000000000000000000000000000000000002``: üçüncü parametrenin ikinci giriş değeri.
- ``0x0000000000000000000000000000000000000000000000000000000000000003``: üçüncü parametrenin üçüncü giriş değeri.

Toplam olarak:

.. code-block:: none

    0xa5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003

Dinamik Tiplerin Kullanımı
=================================

``f(uint256,uint32[],bytes10,bytes)`` imzalı olan bir fonksiyona ``(0x123, [0x456, 0x789], "1234567890", "Hello, world!")`` değerleriyle yapılan herhangi bir çağrı aşağıdaki şekilde şifrelenecektir:

``sha3("f(uint256,uint32[],bytes10,bytes)")`` ifadesinin ilk dört baytını, yani
``0x8be65246`` ifadesini alıyoruz. Daha sonra bu dört argümanın baş kısımlarını
şifreliyoruz. Statik ``uint256`` ve ``bytes10`` tipleri açısından bunlar doğrudan
iletmek istediğimiz değerlerdir, dinamik ``uint32[]`` ve ``bytes`` tipleri açısından
ise değerlerin şifrelemesinin başlangıcından itibaren ölçülen (yani fonksiyon imzasının
özetini içeren ilk dört baytı saymadan önce) veri bölgelerinin başlangıcındaki bayt
cinsindeki ofseti kullanırız. Bunlar:

- ``0x0000000000000000000000000000000000000000000000000000000000000123`` (``0x123`` 32 bayta kadar doldurulmuş)
- ``0x0000000000000000000000000000000000000000000000000000000000000080`` (ikinci parametrenin veri kısmının baş kısmındaki ofset değeri, 4*32 bayt, tam olarak baş kısmının boyutu kadardır)
- ``0x3132333435363738393000000000000000000000000000000000000000000000`` (``"1234567890"`` sağda 32 bayta olacak kadar doldurulmuş)
- ``0x00000000000000000000000000000000000000000000000000000000000000e0`` (dördüncü parametrenin veri bölümünde bulunan başlangıç ofseti = birinci dinamik parametrenin veri bölümünde bulunan başlangıç ofseti + birinci dinamik parametrenin veri bölümünün boyutu = 4\*32 + 3\*32 (aşağı bakınız))

Bundan sonra, ilk dinamik argümanın veri kısmı olan ``[0x456, 0x789]`` gelir:

- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (dizinin eleman sayısı, 2)
- ``0x0000000000000000000000000000000000000000000000000000000000000456`` (ilk eleman)
- ``0x0000000000000000000000000000000000000000000000000000000000000789`` (ikinci eleman)

Son olarak, ikinci dinamik argümanın veri kısmını şifreliyoruz, ``"Hello, world!``:

- ``0x000000000000000000000000000000000000000000000000000000000000000d`` (eleman sayısı (bu örnekte bayt): 13)
- ``0x48656c6c6f2c20776f726c642100000000000000000000000000000000000000`` (``"Hello, world!"`` sağda 32 bayt olacak kadar doldurulmuş)

Hepsi birlikte, şifreleme ( fonksiyon seçiciden sonra satır sonu ve anlaşılabilirlik için her biri 32 bayt) şeklindedir:

.. code-block:: none

    0x8be65246
      0000000000000000000000000000000000000000000000000000000000000123
      0000000000000000000000000000000000000000000000000000000000000080
      3132333435363738393000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000e0
      0000000000000000000000000000000000000000000000000000000000000002
      0000000000000000000000000000000000000000000000000000000000000456
      0000000000000000000000000000000000000000000000000000000000000789
      000000000000000000000000000000000000000000000000000000000000000d
      48656c6c6f2c20776f726c642100000000000000000000000000000000000000

Aynı prensibi ``g(uint256[][],string[])`` imzalı olan bir fonksiyonun verilerini
``([[1, 2], [3]], ["bir", "iki", "üç"])`` değerleriyle şifrelemek için uygulayalım,
ancak şifreleme işleminin en atomik kısımlarından başlayalım:

İlk olarak, birinci kök dizisinin ``[[1, 2], [3]]`` birinci gömülü dinamik dizisinin ``[1, 2]`` uzunluğunu ve verilerini şifreleyeceğiz:

- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (ilk dizideki eleman sayısı, 2; elemanların kendileri ``1`` ve ``2``)
- ``0x0000000000000000000000000000000000000000000000000000000000000001`` (ilk eleman)
- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (ikinci eleman)

Ardından, ilk kök dizisinin ``[[1, 2], [3]]`` ikinci gömülü dinamik dizisinin ``[3]`` uzunluğunu ve verilerini şifreleyeceğiz:

- ``0x0000000000000000000000000000000000000000000000000000000000000001`` (ikinci dizideki eleman sayısı, 1; eleman ``3`` tür)
- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (ilk eleman)

Daha sonra ``[1, 2]`` ve ``[3]`` dinamik dizileri için ``a`` ve ``b`` ofsetlerini
bulmamız gerekir. Ofsetleri hesaplamak için, şifrelenmiş her satırı numaralandırarak
ilk kök dizinin ``[[1, 2], [3]]`` şifrelenmiş verilerine bakabiliriz:

.. code-block:: none

    0 - a                                                                - [ 1, 2 ] ofseti
    1 - b                                                                - [3] ofseti
    2 - 0000000000000000000000000000000000000000000000000000000000000002 - [1, 2] için sayım
    3 - 0000000000000000000000000000000000000000000000000000000000000001 - 1 şifrelemesi
    4 - 0000000000000000000000000000000000000000000000000000000000000002 - 2 şifrelemesi
    5 - 0000000000000000000000000000000000000000000000000000000000000001 - [3] için sayım
    6 - 0000000000000000000000000000000000000000000000000000000000000003 - 3 şifrelemesi

``a`` ofseti, 2. satır (64 bayt) olan ``[1, 2]`` dizisinin içeriğinin başlangıcına
doğru işaret eder; dolayısıyla ``a = 0x000000000000000000000000000000000000000000000040``.

``b`` ofseti ``[3]`` dizisinin içeriğinin başlangıcına işaret eder, bu da 5. satır
demektir (160 bayt); dolayısıyla ``b = 0x00000000000000000000000000000000000000000000000000a0``.


Daha sonra ikinci kök dizisinin gömülü stringlerini şifreleyeceğiz:

- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (``"one"`` kelimesindeki karakter sayısı)
- ``0x6f6e650000000000000000000000000000000000000000000000000000000000`` (``"one"`` kelimesinin utf8 gösterimi)
- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (``"two"`` kelimesindeki karakter sayısı)
- ``0x74776f0000000000000000000000000000000000000000000000000000000000`` (``"two"`` kelimesinin utf8 gösterimi)
- ``0x0000000000000000000000000000000000000000000000000000000000000005`` (``"three"`` kelimesindeki karakter sayısı)
- ``0x7468726565000000000000000000000000000000000000000000000000000000`` (``"three"`` kelimesinin utf8 gösterimi)

İlk kök dizisine paralel olarak, diziler dinamik elemanlar olduğundan, ``c``, ``d`` ve ``e`` ofsetlerini de bulmamız gerekir:

.. code-block:: none

    0 - c                                                                - "one" için ofset
    1 - d                                                                - "two" için ofset
    2 - e                                                                - "three" için ofset
    3 - 0000000000000000000000000000000000000000000000000000000000000003 - "one" için sayım
    4 - 6f6e650000000000000000000000000000000000000000000000000000000000 - "one" şifrelemesi
    5 - 0000000000000000000000000000000000000000000000000000000000000003 - "two" için sayım
    6 - 74776f0000000000000000000000000000000000000000000000000000000000 - "two" şifrelemesi
    7 - 0000000000000000000000000000000000000000000000000000000000000005 - "three" için sayım
    8 - 7468726565000000000000000000000000000000000000000000000000000000 - "three" şifrelemesi

``c`` ofseti, 3. Satırda (96 bayt) bulunan ``"one"`` stringinin içeriğinin başlangıcına işaret eder;
dolayısıyla ``c = 0x0000000000000000000000000000000000000000000000000000000000000060``.

``d`` ofseti, 5. Satırda (160 bayt) bulunan ``"two"`` stringinin içeriğinin başlangıcına işaret eder;
dolayısıyla ``d = 0x00000000000000000000000000000000000000000000000000000000000000a0``.

``e`` ofseti, 7. Satırda (224 bayt) bulunan ``"three"`` stringinin içeriğinin başlangıcına işaret eder;
dolayısıyla ``e = 0x00000000000000000000000000000000000000000000000000000000000000e0``.


Kök dizilerinin ve gömülü öğelerinin şifrelemelerinin birbirine bağlı olmadığını ve
``g(string[],uint256[][])`` imzalı olan bir fonksiyon için aynı şifrelemelere sahip
olduğunu unutmayın.

Daha sonra ilk kök dizisinin uzunluğunu şifreleriz:

- ``0x0000000000000000000000000000000000000000000000000000000000000002`` (ilk kök dizide bulunan eleman sayısı, 2; elemanların kendileri ``[1, 2]`` ve ``[3]``)

Daha sonra ikinci kök dizisinin uzunluğunu şifreleriz:

- ``0x0000000000000000000000000000000000000000000000000000000000000003`` (ikinci kök dizisinde bulunan string sayısı, 3; stringlerin kendileri ``”one"``, ``"two"`` ve ``"three"``)

Son olarak, ilgili kök dinamik dizileri ``[[1, 2], [3]]`` ve ``[" one", "two", "three"]``
için ``f`` ve ``g`` ofsetlerini bulur ve parçaları doğru sırada birleştiririz:

.. code-block:: none

    0x2289b18c                                                            - fonksiyon imzası
     0 - f                                                                - [[1, 2], [3]] için ofset
     1 - g                                                                - ["one", "two", "three"] için ofset
     2 - 0000000000000000000000000000000000000000000000000000000000000002 - [[1, 2], [3]] için sayım
     3 - 0000000000000000000000000000000000000000000000000000000000000040 - [1, 2] için ofset
     4 - 00000000000000000000000000000000000000000000000000000000000000a0 - [3] için ofset
     5 - 0000000000000000000000000000000000000000000000000000000000000002 - [1, 2] için sayım
     6 - 0000000000000000000000000000000000000000000000000000000000000001 - 1 şifrelemesi
     7 - 0000000000000000000000000000000000000000000000000000000000000002 - 2 şifrelemesi
     8 - 0000000000000000000000000000000000000000000000000000000000000001 - [3] için sayım
     9 - 0000000000000000000000000000000000000000000000000000000000000003 - 3 şifrelemesi
    10 - 0000000000000000000000000000000000000000000000000000000000000003 - ["one", "two", "three"] için sayım
    11 - 0000000000000000000000000000000000000000000000000000000000000060 - "one" için ofset
    12 - 00000000000000000000000000000000000000000000000000000000000000a0 - "two" için ofset
    13 - 00000000000000000000000000000000000000000000000000000000000000e0 - "three" için ofset
    14 - 0000000000000000000000000000000000000000000000000000000000000003 - "one" için sayım
    15 - 6f6e650000000000000000000000000000000000000000000000000000000000 - "one" şifrelemesi
    16 - 0000000000000000000000000000000000000000000000000000000000000003 - "two" için sayım
    17 - 74776f0000000000000000000000000000000000000000000000000000000000 - "two" şifrelemesi
    18 - 0000000000000000000000000000000000000000000000000000000000000005 - "three" için sayım
    19 - 7468726565000000000000000000000000000000000000000000000000000000 - "three" şifrelemesi

``f`` ofseti, 2. satırda(64 bayt) bulunan ``[[1, 2], [3]]`` dizisinin içeriğinin başlangıcına işaret eder;
dolayısıyla ``f = 0x0000000000000000000000000000000000000000000000000000000000000040``.

``g`` ofseti, 10. satırda (320 bayt) bulunan ``[" one", "two", "three"]`` dizisinin içeriğinin başlangıcına işaret eder;
dolayısıyla ``g = 0x0000000000000000000000000000000000000000000000000000000000000140``.

.. _abi_events:

Event'ler
===========

Event'ler Ethereum loglama/olay izleme protokolünün bir özetidir. Günlük girdileri
sözleşmenin adresini, dört maddeye kadar bir dizi ve bazı değişken uzunluktaki binary
verileri sağlar. Event'ler, bunu (bir arayüz spesifikasyonu ile birlikte) uygun şekilde
yazılmış bir yapı olarak yorumlamak için mevcut fonksiyon ABI'sinden yararlanır.

Bir event adı ve bir dizi event parametresi verildiğinde, bunları iki alt seriye
ayırırız: indekslenenler ve indekslenmeyenler. İndekslenenler (anonim olmayan olaylar
için) 3'e veya (anonim olanlar için) 4'e kadar numaralandırılabilir, kayıt girdisinin
konu başlıklarını oluşturmak için event imzası Keccak hash'i ile birlikte kullanılır.
İndekslenmemiş olanlar ise event'in bayt dizisini oluşturur.

Gerçekte, bu ABI'yi kullanan bir log girdisi şu şekilde açıklanır:

- ``address`` : sözleşmenin adresi (Ethereum tarafından dahili olarak sağlanır);
- ``topics[0]`` : ``keccak(EVENT_NAME+"("+EVENT_ARGS.map(canonical_type_of).join(",")+")")``
  (``canonical_type_of`` verilen bir argümanın kanonik tipini döndüren bir fonksiyondur,
  örneğin ``uint indexed foo`` için ``uint256`` değerini döndürür). Bu değer yalnızca event
  ``anonymous`` olarak tanımlanmamışsa  ``topics[0]`` içinde bulunur;
- ``topics[n]``: Event ``anonymous`` olarak tanımlanmamışsa ``abi_encode(EVENT_INDEXED_ARGS[n - 1])``
  veya tanımlanmışsa ``abi_encode(EVENT_INDEXED_ARGS[n])`` (``EVENT_INDEXED_ARGS`` indekslenen ``EVENT_ARGS``
  serisidir);
- ``data``: ABI şifrelemesi ``EVENT_NON_INDEXED_ARGS`` (``EVENT_NON_INDEXED_ARGS`` indekslenmemiş
  ``EVENT_ARGS`` serisidir, ``abi_encode`` yukarıda açıklandığı gibi bir fonksiyondan bir dizi
  typed değer döndürmek için kullanılan ABI şifreleme fonksiyonudur).

En fazla 32 bayt uzunluğundaki tüm türler için, ``EVENT_INDEXED_ARGS`` dizisi, normal
ABI şifrelemesinde olduğu gibi, değeri doğrudan, 32 bayta kadar doldurulmuş veya işaret
uzatılmış (işaretli tamsayılar için) olarak içermektedir. Ancak, tüm diziler, ``string``,
``bytes`` ve structlar dahil olmak üzere tüm "karmaşık" tipler veya dinamik uzunluktaki
tipler için, ``EVENT_INDEXED_ARGS`` doğrudan şifrelenmiş değer yerine yerleşik olarak
şifrelenmiş özel bir değerin (bkz :ref:`indexed_event_encoding`) *Keccak hash*'ini tutacaktır.
Bu, uygulamaların dinamik uzunluktaki tiplerin değerlerini verimli bir şekilde sorgulamalarına
olanak tanır ( şifrelenmiş değerin hash'ini topic olarak ayarlayarak), ancak uygulamaların
sorgulamadıkları indekslenmiş değerlerin şifresini çözememelerine imkan tanır. Dinamik
uzunluklu tipler için, uygulama geliştiricileri önceden belirlenmiş değerler için hızlı
arama (argüman indekslenmişse) ve rastgele değerlerin okunabilirliği (argümanların
indekslenmemesini gerektirir) arasında bir trade-off ile karşı karşıyadır. Geliştiriciler,
aynı değeri tutması amaçlanan biri indekslenmiş, diğeri indekslenmemiş iki bağımsız değişkene
sahip event'ler tanımlayarak bu dengesizliğin üstesinden gelebilir ve hem verimli arama
hem de değişken okunabilirlik elde edebileceklerdir.

.. _abi_errors:
.. index:: error, selector; of an error

Error'ler
=============

Bir sözleşme içinde bir hata olması durumunda, sözleşme yürütme işlemini iptal etmek
ve tüm durum değişikliklerini geri almak için özel bir opcode kullanabilir. Bu etkilere
ek olarak, açıklayıcı veriler de çağırana döndürülebilir. Bu açıklayıcı veri, bir hatanın
ve argümanlarının bir fonksiyon çağrısı için veri ile aynı şekilde şifrelenmesidir.

Örnek olarak, ``transfer`` fonksiyonu her zaman "yetersiz bakiye”(insufficient balance)
özel hatası ile geri döndürülen aşağıdaki sözleşmeyi ele alalım:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract TestToken {
        error InsufficientBalance(uint256 available, uint256 required);
        function transfer(address /*to*/, uint amount) public pure {
            revert InsufficientBalance(0, amount);
        }
    }

Geri döndürülen veri, ``InsufficientBalance(uint256,uint256)`` fonksiyonuna
``InsufficientBalance(0, amount)`` fonksiyon çağrısı ile aynı şekilde şifrelenecektir,
yani ``0xcf479181``, ``uint256(0)``, ``uint256(amount)``.

``0x00000000`` ve ``0xffffff`` hata(error) selektörleri gelecekte kullanılmak üzere saklanmıştır.
"0x00000000" ve "0xffffffff" hata seçicileri ileride kullanılmak üzere ayrılmıştır.

.. warning::
    Hata verilerine asla güvenmeyin.
    Hata verileri standart olarak harici çağrılar zinciri boyunca yayılır; bu da bir
    sözleşmenin doğrudan çağırdığı sözleşmelerin hiçbirinde tanımlanmamış bir hata
    alabileceği anlamına gelir.
    Ayrıca, herhangi bir sözleşme, hata hiçbir yerde tanımlanmamış olsa bile, bir
    hata imzasıyla eşleşen verileri döndürerek herhangi bir hatayı taklit edebilir.

.. _abi_json:

JSON
====

Bir sözleşmenin arayüzü için oluşturulan JSON formatı, fonksiyon, olay ve hata açıklamalarından oluşan bir dizi ile verilir.
Fonksiyon açıklaması, alanları içeren bir JSON nesnesidir:

- ``type``: ``"function"``, ``"constructor"``, ``"receive"`` (:ref:`"receive Ether" fonksiyonu <receive-ether-function>`) veya ``"fallback"`` (:ref:`"default" fonksiyonu <fallback-function>`);
- ``name``: fonksiyonun adı;
- ``inputs``: her biri aşağıdakileri içeren bir nesne dizisi:

  * ``name``: parametrenin adı.
  * ``type``: parametrenin kanonik tipi (daha fazla bilgi aşağıdadır).
  * ``components``: tuple türleri için kullanılır (daha fazla bilgi aşağıdadır).

- ``outputs``: an array of objects similar to ``inputs``.
- ``stateMutability``: a string with one of the following values: ``pure`` (:ref:`specified to not read
  blockchain state <pure-functions>`), ``view`` (:ref:`specified to not modify the blockchain
  state <view-functions>`), ``nonpayable`` (function does not accept Ether - the default) and ``payable`` (function accepts Ether).

Constructor ve fallback fonksiyonu asla ``name`` veya ``outputs`` içermez. Fallback fonksiyonunda da ``inputs`` yoktur.

.. note::
    Non-payable fonksiyonuna sıfır olmayan Ether gönderilmesi transferi geri çevirecektir(revert).

.. note::
    Durum değişkenliği ``nonpayable`` Solidity'de bir durum değişkenliği modifier'ı
    belirtilmeden yansıtılmaktadır(reflected).

Bir event açıklaması, oldukça benzer özelliklere sahip bir JSON nesnesidir:

- ``type``: her zaman ``"event"``
- ``name``: event adı.
- ``inputs``: her biri aşağıdakileri içeren bir nesne dizisi:

  * ``name``: the name of the parameter.
  * ``type``: parametrenin kanonik tipi (daha fazla bilgi aşağıdadır).
  * ``components``: tuple türleri için kullanılır (daha fazla bilgi aşağıdadır).
  * ``indexed``: Eğer alan logun konularının bir parçasıysa ``true``, logun veri segmentlerinden biriyse ``false``.

- ``anonymous``: Olay ``anonymous`` olarak tanımlanmışsa ``true``.

Hatalar aşağıdaki gibi görünür:

- ``type``: her zaman ``"error"``
- ``name``: error adı.
- ``inputs``: her biri aşağıdakileri içeren bir nesne dizisi:

  * ``name``: parametrenin adı.
  * ``type``: parametrenin kanonik tipi (daha fazla bilgi aşağıdadır).
  * ``components``: tuple türleri için kullanılır (daha fazla bilgi aşağıdadır).

.. note::
  JSON dizisinde aynı ada ve hatta aynı imzaya sahip birden fazla hata(error) olabilir,
  örneğin hatalar akıllı sözleşmedeki farklı dosyalardan kaynaklanıyorsa veya başka bir
  akıllı sözleşmeden referans alınıyorsa. ABI için hatanın nerede tanımlandığı değil,
  yalnızca adı önemlidir.


Örneğin,

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;


    contract Test {
        constructor() { b = hex"12345678901234567890123456789012"; }
        event Event(uint indexed a, bytes32 b);
        event Event2(uint indexed a, bytes32 b);
        error InsufficientBalance(uint256 available, uint256 required);
        function foo(uint a) public { emit Event(a, b); }
        bytes32 b;
    }

JSON ile sonuçlanacaktır:

.. code-block:: json

    [{
    "type":"error",
    "inputs": [{"name":"available","type":"uint256"},{"name":"required","type":"uint256"}],
    "name":"InsufficientBalance"
    }, {
    "type":"event",
    "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
    "name":"Event"
    }, {
    "type":"event",
    "inputs": [{"name":"a","type":"uint256","indexed":true},{"name":"b","type":"bytes32","indexed":false}],
    "name":"Event2"
    }, {
    "type":"function",
    "inputs": [{"name":"a","type":"uint256"}],
    "name":"foo",
    "outputs": []
    }]

Tuple tiplerinin kullanılması
------------------------------

İsimler bilinçli olarak ABI şifrelemesinin bir parçası olmamasına rağmen, son kullanıcıya
gösterilmesini sağlamak için JSON'a dahil edilmeleri çok önemlidir. Yapı aşağıdaki şekilde
iç içe geçmiştir:

``name``, ``type`` ve potansiyel olarak ``components`` üyelerine sahip bir nesne, tiplendirilmiş
bir değişkeni tanımlar. Kanonik tip, bir tuple tipine ulaşılana kadar belirlenir ve o noktaya
kadar olan dize açıklaması ``tuple`` kelimesiyle ``type`` önekinde saklanır, yani ``tuple``
ve ardından ``[]`` ve ``[k]`` tamsayıları ``k`` ile bir dizi olacaktır. Tuple`ın bileşenleri
daha sonra dizi tipinde olan ve üst düzey nesne ile aynı yapıya sahip olan ``components``
üyesinde saklanır, ancak ``indexed`` öğesine bu durumda izin verilmez.

Örnek olarak, kod

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.5 <0.9.0;
    pragma abicoder v2;

    contract Test {
        struct S { uint a; uint[] b; T[] c; }
        struct T { uint x; uint y; }
        function f(S memory, T memory, uint) public pure {}
        function g() public pure returns (S memory, T memory, uint) {}
    }

JSON ile sonuçlanacaktır:

.. code-block:: json

    [
      {
        "name": "f",
        "type": "function",
        "inputs": [
          {
            "name": "s",
            "type": "tuple",
            "components": [
              {
                "name": "a",
                "type": "uint256"
              },
              {
                "name": "b",
                "type": "uint256[]"
              },
              {
                "name": "c",
                "type": "tuple[]",
                "components": [
                  {
                    "name": "x",
                    "type": "uint256"
                  },
                  {
                    "name": "y",
                    "type": "uint256"
                  }
                ]
              }
            ]
          },
          {
            "name": "t",
            "type": "tuple",
            "components": [
              {
                "name": "x",
                "type": "uint256"
              },
              {
                "name": "y",
                "type": "uint256"
              }
            ]
          },
          {
            "name": "a",
            "type": "uint256"
          }
        ],
        "outputs": []
      }
    ]

.. _abi_packed_mode:

Katı Şifreleme Modu
====================

Sıkı şifreleme modu, yukarıdaki resmi spesifikasyonda tanımlandığı gibi tam olarak aynı
şifrelemeye neden olan moddur. Bu, ofsetlerin veri alanlarında çakışma yaratmadan mümkün
olduğunca küçük olması gerektiği ve dolayısıyla hiçbir boşluğa izin verilmediği anlamına gelir.

Genellikle, ABI şifre çözücüler sadece ofset işaretçilerini takip ederek basit bir şekilde
yazılır, ancak bazı şifre çözücüler katı modu zorlayabilir. Solidity ABI şifre çözücü şu
anda katı modu kullanmayı zorunlu kılmaz, ancak şifreleyici her zaman katı modda veri oluşturur.

Standart Olmayan Paket Modu
=====================================

Solidity, ``abi.encodePacked()`` aracılığıyla standart olmayan bir paketlenmiş modu destekler:

- 32 bayttan kısa tipler, doldurma(padding) veya işaret(sign) uzantısı olmadan doğrudan birleştirilir
- dinamik tipler in-place olarak ve uzunluk olmadan şifrelenir
- dizi elemanları doldurulur, ancak yine de in-place olarak şifrelenir

Ayrıca, struct'ların yanı sıra iç içe diziler de desteklenmez.

Örnek olarak, ``int16(-1), bytes1(0x42), uint16(0x03), string("Hello, world!")`` şeklinde bir şifreleme elde edilir:

.. code-block:: none

    0xffff42000348656c6c6f2c20776f726c6421
      ^^^^                                 int16(-1)
          ^^                               bytes1(0x42)
            ^^^^                           uint16(0x03)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ string("Hello, world!") without a length field

Daha spesifik olarak:

- Şifreleme sırasında her şey in-place olarak şifrelenir. Bu, ABI şifrelemesi gibi
  baş ve kuyruk arasında bir ayrım olmadığı ve bir dizinin uzunluğunun şifrelenmediği
  anlamına gelir.
- ``abi.encodePacked`` komutunun doğrudan argümanları, dizi (veya ``string`` veya
  ``bytes``) olmadıkları sürece doldurma olmadan şifrelenir.
- Bir dizinin şifrelemesi, elemanlarının şifrelemelerinin **doldurma** ile
  birleştirilmesidir.
- ``string``, ``bytes`` veya ``uint[]`` gibi dinamik olarak boyutlandırılan tipler
  uzunluk alanları olmadan şifrelenir.
- Bir dizinin veya struct'ın parçası olmadığı sürece ``string`` veya ``bytes``
  şifrelemesinin sonuna doldurma uygulanmaz (bu durumda 32 baytın katlarına kadar doldurulur).

Genel olarak, eksik uzunluk değeri nedeniyle dinamik olarak boyutlandırılmış iki
öğe olduğu anda şifreleme belirsizleşir.

Doldurma gerekiyorsa, açık tip dönüşümleri kullanılabilir: ``abi.encodePacked(uint16(0x12)) == hex "0012"``.

Fonksiyonları çağırırken paketlenmiş şifreleme kullanılmadığından, bir fonksiyon seçicinin
önüne ekleme yapmak için özel bir destek yoktur. Şifreleme belirsiz olduğundan, şifre çözme fonksiyonu yoktur.

.. warning::

    Eğer ``keccak256(abi.encodePacked(a, b))`` kullanırsanız ve hem ``a`` hem de ``b``
    dinamik tiplerse, ``a``nın bazı kısımlarını ``b``ye taşıyarak veya tam tersini
    yaparak hash değerinde çakışmalar oluşturmak kolaydır. Daha spesifik olarak,
    ``abi.encodePacked("a", "bc") == abi.encodePacked("ab", "c")``. İmzalar, kimlik
    doğrulama veya veri bütünlüğü için ``abi.encodePacked`` kullanıyorsanız, her zaman
    aynı tipleri kullandığınızdan emin olun ve bunlardan en fazla birinin dinamik
    olduğunu kontrol edin. Mecburi bir neden olmadıkça, ``abi.encode`` tercih edilmelidir.


.. _indexed_event_encoding:

İndekslenmiş Event Parametrelerinin Şifrelenmesi
=================================================

Değer türü olmayan indekslenmiş event parametreleri, yani diziler ve struct'lar
doğrudan saklanmaz, bunun yerine bir şifrelemenin keccak256-hash'i saklanır. Bu
şifreleme aşağıdaki gibi tanımlanmaktadır:

- bir ``bytes`` ve ``string`` değerinin şifrelenmesi, herhangi bir doldurma veya
  uzunluk öneki olmaksızın sadece string içeriğinden ibarettir.
- bir structın kodlaması, her zaman 32 baytın katları olacak şekilde (``bytes`` ve
  ``string`` bile) üyelerinin şifrelemelerinin bir araya getirilmesiyle elde edilir.
- bir dizinin şifrelenmesi (hem dinamik hem de statik olarak boyutlandırılmış), her
  zaman 32 baytın katları olacak şekilde (``bytes`` ve ``string`` bile) ve herhangi
  bir uzunluk öneki olmadan elemanlarının şifrelenmesinin birleşimidir

Yukarıda her zamanki gibi, negatif bir sayı işaret uzantısıyla doldurulur ve sıfırla doldurulmaz.
``bytesNN`` tipleri sağdan, ``uintNN`` / ``intNN`` tipleri ise soldan doldurulur.

.. warning::

    Bir struct'ın şifrelenmesi, dinamik olarak boyutlandırılmış birden fazla dizi
    içeriyorsa belirsizdir. Bu nedenle, event verilerini her zaman yeniden kontrol
    edin ve yalnızca indekslenmiş parametrelere dayanan arama sonuçlarına güvenmeyin.
