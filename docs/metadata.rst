.. _metadata:

#####################
Sözleşme Meta Verisi
#####################

.. index:: metadata, contract verification

Solidity derleyicisi derlenen sözleşme hakkında bilgiler içeren "şözleşme meta verisi" adlı bir JSON dosyasını otomatik olarak oluşturur. Bu dosyayı derleyici sürümünü, kaynak dosyaları, ABI ve NatSpec dokümentasyonunu sorgulamak için kullanabilirsiniz. Bu sayede sözleşmenin kaynak kodunu doğrulayabilir ve sözleşmeyle daha güvenli bir şekilde etkileşime geçebilirsiniz.

Derleyici varsayılan şeklinde meta veri dosyasının IPFS hash'ini bayt kodun sonuna ekler (detaylar için aşağıya göz atınız). Böylelikle meta veri merkezi bir veri sağlayıcısına bağlı kalmadan doğrulanmış bir şekilde indirebilirsiniz. Bu konuda diğer seçenekler Swarm hash'ini kullanmak veya meta veri hash'ini bayt kodun sonuna eklememektir. Bu seçenekler :ref:`Standard JSON Arayüzü<compiler-api>` üzerinden ayarlanabilir.

<<<<<<< HEAD
Meta veri dosyasına erişilebilmesi için dosyayı IPFS, Swarm veya başka bir serviste yayınlamanız gerekmektedir. Dosyayı ``SözleşmeAdı_meta.json`` adında bir dosya oluşturan ``solc --metadata`` komutunu kullanarak yaratabilirsiniz. Dosya kaynak kodu dosyalarının IPFS ve Swarm hash'lerini içerdiği için bütün kaynak kodu dosyalarını ve meta veri dosyasını yüklemeniz gerekmektedir.
=======
You have to publish the metadata file to IPFS, Swarm, or another service so
that others can access it. You create the file by using the ``solc --metadata``
command together with the ``--output-dir`` parameter. Without the parameter,
the metadata will be written to standard output.
The metadata contains IPFS and Swarm references to the source code, so you have to
upload all source files in addition to the metadata file. For IPFS, the hash contained
in the CID returned by ``ipfs add`` (not the direct sha2-256 hash of the file)
shall match with the one contained in the bytecode.
>>>>>>> v0.8.17

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
<<<<<<< HEAD
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
=======
        // Required for Solidity: Version of the compiler
        "version": "0.8.2+commit.661d1103",
        // Optional: Hash of the compiler binary which produced this output
        "keccak256": "0x123..."
      },
      // Required: Compilation source files/source units, keys are file paths
      "sources":
      {
        "myDirectory/myFile.sol": {
          // Required: keccak256 hash of the source file
          "keccak256": "0x123...",
          // Required (unless "content" is used, see below): Sorted URL(s)
          // to the source file, protocol is more or less arbitrary, but an
          // IPFS URL is recommended
          "urls": [ "bzz-raw://7d7a...", "dweb:/ipfs/QmN..." ],
          // Optional: SPDX license identifier as given in the source file
>>>>>>> v0.8.17
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
<<<<<<< HEAD
        // Solidity için mecburi: yeniden eşlemelerin sıralı listesi
=======
        // Required for Solidity: Sorted list of import remappings
>>>>>>> v0.8.17
        "remappings": [ ":g=/dir" ],
        // Opsiyonel: Optimize edici ayarları. "enabled" vs "runs" anahtarları 
        // artık kullanılmamaktadır ve geriye dönük uyumluluk için verilmiştir.
        "optimizer": {
          "enabled": true,
          "runs": 500,
          "details": {
            // peephole'ün varsayılanı "true"dur
            "peephole": true,
            // inliner'ın varsayılanı "true"dur
            "inliner": true,
            // jumpdestRemover'ın varsayılanı "true"dur
            "jumpdestRemover": true,
            "orderLiterals": false,
            "deduplicate": false,
            "cse": false,
            "constantOptimizer": false,
            "yul": true,
            // Opsiyonel: Yalnızca "yul" "true" ise mevcut
            "yulDetails": {
              "stackAllocation": false,
              "optimizerSteps": "dhfoDgvulfnTUtnIf..."
            }
          }
        },
        "metadata": {
<<<<<<< HEAD
          // Girdi json'da kullanılan ayarın aynısı. Varsayılan: "false"
=======
          // Reflects the setting used in the input json, defaults to "false"
>>>>>>> v0.8.17
          "useLiteralContent": true,
          // Girdi json'da kullanılan ayarın aynısı. Varsayılan: "ipfs"
          "bytecodeHash": "ipfs"
        },
<<<<<<< HEAD
        // Solidity için mecburi: Bu meta veri hangisi için yaratıldıysa o
        // dosya ile sözleşme veya kütüphanenin adı.
=======
        // Required for Solidity: File path and the name of the contract or library this
        // metadata is created for.
>>>>>>> v0.8.17
        "compilationTarget": {
          "myDirectory/myFile.sol": "MyContract"
        },
        // Solidity için mecburi: Kullanılan kütüphanelerin adresleri
        "libraries": {
          "MyLib": "0x123123..."
        }
      },
      // Mecburi: Sözleşme için oluşturulan bilgiler
      "output":
      {
<<<<<<< HEAD
        // Mecburi: Sözleşmenin ABI tanımı
        "abi": [/* ... */],
        // Mecburi: Sözleşmenin NatSpec kullanıcı dokümantasyonu
        "userdoc": [/* ... */],
        // Mecburi: Sözleşmenin NatSpec geliştirici dokümantasyonu
        "devdoc": [/* ... */]
=======
        // Required: ABI definition of the contract. See "Contract ABI Specification"
        "abi": [/* ... */],
        // Required: NatSpec developer documentation of the contract.
        "devdoc": {
          "version": 1 // NatSpec version
          "kind": "dev",
          // Contents of the @author NatSpec field of the contract
          "author": "John Doe",
          // Contents of the @title NatSpec field of the contract
          "title": "MyERC20: an example ERC20"
          // Contents of the @dev NatSpec field of the contract
          "details": "Interface of the ERC20 standard as defined in the EIP. See https://eips.ethereum.org/EIPS/eip-20 for details",
          "methods": {
            "transfer(address,uint256)": {
              // Contents of the @dev NatSpec field of the method
              "details": "Returns a boolean value indicating whether the operation succeeded. Must be called by the token holder address",
              // Contents of the @param NatSpec fields of the method
              "params": {
                "_value": "The amount tokens to be transferred",
                "_to": "The receiver address"
              }
              // Contents of the @return NatSpec field.
              "returns": {
                // Return var name (here "success") if exists. "_0" as key if return var is unnamed
                "success": "a boolean value indicating whether the operation succeeded"
              }
            }
          },
          "stateVariables": {
            "owner": {
              // Contents of the @dev NatSpec field of the state variable
              "details": "Must be set during contract creation. Can then only be changed by the owner"
            }
          }
          "events": {
             "Transfer(address,address,uint256)": {
               "details": "Emitted when `value` tokens are moved from one account (`from`) toanother (`to`)."
               "params": {
                 "from": "The sender address"
                 "to": "The receiver address"
                 "value": "The token amount"
               }
             }
          }
        },
        // Required: NatSpec user documentation of the contract
        "userdoc": {
          "version": 1 // NatSpec version
          "kind": "user",
          "methods": {
            "transfer(address,uint256)": {
              "notice": "Transfers `_value` tokens to address `_to`"
            }
          },
          "events": {
            "Transfer(address,address,uint256)": {
              "notice": "`_value` tokens have been moved from `from` to `to`"
            }
          }
        }
>>>>>>> v0.8.17
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
===============================================

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

<<<<<<< HEAD
Meta veriyi indirmek için yüklenen bayt kodun sonu bu örüntüye uyuyor mu diye 
bakılabilir ve elde edilen IPFS hash'i ile dosya indirilebilir. 
=======
So in order to retrieve the data, the end of the deployed bytecode can be checked
to match that pattern and the IPFS hash can be used to retrieve the file (if pinned/published).
>>>>>>> v0.8.17

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
=====================================================

Meta veri şu şekilde kullanılır: Bir sözleşmeyle etkileşime geçmek isteyen 
bir bileşen (örn. Mist veya başka bir cüzdan) sözleşmenin kodunu indirir. Daha
sonra bu koddan IPFS/Swarm hash'ini elde eder ve meta veri dosyası indirilir.
Bu dosya yukarıdaki yapıya uygun şekilde JSON formatında çözülür.

<<<<<<< HEAD
İlgili bileşen, ABI'ı otomatik olarak basit bir kullanıcı arayüzü oluşturmak
için kullanabilir.
=======
The metadata is used in the following way: A component that wants to interact
with a contract (e.g. a wallet) retrieves the code of the contract.
It decodes the CBOR encoded section containing the IPFS/Swarm hash of the
metadata file. With that hash, the metadata file is retrieved. That file
is JSON-decoded into a structure like above.
>>>>>>> v0.8.17

Ek olarak cüzdan, kullanıcı bir sözleşmeyle etkileşime geçerken kullanıcıdan
işlem için imza onayı istemenin yanında kullanıcıya bir onay mesajı göstermek 
için NatSpec kullanıcı dokümantasyonunu kullanabilir. 

<<<<<<< HEAD
Daha fazla bilgi için :doc:`Ethereum Natural Language Specification (NatSpec) format <natspec-format>` ını okuyunuz.
=======
Furthermore, the wallet can use the NatSpec user documentation to display a human-readable confirmation message to the user
whenever they interact with the contract, together with requesting
authorization for the transaction signature.
>>>>>>> v0.8.17

Kaynak Kodu Doğrulama için Kullanım
====================================

Derlemeyi doğrulamak için kaynaklar meta veri dosyasında verilen bağlantılar ile
IPFS/Swarm'dan indirilebilir. 
Derleyicinin ("resmi" sürüm mü değil mi diye bakılan) doğru sürümü ilgili girdiye
belirtilen ayarlar ile çağrılır. (Derlemeden) elde edilen bayt kodu (sözleşmeyi) yaratma 
işleminin verisi ile veya ``CREATE`` işlem kodu verisi ile karşılaştırılır. Bu, hash'i 
zaten bayt kodun bir parçası olduğu için meta veriyi otomatik olarak doğrular. Fazladan
veri, kullanıcıya sunulan arayüze uygun şekilde çözülmesi gereken constructor girdi verisidir.

`sourcify <https://github.com/ethereum/sourcify>`_
(`npm paketi <https://www.npmjs.com/package/source-verify>`_) deposunda bu özelliği nasıl 
kullanabileceğinize dair kodu görebilirsiniz.