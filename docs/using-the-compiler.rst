***********************
Derleyicinin Kullanımı
***********************

.. index:: ! commandline compiler, compiler;commandline, ! solc

.. _commandline-compiler:

Komut Satırı Derleyicisinin Kullanımı
**************************************

.. note::
    Bu bölüm, komut satırı modunda kullanılsa bile :ref:`solcjs <solcjs>` için geçerli değildir.

Temel Kullanım
---------------

Solidity deposunun(repository) derleme kaynaklarından biri de Solidity komut satırı derleyicisi olan ``solc`` dur. ``solc --help`` komutunu kullanmak size tüm seçeneklerin açıklamalarını verir. Derleyici, soyut bir sözdizimi ağacı (parse tree) üzerinde basit binary ve assembly'den gaz kullanımı tahminlerine kadar çeşitli çıktılar üretebilir. Sadece tek bir dosyayı derlemek istiyorsanız, ``solc --bin sourceFile.sol`` şeklinde çalıştırdığınızda binary dosyayı yazdıracaktır. Eğer ``solc``un daha gelişmiş çıktı çeşitlerinden bazılarını elde etmek istiyorsanız, ``solc -o outputDirectory --bin --ast-compact-json --asm sourceFile.sol`` kullanarak her öğeyi ayrı dosyalara çıktı olarak vermesini söylemek muhtemelen daha iyi bir seçenek olacaktır.

Optimize Edici Seçenekleri
---------------------------

Sözleşmenizi deploy etmeden önce, ``solc --optimize --bin sourceFile.sol`` kullanarak
derleme yaparken optimize ediciyi etkinleştirmelisiniz. Standart olarak optimize edici,
sözleşmenin ömrü boyunca 200 kez çağrıldığını varsayarak sözleşmeyi optimize edecektir
(daha spesifik olarak, her bir işlem kodunun yaklaşık 200 kez çalıştırıldığını varsayar).
İlk sözleşme dağıtımının daha ucuz olmasını ve daha sonraki fonksiyon yürütmelerinin(executions)
daha pahalı olmasını istiyorsanız, ``--optimize-runs=1`` olarak ayarlayın. Çok sayıda
işlem bekliyorsanız ve daha yüksek dağıtım maliyeti ve çıktı boyutunu önemsemiyorsanız,
``--optimize-runs`` değerini yüksek bir sayıya ayarlayın. Bu parametrenin aşağıdaki
değerler üzerinde etkileri vardır (bu durum gelecekte değişebilir):

- fonksiyon gönderim prosedüründeki binary aramasının boyutu
- büyük sayılar veya dizeler gibi sabitlerin saklanma şekli

.. index:: allowed paths, --allow-paths, base path, --base-path, include paths, --include-path

Base Path ve Import Remapping
------------------------------

Komut satırı derleyicisi içe aktarılan dosyaları dosya sisteminden otomatik olarak
okuyacaktır, ancak aşağıdaki şekilde ``prefix=path`` kullanarak :ref:`path redirects <import-remapping>`
sağlamanız da mümkündür:

.. code-block:: bash

    solc github.com/ethereum/dapp-bin/=/usr/local/lib/dapp-bin/ file.sol

This essentially instructs the compiler to search for anything starting with
``github.com/ethereum/dapp-bin/`` under ``/usr/local/lib/dapp-bin``.

İçe aktarmaları aramak için dosya sistemine erişirken, :ref:` ./ veya ../ <direct-imports>`
ile başlamayan dizinler, ``--base-path`` ve ``--include-path`` seçenekleri kullanılarak
belirtilen dizinlere (veya temel yol belirtilmemişse geçerli çalışma dizinine) bağlı
olarak değerlendirilir. Ayrıca, dizinin bu seçenekler aracılığıyla eklenen kısmı
sözleşme metadatasında görünmeyecektir.

Güvenlik nedeniyle derleyicinin :ref:`hangi dizinlere erişebileceği konusunda kısıtlamaları
vardır <allowed-paths>`. Komut satırında belirtilen kaynak dosyaların dizinlerine ve
yeniden eşlemelerin hedef yollarına dosya okuyucu tarafından erişilmesine otomatik
olarak izin verilir, ancak diğer her şey varsayılan olarak reddedilir. İlave yollara
(ve bunların alt dizinlerine) ``--allow-paths /sample/path,/another/sample/path``
anahtarıyla izin verilebilir. ``--base-path`` ile belirtilen yol içindeki her şeye
her zaman izin verilir.

Yukarıda anlatılanlar, derleyicinin içe aktarma yollarını nasıl ele aldığının
basitleştirilmiş halidir. Örneklerle birlikte ayrıntılı bir açıklama ve uç noktaların
tartışılması için lütfen :ref:`path resolution <path-resolution>` bölümüne bakın.

.. index:: ! linker, ! --link, ! --libraries
.. _library-linking:

Kütüphane Bağlantıları (Library Linking)
-----------------------------------------

Sözleşmeleriniz :ref:`libraries <libraries>` kullanıyorsa, bytecode'un ``__$53aea86b7d70b31448b230b20ae141a537$__``
şeklinde alt dizeler içerdiğini fark edeceksiniz. Bunlar gerçek kütüphane adresleri
için yer tutuculardır. Yer tutucu, tam nitelikli kütüphane adının keccak256 hash'inin
hex encoding'inin 34 karakterlik bir önekidir. Bayt kodu dosyası, yer tutucuların
hangi kütüphaneleri temsil ettiğini belirlemeye yardımcı olmak için sonunda ``// <placeholder> -> <fq library name>``
şeklinde satırlar da içerecektir. Tam nitelikli kütüphane adının, kaynak dosyasının
yolu ve ``:`` ile ayrılmış kütüphane adı olduğunu unutmayın. Bir bağlayıcı olarak
``solc`` kullanabilirsiniz, yani bu noktalarda sizin için kütüphane adreslerini ekleyecektir:

Her kütüphane için bir adres sağlamak üzere komutunuza ``--libraries "file.sol:Math=0x123456789012345678901234567890 file.sol:Heap=0xabCD567890123456789012345678901234567890"`` ekleyin (ayırıcı olarak virgül veya boşluk kullanın) veya dizeyi bir dosyada saklayın (satır başına bir kütüphane) ve ``--libraries fileName`` kullanarak ``solc`` çalıştırın.

.. note::
    Solidity 0.8.1'den itibaren ``=`` kütüphane ve adres arasında ayırıcı olarak kabul etmektedir ve ``:`` ayırıcı olarak kullanımdan kaldırılmıştır. Gelecekte kaldırılacaktır. Şu anda ``-libraries "file.sol:Math:0x1234567890123456789012345678901234567890 file.sol:Heap:0xabCD567890123456789012345678901234567890"`` da çalışacaktır.

.. index:: --standard-json, --base-path

Eğer ``solc`` ``--standard-json`` seçeneği ile çağrılırsa, standart girişte bir JSON girdisi (aşağıda açıklandığı gibi) bekleyecek ve standart çıkışta bir JSON çıktısı döndürecektir. Bu, daha karmaşık ve özellikle otomatikleştirilmiş kullanımlar için önerilen arayüzdür. İşlem her zaman "başarılı" durumda sonlanacak ve hataları JSON çıktısı aracılığıyla bildirecektir. ``--base-path`` seçeneği de standart-json modunda işlenir.

Eğer ``solc`` ``--link`` seçeneği ile çağrılırsa, tüm girdi dosyaları yukarıda verilen ``__$53aea86b7d70b31448b230b20ae141a537$__``-formatında bağlanmamış binaryler (hex-encoded) olarak yorumlanır ve yerinde bağlanır (eğer girdi stdin`den okunuyorsa, stdout`a yazılır). Bu durumda ``--libraries`` dışındaki tüm seçenekler göz ardı edilir (``-o`` dahil).

.. warning::
    Sözleşme meta verilerini güncellemediğinden, oluşturulan bayt kodu üzerinde
    kütüphaneleri manuel olarak bağlamak önerilmez. Metadata derleme sırasında
    belirtilen kütüphanelerin bir listesini içerdiğinden ve bayt kodu bir metadata
    hash'i içerdiğinden, bağlama işleminin ne zaman yapıldığına bağlı olarak farklı
    binary dosyaları elde edersiniz.

    Derleyiciye standart-JSON arayüzünü kullanıyorsanız ``solc`` seçeneğinin ``--libraries``
    seçeneğini veya ``libraries`` anahtarını kullanarak bir sözleşme derlendiğinde
    derleyiciden kütüphaneleri bağlamasını istemelisiniz.

.. note::
    Kütüphane yer tutucusu eskiden kütüphanenin hash'i yerine kütüphanenin kendisinin
    tam nitelikli adı olurdu. Bu biçim hala ``solc --link`` tarafından desteklenmektedir
    ancak derleyici artık bu biçimin çıktısını vermeyecektir. Bu değişiklik, tam nitelikli
    kütüphane adının yalnızca ilk 36 karakteri kullanılabildiğinden, kütüphaneler arasında
    bir çakışma olasılığını azaltmak için yapılmıştır.

.. _evm-version:
.. index:: ! EVM version, compile target

EVM Sürümünün Hedefe Ayarlanması
*********************************

Sözleşme kodunuzu derlerken, belirli özelliklerden veya davranışlardan kaçınmak için
derlenecek Ethereum sanal makine sürümünü belirtebilirsiniz.

.. warning::

   Hatalı EVM sürümü için derleme yapmak yanlış, garip ve başarısız davranışlara
   neden olabilir. Lütfen, özellikle özel bir zincir çalıştırıyorsanız, uyumlu EVM
   sürümlerini kullandığınızdan emin olun.

Komut satırında, EVM sürümünü aşağıdaki gibi seçebilirsiniz:

.. code-block:: shell

  solc --evm-version <VERSION> contract.sol

ref:`standart JSON arayüzü <compiler-api>`de, ``"settings"`` alanında ``"evmVersion"``
anahtarını kullanın:

.. code-block:: javascript

    {
      "sources": {/* ... */},
      "settings": {
        "optimizer": {/* ... */},
        "evmVersion": "<VERSION>"
      }
    }

Hedef Seçenekleri
------------------

Aşağıda hedef EVM sürümlerinin bir listesi ve her sürümde derleyiciyle ilgili yapılan
değişiklikler yer almaktadır. Her sürüm arasında geriye dönük uyumluluk garanti edilmez.

- ``homestead``
   - (en eski sürüm)
- ``tangerineWhistle``
   - Gaz tahmini ve optimize edici ile ilgili diğer hesaplara erişim için gaz maliyeti arttı.
   - Harici aramalar için varsayılan olarak gönderilen tüm gaz. Daha önce belirli bir miktarın tutulması gerekiyordu.
- ``spuriousDragon``
   - Gaz tahmini ve optimize edici ile ilgili ``exp`` işlem kodu için gaz maliyeti arttı.
- ``byzantium``
   - Assembly'de ``returndatacopy``, ``returndatasize`` ve ``staticcall`` işlem kodları mevcuttur.
   - ``staticcall`` işlem kodu, kütüphane dışı görünüm veya pure fonksiyonları çağırırken kullanılır, bu da fonksiyonların EVM seviyesinde durumu değiştirmesini engeller, yani geçersiz tip dönüşümleri kullandığınızda bile geçerlidir.
   - Fonksiyon çağrılarından dönen dinamik verilere erişmek mümkündür.
   - ``revert`` işlem kodu tanıtıldı, bu da ``revert()`` işleminin gaz israfına yol açmayacağı anlamına geliyor.
- ``constantinople``
   - Assembly'de ``create2``, ``extcodehash``, ``shl``, ``shr`` ve ``sar`` işlem kodları mevcuttur.
   - Shifting operatörleri shifting opcodes kullanır ve bu nedenle daha az gaza ihtiyaç duyar.
- ``petersburg``
   - Derleyici istanbul'da olduğu gibi aynı şekilde davranır.
- ``istanbul``
   - Assembly'de ``chainid`` ve ``selfbalance`` opcode'ları mevcuttur.
- ``berlin``
   - ``SLOAD``, ``*CALL``, ``BALANCE``, ``EXT*`` ve ``SELFDESTRUCT`` için gaz maliyetleri arttı. Bu maliyetler derleyici bu tür operasyonlarda soğuk gaz maliyetlerini varsayar. Bu, gaz tahmini için geçerlidir ve optimize edicidir.
- ``london`` (**default**)
   - Bloğun taban ücretine (`EIP-3198 <https://eips.ethereum.org/EIPS/eip-3198>`_ ve `EIP-1559 <https://eips.ethereum.org/EIPS/eip-1559>`_) global ``block.basefee`` veya inline assembly`de ``basefee()`` aracılığıyla erişilebilir.


.. index:: ! standard JSON, ! --standard-json
.. _compiler-api:

Derleyici JSON Girdisi ve Çıktısı Tanımı
******************************************

Özellikle daha karmaşık ve otomatik kurulumlar için Solidity derleyicisi ile arayüz
oluşturmanın önerilen yolu JSON-girdi-çıktı arayüzüdür. Aynı arayüz derleyicinin
tüm dağıtımları tarafından sağlanır.

Alanlar genellikle değişikliğe tabidir, bazıları isteğe bağlıdır (belirtildiği gibi),
ancak yalnızca geriye dönük uyumlu değişiklikler yapmaya çalışıyoruz.

Derleyici API'si JSON formatında bir girdi bekler ve derleme sonucunu JSON formatında
bir çıktı olarak verir. Standart hata çıktısı kullanılmaz ve hatalar olsa bile işlem
her zaman "başarılı" durumda sonlandırılır. Hatalar her zaman JSON çıktısının bir
parçası olarak rapor edilir.

Aşağıdaki alt bölümlerde format bir örnek üzerinden açıklanmaktadır.
Yorumlara elbette izin verilmez ve burada yalnızca açıklama amacıyla kullanılır.

Girdi Açıklaması
-----------------

.. code-block:: javascript

    {
      // Gerekli: Kaynak kod dili. Şu anda "Solidity" ve "Yul" desteklenmektedir.
      "language": "Solidity",
      // Gerekli
      "sources":
      {
        // Buradaki anahtarlar kaynak dosyaların "global" isimleridir,
        // içe aktarmalar yeniden eşlemeler yoluyla diğer dosyaları kullanabilir (aşağıya bakın).
        "myFile.sol":
        {
          // Opsiyonel: kaynak dosyanın keccak256 hash'i
          // URL'ler aracılığıyla içe aktarılmışsa alınan içeriği doğrulamak için kullanılır.
          "keccak256": "0x123...",
          // Gerekli ("content" kullanılmadığı sürece, aşağıya bakın): Kaynak dosyaya giden URL(ler).
          // URL(ler) bu sırayla içe aktarılmalı ve sonuç keccak256 hash'iyle
          // (varsa) kontrol edilmelidir. Hash eşleşmezse veya URL(ler)den hiçbiri başarıyla
          // sonuçlanmazsa, bir hata oluşmalıdır.
          // Komut satırı arayüzü kullanılarak yalnızca dosya sistemi yolları desteklenir.
          // JavaScript arayüzü ile URL, kullanıcı tarafından sağlanan okuma geri çağrısına aktarılır,
          // böylece geri çağrı tarafından desteklenen herhangi bir URL kullanılabilir.
          "urls":
          [
            "bzzr://56ab...",
            "ipfs://Qma...",
            "/tmp/path/to/file.sol"
            // Dosyalar kullanılıyorsa, dizinleri komut satırına şu yolla eklenmelidir
            // `--allow-paths <path>`.
          ]
        },
        "destructible":
        {
          // Opsiyonel: kaynak dosyanın keccak256 hash'i
          "keccak256": "0x234...",
          // Gerekli ("urls" kullanılmadığı sürece): kaynak dosyanın gerçek içeriği
          "content": "contract destructible is owned { function shutdown() { if (msg.sender == owner) selfdestruct(owner); } }"
        }
      },
      // Opsiyonel
      "settings":
      {
        // Opsiyonel: Belirtilen aşamadan sonra derlemeyi durdurun. Şu anda burada sadece "parsing" geçerlidir
        "stopAfter": "parsing",
        // Opsiyonel: Yeniden eşlemelerin sıralanmış listesi
        "remappings": [ ":g=/dir" ],
        // Opsiyonel: Optimize edici ayarları
        "optimizer": {
          // Varsayılan olarak devre dışıdır.
          // NOT: enabled=false hala bazı optimizasyonları açık bırakır. Aşağıdaki yorumlara bakın.
          // UYARI: 0.8.6 sürümünden önce 'enabled' anahtarını atlamak, false olarak ayarlamakla eşdeğer
          // değildi ve aslında tüm optimizasyonları devre dışı bırakıyordu.
          "enabled": true,
          // Kodu kaç kez çalıştırmayı planladığınıza göre optimize edin.
          // Düşük değerler ilk dağıtım maliyeti için daha fazla optimizasyon sağlarken, yüksek
          // değerler yüksek frekanslı kullanım için daha fazla optimizasyon sağlayacaktır.
          "runs": 200,
          // Optimize edici bileşenleri ayrıntılı olarak açın veya kapatın.
          // Yukarıdaki "enabled" anahtarı, burada değiştirilebilecek iki
          // varsayılan değer sağlar. Eğer "details" verilmişse, "enabled" atlanabilir.
          "details": {
            // Ayrıntı verilmediğinde peephole optimizer her zaman açıktır,
            // kapatmak için ayrıntıları kullanın.
            "peephole": true,
            // Ayrıntı verilmediğinde inliner her zaman açıktır,,
            // kapatmak için ayrıntıları kullanın.
            "inliner": true,
            // Kullanılmayan jumpdest kaldırıcı, ayrıntı verilmediğinde her zaman açıktır,
            // kapatmak için ayrıntıları kullanın.
            "jumpdestRemover": true,
            // Bazen değişmeli işlemlerde değişmezleri yeniden sıralar.
            "orderLiterals": false,
            // Yinelenen kod bloklarını kaldırır
            "deduplicate": false,
            // Ortak alt ifade eliminasyonu, bu en karmaşık adımdır ancak
            // aynı zamanda en büyük kazancı sağlayabilir.
            "cse": false,
            // Koddaki değişmez sayıların ve dizelerin gösterimini optimize edin.
            "constantOptimizer": false,
            // Yeni Yul optimize edici. Çoğunlukla ABI coder v2 ve inline assembly kodu
            // üzerinde çalışır.
            // Global optimizer ayarı ile birlikte etkinleştirilir ve
            // buradan devre dışı bırakılabilir.
            // Solidity 0.6.0'dan önce bu anahtar aracılığıyla etkinleştirilmesi gerekiyordu.
            "yul": false,
            // Yul optimize edici için ayarlama seçenekleri.
            "yulDetails": {
              // Değişkenler için yığın yuvalarının tahsisini iyileştirin, yığın yuvalarını erken boşaltabilir.
              // Yul optimize edici etkinleştirilirse varsayılan olarak etkinleştirilir.
              "stackAllocation": true,
              // Uygulanacak optimizasyon adımlarını seçin.
              // İsteğe bağlıdır, atlanırsa optimize edici varsayılan sırayı kullanır.
              "optimizerSteps": "dhfoDgvulfnTUtnIf..."
            }
          }
        },
        // Derlenecek EVM sürümü.
        // Tip denetimini ve kod üretimini etkiler. Yerleşim yeri olabilir,
        // tangerineWhistle, spuriousDragon, byzantium, constantinople, petersburg, istanbul or berlin
        "evmVersion": "byzantium",
        // Opsiyonel: Derleme işlem hattını Yul ara temsilinden geçecek şekilde değiştirin.
        // Bu varsayılan olarak yanlıştır.
        "viaIR": true,
        // Opsiyonel: Hata ayıklama ayarları
        "debug": {
          // Revert (ve require) sebep string' lerine nasıl işlem yapılır. Ayarlar
          // "default", "strip", "debug" ve "verboseDebug" şeklindedir.
          // "default" derleyici tarafından oluşturulan revert stringlerini enjekte etmez ve kullanıcı tarafından sağlananları tutar.
          // "strip" tüm revert stringlerini (mümkünse, yani değişmezler kullanılıyorsa) yan etkilerini koruyarak kaldırır
          // "debug" derleyici tarafından oluşturulan dahili geri dönüşler için stringler enjekte eder, şimdilik ABI kodlayıcıları V1 ve V2 için uygulanmaktadır.
          // "verboseDebug" kullanıcı tarafından sağlanan revert stringlerine daha fazla bilgi ekler (henüz uygulanmadı)
          "revertStrings": "default",
          // Opsiyonel: Üretilen EVM assembly ve Yul kodundaki yorumlara ne kadar ekstra
          // hata ayıklama bilgisi ekleneceği. Mevcut bileşenler şunlardır:
          // - `location`: Orijinal Solidity dosyasındaki ilgili öğenin konumunu belirten
          //    `@src <index>:<start>:<end>` biçimindeki ek açıklamalar, burada:
          //     - `<index>`, `@use-src` ek açıklamasıyla eşleşen dosya dizinidir,
          //     - `<start>` o konumdaki ilk baytın indeksidir,
          //     - `<end>` bu konumdan sonraki ilk baytın indeksidir.
          // - `snippet`: `@src` ile belirtilen konumdan tek satırlık bir kod parçacığı.
          //     Parçacık alıntılanır ve ilgili `@src` ek açıklamasını takip eder.
          // - `*`: Her şeyi talep etmek için kullanılabilecek joker karakter değeri.
          "debugInfo": ["location", "snippet"]
        },
        // Metadata ayarları (isteğe bağlı)
        "metadata": {
          // URL'leri değil, yalnızca gerçek içeriği kullan (varsayılan olarak false)
          "useLiteralContent": true,
          // Bayt koduna eklenen metadata hash'i için verilen hash yöntemini kullanın.
          // Metadata hash'i "none" seçeneği ile bayt kodundan kaldırılabilir.
          // Diğer seçenekler "ipfs" ve "bzzr1 "dir.
          // Seçenek atlanırsa, varsayılan olarak "ipfs" kullanılır.
          "bytecodeHash": "ipfs"
        },
        // Kütüphanelerin adresleri. Tüm kütüphaneler burada verilmezse,
        // çıktı verileri farklı olan bağlantısız nesnelerle sonuçlanabilir.
        "libraries": {
          // En üst düzey anahtar, kütüphanenin kullanıldığı kaynak dosyanın adıdır.
          // Yeniden eşlemeler kullanılıyorsa, bu kaynak dosya yeniden eşlemeler
          // uygulandıktan sonraki genel yolla eşleşmelidir.
          // Bu anahtar boş bir string ise, bu global bir seviyeyi ifade eder.
          "myFile.sol": {
            "MyLib": "0x123123..."
          }
        },
        // Dosya ve sözleşme adlarına göre istenen çıktıları
        // seçmek için aşağıdakiler kullanılabilir.
        // Bu alan atlanırsa, derleyici yükler ve tür denetimi yapar,
        // ancak hatalar dışında herhangi bir çıktı üretmez.
        // Birinci seviye anahtar dosya adı, ikinci seviye anahtar ise sözleşme adıdır.
        // Boş bir sözleşme adı, bir sözleşmeye bağlı olmayan ancak AST gibi
        // tüm kaynak dosyaya bağlı olan çıktılar için kullanılır.
        // Sözleşme adı olarak bir yıldız, dosyadaki tüm sözleşmeleri ifade eder.
        // Benzer şekilde, dosya adı olarak bir yıldız tüm dosyalarla eşleşir.
        // Derleyicinin üretebileceği tüm çıktıları seçmek için
        // "outputSelection: { "*": { "*": [ "*" ], "": [ "*" ] } }"
        // ancak bunun derleme sürecini gereksiz yere yavaşlatabileceğini unutmayın.
        //
        // Mevcut çıktı türleri aşağıdaki gibidir:
        //
        // Dosya seviyesi (sözleşme adı olarak boş dize gerekir):
        //   ast - Tüm kaynak dosyaların AST'si
        //
        // Sözleşme seviyesi (sözleşme adına veya "*" işaretine ihtiyaç duyar):
        //   abi - ABI
        //   devdoc - Geliştirici dokümantasyonu (natspec)
        //   userdoc - Kullanıcı dokümantasyonu (natspec)
        //   metadata - Metadata
        //   ir - Optimizasyondan önce kodun Yul ara temsili
        //   irOptimized - Optimizasyon sonrası ara temsil
        //   storageLayout - Sözleşmenin durum değişkenlerinin yuvaları, ofsetleri ve türleri.
        //   evm.assembly - Yeni assembly formatı
        //   evm.legacyAssembly - JSON'daki eski tarz assembly formatı
        //   evm.bytecode.functionDebugData - Fonksiyon düzeyinde hata ayıklama bilgileri
        //   evm.bytecode.object - Bytecode objesi
        //   evm.bytecode.opcodes - Opcodes listesi
        //   evm.bytecode.sourceMap - Kaynak eşlemesi (hata ayıklama için yararlı)
        //   evm.bytecode.linkReferences - Bağlantı referansları (bağlantısı olmayan nesne ise)
        //   evm.bytecode.generatedSources - Derleyici tarafından oluşturulan kaynaklar
        //   evm.deployedBytecode* - Deployed bytecode (evm.bytecode'un sahip olduğu tüm seçeneklere sahiptir)
        //   evm.deployedBytecode.immutableReferences - AST kimliklerinden değişmezlere referans veren bayt kodu aralıklarına eşleme
        //   evm.methodIdentifiers - Fonksiyon hash'lerinin listesi
        //   evm.gasEstimates - Fonksiyon gazı tahminleri
        //   ewasm.wast - WebAssembly S-expressions biçiminde Ewasm
        //   ewasm.wasm - WebAssembly binary formatında Ewasm
        //
        // Bir `evm`, `evm.bytecode`, `ewasm`, vb. kullanmanın bu çıktının her
        // hedef parçasını seçeceğini unutmayın. Ayrıca, `*` her şeyi istemek için joker karakter olarak kullanılabilir.
        //
        "outputSelection": {
          "*": {
            "*": [
              "metadata", "evm.bytecode" // Her bir sözleşmenin metadata ve bytecode çıktılarını etkinleştirin.
              , "evm.bytecode.sourceMap" // Her bir sözleşmenin kaynak eşleme çıktısını etkinleştirin.
            ],
            "": [
              "ast" // Her bir dosyanın AST çıktısını etkinleştirin.
            ]
          },
          // Def dosyasında tanımlanan MyContract'ın abi ve opcodes çıktısını etkinleştirin.
          "def": {
            "MyContract": [ "abi", "evm.bytecode.opcodes" ]
          }
        },
        // ModelChecker nesnesi deneyseldir ve değişikliklere tabidir.
        "modelChecker":
        {
          // Hangi sözleşmelerin konuşlandırılmış sözleşme olarak analiz edilmesi gerektiğini seçin.
          "contracts":
          {
            "source1.sol": ["contract1"],
            "source2.sol": ["contract2", "contract3"]
          },
          // Bölme ve modulo işlemlerinin nasıl şifreleneceğini seçin.
          // `false` kullanıldığında, bunlar slack değişkenlerle çarpılarak
          // değiştirilir. Bu varsayılandır.
          // CHC motorunu kullanıyorsanız ve Horn çözücü olarak Spacer kullanmıyorsanız
          // (örneğin Eldarica kullanıyorsanız) burada `true` kullanılması önerilir.
          // Bu seçeneğin daha ayrıntılı bir açıklaması için Biçimsel Doğrulama bölümüne bakın.
          "divModNoSlacks": false,
          // Hangi model denetleyici motorunun kullanılacağını seçin: all (varsayılan), bmc, chc, none.
          "engine": "chc",
          // Kullanıcıya hangi tür değişmezlerin rapor edileceğini seçin: contract, reentrancy.
          "invariants": ["contract", "reentrancy"],
          // Kanıtlanmamış tüm hedeflerin çıktısının alınıp alınmayacağını seçin. Varsayılan değer `false`dir.
          "showUnproved": true,
          // Varsa, hangi çözücülerin kullanılması gerektiğini seçin.
          // Çözücülerin açıklaması için Biçimsel Doğrulama bölümüne bakın.
          "solvers": ["cvc4", "smtlib2", "z3"],
          // Hangi hedeflerin kontrol edilmesi gerektiğini seçin: constantCondition,
          // underflow, overflow, divByZero, balance, assert, popEmptyArray, outOfBounds.
          // Seçenek belirtilmezse, Solidity >=0.8.7 için underflow/overflow
          // hariç tüm hedefler varsayılan olarak kontrol edilir.
          // Hedeflerin açıklaması için Biçimsel Doğrulama bölümüne bakın.
          "targets": ["underflow", "overflow", "assert"],
          // Her SMT sorgusu için milisaniye cinsinden zaman aşımı.
          // Bu seçenek verilmezse, SMTChecker varsayılan olarak
          // deterministik bir kaynak sınırı kullanacaktır.
          // Verilen zaman aşımının 0 olması, herhangi bir sorgu için kaynak/zaman kısıtlaması olmadığı anlamına gelir.
          "timeout": 20000
        }
      }
    }


Çıktı Açıklaması
------------------

.. code-block:: javascript

    {
      // Opsiyonel: herhangi bir hata/uyarı/bilgi ile karşılaşılmadıysa mevcut değildir
      "errors": [
        {
          // Opsiyonel: Kaynak dosya içindeki konum.
          "sourceLocation": {
            "file": "sourceFile.sol",
            "start": 0,
            "end": 100
          },
          // Opsiyonel: Diğer yerler (örn. çelişkili beyanların olduğu yerler)
          "secondarySourceLocations": [
            {
              "file": "sourceFile.sol",
              "start": 64,
              "end": 92,
              "message": "Other declaration is here:"
            }
          ],
          // Zorunlu: Hata türü, örneğin "TypeError", "InternalCompilerError", "Exception", vb.
          // Türlerin tam listesi için aşağıya bakınız.
          "type": "TypeError",
          // Zorunlu: Hatanın kaynaklandığı bileşen, örneğin "general", "ewasm", vb.
          "component": "general",
          // Zorunlu (" error", "warning" veya "info", ancak bunun gelecekte genişletilebileceğini lütfen unutmayın)
          "severity": "error",
          // İsteğe bağlı: hatanın nedeni için benzersiz kod
          "errorCode": "3141",
          // Zorunlu
          "message": "Invalid keyword",
          // Opsiyonel: kaynak konumu ile biçimlendirilmiş mesaj
          "formattedMessage": "sourceFile.sol:100: Invalid keyword"
        }
      ],
      // Bu, dosya düzeyinde çıktıları içerir.
      // OutputSelection ayarları ile sınırlandırılabilir/filtrelenebilir.
      "sources": {
        "sourceFile.sol": {
          // Kaynak tanımlayıcısı (kaynak eşlemelerinde kullanılır)
          "id": 1,
          // AST objesi
          "ast": {}
        }
      },
      // Bu, sözleşme düzeyindeki çıktıları içerir.
      // OutputSelection ayarları ile sınırlandırılabilir/filtrelenebilir.
      "contracts": {
        "sourceFile.sol": {
          // Kullanılan dilde sözleşme adı yoksa, bu alan boş bir dizeye eşit olmalıdır.
          "ContractName": {
            // Ethereum Sözleşmesi ABI'si. Boşsa, boş bir dizi olarak gösterilir.
            // bkz. https://docs.soliditylang.org/en/develop/abi-spec.html
            "abi": [],
            // Metadata Çıktısı belgelerine bakın (serileştirilmiş JSON stringi)
            "metadata": "{/* ... */}",
            // Kullanıcı dokümantasyonu (natspec)
            "userdoc": {},
            // Geliştirici dokümantasyonu (natspec)
            "devdoc": {},
            // Ara temsil (string)
            "ir": "",
            // Depolama Düzeni belgelerine bakın.
            "storageLayout": {"storage": [/* ... */], "types": {/* ... */} },
            // EVM'ye ilişkin çıktılar
            "evm": {
              // Assembly (string)
              "assembly": "",
              // Eski tarz assembly (object)
              "legacyAssembly": {},
              // Bytecode ve ilgili ayrıntılar.
              "bytecode": {
                // Fonksiyonlar düzeyinde veri hata ayıklama.
                "functionDebugData": {
                  // Şimdi derleyicinin dahili ve kullanıcı tanımlı fonksiyonlarını içeren bir fonksiyon kümesini takip edin.
                  // Kümenin eksiksiz olması gerekmez.
                  "@mint_13": { // Fonksiyonun dahili adı
                    "entryPoint": 128, // Fonksiyonun başladığı byte offset bytecode (isteğe bağlı)
                    "id": 13, // Fonksiyon tanımının AST ID'si veya derleyiciye dahili fonksiyonlar için null (isteğe bağlı)
                    "parameterSlots": 2, // Fonksiyon parametreleri için EVM yığın yuvası sayısı (isteğe bağlı)
                    "returnSlots": 1 // Dönüş değerleri için EVM yığın yuvası sayısı (isteğe bağlı)
                  }
                },
                // Hex string olarak bytecode.
                "object": "00fe",
                // Opcodes listesi (string)
                "opcodes": "",
                // Bir string olarak kaynak eşlemesi. Kaynak eşleme tanımına bakın.
                "sourceMap": "",
                // Derleyici tarafından oluşturulan kaynakların dizisi. Şu anda yalnızca
                // tek bir Yul dosyası içerir.
                "generatedSources": [{
                  // Yul AST
                  "ast": {/* ... */},
                  // Metin halindeki kaynak dosya (yorum içerebilir)
                  "contents":"{ function abi_decode(start, end) -> data { data := calldataload(start) } }",
                  // Kaynak dosya ID'si, kaynak referansları için kullanılır, Solidity kaynak dosyalarıyla aynı "ad alanı"
                  "id": 2,
                  "language": "Yul",
                  "name": "#utility.yul"
                }],
                // Verilirse, bu bağlantısız bir nesnedir.
                "linkReferences": {
                  "libraryFile.sol": {
                    // Baytların bayt kodu içindeki ofsetleri.
                    // Bağlantı, burada bulunan 20 baytın yerini alır.
                    "Library1": [
                      { "start": 0, "length": 20 },
                      { "start": 200, "length": 20 }
                    ]
                  }
                }
              },
              "deployedBytecode": {
                /* ..., */ // Yukarıdaki ile aynı düzen.
                "immutableReferences": {
                  // AST ID 3 ile değişmeze iki referans vardır, her ikisi de 32 bayt uzunluğundadır. Bir tanesi
                  // bytecode offset 42'de, diğeri bytecode offset 80'de.
                  "3": [{ "start": 42, "length": 32 }, { "start": 80, "length": 32 }]
                }
              },
              // Fonksiyon hash'lerinin listesi
              "methodIdentifiers": {
                "delegate(address)": "5c19a95c"
              },
              // Fonksiyon gaz tahminleri
              "gasEstimates": {
                "creation": {
                  "codeDepositCost": "420000",
                  "executionCost": "infinite",
                  "totalCost": "infinite"
                },
                "external": {
                  "delegate(address)": "25000"
                },
                "internal": {
                  "heavyLifting()": "infinite"
                }
              }
            },
            // Ewasm ile ilgili çıktılar
            "ewasm": {
              // S-expressions biçimi
              "wast": "",
              // Binary formatı (hex string)
              "wasm": ""
            }
          }
        }
      }
    }


Hata Türleri
~~~~~~~~~~~~~~~

<<<<<<< HEAD
1. ``JSONError``: JSON girdisi gerekli biçime uymuyor, örneğin girdi bir JSON nesnesi değil, dil desteklenmiyor vb.
2. ``IOError``: Çözümlenemeyen URL veya sağlanan kaynaklardaki hash uyuşmazlığı gibi IO ve içe aktarma işleme hataları.
3. ``ParserError``: Kaynak kodu dil kurallarına uygun değil.
4. ``DocstringParsingError``: Yorum bloğundaki NatSpec etiketleri ayrıştırılamıyor.
5. ``SyntaxError``: Sözdizimsel hata, örneğin ``continue`` bir ``for`` döngüsünün dışında kullanılmıştır.
6. ``DeclarationError``: Geçersiz, çözümlenemeyen veya çakışan tanımlayıcı adları. ör. ``Identifier not found``
7. ``TypeError``: Geçersiz tür dönüşümleri, geçersiz atamalar vb. gibi tür sistemi içindeki hatalar.
8. ``UnimplementedFeatureError``: Özellik derleyici tarafından desteklenmiyor, ancak gelecek sürümlerde desteklenmesi bekleniyor.
9. ``InternalCompilerError``: Derleyicide tetiklenen dahili hata - bu bir sorun olarak raporlanmalıdır.
10. ``Exception``: Derleme sırasında bilinmeyen hata - bu bir sorun olarak raporlanmalıdır.
11. ``CompilerError``: Derleyici yığınının geçersiz kullanımı - bu bir sorun olarak raporlanmalıdır.
12. ``FatalError``: Ölümcül hata doğru şekilde işlenmedi - bu bir sorun olarak raporlanmalıdır.
13. ``Warning``: Derlemeyi durdurmayan, ancak mümkünse ele alınması gereken bir uyarı.
14. ``Info``: Derleyicinin kullanıcının yararlı bulabileceğini düşündüğü, ancak tehlikeli olmayan ve mutlaka ele alınması gerekmeyen bilgiler.
=======
1. ``JSONError``: JSON input doesn't conform to the required format, e.g. input is not a JSON object, the language is not supported, etc.
2. ``IOError``: IO and import processing errors, such as unresolvable URL or hash mismatch in supplied sources.
3. ``ParserError``: Source code doesn't conform to the language rules.
4. ``DocstringParsingError``: The NatSpec tags in the comment block cannot be parsed.
5. ``SyntaxError``: Syntactical error, such as ``continue`` is used outside of a ``for`` loop.
6. ``DeclarationError``: Invalid, unresolvable or clashing identifier names. e.g. ``Identifier not found``
7. ``TypeError``: Error within the type system, such as invalid type conversions, invalid assignments, etc.
8. ``UnimplementedFeatureError``: Feature is not supported by the compiler, but is expected to be supported in future versions.
9. ``InternalCompilerError``: Internal bug triggered in the compiler - this should be reported as an issue.
10. ``Exception``: Unknown failure during compilation - this should be reported as an issue.
11. ``CompilerError``: Invalid use of the compiler stack - this should be reported as an issue.
12. ``FatalError``: Fatal error not processed correctly - this should be reported as an issue.
13. ``YulException``: Error during Yul Code generation - this should be reported as an issue.
14. ``Warning``: A warning, which didn't stop the compilation, but should be addressed if possible.
15. ``Info``: Information that the compiler thinks the user might find useful, but is not dangerous and does not necessarily need to be addressed.
>>>>>>> v0.8.17


.. _compiler-tools:

Derleyici Araçları
*******************

solidity-upgrade
----------------

``solidity-upgrade`` sözleşmelerinizi dil değişikliklerine yarı otomatik olarak
yükseltmenize yardımcı olabilir. Her son sürüm için gerekli tüm değişiklikleri
uygulamasa ve uygulayamasa da, aksi takdirde çok sayıda tekrarlayan manuel ayarlama
gerektirecek olanları hala desteklemektedir.

.. note::

    ''solidity-upgrade'' işin büyük bir kısmını gerçekleştirir, ancak sözleşmelerinizin
    büyük olasılıkla daha fazla manuel ayarlamaya ihtiyacı olacaktır. Dosyalarınız için
    bir sürüm kontrol sistemi kullanmanızı öneririz. Bu, yapılan değişikliklerin gözden
    geçirilmesine ve sonunda geri alınmasına yardımcı olur.

.. warning::

    ``solidity-upgrade`` tam veya hatasız olarak kabul edilmez, bu nedenle lütfen
    dikkatli kullanın.

Nasıl Çalışır?
~~~~~~~~~~~~~~~

Solidity kaynak dosya(lar)ını ``solidity-upgrade [files]``'a aktarabilirsiniz. Bunlar,
geçerli kaynak dosyanın dizini dışındaki dosyalara referans veren ``import`` ifadesini
kullanıyorsa, ``--allow-paths [directory]`` seçeneğini geçerek dosyaların okunmasına
ve içe aktarılmasına izin verilen dizinleri belirtmeniz gerekir. Eksik dosyaları
``--ignore-missing`` seçeneğini geçerek yok sayabilirsiniz.

``solidity-upgrade``, ``libsolidity`` tabanlıdır ve kaynak dosyalarınızı ayrıştırabilir,
derleyebilir ve analiz edebilir ve içlerinde uygulanabilir kaynak yükseltmeleri bulabilir.

Kaynak yükseltmeleri, kaynak kodunuzda yapılan küçük metinsel değişiklikler olarak
kabul edilir. Bunlar, verilen kaynak dosyaların bellek içi gösterimine uygulanır.
İlgili kaynak dosyası varsayılan olarak güncellenir, ancak herhangi bir dosyaya
yazmadan tüm yükseltme işlemini simüle etmek için ``--dry-run`` geçebilirsiniz.

Yükseltme işleminin iki aşaması vardır. İlk aşamada kaynak dosyalar ayrıştırılır
ve kaynak kodu bu seviyede yükseltmek mümkün olmadığından, hatalar toplanır ve
``--verbose`` geçilerek günlüğe kaydedilebilir. Bu noktada kaynak yükseltmesi mevcut
değildir.

İkinci aşamada, tüm kaynaklar derlenir ve tüm etkinleştirilmiş yükseltme analizi
modülleri derleme ile birlikte çalıştırılır. Varsayılan olarak, mevcut tüm modüller
etkinleştirilir. Daha fazla ayrıntı için lütfen :ref:`available modules <upgrade-modules>`
belgesini okuyun.


Bu, kaynak yükseltmeleri ile düzeltilebilecek derleme hatalarına neden olabilir. Hiçbir
hata oluşmazsa, hiçbir kaynak yükseltmesi bildirilmez ve işiniz biter. Hatalar oluşursa
ve bazı yükseltme modülleri bir kaynak yükseltmesi bildirirse, ilk bildirilen uygulanır
ve verilen tüm kaynak dosyaları için derleme yeniden tetiklenir. Kaynak yükseltmeleri
rapor edildiği sürece önceki adım tekrarlanır. Eğer hala hatalar oluşuyorsa, ``--verbose``
komutunu geçerek bunları günlüğe kaydedebilirsiniz. Herhangi bir hata oluşmazsa, sözleşmeleriniz
günceldir ve derleyicinin en son sürümüyle derlenebilir.

.. _upgrade-modules:

Kullanılabilir Yükseltme Modülleri
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+----------------------------+---------+--------------------------------------------------+
| Modül                      | Versiyon| Açıklama                                         |
+============================+=========+==================================================+
| ``constructor``            | 0.5.0   | Constructor''lar artık ``constructor`` anahtar   |
|                            |         | sözcüğü kullanılarak tanımlanmalıdır.            |
+----------------------------+---------+--------------------------------------------------+
| ``visibility``             | 0.5.0   | Public fonksiyon görünürlüğü artık zorunlu,      |
|                            |         | varsayılan değer ``public``.                     |
+----------------------------+---------+--------------------------------------------------+
| ``abstract``               | 0.6.0   | Bir sözleşme tüm fonksiyonlarını uygulamıyorsa   |
|                            |         | ``abstract`` anahtar sözcüğü kullanılmalıdır.    |
+----------------------------+---------+--------------------------------------------------+
| ``virtual``                | 0.6.0   | Bir arayüz dışında uygulaması olmayan            |
|                            |         | fonksiyonlar ``virtual`` olarak işaretlenmelidir.|
+----------------------------+---------+--------------------------------------------------+
| ``override``               | 0.6.0   | Bir fonksiyon veya modifier geçersiz kılınırken, |
|                            |         | yeni ``override`` anahtar sözcüğü kullanılmalıdır|
+----------------------------+---------+--------------------------------------------------+
| ``dotsyntax``              | 0.7.0   | Aşağıdaki sözdizimi kullanımdan kaldırılmıştır:  |
|                            |         | ``f.gas(...)()``, ``f.value(...)()`` ve          |
|                            |         | ``(new C).value(...)()``. Bu çağrıların yerine   |
|                            |         | ``f{gas: ..., value: ...}()`` ve                 |
|                            |         | ``(new C){value: ...}()``.                       |
+----------------------------+---------+--------------------------------------------------+
| ``now``                    | 0.7.0   | ``now`` anahtar sözcüğü kullanımdan  kalktı.     |
|                            |         | Bunun yerine `block.timestamp`` kullanın.        |
+----------------------------+---------+--------------------------------------------------+
| ``constructor-visibility`` | 0.7.0   | Constructor'ların görünürlüğünü kaldırır.        |
|                            |         |                                                  |
+----------------------------+---------+--------------------------------------------------+

Daha fazla ayrıntı için lütfen :doc:`0.5.0 release notes <050-breaking-changes>`,
:doc:`0.6.0 release notes <060-breaking-changes>`, :doc:`0.7.0 release notes <070-breaking-changes>`
ve :doc:`0.8.0 release notes <080-breaking-changes>` bölümlerini okuyun.

Özet bilgi(Synopsis)
~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: none

    Usage: solidity-upgrade [options] contract.sol

    Allowed options:
        --help               Show help message and exit.
        --version            Show version and exit.
        --allow-paths path(s)
                             Allow a given path for imports. A list of paths can be
                             supplied by separating them with a comma.
        --ignore-missing     Ignore missing files.
        --modules module(s)  Only activate a specific upgrade module. A list of
                             modules can be supplied by separating them with a comma.
        --dry-run            Apply changes in-memory only and don't write to input
                             file.
        --verbose            Print logs, errors and changes. Shortens output of
                             upgrade patches.
        --unsafe             Accept *unsafe* changes.



Hata Raporları / Özellik Talepleri
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bir hata bulduysanız veya bir özellik isteğiniz varsa, lütfen `Github'da <https://github.com/ethereum/solidity/issues/new/choose>`_ bir sorun gönderin.


Örnek
~~~~~~~

``Source.sol`` içinde aşağıdaki sözleşmeye sahip olduğunuzu varsayın:

.. code-block:: Solidity

    pragma solidity >=0.6.0 <0.6.4;
    // This will not compile after 0.7.0
    // SPDX-License-Identifier: GPL-3.0
    contract C {
        // BENİDÜZELT: constructor görünürlüğünü kaldırın ve sözleşmeyi abstract hale getirin
        constructor() internal {}
    }

    contract D {
        uint time;

        function f() public payable {
            // BENİDÜZELT: now'u block.timestamp olarak değiştirin
            time = now;
        }
    }

    contract E {
        D d;

        // BENİDÜZELT: constructor görünürlüğünü kaldır
        constructor() public {}

        function g() public {
            // BENİDÜZELT: .value(5) => {value: 5} olarak değiştirin
            d.f.value(5)();
        }
    }



Gerekli Değişiklikler
^^^^^^^^^^^^^^^^^^^^^^

Yukarıdaki sözleşme 0.7.0'dan itibaren derlenmeyecektir. Sözleşmeyi mevcut Solidity
sürümüyle güncel hale getirmek için aşağıdaki yükseltme modüllerinin çalıştırılması
gerekir: ``constructor-visibility``, ``now`` ve ``dotsyntax``. Daha fazla ayrıntı için
lütfen :ref:`available modules <upgrade-modules>` belgelendirmesini okuyun.


Yükseltmenin Çalıştırılması
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Yükseltme modüllerinin ``--modules`` argümanı kullanılarak açıkça belirtilmesi önerilir.

.. code-block:: bash

    solidity-upgrade --modules constructor-visibility,now,dotsyntax Source.sol

Yukarıdaki komut aşağıda gösterildiği gibi tüm değişiklikleri uygular. Lütfen bunları
dikkatlice inceleyin (pragmaların manuel olarak güncellenmesi gerekecektir).

.. code-block:: Solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    abstract contract C {
        // BENİDÜZELT: constructor görünürlüğünü kaldırın ve sözleşmeyi abstract hale getirin
        constructor() {}
    }

    contract D {
        uint time;

        function f() public payable {
            // BENİDÜZELT: now'u block.timestamp olarak değiştirin
            time = block.timestamp;
        }
    }

    contract E {
        D d;

        // BENİDÜZELT: constructor görünürlüğünü kaldır
        constructor() {}

        function g() public {
            // FIXME: change .value(5) =>  {value: 5}
            d.f{value: 5}();
        }
    }
