##################
Katkıda Bulunmak
##################

Yardıma her zaman açığız ve Solidity'ye nasıl katkıda bulunabileceğinize dair pek çok seçenek var.

Özellikle aşağıdaki alanlardaki destek için minnettar olduğumuzu belirtmek isteriz:

* Sorunların raporlanması.
* `Solidity'nin GitHub sorunlarını <https://github.com/ethereum/solidity/issues>`_
  düzeltmek ve yanıtlamak, özellikle de dışarıdan katkıda bulunanlar için giriş
  sorunları olarak tasarlanan `"good first issue" <https://github.com/ethereum/solidity/labels/good%20first%20issue> _
  olarak etiketlenenler.
* Dokümantasyonun iyileştirilmesi.
* Dokümantasyonun daha fazla dile çevrilmesi.
* `StackExchange'de diğer kullanıcıların sorularını yanıtlama
  <https://ethereum.stackexchange.com>`_ ve `Solidity Gitter Chat
  <https://gitter.im/ethereum/solidity>`_.
* Solidity forumunda <https://forum.soliditylang.org/>`_ dil değişiklikleri veya yeni özellikler önererek ve geri bildirim sağlayarak dil tasarım sürecine dahil olmak.

Başlamak için, Solidity bileşenlerine ve derleme sürecine aşina olmak için
:ref:`building-from-source`u deneyebilirsiniz. Ayrıca, Solidity'de akıllı
sözleşmeler yazma konusunda uzmanlaşmak da faydalı olabilir.

Lütfen bu projenin bir `Katılımcı Davranış Kuralları <https://raw.githubusercontent.com/ethereum/solidity/develop/CODE_OF_CONDUCT.md>`_ ile yayınlandığını unutmayın. Bu projeye katılarak - sorunlarda, pull request' lerde veya Gitter kanallarında - şartlarına uymayı kabul etmiş olursunuz.

Takım Toplantıları
===================

Tartışmak istediğiniz sorunlar veya pull request'ler varsa ya da ekibin ve katkıda
bulunanların neler üzerinde çalıştığını duymak istiyorsanız, herkese açık takım toplantılarımıza katılabilirsiniz:

- Pazartesi günleri saat 15:00 CET/CEST. Türkiye saati ile 16:00, 
- Çarşamba günleri 14:00 CET/CEST.

Her iki çağrı da `Jitsi <https://meet.ethereum.org/solidity>`_ üzerinde gerçekleşir.

Sorunlar Nasıl Rapor Edilir
============================

Bir sorunu bildirmek için lütfen `GitHub sorunları izleyicisini <https://github.com/ethereum/solidity/issues>`_
kullanın. Sorunları bildirirken lütfen aşağıdaki ayrıntıları belirtin:

* Solidity sürümü.
* Kaynak kodu (varsa).
* İşletim sistemi.
* Sorunu yeniden üretmek için adımlar.
* Mevcut ve beklenen davranış.

Soruna neden olan kaynak kodunu en aza indirmek her zaman sorunların çözümüne yardımcı
olur ve hatta bazen bir yanlış anlaşılmayı açıklığa kavuşturur.

Pull Request'ler için İş Akışı(Workflow)
=========================================

Katkıda bulunmak için lütfen ``develop`` dalını forklayın ve değişikliklerinizi
orada yapın. Commit mesajlarınızda *ne* yaptığınızın yanı sıra *neden* değişiklik
yaptığınız da belirtilmelidir (çok küçük bir değişiklik olmadığı sürece).

Fork yaptıktan sonra ``develop``tan herhangi bir değişiklik çekmeniz(pull) gerekiyorsa
(örneğin, olası merge conflict`leri çözmek için), lütfen ``git merge`` kullanmaktan
kaçının ve bunun yerine branch`inizi ``git rebase`` yapın. Bu, değişikliğinizi daha
kolay gözden geçirmemize yardımcı olacaktır.

Ayrıca, yeni bir özellik yazıyorsanız, lütfen ``test/`` altına uygun test örneklerini
eklediğinizden emin olun (aşağıya bakınız).

Bununla birlikte, daha büyük bir değişiklik yapıyorsanız, lütfen önce `Solidity
Development Gitter kanalına <https://gitter.im/ethereum/solidity-dev>`_ (yukarıda
bahsedilenden farklı olarak, bu kanal dil kullanımı yerine derleyici ve dil
geliştirmeye odaklanmıştır) danışın.

Yeni özellikler ve hata düzeltmeleri ``Changelog.md`` dosyasına eklenmelidir:
lütfen uygun durumlarda önceki girişlerin stilini takip edin.

Son olarak, lütfen bu proje için `kodlama stiline <https://github.com/ethereum/solidity/blob/develop/CODING_STYLE.md>`_
uyduğunuzdan emin olun. Ayrıca, CI testi yapmamıza rağmen, lütfen kodunuzu test edin
ve bir pull request göndermeden önce yerel olarak derlendiğinden emin olun.

Yardımlarınız için teşekkür ederiz!

Derleyici Testlerini Çalıştırma
================================

Ön Koşullar
-------------

Tüm derleyici testlerini çalıştırmak için isteğe bağlı olarak birkaç bağlayıcı faktör yüklemek isteyebilirsiniz.
yüklemek isteyebilirsiniz (`evmone <https://github.com/ethereum/evmone/releases>`_,
`libz3 <https://github.com/Z3Prover/z3>`_ ve `libhera <https://github.com/ewasm/hera>`_).

macOS üzerinde bazı test komut dosyaları GNU coreutils'in kurulu olmasını beklemektedir.
Bu en kolay Homebrew kullanılarak gerçekleştirilebilir: ``brew install coreutils``.

Windows sistemlerinde ortak bağlantı oluşturma ayrıcalığına sahip olduğunuzdan emin
olun, aksi takdirde bazı testler başarısız olabilir. Yöneticilerin bu ayrıcalığa
sahip olması gerekir, ancak `diğer kullanıcılara da verebilirsiniz <https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/create-symbolic-links#policy-management>`_ veya
`Geliştirici Modunu etkinleştirebilirsiniz <https://docs.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development>`_.

Testleri Çalıştırma
--------------------

Solidity, çoğu `Boost C++ Test Framework <https://www.boost.org/doc/libs/release/libs/test/doc/html/index.html>`_ uygulaması ``soltest`` içinde paketlenmiş farklı test türleri içerir. Çoğu değişiklik için ``build/test/soltest`` veya onun paketleyicisi olan ``scripts/soltest.sh`` dosyasını çalıştırmak yeterlidir.

./scripts/tests.sh`` betiği, `Boost C++ Test Framework <https://www.boost.org/doc/libs/release/libs/test/doc/html/index.html>`_ uygulaması ``soltest`` (veya paketleyicisi ``scripts/soltest.sh``) ile birlikte komut satırı testleri ve derleme testleri de dahil olmak üzere çoğu Solidity testini otomatik olarak yürütür.

Test sistemi, anlamsal testleri çalıştırmak için otomatik olarak `evmone <https://github.com/ethereum/evmone/releases>`_ konumunu keşfetmeye çalışır.

``evmone`` kütüphanesi, geçerli çalışma dizinine, üst dizinine veya üst dizinin üst dizinine göre ``deps`` veya ``deps/lib`` dizininde bulunmalıdır. Alternatif olarak ``evmone`` paylaşımlı nesnesi için açık bir konum ``ETH_EVMONE`` ortam değişkeni aracılığıyla belirtilebilir.

``evmone`` esas olarak semantik ve gaz testlerini çalıştırmak için gereklidir. Eğer yüklü değilse, ``scripts/soltest.sh`` dosyasına ``--no-semantic-tests`` parametresini girerek bu testleri atlayabilirsiniz.

Ewasm testlerinin çalıştırılması varsayılan olarak devre dışıdır ve ``./scripts/soltest.sh --ewasm`` aracılığıyla açıkça etkinleştirilebilir ve ``hera <https://github.com/ewasm/hera>`_ kütüphanesinin ``soltest`` tarafından bulunmasını gerektirir. ``hera`` kütüphanesini bulma mekanizması ``evmone`` ile aynıdır, ancak açık bir konum belirtmek için kullanılan değişken ``ETH_HERA`` olarak adlandırılır.

``evmone`` ve ``hera`` kütüphanelerinin her ikisi de Linux'ta ``.so``, Windows sistemlerinde ``.dll`` ve macOS'ta ``.dylib`` dosya adı uzantısı ile bitmelidir.

SMT testlerini çalıştırmak için, ``libz3`` kütüphanesi yüklenmeli ve derleyici yapılandırma aşamasında ``cmake`` tarafından bulunabilmelidir.

Eğer ``libz3`` kütüphanesi sisteminizde yüklü değilse, ``./scripts/tests.sh`` dosyasını çalıştırmadan önce ``SMT_FLAGS=--no-smt`` komutunu vererek veya ``./scripts/soltest.sh -no smt`` dosyasını çalıştırarak SMT testlerini devre dışı bırakmalısınız. Bu testler ``libsolidity/smtCheckerTests`` ve ``libsolidity/smtCheckerTestsJSON`` testleridir.

.. note ::

    Soltest tarafından çalıştırılan tüm birim testlerinin bir listesini almak için ``./build/test/soltest --list_content=HRF`` komutunu çalıştırın.

Daha hızlı sonuç almak için testlerin bir alt kümesini veya belirli testleri çalıştırabilirsiniz.

To run a subset of tests, you can use filters:
``./scripts/soltest.sh -t TestSuite/TestName``,
where ``TestName`` can be a wildcard ``*``.

Ya da örneğin, yul disambiguator ile ilgili tüm testleri çalıştırmak için: ``./scripts/soltest.sh -t "yulOptimizerTests/disambiguator/*" --no-smt``.

``./build/test/soltest --help`` mevcut tüm seçenekler hakkında ayrıntılı bir yardım sağlar.

Özellikle bakınız:

- Testin tamamlandığını göstermek için `show_progress (-p) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/show_progress.html>`_,
- Belirli test durumlarını çalıştırmak için `run_test (-t) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/run_test.html>`_ ve
- `report-level (-r) <https://www.boost.org/doc/libs/release/libs/test/doc/html/boost_test/utf_reference/rt_param_reference/report_level.html>`_ daha ayrıntılı bir rapor verir.

.. note ::

    Windows ortamında çalışanlar yukarıdaki temel setleri libz3 olmadan çalıştırmak
    isterler. Git Bash kullanarak, şunları kullanabilirsiniz: ``./build/test/Release/soltest.exe -- --no-smt``.
    Bunu düz Komut İstemi'nde çalıştırıyorsanız, ``.\build\test\Release\soltest.exe -- --no-smt`` kullanın.

GDB kullanarak hata ayıklamak istiyorsanız, "normalden" farklı bir şekilde derlediğinizden
emin olun. Örneğin, ``build`` klasörünüzde aşağıdaki komutu çalıştırabilirsiniz:
.. code-block:: bash

   cmake -DCMAKE_BUILD_TYPE=Debug ..
   make

Bu, ``--debug`` parametresini kullanarak bir testte hata ayıkladığınızda, bozabileceğiniz
veya yazdırabileceğiniz fonksiyonlara ve değişkenlere erişebilmeniz için semboller oluşturur.

CI, Emscripten hedefinin derlenmesini gerektiren ek testler (``solc-js`` ve üçüncü
taraf Solidity çerçevelerinin test edilmesi dahil) çalıştırır.

Sözdizimi Testleri Yazma ve Çalıştırma
---------------------------------------

Sözdizimi testleri, derleyicinin geçersiz kod için doğru hata mesajlarını oluşturduğunu
ve geçerli kodu düzgün bir şekilde kabul ettiğini kontrol eder. Bunlar
``tests/libsolidity/syntaxTests`` klasörü içindeki ayrı dosyalarda saklanır. Bu dosyalar,
ilgili testin beklenen sonuç(lar)ını belirten ek açıklamalar içermelidir. Test paketi
bunları derler ve verilen beklentilere göre kontrol eder.

Örneğin: ``./test/libsolidity/syntaxTests/double_stateVariable_declaration.sol``

.. code-block:: solidity

    contract test {
        uint256 variable;
        uint128 variable;
    }
    // ----
    // DeclarationError: (36-52): Tanımlayıcı zaten bildirilmiş.

Bir sözdizimi testi, en azından test edilen sözleşmenin kendisini ve ardından ``// ----`` ayırıcısını
içermelidir. Ayırıcıyı takip eden yorumlar, beklenen derleyici hatalarını veya uyarılarını
tanımlamak için kullanılır. Sayı aralığı, kaynakta hatanın meydana geldiği konumu belirtir.
Sözleşmenin herhangi bir hata veya uyarı olmadan derlenmesini istiyorsanız, ayırıcıyı ve onu
takip eden yorumları dışarıda bırakabilirsiniz.

Yukarıdaki örnekte, ``variable`` durum değişkeni iki kez bildirilmiştir, buna izin verilmez. Bu, tanımlayıcının zaten bildirilmiş olduğunu belirten bir ``DeclarationError`` ile sonuçlanır.

Bu testler için ``isoltest`` aracı kullanılır ve bu aracı ``./build/test/tools/`` altında bulabilirsiniz.
Tercih ettiğiniz metin editörünü kullanarak başarısız sözleşmelerin düzenlenmesine izin veren etkileşimli
bir araçtır. Şimdi ``variable`` ifadesinin ikinci bildirimini kaldırarak bu testi çözmeye çalışalım:

.. code-block:: solidity

    contract test {
        uint256 variable;
    }
    // ----
    // DeclarationError: (36-52): Tanımlayıcı zaten bildirilmiş.

Tekrar ``./build/test/tools/isoltest`` çalıştırıldığında test başarısız olur:

.. code-block:: text

    syntaxTests/double_stateVariable_declaration.sol: FAIL
        Contract:
            contract test {
                uint256 variable;
            }

          Beklenen sonuç:
              DeclarationError: (36-52): Tanımlayıcı zaten bildirilmiş.
          Elde edilen sonuç:
              Başarılı


``isoltest`` elde edilen sonucun yanına beklenen sonucu yazdırır ve ayrıca mevcut sözleşme dosyasını düzenlemek, güncellemek veya atlamak ya da uygulamadan çıkmak için bir yol sağlar.

Başarısız testler için çeşitli seçenekler sunar:

- ``edit``: ``isoltest`` sözleşmeyi bir editörde açmaya çalışır, böylece onu ayarlayabilirsiniz. Ya komut satırında (``isoltest --editor /path/to/editor`` şeklinde), ya ``EDITOR`` ortam değişkeninde ya da sadece ``/usr/bin/editor`` (bu sırayla) verilen editörü kullanır.
- ``update``: Test edilen sözleşme için beklentileri günceller. Bu, karşılanmamış beklentileri kaldırarak ve eksik beklentileri ekleyerek ek açıklamaları günceller. Test daha sonra tekrar çalıştırılır.
- ``skip``: Bu belirli testin yürütülmesini atlar.
- ``quit``: isoltest`` testinden çıkar.

Bu seçeneklerin tümü, tüm test sürecini durduran ``quit`` dışında mevcut sözleşme için geçerlidir.

Yukarıdaki testin otomatik olarak güncellenmesi onu şu şekilde değiştirir

.. code-block:: solidity

    contract test {
        uint256 variable;
    }
    // ----

ve testi yeniden çalıştırır. Şimdi tekrar geçer:

.. code-block:: text

    Re-running test case...
    syntaxTests/double_stateVariable_declaration.sol: OK


.. note::

    Sözleşme dosyası için neyi test ettiğini açıklayan bir isim seçin, örneğin ``double_variable_declaration.sol``.
    Kalıtım veya çapraz sözleşme çağrılarını test etmediğiniz sürece, tek bir dosyaya birden fazla sözleşme koymayın.
    Her dosya yeni özelliğinizin bir yönünü test etmelidir.


Fuzzer'ı AFL ile Çalıştırma
============================

Fuzzing, istisnai yürütme durumlarını (segmentasyon hataları, istisnalar, vb.) bulmak
için programları az çok rastgele girdiler üzerinde çalıştıran bir tekniktir. Modern
fuzzer'lar akıllıdır ve girdi içinde yönlendirilmiş bir arama yaparlar. Kaynak kodunu
girdi olarak alan ve dahili bir derleyici hatası, segmentasyon hatası veya benzeriyle
karşılaştığında başarısız olan, ancak örneğin kod bir hata içeriyorsa başarısız olmayan
``solfuzzer`` adlı özel bir binary'ye sahibiz. Bu şekilde, fuzzing araçları derleyicideki
dahili sorunları bulabilir.

Biz fuzzing için çoğunlukla `AFL <https://lcamtuf.coredump.cx/afl/>`_ kullanıyoruz. AFL
paketlerini depolarınızdan indirip kurmanız (afl, afl-clang) ya da elle derlemeniz gerekir.
Ardından, derleyiciniz olarak AFL ile Solidity'yi (veya sadece ``solfuzzer`` binary'sini)
derleyin:

.. code-block:: bash

    cd build
    # if needed
    make clean
    cmake .. -DCMAKE_C_COMPILER=path/to/afl-gcc -DCMAKE_CXX_COMPILER=path/to/afl-g++
    make solfuzzer

Bu aşamada aşağıdakine benzer bir mesaj görebilmeniz gerekir:

.. code-block:: text

    Scanning dependencies of target solfuzzer
    [ 98%] Building CXX object test/tools/CMakeFiles/solfuzzer.dir/fuzzer.cpp.o
    afl-cc 2.52b by <lcamtuf@google.com>
    afl-as 2.52b by <lcamtuf@google.com>
    [+] Instrumented 1949 locations (64-bit, non-hardened mode, ratio 100%).
    [100%] Linking CXX executable solfuzzer

Program mesajları görünmediyse, AFL'nin clang binary'lerine işaret eden cmake bayraklarını değiştirmeyi deneyin:

.. code-block:: bash

    # if previously failed
    make clean
    cmake .. -DCMAKE_C_COMPILER=path/to/afl-clang -DCMAKE_CXX_COMPILER=path/to/afl-clang++
    make solfuzzer

Aksi takdirde, yürütme sırasında fuzzer binary'nin enstrümante edilmediğini belirten bir hata ile duracaktır:

.. code-block:: text

    afl-fuzz 2.52b by <lcamtuf@google.com>
    ... (truncated messages)
    [*] Validating target binary...

    [-] Looks like the target binary is not instrumented! The fuzzer depends on
        compile-time instrumentation to isolate interesting test cases while
        mutating the input data. For more information, and for tips on how to
        instrument binaries, please see /usr/share/doc/afl-doc/docs/README.

        When source code is not available, you may be able to leverage QEMU
        mode support. Consult the README for tips on how to enable this.
        (It is also possible to use afl-fuzz as a traditional, "dumb" fuzzer.
        For that, you can use the -n option - but expect much worse results.)

    [-] PROGRAM ABORT : No instrumentation detected
             Location : check_binary(), afl-fuzz.c:6920


Ardından, bazı örnek kaynak dosyalara ihtiyacınız var. Bu, fuzzer'ın hataları bulmasını
çok daha kolay hale getirir. Sözdizimi testlerinden bazı dosyaları kopyalayabilir ya da
dokümantasyondan veya diğer testlerden test dosyalarını çıkarabilirsiniz:

.. code-block:: bash

    mkdir /tmp/test_cases
    cd /tmp/test_cases
    # extract from tests:
    path/to/solidity/scripts/isolate_tests.py path/to/solidity/test/libsolidity/SolidityEndToEndTest.cpp
    # extract from documentation:
    path/to/solidity/scripts/isolate_tests.py path/to/solidity/docs

AFL dokümantasyonunda corpus'un (ilk girdi dosyaları) çok büyük olmaması gerektiği
belirtilmektedir. Dosyaların kendileri 1 kB'den büyük olmamalıdır ve fonksiyonellik
başına en fazla bir girdi dosyası olmalıdır, bu nedenle az sayıda dosya ile başlamak
daha iyidir. Binary'nin benzer davranışına neden olan girdi dosyalarını kırpabilen
``afl-cmin`` adlı bir araç da bulunmaktadır.

Şimdi fuzzer'ı çalıştırın (``-m`` bellek boyutunu 60 MB'a genişletir):

.. code-block:: bash

    afl-fuzz -m 60 -i /tmp/test_cases -o /tmp/fuzzer_reports -- /path/to/solfuzzer

Fuzzer, ``/tmp/fuzzer_reports`` içinde hatalara yol açan kaynak dosyaları oluşturur.
Genellikle aynı hatayı üreten birçok benzer kaynak dosya bulur. Benzersiz hataları
filtrelemek için ``scripts/uniqueErrors.sh`` aracını kullanabilirsiniz.

Whiskers
========

*Whiskers*, `Mustache <https://mustache.github.io>`_ benzeri bir dize şablonlama
sistemidir. Derleyici tarafından çeşitli yerlerde kodun okunabilirliğine ve dolayısıyla
korunabilirliğine ve doğrulanabilirliğine yardımcı olmak için kullanılır.

Sözdizimi Mustache'den önemli bir farkla birlikte gelir. Ayrıştırmaya yardımcı olmak
ve :ref:`yul` ile çakışmaları önlemek için ``{{`` ve ``}}` şablon işaretleyicileri
``<`` ve ``>`` ile değiştirilir (``<`` ve ``>`` sembolleri inline assembly'de geçersizdir,
``{`` ve ``}`` ise blokları sınırlandırmak için kullanılır). Bir başka sınırlama da
listelerin yalnızca bir derinlikte çözümlenebilmesi ve özyinelemeye tabi tutulmamasıdır.
Bu gelecekte değişebilir.

Kaba bir tanımlama aşağıdaki gibidir:

Herhangi bir ``<name>`` oluşumu, herhangi bir kaçış olmadan ve yinelenen değiştirmeler
olmadan sağlanan ``name`` değişkeninin dize değeri ile değiştirilir. Bir alan ``<#name>...</name>``
ile sınırlandırılabilir. Şablon sistemine sağlanan değişken kümeleri kadar içeriğinin
bir araya getirilmesiyle değiştirilir ve her seferinde herhangi bir ``<inner>` öğesi
ilgili değeriyle değiştirilir. Üst düzey değişkenler de bu tür alanların içinde kullanılabilir.

Ayrıca ``<?name>...<!name>...</name>`` biçiminde koşullular da vardır, burada şablon
değiştirmeleri ``name`` boolean parametresinin değerine bağlı olarak birinci ya da
ikinci segmentte özyinelemeli olarak devam eder. Eğer ``<?+name>...<!+name>...</+name>``
kullanılırsa, o zaman ``name`` string parametresinin boş olup olmadığı kontrol edilir.

.. _documentation-style:

Dokümantasyon Stil Rehberi
===========================

Aşağıdaki bölümde özellikle Solidity'ye yapılan dokümantasyon katkılarına odaklanan
stil önerileri bulacaksınız.

İngilizce Dili
----------------

Proje veya marka isimleri kullanmadığınız sürece İngilizce kullanın ve İngiliz İngilizcesi
imla kurallarını tercih edin. Yerel argo ve referansların kullanımını azaltmaya çalışın ve dilinizi tüm okuyucular için mümkün olduğunca anlaşılır hale getirin. Aşağıda size yardımcı olacak bazı referanslar verilmiştir:

* `Basitleştirilmiş teknik İngilizce <https://en.wikipedia.org/wiki/Simplified_Technical_English>`_
* `Uluslararası İngilizce <https://en.wikipedia.org/wiki/International_English>`_
* `İngiliz İngilizcesi yazılışı <https://en.oxforddictionaries.com/spelling/british-and-spelling>`_


.. note::

    Resmi Solidity dokümantasyonu İngilizce olarak yazılmış olsa da, diğer dillerde
    topluluk katkılı :ref: `translations` mevcuttur. Topluluk çevirilerine nasıl katkıda
    bulunabileceğiniz hakkında bilgi için lütfen `çeviri kılavuzuna <https://github.com/solidity-docs/translation-guide>`_ bakın.

Başlıklar için Başlık Düzeni
-----------------------------

Başlıklar için `title case <https://titlecase.com>`_ kullanın. Bu, başlıklardaki
tüm ana sözcüklerin büyük harfle yazılması, ancak başlığa başlamadıkları sürece
artikellerin, bağlaçların ve edatların büyük harfle yazılmaması anlamına gelir.

Örneğin, aşağıdakilerin hepsi doğrudur:

* Başlıklar için Başlık Düzeni.
* Başlıklar İçin Başlık Düzenini Kullanın.
* Yerel ve Eyalet Değişken Adları.
* Düzen Sırası.

Genişletme Kısaltmaları
-------------------------

Örneğin, sözcükler için genişletilmiş kısaltmalar kullanın:

* "Don't" yerine "Do not".
* "Can't" yerine "Can not".

Aktif ve Pasif Ses
------------------------

Aktif ses, okuyucunun bir görevi kimin veya neyin gerçekleştirdiğini anlamasına
yardımcı olduğu için genellikle öğretici tarzı dokümantasyon için önerilir. Ancak,
Solidity dokümantasyonu öğretici ve referans içeriklerin bir karışımı olduğundan,
pasif ses bazen daha uygundur.

Özetlemek gerekirse:

* Teknik referanslar için pasif ses kullanın, örneğin dil tanımı ve Ethereum VM'nin dahili özellikleri.
* Solidity'nin bir yönünün nasıl uygulanacağına ilişkin önerileri açıklarken aktif ses kullanın.

Örneğin, aşağıdaki metin Solidity'nin bir yönünü belirttiği için pasif seslidir:

  Fonksiyonlar ``pure`` olarak bildirilebilir, bu takdirde durumdan okuma yapmayacaklarına
  veya durumu değiştirmeyeceklerine söz verirler.

Örneğin, aşağıda Solidity'nin bir uygulaması tartışılırken aktif ses kullanılmıştır:

  Derleyiciyi çağırırken, bir yolun ilk öğesinin nasıl bulunacağını ve ayrıca yol
  öneki yeniden eşlemelerini belirtebilirsiniz.

Genel Terimler
---------------

* "Fonksiyon parametreleri" ve "dönüş değişkenleri", girdi ve çıktı parametreleri değil.

Kod Örnekleri
--------------

Bir CI süreci, bir PR oluşturduğunuzda ``./test/cmdlineTests.sh`` betiğini kullanarak
``pragma solidity``, ``contract``, ``library`` veya ``interface`` ile başlayan tüm kod
bloğu biçimlendirilmiş kod örneklerini test eder. Yeni kod örnekleri ekliyorsanız, PR
oluşturmadan önce bunların çalıştığından ve testleri geçtiğinden emin olun.

Tüm kod örneklerinin, sözleşme kodunun geçerli olduğu en geniş alanı kapsayan bir
``pragma`` sürümü ile başladığından emin olun. Örneğin ``pragma solidity >=0.4.0 <0.9.0;``.

Dokümantasyon Testlerini Çalıştırma
------------------------------------

Dokümantasyon için gerekli bağımlılıkları yükleyen ve kırık bağlantılar veya sözdizimi
sorunları gibi sorunları kontrol eden ``./docs/docs.sh`` dosyasını çalıştırarak katkılarınızın dokümantasyon testlerimizi geçtiğinizden emin olun.

Solidity Dili Tasarımı
========================

Dil tasarım sürecine aktif olarak dahil olmak ve Solidity'nin geleceği ile ilgili
fikirlerinizi paylaşmak için lütfen `Solidity forum <https://forum.soliditylang.org/>`_'a katılın.

Solidity forumu, yeni dil özelliklerinin ve bunların uygulanmasının ilk aşamalarında
veya mevcut özelliklerin modifikasyonlarının önerildiği ve tartışıldığı bir yer olarak
hizmet vermektedir.

Öneriler daha somut hale gelir gelmez, bunların uygulanması da `Solidity GitHub repository
<https://github.com/ethereum/solidity>`_'de sorunlar şeklinde tartışılacaktır.

Forum ve sorun tartışmalarına ek olarak, seçilen konuların, sorunların veya özellik
uygulamalarının ayrıntılı olarak tartışıldığı dil tasarımı tartışma çağrılarına
düzenli olarak ev sahipliği yapıyoruz. Bu çağrılar için davetiye forum üzerinden
paylaşılmaktadır.

Ayrıca geri bildirim anketlerini ve dil tasarımıyla ilgili diğer içerikleri de forumda
paylaşıyoruz.

Ekibin yeni özelliklerin uygulanması konusunda ne durumda olduğunu öğrenmek istiyorsanız,
`Solidity Github projesi <https://github.com/ethereum/solidity/projects/43>`_ adresinden
uygulama durumunu takip edebilirsiniz. Tasarım birikimindeki konular daha fazla spesifikasyona
ihtiyaç duyar ve ya bir dil tasarımı çağrısında ya da normal bir ekip çağrısında tartışılacaktır.
Varsayılan branch'ten (`develop`) `breaking branch <https://github.com/ethereum/solidity/tree/breaking>`_'e
geçerek bir sonraki breaking release için gelecek değişiklikleri görebilirsiniz.

Geçici durumlar ve sorularınız için, Solidity derleyicisi ve dil geliştirme ile ilgili
konuşmalar için özel bir sohbet odası olan `Solidity dev Gitter kanalı <https://gitter.im/ethereum/solidity-dev>`_ üzerinden bize ulaşabilirsiniz.

Dil tasarım sürecini daha işbirlikçi ve şeffaf hale getirmek için neler yapabileceğimiz
konusundaki düşüncelerinizi duymaktan mutluluk duyarız.
