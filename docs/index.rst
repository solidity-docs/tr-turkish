Solidity
========

.. warning::

  You are reading a community translation of the Solidity documentation. The Solidity team
  can give no guarantees on the quality and accuracy of the translations provided.
  The English reference version is and will remain the only officially supported version
  by the Solidity team and will always be the most accurate and most up-to-date one.
  When in doubt, please always refer to the `English (original) documentation <https://docs.soliditylang.org/en/latest/>`_.

Solidity akıllı sözleşmelerin (smart contracts) uygulanması için geliştirilen nesne yönelimli, üst düzey
bir programlama dilidir. Akıllı sözleşmeler Ethereum ağı içindeki hesapların hareketlerini
ve davranışlarını yöneten programlardır.

Solidity Ethereum Sanal Makinası (ESM) (Ethereum Virtual Machine) hedeflenerek dizayn edilmiş bir `curly-bracket dilidir
<https://en.wikipedia.org/wiki/List_of_programming_languages_by_type#Curly-bracket_languages>`_.
C++, Python ve JavaScript gibi dillerden ilham alınarak oluşturulmuştur. Solidity'nin başka
hangi dillerden ilham aldığı hakkındaki detaylı bilgiyi :doc:`ilham alınan diller
<language-influences>` bölümünde bulabilirsiniz.

Solidity statik olarak yazılmış olmasının yanı sıra, kütüphaneleri, kullanıcı tanımlı karmaşık
türleri ve kalıtımsallığı destekler.

Solidity'le kullanıcılar için oylama, crowdfunding, blind auctions ve çoklu-imza cüzdanları
gibi kullanımlara yönelik akıllı sözleşmeler oluşturabilirsiniz.

Sözleşmelerin gönderimini yaparken, en son yayınlanan Solidity sürümünü kullanmalısınız. İstisnai
durumlar dışında, yalnızca son sürüm `güvenlik düzeltmeleri
<https://github.com/ethereum/solidity/security/policy#supported-versions>`_ güncellemelerini alır.
Ayrıca, önemli değişikliklerinin yanı sıra yeni özellikler düzenli olarak tanıtılmaktadır.
Bu hızlı `değişimleri belirtmek için <https://semver.org/#spec-item-4>`_ bir 0.y.z sürüm numarası
kullanıyoruz.

.. hint::

  Solidity kısa bir süre önce birçok yenilik ve önemli değişiklikler getiren 0.8.x sürümünü yayınladı.
  Değişiklikleri mutlaka okuyun :doc:`tam liste <080-breaking-changes>`.

  Solidity'yi veya bu dokümantasyonu geliştirmek için fikirlere her zaman açığız,
  Daha fazla ayrıntı için :doc:`katkıda bulunanlar rehberi <contributing>` sayfamızı okuyun.

.. warning::

  Bu belgeyi, sol alt köşedeki sürümler menüsüne tıklayarak ve tercih edilen indirme biçimini
  seçerek PDF, HTML veya Epub olarak indirebilirsiniz.


Hadi Başlayalım
---------------

**1. Akıllı Sözleşmelerin Temellerini Anlama**

Eğer akıllı sözleşmeler kavramında yeniyseniz "Akıllı Sözleşmelere Giriş" bölümünü araştırarak
başlamanızı öneririz. Bu bölüm aşağıdakileri kapsar:

* Solidity ile yazılmış :ref:`Basit bir akıllı sözleşme örneği <simple-smart-contract>`.
* :ref:`Blockchain Temelleri <blockchain-basics>`.
* :ref:`Ethereum Sanal Makinası (Ethereum Virtual Machine) <the-ethereum-virtual-machine>`.

**2. Solidity ile Tanışın**

Temel bilgilere alıştıktan sonra, :doc:`"Örneklerle Solidity" <solidity-by-example>` bölümünü
okumanızı öneririz. Ve ayrıca "Dil Tanımları" bölümünü inceleyerek dilin temel kavramlarını
anlayabilirsiniz..

**3. Solidity Derleyicisini İndirme**

Solidity derleyicisini indirmenin birçok yolu vardır,
tercih edeceğiniz yola göre :ref:`indirme sayfası <installing-solidity>`
'da bulunan adımları izleyin.

.. hint::
   `Remix IDE <https://remix.ethereum.org>`_ ile birlikte kod örneklerini doğrudan tarayıcınızda
   deneyebilirsiniz. Remix, Solidity'yi yerel olarak yüklemenize gerek kalmadan Solidity akıllı sözleşmelerini yazmanıza,
   dağıtmanıza ve yönetmenize olanak tanıyan web tarayıcısı tabanlı bir IDE'dir.

.. warning::
    İnsanlar kodlama yaparken, hataları olabilir. Akıllı sözleşmelerinizi yazarken
    belirlenmiş en iyi yazılım geliştirme uygulamalarını izlemelisiniz. Buna kod incelemesi,
    kodunuzu test etme, denetimler ve correctness proofs dahildir. Akıllı sözleşme kullanıcıları bazen
    kod konusunda yazarlarından daha emin olabilirler, blockchain ve akıllı sözleşmelerin
    dikkat edilmesi gereken kendine özgü sorunları vardır, bu nedenle üretim kodu(production code)
    üzerinde çalışmadan önce :ref:`security_considerations` bölümünü okuduğunuzdan emin olun.

**4. Daha Fazla Bilgi Edinin**

Ethereum ağı üzerinde merkeziyetsiz uygulamalar oluşturma hakkında daha fazla bilgi edinmek
istiyorsanız, `Ethereum Geliştirici Kaynakları <https://ethereum.org/en/developers/>`_ size Ethereum
ile ilgili daha fazla genel dokümantasyon, çok çeşitli öğreticiler,
araçlar ve framework'ler(Yazılım iskeleti) konusunda yardımcı olabilir.

Eğer herhangi bir sorunuz varsa, `Ethereum StackExchange <https://ethereum.stackexchange.com/>`_,
veya `Gitter kanalımıza <https://gitter.im/ethereum/solidity/>`_ sorabilirsiniz.

.. _translations:

Çeviriler
------------

Topluluk'tan bazı gönüllüler bu belgeyi farklı dillere çevirmemize yardımcı oluyor.
Bu sebeple çevirilerin farklı derecelerde bütünlük ve güncelliğe sahip olduğunu unutmayın.
İngilizce versiyonunu referans olarak alın.

Sol alt köşedeki açılır menüye tıklayarak ve tercih ettiğiniz dili seçerek diller
arasında geçiş yapabilirsiniz.

* `Fransızce <https://docs.soliditylang.org/fr/latest/>`_
* `Endonezya Dili <https://github.com/solidity-docs/id-indonesian>`_
* `Farsça <https://github.com/solidity-docs/fa-persian>`_
* `Japonca <https://github.com/solidity-docs/ja-japanese>`_
* `Korece <https://github.com/solidity-docs/ko-korean>`_
* `Çince <https://github.com/solidity-docs/zh-cn-chinese/>`_

.. note::

   Kısa süre önce topluluk çalışmalarını kolaylaştırmak ve düzene koymak için yeni bir
   GitHub organizasyonu ve çeviri için bir iş akışı(workflow) kurduk. Yeni bir dile nasıl
   başlayacağınız veya var olan çevirilere nasıl katkıda bulunacağınız hakkında bilgi için
   lütfen `çeviri kılavuzuna <https://github.com/solidity-docs/translation-guide>`_ bakın.

İçindekiler
============

:ref:`Anahtar Kelime Dizini <genindex>`, :ref:`Arama Sayfası <search>`

.. toctree::
   :maxdepth: 2
   :caption: Temeller

   introduction-to-smart-contracts.rst
   installing-solidity.rst
   solidity-by-example.rst

.. toctree::
   :maxdepth: 2
   :caption: Dil Açıklaması

   layout-of-source-files.rst
   structure-of-a-contract.rst
   types.rst
   units-and-global-variables.rst
   control-structures.rst
   contracts.rst
   assembly.rst
   cheatsheet.rst
   grammar.rst

.. toctree::
   :maxdepth: 2
   :caption: Derleyici

   using-the-compiler.rst
   analysing-compilation-output.rst
   ir-breaking-changes.rst

.. toctree::
   :maxdepth: 2
   :caption: Dahili

   internals/layout_in_storage.rst
   internals/layout_in_memory.rst
   internals/layout_in_calldata.rst
   internals/variable_cleanup.rst
   internals/source_mappings.rst
   internals/optimizer.rst
   metadata.rst
   abi-spec.rst

.. toctree::
   :maxdepth: 2
   :caption: Ek Materyaller

   050-breaking-changes.rst
   060-breaking-changes.rst
   070-breaking-changes.rst
   080-breaking-changes.rst
   natspec-format.rst
   security-considerations.rst
   smtchecker.rst
   resources.rst
   path-resolution.rst
   yul.rst
   style-guide.rst
   common-patterns.rst
   bugs.rst
   contributing.rst
   brand-guide.rst
   language-influences.rst
