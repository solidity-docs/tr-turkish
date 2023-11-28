.. index:: auction;blind, auction;open, blind auction, open auction

*************
Gizli İhale
*************

Bu bölümde Ethereum'da tamamiyle gizli bir ihale kontratı oluşturmanın ne 
kadar kolay olduğunu göstereceğiz. Önce herkesin başkalarının tekliflerini 
görebildiği açık bir ihale kontratı oluşturup sonrasında ondan teklif süresi
dolana kadar kimsenin başkasının teklifini göremediği gizli bir ihale kontratı
oluşturacağız.

.. _simple_auction:

Basit Açık İhale
===================

Aşağıdaki basit ihale kontratındaki fikir herkes teklif sürecinde teklfilerini
gönderebilcek. Teklifler yanında teklif verenlerin tekliflerine sadık kalmaları
için teklifte belirtilen parayı da içerecek. Eğer en yüksek teklif geçilirse önceki
en yüksek teklifi veren kişi parasını geri alacak. Teklif süreci bittiğinde kontratlar
kendi kendilerine çalışamadıklarından hak sahibi parasını almak için kontratı manuel olarak
çağırılmalıdır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract SimpleAuction {
        // İhalenin parametreleri. Süreler unix zaman damgası
        // (1970-01-01'den itibaren saniyeler) ya da saniye
        // cinsinden ne kadar süreceği.
        address payable public beneficiary;
        uint public auctionEndTime;

        // İhalenin şu an ki durumu
        address public highestBidder;
        uint public highestBid;

        // Önceki tekliflerden para çekmeye izin verilenler
        mapping(address => uint) pendingReturns;

        // En son `true`ya çevir, herhangi bir değişiklik yapılmasını engeller
        // varsayılan olarak `false` tanımlanır.
        bool ended;

        // Değişikliklerde yayınlanacak Event'ler
        event HighestBidIncreased(address bidder, uint amount);
        event AuctionEnded(address winner, uint amount);

        // Başarısızları açıklayan hatalar

        // Üçlü eğik çizgiler natspec yorumları olarak
        // adlandırılır. Kullanıcıya bir işlemi onaylayacağı
        // zaman ya da bir hatada gösterilir.

        /// İhale bitti.
        error AuctionAlreadyEnded();
        /// Eşit ya da daha yüksek bir teklif var.
        error BidNotHighEnough(uint highestBid);
        /// Teklif henüz bitmedi.
        error AuctionNotYetEnded();
        /// auctionEnd fonksiyonu zaten çağrıldı.
        error AuctionEndAlreadyCalled();

        /// Hak sahibi adına `beneficiaryAddress`
        /// `biddingTime` daki süre ile bir ihale başlatır.
        constructor(
            uint biddingTime,
            address payable beneficiaryAddress
        ) {
            beneficiary = beneficiaryAddress;
            auctionEndTime = block.timestamp + biddingTime;
        }

        /// İşlemle birlikte teklifteki para da
        /// gönderilir. Ödeme sadece teklif kazanmazsa
        /// iade edilir.
        function bid() external payable {
            // Herhangi bir argümana gerek yok,
            // bütün bilgi zaten işlemin parçası.
            // payable anahtar kelimesi fonksiyonun
            // Ether alabilmesi için zorunlu.

            // teklif süreci bittiyse çağrıyı
            // geri çevir.
            if (block.timestamp > auctionEndTime)
                revert AuctionAlreadyEnded();
            // Teklif daha yüksek değilse,
            // parayı geri gönderin (revert ifadesi 
            // parayı almış olması da dahil olmak
            // üzere bu fonksiyon yürütmesindeki tüm
            // değişiklikleri geri alacaktır).
            if (msg.value <= highestBid)
                revert BidNotHighEnough(highestBid);

            if (highestBid != 0) {
                // Basit bir şekilde highestBidder.send(highestBid)'i 
                // kullanarak para göndermek bir güvenlik riski oluşturuyor
                // çünkü güvenilmez bir kontratı (içinde fallback fonksiyonu 
                // içeren) çalıştırabilir. Her zaman katılımcıların paralarını
                // kendilerinin çekmeleri daha güvenilirdir.
                pendingReturns[highestBidder] += highestBid;
            }
            highestBidder = msg.sender;
            highestBid = msg.value;
            emit HighestBidIncreased(msg.sender, msg.value);
        }

        /// Geçilmiş bir teklifin parasını geri çek.
        function withdraw() external returns (bool) {
            uint amount = pendingReturns[msg.sender];
            if (amount > 0) {
                // Bu değeri sıfıra eşitlemek önemli çünkü alıcı bu fonksiyonu
                // `send` tamamlanmadan tekrar çağırırsa (reentrancy) alması gerekenden
                // daha fazla para çekebilir.
                pendingReturns[msg.sender] = 0;

                // msg.sender `address payable` türünde değil ve `send()` 
                // fonksiyonunda çağrılabilmesi `payable(msg.sender)` ile
                // `address payable` a dönüştürülmesi gerekiyor.
                if (!payable(msg.sender).send(amount)) {
                    // No need to call throw here, just reset the amount owing
                    pendingReturns[msg.sender] = amount;
                    return false;
                }
            }
            return true;
        }
        
        /// İhaleyi bitir ve en yüksek teklifi 
        /// hak sahibine gönder.
        function auctionEnd() external {
            // Diğer kontratlar ile etkileşime giren (fonksiyon çağıran ya da
            // Ether gönderen) fonksiyonları üç parçada şekilldenirmek güzel bir yöntem.
            // Şu parçalar
            // 1. koşul kontrolleri
            // 2. eylem gerçekleştirenler (koşulları değiştirebilirler)
            // 3. başka kontratlarlar etkileşime girenler
            // Eüer bu fazlar karışırsa, diğer kontrat bu kontratı çağırıp
            // durumları değiştirebilir ya da olayların (ether ödemesi gibi)
            // birkaç kere gerçekleşmesine sebep olabilir.
            // Eğer içeriden çağırılan fonksiyonlar başka kontratlarla etkileşime
            // giriyorsa o fonksiyonlar da başka fonksiyonlarla etkileşenler olarak
            // değerlendirilmeli

            // 1. Şartlar
            if (block.timestamp < auctionEndTime)
                revert AuctionNotYetEnded();
            if (ended)
                revert AuctionEndAlreadyCalled();

            // 2. Etkiler
            ended = true;
            emit AuctionEnded(highestBidder, highestBid);

            // 3. Etkileşim
            beneficiary.transfer(highestBid);
        }
    }

Gizli İhale
=============

Aşağıda yukarıdaki açık ihalenin kapalı ihaleye dönüştürülmüş halini bulabilirsiniz.
Gizli ihalenin avantajı ihale sürecinin sonunda doğru bir zaman baskısı oluşturmaması.
Saydam bir işlem platformunda gizli ihale oluşturmak çelişkili olsa da kriptografi 
burada yardımımıza koşuyor.

**Teklif süreci** boyunca, teklif veren kişi aslında gerçekten teklif yapmıyor, sadece
hashlenmiş bir halini gönderiyor. Şu an hash değerleri eşit olan iki değer (yeterince uzun) 
bulmak pratik olarak imkansız olduğundan, teklif veren kişi bu şekilde teklif oluşturmuş olur.
Teklif süreci bittikten sonra teklif veren kişiler tekliflerini açıklamalı, girdikleri şifrelenmemiş
değerin hashlenmiş hali ile önceden girdikleri hash ile aynı olmalıdır. 

Başka bir zorluk da **gizlilik ve bağlayıcılığı** aynı anda sağlamak. Teklif veren kişinin
kazandıktan sonra teklifinden vazgeçmemesinin tek yolu teklif ile birlikte parayı
da yollaması ancak transferler Ethereum'da gizlenemediğinden herhangi bir kişi miktarı görebilir.

Aşağıdaki kontrat bu sorunu teklif ile birlikte herhangi bir miktar paranın
birlikte gönderilmesiyle çözüyor. Miktar ile teklifin eşitliği sadece açıklama
fazında ortaya anlaşılabildiği için bazı teklifleri **geçersiz** olabilir, ve teklif
veren kişiler bunu kasıtlı olarak kullanabilir (hatta bu durum daha fazla gizlilik sağlıyor)
Teklif veren kişiler kasıtlı olarak bir kaç yüksek ve düşük geçersiz teklifler oluşturarak
kafa karıştırabilirler.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract BlindAuction {
        struct Bid {
            bytes32 blindedBid;
            uint deposit;
        }

        address payable public beneficiary;
        uint public biddingEnd;
        uint public revealEnd;
        bool public ended;

        mapping(address => Bid[]) public bids;

        address public highestBidder;
        uint public highestBid;

        // Önceki tekliflerden para çekmeye izin verilenler
        mapping(address => uint) pendingReturns;

        event AuctionEnded(address winner, uint highestBid);

        // Başarısızları açıklayan hatalar

        /// Fonksiyon erken çağırıldı.
        /// `time` de tekrar deneyin.
        error TooEarly(uint time);
        /// Fonksyion geç çağırıldı.
        /// `time` dan sonra çağırılamaz.
        error TooLate(uint time);
        /// auctionEnd fonksyionu zaten çağırıldı.
        error AuctionEndAlreadyCalled();

        // Modifierlar fonksiyon girdilerini kontrol etmenin
        // kolay bir yöntemidir. `onlyBefore` modifierı aşağıdaki
        // `bid` e uygulandı:
        // Yeni fonksyionun gövde kısmı modifierın gövde kısmı oluyor.
        // Sadece `_` eski fonksiyonun gövdesiyle değişiyor..
        modifier onlyBefore(uint time) {
            if (block.timestamp >= time) revert TooLate(time);
            _;
        }
        modifier onlyAfter(uint time) {
            if (block.timestamp <= time) revert TooEarly(time);
            _;
        }

        constructor(
            uint biddingTime,
            uint revealTime,
            address payable beneficiaryAddress
        ) {
            beneficiary = beneficiaryAddress;
            biddingEnd = block.timestamp + biddingTime;
            revealEnd = biddingEnd + revealTime;
        }
        /// `blindedBid` = keccak256(abi.encodePacked(value, fake, secret))
        /// ile gizli bir teklif ver. Gönderilen ether sadece teklif doğru
        /// bir şekilde açıklandıysa geri alınabilir. Teklif eğer "value"daki
        /// değer ile en az gönderilen Ether kadar ya da "fake" değeri `false`
        /// ise geçerlidir.  Bir miktar Ether yatırılması  gereksenede 
        /// "fake" değerini `true` yapmak ve "value" değerinden
        /// farklı miktarda Ether göndermek gerçek teklifi gizlemenin yöntemleridir.
        /// Aynı adres birden fazla kez para yatırabilir.
        function bid(bytes32 blindedBid)
            external
            payable
            onlyBefore(biddingEnd)
        {
            bids[msg.sender].push(Bid({
                blindedBid: blindedBid,
                deposit: msg.value
            }));
        }

        /// Gizli teklifini açıkla. Tüm teklifler arasında en yüksek olan hariç
        /// doğru şekilde açıklanmış tüm tekliflerin parasını iade alabilirsin.
        function reveal(
            uint[] calldata values,
            bool[] calldata fakes,
            bytes32[] calldata secrets
        )
            external
            onlyAfter(biddingEnd)
            onlyBefore(revealEnd)
        {
            uint length = bids[msg.sender].length;
            require(values.length == length);
            require(fakes.length == length);
            require(secrets.length == length);

            uint refund;
            for (uint i = 0; i < length; i++) {
                Bid storage bidToCheck = bids[msg.sender][i];
                (uint value, bool fake, bytes32 secret) =
                        (values[i], fakes[i], secrets[i]);
                if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                    // Teklif açıklanmadı
                    // Yatırılan parayı iade etme
                    continue;
                }
                refund += bidToCheck.deposit;
                if (!fake && bidToCheck.deposit >= value) {
                    if (placeBid(msg.sender, value))
                        refund -= value;
                }
                // Göndericinin gönderdiği parayı tekrar geri almasını
                // imkansız hale getir.
                bidToCheck.blindedBid = bytes32(0);
            }
            payable(msg.sender).transfer(refund);
        }

        /// Fazladan para yatırılmış bir teklifi geri çek.
        function withdraw() external {
            uint amount = pendingReturns[msg.sender];
            if (amount > 0) {
                // Bu değeri sıfıra eşitlemek önemli çünkü alıcı bu fonksiyonu
                // `send` tamamlanmadan tekrar çağırırsa (reentrancy) alması gerekenden
                // daha fazla para çekebilir. (yukarıdaki şartlar -> etkiler -> etkileşimler 
                // hakkındaki bilgilendirmeye bakabilirsiniz)
                pendingReturns[msg.sender] = 0;

                payable(msg.sender).transfer(amount);
            }
        }

        /// İhaleyi bitir ve en yüsek teklifi
        /// hak sahibine gönder.
        function auctionEnd()
            external
            onlyAfter(revealEnd)
        {
            if (ended) revert AuctionEndAlreadyCalled();
            emit AuctionEnded(highestBidder, highestBid);
            ended = true;
            beneficiary.transfer(highestBid);
        }
        
        // "internal" (içsel) bir fonksiyon yani sadece kontratın
        // kendisi (ya da bu kontrattan çıkan (derive edilen) kontratlar)
        // bunu çağırabilir.
        function placeBid(address bidder, uint value) internal
                returns (bool success)
        {
            if (value <= highestBid) {
                return false;
            }
            if (highestBidder != address(0)) {
                // Önceki en yüksek teklifin parasını iade et.
                pendingReturns[highestBidder] += highestBid;
            }
            highestBid = value;
            highestBidder = bidder;
            return true;
        }
    }
