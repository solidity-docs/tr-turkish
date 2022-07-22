
.. index: memory layout

****************
Bellekteki Düzen
****************

Solidity, belirli bayt aralıkları (uç noktalar dahil) aşağıdaki şekilde kullanılmak üzere dört adet 32 baytlık yuva ayırır:

- ``0x00`` - ``0x3f`` (64 bytes): Hash metotları için scratch(kazıma) alanı
- ``0x40`` - ``0x5f`` (32 bytes): Şuan ayrılmış olan bellek boyutu (boş bellek işaretçisi olarak da bilinir)
- ``0x60`` - ``0x7f`` (32 bytes): zero slot (sıfır yuva)    

Durumlar arasında scratch alanı kullanılabilir (yani assembly içinde). Sıfır yuvası, dinamik bellek dizilerinin başlangıç
değeri olarak kullanılır ve asla başlangıçta ``0x80``'i gösteren boş bellek işaretçi noktasına yazılmamalıdır.

Solidity her zaman yeni nesneleri boş bellek işaretçisine yerleştirir ve
hafıza asla serbest bırakılmaz (Bu gelecekte değişebilir).

Solidity'deki bellek dizilerindeki öğeler her zaman 32 baytın katlarını kaplar (Bu 
``bytes1[]`` için bile doğrudur, ama ``bytes`` ve ``string`` için geçerli değildir).
Çok boyutlu bellek dizileri, bellek dizilerinin işaretçileridir. Bir dinamik dizinin uzunluğu
dizinin ilk yuvasında depolanır ve ardından dizinin elemanları gelir.

.. Uyarı::
  Solidity'de 64 bayttan daha büyük bir geçici bellek alanına ihtiyaç 
  duyan ve bu nedenle scratch alanına sığmayan bazı işlemler vardır.
  Bu işlemler boş bellek noktalarına yerleştirilecektir, ama kısa ömürleri
  nedeniyle işaretçi güncellenemez. Bellek sıfırlanmış olabilir ya da
  olmayabilir. Bu nedenle, boş hafıza noktasının hafızayı sıfırlaması beklenmemelidir.

  Net bir sıfırlanmış bellek alanına ulaşmak için ``msize`` kullanmak
  iyi bir fikir gibi görünse de, boş bellek işaretçisi güncellenmeden 
  geçici olmayan bir işaretçi kullanmak beklenmeyen sonuçlara neden olabilir.


Differences to Layout in Storage
================================

As described above the layout in memory is different from the layout in
:ref:`storage<storage-inplace-encoding>`. Below there are some examples.

Example for Difference in Arrays
--------------------------------

The following array occupies 32 bytes (1 slot) in storage, but 128
bytes (4 items with 32 bytes each) in memory.

.. code-block:: solidity

    uint8[4] a;



Example for Difference in Struct Layout
---------------------------------------

The following struct occupies 96 bytes (3 slots of 32 bytes) in storage,
but 128 bytes (4 items with 32 bytes each) in memory.


.. code-block:: solidity

    struct S {
        uint a;
        uint b;
        uint8 c;
        uint8 d;
    }
