
.. index: memory layout

****************
Bellekteki Düzen
****************

Solidity, belirli bayt aralıklarını (uç noktalar dahil) aşağıdaki şekilde kullanılmak üzere dört adet 32 baytlık yuva ayırır:

- ``0x00`` - ``0x3f`` (64 bytes): Hash metotları için scratch(kazıma) alanı
- ``0x40`` - ``0x5f`` (32 bytes): Şuan ayrılmış olan bellek boyutu (boş bellek pointer'ı olarak da bilinir)
- ``0x60`` - ``0x7f`` (32 bytes): zero slot (sıfır yuva)    

Durumlar arasında (yani assembly içinde) scratch alanı kullanılabilir. Sıfır yuvası, dinamik bellek dizilerinin başlangıç
değeri olarak kullanılır ve asla başlangıçta ``0x80``'i gösteren boş bellek pointer noktasına yazılmamalıdır.

Solidity her zaman yeni nesneleri boş bellek işaretçisine yerleştirir ve
hafıza asla serbest bırakılmaz (Bu özellik gelecekte değişebilir).

Solidity'de bulunan bellek dizilerindeki öğeler her zaman 32 baytın katlarını kaplar (Bu 
``bytes1[]`` için bile doğrudur, ama ``bytes`` ve ``string`` için geçerli değildir).
Çok boyutlu bellek dizileri, bellek dizilerinin işaretçileridir. Bir dinamik dizinin uzunluğu
dizinin ilk yuvasında depolanır ve ardından dizinin elemanları gelir.

.. warning::
  Solidity'de 64 bayttan daha büyük bir geçici bellek alanına ihtiyaç 
  duyan ve bu nedenle scratch alanına sığmayan bazı işlemler vardır.
  Bu işlemler boş bellek noktalarına yerleştirilecektir, ama kısa ömürleri
  nedeniyle işaretçi güncellenemez. Bellek sıfırlanmış olabilir ya da
  olmayabilir. Bu nedenle, boş hafızanın sıfırlanmış hafızayı göstermesi beklenmemelidir.

  Net bir sıfırlanmış bellek alanına ulaşmak için ``msize`` kullanmak
  iyi bir fikir gibi görünse de, boş bellek işaretçisi güncellenmeden 
  geçici olmayan bir işaretçi kullanmak beklenmeyen sonuçlara neden olabilir.


Depolama Düzeni Farklılıkları
================================

Yukarıda açıklandığı üzere bellekteki düzen ile depolama düzeni
(:ref:`storage<storage-inplace-encoding>`) farklıdır.
Aşağıda bunlara yönelik bazı örnekler bulunmaktadır.

Dizilerdeki Farklılıklara Bir Örnek
--------------------------------

Aşağıdaki dizi, depolamada 32 bayt (1 yuva) yer kaplar, ancak bellekte 128
bayt (her biri 32 bayt olan 4 öğe) yer kaplar.

.. code-block:: solidity

    uint8[4] a;



Yapı(Struct) Düzeni Farklılıklarına Bir Örnek
---------------------------------------

Aşağıdaki struct, depolamada 96 bayt (32 baytlık 3 yuva) kaplar,
ama bellekte 128 bayt (her biri 32 bayt olan 4 öğe) yer kaplar.

.. code-block:: solidity

    struct S {
        uint a;
        uint b;
        uint8 c;
        uint8 d;
    }
