.. index:: ! installing

.. _installing-solidity:

################################
Solidity Derleyicisini Yükleme
################################

Sürüm
==========

Solidity sürümleri `Semantic Sürümlemeyi <https://semver.org>`_ takip eder. Ek
olarak, ana sürüm 0'a (yani 0.x.y) sahip yama düzeyindeki sürümler, kırılma değişiklikleri(breaking changes)
içermeyecektir. Bu, 0.x.y sürümü ile derlenen kodun z > y olduğu durumlarda 0.x.z ile derlenmesinin umulabileceği anlamına gelir.

Sürümlere ek olarak, geliştiricilerin gelecek özellikleri denemelerini ve erken
geri bildirim sağlamalarını kolaylaştırmak amacıyla **gece geliştirme yapıları**
(Nightly Development Builds diye de bilinir) sağlıyoruz. Bununla birlikte, nightly
yapılar genellikle çok kararlı olsalar da, geliştirme kolundaki (branch) en yeni
kodları içerdiklerini ve her zaman çalışacaklarının garanti edilmediğini unutmayın.
Tüm emeklerimize karşın, hala gerçek sürümün bir parçası olmayacak belgelenmemiş
ve/veya arızalı değişiklikler içerebilirler. Bunlar üretim amaçlı kullanım için uygun değillerdir.

Sözleşmeleri derleyip yüklerken Solidity'nin yayınlanan en son sürümünü kullanmalısınız. Bunun nedeni,
kırılma değişikliklerinin yanı sıra yeni özelliklerin tanıtılması ve eski sürümlerdeki hataların düzenli
olarak düzeltilmesinden kaynaklanmaktadır. Bu `hızlı sürüm değişikliklerini belirtmek için <https://semver.org/#spec-item-4>`_
şu anda 0.x sürüm numarası kullanıyoruz.

Remix
=====

*Solidity'i hızlı bir şekilde öğrenmek ve küçük akıllı sözleşmeler geliştirmek için Remix'i kullanmanızı tavsiye ediyoruz.*

`Remix'i online bir şekilde kullanabilirsiniz <https://remix.ethereum.org/>`_, bunun için herhangi bir şey indirip kurmanıza gerek yoktur.
Remix’i internet bağlantısı olmadan da kullanmak istiyorsanız, https://github.com/ethereum/remix-live/tree/gh-pages adresine gidip
sayfada açıklandığı gibi ``.zip`` dosyasını indirebilirsiniz. Remix, birden fazla Solidity sürümü yüklemenize gerek kalmadan gece
yapılarını da test etmek için uygun bir seçenektir.

Bu sayfada bulunan diğer seçenekler de komut satırı için Solidity derleyicisini bilgisayarınıza
nasıl kuracağınızı detaylı bir şekilde anlatmaktadır. Eğer daha büyük bir sözleşme üzerinde
çalışıyorsanız veya daha fazla derleme seçeneğine ihtiyacınız varsa lütfen bir komut satırı
derleyicisi seçin.

.. _solcjs:

npm / Node.js
=============

Solidity derleyicisi olan ``solcjs`` programını kurmanın kullanışlı ve taşınabilir bir yolu
için ``npm`` programını kullanabilirsiniz. `solcjs` programı, bu sayfanın ilerleyen kısımlarında
açıklanacak olan derleyiciye erişim yollarından daha az özelliğe sahiptir. ``solc``.ref:`commandline-compiler`(komut satırı derleyicisi) dokümantasyonu
tam özellikli derleyici olan ``solc`` kullandığınızı varsayar. ``solcjs`` kullanımı için oluşturulan
belgeler kendi `deposu <https://github.com/ethereum/solc-js>`_ içinde bulunmaktadır.

Not: solc-js projesi, Emscripten kullanılarak oluşturulan C++ `solc`
projesinden türetilmiştir, bu da her ikisinin de aynı derleyici kaynak
kodunu kullandığı anlamına gelir. Aynı zamanda `solc-js` doğrudan JavaScript
projelerinde (Remix gibi) kullanılabilmektedir. Talimatlar için lütfen solc-js deposuna göz atın.

.. code-block:: bash

    npm install -g solc

.. note::

    Komut satırında çalışabilen kod``solcjs`` olarak adlandırılmıştır (Komut satırına “solcjs" yazarak çalıştırabilirsiniz).

    ``solcjs`` komut satırı seçenekleri ``solc`` ile uyumlu değildir. Aynı zamanda çalışmak için ``solc`` komutuna ihtiyaç
    duyan araçlar (örneğin ``geth`` gibi) ``solcjs`` ile çalışmayacaktır.

Docker
======

Solidity yapılarında bulunan Docker imajları, ``ethereum`` kuruluşundaki ``solc`` imajlarını da kullanarak elde edilebilir.
Yayınlanan en son sürüm için ``stable`` etiketini ve geliştirme kolundaki (branch) sağlam olmayabilecek stabil olmayan değişiklikler
için ``nightly`` etiketini kullanabilirsiniz.

Docker imajı derleyicinin yürütülebilir dosyasını çalıştırır, bu sayede tüm değişkenleri derleyiciye iletebilirsiniz.
Örneğin, aşağıdaki komut ``solc`` imajının (elinizde mevcut değilse) kararlı bir sürümünü çeker ve ``--help`` parametresini ileterek
yeni bir konteynerde çalıştırır.

.. code-block:: bash

    docker run ethereum/solc:stable --help

Etikette derleme sürümlerini de belirtebilirsiniz, örneğin 0.5.4 sürümü için:

.. code-block:: bash

    docker run ethereum/solc:0.5.4 --help

Docker imajını kullanarak Solidity dosyalarını ana makinede derlemek istiyorsanız,
girdi ve çıktı için yerel bir klasör bağladıktan sonra derlenecek olan sözleşmeyi belirtin. Örnek vermek gerekirse:

.. code-block:: bash

    docker run -v /local/path:/sources ethereum/solc:stable -o /sources/output --abi --bin /sources/Contract.sol

Ayrıca spesifik bir JSON arayüzünü de kullanabilirsiniz (Hardhat,Truffle gibi derleyiciyi araçlarıyla birlikte kullanırken tavsiye edilir).
Bu arayüzü kullanırken, JSON girdisi bağımsız olduğu sürece herhangi bir dizini bağlamak gerekli değildir
(yani :ref:`içeri aktarılan(import) geri çağrısı (callback) <initial-vfs-content-standard-json-with-import-callback>`
tarafından yüklenmesi gereken herhangi bir harici dosyaya referans göstermez).

.. code-block:: bash

    docker run ethereum/solc:stable --standard-json < input.json > output.json

Linux Paketleri
================

Solidity'nin binary paketleri `solidity/releases <https://github.com/ethereum/solidity/releases>`_ adresinde mevcuttur.

Ayrıca Ubuntu için PPA'larımız da bulunmaktadır, aşağıdaki komutları kullanarak en son kararlı sürümü edinebilirsiniz:

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install solc

Gece sürümü de bu komutlar kullanılarak kurulabilir:

.. code-block:: bash

    sudo add-apt-repository ppa:ethereum/ethereum
    sudo add-apt-repository ppa:ethereum/ethereum-dev
    sudo apt-get update
    sudo apt-get install solc

Ayrıca, bazı Linux dağıtımları kendi paketlerini sağlamaktadırlar. Fakat bu paketlerin
bakımı doğrudan bizim tarafımızdan yapılmamaktadır. Bu paketler genellikle ilgili
paket sorumluları tarafından güncel tutulmaktadır.

Örnek vermek gerekirse, Arch Linux en son geliştirme sürümü için paketlere sahiptir:

.. code-block:: bash

    pacman -S solidity

Ayrıca bir `snap paketi <https://snapcraft.io/solc>`_ vardır, ancak **şu anda bakımı yapılmamaktadır**.
Bu paket `desteklenen tüm Linux dağıtımlarına <https://snapcraft.io/docs/core/install>`_ yüklenebilir.
Solc'un en son çıkan kararlı sürümünü yüklemek için:

.. code-block:: bash

    sudo snap install solc

Solidity'nin en son değişiklikleri içeren son çıkan geliştirme sürümünün test edilmesine yardımcı olmak istiyorsanız, lütfen aşağıdaki komutları kullanın:

.. code-block:: bash

    sudo snap install solc --edge

.. note::

    ``solc`` snap`i katı bir sınırlama sistemine sahiptir. Bu snap paketleri için uygulanabilecek
    en güvenli moddur, tabi bu modda yalnızca ``/home`` ve ``/media`` dizinlerinizdeki dosyalara
    erişmek gibi sınırlamalarla birlikte gelmektedir. Daha fazla bilgi için lütfen `Sıkı Snap Sınırlaması
    Sistemini Açıklamak <https://snapcraft.io/blog/demystifying-snap-confinement>`_ bölümüne gidin.


macOS Paketleri
================

Solidity derleyicisini, kaynaktan oluşturulmuş bir sürüm olarak Homebrew aracılığıyla
dağıtıyoruz. Önceden oluşturulmuş olan “bottles"lar(binary paketleri)
şu anda desteklenmemektedir.

.. code-block:: bash

    brew update
    brew upgrade
    brew tap ethereum/ethereum
    brew install solidity

Solidity'nin en son 0.4.x / 0.5.x sürümünü yüklemek için sırasıyla ``brew install solidity@4``
ve ``brew install solidity@5`` de kullanabilirsiniz.

Solidity'nin belirli bir sürümüne ihtiyacınız varsa, doğrudan Github'dan bir Homebrew “formula”sını
(Formula, paket tanımı için kullanılan bir ifadedir) yükleyebilirsiniz.

Github'daki `solidity.rb "commit"lerini görüntüleyin <https://github.com/ethereum/homebrew-ethereum/commits/master/solidity.rb>`_.

İstediğiniz bir sürümün commit hash'ini kopyalayabilir ve kendi makinenizde kontrol edebilirsiniz.

.. code-block:: bash

    git clone https://github.com/ethereum/homebrew-ethereum.git
    cd homebrew-ethereum
    git checkout <your-hash-goes-here>

Bunu ``brew`` kullanarak yükleyin:

.. code-block:: bash

    brew unlink solidity
    # eg. Install 0.4.8
    brew install solidity.rb

Statik Binaryler
============================

Desteklenen tüm platformlar için geçmiş ve güncel derleyici sürümlerinin statik yapılarını içeren
bir depoyu `solc-bin`_ adresinde tutuyoruz. Bu adreste aynı zamanda nightly yapıları da bulabilirsiniz.

Bu depo, son kullanıcıların ikili dosya sistemlerini kullanıma hazır hale getirmeleri için hızlı ve kolay bir yol
olmasının yanı sıra üçüncü taraf araçlarla da dost olmayı (kolay bir şekilde etkileşimde bulunmayı) amaçlamaktadır:

- https://binaries.soliditylang.org adresine yansıtılan bu içerik herhangi bir kimlik doğrulama, hız
  sınırlaması veya git kullanma ihtiyacı olmadan HTTPS üzerinden kolayca indirilebilir.
- İçerik, tarayıcıda çalışan araçlar tarafından doğrudan yüklenebilmesi için doğru `Content-Type`
  başlıklarıyla ve serbest CORS yapılandırmasıyla sunulur.
- Binaryler için herhangi bir kurulum veya paketten çıkarma işlemi gerekmez (gerekli DLL'lerle
  birlikte gelen eski Windows yapıları hariç).
- Biz yüksek düzeyde geriye dönük uyumluluk için çabalamaktayız. Dosyalar eklendikten sonra, eski konumunda
  bulunan bir kısayol bağlantısı veya yönlendirme sağlanmadan kaldırılmaz veya taşınmaz. Ayrıca bu dosyalar
  hiçbir zaman değiştirilmez ve her zaman orijinal  sağlama toplamı ile eşleşmelidirler. Buradaki tek istisna,
  olduğu gibi bırakıldığında yarardan çok zarar verme potansiyeli olan bozuk veya kullanılamaz dosyalar için geçerlidir.
- Dosyalar hem HTTP hem de HTTPS protokolleri üzerinden sunulur. Dosya listesini güvenli bir şekilde aldığınız (git, HTTPS,
  IPFS aracılığıyla veya yerel olarak önbelleğe aldığınız) ve indirdikten sonra ikili sayı sistemi dosyalarının hash'lerini
  doğruladığınız sürece, ikili dosyalar için HTTPS protokolünü kullanmanız gerekmez.

Aynı ikili sayı sistemi dosyaları genellikle `Github üzerindeki Solidity sürüm sayfası`_ nda bulunmaktadır.
Aradaki fark, Github sürüm sayfasındaki eski sürümleri genellikle güncellemiyor olmamızdır. Bu, adlandırma
kuralı değişirse onları yeniden adlandırmadığımız ve yayınlandığı sırada desteklenmeyen platformlar için
derlemeler eklemediğimiz anlamına gelir. Bu sadece ``solc-bin`` içinde gerçekleşir.

``solc-bin`` deposu, her biri tek bir platformu temsil eden birkaç üst düzey dizin içerir. Her biri mevcut
ikili sayı sistemi dosyalarını listeleyen bir ``list.json`` dosyası içerir. Örneğin ``emscripten-wasm32/list.json``
dosyasında bulunan 0.7.4 sürümü hakkındaki bilgileri aşağıda bulabilirsiniz:

.. code-block:: json

    {
      "path": "solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js",
      "version": "0.7.4",
      "build": "commit.3f05b770",
      "longVersion": "0.7.4+commit.3f05b770",
      "keccak256": "0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3",
      "sha256": "0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2",
      "urls": [
        "bzzr://16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1",
        "dweb:/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS"
      ]
    }

Bu şu anlama gelmektedir:

- Binary dosyasını aynı dizinde `solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js <https://github.com/ethereum/solc-bin/blob/gh-pages/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js>`_
  adı altında bulabilirsiniz.  Dosyanın bir kısayol bağlantısı olabileceğini ve dosyayı indirmek için
  eğer git kullanmıyorsanız veya dosya sisteminiz kısayol bağlantılarını desteklemiyorsa bu dosyayı
  kendiniz çözümlemeniz gerekebileceğini unutmayın.
- Binary dosyası ayrıca https://binaries.soliditylang.org/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js
  adresine de yansıtılır. Bu durumda git kullanımı gerekli değildir ve kısayol bağlantıları
  ya dosyanın bir kopyasını sunarak ya da bir HTTP yönlendirmesi döndürerek dosyanın şeffaf
  bir şekilde çözümlenmesini sağlar.
- Dosya ayrıca IPFS üzerinde `QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS`_ adresinde de mevcuttur.
- Dosya, gelecekte Swarm’da bulunan `16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1`_ adresinde mevcut olabilir.
- Binary'nin bütünlüğünü keccak256 hash değerini ``0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3``
  ile karşılaştırarak da doğrulayabilirsiniz.  Hash, komut satırında `sha3sum`_ tarafından sağlanan
  ``keccak256sum`` yardımcı programı veya JavaScript’te `ethereumjs-util'de bulunan keccak256()`_ fonksiyonu
  kullanılarak da hesaplanabilir.
- Binary'nin bütünlüğünü sha256 hash değerini ``0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2`` ile karşılaştırarak da doğrulayabilirsiniz.

.. warning::

   Güçlü bir şekilde geriye dönük uyumluluk gereksinimi sebebiyle depo bazı eski öğeler içerir, ancak
   yeni araçlar yazarken bunları kullanmaktan kaçınmalısınız:

   - En iyi performansı istiyorsanız ``bin/`` yerine ``emscripten-wasm32/`` son çare (fallback) (``emscripten-asmjs/`` geri
     dönüşü ile) kullanın. Biz 0.6.1 sürümüne kadar sadece asm.js ikili sayı sistemi dosyalarını sağlamıştık.
     0.6.2`den itibaren çok daha iyi performans sağlayan `WebAssembly derlemeleri`_ne geçtik. Eski sürümleri
     wasm için yeniden oluşturduk ancak orijinal asm.js dosyaları ``bin/`` içinde kaldı. Çünkü isim çakışmalarını
     önlemek amacıyla yenilerinin ayrı bir dizine yerleştirilmesi gerekiyordu.
   - Bir wasm veya asm.js ikili sayı sistemi dosyasını indirdiğinizden emin olmak istiyorsanız ``bin/``
     ve ``wasm/`` dizinleri yerine ``emscripten-asmjs/`` ve ``emscripten-wasm32/`` dizinlerini kullanın.
   - ``list.js`` ve ``list.txt`` yerine ``list.json`` kullanın. JSON liste formatı eskilerde bulunan
     tüm bilgileri ve daha fazlasını içerir.
   - https://solc-bin.ethereum.org yerine https://binaries.soliditylang.org kullanın. İşleri basit tutmak
     için derleyiciyle ilgili neredeyse her şeyi yeni ``soliditylang.org`` alan adı altına taşıdık ve bu durum
     ``solc-bin`` için de geçerlidir. Yeni alan adı önerilse de, eski alan adı hala tam olarak
     desteklenmekte ve aynı konuma işaret etmesi garanti edilmektedir.

.. warning::

    Binary dosyaları https://ethereum.github.io/solc-bin/ adresinde de mevcuttur, fakat
    bu sayfanın güncellenmesi 0.7.2 sürümünün yayınlanmasından hemen sonra durdurulmuştur. Aynı
    zamanda bu adres herhangi bir platform için yeni sürümler veya nightly yapılar almayacak ve
    emscripten olmayan yapılar da dahil olmak üzere yeni dizin yapısını sunmayacaktır.

    Eğer hala bu adresi kullanıyorsanız, lütfen bunun yerine  https://binaries.soliditylang.org
    adresine kullanmaya devam edin. Bu, temeldeki barındırma hizmeti(hosting) üzerinde şeffaf bir şekilde
    değişiklik yapmamıza ve kesintiyi en aza indirmemize olanak tanır. Herhangi bir kontrole sahip
    olmadığımız ``ethereum.github.io`` alan adının aksine, ``binaries.soliditylang.org`` alan adının
    uzun vadede aynı URL yapısını koruyacağını ve çalışacağını garanti ediyoruz.

.. _IPFS: https://ipfs.io
.. _Swarm: https://swarm-gateways.net/bzz:/swarm.eth
.. _solc-bin: https://github.com/ethereum/solc-bin/
.. _Github üzerindeki Solidity sürüm sayfası: https://github.com/ethereum/solidity/releases
.. _sha3sum: https://github.com/maandree/sha3sum
.. _ethereumjs-util'de bulunan keccak256(): https://github.com/ethereumjs/ethereumjs-util/blob/master/docs/modules/_hash_.md#const-keccak256
.. _WebAssembly derlemeleri: https://emscripten.org/docs/compiling/WebAssembly.html
.. _QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS: https://gateway.ipfs.io/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS
.. _16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1: https://swarm-gateways.net/bzz:/16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1/

.. _building-from-source:

Kaynağından Kurulum
====================

Ön Koşullar - Tüm İşletim Sistemleri
-------------------------------------

Aşağıda Solidity'nin tüm geliştirmeleri için bağımlılıklar verilmiştir:

+-----------------------------------+-------------------------------------------------------+
| Yazılım                           | Notlar                                                |
+===================================+=======================================================+
| `CMake`_ (sürüm 3.13+)            | Platformlar arası derleme dosyası oluşturucusu.       |
+-----------------------------------+-------------------------------------------------------+
| `Boost`_ (Windows 'ta 1.77+       | C++ kütüphaneleri.                                    |
| sürümü, aksi takdirde 1.65+)      |                                                       |
+-----------------------------------+-------------------------------------------------------+
| `Git`_                            | Kaynak kodu almak için komut satırı aracı.            |
+-----------------------------------+-------------------------------------------------------+
| `z3`_ (sürüm 4.8+, Opsiyonel)     | SMT denetleyicisi ile kullanım için.                  |
+-----------------------------------+-------------------------------------------------------+
| `cvc4`_ (Opsiyonel)               | SMT denetleyicisi ile kullanım için.                  |
+-----------------------------------+-------------------------------------------------------+

.. _cvc4: https://cvc4.cs.stanford.edu/web/
.. _Git: https://git-scm.com/download
.. _Boost: https://www.boost.org
.. _CMake: https://cmake.org/download/
.. _z3: https://github.com/Z3Prover/z3

.. note::
    Solidity'nin 0.5.10'dan önceki sürümleri Boost'un 1.70+ olan sürümlerine doğru bir şekilde
    bağlanamayabilir. Olası bir geçici çözüm, solidity'yi yapılandırmak için cmake komutunu çalıştırmadan
    önce ``<Boost yükleme yolu>/lib/cmake/Boost-1.70.0`` adını geçici olarak yeniden adlandırmaktır.

    0.5.10'dan başlayarak Boost 1.70+ kadar olan sürümlerle bağlantı kurmak(linking) manuel müdahale olmadan çalışmalıdır.

.. note::
    Varsayılan derleme yapılandırması belirli bir Z3 sürümü (kodun en son güncellendiği zamandaki en son sürüm)
    gerektirir. Z3 sürümleri arasında yapılan değişiklikler genellikle biraz farklı (ancak yine de geçerli olan)
    sonuçların döndürülmesine neden olur. SMT testlerimiz bu farklılıkları hesaba katmaz ve muhtemelen yazıldıkları
    sürümden farklı olan bir sürümde başarısız olacaklardır. Bu, farklı bir sürüm kullanan bir derlemenin hatalı
    olduğu anlamına gelmez. CMake'e ``-DSTRICT_Z3_VERSION=OFF`` seçeneğini iletirseniz, yukarıdaki tabloda verilen
    gereksinimi karşılayan herhangi bir sürümle derleme yapabilirsiniz. Ancak bunu yaparsanız, SMT testlerini atlamak
    için lütfen ``scripts/tests.sh`` dosyasına ``--no-smt`` seçeneğini de eklemeyi unutmayın.

Minimum Derleyici Sürümleri
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Aşağıdaki C++ derleyicileri ve minimum sürümleri Solidity kod tabanını derleyebilir:

- `GCC <https://gcc.gnu.org>`_, version 8+
- `Clang <https://clang.llvm.org/>`_, version 7+
- `MSVC <https://visualstudio.microsoft.com/vs/>`_, version 2019+

Ön Koşullar - macOS
---------------------

macOS derlemeleri için, `Xcode`un en son sürümünün <https://developer.apple.com/xcode/download/>`_
yüklü olduğundan emin olun. Bu, `Clang C++ derleyicisi <https://en.wikipedia.org/wiki/Clang>`_,
`Xcode IDE <https://en.wikipedia.org/wiki/Xcode>`_ ve OS X üzerinde C++ uygulamaları oluşturmak
için gerekli olan diğer Apple geliştirme araçlarını içerir.
Xcode'u ilk kez yüklüyorsanız veya yeni bir sürüm yüklediyseniz, komut satırı derlemeleri yapmadan
önce lisansı kabul etmeniz gerekecektir:

.. code-block:: bash

    sudo xcodebuild -license accept

OS X derleme betiğimiz, harici bağımlılıkları yüklemek için `Homebrew
<https://brew.sh>`_ paket yöneticisini kullanır. Eğer sıfırdan başlamak
isterseniz, Homebrew <https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew>`_'i
nasıl kaldıracağınız aşağıda açıklanmıştır.

Ön Koşullar - Windows
-----------------------

Solidity'nin Windows derlemeleri için aşağıdaki bağımlılıkları yüklemeniz gerekir:

+-----------------------------------+-------------------------------------------------------+
| Yazılım                           | Notlar                                                |
+===================================+=======================================================+
| `Visual Studio 2019 Build Tools`_ | C++ derleyicisi                                       |
+-----------------------------------+-------------------------------------------------------+
| `Visual Studio 2019`_ (Opsiyonel) | C++ derleyicisi ve geliştirme ortamı                  |
+-----------------------------------+-------------------------------------------------------+
| `Boost`_ (sürüm 1.77+)            | C++ kütüphaneleri.                                    |
+-----------------------------------+-------------------------------------------------------+

Eğer zaten bir IDE'niz varsa ve yalnızca derleyici ve kütüphanelere ihtiyaç duyuyorsanız,
Visual Studio 2019 Build Tools'u yükleyebilirsiniz.

Visual Studio 2019 hem IDE hem de gerekli derleyici ve kütüphaneleri sağlar.
Dolayısıyla, bir IDE'niz yoksa ve Solidity geliştirmeyi tercih ediyorsanız,
Visual Studio 2019 her şeyi kolayca kurmanız için iyi bir tercih olabilir.

Visual Studio 2019 Build Tools veya Visual Studio 2019'da yüklenmesi
gereken bileşenlerin listesi aşağıda verilmiştir:

* Visual Studio C++ core features
* VC++ 2019 v141 toolset (x86,x64)
* Windows Universal CRT SDK
* Windows 8.1 SDK
* C++/CLI support

.. _Visual Studio 2019: https://www.visualstudio.com/vs/
.. _Visual Studio 2019 Build Tools: https://www.visualstudio.com/downloads/#build-tools-for-visual-studio-2019

Gerekli tüm harici bağımlılıkları yüklemek için kullanabileceğiniz bir yardımcı betiğimiz var:

.. code-block:: bat

    scripts\install_deps.ps1

Bu ``boost`` ve ``cmake``'i ``deps`` alt dizinine yükleyecektir.

Depoyu Klonlamak
--------------------

Kaynak kodunu klonlamak için aşağıdaki komutu çalıştırın:

.. code-block:: bash

    git clone --recursive https://github.com/ethereum/solidity.git
    cd solidity

Solidity'nin geliştirilmesine yardımcı olmak istiyorsanız,
Solidity'yi çatallamalı(fork) ve kişisel çatalınızı(fork) ikinci bir remote olarak eklemelisiniz:

.. code-block:: bash

    git remote add personal git@github.com:[username]/solidity.git

.. note::
    Bu yöntem, örneğin böyle bir derleyici tarafından üretilen her bayt kodunda bir bayrağın
    ayarlanmasına yol açan bir ön sürüm derlemesiyle sonuçlanacaktır. Yayınlanmış bir Solidity
    derleyicisini yeniden derlemek istiyorsanız, lütfen github sürüm sayfasındaki kaynak tarball'u kullanın:

    https://github.com/ethereum/solidity/releases/download/v0.X.Y/solidity_0.X.Y.tar.gz

    (github tarafından sağlanan "Kaynak kodu" değil).

Komut Satırı Kullanarak Derlemek
----------------------------------

**Derlemeden önce Harici Bağımlılıkları(yukarıda bulunan) yüklediğinizden emin olun.**

Solidity projesi derlemeyi yapılandırmak için CMake kullanır.
Tekrarlanan derlemeleri hızlandırmak için `ccache`_ yüklemek isteyebilirsiniz.
CMake bunu otomatik olarak alacaktır. Solidity'yi derlemek Linux,
macOS ve diğer Unix'lerde de oldukça benzerdir:

.. _ccache: https://ccache.dev/

.. code-block:: bash

    mkdir build
    cd build
    cmake .. && make

veya Linux ve macOS'ta daha da kolay çalıştırabilirsiniz:

.. code-block:: bash

    #note: this will install binaries solc and soltest at usr/local/bin
    ./scripts/build.sh

.. warning::

    BSD derlemeleri çalışmalıdır, fakat Solidity ekibi tarafından test edilmemiştir.

Ve Windows İçin:

.. code-block:: bash

    mkdir build
    cd build
    cmake -G "Visual Studio 16 2019" ..

Eğer ``scripts\install_deps.ps1`` tarafından yüklenen boost sürümünü kullanmak isterseniz,
``-DBoost_DIR="deps\boost\lib\cmake\Boost-*"`` ve ``-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded``
seçeneklerini ``cmake`` çağrısına argüman olarak iletmeniz gerekecektir.

Bunun sonucunda bu yapı dizininde **solidity.sln** dosyası oluşturulmalıdır. Ayrıca
bu dosyaya çift tıklandığında Visual Studio nun açılması gerekir. Biz **Yayın**
yapılandırmasını oluşturmanızı öneririz, ancak diğerleri de çalışır.

Alternatif olarak, Windows için komut satırında aşağıdaki gibi bir derleme de yapabilirsiniz:

.. code-block:: bash

    cmake --build . --config Release

CMake Ayarları
===============

CMake ayarlarının ne olduğunu merak ediyorsanız ``cmake .. -LH`` komutunu çalıştırın.

.. _smt_solvers_build:

SMT Çözücüleri
---------------
Solidity, SMT çözücülerine karşı derlenebilir ve sistemde bulunurlarsa default(varsayılan)
olarak bunu yapacaklardır. Her çözücü bir `cmake` seçeneği ile devre dışı bırakılabilir.

*Not: Bazı durumlarda bu, derleme hataları için potansiyel olarak geçici bir çözüm de olabilir.*


Yapı klasörünün içinde bunları devre dışı bırakabilirsiniz, çünkü varsayılan olarak etkin durumdadırlar:

.. code-block:: bash

    # disables only Z3 SMT Solver.
    cmake .. -DUSE_Z3=OFF

    # disables only CVC4 SMT Solver.
    cmake .. -DUSE_CVC4=OFF

    # disables both Z3 and CVC4
    cmake .. -DUSE_CVC4=OFF -DUSE_Z3=OFF

Sürüm Dizgisi (String) Detayları
=================================

Solidity sürüm dizgisi dört bölümden oluşur:

- Sürüm numarası
- Sürüm öncesi etiketi (genellikle develop.YYYY.MM.DD veya night..YYYY.MM.DD olarak ayarlanır)
- ``commit.GITHASH`` biçiminde ilgili commit
- Platform ve derleyici ile ilgili ayrıntıları içeren, rasgele sayıda öğeye sahip platform

Yerel değişiklikler varsa commit'in sonuna ``.mod`` diye eklenir.

Tüm değişiklikler, Semver'in gerektirdiği şekilde, Solidity yayınlanma öncesi sürümün Semver yayınlanma
öncesi sürümüne eşit olduğu ve Solidity'de bir işlem yapıldığında Semver'deki meta verilerinin de değiştiği
bir şekilde gerçekleşir.

Bir yayın örneği: ``0.4.8+commit.60cc1668.Emscripten.clang``.

Bir ön yayın örneği: ``0.4.9-nightly.2017.1.17+commit.6ecb4aa3.Emscripten.clang``

Sürümleme Hakkında Önemli Bilgi
======================================

Bir sürüm yapıldıktan sonra, yama sürüm seviyesi yükseltilir, çünkü sadece yama
seviyesindeki değişikliklerin takip edildiğini varsayıyoruz. Değişiklikler birleştirildiğinde
(merge) , SemVer'e ve değişikliğin ciddiyetine göre sürüm yükseltilmelidir. Son olarak, bir
sürüm her zaman mevcut nightly derlemenin sürümüyle, ancak ``prerelease`` belirteci olmadan yapılır.

Örnek:

1. 0.4.0 sürümü çıktı.
2. Nightly yapı şu andan itibaren 0.4.1 sürümüne sahiptir.
3. İşleyişi bozmayan değişikliler tanıtıldı --> sürümde değişiklik yok.
4. İşleyişi bozan değişiklikler tanıtıldı --> version 0.5.0'a yükseltildi.
5. 0.5.0 sürümü çıktı.

Bu davranış :ref:`version pragma <version_pragma>` ile iyi çalışır.
