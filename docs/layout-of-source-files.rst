**********************************
Solidity Kaynak Dosyasının Düzeni
**********************************

Kaynak dosyalar, istenilen sayıda :ref:`contract definitions<contract_structure>`, import_ ,:ref:`pragma<pragma>` ve :ref:`using for<using-for>` yönergeleri ile :ref:`struct<structs>`,:ref:`enum<enums>`, :ref:`function<functions>`, :ref:`error<errors>` ve :ref:`constant variable<constants>` tanımları içerebilir.

.. index:: ! license, spdx

SPDX Lisans Tanımlayıcısı
==========================

Kaynak kodlarının erişilebilir olması, akıllı sözleşmeleri daha güvenilir
hale getirebilir. Kaynak kodunun erişilebilir hale getirilmesi her zaman telif hakkı ile ilgili yasal sorunlara yol açtığından, Solidity derleyicisi, makine tarafından okunabilen `SPDX lisans tanımlayıcılarının <https://spdx.org>`_ kullanılmasını teşvik eder:

``// SPDX-License-Identifier: MIT``

Derleyici, lisansın,
`SPDX'in izin verdiği liste <https://spdx.org/licenses/>`_ kapsamında olduğunu doğrulamaz ancak
sağlanan dizeyi :ref:`bytecode metadata <metadata>` içine dahil eder.

Bir lisans belirtmek istemiyorsanız veya kaynak kodu
açık kaynak değilse, lütfen ``UNLICENSED`` özel değerini kullanın.
``UNLICENSED`` (kullanıma izin verilmez, SPDX lisans listesinde bulunmaz) değerinin, ``UNLICENSE`` (herkese tüm hakları verir) değerinden farklı olduğunu unutmayın.
Solidity, ` npm önerisine <https://docs.npmjs.com/cli/v7/configuring-npm/package-json#license>`_  uyar.

Bu açıklamayı eklemeniz, elbette ki sizi, her kaynak dosyada belirli bir lisans adından veya
telif hakkının orijinal sahibinden bahsetme zorunluluğu gibi, lisans konusuyla ilgili diğer yükümlülüklerden muaf tutmaz.
Derleyici, açıklamayı, dosya düzeyinde dosyanın herhangi bir yerinde algılayabilir
ancak dosyanın üst kısmına eklenmesi önerilir.

SPDX lisans tanımlayıcılarının nasıl kullanılacağı hakkında daha fazla bilgi `SPDX web sitesinde <https://spdx.org/ids-how>`_ bulunabilir.

.. index:: ! pragma

.. _pragma:

Pragmalar
==========
``Pragma`` anahtar sözcüğü, belirli derleyici özelliklerini veya kontrollerini etkinleştirmek için
kullanılır. Bir pragma yönergesi, her zaman bir kaynak dosya için yereldir, bu nedenle pragmayı tüm projenizde etkinleştirmek istiyorsanız tüm dosyalarınıza eklemeniz gerekir. Başka bir dosyayı :ref:`içe aktarırsanız<import>` o dosyadaki pragma, içe aktarılan dosyaya otomatik olarak _*uygulanmaz*._
.. index:: ! pragma, version

.. _version_pragma:

Sürüm Pragması
---------------

Uyumsuz değişiklikler getirebilecek gelecekteki derleyici sürümleriyle derlemeyi önlemek için kaynak dosyalarına bir sürüm pragması eklenebilir (ve eklenmelidir). Bunları mutlak minimumda tutmaya ve anlambilimdeki değişikliklerin sözdiziminde de değişiklik gerektireceği şekilde tanıtmaya çalışıyoruz, ancak bu her zaman mümkün olmayabilir. Bu nedenle, en azından işleyişi bozan değişiklikler içeren sürümler için değişiklik günlüğünü okumak her zaman iyi bir fikirdir. Bu sürümler her zaman ``0.x.0`` veya ``x.0.0`` biçiminde versiyonlara sahiptir.

Sürüm pragması aşağıdaki gibi kullanılır: ``pragma solidity ^0.5.2;``

Yukarıdaki satırı içeren bir kaynak dosyası, 0.5.2'den eski sürümlü bir derleyiciyle derleme yapmadığı gibi, 0.6.0'dan yeni sürümlü bir derleyicide de çalışmaz (bu ikinci koşul ``^`` kullanılarak eklenir). ``0.6.0`` sürümüne kadar işleyişi bozan bir değişiklik olmayacağından, kodunuzun amaçladığınız şekilde derleme yaptığından emin olabilirsiniz. Derleyicinin tam sürümü sabit olmadığından hata düzeltme sürümlerinin kullanılması da mümkün olacaktır.

Derleyici sürümü için daha karmaşık kurallar belirlemek mümkündür,
bunlar `npm<https://docs.npmjs.com/cli/v6/using-npm/semver>`_ tarafından kullanılan sözdizimin aynısına uyar.

.. note::
  Sürüm pragmasının kullanılması, derleyicinin sürümünü _*değiştirmez*._
  Derleyicinin özelliklerini etkinleştirme veya devre dışı bırakma işlevine de sahip _*değildir*._
  Yalnızca, derleyiciye kendi sürümünün, pragmanın gerektirdiği sürüm ile uyumlu olup olmadığını kontrol
  etmesi için yönerge verir. Sürümler uyumlu değilse derleyici hata verir.

ABI Kodlayıcı Pragması
-----------------------

``pragma abicoder v1`` veya ``pragma abicoder v2`` kullanarak ABI kodlayıcı ile
kod çözücü iki uygulama arasında seçim yapabilirsiniz.

Yeni ABI kodlayıcı (v2) keyfi olarak iç içe geçmiş dizileri ve yapıları kodlama(encode) ve kod çözme(decode) yapabilir
. Daha az optimal kod üretebilir ve eski kodlayıcı kadar test edilmemiştir, ancak Solidity 0.6.0'dan itibaren deneysel olmayan olarak kabul edilir. Yine de ``pragma abicoder v2;`` kullanarak açıkça etkinleştirmeniz gerekir. Solidity 0.8.0'dan itibaren varsayılan olarak etkinleştirileceğinden, ``pragma abicoder v1;`` kullanarak eski kodlayıcıyı seçme seçeneği vardır.

Yeni kodlayıcı tarafından desteklenen türler, eskisi tarafından desteklenenlerin katı bir üst kümesidir. Bunu kullanan sözleşmeler, kullanmayanlarla sınırlama olmadan etkileşime girebilir. Bunun tersi ancak, ``abicoder v2`` dışı sözleşme, yalnızca yeni kodlayıcı tarafından desteklenen kod çözme türlerini gerektirecek çağrılarda bulunmaya çalışmadığı sürece mümkündür. Aksi halde, derleyici bu çağrıları tespit ederek hata verebilir. Sözleşmeniz için ``abicoder v2`` yi etkinleştirmeniz hatanın ortadan kalkması için yeterlidir.

.. note::
  Bu pragma, en nihayetinde kodun nerede sonlandığına bakılmaksızın, etkinleştirildiği dosyada tanımlanan tüm kodlar için geçerlidir. Yani, kaynak dosyası ABI coder v1 ile derlenmek üzere seçilen bir sözleşme, başka bir
  sözleşmeden kalıt alarak, yeni kodlayıcıyı kullanan kod içermeye devam edebilir. Bu, yeni türlerin, external fonksiyon imzalarında değil, yalnızca dahili olarak kullanılması halinde mümkündür.

.. note::
  Solidity 0.7.4'e kadar, ``pragma experimental ABIEncoderV2`` kullanarak ABI kodlayıcı v2'yi seçmek mümkündü, ancak varsayılan olduğu için kodlayıcı v1'i açık bir şekilde seçmek mümkün değildi.

.. index:: ! pragma, deneysel

.. _experimental_pragma:

Deneysel Pragma
-------------------

İkinci pragma deneysel pragmadır. Derleyicinin veya dilin henüz varsayılan olarak etkinleştirilmemiş özelliklerini etkinleştirmek için kullanılabilir. Şu anda, aşağıdaki deneysel pragmalar desteklenmektedir:


ABIEncoderV2
~~~~~~~~~~~~

ABI kodlayıcı v2 artık deneysel kabul edilmediğinden
Solidity 0.7.4 sonrasında ``pragma abicoder v2`` aracılığıyla seçilebilir (lütfen yukarıya bakın).

.. _smt_checker:

SMTChecker
~~~~~~~~~~

Bu bileşeni, Solidity derleyicisi oluşturulduğunda etkinleştirmek gerektiği için
tüm Solidity binary'lerinde mevcut değildir. :ref:`build yönergeleri<smt_solvers_build>` bu seçeneğin nasıl etkinleştirileceğini açıklar. Çoğu sürümde Ubuntu PPA sürümleri için etkinleştirilmiş olsa da
Docker görüntüleri, Windows binary'leri veya statik olarak oluşturulmuş Linux binary'leri için etkin değildir. Yerel olarak yüklenmiş bir SMT çözücünüz varsa ve solc-js'yi node üzerinden (tarayıcı üzerinden değil) çalıştırıyorsanız `smtCallback <https://github.com/ethereum/solc js#example-usage-with-smtsolver-callback>`_ kullanarak solc-js için etkinleştirebilirsiniz.

Eğer ``pragma experimental SMTChecker;`` kullanırsanız bir SMT çözücü sorgulatarak ek:ref:`güvenlik uyarıları<formal_verification>` alırsınız.
Bileşen henüz Solidity dilinin tüm özelliklerini desteklememekte ve muhtemelen çok sayıda uyarı vermektedir. Desteklenmeyen özellikleri bildirmesi durumunda, analiz tamamen sağlıklı olmayabilir.


.. index:: kaynak dosya, ! içe aktarma, modül, kaynak birim
.. _import:

Diğer Kaynak Dosyalarını İçe Aktarma
=====================================

Sözdizimi ve Anlambilim
------------------------

Solidity, kodunuzu modüler hale getirmenize yardımcı olmak için Javascript'te mevcut olanlara (ES6'dan sonrası)
benzer import ifadelerini destekler. Ancak, Solidity `varsayılan export <https://developer.mozilla.org/en-US/docs/web/javascript/reference/statements/export#Description>`_ kavramını desteklemez.

Genel düzeyde, aşağıdaki formdaki içe aktarma deyimlerini kullanabilirsiniz:

.. code-block:: solidity

    import "filename";

``filename`` kısmı *import path* olarak adlandırılır.
Bu deyim, "filename "deki tüm global sembolleri (ve orada içe aktarılan sembolleri) geçerli global kapsama içe aktarır (ES6'dakinden farklıdır, ancak Solidity için geriye dönük olarak uyumludur).
Bu formun kullanılması tavsiye edilmez, çünkü isim alanını tahmin edilemeyecek şekilde kirletir.
"filename" içine yeni üst düzey öğeler eklerseniz, bunlar otomatik olarak "filename "den bu şekilde içe aktarılan tüm dosyalarda görünür. Belirli sembolleri açık bir şekilde içe aktarmak
daha iyidir.

Aşağıdaki örnek, üyeleri ``"filename"`` içindeki tüm global semboller olan yeni bir global sembol ``symbolName`` oluşturur:

.. code-block:: solidity

    import * as symbolName from "filename";

bu da tüm global sembollerin ``symbolName.symbol`` biçiminde kullanılabilir olmasıyla sonuçlanır.

Bu sözdiziminin ES6'nın bir parçası olmayan, ancak muhtemelen yararlı olan bir çeşidi:
.. code-block:: solidity

  import "filename" as symbolName;

bu da ``import * as symbolName from "filename";`` ile eşdeğerdir.

Bir adlandırma çakışması varsa içe aktarma sırasında sembolleri yeniden adlandırabilirsiniz. Örneğin, aşağıdaki kod sırasıyla ``"filename"`` içinden ``symbol1`` ve ``symbol2`` yi referans veren yeni global semboller ``alias`` ve ``symbol2`` oluşturur.
.. code-block:: solidity

    import {symbol1 as alias, symbol2} from "filename";

.. index:: virtual filesystem, source unit name, import; path, filesystem path, import callback, Remix IDE

İçe Aktarma Yolları
--------------------

Tüm platformlarda tekrarlanabilir derlemeleri destekleyebilmek için Solidity derleyicisinin kaynak dosyalarının depolandığı dosya sisteminin ayrıntılarını soyutlaması gerekir.
Bu nedenle içe aktarma yolları doğrudan ana dosya sistemindeki dosyalara başvurmaz.
Bunun yerine derleyici, her kaynak birime opak ve yapılandırılmamış bir tanımlayıcı olan benzersiz bir *kaynak birim adı* atanan dahili bir veritabanı (*sanal dosya sistemi* veya kısaca *VFS*) tutar. İçe aktarma ifadesinde belirtilen içe aktarma yolu, bir kaynak birim adına çevrilir
ve veritabanında ilgili kaynak birimini bulmak için kullanılır.

:ref:`Standart JSON <compiler-api>` API'sini kullanarak, derleyici girdisinin bir parçası olarak tüm kaynak dosyaların adlarını ve içeriğini doğrudan sağlamak mümkündür. Bu durumda kaynak birim adları gerçekten keyfi olabilir. Ancak, derleyicinin kaynak kodu otomatik olarak bulmasını ve VFS'ye yüklemesini istiyorsanız, kaynak birim adlarınızın bir :ref:`import callback <import-callback>` i mümkün kılacak şekilde yapılandırılması gerekir.
Komut satırı derleyicisini kullanırken varsayılan import callback yalnızca kaynak kodun bir ana bilgisayar dosya sisteminden yüklenmesini destekler; yani kaynak birim adları, yollar olmalıdır.```
Bazı ortamlar daha çok yönlü olan özel callback'ler sağlar. Örneğin `Remix IDE <https://remix.ethereum.org/>`_, `HTTP, IPFS ve Swarm URL'lerinden dosya içe aktarmanıza veya doğrudan NPM kayıt defterindeki paketlere başvurmanıza<https://remix-ide.readthedocs.io/en/latest/import.html>`_ olanak tanıyan bir tane sağlar.
Derleyici tarafından kullanılan sanal dosya sistemi ve yol çözümleme mantığının tam bir açıklaması için
bkz :ref:`Path Resolution <path-resolution>`.

.. index:: ! comment, natspec

Yorumlar
=========

Tek satırlı yorumlar (``//``) ve çok satırlı yorumlar (``/*...*/``) mümkündür.

.. code-block:: solidity

    // This is a single-line comment.

    /*
    This is a
    multi-line comment.
    */

.. note::
  Tek satırlık bir yorum UTF-8 kodlamasında herhangi bir unicode satır sonlandırıcısı (LF, VF, FF, CR, NEL, LS veya PS) ile sonlandırılır. Sonlandırıcı, yorumdan sonra hala kaynak kodun bir parçasıdır, bu nedenle bir ASCII sembolü değilse (bunlar NEL, LS ve PS'dir), bir ayrıştırıcı hatasına yol açacaktır.
  Ayrıca, NatSpec yorumu adı verilen başka bir yorum türü daha vardır,
  :ref:`stil kılavuzu<style_guide_natspec>` içinde ayrıntılı olarak açıklanmıştır. Bunlar üçlü eğik çizgi (``///``) veya çift yıldız bloğu (``/** ... */``) ile yazılır ve doğrudan fonksiyon bildirimlerinin veya deyimlerinin üzerinde kullanılmalıdır.