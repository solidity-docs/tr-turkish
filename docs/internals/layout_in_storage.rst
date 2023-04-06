.. index:: storage, state variable, mapping

*************************************************
Depolama Alanındaki Durum Değişkenlerinin Düzeni
*************************************************

.. _storage-inplace-encoding:

Sözleşmelerin durum değişkenleri, birden fazla değerin bazen aynı depolama yuvasını(slot)
kullanacağı şekilde kompakt bir şekilde depolanır. Dinamik olarak boyutlandırılmış diziler(arrays)
ve mappingler (aşağıya bakınız) hariç olmak üzere, diğer tüm veriler ``0`` yuvasında saklanan ilk
durum değişkeninden başlamak üzere bitişik bir şekilde öğe öğe saklanır. Her değişken için, değişkenin
türüne göre bayt cinsinden bir boyut belirlenir. 32 bayttan daha az bir değere ihtiyaç duyan birden
fazla bitişik öğe aşağıdaki kurallara uygun olarak eğer mümkünse tek bir depolama yuvasında paketlenir:

- Bir depolama yuvasındaki ilk öğe alt sıraya hizalanmış olarak saklanır.
- Değer türleri, depolanmak için yalnızca gerek duydukları kadar bayt kullanır.
- Bir değer türü bir depolama yuvasının kalan kısmına sığmazsa, bir sonraki depolama yuvasında saklanır.
- Struct'lar ve dizi(array) verileri için her zaman yeni bir yuva başlatılır. Ve öğeler bu kurallara göre sıkıca paketlenir.
- Struct veya dizi (array) verilerini izleyen öğeler için her zaman yeni bir depolama yuvası başlatır.

Kalıtım kullanan sözleşmeler için durum değişkenlerinin sıralaması, en temeldeki sözleşmeden başlayarak
sözleşmelerin C3-doğrusallaştırılmış sırasına göre belirlenir. Eğer yukarıdaki kurallara da uygunsa,
farklı sözleşmelerdeki durum değişkenleri aynı depolama yuvasını paylaşabilir.

Structure'ların ve dizilerin(arrays) elemanları, ayrı ayrı değerler şeklinde verilmiş gibi birbirlerinden sonra saklanırlar.

.. warning::
    32 bayttan daha küçük değerdeki elemanları kullanırken, sözleşmenizin gas kullanımı daha yüksek olabilir.
    Bunun nedeni, ESM'nin bir seferde 32 bayt üzerinde çalışmasıdır. Bu nedenle, eleman bundan daha küçükse,
    ESM'nin elemanın boyutunu 32 bayttan istenen boyuta düşürmek için daha fazla işlem kullanması gerekir.

    Depolama değerleriyle uğraşıyorsanız, küçültülmüş boyutlu türleri kullanmak faydalı olabilir, çünkü derleyici
    birden fazla öğeyi tek bir depolama yuvasına yerleştirecek ve böylece birden fazla okuma veya yazma işlemini
    tek bir işlemde birleştirecektir. Ancak bir yuvadaki tüm değerleri aynı anda okumuyor veya yazmıyorsanız, bunun
    ters bir etkisi olabilir: Çok değerli bir depolama yuvasına bir değer yazıldığı zaman, depolama yuvasının önce
    okunması ve ardından aynı yuvadaki diğer verilerin yok edilmemesi için yeni değerler ile birleştirilmesi gerekir.

    Fonksiyon argümanları veya bellek değerleriyle uğraşırken, derleyici bu değerleri paketlemediği için bu durumun
    herhangi bir faydası yoktur.

    Son olarak, ESM'nin bunu optimize etmesine izin vermek için, depolama değişkenlerinizi ve ``struct`` üyelerinizi
    sıkıca paketlenebilecekleri şekilde sıralamaya çalıştığınızdan emin olun. Örneğin, saklama değişkenlerinizi
    ``uint128, uint256, uint128`` yerine ``uint128, uint128, uint256`` şeklinde bildirdiğinizde, ilk örnek yalnızca
    iki saklama alanı kaplarken ikincisi üç saklama alanı kaplayacaktır.

.. note::
     Depolama alanındaki durum değişkenlerinin düzeni, depolama pointer'larının
     kütüphanelere aktarılabilmesi nedeniyle Solidity'nin harici arayüzünün bir
     parçası olarak kabul edilir. Bu, bu bölümde özetlenen kurallarda yapılacak
     herhangi bir değişikliğin dilde işleyişi bozan bir değişiklik olarak kabul
     edileceği ve kritik yapısı nedeniyle uygulanmadan önce çok dikkatli bir şekilde
     düşünülmesi gerekeceği anlamına gelir. Böyle bir işleyişi bozan değişiklik
     durumunda, derleyicinin eski düzeni(layout) destekleyecek bir bytecode üreteceği
     bir uyumluluk modu yayınlamak isteriz.


Mapping'ler ve Dinamik Diziler(Arrays)
=======================================

.. _storage-hashed-encoding:

Tahmin edilemeyen boyutları nedeniyle, mapping’ler ve dinamik boyutlu dizi türleri
kendilerinden önceki ve sonraki durum değişkenlerinin "arasında" saklanamaz. Bunun
yerine, :ref:`yukarıdaki <storage-inplace-encoding>` depolama kurallarına göre yalnızca
32 bayt kapladıkları kabul edilir ve içerdikleri öğeler bir Keccak-256 hash'i kullanılarak
hesaplanan farklı bir depolama yuvasından başlayarak depolanır.

Mapping veya dizinin depolama konumunun :ref:`depolama düzeni kuralları <storage-inplace-encoding>`
uygulandıktan sonra ``p`` yuvası olduğunu varsayalım. Dinamik diziler için, bu yuva dizideki
eleman sayısını saklar (bayt dizileri ve stringler bir istisnadır, bkz. :ref:`aşağıda <bytes-and-string>`).
Mapping'ler için yuva boş kalır, ancak yine de yan yana duran iki mapping olsa bile içeriklerinin farklı
depolama konumlarında sonlanmasını sağlamak için gereklidir.

Dizi(array) verileri ``keccak256(p)`` adresinden başlayarak yerleştirilir ve statik olarak boyutlandırılmış
dizi verileriyle aynı biçimde düzenlenir: Elemanlar birbiri ardına sıralanır ve elemanlar 16 bayttan uzun
değilse potansiyel olarak depolama yuvalarını paylaşırlar. Dinamik dizilerin dinamik dizileri bu kuralı
özyinelemeli(recursive) şekilde uygular. ``x`` türünün ``uint24[][]`` olduğu ``x[i][j]`` öğesinin konumu aşağıdaki
gibi hesaplanır (yine ``x`` öğesinin kendisinin ``p`` yuvasında saklandığını varsayarak): Yuva
``keccak256(keccak256(p) + i) + floor(j / floor(256 / 24))`` ve eleman ``v`` yuva verisinden ``(v >> ((j % floor(256 / 24)) * 24)) & type(uint24).max``.

Bir ``k`` mapping anahtarına karşılık gelen değer ``keccak256(h(k) . p)`` adresinde bulunur; burada ``.`` birleştirme,
``h`` ise türüne bağlı olarak anahtara uygulanan bir fonksiyondur:

- değer türleri için, ``h`` değeri bellekte depolarken olduğu gibi 32 bayt olarak doldurur.
- stringler ve byte dizileri için, ``h(k)`` sadece doldurulmamış veridir.

Mapping değeri değer olmayan bir türse, hesaplanan yuva verinin başlangıcını işaret eder. Örneğin, değer struct
türündeyse, üyeye ulaşmak için struct üyesine karşılık gelen bir ofset eklemeniz gerekir.

Örnek olarak, aşağıdaki sözleşmeye bakalım:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;


    contract C {
        struct S { uint16 a; uint16 b; uint256 c; }
        uint x;
        mapping(uint => mapping(uint => S)) data;
    }

Let us compute the storage location of ``data[4][9].c``.
The position of the mapping itself is ``1`` (the variable ``x`` with 32 bytes precedes it).
This means ``data[4]`` is stored at ``keccak256(uint256(4) . uint256(1))``. The type of ``data[4]`` is
again a mapping and the data for ``data[4][9]`` starts at slot
``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1)))``.
The slot offset of the member ``c`` inside the struct ``S`` is ``1`` because ``a`` and ``b`` are packed
in a single slot. This means the slot for
``data[4][9].c`` is ``keccak256(uint256(9) . keccak256(uint256(4) . uint256(1))) + 1``.
The type of the value is ``uint256``, so it uses a single slot.


.. _bytes-and-string:

``bytes`` ve ``string``
------------------------

``bytes`` ve ``string`` aynı şekilde şifrelenir. Genel olarak, şifreleme ``bytes1[]`` şifrelemesine benzer;
dizinin kendisi için bir yuva ve bu yuvanın konumunun ``keccak256`` hash`i kullanılarak hesaplanan bir veri
alanı vardır. Ancak, küçük değerler için (32 bayttan daha küçük) dizi elemanları uzunluklarıyla birlikte aynı
yuvada saklanır.

Özellikle: veri en fazla ``31`` bayt uzunluğundaysa, elemanlar yüksek sıralı baytlarda (sola hizalı bir şekilde)
saklanır ve en düşük sıralı baytta ``uzunluk * 2`` değeri saklanır. ``32`` veya daha fazla bayt uzunluğundaki
verileri saklayan bayt dizileri için, ``p`` ana yuvası ``length * 2 + 1`` değerini saklar ve veriler her zamanki
gibi ``keccak256(p)`` içinde saklanır. Bu, en düşük bit'in ayarlanıp ayarlanmadığını kontrol ederek kısa bir
diziyi uzun bir diziden ayırt edebileceğiniz anlamına gelir: kısa (ayarlanmamış) ve uzun (ayarlanmış).

.. note::
  Geçersiz olarak şifrelenmiş yuvaların işlenmesi şu anda desteklenmemektedir ancak gelecekte bu özellik eklenebilir.
  IR aracılığıyla derleme yapıyorsanız, geçersiz olarak kodlanmış bir yuvayı okumak ``Panic(0x22)`` hatasıyla sonuçlanır.

JSON Çıktısı
=============

.. _storage-layout-top-level:

Bir sözleşmenin depolama düzeni :ref:`standart JSON arayüzü <compiler-api>` aracılığıyla talep edilebilir.
Çıktı, ``storage`` ve ``types`` olmak üzere iki anahtar içeren bir JSON nesnesidir.  ``storage`` nesnesi,
her bir elemanın aşağıdaki forma sahip olduğu bir dizidir:


.. code-block:: json


    {
        "astId": 2,
        "contract": "fileA:A",
        "label": "x",
        "offset": 0,
        "slot": "0",
        "type": "t_uint256"
    }

Yukarıdaki örnek, ``fileA`` kaynak biriminden ``contract A { uint x; }`` depolama düzenidir ve

- ``astId`` durum değişkeninin bildiriminin AST node'unun id'sidir
- ``contract``, ön ek olarak yolunu da içeren sözleşmenin adıdır
- ``label`` durum değişkeninin adıdır
- ``offset`` şifrelemeye göre depolama yuvası içindeki bayt cinsinden ofsettir
- ``slot`` durum değişkeninin bulunduğu veya başladığı depolama yuvasıdır. Bu sayı çok büyük olabilir ve bu nedenle JSON değeri bir dize olarak gösterilir.
- ``type`` değişkenin tip bilgisi için anahtar olarak kullanılan bir tanımlayıcıdır (aşağıda açıklanmıştır)

Verilen ``typep``, bu durumda ``t_uint256``, ``types`` içinde şu forma sahip bir elemanı temsil eder:


.. code-block:: json

    {
        "encoding": "inplace",
        "label": "uint256",
        "numberOfBytes": "32",
    }

nerede

- ``encoding`` verinin depolama alanında nasıl kodlandığı, olası değerler şunlardır:

  - ``inplace``: veri depolama alanında bitişik olarak yerleştirilir (bkz :ref:`above <storage-inplace-encoding>`).
  - ``mapping``: Keccak-256 hash tabanlı yöntem (bkz :ref:`above <storage-hashed-encoding>`).
  - ``dynamic_array``: Keccak-256 hash tabanlı yöntem (bkz :ref:`above <storage-hashed-encoding>`).
  - ``bytes``: veri boyutuna bağlı olarak tek slot veya Keccak-256 hash tabanlı (bkz :ref:`above <bytes-and-string>`).

- ``label`` kanonik tip adıdır.
- ``numberOfBytes`` kullanılan bayt sayısıdır (ondalık bir dize olarak).
      Eğer ``numberOfBytes > 32`` ise bunun birden fazla slot kullanıldığı anlamına geldiğini unutmayın.

Bazı türler yukarıdaki dört bilginin yanı sıra ekstra bilgilere de sahiptir.
Mappingler ``key`` ve ``value`` türlerini içerir (yine bu tür mappingindeki
bir girdiye referansta bulunur), diziler ``base`` türüne sahiptir ve structlar
``members`` türlerini üst düzey ``storage`` ile aynı formatta listeler (bkz :ref:`above <storage-layout-top-level>`).

.. note ::
  Bir sözleşmenin depolama düzeninin JSON çıktısı hala deneysel olarak kabul edilir
  ve Solidity'nin işleyişi bozmayan sürümlerinde değiştirilebilir.

Aşağıdaki örnekte, değer ve referans türleri, paketlenmiş olarak şifrelenmiş türler
ve iç içe geçmiş türler içeren bir sözleşme ve depolama düzeni gösterilmektedir.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;
    contract A {
        struct S {
            uint128 a;
            uint128 b;
            uint[2] staticArray;
            uint[] dynArray;
        }

        uint x;
        uint y;
        S s;
        address addr;
        mapping (uint => mapping (address => bool)) map;
        uint[] array;
        string s1;
        bytes b1;
    }

.. code-block:: json

    {
      "storage": [
        {
          "astId": 15,
          "contract": "fileA:A",
          "label": "x",
          "offset": 0,
          "slot": "0",
          "type": "t_uint256"
        },
        {
          "astId": 17,
          "contract": "fileA:A",
          "label": "y",
          "offset": 0,
          "slot": "1",
          "type": "t_uint256"
        },
        {
          "astId": 20,
          "contract": "fileA:A",
          "label": "s",
          "offset": 0,
          "slot": "2",
          "type": "t_struct(S)13_storage"
        },
        {
          "astId": 22,
          "contract": "fileA:A",
          "label": "addr",
          "offset": 0,
          "slot": "6",
          "type": "t_address"
        },
        {
          "astId": 28,
          "contract": "fileA:A",
          "label": "map",
          "offset": 0,
          "slot": "7",
          "type": "t_mapping(t_uint256,t_mapping(t_address,t_bool))"
        },
        {
          "astId": 31,
          "contract": "fileA:A",
          "label": "array",
          "offset": 0,
          "slot": "8",
          "type": "t_array(t_uint256)dyn_storage"
        },
        {
          "astId": 33,
          "contract": "fileA:A",
          "label": "s1",
          "offset": 0,
          "slot": "9",
          "type": "t_string_storage"
        },
        {
          "astId": 35,
          "contract": "fileA:A",
          "label": "b1",
          "offset": 0,
          "slot": "10",
          "type": "t_bytes_storage"
        }
      ],
      "types": {
        "t_address": {
          "encoding": "inplace",
          "label": "address",
          "numberOfBytes": "20"
        },
        "t_array(t_uint256)2_storage": {
          "base": "t_uint256",
          "encoding": "inplace",
          "label": "uint256[2]",
          "numberOfBytes": "64"
        },
        "t_array(t_uint256)dyn_storage": {
          "base": "t_uint256",
          "encoding": "dynamic_array",
          "label": "uint256[]",
          "numberOfBytes": "32"
        },
        "t_bool": {
          "encoding": "inplace",
          "label": "bool",
          "numberOfBytes": "1"
        },
        "t_bytes_storage": {
          "encoding": "bytes",
          "label": "bytes",
          "numberOfBytes": "32"
        },
        "t_mapping(t_address,t_bool)": {
          "encoding": "mapping",
          "key": "t_address",
          "label": "mapping(address => bool)",
          "numberOfBytes": "32",
          "value": "t_bool"
        },
        "t_mapping(t_uint256,t_mapping(t_address,t_bool))": {
          "encoding": "mapping",
          "key": "t_uint256",
          "label": "mapping(uint256 => mapping(address => bool))",
          "numberOfBytes": "32",
          "value": "t_mapping(t_address,t_bool)"
        },
        "t_string_storage": {
          "encoding": "bytes",
          "label": "string",
          "numberOfBytes": "32"
        },
        "t_struct(S)13_storage": {
          "encoding": "inplace",
          "label": "struct A.S",
          "members": [
            {
              "astId": 3,
              "contract": "fileA:A",
              "label": "a",
              "offset": 0,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 5,
              "contract": "fileA:A",
              "label": "b",
              "offset": 16,
              "slot": "0",
              "type": "t_uint128"
            },
            {
              "astId": 9,
              "contract": "fileA:A",
              "label": "staticArray",
              "offset": 0,
              "slot": "1",
              "type": "t_array(t_uint256)2_storage"
            },
            {
              "astId": 12,
              "contract": "fileA:A",
              "label": "dynArray",
              "offset": 0,
              "slot": "3",
              "type": "t_array(t_uint256)dyn_storage"
            }
          ],
          "numberOfBytes": "128"
        },
        "t_uint128": {
          "encoding": "inplace",
          "label": "uint128",
          "numberOfBytes": "16"
        },
        "t_uint256": {
          "encoding": "inplace",
          "label": "uint256",
          "numberOfBytes": "32"
        }
      }
    }
