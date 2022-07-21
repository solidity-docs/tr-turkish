.. index:: ! constant

.. _constants:

**************************************
Constant ve Immutable State Değişkenleri
**************************************

State değişkenleri ``constant`` veya ``immutable`` olarak tanımlanabilir.
Her iki durumda da contract kurulduktan sonra (constructor çalıştıktan sonra) bu tür değişkenler değiştirilemez.
``constant`` compile-time'da (kodun içerisinde) tanımlı olması gerekirken,
``immutable`` değişkenler constructor içerisinde de tanımlanabilir.

``constant`` değişkenleri contractların dışarısında (dosya seviyesinde) da tanımlayabiliriz.

Derleyici bu tür değişkenler için storage'de slot ayırmaz. Çünkü bu değişkenlerin kullanıldığı
her yer, belirlenmiş değerle değiştirilir.

Normal state değişkenleriyle karşılaştırıldığında, constant ve immutable değişkenler çok daha az gaz harcar.
Constant değişkenlerde, kullanıldıkları her yere karşılığında verilen değer kopyalanıp yapıştırılır.
Bu, lokal optimizasyon olarak kullanılır. Immutable değişkenlerde ise, contractın kurulum anında (construction time)
karşılık gelen değeri belirlenir ve kullanıldığı her yere kopyalanıp yapıştırılır. Bu değerler
32 byte'dan daha az yer kaplasa bile 32 byte'lık bir alanda muhafaza edilir. Bu sebepten ötürü, bazı durumlarda
constant değerler kullanmak, immutable değerleri kullanmaktan daha ucuz olabilir.

Şu anda constant ve immutable bütün tipler için uygulanamamaktadır. Desteklenen tipler
:ref:`strings <strings>` (sadece constant) ve :ref:`değer tipleridir <value-types>`.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.4;

    uint constant X = 32**22 + 8;

    contract C {
        string constant TEXT = "abc";
        bytes32 constant MY_HASH = keccak256("abc");
        uint immutable decimals;
        uint immutable maxBalance;
        address immutable owner = msg.sender;

        constructor(uint decimals_, address ref) {
            decimals = decimals_;
            // Immutable tanımlamalarında blok zincirinden veri de okunabilir.
            maxBalance = ref.balance;
        }

        function isBalanceTooHigh(address other) public view returns (bool) {
            return other.balance > maxBalance;
        }
    }


Constant
========

``constant`` değişkenlerin değerleri derleme anında (compile-time) sabit olmalı ve değişkenin
tanımlandığı konumda belirtilmelidir. Herhangi bir storage'e erişim, blok zinciri verisi
(örneğin, ``block.timestamp``, ``address(this).balance`` veya
``block.number``) veya
çalıştırma verisi (``msg.value`` veya ``gasleft()``) veya başka contractlara yapılan external
çağrılara izin verilmez. Kullanılacak memory'i belirleme konusunda yan etki oluşturacak tanımalamalara
izin verilirken, başka memory objeleri üzerinde yan etki oluşturan tanımlamalara izin verilmez.
Built-in fonksiyonlarından ``keccak256``, ``sha256``, ``ripemd160``, ``ecrecover``, ``addmod`` ve ``mulmod``
fonksiyonlarının kullanımına izin verilmiştir (``keccak256`` başka contractları çağırsa da, bir istisnadır).

Memory belirleyicisi üzerinde yan etkiye izin verilmesinin sebebi, karmaşık yapılarında kurulabilinmesi
gereksinimidir (örneğin, lookup-table). Bu özellikler henüz tamamen kullanılabilir değildir.

Immutable
=========

``immutable`` olarak tanımlanan değişkenler ``constant`` olarak tanımlananlara göre
biraz daha az kısıtlanmıştır: Immutable değişkenler contractın constructor fonksiyonunda
keyfi bir değere atanabilir. Sadece bir kere tanımlanabilirler ve tanımlandıktan sonra
istenilen anda sahip oldukları değer okunabilir.

Derleyici tarafından oluşturulmuş contractın creation code'u, runtime code'u
return etmeden önce bütün immutable referanslarını tanımlanan değerle değiştirir.
Bu yüzden immutable değişken kullandığınız bir contract için,
compiler'ın oluşturduğu runtime code ile blok zincirinde saklanan runtime code'u
karşılaştırdığınızda farklı sonuçlar alırsınız.

.. note::
  Tanımlandıkları satırda direkt olarak değerleri atanan immutable değişkenler
  contractın constructor fonksiyonu çalıştıktan sonra initialize edilmiş olarak
  düşünülür. Bu demek oluyor ki başka bir immutable değişkenin değerini kullanan
  bir immutable değişkenin değerini direkt olarak atayamazsınız. Bunu ancak constructor
  içerisinde yapabilirsiniz.

  Bu state değişkenlerini ilk defa tanımlama sırasının farklı bir şekilde yorumlanmasını
  engellemek amacıyla konulmuş bir önleyicidir, özellikle de türetme (inheritance) konusunda.

