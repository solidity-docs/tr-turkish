.. index:: ! installing

.. _installing-solidity:

################################
Solidity Derleyicisini İndirme
################################

Sürüm
==========

Solidity versiyonları `Semantic Versiyonlamayı <https://semver.org>`_ takip eder. Ek
olarak, ana sürüm 0'a (yani 0.x.y) sahip yama düzeyindeki sürümler, kırılma değişiklikleri(breaking changes)
içermeyecektir. Bu, 0.x.y sürümü ile derlenen kodun z > y olduğu durumlarda 0.x.z ile derlenmesinin umulabileceği anlamına gelir.

Sürümlere ek olarak, geliştiricilerin gelecek özellikleri denemelerini ve erken
geri bildirim sağlamalarını kolaylaştırmak amacıyla **gece geliştirme yapıları**
(Nightly Development Builds diye de bilinir) sağlıyoruz. Bununla birlikte, gecelik
yapılar genellikle çok kararlı olsalar da, geliştirme kolundaki (branch) en yeni
kodları içerdiklerini ve her zaman çalışacaklarının garanti edilmediğini unutmayın.
Tüm emeklerimize karşın, hala gerçek sürümün bir parçası olmayacak belgelenmemiş
ve/veya arızalı değişiklikler içerebilirler. Bunlar üretim amaçlı kullanım için uygun değillerdir.

Sözleşmelerin gönderimini yaparken Solidity'nin yayınlanan en son sürümünü kullanmalısınız. Bunun nedeni,
kırılma değişikliklerinin yanı sıra yeni özelliklerin tanıtılması ve eski sürümlerdeki hataların düzenli
olarak düzeltilmesinden kaynaklanmaktadır. Bu `hızlı versiyon değişiklilerini belirtmek için <https://semver.org/#spec-item-4>`_
şu anda 0.x sürüm numarası kullanıyoruz.

Remix
=====

*Solidity'i hızlı bir şekilde öğrenmeniz ve küçük akıllı sözleşmeleriniz için Remix'i kullanmanızı tavsiye ediyoruz.*

`Remix'i online bir şekilde kullanabilirsiniz <https://remix.ethereum.org/>`_, bunun için herhangi bir şey indirmenize gerek yoktur.
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
açıklanacak olan derleyiciye erişim yollarından daha az özelliğe sahiptir. The
:ref:`commandline-compiler` documentation assumes you are using
the full-featured compiler, ``solc``.ref:`commandline-compiler`(komut satırı derleyicisi) belgeleri
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

    ``solcjs`` komut satırı seçenekleri ``solc`` ile uyumlu değildir. Ve aynı zamanda çalışmak için ``solc``’un davranışını
    bekleyen araçlar (örneğin ``geth`` gibi) ``solcjs`` ile çalışmayacaktır.

Docker
======

Solidity yapılarında bulunan Docker imajları, ``ethereum`` kuruluşundaki ``solc`` imajlarını da kullanarak elde edilebilir.
Yayınlanan en son sürüm için ``stable`` etiketini ve geliştirme kolundaki (branch) potansiyel olarak kararsız değişiklikler
için ``nightly`` etiketini kullanabilirsiniz.

Docker imajı derleyicinin yürütülebilir dosyasını çalıştırır, bu sayede tüm derleyici bağımsız değişkenlerini ona iletebilirsiniz.
Örneğin, aşağıdaki komut ``solc`` imajının kararlı bir sürümünü çeker (zaten sahip değilseniz) ve ``--help`` parametresini ileterek
yeni bir konteynerde çalıştırır.

.. code-block:: bash

    docker run ethereum/solc:stable --help

Etikette, örneğin 0.5.4 sürümü için oluşturulmuş derleme sürümlerini de belirtebilirsiniz.

.. code-block:: bash

    docker run ethereum/solc:0.5.4 --help

Docker imajını kullanarak Solidity dosyalarını ana makinede derlemek istiyorsanız,
girdi ve çıktı için yerel bir klasör bağladıktan sonra derlenecek olan sözleşmeyi belirtin. Örnek vermek gerekirse:

.. code-block:: bash

    docker run -v /local/path:/sources ethereum/solc:stable -o /sources/output --abi --bin /sources/Contract.sol

Ayrıca standart bir JSON arayüzünü de kullanabilirsiniz (derleyiciyi araçlarıyla birlikte kullanırken tavsiye edilir).
Bu arayüzü kullanırken, JSON girdisi bağımsız olduğu sürece herhangi bir dizini bağlamak gerekli değildir
(yani :ref:`içeri aktarılan(import) geri çağrısı (callback) <initial-vfs-content-standard-json-with-import-callback>`
tarafından yüklenmesi gereken herhangi bir harici dosyaya referans göstermez).

.. code-block:: bash

    docker run ethereum/solc:stable --standard-json < input.json > output.json

Linux Packages
==============

Solidity'nin ikili sayı sistemi (binary) paketleri `solidity/releases <https://github.com/ethereum/solidity/releases>`_ adresinde mevcuttur.

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
bakımını doğrudan bizim tarafımızdan yapılmamaktadır. Ama bu konuda endişelenmenize gerek
yoktur, çünkü bu paketler genellikle ilgili paket sorumluları tarafından güncel tutulmaktadır.

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
==============

Solidity derleyicisini, kaynaktan oluşturulmuş bir sürüm olarak Homebrew aracılığıyla
dağıtıyoruz. Önceden oluşturulmuş olan “bottles"lar(ikili sayı sistemi(binary) paketleri)
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

İstediğiniz bir sürümün commit hash'ini kopyalayıp ve kendi makinenizde kontrol edebilirsiniz.

.. code-block:: bash

    git clone https://github.com/ethereum/homebrew-ethereum.git
    cd homebrew-ethereum
    git checkout <your-hash-goes-here>

Bunu ``brew`` kullanarak yükleyin:

.. code-block:: bash

    brew unlink solidity
    # eg. Install 0.4.8
    brew install solidity.rb

Statik İkili Sayı Sistemleri
============================

Desteklenen tüm platformlar için geçmiş ve güncel derleyici sürümlerinin statik yapılarını içeren
bir depoyu `solc-bin`_ adresinde tutuyoruz. Bu adreste aynı zamanda gecelik yapıları da bulabilirsiniz.

Bu depo, son kullanıcıların ikili dosya sistemlerini kullanıma hazır hale getirmeleri için hızlı ve kolay bir yol
olmasının yanı sıra üçüncü taraf araçlarla da dost olmayı (kolay bir şekilde etkileşimde bulunmayı) amaçlamaktadır:

- https://binaries.soliditylang.org adresine yansıtılan bu içerik herhangi bir kimlik doğrulama, hız
  sınırlaması veya git kullanma ihtiyacı olmadan HTTPS üzerinden kolayca indirilebilir.
- Content is served with correct `Content-Type` headers and lenient CORS configuration so that it
  can be directly loaded by tools running in the browser.
- Binaries do not require installation or unpacking (with the exception of older Windows builds
  bundled with necessary DLLs).
- We strive for a high level of backwards-compatibility. Files, once added, are not removed or moved
  without providing a symlink/redirect at the old location. They are also never modified
  in place and should always match the original checksum. The only exception would be broken or
  unusable files with a potential to cause more harm than good if left as is.
- Files are served over both HTTP and HTTPS. As long as you obtain the file list in a secure way
  (via git, HTTPS, IPFS or just have it cached locally) and verify hashes of the binaries
  after downloading them, you do not have to use HTTPS for the binaries themselves.

The same binaries are in most cases available on the `Solidity release page on Github`_. The
difference is that we do not generally update old releases on the Github release page. This means
that we do not rename them if the naming convention changes and we do not add builds for platforms
that were not supported at the time of release. This only happens in ``solc-bin``.

The ``solc-bin`` repository contains several top-level directories, each representing a single platform.
Each one contains a ``list.json`` file listing the available binaries. For example in
``emscripten-wasm32/list.json`` you will find the following information about version 0.7.4:

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

This means that:

- You can find the binary in the same directory under the name
  `solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js <https://github.com/ethereum/solc-bin/blob/gh-pages/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js>`_.
  Note that the file might be a symlink, and you will need to resolve it yourself if you are not using
  git to download it or your file system does not support symlinks.
- The binary is also mirrored at https://binaries.soliditylang.org/emscripten-wasm32/solc-emscripten-wasm32-v0.7.4+commit.3f05b770.js.
  In this case git is not necessary and symlinks are resolved transparently, either by serving a copy
  of the file or returning a HTTP redirect.
- The file is also available on IPFS at `QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS`_.
- The file might in future be available on Swarm at `16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1`_.
- You can verify the integrity of the binary by comparing its keccak256 hash to
  ``0x300330ecd127756b824aa13e843cb1f43c473cb22eaf3750d5fb9c99279af8c3``.  The hash can be computed
  on the command line using ``keccak256sum`` utility provided by `sha3sum`_ or `keccak256() function
  from ethereumjs-util`_ in JavaScript.
- You can also verify the integrity of the binary by comparing its sha256 hash to
  ``0x2b55ed5fec4d9625b6c7b3ab1abd2b7fb7dd2a9c68543bf0323db2c7e2d55af2``.

.. warning::

   Due to the strong backwards compatibility requirement the repository contains some legacy elements
   but you should avoid using them when writing new tools:

   - Use ``emscripten-wasm32/`` (with a fallback to ``emscripten-asmjs/``) instead of ``bin/`` if
     you want the best performance. Until version 0.6.1 we only provided asm.js binaries.
     Starting with 0.6.2 we switched to `WebAssembly builds`_ with much better performance. We have
     rebuilt the older versions for wasm but the original asm.js files remain in ``bin/``.
     The new ones had to be placed in a separate directory to avoid name clashes.
   - Use ``emscripten-asmjs/`` and ``emscripten-wasm32/`` instead of ``bin/`` and ``wasm/`` directories
     if you want to be sure whether you are downloading a wasm or an asm.js binary.
   - Use ``list.json`` instead of ``list.js`` and ``list.txt``. The JSON list format contains all
     the information from the old ones and more.
   - Use https://binaries.soliditylang.org instead of https://solc-bin.ethereum.org. To keep things
     simple we moved almost everything related to the compiler under the new ``soliditylang.org``
     domain and this applies to ``solc-bin`` too. While the new domain is recommended, the old one
     is still fully supported and guaranteed to point at the same location.

.. warning::

    The binaries are also available at https://ethereum.github.io/solc-bin/ but this page
    stopped being updated just after the release of version 0.7.2, will not receive any new releases
    or nightly builds for any platform and does not serve the new directory structure, including
    non-emscripten builds.

    If you are using it, please switch to https://binaries.soliditylang.org, which is a drop-in
    replacement. This allows us to make changes to the underlying hosting in a transparent way and
    minimize disruption. Unlike the ``ethereum.github.io`` domain, which we do not have any control
    over, ``binaries.soliditylang.org`` is guaranteed to work and maintain the same URL structure
    in the long-term.

.. _IPFS: https://ipfs.io
.. _Swarm: https://swarm-gateways.net/bzz:/swarm.eth
.. _solc-bin: https://github.com/ethereum/solc-bin/
.. _Solidity release page on github: https://github.com/ethereum/solidity/releases
.. _sha3sum: https://github.com/maandree/sha3sum
.. _keccak256() function from ethereumjs-util: https://github.com/ethereumjs/ethereumjs-util/blob/master/docs/modules/_hash_.md#const-keccak256
.. _WebAssembly builds: https://emscripten.org/docs/compiling/WebAssembly.html
.. _QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS: https://gateway.ipfs.io/ipfs/QmTLs5MuLEWXQkths41HiACoXDiH8zxyqBHGFDRSzVE5CS
.. _16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1: https://swarm-gateways.net/bzz:/16c5f09109c793db99fe35f037c6092b061bd39260ee7a677c8a97f18c955ab1/

.. _building-from-source:

Building from Source
====================

Prerequisites - All Operating Systems
-------------------------------------

The following are dependencies for all builds of Solidity:

+-----------------------------------+-------------------------------------------------------+
| Software                          | Notes                                                 |
+===================================+=======================================================+
| `CMake`_ (version 3.13+)          | Cross-platform build file generator.                  |
+-----------------------------------+-------------------------------------------------------+
| `Boost`_ (version 1.77+ on        | C++ libraries.                                        |
| Windows, 1.65+ otherwise)         |                                                       |
+-----------------------------------+-------------------------------------------------------+
| `Git`_                            | Command-line tool for retrieving source code.         |
+-----------------------------------+-------------------------------------------------------+
| `z3`_ (version 4.8+, Optional)    | For use with SMT checker.                             |
+-----------------------------------+-------------------------------------------------------+
| `cvc4`_ (Optional)                | For use with SMT checker.                             |
+-----------------------------------+-------------------------------------------------------+

.. _cvc4: https://cvc4.cs.stanford.edu/web/
.. _Git: https://git-scm.com/download
.. _Boost: https://www.boost.org
.. _CMake: https://cmake.org/download/
.. _z3: https://github.com/Z3Prover/z3

.. note::
    Solidity versions prior to 0.5.10 can fail to correctly link against Boost versions 1.70+.
    A possible workaround is to temporarily rename ``<Boost install path>/lib/cmake/Boost-1.70.0``
    prior to running the cmake command to configure solidity.

    Starting from 0.5.10 linking against Boost 1.70+ should work without manual intervention.

.. note::
    The default build configuration requires a specific Z3 version (the latest one at the time the
    code was last updated). Changes introduced between Z3 releases often result in slightly different
    (but still valid) results being returned. Our SMT tests do not account for these differences and
    will likely fail with a different version than the one they were written for. This does not mean
    that a build using a different version is faulty. If you pass ``-DSTRICT_Z3_VERSION=OFF`` option
    to CMake, you can build with any version that satisfies the requirement given in the table above.
    If you do this, however, please remember to pass the ``--no-smt`` option to ``scripts/tests.sh``
    to skip the SMT tests.

Minimum Compiler Versions
^^^^^^^^^^^^^^^^^^^^^^^^^

The following C++ compilers and their minimum versions can build the Solidity codebase:

- `GCC <https://gcc.gnu.org>`_, version 8+
- `Clang <https://clang.llvm.org/>`_, version 7+
- `MSVC <https://visualstudio.microsoft.com/vs/>`_, version 2019+

Prerequisites - macOS
---------------------

For macOS builds, ensure that you have the latest version of
`Xcode installed <https://developer.apple.com/xcode/download/>`_.
This contains the `Clang C++ compiler <https://en.wikipedia.org/wiki/Clang>`_, the
`Xcode IDE <https://en.wikipedia.org/wiki/Xcode>`_ and other Apple development
tools that are required for building C++ applications on OS X.
If you are installing Xcode for the first time, or have just installed a new
version then you will need to agree to the license before you can do
command-line builds:

.. code-block:: bash

    sudo xcodebuild -license accept

Our OS X build script uses `the Homebrew <https://brew.sh>`_
package manager for installing external dependencies.
Here's how to `uninstall Homebrew
<https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew>`_,
if you ever want to start again from scratch.

Prerequisites - Windows
-----------------------

You need to install the following dependencies for Windows builds of Solidity:

+-----------------------------------+-------------------------------------------------------+
| Software                          | Notes                                                 |
+===================================+=======================================================+
| `Visual Studio 2019 Build Tools`_ | C++ compiler                                          |
+-----------------------------------+-------------------------------------------------------+
| `Visual Studio 2019`_  (Optional) | C++ compiler and dev environment.                     |
+-----------------------------------+-------------------------------------------------------+
| `Boost`_ (version 1.77+)          | C++ libraries.                                        |
+-----------------------------------+-------------------------------------------------------+

If you already have one IDE and only need the compiler and libraries,
you could install Visual Studio 2019 Build Tools.

Visual Studio 2019 provides both IDE and necessary compiler and libraries.
So if you have not got an IDE and prefer to develop Solidity, Visual Studio 2019
may be a choice for you to get everything setup easily.

Here is the list of components that should be installed
in Visual Studio 2019 Build Tools or Visual Studio 2019:

* Visual Studio C++ core features
* VC++ 2019 v141 toolset (x86,x64)
* Windows Universal CRT SDK
* Windows 8.1 SDK
* C++/CLI support

.. _Visual Studio 2019: https://www.visualstudio.com/vs/
.. _Visual Studio 2019 Build Tools: https://www.visualstudio.com/downloads/#build-tools-for-visual-studio-2019

We have a helper script which you can use to install all required external dependencies:

.. code-block:: bat

    scripts\install_deps.ps1

This will install ``boost`` and ``cmake`` to the ``deps`` subdirectory.

Clone the Repository
--------------------

To clone the source code, execute the following command:

.. code-block:: bash

    git clone --recursive https://github.com/ethereum/solidity.git
    cd solidity

If you want to help developing Solidity,
you should fork Solidity and add your personal fork as a second remote:

.. code-block:: bash

    git remote add personal git@github.com:[username]/solidity.git

.. note::
    This method will result in a prerelease build leading to e.g. a flag
    being set in each bytecode produced by such a compiler.
    If you want to re-build a released Solidity compiler, then
    please use the source tarball on the github release page:

    https://github.com/ethereum/solidity/releases/download/v0.X.Y/solidity_0.X.Y.tar.gz

    (not the "Source code" provided by github).

Command-Line Build
------------------

**Be sure to install External Dependencies (see above) before build.**

Solidity project uses CMake to configure the build.
You might want to install `ccache`_ to speed up repeated builds.
CMake will pick it up automatically.
Building Solidity is quite similar on Linux, macOS and other Unices:

.. _ccache: https://ccache.dev/

.. code-block:: bash

    mkdir build
    cd build
    cmake .. && make

or even easier on Linux and macOS, you can run:

.. code-block:: bash

    #note: this will install binaries solc and soltest at usr/local/bin
    ./scripts/build.sh

.. warning::

    BSD builds should work, but are untested by the Solidity team.

And for Windows:

.. code-block:: bash

    mkdir build
    cd build
    cmake -G "Visual Studio 16 2019" ..

In case you want to use the version of boost installed by ``scripts\install_deps.ps1``, you will
additionally need to pass ``-DBoost_DIR="deps\boost\lib\cmake\Boost-*"`` and ``-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded``
as arguments to the call to ``cmake``.

This should result in the creation of **solidity.sln** in that build directory.
Double-clicking on that file should result in Visual Studio firing up.  We suggest building
**Release** configuration, but all others work.

Alternatively, you can build for Windows on the command-line, like so:

.. code-block:: bash

    cmake --build . --config Release

CMake Options
=============

If you are interested what CMake options are available run ``cmake .. -LH``.

.. _smt_solvers_build:

SMT Solvers
-----------
Solidity can be built against SMT solvers and will do so by default if
they are found in the system. Each solver can be disabled by a `cmake` option.

*Note: In some cases, this can also be a potential workaround for build failures.*


Inside the build folder you can disable them, since they are enabled by default:

.. code-block:: bash

    # disables only Z3 SMT Solver.
    cmake .. -DUSE_Z3=OFF

    # disables only CVC4 SMT Solver.
    cmake .. -DUSE_CVC4=OFF

    # disables both Z3 and CVC4
    cmake .. -DUSE_CVC4=OFF -DUSE_Z3=OFF

The Version String in Detail
============================

The Solidity version string contains four parts:

- the version number
- pre-release tag, usually set to ``develop.YYYY.MM.DD`` or ``nightly.YYYY.MM.DD``
- commit in the format of ``commit.GITHASH``
- platform, which has an arbitrary number of items, containing details about the platform and compiler

If there are local modifications, the commit will be postfixed with ``.mod``.

These parts are combined as required by SemVer, where the Solidity pre-release tag equals to the SemVer pre-release
and the Solidity commit and platform combined make up the SemVer build metadata.

A release example: ``0.4.8+commit.60cc1668.Emscripten.clang``.

A pre-release example: ``0.4.9-nightly.2017.1.17+commit.6ecb4aa3.Emscripten.clang``

Important Information About Versioning
======================================

After a release is made, the patch version level is bumped, because we assume that only
patch level changes follow. When changes are merged, the version should be bumped according
to SemVer and the severity of the change. Finally, a release is always made with the version
of the current nightly build, but without the ``prerelease`` specifier.

Example:

1. The 0.4.0 release is made.
2. The nightly build has a version of 0.4.1 from now on.
3. Non-breaking changes are introduced --> no change in version.
4. A breaking change is introduced --> version is bumped to 0.5.0.
5. The 0.5.0 release is made.

This behaviour works well with the  :ref:`version pragma <version_pragma>`.
