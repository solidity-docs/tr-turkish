********************************
Solidity Kaynak Dosyasının Düzeni
********************************

Kaynak dosyalar keyfi sayıda:ref:`contract definitions<contract_structure>`, import_ ,:ref:`pragma<pragma>` ve :ref:`using for<using-for>` yönergeleri ve:ref:`struct<structs>`,:ref:`enum<enums>`, :ref:`function<functions>`, :ref:`error<errors>` ve :ref:`constant variable<constants>` tanımları içerebilir.

.. index:: ! license, spdx

SPDX Lisans Tanımlayıcısı
=======================

Akıllı sözleşmelere olan güven, kaynak kodlarının
kullanılabilir. Kaynak kodunu erişilebilir kılmak her zaman telif hakkı ile ilgili yasal sorunlara yol açtığından, Solidity derleyicisi makine tarafından okunabilen `SPDX lisans tanımlayıcılarının <https://spdx.org>`_ kullanılmasını teşvik eder:

``// SPDX-License-Identifier: MIT``

Derleyici, lisansın belgenin bir parçası olduğunu doğrulamaz.
SPDX <https://spdx.org/licenses/>`_ tarafından izin verilen liste, ancak
sağlanan dizeyi :ref:`bytecode metadata <metadata>` içine dahil eder.

Bir lisans belirtmek istemiyorsanız veya kaynak kodu
açık kaynak değilse, lütfen ``UNLICENSED`` özel değerini kullanın.
UNLICENSED`` (kullanıma izin verilmez, SPDX lisans listesinde bulunmaz) değerinin ``UNLICENSE`` (herkese tüm hakları verir) değerinden farklı olduğunu unutmayın.
Solidity, <https://docs.npmjs.com/cli/v7/configuring-npm/package-json#license>`_ npm önerisini takip eder.

Bu yorumu yapmak elbette sizi diğer yorumlardan muaf tutmaz.
Her kaynak dosyada belirli bir lisans başlığından veya orijinal telif hakkı sahibinden bahsetme zorunluluğu gibi lisanslama ile ilgili yükümlülükler.
The comment is recognized by the compiler anywhere in the file at the
file level, but it is recommended to put it at the top of the file.

SPDX lisans tanımlayıcılarının nasıl kullanılacağı hakkında daha fazla bilgi `SPDX web sitesi <https://spdx.org/ids-how>`_ adresinde bulunabilir.

.. index:: ! pragma

.. _pragma:

Pragmalar
=======
Pragma`` anahtar sözcüğü belirli derleyici özelliklerini etkinleştirmek için kullanılır
veya kontrol eder. Bir pragma yönergesi her zaman bir kaynak dosya için yereldir, bu nedenle tüm projenizde etkinleştirmek istiyorsanız pragmayı tüm dosyalarınıza eklemeniz gerekir. Eğer :ref:`import<import>` başka bir dosyayı içe aktarırsanız, bu dosyadaki pragma içe aktarılan dosyaya otomatik olarak uygulanmaz *değildir*.
.. index:: ! pragma, version

.. _version_pragma:

Sürüm Pragması
--------------

Uyumsuz değişiklikler getirebilecek gelecekteki derleyici sürümleriyle derlemeyi önlemek için kaynak dosyalarına bir sürüm pragması eklenebilir (ve eklenmelidir). Bunları mutlak minimumda tutmaya ve anlambilimdeki değişikliklerin sözdiziminde de değişiklik gerektireceği şekilde tanıtmaya çalışıyoruz, ancak bu her zaman mümkün değildir. Bu nedenle, en azından kırıcı değişiklikler içeren sürümler için değişiklik günlüğünü okumak her zaman iyi bir fikirdir. Bu sürümler her zaman ``0.x.0`` veya ``x.0.0`` biçiminde sürümlere sahiptir.

Sürüm pragması aşağıdaki gibi kullanılır: ``pragma solidity ^0.5.2;``

Yukarıdaki satıra sahip bir kaynak dosyası 0.5.2 sürümünden önceki bir derleyiciyle derlenmez ve 0.6.0 sürümünden başlayan bir derleyicide de çalışmaz (bu ikinci koşul ``^`` kullanılarak eklenir). 0.6.0`` sürümüne kadar herhangi bir kırılma değişikliği olmayacağından, kodunuzun amaçladığınız şekilde derlendiğinden emin olabilirsiniz. Derleyicinin tam sürümü sabit değildir, bu nedenle hata düzeltme sürümleri hala mümkündür.

Derleyici sürümü için daha karmaşık kurallar belirlemek mümkündür,
bunlar `npm<https://docs.npmjs.com/cli/v6/using-npm/semver>`_ tarafından kullanılan aynı sözdizimini takip eder.

.. note::
  Version pragmasının kullanılması *derleyicinin sürümünü değiştirmez*.
Ayrıca derleyicinin özelliklerini etkinleştirmez veya devre dışı bırakmaz. Sadece
derleyiciye kendi sürümünün aşağıdakiyle eşleşip eşleşmediğini kontrol etmesi talimatını verir
pragma tarafından gerekli kılınmıştır. Eşleşmezse, derleyici şu sorunları verir bir hata.

ABI Kodlayıcı Pragması
----------------

``pragma abicoder v1`` veya ``pragma abicoder v2`` kullanarak şunları yapabilirsiniz
ABI kodlayıcı ve kod çözücünün iki uygulaması arasında seçim yapın.

Yeni ABI kodlayıcı (v2) keyfi olarak iç içe geçmiş dizileri ve yapıları kodlama ve kod çözme yapabilmektedir
. Daha az optimal kod üretebilir ve eski kodlayıcı kadar test edilmemiştir, ancak Solidity 0.6.0'dan itibaren deneysel olmayan olarak kabul edilir. Yine de ``pragma abicoder v2;`` kullanarak açıkça etkinleştirmeniz gerekir. Solidity 0.8.0'dan itibaren varsayılan olarak etkinleştirileceğinden, ``pragma abicoder v1;`` kullanarak eski kodlayıcıyı seçme seçeneği vardır.

Yeni kodlayıcı tarafından desteklenen türler, eskisi tarafından desteklenenlerin katı bir üst kümesidir. Bunu kullanan sözleşmeler, sınırlama olmaksızın kullanmayanlarla etkileşime girebilir. Bunun tersi ancak ``abicoder v2`` olmayan sözleşme, yalnızca yeni kodlayıcı tarafından desteklenen kod çözme türlerini gerektirecek çağrılar yapmaya çalışmadığı sürece mümkündür. Derleyici bunu algılayabilir ve bir hata verecektir. Sözleşmeniz için ``abicoder v2``yi etkinleştirmeniz hatanın ortadan kalkması için yeterlidir.

.. note::
  Bu pragma, etkinleştirildiği dosyada tanımlanan tüm kodlar için, bu kodun sonunda nerede sonlandığına bakılmaksızın geçerlidir. Bu, kaynak dosyası ABI coder v1 ile derlenmek üzere seçilen bir sözleşmenin
yine de başka bir sözleşmeden miras alarak yeni kodlayıcıyı kullanan kod içerebilir. Yeni türler harici işlev imzalarında değil de yalnızca dahili olarak kullanılıyorsa buna izin verilir.

.. note::
  
Solidity 0.7.4'e kadar, ``pragma experimental ABIEncoderV2`` kullanarak ABI kodlayıcı v2'yi seçmek mümkündü, ancak varsayılan olduğu için kodlayıcı v1'i açıkça seçmek mümkün değildi.
.. index:: ! pragma, deneysel

.. _experimental_pragma:
Deneysel Pragma
-------------------

İkinci pragma deneysel pragmadır. Derleyicinin veya dilin henüz varsayılan olarak etkinleştirilmemiş özelliklerini etkinleştirmek için kullanılabilir.aşağıdaki deneysel pragmalar şu anda desteklenmektedir:


ABIEncoderV2
~~~~~~~~~~~~

Çünkü ABI kodlayıcı v2 artık deneysel olarak kabul edilmiyor,
``pragma abicoder v2`` aracılığıyla seçilebilir (lütfen yukarıya bakın)
Solidity 0.7.4'ten beri.
.. _smt_checker:

SMTChecker
~~~~~~~~~~

Solidity derleyicisi oluşturulduğunda bu bileşen etkinleştirilmelidir
ve bu nedenle tüm Solidity ikili dosyalarında mevcut değildir. :ref:`build instructions<smt_solvers_build>` bu seçeneğin nasıl etkinleştirileceğini açıklar. çoğu sürümde Ubuntu PPA sürümleri için etkinleştirilmiştir,
ancak Docker görüntüleri, Windows ikili dosyaları veya statik olarak oluşturulmuş Linux ikili dosyaları için değil. Yerel olarak yüklenmiş bir SMT çözücünüz varsa ve solc-js'yi node üzerinden (tarayıcı üzerinden değil) çalıştırıyorsanız, solc-js için `smtCallback <https://github.com/ethereum/solc js#example-usage-with-smtsolver-callback>`_ aracılığıyla etkinleştirilebilir.

Eğer ``pragma experimental SMTChecker;`` kullanırsanız, o zaman ek:ref:`safety warnings<formal_verification>` alırsınız.
SMT çözücü. Bileşen henüz Solidity dilinin tüm özelliklerini desteklememektedir ve muhtemelen birçok uyarı vermektedir. Desteklenmeyen özellikleri bildirmesi durumunda, analiz tam olarak sağlıklı olmayabilir.

.. index:: kaynak dosya, ! içe aktarma, modül, kaynak birim
.. _import:

Diğer Kaynak Dosyaları İçe Aktarma
============================

Sözdizimi ve Anlambilim
--------------------

Solidity, kodunuzu modüler hale getirmenize yardımcı olmak için import deyimlerini destekler
JavaScript'te mevcut olanlara benzerdir (ES6'dan itibaren). Ancak, Solidity `default export <https://developer.mozilla.org/en-US/docs/web/javascript/reference/statements/export#Description>`_ kavramını desteklemez.

Genel düzeyde, aşağıdaki formdaki içe aktarma deyimlerini kullanabilirsiniz:

.. code-block:: solidity

    import "filename";

Filename kısmı *import path* olarak adlandırılır.
Bu deyim, "filename "deki tüm global sembolleri (ve orada içe aktarılan sembolleri) geçerli global kapsama içe aktarır (ES6'dakinden farklıdır, ancak Solidity için geriye dönük olarak uyumludur).
Bu formun kullanılması tavsiye edilmez, çünkü isim alanını tahmin edilemeyecek şekilde kirletir.
"filename" içine yeni üst düzey öğeler eklerseniz, bunlar otomatik olarak "filename "den bu şekilde içe aktarılan tüm dosyalarda görünür. Belirli öğeleri içe aktarmak daha iyidir
sembolleri açıkça.

Aşağıdaki örnek, üyeleri ``"filename"`` içindeki tüm global semboller olan yeni bir global sembol ``symbolName`` oluşturur:

.. code-block:: solidity

    import * as symbolName from "filename";

bu da tüm global sembollerin ``symbolName.symbol`` biçiminde kullanılabilir olmasıyla sonuçlanır.

Bu sözdiziminin ES6'nın bir parçası olmayan, ancak muhtemelen yararlı olan bir çeşidi:
.. code-block:: solidity

  import "filename" as symbolName;

bu da ``import * as symbolName from "filename";`` ile eşdeğerdir.

Bir adlandırma çakışması varsa, içe aktarma sırasında sembolleri yeniden adlandırabilirsiniz. Örneğin, aşağıdaki kod sırasıyla ``"filename"`` içinden ``symbol1`` ve ``symbol2``ye referans veren yeni global semboller ``alias`` ve ``symbol2`` oluşturur.
.. code-block:: solidity

    import {symbol1 as alias, symbol2} from "filename";

.. index:: virtual filesystem, source unit name, import; path, filesystem path, import callback, Remix IDE

İçe Aktarma Yolları
------------

 Tüm platformlarda tekrarlanabilir derlemeleri destekleyebilmek için Solidity derleyicisinin kaynak dosyalarının depolandığı dosya sisteminin ayrıntılarını soyutlaması gerekir.
Bu nedenle içe aktarma yolları doğrudan ana dosya sistemindeki dosyalara başvurmaz.
Bunun yerine derleyici, her kaynak birime opak ve yapılandırılmamış bir tanımlayıcı olan benzersiz bir *kaynak birim adı* atanan dahili bir veritabanı (*sanal dosya sistemi* veya kısaca *VFS*) tutar. import deyiminde belirtilen import yolu, bir kaynak birim adına çevrilir ve
Bu veritabanında ilgili kaynak birimi bulun.

ref:`Standart JSON <compiler-api>` API'sini kullanarak, derleyici girdisinin bir parçası olarak tüm kaynak dosyaların adlarını ve içeriğini doğrudan sağlamak mümkündür. bu durumda kaynak birim adları gerçekten keyfi olabilir. ancak, derleyicinin kaynak kodu otomatik olarak bulmasını ve VFS'ye yüklemesini istiyorsanız, kaynak birim adlarınızın bir :ref:`import callback'i mümkün kılacak şekilde yapılandırılması gerekir.
<import-callback>` komut satırı derleyicisini kullanırken varsayılan import callback yalnızca kaynak kodun yüklenmesini destekler
Bazı ortamlar daha çok yönlü olan özel geri aramalar sağlar. Örneğin `Remix IDE <https://remix.ethereum.org/>`_, `HTTP, IPFS ve Swarm URL'lerinden dosya içe aktarmanıza veya doğrudan NPM kayıt defterindeki paketlere başvurmanıza<https://remix-ide.readthedocs.io/en/latest/import.html>`_ olanak tanıyan bir tane sağlar.
tarafından kullanılan sanal dosya sistemi ve yol çözümleme mantığının tam bir açıklaması için
derleyici bkz :ref:`Path Resolution <path-resolution>`.

.. index:: ! comment, natspec

Yorumlar
========

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
ref:`style guide<style_guide_natspec>` içinde ayrıntılı olarak açıklanmıştır. Bunlar üçlü eğik çizgi (``//``) veya çift yıldız bloğu (``/** ... */``) ile yazılır ve doğrudan fonksiyon bildirimlerinin veya deyimlerinin üzerinde kullanılmalıdır.