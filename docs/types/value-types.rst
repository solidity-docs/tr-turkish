.. index:: ! value type, ! type;value
.. _value-types:

Değer Türleri
===========

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
--------

``int`` / ``uint``: Çeşitli boyutlarda işaretli ve işaretsiz tam sayılar.
``8`` (8'den 256 bit'e kadar işaretsiz) ve ``uint8`` ila ``uint256`` adımlarında ``uint8`` ile ``uint256`` arasındaki anahtar kelimeler. ``uint`` ve ``int`` sırasıyla ``uint256`` ve ``int256`` için takma adlardır.

Operatörler:

* Karşılaştırmalar: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (``bool`` olarak değerlendir)
* Bit operatörleri: ``&``, ``|``, ``^`` (bit düzeyinde özel veya), ``~`` (bitsel olumsuzlama)
* Değiştirme (Shift) operatörleri: ``<<`` (sol shift), ``>>`` (sağ shift)
* Aritmetik operatörler: ``+``, ``-``, tekli ``-`` (sadece imzalı tamsayılar için), ``*``, ``/``, ``%`` (mod alma operatörü), ``**`` (ül alma operatörü)

Bir tamsayı türü olan ``X`` için, tür tarafından gösterilebilen minimum ve maksimum değere erişmek için ``type(X).min`` ve ``type(X).max``ı kullanabilirsiniz.


.. uyarı::

 Solidity'deki tamsayılar belirli bir aralıkla sınırlıdır. Örneğin, ``uint32`` ile bu ``0``dan ``2**32 - 1``e kadardır. Bu türlerde aritmetiğin gerçekleştirildiği iki mod vardır: "wrapping" veya "unchecked" mod ve "checked" mod. Varsayılan olarak, aritmetik her zaman "checked" durumundadır, yani bir işlemin sonucu türün değer aralığının dışına çıkarsa, çağrı bir :ref:`başarısız onaylama<asset-and-require>` aracılığıyla geri döndürülür. ``unchecked { ... }`` kullanarak "unchecked" moda geçebilirsiniz. Daha fazla ayrıntı :ref:`unchecked <unchecked>` ile ilgili bölümde bulunabilir.


Karşılaştırmalar
^^^^^^^^^^^

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

.. uyarı::

    ``0.5.0`` sürümünden önce, negatif ``x`` için bir sağa kaydırma ``x >> y`` sıfıra yuvarlanmış ``x / 2**y`` matematiksel ifadesine eşdeğerdi, yani sağa kaydırmalar, aşağı yuvarlama (negatif sonsuza doğru) yerine yukarı (sıfıra doğru) yuvarlama olarak kullanılır.

.. not::
    Aritmetik işlemlerde olduğu gibi kaydırma işlemleri için de taşma kontrolleri yapılmaz. Bunun yerine, sonuç her zaman kesilir.

Toplama, Çıkarma ve Çarpma
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Toplama, çıkarma ve çarpma, taşma ve alttan akışa ilişkin iki farklı mod ile olağan semantiklere sahiptir:

Varsayılan olarak, tüm aritmetik yetersiz veya taşma açısından kontrol edilir, ancak bu, :ref:`unchecked blok<unchecked>` kullanılarak devre dışı bırakılabilir, bu da sarma aritmetiğiyle sonuçlanır. Daha fazla ayrıntı o bölümde bulunabilir.

``-x`` ifadesi, ``(T(0) - x)`` ile eşdeğerdir; burada ``T``, ``x``in türüdür. Yalnızca imzalı türlere uygulanabilir. ``x`` negatifse ``-x``in değeri pozitif olabilir. İkisinin tamamlayıcı temsilinden kaynaklanan başka bir uyarı daha var:

``int x = type(int).min;`` varsa, ``-x`` pozitif aralığa uymaz. ``unchecked { assert(-x == x); }`` çalışır ve işaretli modda kullanıldığında ``-x`` ifadesi başarısız bir onaylamaya neden olur.


Bölme
^^^^^^^^

Bir işlemin sonucunun türü her zaman işlenenlerden birinin türü olduğundan, tamsayılarda bölme her zaman bir tamsayı ile sonuçlanır. Solidity'de bölme sıfıra doğru yuvarlanır. Bu, ``int256(-5) / int256(2) == int256(-2)`` anlamına gelir.


Buna karşılık, :ref:`değişmezler (literals) <rational_literals>` üzerinde bölmenin keyfi kesinliğin kesirli değerleriyle sonuçlandığını unutmayın.

.. not::
    Sıfıra bölme bir :ref:`panik hatasına<assert-and-require>` neden olur. Bu kontrol, ``unckecked { ... }`` ile devre dışı **bırakılamaz**.

.. not::
  ``type(int).min / (-1)`` ifadesi, bölmenin taşmaya neden olduğu tek durumdur. Kontrollü aritmetik modda, bu başarısız bir onaylamaya neden olurken, sarma modunda değer ``type(int).min`` olacaktır.

Mod Alma
^^^^^^

Mod alma işlemi ``a % n``, ``a`` işleneninin ``n`` işlenenine bölünmesinden sonra kalan ``r``yi verir, burada ``q = int(a / n)`` ve ``r = a - (n * q)``. Bu, mod alma işleminin sol işleneni (veya sıfır) ile aynı işaretle sonuçlandığı ve ``a % n == -(-a % n)``nin negatif ``a`` için geçerli olduğu anlamına gelir:


* ``int256(5) % int256(2) == int256(1)``
* ``int256(5) % int256(-2) == int256(1)``
* ``int256(-5) % int256(2) == int256(-1)``
* ``int256(-5) % int256(-2) == int256(-1)``

.. not::
  Sıfırlı mod alma işlemi :ref:`Panik hatasına<assert-and-require>` neden oluyor. Bu kontrol, ``unckecked { ... }`` ile devre dışı **bırakılamaz**.

Üs Alma
^^^^^^^^^^^^^^

Üs, yalnızca üsteki işaretsiz türler için kullanılabilir. Elde edilen bir üs türü her zaman tabanın türüne eşittir. Lütfen sonucu tutacak ve olası onaylama hatalarına veya sarma davranışına hazırlanacak kadar büyük olmasına dikkat edin.


.. not::
  İşaretli (checked) modda, üs alma yalnızca küçük tabanlar için nispeten ucuz ``exp`` işlem kodunu kullanır.
   ``x**3`` durumları için ``x*x*x`` ifadesi daha ucuz olabilir.
   Her durumda, gaz maliyeti testleri ve optimize edicinin kullanılması tavsiye edilir.


.. not::
  ``0**0``ın EVM tarafından ``1`` olarak tanımlandığını unutmayın.

.. index:: ! ufixed, ! fixed, ! fixed point number

Sabit Nokta Sayıları
-------------------

.. uyarı::
    Sabit nokta sayıları henüz Solidity tarafından tam olarak desteklenmemektedir. Bildirilebilirler, ancak atanamazlar veya atanamazlar.

``fixed`` / ``ufixed``: Çeşitli boyutlarda imzalı ve imzasız sabit nokta sayısı. 
Anahtar sözcükler ``ufixedMxN`` ve ``fixedMxN``, burada ``M`` türün aldığı bit sayısını ve ``N`` kaç ondalık noktanın mevcut olduğunu gösterir. ``M`` 8'e bölünebilir olmalı ve 8'den 256 bit'e kadar gider. ``N`` 0 ile 80 arasında olmalıdır. ``ufixed`` ve ``fixed`` sırasıyla ``ufixed128x18`` ve ``fixed128x18`` için takma adlardır.


Operatörler:

* Karşılaştırma: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (``bool`` olarak değerlendir)
* Aritmetik operatörler: ``+``, ``-``, tekil ``-``, ``*``, ``/``, ``%`` (mod alma)

.. not::
    Kayan nokta (birçok dilde ``float`` ve ``double``, daha doğrusu IEEE 754 sayıları) ile sabit nokta sayıları arasındaki temel fark, tamsayı ve kesirli kısım için kullanılan bit sayısının (birçok dilde ondalık nokta) birincisinde esnektir, ikincisinde ise kesin olarak tanımlanmıştır. Genel olarak, kayan noktada neredeyse tüm alan sayıyı temsil etmek için kullanılırken, ondalık noktanın nerede olduğunu yalnızca az sayıda bit tanımlar.


.. index:: address, balance, send, call, delegatecall, staticcall, transfer

.. _address:

Adresler
-------

Adres türü, büyük ölçüde aynı olan iki şekilde gelir:

- ``address``: 20 baytlık bir değer tutar (bir Ethereum adresinin boyutu).
- ``address payable``: ``address`` ile aynıdır, ek olarak ``transfer`` ve ``send`` bulundurur.

Bu ayrımın arkasındaki fikir, ``address payable``in, Ether gönderebileceğiniz bir adres olduğu, ancak Ether'i düz bir ``address``e göndermemeniz gerektiğidir, örneğin akıllı bir sözleşme olabileceği için. Ether'i kabul etmek için oluşturulmamıştır.


Tür dönüşümleri:

``address payable``den ``address``e örtülü dönüşümlere izin verilirken, ``address``den ``address payable``a dönüşümler ``payable(<address>)`` üzerinden açık olmalıdır.

``uint160``, tamsayı değişmezleri, ``bytes20`` ve sözleşme türleri için ``address``e ve adresten açık dönüşümlere izin verilir.

Yalnızca ``address`` ve sözleşme türündeki ifadeler, açık dönüştürme ``payable(...)`` aracılığıyla ``address
payable`` türüne dönüştürülebilir. Sözleşme türü için, bu dönüştürmeye yalnızca sözleşme Ether alabiliyorsa, yani sözleşmenin bir :ref:`alma <receive-ether-function>` veya ödenebilir yedek fonksiyonu varsa izin verilir. ``payable(0)``ın geçerli olduğunu ve bu kuralın bir istisnası olduğunu unutmayın.

.. not::
    ``address`` türünde bir değişkene ihtiyacınız varsa ve buna Ether göndermeyi planlıyorsanız, bu gereksinimi görünür kılmak için türünü ``address payable`` olarak bildirin. Ayrıca, bu ayrımı veya dönüşümü mümkün olduğunca erken yapmaya çalışın.

Operatörler:

* ``<=``, ``<``, ``==``, ``!=``, ``>=`` ve ``>``

.. uyarı::
    Daha büyük bir bayt boyutu kullanan bir türü bir ``address``e, örneğin ``bytes32``ye dönüştürürseniz, ``address`` kısaltılır. Dönüştürme belirsizliğini azaltmak için sürüm 0.4.24 ve derleyici kuvvetinin daha yüksek sürümü, dönüştürmede kesmeyi açık hale getirirsiniz.
     Örneğin, ``0x111122223333444455556666777788889999AAAABBBBCCCCDDDDEEEEFFFFCCC`` 32 bayt değerini alın.

    ``address(uint160(bytes20(b)))`` kullanabilirsiniz, bu da ``0x111122223333444455556666777788889999aAaa`` ile sonuçlanır,
     veya ``0x777788889999AaAAbBbbCccccddDdeeeEfFFfCcCc`` ile sonuçlanan ``address(uint160(uint256(b)))``i kullanabilirsiniz.

.. not::
    ``address`` ve ``address payable`` arasındaki ayrım, 0.5.0 sürümüyle tanıtıldı. Ayrıca bu versiyondan başlayarak, sözleşmeler adres türünden türetilmez, ancak yine de bir alma veya ödeme geri dönüş işlevi varsa, açıkça ``address``e veya ``address payable``a dönüştürülebilir.

.. _members-of-addresses:

Adres Üyeleri
^^^^^^^^^^^^^^^^^^^^

Adreslerin tüm üyelerine hızlıca göz atmak için, bkz.:ref:`address_related`.

* ``balance`` and ``transfer``

Bir adresin bakiyesini ``balance`` özelliğini kullanarak sorgulamak ve ``transfer`` işlevini kullanarak Ether'i (wei birimi cinsinden) bir ödenecek adrese göndermek mümkündür:

.. code-block:: solidity
    :force:

    address payable x = payable(0x123);
    address myAddress = address(this);
    if (x.balance < 10 && myAddress.balance >= 10) x.transfer(10);

Mevcut sözleşmenin bakiyesi yeterince büyük değilse veya Ether transferi alıcı hesap tarafından reddedilirse ``transfer`` fonksiyonu başarısız olur. ``transfer`` fonksiyonu başarısızlık üzerine geri döner.


.. not::
    If ``x`` is a contract address, its code (more specifically: its :ref:`receive-ether-function`, if present, or otherwise its :ref:`fallback-function`, if present) will be executed together with the ``transfer`` call (this is a feature of the EVM and cannot be prevented). If that execution runs out of gas or fails in any way, the Ether transfer will be reverted and the current contract will stop with an exception.

* ``send``

Send is the low-level counterpart of ``transfer``. If the execution fails, the current contract will not stop with an exception, but ``send`` will return ``false``.

.. warning::
    There are some dangers in using ``send``: The transfer fails if the call stack depth is at 1024
    (this can always be forced by the caller) and it also fails if the recipient runs out of gas. So in order
    to make safe Ether transfers, always check the return value of ``send``, use ``transfer`` or even better:
    use a pattern where the recipient withdraws the money.

* ``call``, ``delegatecall`` and ``staticcall``

In order to interface with contracts that do not adhere to the ABI,
or to get more direct control over the encoding,
the functions ``call``, ``delegatecall`` and ``staticcall`` are provided.
They all take a single ``bytes memory`` parameter and
return the success condition (as a ``bool``) and the returned data
(``bytes memory``).
The functions ``abi.encode``, ``abi.encodePacked``, ``abi.encodeWithSelector``
and ``abi.encodeWithSignature`` can be used to encode structured data.

Example:

.. code-block:: solidity

    bytes memory payload = abi.encodeWithSignature("register(string)", "MyName");
    (bool success, bytes memory returnData) = address(nameReg).call(payload);
    require(success);

.. warning::
    All these functions are low-level functions and should be used with care.
    Specifically, any unknown contract might be malicious and if you call it, you
    hand over control to that contract which could in turn call back into
    your contract, so be prepared for changes to your state variables
    when the call returns. The regular way to interact with other contracts
    is to call a function on a contract object (``x.f()``).

.. note::
    Previous versions of Solidity allowed these functions to receive
    arbitrary arguments and would also handle a first argument of type
    ``bytes4`` differently. These edge cases were removed in version 0.5.0.

It is possible to adjust the supplied gas with the ``gas`` modifier:

.. code-block:: solidity

    address(nameReg).call{gas: 1000000}(abi.encodeWithSignature("register(string)", "MyName"));

Similarly, the supplied Ether value can be controlled too:

.. code-block:: solidity

    address(nameReg).call{value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));

Lastly, these modifiers can be combined. Their order does not matter:

.. code-block:: solidity

    address(nameReg).call{gas: 1000000, value: 1 ether}(abi.encodeWithSignature("register(string)", "MyName"));

In a similar way, the function ``delegatecall`` can be used: the difference is that only the code of the given address is used, all other aspects (storage, balance, ...) are taken from the current contract. The purpose of ``delegatecall`` is to use library code which is stored in another contract. The user has to ensure that the layout of storage in both contracts is suitable for delegatecall to be used.

.. note::
    Prior to homestead, only a limited variant called ``callcode`` was available that did not provide access to the original ``msg.sender`` and ``msg.value`` values. This function was removed in version 0.5.0.

Since byzantium ``staticcall`` can be used as well. This is basically the same as ``call``, but will revert if the called function modifies the state in any way.

All three functions ``call``, ``delegatecall`` and ``staticcall`` are very low-level functions and should only be used as a *last resort* as they break the type-safety of Solidity.

The ``gas`` option is available on all three methods, while the ``value`` option is only available
on ``call``.

.. note::
    It is best to avoid relying on hardcoded gas values in your smart contract code,
    regardless of whether state is read from or written to, as this can have many pitfalls.
    Also, access to gas might change in the future.

* ``code`` and ``codehash``

You can query the deployed code for any smart contract. Use ``.code`` to get the EVM bytecode as a
``bytes memory``, which might be empty. Use ``.codehash`` get the Keccak-256 hash of that code
(as a ``bytes32``). Note that ``addr.codehash`` is cheaper than using ``keccak256(addr.code)``.

.. note::
    All contracts can be converted to ``address`` type, so it is possible to query the balance of the
    current contract using ``address(this).balance``.

.. index:: ! contract type, ! type; contract

.. _contract_types:

Contract Types
--------------

Every :ref:`contract<contracts>` defines its own type.
You can implicitly convert contracts to contracts they inherit from.
Contracts can be explicitly converted to and from the ``address`` type.

Explicit conversion to and from the ``address payable`` type is only possible
if the contract type has a receive or payable fallback function.  The conversion is still
performed using ``address(x)``. If the contract type does not have a receive or payable
fallback function, the conversion to ``address payable`` can be done using
``payable(address(x))``.
You can find more information in the section about
the :ref:`address type<address>`.

.. note::
    Before version 0.5.0, contracts directly derived from the address type
    and there was no distinction between ``address`` and ``address payable``.

If you declare a local variable of contract type (``MyContract c``), you can call
functions on that contract. Take care to assign it from somewhere that is the
same contract type.

You can also instantiate contracts (which means they are newly created). You
can find more details in the :ref:`'Contracts via new'<creating-contracts>`
section.

The data representation of a contract is identical to that of the ``address``
type and this type is also used in the :ref:`ABI<ABI>`.

Contracts do not support any operators.

The members of contract types are the external functions of the contract
including any state variables marked as ``public``.

For a contract ``C`` you can use ``type(C)`` to access
:ref:`type information<meta-type>` about the contract.

.. index:: byte array, bytes32

Fixed-size byte arrays
----------------------

The value types ``bytes1``, ``bytes2``, ``bytes3``, ..., ``bytes32``
hold a sequence of bytes from one to up to 32.

Operators:

* Comparisons: ``<=``, ``<``, ``==``, ``!=``, ``>=``, ``>`` (evaluate to ``bool``)
* Bit operators: ``&``, ``|``, ``^`` (bitwise exclusive or), ``~`` (bitwise negation)
* Shift operators: ``<<`` (left shift), ``>>`` (right shift)
* Index access: If ``x`` is of type ``bytesI``, then ``x[k]`` for ``0 <= k < I`` returns the ``k`` th byte (read-only).

The shifting operator works with unsigned integer type as right operand (but
returns the type of the left operand), which denotes the number of bits to shift by.
Shifting by a signed type will produce a compilation error.

Members:

* ``.length`` yields the fixed length of the byte array (read-only).

.. note::
    The type ``bytes1[]`` is an array of bytes, but due to padding rules, it wastes
    31 bytes of space for each element (except in storage). It is better to use the ``bytes``
    type instead.

.. note::
    Prior to version 0.8.0, ``byte`` used to be an alias for ``bytes1``.

Dynamically-sized byte array
----------------------------

``bytes``:
    Dynamically-sized byte array, see :ref:`arrays`. Not a value-type!
``string``:
    Dynamically-sized UTF-8-encoded string, see :ref:`arrays`. Not a value-type!

.. index:: address, literal;address

.. _address_literals:

Address Literals
----------------

Hexadecimal literals that pass the address checksum test, for example
``0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF`` are of ``address`` type.
Hexadecimal literals that are between 39 and 41 digits
long and do not pass the checksum test produce
an error. You can prepend (for integer types) or append (for bytesNN types) zeros to remove the error.

.. note::
    The mixed-case address checksum format is defined in `EIP-55 <https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md>`_.

.. index:: literal, literal;rational

.. _rational_literals:

Rational and Integer Literals
-----------------------------

Integer literals are formed from a sequence of digits in the range 0-9.
They are interpreted as decimals. For example, ``69`` means sixty nine.
Octal literals do not exist in Solidity and leading zeros are invalid.

Decimal fractional literals are formed by a ``.`` with at least one number on
one side.  Examples include ``1.``, ``.1`` and ``1.3``.

Scientific notation in the form of ``2e10`` is also supported, where the
mantissa can be fractional but the exponent has to be an integer.
The literal ``MeE`` is equivalent to ``M * 10**E``.
Examples include ``2e10``, ``-2e10``, ``2e-10``, ``2.5e1``.

Underscores can be used to separate the digits of a numeric literal to aid readability.
For example, decimal ``123_000``, hexadecimal ``0x2eff_abde``, scientific decimal notation ``1_2e345_678`` are all valid.
Underscores are only allowed between two digits and only one consecutive underscore is allowed.
There is no additional semantic meaning added to a number literal containing underscores,
the underscores are ignored.

Number literal expressions retain arbitrary precision until they are converted to a non-literal type (i.e. by
using them together with anything other than a number literal expression (like boolean literals) or by explicit conversion).
This means that computations do not overflow and divisions do not truncate
in number literal expressions.

For example, ``(2**800 + 1) - 2**800`` results in the constant ``1`` (of type ``uint8``)
although intermediate results would not even fit the machine word size. Furthermore, ``.5 * 8`` results
in the integer ``4`` (although non-integers were used in between).

.. warning::
    While most operators produce a literal expression when applied to literals, there are certain operators that do not follow this pattern:

    - Ternary operator (``... ? ... : ...``),
    - Array subscript (``<array>[<index>]``).

    You might expect expressions like ``255 + (true ? 1 : 0)`` or ``255 + [1, 2, 3][0]`` to be equivalent to using the literal 256
    directly, but in fact they are computed within the type ``uint8`` and can overflow.

Any operator that can be applied to integers can also be applied to number literal expressions as
long as the operands are integers. If any of the two is fractional, bit operations are disallowed
and exponentiation is disallowed if the exponent is fractional (because that might result in
a non-rational number).

Shifts and exponentiation with literal numbers as left (or base) operand and integer types
as the right (exponent) operand are always performed
in the ``uint256`` (for non-negative literals) or ``int256`` (for a negative literals) type,
regardless of the type of the right (exponent) operand.

.. warning::
    Division on integer literals used to truncate in Solidity prior to version 0.4.0, but it now converts into a rational number, i.e. ``5 / 2`` is not equal to ``2``, but to ``2.5``.

.. note::
    Solidity has a number literal type for each rational number.
    Integer literals and rational number literals belong to number literal types.
    Moreover, all number literal expressions (i.e. the expressions that
    contain only number literals and operators) belong to number literal
    types.  So the number literal expressions ``1 + 2`` and ``2 + 1`` both
    belong to the same number literal type for the rational number three.


.. note::
    Number literal expressions are converted into a non-literal type as soon as they are used with non-literal
    expressions. Disregarding types, the value of the expression assigned to ``b``
    below evaluates to an integer. Because ``a`` is of type ``uint128``, the
    expression ``2.5 + a`` has to have a proper type, though. Since there is no common type
    for the type of ``2.5`` and ``uint128``, the Solidity compiler does not accept
    this code.

.. code-block:: solidity

    uint128 a = 1;
    uint128 b = 2.5 + a + 0.5;

.. index:: literal, literal;string, string
.. _string_literals:

String Literals and Types
-------------------------

String literals are written with either double or single-quotes (``"foo"`` or ``'bar'``), and they can also be split into multiple consecutive parts (``"foo" "bar"`` is equivalent to ``"foobar"``) which can be helpful when dealing with long strings.  They do not imply trailing zeroes as in C; ``"foo"`` represents three bytes, not four.  As with integer literals, their type can vary, but they are implicitly convertible to ``bytes1``, ..., ``bytes32``, if they fit, to ``bytes`` and to ``string``.

For example, with ``bytes32 samevar = "stringliteral"`` the string literal is interpreted in its raw byte form when assigned to a ``bytes32`` type.

String literals can only contain printable ASCII characters, which means the characters between and including 0x20 .. 0x7E.

Additionally, string literals also support the following escape characters:

- ``\<newline>`` (escapes an actual newline)
- ``\\`` (backslash)
- ``\'`` (single quote)
- ``\"`` (double quote)
- ``\n`` (newline)
- ``\r`` (carriage return)
- ``\t`` (tab)
- ``\xNN`` (hex escape, see below)
- ``\uNNNN`` (unicode escape, see below)

``\xNN`` takes a hex value and inserts the appropriate byte, while ``\uNNNN`` takes a Unicode codepoint and inserts an UTF-8 sequence.

.. note::

    Until version 0.8.0 there were three additional escape sequences: ``\b``, ``\f`` and ``\v``.
    They are commonly available in other languages but rarely needed in practice.
    If you do need them, they can still be inserted via hexadecimal escapes, i.e. ``\x08``, ``\x0c``
    and ``\x0b``, respectively, just as any other ASCII character.

The string in the following example has a length of ten bytes.
It starts with a newline byte, followed by a double quote, a single
quote a backslash character and then (without separator) the
character sequence ``abcdef``.

.. code-block:: solidity
    :force:

    "\n\"\'\\abc\
    def"

Any Unicode line terminator which is not a newline (i.e. LF, VF, FF, CR, NEL, LS, PS) is considered to
terminate the string literal. Newline only terminates the string literal if it is not preceded by a ``\``.

Unicode Literals
----------------

While regular string literals can only contain ASCII, Unicode literals – prefixed with the keyword ``unicode`` – can contain any valid UTF-8 sequence.
They also support the very same escape sequences as regular string literals.

.. code-block:: solidity

    string memory a = unicode"Hello 😃";

.. index:: literal, bytes

Hexadecimal Literals
--------------------

Hexadecimal literals are prefixed with the keyword ``hex`` and are enclosed in double
or single-quotes (``hex"001122FF"``, ``hex'0011_22_FF'``). Their content must be
hexadecimal digits which can optionally use a single underscore as separator between
byte boundaries. The value of the literal will be the binary representation
of the hexadecimal sequence.

Multiple hexadecimal literals separated by whitespace are concatenated into a single literal:
``hex"00112233" hex"44556677"`` is equivalent to ``hex"0011223344556677"``

Hexadecimal literals behave like :ref:`string literals <string_literals>` and have the same convertibility restrictions.

.. index:: enum

.. _enums:

Enums
-----

Enums are one way to create a user-defined type in Solidity. They are explicitly convertible
to and from all integer types but implicit conversion is not allowed.  The explicit conversion
from integer checks at runtime that the value lies inside the range of the enum and causes a
:ref:`Panic error<assert-and-require>` otherwise.
Enums require at least one member, and its default value when declared is the first member.
Enums cannot have more than 256 members.

The data representation is the same as for enums in C: The options are represented by
subsequent unsigned integer values starting from ``0``.

Using ``type(NameOfEnum).min`` and ``type(NameOfEnum).max`` you can get the
smallest and respectively largest value of the given enum.


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

        // Since enum types are not part of the ABI, the signature of "getChoice"
        // will automatically be changed to "getChoice() returns (uint8)"
        // for all matters external to Solidity.
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
    Enums can also be declared on the file level, outside of contract or library definitions.

.. index:: ! user defined value type, custom type

.. _user-defined-value-types:

User Defined Value Types
------------------------

A user defined value type allows creating a zero cost abstraction over an elementary value type.
This is similar to an alias, but with stricter type requirements.

A user defined value type is defined using ``type C is V``, where ``C`` is the name of the newly
introduced type and ``V`` has to be a built-in value type (the "underlying type"). The function
``C.wrap`` is used to convert from the underlying type to the custom type. Similarly, the
function ``C.unwrap`` is used to convert from the custom type to the underlying type.

The type ``C`` does not have any operators or bound member functions. In particular, even the
operator ``==`` is not defined. Explicit and implicit conversions to and from other types are
disallowed.

The data-representation of values of such types are inherited from the underlying type
and the underlying type is also used in the ABI.

The following example illustrates a custom type ``UFixed256x18`` representing a decimal fixed point
type with 18 decimals and a minimal library to do arithmetic operations on the type.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.8;

    // Represent a 18 decimal, 256 bit wide fixed point type using a user defined value type.
    type UFixed256x18 is uint256;

    /// A minimal library to do fixed point operations on UFixed256x18.
    library FixedMath {
        uint constant multiplier = 10**18;

        /// Adds two UFixed256x18 numbers. Reverts on overflow, relying on checked
        /// arithmetic on uint256.
        function add(UFixed256x18 a, UFixed256x18 b) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(UFixed256x18.unwrap(a) + UFixed256x18.unwrap(b));
        }
        /// Multiplies UFixed256x18 and uint256. Reverts on overflow, relying on checked
        /// arithmetic on uint256.
        function mul(UFixed256x18 a, uint256 b) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(UFixed256x18.unwrap(a) * b);
        }
        /// Take the floor of a UFixed256x18 number.
        /// @return the largest integer that does not exceed `a`.
        function floor(UFixed256x18 a) internal pure returns (uint256) {
            return UFixed256x18.unwrap(a) / multiplier;
        }
        /// Turns a uint256 into a UFixed256x18 of the same value.
        /// Reverts if the integer is too large.
        function toUFixed256x18(uint256 a) internal pure returns (UFixed256x18) {
            return UFixed256x18.wrap(a * multiplier);
        }
    }

Notice how ``UFixed256x18.wrap`` and ``FixedMath.toUFixed256x18`` have the same signature but
perform two very different operations: The ``UFixed256x18.wrap`` function returns a ``UFixed256x18``
that has the same data representation as the input, whereas ``toUFixed256x18`` returns a
``UFixed256x18`` that has the same numerical value.

.. index:: ! function type, ! type; function

.. _function_types:

Function Types
--------------

Function types are the types of functions. Variables of function type
can be assigned from functions and function parameters of function type
can be used to pass functions to and return functions from function calls.
Function types come in two flavours - *internal* and *external* functions:

Internal functions can only be called inside the current contract (more specifically,
inside the current code unit, which also includes internal library functions
and inherited functions) because they cannot be executed outside of the
context of the current contract. Calling an internal function is realized
by jumping to its entry label, just like when calling a function of the current
contract internally.

External functions consist of an address and a function signature and they can
be passed via and returned from external function calls.

Function types are notated as follows:

.. code-block:: solidity
    :force:

    function (<parameter types>) {internal|external} [pure|view|payable] [returns (<return types>)]

In contrast to the parameter types, the return types cannot be empty - if the
function type should not return anything, the whole ``returns (<return types>)``
part has to be omitted.

By default, function types are internal, so the ``internal`` keyword can be
omitted. Note that this only applies to function types. Visibility has
to be specified explicitly for functions defined in contracts, they
do not have a default.

Conversions:

A function type ``A`` is implicitly convertible to a function type ``B`` if and only if
their parameter types are identical, their return types are identical,
their internal/external property is identical and the state mutability of ``A``
is more restrictive than the state mutability of ``B``. In particular:

- ``pure`` functions can be converted to ``view`` and ``non-payable`` functions
- ``view`` functions can be converted to ``non-payable`` functions
- ``payable`` functions can be converted to ``non-payable`` functions

No other conversions between function types are possible.

The rule about ``payable`` and ``non-payable`` might be a little
confusing, but in essence, if a function is ``payable``, this means that it
also accepts a payment of zero Ether, so it also is ``non-payable``.
On the other hand, a ``non-payable`` function will reject Ether sent to it,
so ``non-payable`` functions cannot be converted to ``payable`` functions.

If a function type variable is not initialised, calling it results
in a :ref:`Panic error<assert-and-require>`. The same happens if you call a function after using ``delete``
on it.

If external function types are used outside of the context of Solidity,
they are treated as the ``function`` type, which encodes the address
followed by the function identifier together in a single ``bytes24`` type.

Note that public functions of the current contract can be used both as an
internal and as an external function. To use ``f`` as an internal function,
just use ``f``, if you want to use its external form, use ``this.f``.

A function of an internal type can be assigned to a variable of an internal function type regardless
of where it is defined.
This includes private, internal and public functions of both contracts and libraries as well as free
functions.
External function types, on the other hand, are only compatible with public and external contract
functions.
Libraries are excluded because they require a ``delegatecall`` and use :ref:`a different ABI
convention for their selectors <library-selectors>`.
Functions declared in interfaces do not have definitions so pointing at them does not make sense either.

Members:

External (or public) functions have the following members:

* ``.address`` returns the address of the contract of the function.
* ``.selector`` returns the :ref:`ABI function selector <abi_function_selector>`

.. note::
  External (or public) functions used to have the additional members
  ``.gas(uint)`` and ``.value(uint)``. These were deprecated in Solidity 0.6.2
  and removed in Solidity 0.7.0. Instead use ``{gas: ...}`` and ``{value: ...}``
  to specify the amount of gas or the amount of wei sent to a function,
  respectively. See :ref:`External Function Calls <external-function-calls>` for
  more information.

Example that shows how to use the members:

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

Example that shows how to use internal function types:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    library ArrayUtils {
        // internal functions can be used in internal library functions because
        // they will be part of the same code context
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

Another example that uses external function types:

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
            // Here goes the check that the reply comes from a trusted source
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
    Lambda or inline functions are planned but not yet supported.
