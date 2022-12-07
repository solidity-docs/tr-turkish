.. index:: ! library, callcode, delegatecall

.. _libraries:

*************
Kütüphaneler
*************

Kütüphaneler akıllı sözleşmelere benzerler, ama onların amacı sadece bir kere deploy edilip
daha sonrasında ihtiyaç duyulması halinde ``DELEGATECALL`` ile çağrılmalarıdır
(Homestead'a kadar ``CALLCODE`` kullanılırdı). Bu demek oluyor ki kütüphane fonksiyonları
çağrıldığında, onların kodu çağıran akıllı sözleşmenin içeriği ile çalıştırılıyor, mesela ``this``
sözcüğü çağıran akıllı sözleşmeyi işaret eder ve özellikle storage olarak çağıran akıllı sözleşmenin
storage kısmı kullanılır. Bir kütüphane izole edilmiş bir kaynak kodu parçası olduğundan, 
yalnızca açıkça sağlanmışlarsa çağrı sözleşmesinin durum değişkenlerine erişebilir 
(aksi takdirde bunları adlandırmanın hiçbir yolu yoktur). Kütüphane fonksiyonları yalnızca 
durumu değiştirmedikleri takdirde (yani ``view`` veya ``pure`` fonksiyonlarsa) doğrudan 
(yani ``DELEGATECALL`` kullanılmadan) çağrılabilir, çünkü kütüphanelerin durumsuz 
olduğu varsayılır. Özellikle, bir kütüphaneyi yok etmek mümkün değildir.

.. note::
    0.4.20 sürümüne kadar, Solidity'nin tip sistemini atlayarak kütüphaneleri yok etmek mümkündü.
    Bu sürümden başlayarak, kütüphaneler, durumu değiştiren fonksiyonların doğrudan çağrılmasına 
    izin vermeyen bir :ref:`mekanizma<call-protection>` içerir (yani ``DELEGATECALL`` olmadan).

Kütüphaneler, onları kullanan akıllı sözleşmelerin zımni temel akıllı sözleşmeleri olarak görülebilir. 
Miras hiyerarşisinde açıkça görünmezler, ancak kütüphane fonksiyonlarına yapılan çağrılar, 
açık temel akıllı sözleşmelerin fonksiyonlarına yapılan çağrılara benzer 
(L.f() gibi nitelikli erişim kullanarak). 
Tabii ki, dahili fonksiyonlara yapılan çağrılar dahili çağrı kuralını kullanır; 
bu, tüm dahili türlerin iletilebileceği ve bellekte depolanan türlerin kopyalanmadan 
referans olarak iletileceği anlamına gelir. Bunu EVM'de gerçekleştirmek için, bir akıllı sözleşmeden 
çağrılan dahili kütüphane fonksiyonlarının ve buradan çağrılan tüm fonksiyonların kodu 
derleme zamanında çağrı akıllı sözleşmesine dahil edilecek ve bir ``DELEGATECALL`` yerine normal 
bir JUMP çağrısı kullanılacaktır.

.. note::
    Public fonksiyonlar söz konusu olduğunda miras analojisi bozulur. 
    L.f() ile bir genel kütüphane fonksiyonunun çağrılması, 
    harici bir çağrıyla sonuçlanır (kesin olarak ``DELEGATECALL``). 
    Buna karşılık, A mevcut akıllı sözleşmesinin temel akıllı sözleşmesi olduğunda, A.f() dahili bir çağrıdır.

.. index:: using for, set

Aşağıdaki örnek, kütüphanelerin nasıl kullanılacağını gösterir 
(ancak manuel bir yöntem kullanarak, bir kümeyi uygulamak için daha gelişmiş 
bir örnek için kullanmayı kontrol ettiğinizden emin olun).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;


    // Çağrı akıllı sözleşmesinde verilerini tutmak 
    // için kullanılacak yeni bir struct veri türü tanımlıyoruz.
    struct Data {
        mapping(uint => bool) flags;
    }

    library Set {
        // İlk parametrenin "depolama referansı" türünde 
        // olduğunu ve bu nedenle çağrının bir parçası 
        // olarak içeriğinin değil, yalnızca depolama 
        // adresinin iletildiğini unutmayın. 
        // Bu, kütüphane fonksiyonlarının özel bir özelliğidir. 
        // Fonksiyon, o nesnenin bir yöntemi olarak görülebiliyorsa, 
        // ilk parametreyi 'self' olarak adlandırmak deyimseldir.
        function insert(Data storage self, uint value)
            public
            returns (bool)
        {
            if (self.flags[value])
                return false; // zaten orada
            self.flags[value] = true;
            return true;
        }

        function remove(Data storage self, uint value)
            public
            returns (bool)
        {
            if (!self.flags[value])
                return false; // orada değil
            self.flags[value] = false;
            return true;
        }

        function contains(Data storage self, uint value)
            public
            view
            returns (bool)
        {
            return self.flags[value];
        }
    }


    contract C {
        Data knownValues;

        function register(uint value) public {
            // "Instance" geçerli akıllı sözleşme olacağından, 
            // kütüphane fonksiyonları kütüphanenin belirli 
            // bir örneği olmadan çağrılabilir.
            require(Set.insert(knownValues, value));
        }
        // Bu sözleşmede ayrıca direkt olarak knownValues.flags değişkenine de erişebiliriz.
    }

Elbette kütüphaneleri kullanmak için bu yolu izlemeniz gerekmez: struct veri türleri 
tanımlamadan da kullanılabilirler. Fonksiyonlar ayrıca herhangi bir depolama 
referans parametresi olmadan da çalışırlar ve herhangi bir pozisyonda 
birden fazla depolama referans parametresine sahip olabilirler.

``Set.contains``, ``Set.insert`` ve ``Set.remove`` çağrılarının hepsi
harici çağrı olarak derlenir (``DELEGATECALL``). Eğer kütüphaneleri kullanacaksanız
gerçekten bir harici fonksiyon çağrısı yaptığınızı unutmayın.
``msg.sender``, ``msg.value`` ve ``this`` çağrı boyunca kendi değerlerini koruyacaktır
(Homestead öncesi ``CALLCODE`` yüzünden ``msg.sender`` ve ``msg.value`` değişiyordu).

Aşağıdaki örnek, harici fonksiyon çağrılarının ek yükü olmadan özel türleri 
uygulamak için :ref:`bellekte depolanan türlerin <data-location>` ve kütüphanelerdeki dahili fonksiyonların 
nasıl kullanılacağını gösterir:

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.0;

    struct bigint {
        uint[] limbs;
    }

    library BigInt {
        function fromUint(uint x) internal pure returns (bigint memory r) {
            r.limbs = new uint[](1);
            r.limbs[0] = x;
        }

        function add(bigint memory a, bigint memory b) internal pure returns (bigint memory r) {
            r.limbs = new uint[](max(a.limbs.length, b.limbs.length));
            uint carry = 0;
            for (uint i = 0; i < r.limbs.length; ++i) {
                uint limbA = limb(a, i);
                uint limbB = limb(b, i);
                unchecked {
                    r.limbs[i] = limbA + limbB + carry;

                    if (limbA + limbB < limbA || (limbA + limbB == type(uint).max && carry > 0))
                        carry = 1;
                    else
                        carry = 0;
                }
            }
            if (carry > 0) {
                // çok kötü, bir limb eklemeliyiz
                uint[] memory newLimbs = new uint[](r.limbs.length + 1);
                uint i;
                for (i = 0; i < r.limbs.length; ++i)
                    newLimbs[i] = r.limbs[i];
                newLimbs[i] = carry;
                r.limbs = newLimbs;
            }
        }

        function limb(bigint memory a, uint index) internal pure returns (uint) {
            return index < a.limbs.length ? a.limbs[index] : 0;
        }

        function max(uint a, uint b) private pure returns (uint) {
            return a > b ? a : b;
        }
    }

    contract C {
        using BigInt for bigint;

        function f() public pure {
            bigint memory x = BigInt.fromUint(7);
            bigint memory y = BigInt.fromUint(type(uint).max);
            bigint memory z = x.add(y);
            assert(z.limb(1) > 0);
        }
    }

Bir kütüphanenin adresini, kütüphane tipini ``address`` tipine çevirerek, 
yani ``address(LibraryName)`` kullanarak elde etmek mümkündür.

Derleyici kütüphanenin konuşlandırılacağı adresi bilmediğinden, 
derlenmiş onaltılık kod ``__$30bbc0abd4d6364515865950d3e0d10953$__`` biçiminde yer tutucular 
içerecektir. Yer tutucu, tam nitelikli kütüphane adının keccak256 hashinin hex kodlamasının 
34 karakterlik bir önekidir; bu, örneğin kütüphane ``bigint.sol`` isimli bir dosyada
ve ``libraries/`` isimli bir dizinde bulunuyorsa şu şekilde gösterilir ``libraries/bigint.sol:BigInt``. 
Bu tür bayt kodu eksiktir ve dağıtılmamalıdır. Yer tutucuların gerçek adreslerle değiştirilmesi gerekir. 
Bunu, kütüphane derlenirken bunları derleyiciye ileterek veya önceden derlenmiş bir ikili dosyayı 
güncellemek için bağlayıcıyı kullanarak yapabilirsiniz. Bağlama için komut satırı derleyicisinin 
nasıl kullanılacağı hakkında bilgi için :ref:`library-linking` konusuna bakın.

Akıllı sözleşmelerle kıyaslandığında, kütüphaneler aşağıdaki şekillerde kısıtlanmışlardır:

- durum değişkenleri olamaz
- miras veremezler veya alamazlar
- Ether kabul edemezler
- yok edilemezler

(Bunlar ilerleyen zamanlarda kaldırılabilirler.)

.. _library-selectors:
.. index:: ! selector; of a library function

Function Signatures and Selectors in Libraries
===============================================

Public veya external kütüphane fonksiyonlarına harici çağrılar mümkün olsa da, 
bu tür çağrılar için çağrı kuralının Solidity'nin içinde olduğu ve normal 
:ref:`contract ABI<ABI>` için belirtilenle aynı olmadığı kabul edilir. 
External kütüphane fonksiyonları, örneğin özyinelemeli yapılar ve depolama işaretçileri 
gibi external kütüphane fonksiyonlarından daha fazla bağımsız değişken türünü destekler. 
Bu nedenle, 4 baytlık seçiciyi hesaplamak için kullanılan fonksiyon imzaları, 
bir internal adlandırma şemasının ardından hesaplanır ve 
ABI akıllı sözleşmesinde desteklenmeyen türdeki bağımsız değişkenler bir dahili kodlama kullanır.

İmzalardaki türler için aşağıdaki tanımlayıcılar kullanılır:

- Değer tipleri, storage olmayan ``string`` ve storage olmayan ``bytes`` tipleri akıllı sözleşme ABI'sinde aynı tanımlayıcıları kullanır.
- Storage olmayan array tipleri de akıllı sözleşme ABI'sindeki genel görüşü kabul eder, yani dinamik arrayler için ``<type>[]`` ve fixed-size arrayler için ``<type>[M]`` kullanılır.
- Storage olmayan structlar tam isimleri ile referans edilir, yani ``contract C { struct S { ... } }`` için ``C.S``.
- Storage pointer mappingleri de ``mapping(<keyType> => <valueType>) storage`` kullanır. Burada ``<keyType>`` ve ``<valueType>`` sırasıyla mappingdeki anahtar ve değer tipleridir.
- Diğer storage pointer tipleri de kendi storage olmayan tiplerinin tanımlayıcılarını kullanırlar, ama bir boşluk ile ``storage`` eklenmiş halleri ile.

Argüman encode'lama da sıradan akıllı sözleşme ABI'si gibidir, storage pointerları hariç, 
işaret ettikleri storage slotuna atıfta bulunan bir ``uint256`` değeri olarak kodlanmıştır.

Akıllı sözleşme ABI'sine benzer bir şekilde, selector, imzanın Keccak256-hashinin ilk dört baytından oluşur. 
Değeri, ``.selector`` üyesi kullanılarak Solidity'den şu şekilde elde edilebilir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.14 <0.9.0;

    library L {
        function f(uint256) external {}
    }

    contract C {
        function g() public pure returns (bytes4) {
            return L.f.selector;
        }
    }



.. _call-protection:

Kütüphaneler İçin Çağrı Koruması
=================================

Girişte belirtildiği gibi, bir kütüphanenin kodu ``DELEGATECALL`` veya ``CALLCODE`` 
yerine bir ``CALL`` kullanılarak yürütülürse, bir ``view`` veya ``pure`` fonksiyon
çağrılmadığı sürece geri dönecektir.

EVM, bir akıllı sözleşmenin ``CALL`` kullanılarak çağrılıp çağrılmadığını tespit etmek 
için doğrudan bir yol sağlamaz, ancak bir sözleşme, “nerede” çalıştığını bulmak 
için ``ADDRESS`` işlem kodunu kullanabilir. Oluşturulan kod, arama modunu 
belirlemek için bu adresi yapım sırasında kullanılan adresle karşılaştırır.

Daha spesifik olarak, bir kütüphanenin çalışma zamanı kodu her zaman derleme 
zamanında 20 bayt sıfır olan bir push komutuyla başlar. Dağıtım kodu çalıştığında, 
bu sabit bellekte geçerli adresle değiştirilir ve bu değiştirilmiş kod sözleşmede 
saklanır. Çalışma zamanında, bu, dağıtım zamanı adresinin yığına gönderilecek 
ilk sabit olmasına neden olur ve dağıtıcı kodu, herhangi bir görünüm olmayan ve 
saf olmayan işlev için geçerli adresi bu sabitle karşılaştırır.

Bu, bir kitaplık için zincirde depolanan gerçek kodun
derleyici tarafından bildirilen koddan farklıdır.
``deployedBytecode``.
