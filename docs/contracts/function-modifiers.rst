.. index:: ! function;modifier

.. _modifiers:

******************
Fonksiyon Modifier'ları
******************

Modifier'lar fonksiyonların tanımlandığı şekillerinden farklı davranmalarını sağlamak için kullanılabilir.
Örneğin,
bir fonksiyonun çalıştırılmasından hemen önce bir koşulun kontrolünü gerçekleştirebilirsiniz.

Modifier'lar akıllı sözleşmelerin türetilebilen özelliklerindendir. Bu yüzden türetilmiş bir akıllı sözleşme
bir modifier'ı eğer ``virtual`` olarak belirtilmişse onu override edebilir. Daha fazla bilgi için
:ref:`Modifier Overriding <modifier-overriding>` kısmına bakabilirsiniz.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.1 <0.9.0;

    contract owned {
        constructor() { owner = payable(msg.sender); }
        address payable owner;

        // Bu akıllı sözleşme sadece bir tane modifier tanımlar ve onu da kullanmıyor.
        // Tanımlanan modifier türetilen fonksiyonda kullanılacaktır.
        // Fonksiyon içerisindeki kodların kullanılacağı yer
        // `_;` şeklinde modifier içerisinde belirtilir.
        // Yani `_;` gördüğünüz yerde o modifier'ın kullanıldığı fonksiyonun
        // içerisindeki kodlar yazılmış gibi düşünebilirsiniz.
        // Bu modifier eklendiği fonksiyonu sadece akıllı sözleşmeyi oluşturan
        // kişinin çağırmasını sağlar. Diğer erişimlerde ise işlemi revert eder.
        modifier onlyOwner {
            require(
                msg.sender == owner,
                "Only owner can call this function."
            );
            _;
        }
    }

    contract destructible is owned {
        // Bu akıllı sözleşme türetildiği `owned` fonksiyonundaki
        // `onlyOwner` modifier'ını `destroy` fonksiyonuna ekler.
        // Böylece `destroy` fonksiyonunu sadece `owner` çağırabilir.
        function destroy() public onlyOwner {
            selfdestruct(owner);
        }
    }

    contract priced {
        // Modifier'lar parametre alabilir:
        modifier costs(uint price) {
            if (msg.value >= price) {
                _;
            }
        }
    }

    contract Register is priced, destructible {
        mapping (address => bool) registeredAddresses;
        uint price;

        constructor(uint initialPrice) { price = initialPrice; }

        // Buradaki `payable` sözcüğü de oldukça önemlidir.
        // Eğer bu fonksiyon `payable` olmazsa kendisine gelen bütün
        // etherleri reddeder.
        function register() public payable costs(price) {
            registeredAddresses[msg.sender] = true;
        }

        function changePrice(uint price_) public onlyOwner {
            price = price_;
        }
    }

    contract Mutex {
        bool locked;
        modifier noReentrancy() {
            require(
                !locked,
                "Reentrant call."
            );
            locked = true;
            _;
            locked = false;
        }

        /// Bu fonksiyon bir mutex ile korunmaktadır. 
        /// Yani, bu akıllı sözleşme re-entrancy çağrılarına karşı zaafiyetli değildir. 
        /// `return 7` fonksiyonun bittiğini belirtse de henüz modifier'ımızın işi bitmedi.
        /// `locked = false;` satırı return ifademizden sonra çalışır.
        function f() public noReentrancy returns (uint) {
            (bool success,) = msg.sender.call("");
            require(success);
            return 7;
        }
    }

Eğer ``C`` akıllı sözleşmesindeki ``m`` modifier'ına erişmek istiyorsanız, ``C.m`` şeklinde erişebilirsiniz.
Modifier'lar sadece tanımlandıkları akıllı sözleşmede veya türetilen bir akıllı sözleşmede kullanılabilir.
Modifier'lar kütüphanelerde de tanımlanabilir. Ancak kullanımları o kütüphanenin fonksiyonlarıyla kısıtlıdır.
Yani tanımlandıkları kütüphane dışında kullanılamazlar.

Bir fonksiyona birden fazla modifier tanımlanabilir. Bunu gerçekleştirmek için her bir modifier isminden sonra
bir boşluk bırakılmalıdır. Modifier'lar tanımlandıkları sıraya göre çalışacaktır.

Modifier'lar eklendikleri fonksiyonların parametrelerine veya return değerlerine kendi başlarına erişemezler.
Eğer bir parametreyi bir modifier'da kullanmak istiyorsanız, o modifier'ı eklediğiniz yerde
parametreyi de vermelisiniz. Fonksiyon çağırma yapısına benzer bir şekilde kullanılırlar.

Modifier'daki veya fonksiyon'daki return işlemi sadece o yazıldığı modifier'dan veya fonksiyon'dan
çıkmaya yarar. Program akışı ``_`` işaretinin olduğu yerden çalışmaya devam eder.

.. warning::
    Daha önceki Solidity versiyonlarında modifier'a sahip fonksiyonlarda ``return`` ifadesi farklı
    bir şekilde davranış sergiler.

Açık bir şekilde ``return;`` ifadesinin yer aldığı bir modifier, fonksiyonun return edeceği değerle alakalı değildir.
Modifier'lar fonksiyon içerisindeki kodları hiç çalıştırmamayı da tercih edebilirler.
Bu durumda return değerleri :ref:`default değerlerine<default-value>` eşitlenebilir. Böylelikle,
fonksiyonun hiç bir kodu yokmuş gibi bir davranış sergilenir.

``_`` sembolü bir modifier'da birden fazla kez kullanılabilir. Her bir kullanım, fonksiyon
içerisindeki kodla değiştirilecektir. Yani, ``_`` gördüğünüz her yerde, eklenen fonksiyonun kodlarının
bulunduğunu düşünebilirsiniz.

Modifier'lar parametre alabildiği için, bir fonksiyondaki bütün parametreler istenilen modifier'a gönderilebilir. 
Modifier'da tanımlanan semboller, fonksiyonlarda görülemez (override ile değiştirilebilir).