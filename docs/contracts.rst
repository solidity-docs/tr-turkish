.. index:: ! contract

.. _contracts:

##########
Akıllı Sözleşmeler
##########

Solidity'deki akıllı sözleşmeler nesne yönelimli programlama dillerine benzerdir. State
değişkenlerinde kalıcı data içerirler ve fonksiyonlar bu değişkenlerin değerini
değiştirebilir. Başka bir akıllı sözleşmedeki fonksiyonu çağırmak bir EVM fonksiyon çağrısı
gerçekleştirir ve burada çağıran akıllı sözleşmenin state değişkenlerine erişilemez. Akıllı sözleşmede
herhangi bir şeyin yaşanmasını istiyorsanız o akıllı sözleşmenin herhangi bir fonksiyonunu 
çağırmanız gerekir. Çünkü Ethereum'da "cron" konsepti yoktur, yani akıllı sözleşmeler kendi
başlarına bir şeyler yapamaz. Dışarıdan tetiklenmeleri gerekir.

.. include:: contracts/creating-contracts.rst

.. include:: contracts/visibility-and-getters.rst

.. include:: contracts/function-modifiers.rst

.. include:: contracts/constant-state-variables.rst
.. include:: contracts/functions.rst

.. include:: contracts/events.rst
.. include:: contracts/errors.rst

.. include:: contracts/inheritance.rst

.. include:: contracts/abstract-contracts.rst
.. include:: contracts/interfaces.rst

.. include:: contracts/libraries.rst

.. include:: contracts/using-for.rst