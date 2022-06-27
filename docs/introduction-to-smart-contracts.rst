###############################
Akıllı Sözleşmelere Giriş
###############################

.. _simple-smart-contract:

***********************
Basit Bir Akıllı Sözleşme
***********************

Bir değişkenin değerini atayan ve bunu diğer sözleşmelerin erişimine sunan temel bir örnekle başlayalım.
Şu an her şeyi anlamadıysanız sorun değil, birazdan daha fazla ayrıntıya gireceğiz.

Depolama
===============

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.16 <0.9.0;

    contract SimpleStorage {
        uint storedData;

        function set(uint x) public {
            storedData = x;
        }

        function get() public view returns (uint) {
            return storedData;
        }
    }

İlk satır size kaynak kodunun GPL 3.0 sürümü altında lisanslanmış
olduğunu söyler. Kaynak kodu yayınlamanın varsayılan olduğu bir ortamda
makine tarafından okunabilen lisans belirleyicileri önemlidir.

Bir sonraki satır, kaynak kodun Solidity 0.4.16 sürümü veya 0.9.0 sürümüne
kadar olan fakat bu sürümü içermeyen daha yeni bir sürümü için yazıldığını belirtir.
Bu, sözleşmenin farklı sonuçlar verebileceği yeni bir derleyici sürümü ile derlenemez olmasını sağlamak içindir.
:ref:`Pragmalar<pragma>`, derleyiciler için kaynak kodun nasıl ele alınacağına ilişkin ortak talimatlardır
(ör. `pragma once <https://en.wikipedia.org/wiki/Pragma_once>`_).

Solidity kapsamında olan bir sözleşme, Ethereum blockchain ağında belirli bir adreste bulunan kod (*fonksiyonlar*) ve veri (*durum*) koleksiyonudur.
``uint storeData;`` satırı, ``uint`` türünde (*256* bitlik bir *u*\nsigned (pozitif) *int*\eger ) ``storedData`` adlı bir
durum değişkeni tanımlar . Bunu, veritabanını yöneten kodun fonksiyonlarını
çağırarak sorgulayabileceğiniz ve değiştirebileceğiniz, veritabanındaki bir bilgi olarak düşünebilirsiniz.
Ve bu örnektede, "set" ve “get” fonksiyonları değişkenin değerini değiştirmek veya çağırmak için tanımlanmıştır.

Mevcut sözleşmenizde bulunan bir durum değişkenine erişmek için genellikle ``this.`` önekini eklemezsiniz, doğrudan adı üzerinden erişirsiniz.
Diğer bazı dillerin aksine, bu öneki atlamak sadece kodun görünüşünü iyileştirmek için değildir. Bu düzenleme değişkene
erişmek için de tamamen farklı sonuçlar doğurabilir, fakat bu konuya daha sonra detaylıca değineceğiz.

Bu sözleşme, (Ethereum temel yapısı nedeniyle) herhangi birinin, tanımladığınız bu
değişkenin (yayınlamanızı engelleyecek (uygulanabilir) bir yol olmadan) dünyadaki herkes
tarafından erişilebilmesi için saklamaktan başka pek bir işe yaramıyor.
Herhangi biri ``set`` fonksiyonunu farklı bir değer tanımlamak için tekrar çağırabilir
ve değişkeninizin üzerine yazdırabilir, fakat bu değiştirilen değişkenin kayıtları blok zincirinin
geçmişinde saklanmaya devam eder. İlerleyen zamanlarda, değişkeni yalnızca sizin değiştirebilmeniz
için nasıl erişim kısıtlamalarını koyabileceğinizi göreceksiniz.

.. warning::
    Unicode metni kullanırken dikkatli olunması gerekir, çünkü benzer görünümlü (hatta aynı)
    karakterler farklı kod işlevlerine sahip olabilir ve farklı bir bayt dizisi olarak kodlanabilirler.

.. note::
    Sözleşmenizin tüm tanımlayıcı değerleri (sözleşme isimleri, fonksiyon isimleri ve değişken
    isimleri) ASCII karakter seti ile sınırlıdır. UTF-8 ile kodlanmış verileri string değişkenlerinde
    saklamak mümkündür.

.. index:: ! subcurrency

Alt Para Birimi Örneği
===================

Aşağıdaki sözleşme, bir kripto para biriminin en basit biçiminin bir örneğidir.
Bu sözleşme, yalnızca sözleşme sahibinin (oluşturucusunun) yeni paralar oluşturmasına
izin verir (farklı para oluşturma planları ayarlamak mümkündür).
Herkes kullanıcı adı ve parolayla kayıt olmadan birbirine para gönderebilir.
Tüm bunlar için tek ihtiyacınız olan şey sadece Ethereum anahtar çiftidir.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract Coin {
        // "public" anahtar kelimesi, değişkenleri
        // diğer sözleşmeler tarafından erişilebilir kılar
        address public minter;
        mapping (address => uint) public balances;

        // Event'ler müşterilerin sözleşme üzerinde yaptığınız
        // değişikliklere tepki vermelerini sağlar
        event Sent(address from, address to, uint amount);

        // Constructor kodu sadece sözleşme
        // oluşturulduğunda çalışır
        constructor() {
            minter = msg.sender;
        }

        // Yeni oluşturulan bir miktar parayı adrese gönderir
        // Yalnızca sözleşme yaratıcısı tarafından çağrılabilir
        function mint(address receiver, uint amount) public {
            require(msg.sender == minter);
            balances[receiver] += amount;
        }

        // Error'ler bir işlemin neden başarısız olduğu hakkında
        // bilgi almanızı sağlar. Fonksiyonu çağıran kişiye
        // bilgilendirme amacıyla bir sonuç döndürürler.
        error InsufficientBalance(uint requested, uint available);

        // Fonksiyonu çağıran kişinin var olan paralarından
        // alıcı adrese para gönderir.
        function send(address receiver, uint amount) public {
            if (amount > balances[msg.sender])
                revert InsufficientBalance({
                    requested: amount,
                    available: balances[msg.sender]
                });

            balances[msg.sender] -= amount;
            balances[receiver] += amount;
            emit Sent(msg.sender, receiver, amount);
        }
    }

Bu sözleşmede bazı yeni kavramlar tanıtılıyor, hadi hepsini teker teker inceleyelim.

``address public minter;`` satırı :ref:`address<address>` türündeki bir durum değişkenini tanımlıyor.
``address`` değişken türü, herhangi bir aritmetik işlemin uygulanmasına izin vermeyen 160 bitlik bir değerdir.
Sözleşmelerin adreslerini veya :ref:`harici hesaplar<accounts>`'a ait bir anahtar çiftinin
teki olan public key hash'ini saklamak için uygundur.

``public`` anahtar sözcüğü otomatik olarak durum değişkeninin mevcut değerine sözleşme dışından da erişmenizi sağlayan
bir fonksiyonu oluşturur. Bu anahtar kelime olmadan, diğer sözleşmelerin bu değişkene erişme yolu yoktur.
Derleyici tarafından oluşturulan fonksiyonun kodu aşağıdakine eşdeğerdir
(şimdilik ``external`` ve ``view`` i göz ardı edin):

.. code-block:: solidity

    function minter() external view returns (address) { return minter; }

Yukarıdaki gibi bir fonksiyonu koda kendiniz de ekleyebilirsiniz, fakat aynı isimde olan bir fonksiyon ve
durum değişkeniniz olur. Bunu yapmanıza gerek yoktur, bu işi derleyici sizin yerinize halleder.

.. index:: mapping

Diğer satır olan ``mapping (address => uint) public balances;`` de bir public durum değişkeni oluşturuyor,
fakat bu değişken biraz daha karmaşık bir veri yapısına sahip. Burada bulunan
ref:`mapping <mapping-types>` türü adresleri :ref:`unsigned integers <integers>` ile eşliyor.

Mappingler, her olası anahtarın başlangıçtan itibaren var olduğu ve bayt temsilinin tamamı sıfır
olan bir değerle eşlendiği şekilde sanal bir şekilde başlatılan `hash tabloları <https://en.wikipedia.org/wiki/Hash_table>`_
olarak görülebilir. Ancak, bir mapping’in ne tüm anahtarlarının ne de tüm değerlerinin bir listesini
elde etmek mümkün değildir. Bunun için mapping'e eklediğiniz değerleri kaydedin veya buna gerek duyulmayacak
bir durumda kullanın. Hatta daha da iyisi bir liste tutun ya da daha uygun bir veri türünü kullanmayı deneyin.

``public`` anahtar kelimesi ile oluşturulmuş aşağıda bulunan :ref:`çağırıcı fonksiyon<getter-functions>`, mapping örneğine
göre biraz daha karmaşık bir yapıya sahiptir:

.. code-block:: solidity

    function balances(address account) external view returns (uint) {
        return balances[account];
    }

Bu fonksiyonu tek bir hesabın bakiyesini sorgulamak için kullanabilirsiniz.

.. index:: event

``event Sent(address from, address to, uint amount);`` satırı ``send`` fonksiyonunun son
satırında yayınlanan (emit) bir :ref:`”olay (event)" <events>` bildirir.
Web uygulamaları gibi Ethereum istemcileri, blockchainde yayılan (emit) bu olaylardan (event) fazla maliyet olmadan veri alabilir.
Event yayınlanır yayınlanmaz, veri alıcısı ``from``, ``to`` ve ``amount`` argümanlarını alır,
bu da alım satım işlemlerinin takip edilmesini mümkün kılar.

Bu olayı(event) dinlemek amacıyla, ``Coin`` sözleşme nesnesini oluşturmak için `web3.js <https://github.com/ethereum/web3.js/>`_
kütüphanesini kullanan aşağıdaki JavaScript kodunu kullanabilirsiniz. Ve herhangi bir kullanıcı arayüzü (user interface),
otomatik olarak oluşturulan ``balances`` fonksiyonunu yukarıdan sizin için çağırır::

    Coin.Sent().watch({}, '', function(error, result) {
        if (!error) {
            console.log("Coin transfer: " + result.args.amount +
                " coins were sent from " + result.args.from +
                " to " + result.args.to + ".");
            console.log("Balances now:\n" +
                "Sender: " + Coin.balances.call(result.args.from) +
                "Receiver: " + Coin.balances.call(result.args.to));
        }
    })

.. index:: coin

:ref:`constructor<constructor>` fonksiyonu, sözleşmenin oluşturulması sırasında çalıştırılan
ve daha sonra çağırılamayan özel bir fonksiyondur. Bu örnekte ise constructor fonksiyonu sözleşmeyi oluşturan kişinin adresini kalıcı olarak depoluyor.
``msg`` değişkeni (``tx`` ve ``block`` ile birlikte), blockchain'e erişim izini veren özellikleri olan :ref:`özel bir global değişken <special-variables-functions>`dir.
``msg.sender`` her zaman varsayılan fonksiyonu (external) çağıran kişinin adresini döndürür.

Sözleşmeyi oluşturan ve hem kullanıcıların hemde sözleşmelerin çağırabileceği fonksiyonlar ``mint`` ve ``send``dir.

``mint`` fonksiyonu yeni oluşturulan bir miktar parayı başka bir adrese gönderir. ref:`require <assert-and-require>`
fonksiyon çağrısı, karşılanmadığı takdirde tüm değişiklikleri geri döndüren koşulları tanımlar.
Bu örnekte, ``require(msg.sender == minter);`` yalnızca sözleşme yaratıcısının ``mint`` fonksiyonunu çağırabilmesini sağlar.
Genel olarak, sözleşme yaratıcısı istediği kadar para basabilir, fakat belirili bir noktadan sonra bu durum "owerflow" adı verilen bir olaya yol açacaktır.
Varsayılan :ref:`Checked arithmetic <unchecked>` nedeniyle, ``balances[receiver] += amount;`` ifadesi
taşarsa, yani  ``balances[receiver] + amount`` ifadesi ``uint`` maksimum değerinden (``2**256 - 1``)
büyükse işlemin geri döndürüleceğini unutmayın. Bu, ``send`` fonksiyonundaki
``balances[receiver] += amount;`` ifadesi için de geçerlidir.

:ref:`Hatalar <hatalar>`, bir koşulun veya işlemin neden başarısız olduğu hakkında
fonksiyonu çağıran kişiye daha fazla bilgi sağlamanıza olanak tanır. Hatalar
:ref:`revert ifadesi <revert-statement>` ile birlikte kullanılır. ``revert`` ifadesi,
``require`` fonksiyonuna benzer bir şekilde tüm değişiklikleri koşulsuz olarak iptal eder
ve geri alır, ancak aynı zamanda bir hatanın daha kolay hata ayıklanabilmesi veya tepki
verilebilmesi için hatanın adını ve çağıran kişiye (ve nihayetinde ön uç uygulamaya veya
blok gezginine) sağlanacak ek verileri sağlamanıza olanak tanır.

‘'send'' fonksiyonu, herhangi biri tarafından (hali hazırda bir miktar paraya sahip olan)
başka birine para göndermek için kullanılabilir. Gönderen kişinin göndermek için yeterli
bakiyesi yoksa, ``if`` koşulu doğru (true) olarak değerlendirilir. Sonuç olarak ``revert``
fonksiyonu, ``InsufficientBalance``(Yetersiz bakiye) hatasını kullanarak göndericiye hata
ayrıntılarını sağlarken işlemin başarısız olmasına neden olacaktır.

.. note::
    Bu sözleşmeyi bir adrese para (coin) göndermek için kullanırsanız, bir blockchain
    gezgininde (explorer) o adrese baktığınızda hiçbir şey göremezsiniz, çünkü para (coin)
    gönderdiğiniz kayıt ve değişen bakiyeler yalnızca bu coin sözleşmesinin veri deposunda
    saklanır. Event’leri kullanarak, yeni coin'inizin işlemlerini ve bakiyelerini izleyen
    bir "blockchain gezgini (explorer)" oluşturabilirsiniz, ancak coin sahiplerinin adreslerini
    değil, coin'in sözleşme adresini incelemeniz gerekir.

.. _blockchain-basics:

*****************
Blockchain Temelleri
*****************

Bir kavram olarak Blockchain'leri anlamak programcılar için çok zor değildir. Bunun nedeni,
komplikasyonların (madencilik (mining), `hashing <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_,
`elliptic-curve cryptography <https://en.wikipedia.org/wiki/Elliptic_curve_cryptography>`_,
`peer-to-peer networks <https://en.wikipedia.org/wiki/Peer-to-peer>`_, etc.) çoğunun sadece platform
için belirli bir dizi özellik ve vaat sağlamak için orada olmasıdır. Bu özellikleri olduğu gibi
kabul ettiğinizde, altta yatan teknoloji hakkında endişelenmenize gerek kalmaz - yoksa  Amazon'un
AWS'sini kullanmak için dahili olarak nasıl çalıştığını bilmek zorunda mısınız?

.. index:: transaction

İşlemler (Transactions)
============

Blockchain, küresel olarak paylaşılan, işlemsel bir veritabanıdır.
Bu, herkesin yalnızca ağa katılarak veritabanındaki girdileri okuyabileceği anlamına gelir.
Veritabanındaki bir şeyi değiştirmek istiyorsanız, diğerleri tarafından kabul edilmesi gereken
sözde bir işlem oluşturmanız gerekir.
İşlem kelimesi, yapmak istediğiniz değişikliğin (aynı anda iki değeri değiştirmek istediğinizi
varsayın) ya hiç yapılmadığını ya da tamamen uygulanmasını ifade eder. Ayrıca, işleminiz
veritabanına uygulanırken başka hiçbir işlem onu değiştiremez.

Örnek olarak, elektronik para birimindeki tüm hesapların bakiyelerini
listeleyen bir tablo hayal düşünün. Bir hesaptan diğerine transfer talep edilirse,
veri tabanının işlemsel yapısı, tutar bir hesaptan çıkarılırsa, her zaman diğer hesaba
eklenmesini sağlar. Herhangi bir nedenden dolayı tutarın hedef hesaba eklenmesi mümkün değilse,
kaynak hesaptaki bakiye de değiştirilmez.

Ayrıca, bir işlem her zaman gönderen (yaratıcı) tarafından şifreli olarak imzalanır. Bu,
veritabanındaki belirli değişikliklere erişimi korumayı kolaylaştırır. Kripto para birimi
örneğinde, basit bir kontrol, yalnızca anahtarları hesaba katan bir kişinin hesaptan para
aktarabilmesini sağlar.

.. index:: ! block

Bloklar
======

Üstesinden gelinmesi gereken en büyük engellerden biri (Bitcoin açısından) "çifte harcama
saldırısı" olarak adlandırılan bir olaydır: Ağda bir cüzdanı boşaltmak isteyen eşzamanlı iki
işlem varsa ne olur? İşlemlerden sadece biri geçerli olabilir, tipik olarak önce kabul edilmiş
olanı. Sorun, “ilk” in eşler arası ağda (peer-to-peer network) nesnel bir terim olmamasıdır.

Özetle tüm bunları düşünmenize gerk yoktur. İşlemlerin global olarak kabul edilen bir sırası
sizin için seçilecek ve çatışma çözülecektir. İşlemler "blok" adı verilen bir yapıda bir araya
getirilecek ve daha sonra yürütülerek tüm katılımcı düğümler arasında dağıtılacaktır. Eğer iki
işlem birbiriyle çelişirse, ikinci olan işlem reddedilecek ve bloğun bir parçası olmayacaktır.

Bu bloklar zaman içinde doğrusal bir dizi oluşturur ve “blockchain" kelimesi de zaten buradan
türemiştir. Bloklar zincire oldukça düzenli aralıklarla eklenir - Ethereum için bu süre kabaca
her 17 saniye birdir.

"Sıra seçim mekanizmasının" ("madencilik" olarak adlandırılır) bir parçası olarak zaman zaman
bloklar geri alınabilir, ancak bu sadece zincirin en "ucunda" gerçekleşir. Belirli bir bloğun üzerine
ne kadar çok blok eklenirse, bu bloğun geri döndürülme olasılığı o kadar azalır. Yani işlemleriniz
geri alınabilir ve hatta blockchain'den kaldırılabilir, ancak ne kadar uzun süre beklerseniz, bu
olasılık o kadar azalacaktır.

.. note::

    İşlemlerin bir sonraki bloğa veya gelecekteki herhangi bir bloğa dahil
    edileceği garanti edilmez, çünkü işlemin hangi bloğa dahil edileceğini belirlemek,
    işlemi gönderen kişiye değil madencilere bağlıdır.

    Sözleşmenizin gelecekteki çağrılarını planlamak istiyorsanız, bir akıllı sözleşme
    otomasyon aracı veya bir oracle hizmeti kullanabilirsiniz.

.. _the-ethereum-virtual-machine:

.. index:: !evm, ! ethereum virtual machine

****************************
Ethereum Sanal Makinası
****************************

Genel Bakış
========

Ethereum Sanal Makinesi veya ESM, Ethereum'daki akıllı sözleşmeler
için çalışma ortamıdır. Bu alan yalnızca korumalı bir alan değil, aynı
zamanda tamamen yalıtılmış bir alandır; yani ESM içinde çalışan kodun ağa,
dosya sistemine ya da diğer süreçlere erişimi yoktur. Akıllı sözleşmelerin
diğer akıllı sözleşmelere erişimi bile sınırlıdır.

.. index:: ! account, address, storage, balance

.. _accounts:

Hesaplar
========

Ethereum'da aynı adres alanını paylaşan iki tür hesap vardır:
Public anahtar çiftleri (yani insanlar) tarafından kontrol edilen
**harici hesaplar** ve hesapla birlikte depolanan kod tarafından kontrol
edilen **sözleşme hesapları**.

Harici bir hesabın adresi açık (public) anahtardan belirlenirken, bir sözleşmenin
adresi sözleşmenin oluşturulduğu anda belirlenir ("nonce" olarak adlandırılan yaratıcı
adres ve bu adresten gönderilen işlem sayısından türetilir).

Hesabın kod depolayıp depolamadığına bakılmaksızın, iki tür ESM tarafından
eşit olarak değerlendirilir.

Her hesabın, 256-bit sözcükleri **storage** adı verilen 256-bit sözcüklere e
şleyen kalıcı bir anahtar-değer deposu vardır.

Ayrıca, her hesabın Ether cinsinden bir **bakiyesi** vardır (tam olarak "Wei"
cinsinden, ``1 ether`` ``10**18 wei``dir) ve bu Ether içeren işlemler gönderilerek
değiştirilebilir.

.. index:: ! transaction

İşlemler
============

İşlem, bir hesaptan diğerine gönderilen bir mesajdır (aynı veya boş olabilir, aşağıya bakınız).
İkili verileri ("yük" olarak adlandırılır) ve Ether içerebilir.

Hedef hesap kod içeriyorsa, bu kod çalıştırılır ve sonucunda elde erilen veri yükü girdi olarak
kabul edilir.

Hedef hesap ayarlanmamışsa (işlemin alıcısı yoksa veya alıcı ``null``
olarak ayarlanmışsa), işlem **yeni bir sözleşme** oluşturur.
Daha önce de belirtildiği gibi, bu sözleşmenin adresi sıfır adres değil,
göndericiden ve gönderilen işlem sayısından ("nonce") türetilen bir adrestir.
Böyle bir sözleşme oluşturma işleminin yükü ESM bytecode'u olarak alınır ve çalıştırılır.
Bu uygulamanın çıktı verileri kalıcı olarak sözleşmenin kodu olarak saklanır.
Bu, bir sözleşme oluşturmak için sözleşmenin gerçek kodunu değil, aslında yürütüldüğünde
bu kodu döndüren kodu gönderdiğiniz anlamına gelir.

.. note::
  Bir sözleşme oluşturulurken, kodu hala boştur.
  Bu nedenle, constructor fonksiyonu çalışmayı bitirene
  kadar yapım aşamasındaki sözleşmeyi geri çağırmamalısınız.

.. index:: ! gas, ! gas price

Gas
===

Oluşturulduktan sonra, her işlem, işlemin kaynağı (``tx.origin``) tarafından
ödenmesi gereken belirli bir **gas** miktarı ile ücretlendirilir.
ESM işlemi gerçekleştirirken, gas belirli kurallara göre kademeli olarak tüketilir.
Gas herhangi bir noktada tükenirse (yani negatif olursa), yürütmeyi sona erdiren ve
mevcut çağrı çerçevesinde durumunda yapılan tüm değişiklikleri geri alan bir out-of-gas
(gas bitti) istisnası tetiklenir.

Bu mekanizma, ESM'in çalışma süresinin tasarruflu bir şekilde kullanılmasını teşvik eder
ve aynı zamanda ESM yürütücülerinin (yani madencilerin / stakerların) çalışmalarını telafi eder.
Her blok maksimum miktarda gaza sahip olduğundan, bir bloğu doğrulamak için gereken iş miktarını da sınırlanmış olur.

**Gas ücreti**, işlemin yaratıcısı tarafından yani gönderen hesabından ``gaz_ücreti * gaz`` miktarında ödemek zorunda olduğu bir değerdir.
Uygulamadan sonra bir miktar gaz kalırsa, bu miktar işlemi çalıştıran kişiye iade edilir.
Değişikliği geri döndüren bir istisna olması durumunda, kullanılmış gas'ın iadesi yapılmaz.

ESM yürütücüleri bir işlemi ağa dahil edip etmemeyi seçebildiğinden, işlem gönderenler
düşük bir gas fiyatı belirleyerek sistemi kötüye kullanamazlar.

.. index:: ! storage, ! memory, ! stack

Depolama, Bellek ve Yığın
=============================

Ethereum Sanal Makinesi'nin veri depolayabileceği üç alan vardır:
storage (depolama), memory (bellek) ve stack (yığın).

Her hesap, fonksiyon çağrıları ve işlemler arasında kalıcı olan **storage**
adlı bir veri alanına sahiptir. Storage is a key-value store that maps 256-bit words to 256-bit words.
It is not possible to enumerate storage from within a contract, it is
comparatively costly to read, and even more to initialise and modify storage. Because of this cost,
you should minimize what you store in persistent storage to what the contract needs to run.
Store data like derived calculations, caching, and aggregates outside of the contract.
A contract can neither read nor write to any storage apart from its own.

The second data area is called **memory**, of which a contract obtains
a freshly cleared instance for each message call. Memory is linear and can be
addressed at byte level, but reads are limited to a width of 256 bits, while writes
can be either 8 bits or 256 bits wide. Memory is expanded by a word (256-bit), when
accessing (either reading or writing) a previously untouched memory word (i.e. any offset
within a word). At the time of expansion, the cost in gas must be paid. Memory is more
costly the larger it grows (it scales quadratically).

The EVM is not a register machine but a stack machine, so all
computations are performed on a data area called the **stack**. It has a maximum size of
1024 elements and contains words of 256 bits. Access to the stack is
limited to the top end in the following way:
It is possible to copy one of
the topmost 16 elements to the top of the stack or swap the
topmost element with one of the 16 elements below it.
All other operations take the topmost two (or one, or more, depending on
the operation) elements from the stack and push the result onto the stack.
Of course it is possible to move stack elements to storage or memory
in order to get deeper access to the stack,
but it is not possible to just access arbitrary elements deeper in the stack
without first removing the top of the stack.

.. index:: ! instruction

Instruction Set
===============

The instruction set of the EVM is kept minimal in order to avoid
incorrect or inconsistent implementations which could cause consensus problems.
All instructions operate on the basic data type, 256-bit words or on slices of memory
(or other byte arrays).
The usual arithmetic, bit, logical and comparison operations are present.
Conditional and unconditional jumps are possible. Furthermore,
contracts can access relevant properties of the current block
like its number and timestamp.

For a complete list, please see the :ref:`list of opcodes <opcodes>` as part of the inline
assembly documentation.

.. index:: ! message call, function;call

Message Calls
=============

Contracts can call other contracts or send Ether to non-contract
accounts by the means of message calls. Message calls are similar
to transactions, in that they have a source, a target, data payload,
Ether, gas and return data. In fact, every transaction consists of
a top-level message call which in turn can create further message calls.

A contract can decide how much of its remaining **gas** should be sent
with the inner message call and how much it wants to retain.
If an out-of-gas exception happens in the inner call (or any
other exception), this will be signaled by an error value put onto the stack.
In this case, only the gas sent together with the call is used up.
In Solidity, the calling contract causes a manual exception by default in
such situations, so that exceptions "bubble up" the call stack.

As already said, the called contract (which can be the same as the caller)
will receive a freshly cleared instance of memory and has access to the
call payload - which will be provided in a separate area called the **calldata**.
After it has finished execution, it can return data which will be stored at
a location in the caller's memory preallocated by the caller.
All such calls are fully synchronous.

Calls are **limited** to a depth of 1024, which means that for more complex
operations, loops should be preferred over recursive calls. Furthermore,
only 63/64th of the gas can be forwarded in a message call, which causes a
depth limit of a little less than 1000 in practice.

.. index:: delegatecall, callcode, library

Delegatecall / Callcode and Libraries
=====================================

There exists a special variant of a message call, named **delegatecall**
which is identical to a message call apart from the fact that
the code at the target address is executed in the context (i.e. at the address) of the calling
contract and ``msg.sender`` and ``msg.value`` do not change their values.

This means that a contract can dynamically load code from a different
address at runtime. Storage, current address and balance still
refer to the calling contract, only the code is taken from the called address.

This makes it possible to implement the "library" feature in Solidity:
Reusable library code that can be applied to a contract's storage, e.g. in
order to implement a complex data structure.

.. index:: log

Logs
====

It is possible to store data in a specially indexed data structure
that maps all the way up to the block level. This feature called **logs**
is used by Solidity in order to implement :ref:`events <events>`.
Contracts cannot access log data after it has been created, but they
can be efficiently accessed from outside the blockchain.
Since some part of the log data is stored in `bloom filters <https://en.wikipedia.org/wiki/Bloom_filter>`_, it is
possible to search for this data in an efficient and cryptographically
secure way, so network peers that do not download the whole blockchain
(so-called "light clients") can still find these logs.

.. index:: contract creation

Create
======

Contracts can even create other contracts using a special opcode (i.e.
they do not simply call the zero address as a transaction would). The only difference between
these **create calls** and normal message calls is that the payload data is
executed and the result stored as code and the caller / creator
receives the address of the new contract on the stack.

.. index:: ! selfdestruct, deactivate

Deactivate and Self-destruct
============================

The only way to remove code from the blockchain is when a contract at that
address performs the ``selfdestruct`` operation. The remaining Ether stored
at that address is sent to a designated target and then the storage and code
is removed from the state. Removing the contract in theory sounds like a good
idea, but it is potentially dangerous, as if someone sends Ether to removed
contracts, the Ether is forever lost.

.. warning::
    Even if a contract is removed by ``selfdestruct``, it is still part of the
    history of the blockchain and probably retained by most Ethereum nodes.
    So using ``selfdestruct`` is not the same as deleting data from a hard disk.

.. note::
    Even if a contract's code does not contain a call to ``selfdestruct``,
    it can still perform that operation using ``delegatecall`` or ``callcode``.

If you want to deactivate your contracts, you should instead **disable** them
by changing some internal state which causes all functions to revert. This
makes it impossible to use the contract, as it returns Ether immediately.


.. index:: ! precompiled contracts, ! precompiles, ! contract;precompiled

.. _precompiledContracts:

Precompiled Contracts
=====================

There is a small set of contract addresses that are special:
The address range between ``1`` and (including) ``8`` contains
"precompiled contracts" that can be called as any other contract
but their behaviour (and their gas consumption) is not defined
by EVM code stored at that address (they do not contain code)
but instead is implemented in the EVM execution environment itself.

Different EVM-compatible chains might use a different set of
precompiled contracts. It might also be possible that new
precompiled contracts are added to the Ethereum main chain in the future,
but you can reasonably expect them to always be in the range between
``1`` and ``0xffff`` (inclusive).
