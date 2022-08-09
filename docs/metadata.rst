.. _metadata:

#################
Sözleşme Meta Verisi
#################

.. index:: metadata, contract verification

Solidity derleyicisi derlenen sözleşme hakkında bilgiler içeren "şözleşme meta verisi" adlı bir JSON dosyasını otomatik olarak oluşturur. Bu dosyayı derleyici sürümünü, kaynak dosyaları, ABI ve NatSpec dokümentasyonunu sorgulamak için kullanabilirsiniz. Bu sayede sözleşmenin kaynak kodunu doğrulayabilir ve sözleşmeyle daha güvenli bir şekilde etkileşime geçebilirsiniz.

Derleyici varsayılan şeklinde meta veri dosyasının IPFS hash'ini bayt kodun sonuna ekler (detaylar için aşağıya göz atınız). Böylelikle meta veri merkezi bir veri sağlayıcısına bağlı kalmadan doğrulanmış bir şekilde indirebilirsiniz. Bu konuda diğer seçenekler Swarm hash'ini kullanmak veya meta veri hash'ini bayt kodun sonuna eklememektir. Bu seçenekler :ref:`Standard JSON Arayüzü<compiler-api>` üzerinden ayarlanabilir.

Meta veri dosyasına erişilebilmesi için dosyayı IPFS, Swarm veya başka bir serviste yayınlamanız gerekmektedir. Dosyayı ``SözleşmeAdı_meta.json`` adında bir dosya oluşturan ``solc --metadata`` komutunu kullanarak yaratabilirsiniz. Dosya kaynak kodu dosyalarının IPFS ve Swarm hash'lerini içerdiği için bütün kaynak kodu dosyalarını ve meta veri dosyasını yüklemeniz gerekmektedir.

Meta veri dosyası aşağıdaki formattadır. Fakat aşağıdaki örnek okuması kolay şekilde gösterilmektedir. Normalde düzgün şekilde formatlanmış meta veri tırnak işaretlerini doğru şekilde kullanmalı, metindeki boşlukları en aza indirmeli ve JSON nesnesinin anahtarlarını tutarlı bir formatlamaya ulaşmak için sıralamalıdır. Normalde JSON dosyalarında yorum satırlarına müsade edilmezken burada yalnızca gösterim amaçlı olarak eklenmiştir.

.. code-block:: javascript

    {
      // Mecburi: Meta veri formatının sürümü
      "version": "1",
      // Mecburi: Kaynak kodu dili. Spesifikasyonun bir "alt-sürümü"nü seçer.
      "language": "Solidity",
      // Mecburi: Derleyici hakkında detaylar. İçeriği kullanılan dile 
      // göre değişebilir.
      "compiler": {
        // Solidity için mecburi: Derleyici sürümü.
        "version": "0.4.6+commit.2dabbdf0.Emscripten.clang",
        // Opsiyonel: Bu çıktıyı elde etmek için kullanılan 
        // derleyici binary'sinin  hash'i
        "keccak256": "0x123..."
      },
      // Mecburi: Derleyici kaynak dosyaları/kaynak birimleri. 
      // Her bir anahtar dosya adıdır.
      "sources":
      {
        "myFile.sol": {
          // Mecburi: kaynak dosyasının keccak256 hash'i.
          "keccak256": "0x123...",
          // Mecburi: Kaynak dosyasının sıralanmış URL'leri. Herhangi bir 
          // protokol kullanılabilir fakat bir Swarm URL'i önerilir. 
          // ("content" kullanıldığında mecburi değildir, aşağıya bakınız)
          "urls": [ "bzzr://56ab..." ],
          // Opsiyonel: Kaynak kodunda belirtilen şekilde SPDX lisans kodu
          "license": "MIT"
        },
        "destructible": {
          // Mecburi: Kaynak dosyasının keccak256 hash'i.
          "keccak256": "0x234...",
          // Mecburi: Kaynak dosyasının kelimesi kelimesine içeriği
          // ("url" kullanıldığında mecburi değildir)
          "content": "contract destructible is owned { function destroy() { if (msg.sender == owner) selfdestruct(owner); } }"
        }
      },
      // Mecburi: Derleyici ayarları
      "settings":
      {
        // Solidity için mecburi: yeniden eşlemelerin sıralı listesi
        "remappings": [ ":g=/dir" ],
        // Opsiyonel: Optimize edici ayarları. "enabled" vs "runs" anahtarları 
        // artık kullanılmamaktadır ve geriye dönük uyumluluk için verilmiştir.
        "optimizer": {
          "enabled": true,
          "runs": 500,
          "details": {
            // peephole'ün varayılanı "true"dur
            "peephole": true,
            // inliner'ın varayılanı "true"dur
            "inliner": true,
            // jumpdestRemover'ın varayılanı "true"dur
            "jumpdestRemover": true,
            "orderLiterals": false,
            "deduplicate": false,
            "cse": false,
            "constantOptimizer": false,
            "yul": true,
            // Opsyionel: Yalnızca "yul" "true" ise mevcut
            "yulDetails": {
              "stackAllocation": false,
              "optimizerSteps": "dhfoDgvulfnTUtnIf..."
            }
          }
        },
        "metadata": {
          // Girdi json'da kullanılan ayarın aynısı. Varsayılan: "false"
          "useLiteralContent": true,
          // Girdi json'da kullanılan ayarın aynısı. Varsayılan: "ipfs"
          "bytecodeHash": "ipfs"
        },
        // Solidity için mecburi: Bu meta veri hangisi için yaratıldıysa o
        // dosya ile sözleşme veya kütüphanenin adı.
        "compilationTarget": {
          "myFile.sol": "MyContract"
        },
        // Solidity için mecburi: Kullanılan kütüphanelerin adresleri
        "libraries": {
          "MyLib": "0x123123..."
        }
      },
      // Mecburi: Sözleşme için oluşturulan bilgiler
      "output":
      {
        // Mecburi: Sözleşmenin ABI tanımı
        "abi": [/* ... */],
        // Mecburi: Sözleşmenin NatSpec kullanıcı dokümantasyonu
        "userdoc": [/* ... */],
        // Mecburi: Sözleşmenin NatSpec geliştirici dokümantasyonu
        "devdoc": [/* ... */]
      }
    }

.. warning::
  Elde edilen sözleşmenin bayt kodu meta veri hash'ini varsayılan şekilde içerdiği için
  meta veride yapılacak herhangi bir değişiklik bayt kodda bir değişikliğe sebep olabilir.
  Bir dosya adı veya yolunda yapılacak bir değişiklik veya meta veri bütün kaynakların
  hash'ini içerdiği için kaynaklarda eklenecek veya çıkarılacak bir boşluk farklı bir 
  meta veri ile dolayısı ile farklı bir bayt kod ile sonuçlanabilir. 

.. note::
    Yukarıdaki ABI tanımının belirlenmiş bir sıralaması yoktur ve derleyici sürümlerine 
    göre değişebilir. Fakat Solidity 0.5.12 sürümüyle birlikte ABI dizisi belirili bir 
    sıralamayı takip eder.

.. _encoding-of-the-metadata-hash-in-the-bytecode:

Meta Veri Hash'inin Bayt Kod İçinde Kodlanması
=============================================

Meta veriyi indirmenin farklı yollarını ileride destekleyebileceğimiz için 
``{"ipfs": <IPFS hash>, "solc": <compiler version>}`` eşlemesi 
`CBOR <https://tools.ietf.org/html/rfc7049>`_ ile kodlanmıştır. Eşleme birden
fazla anahtar içerebileceği için (aşağıdaki gibi) ve kodlamanın en başını bulması
kolay olmayabileceği için kodlamanın uzunluğu 2 bayt big-endian şeklinde (sona)
eklenmiştir. Solidity derleyicisinin mevcut sürümü çoğunlukla aşağıdaki kodu
yüklenen bayt kodun sonuna ekler. 

.. code-block:: text

    0xa2
    0x64 'i' 'p' 'f' 's' 0x58 0x22 <34 bayt IPFS hash'i>
    0x64 's' 'o' 'l' 'c' 0x43 <3 bayt sürüm kodlaması>
    0x00 0x33

Meta veriyi indirmek için yüklenen bayt kodun sonu bu örüntüye uyuyor mu diye 
bakılabilir ve elde edilen IPFS hash'i ile dosya indirilebilir. 

solc'in tamamlanmış sürümleri yukarıdaki 3 baytlık kodlama ile kodlanırken 
(her bir "büyük", "küçük", ve "yama" sürümü için birer bayt), tamamlanmamış 
ön sürümler sürümün derlenme tarihi ve commit hash'ini içeren komple bir 
string ile kodlanır.

.. note::
  CBOR eşlemesi farklı anahtarlar kullanabileceği için bu kodlamanın 
  ``0xa264`` ile başlamasına güvenmemek ve kodlamayı doğru şekilde çözmek
  gerekir. Örneğin, kod oluşturmayı etkileyecek herhangi bir deneysel
  özellik kullanıldıysa eşleme ``"experimental": true``'yu içerir.

.. note::
  Derleyici şu anda varsayılan olarak meta verinin IPFS hash'ini kullanıyor olsa 
  da ileride bzzr1 hash veya daha farklı bir hash kullanabilir. Bu yüzden
  bu serinin  ``0xa2 0x64 'i' 'p' 'f' 's'`` ile başlamasına güvenmemeniz 
  gerekir. Bu CBOR yapısına ayrıca ileride farklı veriler ekleyebiliriz. 
  Bu sebeple en doğrusu uygun bir CBOR ayrıştırıcı (parser) kullanmanızdır.

Otomatik Arayüz Oluşturmanın Kullanılması ve NatSpec
====================================================

Meta veri şu şekilde kullanılır: Bir sözleşmeyle etkileşime geçmek isteyen 
bir bileşen (örn. Mist veya başka bir cüzdan) sözleşmenin kodunu indirir. Daha
sonra bu koddan IPFS/Swarm hash'ini elde eder ve meta veri dosyası indirilir.
Bu dosya yukarıdaki yapıya uygun şekilde JSON formatında çözülür.

İlgili bileşen, ABI'ı otomatik olarak basit bir kullanıcı arayüzü oluşturmak
için kullanabilir.

Ek olarak cüzdan, kullanıcı bir sözleşmeyle etkileşime geçerken kullanıcıdan
işlem için imza onayı istemenin yanında kullanıcıya bir onay mesajı göstermek 
için NatSpec kullanıcı dokümantasyonunu kullanabilir. 

Daha fazla bilgi için :doc:`Ethereum Natural Language Specification (NatSpec) format <natspec-format>`ını okuyunuz.

Kaynak Kodu Doğrulama için Kullanım
==================================

Derlemeyi doğrulamak için kaynaklar meta veri dosyasında verilen bağlantılar ile
IPFS/Swarm'dan indirilebilir. 
Derleyicinin ("resmi" sürüm mü değil mi diye bakılan) doğru sürümü ilgili girdiye
belirtilen ayarlar ile çağrılır. (Derlemeden) elde edilen bayt kodu (sözleşmeyi) yaratma 
işleminin verisi ile veya ``CREATE`` işlem kodu verisi ile karşılaştırılır. Bu, hash'i 
zaten bayt kodun bir parçası olduğu için meta veriyi otomatik olarak doğrular. Fazldan
veri, kullanıcıya sunulan arayüze uygun şekilde çözülmesi gereken constructor girdi verisidir.

`sourcify <https://github.com/ethereum/sourcify>`_
(`npm paketi <https://www.npmjs.com/package/source-verify>`_) deposunda bu özelliği nasıl 
kullanabileceğinize dair kodu görebilirsiniz.