.. index:: type

.. _types:

********
Türler
********

Solidity statik olarak yazılmış bir dildir, bu, her bir değişkenin türünün (durum ve yerel) belirtilmesi gerektiği anlamına gelir.
Solidity, karmaşık türler oluşturmak için bir araya getirilen birkaç temel tür sağlar. 

Ayrıca, operatör içeren ifadelerde türler birbirleriyle etkileşime girebilirler.
Çeşitli operatörlere göz atmak için, :ref:`order`.

Solidity'de "tanımsız" veya "boş" değerler kavramı yoktur, yeni bildirilen değişkenlerin türüne bağlı olarak her zaman :ref:`varsayılan bir değeri<default-value>` vardır.
Beklenmeyen değerler ile uğraşırken, tüm işlemi geri almak için bir :ref:`geri alma fonksiyonu<assert-and-require>` kullanmalı ya da sonucu işaret eden ikinci bir ``bool`` değerine sahip bir veri demeti döndürmelisiniz.

.. include:: types/value-types.rst

.. include:: types/reference-types.rst

.. include:: types/mapping-types.rst

.. include:: types/operators.rst

.. include:: types/conversion.rst
