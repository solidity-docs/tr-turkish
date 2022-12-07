.. index:: ! type;conversion, ! cast

.. _types-conversion-elementary-types:

Temel Türler Arası Dönüşümler
====================================

Örtülü Dönüşümler
--------------------

Örtülü tür dönüşümü, argümanları fonksiyonlara iletme ya da operatör atamaları sırasında, derleyici tarafından
otomatik olarak uygulanır. Genel olarak, bilgi kaybı yoksa ve anlamsal açıdan bir sorun yoksa, değer türleri arasında örtülü bir dönüşüm mümkündür. 

Örneğin, ``uint8`` türü,
``uint16`` türüne ve ``int128`` türü, ``int256`` türüne dönüştürülebilirken, ``int8`` türü ``uint256`` türüne dönüştürülemez çünkü  ``uint256``, ``-1`` gibi değerleri tutamaz.

Bir operatör birbirinden farklı türlere uygulanırsa, derleyici işlenenlerden birini örtük olarak diğerinin türüne dönüştürmeye çalışır (aynısı atamalar için de geçerlidir).
Bu, işlemlerin her zaman işlenenlerden birinin türünde gerçekleştirildiği anlamına gelir.

Hangi örtük dönüşümlerin mümkün olduğu hakkında daha fazla ayrıntı için, lütfen türlerle ilgili bölümlere bakın.

Aşağıdaki örnekte, toplamanın işlenenleri olarak ``y`` ve ``z``, aynı türe sahip değildir, fakat ``uint8`` örtük olarak
``uint16`` türüne dönüştürülebilirken bunun tersi mümkün değildir. Bu sebeple, ``uint16`` türünde bir dönüştürme yapılmadan önce 
``y`` türü, ``z`` türüne dönüştürülür.  ``y + z`` ifadesinden elde edilen tür, ``uint16`` dır.
Toplama işleminin sonucu ``uint32`` türünde bir değişkene atandığı için, toplama işleminden sonra yeniden örtük dönüştürme gerçekleşir.

.. code-block:: solidity

    uint8 y;
    uint16 z;
    uint32 x = y + z;


Açık Dönüşümler
--------------------

Derleyici örtük dönüştürmeye izin vermiyorsa ancak bir dönüştürmenin işe yarayacağından eminseniz, bazen açık bir tür dönüştürme mümkündür. Bu, beklenmeyen davranışlara neden olabilir ve derleyicinin bazı güvenlik özelliklerini atlamanıza izin verir, bu nedenle sonucun istediğiniz ve beklediğiniz gibi olduğunu test ettiğinizden emin olun!

Negatif değere sahip bir ``int`` değişkenini, ``uint`` değişkenine dönüştüren aşağıdaki örneği ele alalım:

.. code-block:: solidity

    int  y = -3;
    uint x = uint(y);

Bu kod bloğunun sonunda ``x``, ``0xfffff..fd`` (64 adet onaltılık karaker) değerine sahip olacaktır, bu, iki'nin 256 bitlik tümleyen (two's complement) temsili olan -3'tür.

Bir tam sayı, kendisinden daha küçük bir türe açık şekilde dönüştürülürse, daha yüksek dereceli bitler kesilir.

.. code-block:: solidity

    uint32 a = 0x12345678;
    uint16 b = uint16(a); // b, 0x5678 olacaktır

Bir tam sayı, kendisinden daha büyük bir türe açık şekilde dönüştürülürse, elde edilen ortak tümleyenin solu yani daha yüksek dereceli ucu doldurulur. Dönüşümün sonucu orijinal tam sayıya eşit olacaktır:

.. code-block:: solidity

    uint16 a = 0x1234;
    uint32 b = uint32(a); // b, 0x00001234 olacaktır
    assert(a == b);

Sabit boyutlu bayt dizisi türleri, dönüşümler sırasında farklı davranır. Bireysel bayt dizileri olarak düşünülebilirler ve daha küçük bir türe dönüştürmek diziyi kesecektir:

.. code-block:: solidity

    bytes2 a = 0x1234;
    bytes1 b = bytes1(a); // b, 0x12 olacaktır


Sabit boyutlu bir bayt dizisi türü, daha büyük bir türe açıkça dönüştürülürse, elde edilen ortak tümleyen sağ tarafta doldurulur. Sabit bir dizindeki bayt dizisine erişmek, dönüştürmeden önce ve sonra aynı değerle sonuçlanır (dizin hala aralıktaysa):

.. code-block:: solidity

    bytes2 a = 0x1234;
    bytes4 b = bytes4(a); // b, 0x12340000 olacaktır
    assert(a[0] == b[0]);
    assert(a[1] == b[1]);

Tamsayılar ve sabit boyutlu bayt dizileri, kesme veya doldurma sırasında farklı davrandığından, tamsayılar ve sabit boyutlu bayt dizileri arasındaki açık dönüştürmelere yalnızca, her ikisi de aynı boyuta sahipse izin verilir. Farklı boyuttaki tamsayılar ve sabit boyutlu bayt dizileri arasında dönüştürmek istiyorsanız, istenen kesme ve doldurma kurallarını açık hale getiren ara dönüşümleri kullanmanız gerekir:

.. code-block:: solidity

    bytes2 a = 0x1234;
    uint32 b = uint16(a); // b, 0x00001234 olacaktır
    uint32 c = uint32(bytes4(a)); // c, 0x12340000 olacaktır
    uint8 d = uint8(uint16(a)); // d, 0x34 olacaktır
    uint8 e = uint8(bytes1(a)); // e, 0x12 olacaktır

``bytes`` dizileri ve ``bytes`` çağrı verisi (calldata) dilimleri, sabit bayt türlerine(``bytes1``/.../``bytes32``) açıkça dönüştürülebilir.
Dizinin hedef sabit bayt türünden daha uzun olması durumunda, sonunda kesme gerçekleşir. Dizi hedef türden daha kısaysa, sonunda sıfırlarla doldurulur.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.5;

    contract C {
        bytes s = "abcdefgh";
        function f(bytes calldata c, bytes memory m) public view returns (bytes16, bytes3) {
            require(c.length == 16, "");
            bytes16 b = bytes16(m);  // 'm'in uzunluğu 16'dan büyükse, kesme gerçekleşecektir
            b = bytes16(s);  // sağa genişletilir, sonuç "abcdefgh\0\0\0\0\0\0\0\0" olacaktır
            bytes3 b1 = bytes3(s); // kesilir, b1, "abc"ye eşittir
            b = bytes16(c[:8]);  // sıfırlar ile genişletilir
            return (b, b1);
        }
    }

.. _types-conversion-literals:

İfadeler (Literals) ve Temel Türler Arasındaki Dönüşümler
==========================================================

Tamsayı Türleri
--------------------

Ondalık ve onaltılık sayı ifadeleri, onu kesmeden temsil edecek kadar büyük herhangi bir tamsayı türüne örtük olarak dönüştürülebilir:

.. code-block:: solidity

    uint8 a = 12; // uygun
    uint32 b = 1234; // uygun
    uint16 c = 0x123456; // hatalı, çünkü 0x3456 olacak şekilde kesilmek zorundadır

.. note::
    0.8.0 sürümünden önce, herhangi bir ondalık veya onaltılık sayı ifadeleri bir tamsayı türüne açıkça dönüştürülebilirdi. 0.8.0'dan itibaren, bu tür açık dönüştürmeler, örtülü dönüştürmeler kadar katıdır, yani, yalnızca ifade elde edilen aralığa uyuyorsa bunlara izin verilir.  

Sabit Boyutlu Bayt Dizileri
---------------------------------

Ondalık sayı ifadeleri örtük olarak sabit boyutlu bayt dizilerine dönüştürülemez. Onaltılık sayı ifadeleri olabilir, ancak yalnızca onaltılık basamak sayısı bayt türünün boyutuna tam olarak uyuyorsa. Bir istisna olarak, sıfır değerine sahip hem ondalık hem de onaltılık ifadeler herhangi bir sabit boyutlu bayt türüne dönüştürülebilir:

.. code-block:: solidity

    bytes2 a = 54321; // izin verilmez
    bytes2 b = 0x12; //  izin verilmez
    bytes2 c = 0x123; // izin verilmez
    bytes2 d = 0x1234; // uygun
    bytes2 e = 0x0012; // uygun
    bytes4 f = 0; // uygun
    bytes4 g = 0x0; // uygun

String ifadeleri ve onaltılı string ifadeleri, karakter sayıları bayt türünün boyutuyla eşleşiyorsa, örtük olarak sabit boyutlu bayt dizilerine dönüştürülebilir:

.. code-block:: solidity

    bytes2 a = hex"1234"; // uygun
    bytes2 b = "xy"; // uygun
    bytes2 c = hex"12"; // izin verilmez
    bytes2 d = hex"123"; // izin verilmez
    bytes2 e = "x"; // izin verilmez
    bytes2 f = "xyz"; // izin verilmez

Adresler
---------

 :ref:`address_literals` bölümünde açıklandığı gibi, sağlama toplamı (checksum) testini geçen doğru boyuttaki onaltılık ifadeler ``address`` türündedir. Başka hiçbir ifade ``address`` türüne örtük olarak dönüştürülemez.

``bytes20`` değişkeninden ya da herhangi bir tam sayı türünden ``adress`` değişkenine yapılacak açık dönüştürmeler, ``address payable`` ile sonuçlanır.

``address a``'dan  ``address payable``'a yapılacak bir dönüşüm, ``payable(a)`` kullanılarak gerçekleştirilebilir.
