
.. index: memory layout

****************
Bellekteki Düzen
****************

Solidity, belirli bayt aralıkları (uç noktalar dahil) aşağıdaki şekilde kullanılmak üzere dört adet 32 baytlık yuva ayırır:

- ``0x00`` - ``0x3f`` (64 bytes): Hash metotları için scratch(kazıma) alanı
- ``0x40`` - ``0x5f`` (32 bytes): Şuan ayrılmış olan bellek boyutu (boş bellek işaretçisi olarak da bilinir)
- ``0x60`` - ``0x7f`` (32 bytes): sıfır yuva

Durumlar arasında scratch alanı kullanılabilir (yani assembly içinde). Sıfır yuvası, dinamik bellek dizilerinin başlangıç
değeri olarak kullanılır ve asla başlangıçta ``0x80``'i gösteren boş bellek işaretçi noktasına yazılmamalıdır.

Solidity always places new objects at the free memory pointer and
memory is never freed (this might change in the future).

Elements in memory arrays in Solidity always occupy multiples of 32 bytes (this
is even true for ``bytes1[]``, but not for ``bytes`` and ``string``).
Multi-dimensional memory arrays are pointers to memory arrays. The length of a
dynamic array is stored at the first slot of the array and followed by the array
elements.

.. warning::
  There are some operations in Solidity that need a temporary memory area
  larger than 64 bytes and therefore will not fit into the scratch space.
  They will be placed where the free memory points to, but given their
  short lifetime, the pointer is not updated. The memory may or may not
  be zeroed out. Because of this, one should not expect the free memory
  to point to zeroed out memory.

  While it may seem like a good idea to use ``msize`` to arrive at a
  definitely zeroed out memory area, using such a pointer non-temporarily
  without updating the free memory pointer can have unexpected results.


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
