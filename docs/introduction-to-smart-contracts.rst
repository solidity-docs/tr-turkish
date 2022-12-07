###############################
Akıllı Sözleşmelere Giriş
###############################

.. _simple-smart-contract:

**************************
Basit Bir Akıllı Sözleşme
**************************

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
olduğunu söyler. Kaynak kodu yayınlamanın standart olduğu bir ortamda
makine tarafından okunabilen lisans belirleyicileri önemlidir.

Bir sonraki satır, kaynak kodun Solidity 0.4.16'dan başlayarak 0.9.0'a kadar (0.9.0 hariç) olan sürümler için yazıldığını belirtir.
Bu, sözleşmenin farklı sonuçlar verebileceği yeni bir derleyici sürümü ile derlenemez olmasını sağlamak içindir.
:ref:`Pragmalar<pragma>`, derleyiciler için kaynak kodun nasıl ele alınacağına ilişkin ortak talimatlardır
(ör. `pragma once <https://en.wikipedia.org/wiki/Pragma_once>`_).

Solidity kapsamında olan bir sözleşme, Ethereum blok zinciri ağında belirli bir adreste bulunan kod (*fonksiyonlar*) ve veri (*durum*) bütünüdür.
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
=======================

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

        // Event'ler istemcilerin sözleşme üzerinde yaptığınız
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

Mapping'ler, sanal bir şekilde tanımlanıp değer atanan `hash tabloları <https://en.wikipedia.org/wiki/Hash_table>`_
olarak görülebilir. Bu yapıda mümkün olan her anahtar değeri tanımlandığı andan itibaren bulunur ve bu anahtarların
eşlendiği değer (byte gösterminde) sıfırdır.  Ancak, bir mapping’in ne tüm anahtarlarının ne de tüm değerlerinin bir listesini
elde etmek mümkün değildir. Bunun için mapping'e eklediğiniz değerleri kaydedin veya buna gerek duyulmayacak
bir durumda kullanın. Hatta daha da iyisi bir liste tutun ya da daha uygun bir veri türünü kullanmayı deneyin.

``public`` anahtar kelimesi ile oluşturulmuş aşağıda bulunan :ref:`çağırıcı fonksiyon<getter-functions>`, mapping örneğine
göre biraz daha karmaşık bir yapıya sahiptir:

.. code-block:: solidity

    function balances(address _account) external view returns (uint) {
        return balances[_account];
    }

Bu fonksiyonu tek bir hesabın bakiyesini sorgulamak için kullanabilirsiniz.

.. index:: event

``event Sent(address from, address to, uint amount);`` satırı ``send`` fonksiyonunun son
satırında yayılan (emit) bir :ref:`”olay (event)" <events>` bildirir.
Web uygulamaları gibi Ethereum istemcileri, blok zincirinde yayılan (emit) bu olaylardan (event) fazla maliyet olmadan veri alabilir.
Event yayılır yayılmaz, veri alıcısı ``from``, ``to`` ve ``amount`` argümanlarını alır,
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
``msg`` değişkeni (``tx`` ve ``block`` ile birlikte), blok zincirine erişim izini veren özellikleri olan :ref:`özel bir global değişken <special-variables-functions>`dir.
``msg.sender`` her zaman varsayılan fonksiyonu (external) çağıran kişinin adresini döndürür.

Sözleşmeyi oluşturan ve hem kullanıcıların hemde sözleşmelerin çağırabileceği fonksiyonlar ``mint`` ve ``send`` dir.

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

``send`` fonksiyonu, herhangi biri tarafından (hali hazırda bir miktar paraya sahip olan)
başka birine para göndermek için kullanılabilir. Gönderen kişinin göndermek için yeterli
bakiyesi yoksa, ``if`` koşulu doğru (true) olarak değerlendirilir. Sonuç olarak ``revert``
fonksiyonu, ``InsufficientBalance``(Yetersiz bakiye) hatasını kullanarak göndericiye hata
ayrıntılarını sağlarken işlemin başarısız olmasına neden olacaktır.

.. note::
    Bu sözleşmeyi bir adrese para (coin) göndermek için kullanırsanız, bir blok zinciri
    gezgininde (explorer) o adrese baktığınızda hiçbir şey göremezsiniz, çünkü para (coin)
    gönderdiğiniz kayıt ve değişen bakiyeler yalnızca bu coin sözleşmesinin veri deposunda
    saklanır. Event’leri kullanarak, yeni coin'inizin işlemlerini ve bakiyelerini izleyen
    bir "blok zinciri gezgini (explorer)" oluşturabilirsiniz, ancak coin sahiplerinin adreslerini
    değil, coin'in sözleşme adresini incelemeniz gerekir.

.. _blockchain-basics:

***********************
Blok Zinciri Temelleri
***********************

Bir kavram olarak blok zincirleri anlamak programcılar için çok zor değildir. Bunun nedeni,
komplikasyonların (madencilik (mining), `hashing <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_,
`elliptic-curve cryptography <https://en.wikipedia.org/wiki/Elliptic_curve_cryptography>`_,
`peer-to-peer networks <https://en.wikipedia.org/wiki/Peer-to-peer>`_, etc.) çoğunun sadece platform
için belirli bir dizi özellik ve vaat sağlamak için orada olmasıdır. Bu özellikleri olduğu gibi
kabul ettiğinizde, altta yatan teknoloji hakkında endişelenmenize gerek kalmaz - yoksa  Amazon'un
AWS'sini kullanmak için dahili olarak nasıl çalıştığını bilmek zorunda mısınız?

.. index:: transaction

İşlemler (Transactions)
========================

Blok zinciri, küresel olarak paylaşılan, işlemsel bir veritabanıdır.
Bu, herkesin yalnızca ağa katılarak veritabanındaki girdileri okuyabileceği anlamına gelir.
Veritabanındaki bir şeyi değiştirmek istiyorsanız, diğerleri tarafından kabul edilmesi gereken bir "işlem" oluşturmanız gerekir.
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
========

Üstesinden gelinmesi gereken en büyük engellerden biri (Bitcoin açısından) "çifte harcama
saldırısı" olarak adlandırılan bir olaydır: Ağda bir cüzdanı boşaltmak isteyen eşzamanlı iki
işlem varsa ne olur? İşlemlerden sadece biri geçerli olabilir, tipik olarak önce kabul edilmiş
olanı. Sorun, “ilk” in eşler arası ağda (peer-to-peer network) nesnel bir terim olmamasıdır.

Özetle tüm bunları düşünmenize gerk yoktur. İşlemlerin global olarak kabul edilen bir sırası
sizin için seçilecek ve çatışma çözülecektir. İşlemler "blok" adı verilen bir yapıda bir araya
getirilecek ve daha sonra yürütülerek tüm katılımcı düğümler arasında dağıtılacaktır. Eğer iki
işlem birbiriyle çelişirse, ikinci olan işlem reddedilecek ve bloğun bir parçası olmayacaktır.

Bu bloklar zaman içinde doğrusal bir dizi oluşturur ve “blok zinciri" kelimesi de zaten buradan
türemiştir. Bloklar zincire oldukça düzenli aralıklarla eklenir - Ethereum için bu süre kabaca
her 17 saniye birdir.

"Sıra seçim mekanizmasının" ("madencilik" olarak adlandırılır) bir parçası olarak zaman zaman
bloklar geri alınabilir, ancak bu sadece zincirin en "ucunda" gerçekleşir. Belirli bir bloğun üzerine
ne kadar çok blok eklenirse, bu bloğun geri döndürülme olasılığı o kadar azalır. Yani işlemleriniz
geri alınabilir ve hatta blok zincirinden kaldırılabilir, ancak ne kadar uzun süre beklerseniz, bu
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
============

Ethereum Sanal Makinesi veya ESM, Ethereum'daki akıllı sözleşmeler
için çalışma ortamıdır. Bu alan yalnızca korumalı bir alan değil, aynı
zamanda tamamen yalıtılmış bir alandır; yani ESM içinde çalışan kodun ağa,
dosya sistemine ya da diğer süreçlere erişimi yoktur. Akıllı sözleşmelerin
diğer akıllı sözleşmelere erişimi bile sınırlıdır.

.. index:: ! account, address, storage, balance

.. _accounts:

Hesaplar
==========

Ethereum'da aynı adres alanını paylaşan iki tür hesap vardır:
Public anahtar çiftleri (yani insanlar) tarafından kontrol edilen
**harici hesaplar** ve hesapla birlikte depolanan kod tarafından kontrol
edilen **sözleşme hesapları**.

Harici bir hesabın adresi açık (public) anahtardan belirlenirken, bir sözleşmenin
adresi sözleşmenin oluşturulduğu anda belirlenir ("nonce" olarak adlandırılan yaratıcı
adres ve bu adresten gönderilen işlem sayısından türetilir).

Hesabın kod depolayıp depolamadığına bakılmaksızın, iki tür ESM tarafından
eşit olarak değerlendirilir.

Her hesabın, 256-bit sözcükleri **storage** adı verilen 256-bit sözcüklere eşleyen
kalıcı bir anahtar-değer deposu vardır.

Ayrıca, her hesabın Ether cinsinden bir **bakiyesi** vardır (tam olarak "Wei"
cinsinden, ``1 ether`` ``10**18 wei`` dir) ve bu Ether içeren işlemler gönderilerek
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
adlı bir veri alanına sahiptir. Depolama, 256 bit kelimeleri 256 bit kelimelerle eşleyen bir anahtar/değer deposudur.
Bir sözleşmenin içinden depolamayı belirtmek mümkün değildir, depolamayı okumak da maliyetlidir ancak depolamayı
başlatmak ve değiştirmek daha da maliyetlidir. Bu maliyet nedeniyle, kalıcı depolama alanında depoladığınız verinin
miktarını sözleşmenin çalışması için gereken en azami miktara indirmelisiniz.
Ayrıca türetilmiş hesaplamalar, önbelleğe alma ve toplamalar gibi verileri sözleşmenin dışında depolamalısınız.
Bir sözleşme, kendi depolama alanı dışında herhangi bir depolama alanını ne okuyabilir ne de bu alandaki verileri değiştirebilir.

İkincisi ise, **memory** (bellek) olarak adlandırılan ve bir sözleşmenin her ileti çağrısı
için yeniden oluşturulmuş bir örneğini alan bir veri alanıdır. Bellek doğrusaldır ve bayt
düzeyinde adreslenebilir, ancak okumalar 256 bit genişlikle sınırlıyken, yazmalar 8 bit veya
256 bit genişliğinde olabilir. Daha önceden dokunulmamış bir bellek kelimesine (yani bir kelime
içindeki herhangi bir ofsete) erişirken (okurken veya yazarken) bellek bir kelime (256 bit)
kadar genişletilir. Bu genişletilme sırasında gas maliyeti ödenmelidir. Bellek büyüdükçe
daha maliyetli olmaya başlıyacaktır (söz konusu artış maliyetin karesi olarak artmaya devam
edecektir).

ESM, kayıt makinesi değil yığın makinesi olduğundan tüm hesaplamalar
**stack** (yığın) adı verilen bir veri alanında gerçekleştirilir.
Bu alan maksimum 1024 eleman boyutuna sahiptir ve 256 bitlik kelimeler içerir.
Yığına erişim aşağıdaki şekilde üst uçla sınırlıdır: En üstteki 16 elemandan
birini yığının en üstüne kopyalamak veya en üstteki elemanı altındaki 16 elemandan
biriyle değiştirmek mümkündür. Diğer tüm işlemler yığından en üstteki iki
(veya işleme bağlı olarak bir veya daha fazla) elemanı alır ve sonucu yığının üzerine iter.
Elbette yığına daha derin erişim sağlamak için yığın elemanlarını depolama alanına veya
belleğe taşımak mümkündür, ancak önce yığının üst kısmını çıkarmadan yığının daha derinlerindeki
rastgele elemanlara erişmek mümkün değildir.

.. index:: ! instruction

Yönerge Seti
===============

ESM'nin komut seti, uzlaşma sorunlarına neden olabilecek yanlış veya tutarsız
uygulamalardan kaçınmak için minimum düzeyde tutulmuştur. Tüm komutlar temel
veri tipi olan 256 bitlik kelimeler veya bellek dilimleri (veya diğer bayt dizileri)
üzerinde çalışır. Her zamanki aritmetik, bit, mantıksal ve karşılaştırma işlemleri mevcuttur.
Koşullu ve koşulsuz atlamalar mümkündür. Ayrıca, sözleşmeler mevcut bloğun numarası ve zaman bilgisi gibi ilgili özelliklerine erişebilir.

Tam bir liste için lütfen satır içi montaj belgelerinin bir parçası olarak :ref:`işlem kodu (opcode) listeleri <opcodes>` belgesine bakın.

.. index:: ! message call, function;call

Mesaj Çağırıları
=================

Sözleşmeler, mesaj çağrıları aracılığıyla diğer sözleşmeleri çağırabilir
veya sözleşme dışı hesaplara Ether gönderebilir. Mesaj çağrıları, bir kaynak,
bir hedef, veri yükü, Ether, gas ve geri dönüş verilerine sahip olmaları bakımından
işlemlere benzerler. Aslında, her işlem üst düzey bir mesaj çağrısından oluşur
ve bu da başka mesaj çağrıları oluşturabilir.

Bir sözleşme, kalan **gas'ın** ne kadarının iç mesaj çağrısı ile gönderilmesi
gerektiğine ve ne kadarını tutmak istediğine karar verebilir.
İç çağrıda yetersiz-gas dışında bir istisna meydana gelirse (veya başka bir istisna),
bu durum yığına yerleştirilen bir hata değeri ile bildirilir. Bu durumda,
sadece çağrı ile birlikte gönderilen gas miktarı kullanılır.
Solidity dilinde, bu gibi istisnaların oluşması varsayılan olarak manuel
başka zincirleme istisnalar da yaratmaya meyilli olduğundan totalde yığınını
“kabarcıklandıran” durum olarak nitelendirilir.

Daha önce de belirtildiği gibi, çağrılan sözleşme (arayan ile aynı olabilir)
belleğin yeni temizlenmiş bir örneğini alır ve **calldata** adı verilen ayrı
bir alanda sağlanacak olan çağrı yüküne (payload) erişebilir. Yürütmeyi tamamladıktan
sonra, arayanın belleğinde arayan tarafından önceden ayrılmış bir konumda saklanacak
olan verileri döndürebilir. Tüm bu çağrılar tamamen eşzamanlıdır.

Çağrılar, 1024 bitlik alanla ile sınırlıdır; bu, daha karmaşık işlemler için
tekrarlamalı çağrılar yerine döngüler tercih edileceği anlamına gelir. Ayrıca,
bir mesaj çağrısında gazın sadece 63 / 64'ü iletilebilir; bu, pratikte 1000 bit'ten
daha az bir alan sınırlamasına neden olur.

.. index:: delegatecall, callcode, library

Delegatecall / Çağrı Kodu ve Kütüphaneler
==========================================

Bir mesaj çağrısı ile temelde aynı anlama gelen **delegatecall**, hedef
adresteki kodun arama sözleşmesi bağlamında (yani adresinde) yürütülmesi ve
``msg.sender`` ve ``msg.value`` değerlerinin değiştirilememesi gibi özellikleri
ile mesaj çağrısının özel bir çeşidi olarak kabul edilir.

Bu, bir sözleşmenin çalışma zamanında farklı bir adresten dinamik olarak
kod yükleyebileceği anlamına gelir. Depolama, geçerli adres ve bakiye hala
çağıran sözleşmeye atıfta bulunurken, yalnızca kod çağrılan adresten aktarılır.

Karmaşık bir veri yapısını uygulamak için bir sözleşmenin depolama alanına
uygulanabilen ve yeniden kullanılabilen bir kütüphane kodu örnek olarak verilebilir.

.. index:: log

Kayıtlar (Logs)
================

Verileri, tamamen blok seviyesine kadar haritalayan özel olarak indekslenmiş bir veri
yapısında depolamak mümkündür. **Kayıtlar** (log) olarak adlandırılan bu özellik, Solidity
tarafından :ref:`event'lerin <events>` uygulanmasını için kullanılır. Sözleşmeler, oluşturulduktan
sonra kayıt verilerine erişemez, ancak bunlara blok zincirinin dışından etkin bir şekilde
erişilebilir. Kayıt edilen verilerinin bir kısmı `bloom filtrelerinde
<https://en.wikipedia.org/wiki/Bloom_filter>`_ depolandığından, bu verileri verimli ve
kriptografik olarak güvenli bir şekilde aramak mümkündür,  böylece tüm zinciri indirmek zorunda
kalmayan ağ elemanları(peer) ("hafif istemciler" olarak adlandırılır) yine de bu günlükleri
bulabilir.

.. index:: contract creation

Create
=======

Sözleşmeler, özel bir opcode kullanarak başka sözleşmeler bile oluşturabilir
(bunu, hedef adresi boş bırakarak yaparlar). Bu arama çağrıları ve normal mesaj
çağrıları arasındaki tek fark, açığa çıkan veri yükünün yürütülmesi ve sonucun kod
olarak saklanarak arayan tarafın(yaratıcının) yığındaki yeni sözleşmenin adresini almasıdır.

.. index:: selfdestruct, self-destruct, deactivate

Devre Dışı Bırakma ve Kendini İmha
===================================

Blok zincirinden bir kodu kaldırmanın tek yolu, söz konusu adresteki bir sözleşmenin
selfdestruct işlemini gerçekleştirmesidir. Bu adreste depolanan kalan Ether belirlenen
bir hedefe gönderilir ve ardından depolama ve kod durumdan kaldırılır. Teoride sözleşmeyi
kaldırmak iyi bir fikir gibi görünse de, biri kaldırılan sözleşmelere Ether gönderirse,
Ether sonsuza dek kaybolacağından potansiyel olarak tehlikelidir.

.. warning::
    Bir sözleşme ``selfdestruct`` ile kaldırılsa bile, hala blok zinciri
    geçmişinin bir parçasıdır ve muhtemelen çoğu Ethereum node`u tarafından
    saklanmaktadır. Yani ``selfdestruct`` kullanmak sabit diskten veri silmekle
    aynı şey değildir.

.. note::
    Bir sözleşmenin kodu ``selfdestruct`` çağrısı içermese bile, ``delegatecall``
    veya ``callcode`` kullanarak bu işlemi gerçekleştirebilir.

Sözleşmelerinizi devre dışı bırakmak istiyorsanız, bunun yerine tüm fonksiyonların
geri alınmasına neden olan bazı iç durumları değiştirerek bunları devre dışı bırakmalısınız.
Bu, Ether'i derhal iade ettiğinden sözleşmeyi kullanmayı imkansız kılar.

.. index:: ! precompiled contracts, ! precompiles, ! contract;precompiled

.. _precompiledContracts:

Önceden Derlenmiş Sözleşmeler (Precompiled Contracts)
=======================================================

Özel olan bir dizi küçük sözleşme adresi vardır: ``1`` ile (``8`` dahil)
``8`` arasındaki adres aralığı, diğer sözleşmeler gibi çağrılabilen "önceden
derlenmiş sözleşmeler" içerir, ancak davranışları (ve gaz tüketimleri) bu adreste
saklanan ESM kodu tarafından tanımlanmaz (kod içermezler), bunun yerine ESM kendi
yürütme ortamında yürütülür.

Farklı ESM uyumlu zincirler, önceden derlenmiş farklı bir sözleşme seti kullanabilir.
Gelecekte Ethereum ana zincirine önceden derlenmiş yeni sözleşmelerin eklenmesi de
mümkün olabilir, ancak mantıklı olarak bunların her zaman ``1`` ile ``0xffff``
(dahil) aralığında olmasını beklemelisiniz.
