.. index:: ! contract;abstract, ! abstract contract

.. _abstract-contract:

****************************
Abstract Akıllı Sözleşmeler
****************************

Sözleşmeler, işlevlerinden en az biri uygulanmadığında veya bütün temel sözleme yapıcılar için argüman sağlamadığında abstract olarak işaretlenmelidir.
Bu durumlardan herhangi biri geçerli değilse bile bir akıllı sözleşme abstract olarak işaretlenebilir.
Örneğin bir akıllı sözleşmenin direkt olarak oluşturulmasını istemediğiniz durumlarda bunu gerçekleştirebilirsiniz.
Abstract akıllı sözleşmeler :ref:`interfaces` oldukça benzerdir ancak interface'ler çok daha kısıtlı bir
yapıdadır.

Aşağıdaki örnekte belirtildiği gibi, Abstract akıllı sözleşmeler ``abstract`` olarak işaretlenerek belirtilir.
Aşağıdaki akıllı sözleşmenin abstract olarak tanımlanması gerektiğine dikkat edin. Çünkü ``utterance()``
fonksiyonu tanımlanıp kodları yazılmamıştır (``{ }`` arasında kod bulunmamakta).

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public virtual returns (bytes32);
    }

Bu tip abstract akıllı sözleşmeler direkt olarak örneklendirilemez. Bu, abstract sözleşmenin 
kendisi tanımlanmış tüm işlevleri yerine getiriyorsa da geçerlidir. Abstract bir akıllı sözleşmenin 
temel sınıf olarak kullanımı aşağıda gösterilmiştir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.6.0 <0.9.0;

    abstract contract Feline {
        function utterance() public pure virtual returns (bytes32);
    }

    contract Cat is Feline {
        function utterance() public pure override returns (bytes32) { return "miaow"; }
    }

Bir akıllı sözleşme bir abstract akıllı sözleşmeden türetiliyorsa ve abstract akıllı sözleşmedeki bütün kodu yazılmamış
fonksiyonların kodunu yazmıyorsa, o akıllı sözleşme da abstract olarak belirtilmelidir.

Kodu olmayan bir fonksiyonun :ref:`Fonksiyon Tipinden <function_types>` farklı olduğuna dikkat edin,
her ne kadar yazılışları oldukça benzer olsa da.

Kodu olmayan bir fonksiyona örnek olarak (fonksiyon tanımlaması):

.. code-block:: solidity

    function foo(address) external returns (address);

Türü bir fonksiyon türü olan bir değişken bildirimi örneği:

.. code-block:: solidity

    function(address) external returns (address) foo;

Abstract akıllı sözleşmeler, daha iyi genişletilebilirlik ve kendi kendine belgeleme sağlayarak 
ve `Template yöntemi <https://en.wikipedia.org/wiki/Template_method_pattern>`_ gibi kalıpları 
kolaylaştırarak ve kod tekrarını ortadan kaldırarak bir akıllı sözleşmenin tanımını uygulamasından ayırır.
Abstract akıllı sözleşmeler, bir arabirimdeki yöntemleri tanımlamanın yararlı olduğu şekilde yararlıdır. Abstract
akıllı sözleşmenin tasarımcısının “her çocuğum bu yöntemi uygulamalı” demesinin bir yoludur.

.. note::
  Abstract akıllı sözleşmeler kodu yazılmış bir virtual fonksiyonu kodu yazılmamış bir
  fonksiyon ile override edemezler.
