.. index:: ! visibility, external, public, private, internal

.. |visibility-caveat| replace::Bir şeyi ``private`` veya ``internal`` yapmak sadece diğer contractların o bilgiye erişimini veya değiştirilmesini engeller. Ama bu bilgiler blok zinciri dışından erişilebilir durumdadır.

.. _visibility-and-getters:

**********************
Görünürlük ve Getter Fonksiyonlar
**********************

Durum Değişkenlerinde Görünürlük
=========================

``public``
    Public durum değişkenleri internallerden sadece bir açıdan farklıdır, o da derleyicinin direkt olarak bir
    :ref:`getter fonksiyon<getter-functions>` oluşturmasıdır. Bu şekilde diğer contractlar bu değerlere erişebilir.
    Aynı fonksiyon içerisinde external erişim sağlandığında (örneğin, ``this.x``) getter fonksiyonu çağrılırken,
    internal erişimde (örneğin, ``x``) değer direkt olarak storage'den alınır.
    Setter fonksiyonlar derleyici tarafından tanımlanmaz. Bu yüzden siz kendiniz bir setter fonksiyon eklemediyseniz
    diğer fonksiyonlar bu değişkeni değiştiremez.

``internal``
    Internal durum değişkenleri sadece tanımlandıkları contractlar ve o contractlardan türetilen (inherited)
    contractlar tarafından erişebilir durumdadır.
    External erişim mümkün değildir.
    Bütün durum değişkenlerinin default hali internal'dir.

``private``
    Private durum değişkenlerine sadece tanımlandıkları contracttan erişim mümkündür. Internal'den farklı olarak
    türetilen contractlardan da erişilemez.

.. warning::
    |visibility-caveat|

Fonksiyonlarda Görünürlük
===================

Solidity iki tip fonksiyon çağrısı bilir: gerçek bir EVM mesaj çağrısı yapan external'lar ve bu çağrıyı yapmayan internal'lar.
Ayrıca internal fonksiyonlar türetilen fonksiyonlardan erişilemez hale de getirilebilir.
Bu da ortaya dört çeşit fonksiyon görünürlüğü çıkarır.

``external``
    External fonksiyonlar contract interface'inin bir parçasıdır,
    bu da demektir ki diğer contractlar ve transactionlar tarafından çağrılabilirler.
    Bir ``f`` external fonksiyonu internal olarak çağrılamaz (yani, ``f()`` işe yaramaz, ama ``this.f()`` çalışır).

``public``
    Public fonksiyonlar contract interface'inin bir parçasıdır
    ve internal olarak veya mesaj çağrıları ile kullanılabilirler.

``internal``
    Internal fonksiyonlar sadece tanımlandıkları contracttan veya o contracttan türetilen contractlar tarafından erişilebilir.
    External olarak erişim mümkün değildir.
    ABI kullanılarak external olarak erişilemese bile mapping ve storage referanslarını parametre olarak alabilirler.

``private``
    Private fonksiyonlar internaller gibidir ama bunlara türetilen fonksiyonlardan da erişim mümkün değildir.

.. warning::
    |visibility-caveat|

Görünürlük parametreleri durum değişkenleri için değişkenin tipinden sonra yazılırken
fonksiyonlarda parametreler ve return tanımının arasına yazılır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        function f(uint a) private pure returns (uint b) { return a + 1; }
        function setData(uint a) internal { data = a; }
        uint public data;
    }

Aşağıdaki örnekte, ``D``, ``c.getData()`` çağrısı yapabilir ve ``data`` değerini elde eder,
ama ``f`` fonksiyonunu çağıramaz. ``E`` contractı ise ``C`` contractından türetildiği için
``compute`` fonksiyonunu çağırabilir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        uint private data;

        function f(uint a) private pure returns(uint b) { return a + 1; }
        function setData(uint a) public { data = a; }
        function getData() public view returns(uint) { return data; }
        function compute(uint a, uint b) internal pure returns (uint) { return a + b; }
    }

    // Bu contract derlenemez, hata verir
    contract D {
        function readData() public {
            C c = new C();
            uint local = c.f(7); // hata: `f` görünür değil
            c.setData(3);
            local = c.getData();
            local = c.compute(3, 5); // hata: `compute` görünür değil
        }
    }

    contract E is C {
        function g() public {
            C c = new C();
            uint val = compute(3, 5); // internal fonksiyona türetilen fonksiyon sayesinde erişim sağlanabilir
        }
    }

.. index:: ! getter;function, ! function;getter
.. _getter-functions:

Getter Fonksiyonlar
================

Derleyici bütün **public** durum değişkenleri için getter fonksiyonu oluşturur.
Örneğin aşağıdaki contract için, derleyici ``data`` adında bir fonksiyon üretir.
Bu fonksiyon hiçbir parametre almaz ve ``uint`` tipinde bir değişken return eder.
Return edilen değer ise ``data`` değişkeninde saklanan değerdir. Durum değişkenleri
tanımlandıkları yerde initialize edilebilir (initialize, bir değişkenin ilk defa tanımlanması olarak çevrilebilir).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract C {
        uint public data = 42;
    }

    contract Caller {
        C c = new C();
        function f() public view returns (uint) {
            return c.data();
        }
    }

Getter fonksiyonların görünürlüğü external'dir. Eğer internal olarak
erişim sağlandıysa (``this.`` olmadan), bu bir durum değişkenine erişim
anlamına gelir.  Eğer external olarak erişildiyse
(``this.`` kullanarak), bu getter fonksiyonuna erişim anlamına gelir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract C {
        uint public data;
        function x() public returns (uint) {
            data = 3; // internal erişim
            return this.data(); // external erişim
        }
    }

Eğer bir ``public`` görünürlüğe sahip dizi tipinden bir durum değişkenine sahipseniz, getter
fonksiyonunu kullanarak sadece tek bir elemana erişim sağlayabilirsiniz. Bu mekanizma
tüm diziyi return ederken oluşan yüksek gaz ücretlerinden sıyrılmak için kurulmuştur. Hangi elemanın
return edileceğini belirtmek için parametreleri kullanabilirsiniz (örneğin, ``myArray(0)``).
Eğer bütün diziyi tek bir fonksiyon ile elde etmeniz gerekiyorsa, bunun için aşağıdaki gibi
bir fonksiyon yazmanız gerekir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract arrayExample {
        // public durum değişkeni
        uint[] public myArray;

        // Derleyici tarafından tanımlanan getter fonksiyonu
        /*
        function myArray(uint i) public view returns (uint) {
            return myArray[i];
        }
        */

        // Bütün array'i return eden fonksiyon
        function getArray() public view returns (uint[] memory) {
            return myArray;
        }
    }

Şimdi ``getArray()`` fonksiyonunu kullanarak bütün array'i elde edebilirsiniz. Tek tek bütün elemanları
``myArray(i)`` kullanarak çağırmanıza gerek kalmadı.

Sıradaki örnek biraz daha karmaşık.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract Complex {
        struct Data {
            uint a;
            bytes3 b;
            mapping (uint => uint) map;
            uint[3] c;
            uint[] d;
            bytes e;
        }
        mapping (uint => mapping(bool => Data[])) public data;
    }

Derleyici bize aşağıdaki gibi bir getter fonksiyonu oluşturur. Struct'daki mapping'ler ve diziler 
(byte dizileri istisnadır) gözardı edilmiştir. Çünkü getter fonksiyonlarında onların spesifik bir elemanına uygun bir şekilde
erişim mümkün değildir.

.. code-block:: solidity

    function data(uint arg1, bool arg2, uint arg3)
        public
        returns (uint a, bytes3 b, bytes memory e)
    {
        a = data[arg1][arg2][arg3].a;
        b = data[arg1][arg2][arg3].b;
        e = data[arg1][arg2][arg3].e;
    }
