.. index:: ! contract;abstract, ! abstract contract

.. _abstract-contract:

******************
Abstract Contract'lar
******************

Contractlar en azından bir fonksiyonlarının kodu yazılmadığında veya temel contractlarının
constructor'larına argüman sağlamadıklarında abstract olarak tanımlanmalıdır.
Bu durumlardan herhangi birisi geçerli değilse bile bir contract abstract olarak işaretlenebilir.
Örneğin bir contractın direkt olarak oluşturulmasını istemediğiniz durumlarda bunu gerçekleştirebilirsiniz.
Abstract contractlar :ref:`interface'lere` oldukça benzerdir ancak interface'ler çok daha kısıtlı bir
yapıdadır.

Abstract contractlar ``abstract`` olarak işaretlenerek belirtilir, aşağıdaki örnekteki gibi.
Aşağıdaki contractın abstract olarak tanımlanması gerektiğine dikkat edin. Çünkü ``utterance()``
fonksiyonu tanımlanıp kodları yazılmamıştır (``{ }`` arasında kod bulunmamakta).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public virtual returns (bytes32);
    }

Bu tip abstract contractlar direkt olarak örneklendirilemez. Bu ayrıca bütün fonksiyonlarını tanımlayan bir
abstract contract için de geçerlidir. Abstract bir contractın temel sınıf olarak kullanımı aşağıda gösterilmiştir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public pure virtual returns (bytes32);
    }

    contract Cat is Feline {
        function utterance() public pure override returns (bytes32) { return "miaow"; }
    }

Bir contract bir abstract contracttan türetiliyorsa ve abstract contracttaki bütün kodu yazılmamış
fonksiyonların kodunu yazmıyorsa, o contract da abstract olarak belirtilmelidir.

Kodu olmayan bir fonksiyonun :ref:`Fonksiyon Tipinden <function_types>` farklı olduğuna dikkat edin,
her ne kadar yazılışları oldukça benzer olsa da.

Kodu olmayan bir fonksiyona örnek olarak (fonksiyon tanımlaması):

.. code-block:: solidity

    function foo(address) external returns (address);

Türü bir fonksiyon türü olan bir değişken bildirimi örneği:

.. code-block:: solidity

    function(address) external returns (address) foo;

Abstract contractlar, daha iyi genişletilebilirlik ve kendi kendine belgeleme sağlayarak 
ve `Template yöntemi <https://en.wikipedia.org/wiki/Template_method_pattern>`_ gibi kalıpları 
kolaylaştırarak ve kod tekrarını ortadan kaldırarak bir contractın tanımını uygulamasından ayırır.
Abstract contractlar, bir arabirimdeki yöntemleri tanımlamanın yararlı olduğu şekilde yararlıdır. Abstract
contractın tasarımcısının “her çocuğum bu yöntemi uygulamalı” demesinin bir yoludur.

.. note::
  Abstract contractlar kodu yazılmış bir virtual fonksiyonu kodu yazılmamış bir
  fonksiyon ile override edemezler.
