.. _natspec:

##############
NatSpec Formatı
##############

Solidity sözleşmeleri, fonksiyonlar, dönüş değişkenleri ve daha fazlası için zengin
dokümantasyon sağlamak üzere özel bir yorum biçimi kullanabilir. Bu özel form Ethereum
Doğal Dil Belirtim Formatı( Ethereum Natural Language Specification Format) (NatSpec) olarak adlandırılır.

.. note::

  NatSpec, `Doxygen <https://en.wikipedia.org/wiki/Doxygen>`_'den esinlenmiştir.
  Doxygen tarzı yorumlar ve etiketler kullansa da, Doxygen ile olan sıkı uyumluluğunu
  sürdürme niyeti yoktur. Lütfen aşağıda listelenen desteklenmiş etiketleri dikkatlice inceleyin.

  Bu dokümantasyon, geliştirici odaklı mesajlar ve son kullanıcıya yönelik mesajlar olarak
  bölümlere ayrılmıştır. Bu mesajlar son kullanıcıya (insan) sözleşme ile etkileşime gireceği
  (örneğin bir işlem imzalayacağı) zaman gösterilebilir.

  Solidity sözleşmelerinin tüm genel arayüzler (ABI'deki her şey) için NatSpec kullanılarak
  tamamen açıklanması önerilir.

  NatSpec, akıllı sözleşme yazarının kullanacağı ve Solidity derleyicisi tarafından anlaşılan
  yorumlar için biçimlendirme içerir. Ayrıca bu yorumları makine tarafından okunabilir bir
  biçime dönüştüren Solidity derleyicisinin çıktısı da aşağıda detaylı olarak açıklanmıştır.

  NatSpec, üçüncü taraf araçlar tarafından kullanılan ek açıklamaları da içerebilir. Bunlar
  büyük olasılıkla ``@custom:<name>` etiketi aracılığıyla gerçekleştirilir ve iyi bir kullanım
  örneği analiz ve doğrulama araçlarıdır.

.. _header-doc-example:

Dokümantasyon Örneği
=====================

Dokümantasyon, Doxygen notasyon formatı kullanılarak her ``contract``, ``interface``,
``library``, ``function`` ve ``event`` üzerine eklenir. Bir ``public`` durum değişkeni,
NatSpec'in kullanım amaçları doğrultusunda bir ``fonksiyon``a eşdeğerdir.

-  Solidity için tek veya çok satırlı yorumlar için ``//`` veya ``/**`` ve ``*/``
   ile sonlandırmayı tercih edebilirsiniz.

-  Vyper için, iç içeriğe yalın yorumlarla girintili ``"""`` kullanın. Vyper
   belgelerine <https://vyper.readthedocs.io/en/latest/natspec.html>`__ bakınız.

Aşağıdaki örnekte, mevcut tüm etiketler kullanılarak bir sözleşme ve bir fonksiyon gösterilmektedir.

.. note::

  Solidity derleyicisi, etiketleri yalnızca external veya public olmaları durumunda
  yorumlamaktadır. Internal ve private fonksiyonlarınız için benzer yorumlar
  kullanabilirsiniz, ancak bunlar çözümlenmeyecektir.

  Bu özellik belki gelecekte değişebilir.

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.8.2 < 0.9.0;

    /// @title Ağaçlar için bir simülatör
    /// @author Larry A. Gardner
    /// @notice Bu sözleşmeyi yalnızca en sade simulasyonlar için kullanabilirsiniz
    /// @dev Tüm fonksiyon çağrıları şu anda yan etkiler olmadan uygulanmaktadır
    /// @custom:experimental Bu deneysel bir sözleşmedir.
    contract Tree {
        /// @notice Canlı ağaçlar için ağaç yaşını yıl olarak hesaplayın, üst sayıya yuvarlayın
        /// @dev Alexandr N. Tetearing algoritması doğruluğu artırabilir
        /// @param rings Dendrokronolojik örnekten elde edilen halka sayısı
        /// @return Yıl cinsinden yaş, kısmi yıllar için yuvarlanır
        function age(uint256 rings) external virtual pure returns (uint256) {
            return rings + 1;
        }

        /// @notice Ağacın sahip olduğu yaprak miktarını döndürür.
        /// @dev Yalnızca sabit bir sayı döndürür.
        function leaves() external virtual pure returns(uint256) {
            return 2;
        }
    }

    contract Plant {
        function leaves() external virtual pure returns(uint256) {
            return 3;
        }
    }

    contract KumquatTree is Tree, Plant {
        function age(uint256 rings) external override pure returns (uint256) {
            return rings + 2;
        }

        /// Bu spesifik ağaç türünün sahip olduğu yaprak miktarını döndürür
        /// @inheritdoc Tree
        function leaves() external override(Tree, Plant) pure returns(uint256) {
            return 3;
        }
    }

.. _header-tags:

Tags
====

Tüm etiketler opsiyoneldir. Aşağıdaki tabloda her bir NatSpec etiketinin amacı ve
nerede kullanılabileceği açıklanmaktadır. Özel bir durum olarak, hiçbir etiket
kullanılmazsa Solidity derleyicisi bir ``///`` veya ``/**`` yorumunu ``@notice``
ile etiketlenmiş gibi yorumlayacaktır.

=============== ====================================================================================== =============================
Etiket                                                                                                 Bağlam
=============== ====================================================================================== =============================
``@title``      Sözleşmeyi/arayüzü tanımlaması gereken bir başlık                                      contract, library, interface
``@author``     Yazarın adı                                                                            contract, library, interface
``@notice``     Son kullanıcıya bunun ne işe yaradığını açıklayın                                      contract, library, interface, function, public state variable, event
``@dev``        Bir geliştiriciye ekstra ayrıntıları açıklayın                                         contract, library, interface, function, state variable, event
``@param``      Tıpkı Doxygen'de olduğu gibi bir parametreyi belgeler                                  function, event
                (parametre adının ardından gelmelidir)
``@return``     Bir sözleşmenin fonksiyonunun dönüş değişkenlerini belgeler                            function, public state variable
``@inheritdoc`` Temel fonksiyondaki tüm eksik etiketleri kopyalar (ardından sözleşme adı gelmelidir)   function, public state variable
``@custom:...`` Özel etiket, semantiği uygulama tanımlıdır                                             everywhere
=============== ====================================================================================== =============================

Fonksiyonunuz ``(int quotient, int remainder)`` gibi birden fazla değer döndürüyorsa,
``@param`` ifadeleriyle aynı formatta birden fazla ``@return`` ifadesi kullanın.

Özel etiketler ``@custom:`` ile başlar ve ardından bir veya daha fazla küçük harf
veya kısa çizgi gelmelidir. Ancak kısa çizgi ile başlayamaz. Her yerde kullanılabilirler
ve geliştirici belgelerinin bir parçasıdırlar.

.. _header-dynamic:

Dinamik ifade biçimleri
-------------------

Solidity derleyicisi, NatSpec belgelerini Solidity kaynak kodunuzdan bu kılavuzda
açıklandığı gibi JSON çıktısına aktaracaktır. Bu JSON çıktısının kullanıcısı, örneğin
son kullanıcı istemci yazılımı, bunu son kullanıcıya doğrudan sunabilir veya bazı ön
işlemler uygulayabilir.

Örneğin, bazı istemci yazılımları render edecektir:

.. code:: Solidity

   /// @notice This function will multiply `a` by 7

son kullanıcıya:

.. code:: text

    This function will multiply 10 by 7

eğer bir fonksiyon çağrılıyorsa ve ``a`` girdisine 10 değeri atanmışsa.

Bu dinamik ifadelerin belirtilmesi Solidity dokümantasyonunun kapsamı dışındadır
ve bu konuda daha fazla bilgiyi `the radspec project <https://github.com/aragon/radspec>`__
adresinden edinebilirsiniz.

.. _header-inheritance:

Kalıtım Notları
-----------------

NatSpec içermeyen fonksiyonlar otomatik olarak temel fonksiyonlarının dokümantasyonunu
devralacaktır. Bununla ilgili istisnalar şunlardır:

* Parametre adları farklı olduğunda.
* Birden fazla temel fonksiyon olduğunda.
* Kalıtım için hangi sözleşmenin kullanılması gerektiğini belirten açık bir ``@inheritdoc`` etiketi olduğunda.

.. _header-output:

Dokümantasyon Çıktısı
====================

Derleyici tarafından çözümlendiğinde, yukarıdaki örnekteki gibi belgeler iki farklı
JSON dosyası üretecektir. Biri son kullanıcı tarafından bir fonksiyon çalıştırıldığında
bildirim olarak tüketilmek üzere, diğeri ise geliştirici tarafından kullanılmak üzere
tasarlanmıştır.

Yukarıdaki sözleşme ``ex1.sol`` olarak kaydedilirse,
belgeleri kullanarak oluşturabilirsiniz:

.. code::

   solc --userdoc --devdoc ex1.sol

Çıktı aşağıda verilmiştir.

.. note::
    Solidity 0.6.11 sürümünden itibaren NatSpec çıktısı ayrıca bir ``version`` ve
    bir ``kind`` alanı içerir. Şu anda ``version`` ``1`` olarak ayarlanmıştır ve
    ``kind`` ``user`` veya ``dev`` alanlarından biri olmalıdır. Gelecekte, eski
    sürümleri kullanımdan kaldırarak yeni sürümlerin tanıtılması mümkündür.

.. _header-user-doc:

Kullanıcı Dokümantasyonu
------------------

Yukarıdaki dokümantasyon çıktı olarak aşağıdaki kullanıcı dokümantasyonu JSON dosyasını üretecektir:

.. code::

    {
      "version" : 1,
      "kind" : "user",
      "methods" :
      {
        "age(uint256)" :
        {
          "notice" : "Calculate tree age in years, rounded up, for live trees"
        }
      },
      "notice" : "You can use this contract for only the most basic simulation"
    }

Metotları bulmak için anahtarın sadece fonksiyonun adı değil, :ref:`Contract ABI
<abi_function_selector>`da tanımlandığı gibi fonksiyonun kanonik imzası olduğunu
unutmayın.

.. _header-developer-doc:

Geliştirici Dokümantasyonu
-----------------------

Kullanıcı dokümantasyon dosyasının yanı sıra, bir geliştirici dokümantasyon JSON
dosyası da üretilmeli ve aşağıdaki gibi görünmelidir:

.. code::

    {
      "version" : 1,
      "kind" : "dev",
      "author" : "Larry A. Gardner",
      "details" : "All function calls are currently implemented without side effects",
      "custom:experimental" : "This is an experimental contract.",
      "methods" :
      {
        "age(uint256)" :
        {
          "details" : "The Alexandr N. Tetearing algorithm could increase precision",
          "params" :
          {
            "rings" : "The number of rings from dendrochronological sample"
          },
          "return" : "age in years, rounded up for partial years"
        }
      },
      "title" : "A simulator for trees"
    }
