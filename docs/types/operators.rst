.. index:: ! operator

Operatörler
============

Aritmetik operatörler ve bit operatörleri, iki işlenen aynı türe sahip olmasa bile uygulanabilir. Örneğin, ``y = x + z`` yi hesaplayabilirsiniz, burada ``x`` bir ``uint8`` dir ve ``z`` nin türü ``uint32`` dir. Bu durumlarda, işlemin hesaplandığı türü (taşma durumunda bu önemlidir) ve operatörün sonucunun türünü belirlemek için aşağıdaki mekanizma kullanılacaktır:

1. Sağ işlenenin türü dolaylı olarak sol işlenenin türüne dönüştürülebiliyorsa, 
    sol işlenenin türünü kullanın.
2. Sol işlenenin türü dolaylı olarak sağ işlenenin türüne dönüştürülebiliyorsa, 
    sağ işlenenin türünü kullanın,
3. İki seçenek de uygulanamıyorsa işleme izin verilmez.

<<<<<<< HEAD
İşlenenlerden birinin :ref:`gerçek sayı <rational_literals>` olması durumunda, ilk önce değeri tutabilen en küçük tür olan "mobil türe" dönüştürülür (aynı bit genişliğindeki işaretsiz türler, işaretli türlerden "daha küçük" olarak kabul edilir) .
=======
In case one of the operands is a :ref:`literal number <rational_literals>` it is first converted to its
"mobile type", which is the smallest type that can hold the value
(unsigned types of the same bit-width are considered "smaller" than the signed types).
If both are literal numbers, the operation is computed with effectively unlimited precision in
that the expression is evaluated to whatever precision is necessary so that none is lost
when the result is used with a non-literal type.
>>>>>>> v0.8.17

Her ikisi de gerçek sayıysa, işlem keyfi bir kesinlikle hesaplanır.

Operatörün sonuç türü, sonucun her zaman ``bool`` olduğu karşılaştırma operatörleri dışında, işlemin gerçekleştirildiği türle aynıdır.

``**`` (üs alma), ``<<`` ve ``>>`` operatörleri, işlem ve sonuç için sol işlenenin türünü kullanır.


Üçlü Operatör
----------------

Üçlü operatör, ``<expression> ? <trueExpression> : <falseExpression>`` formunda bulunan ifadelerin açıklanmasında kullanılır. Ana ``<expression>`` değerlendirmesinin sonucuna bağlı olarak verilen son iki ifadeden birini değerlendirir. ``<expression>`` "doğru" olarak değerlendirilirse, ``<trueExpression>`` olarak sayılır, aksi takdirde ``<falseExpression>`` olarak sayılır.

Üçlü operatörün sonucu, tüm işlenenleri rasyonel sayı değişmezleri olsa bile, bir rasyonel sayı türüne sahip değildir. Sonuç türü, iki işlenenin türlerinden yukarıdakiyle aynı şekilde belirlenir, gerekirse ilk önce mobil türlerine dönüştürülür.

Sonuç olarak, ``255 + (true ? 1 : 0)`` işlemi, aritmetik taşma nedeniyle geri döndürülecektir (revert edilecektir). Bunun nedeni, ``(true ? 1 : 0)`` ifadesinin ``uint8`` türünde olmasıdır.Bu, eklemenin ``uint8`` içinde gerçekleştirilmesini zorunlu kılıyor ve 256'nın bu tür için izin verilen aralığı aşıyor.

Diğer bir sonuç da, ``1.5 + 1.5`` gibi bir ifadenin geçerli olduğu, ancak ``1.5 + (true ? 1.5 : 2.5)`` olmadığıdır. Bunun nedeni, birincisinin sınırsız kesinlikle değerlendirilen rasyonel bir ifade olması ve yalnızca nihai değerinin önemli olmasıdır. İkincisi, şu anda izin verilmeyen bir kesirli rasyonel sayının bir tam sayıya dönüştürülmesini içerir.

.. index:: assignment, lvalue, ! compound operators

Bileşik Operatörler ve Artırma/Azaltma Operatörleri
----------------------------------------------------

``a`` bir LValue ise (yani bir değişken veya atanabilecek bir şey), aşağıdaki operatörler kısayol olarak kullanılabilir:

``a += e``, ``a = a + e`` ile eşdeğerdir. ``-=``, ``*=``, ``/=``, ``%=``, ``|=``, ``&=``, ``^=``, ``<<=`` ve ``>>=`` buna göre tanımlanır. ``a++`` ve ``a--``, ``a += 1`` / ``a -= 1`` ile eşdeğerdir, ancak ifadenin kendisi hala önceki ``a`` değerine sahiptir. Buna karşılık, ``--a`` ve ``++a``, ``a`` üzerinde aynı etkiye sahiptir ancak değişiklikten sonra değeri döndürür.


.. index:: !delete

.. _delete:

silmek
------

``delete a``, türün başlangıç değerini ``a``ya atar. Yani, tamsayılar için ``a = 0`` ile eşdeğerdir, ancak sıfır uzunlukta dinamik bir dizi veya tüm öğeleri başlangıç değerlerine ayarlanmış aynı uzunlukta statik bir dizi atadığı dizilerde de kullanılabilir.

``delete a[x]``, dizinin ``x`` dizinindeki öğeyi siler ve diğer tüm öğelere ve dizinin uzunluğuna dokunmadan bırakır. Bu özellikle dizide bir boşluk bırakıldığı anlamına gelir. Öğeleri kaldırmayı planlıyorsanız, :ref:`eşleme <mapping-types>` yapmak muhtemelen daha iyi bir seçimdir.

Yapılar (structs) için, tüm üyelerin sıfırlandığı bir yapı atar. Başka bir deyişle, ``a`` nın ``delete a`` dan sonraki değeri, ``a`` nın atama olmadan bildirilmesiyle aynıdır:

``delete`` fonksiyonunun eşlemeler üzerinde hiçbir etkisi yoktur (çünkü eşlemelerin anahtarları rastgele olabilir ve genellikle bilinmez). Bu nedenle, bir yapıyı silerseniz, eşleme olmayan tüm üyeleri sıfırlar ve eşleme olmadıkça üyelere geri döner. Ancak, bireysel anahtarlar ve eşledikleri şey silinebilir: ``a`` bir eşleme ise, ``delete a[x]`` , ``x`` de depolanan değeri siler.

``delete a`` nın gerçekten ``a`` ya atanmış gibi davrandığını, yani ``a`` da yeni bir nesne depoladığını unutmamak önemlidir. Bu ayrım, ``a`` referans değişkeni olduğunda görünür:
Daha önce atıfta bulunduğu değeri değil, yalnızca ``a`` nın kendisini sıfırlayacaktır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract DeleteExample {
        uint data;
        uint[] dataArray;

        function f() public {
            uint x = data;
            delete x; // x'i 0'a ayarlar, verileri etkilemez
            delete data; // verileri 0'a ayarlar, x'i etkilemez
            uint[] storage y = dataArray;
            delete dataArray; // bu, dataArray.length değerini sıfıra ayarlar, ancak uint[] karmaşık bir nesne olduğundan,
            // depolama nesnesinin diğer adı olan y da etkilenir.
            // Öte yandan: "delete y" geçerli değildir, çünkü depolama nesnelerine başvuran yerel değişkenlere atamalar yalnızca mevcut depolama nesnelerinden yapılabilir.
            assert(y.length == 0);
        }
    }

.. index:: ! operator; precedence
.. _order:

Operatörlerin Öncelik Sırası
--------------------------------

.. include:: types/operator-precedence-table.rst
