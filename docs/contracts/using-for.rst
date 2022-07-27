.. index:: ! using for, library

.. _using-for:

*********
Using For
*********

``using A for B;`` yönergesi, (``A``) fonksiyonlarını herhangi bir türe
(``B``) üye fonksiyonlar olarak eklemek için kullanılabilir. Bu fonksiyonlar,
çağrıldıkları nesneyi ilk parametreleri olarak alırlar (Python'daki  ``self`` değişkeni gibi).

Dosya seviyesinde veya bir contract içerisinde, contract seviyesinde, geçerlidir.

İlk kısım, ``A``, aşağıdakilerden biri olabilir:

- dosya seviyesindeki fonksiyonların bir listesi veya kütüphane fonksiyonları (``using {f, g, h, L.t} for uint;``) -
  sadece o fonksiyonlar eklenecektir.
- kütüphanenin adı (``using L for uint;``) - bütün fonksiyonlar (public ve internallerin hepsi) tipe eklenir.

Dosya seviyesinde, ikinci kısım, ``B``, açık bir tip olmalıdır (veri konumu belirtici olmadan).
Contractın içerisinde, ayrıca şu ifadeyi de kullanabilirsiniz ``using L for *;``, böylece ``L``
kütüphanesinin bütün fonksiyonları *bütün* tiplere eklenmiş olur.

Bir kütüphane belirtirseniz, kütüphanedeki tüm fonksiyonlar, ilk parametrenin türü 
nesnenin türüyle eşleşmese bile eklenir. Fonksiyonun çağrıldığı noktada tip kontrol 
edilir ve fonksiyon aşırı yük çözünürlüğü gerçekleştirilir.

Eğer bir fonksiyon listesi kullanırsanız (``using {f, g, h, L.t} for uint;``),
ardından gelen tip (``uint``) o kütüphanedeki bütün fonksiyonların ilk parametrelerine
gizlice dönüştürülebilir olmalıdır. Bu kontrol, fonksiyonların hiçbiri çağrılmasa bile
gerçekleştirilir.

``using A for B;`` direktifi, tüm fonksiyonları dahil olmak üzere yalnızca mevcut kapsamda 
(sözleşme veya mevcut modül/kaynak birim) etkindir ve kullanıldığı sözleşme veya modül 
dışında hiçbir etkisi yoktur. 

Yönerge dosya düzeyinde kullanıldığında ve aynı dosyada dosya düzeyinde tanımlanmış 
kullanıcı tanımlı bir türe uygulandığında, sonuna ``global`` sözcüğü eklenebilir. 
Bu, yalnızca using ifadesinin kapsamında değil, türün kullanılabilir olduğu her yerde 
(diğer dosyalar dahil) işlevlerin türe eklenmesi etkisine sahip olacaktır.

:ref:`libraries` bölümünde yazdığımız bir örneği dosya seviyesindeki
fonksiyonlarla yeniden yazalım:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.13;

    struct Data { mapping(uint => bool) flags; }
    // Şimdi örneğe fonksiyonları ekliyoruz.
    // Eklenen fonksiyonlar modül boyuna kullanılabilir.
    // Eğer modülü başka bir dosyadan eklerseniz
    // using yönergesini orada yeniden kullanmalısınız:
    //   import "flags.sol" as Flags;
    //   using {Flags.insert, Flags.remove, Flags.contains}
    //     for Flags.Data;
    using {insert, remove, contains} for Data;

    function insert(Data storage self, uint value)
        returns (bool)
    {
        if (self.flags[value])
            return false; // already there
        self.flags[value] = true;
        return true;
    }

    function remove(Data storage self, uint value)
        returns (bool)
    {
        if (!self.flags[value])
            return false; // not there
        self.flags[value] = false;
        return true;
    }

    function contains(Data storage self, uint value)
        view
        returns (bool)
    {
        return self.flags[value];
    }


    contract C {
        Data knownValues;

        function register(uint value) public {
            // Burada, Data türündeki tüm değişkenlerin karşılık 
            // gelen üye işlevleri vardır. Aşağıdaki işlev çağrısı, 
            // `Set.insert(knownValues, value)` ile aynıdır.
            require(knownValues.insert(value));
        }
    }

Yerleşik türleri bu şekilde genişletmek de mümkündür. 
Bu örnekte bir kütüphane kullanacağız.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.13;

    library Search {
        function indexOf(uint[] storage self, uint value)
            public
            view
            returns (uint)
        {
            for (uint i = 0; i < self.length; i++)
                if (self[i] == value) return i;
            return type(uint).max;
        }
    }
    using Search for uint[];

    contract C {
        uint[] data;

        function append(uint value) public {
            data.push(value);
        }

        function replace(uint from, uint to) public {
            // Bu, kütüphane işlev çağrısını gerçekleştirir
            uint index = data.indexOf(from);
            if (index == type(uint).max)
                data.push(to);
            else
                data[index] = to;
        }
    }

Tüm harici kütüphane çağrılarının gerçek EVM fonksiyon çağrıları olduğunu unutmayın. 
Bu, bellek veya değer türlerini geçerseniz, ``self`` değişken durumunda bile bir kopyanın 
gerçekleştirileceği anlamına gelir. Kopyalama yapılmayacak tek durum, depolama referans 
değişkenlerinin kullanıldığı veya dahili kütüphane fonksiyonlarının çağrıldığı durumlardır.
