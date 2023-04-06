########################
Sık Kullanılan Modeller
########################

.. index:: withdrawal

.. _withdrawal_pattern:

*************************
Sözleşmelerden Para Çekme
*************************

Bir etkiden sonra önerilen fon gönderme yöntemi, para çekme
modelini kullanmaktır. Bir etki sonucunda, anlaşılması en kolay Ether
gönderme yöntemi doğrudan ``transfer`` çağrısı olsa da,
potansiyel güvenlik riski oluşturduğundan bu önerilmez. Bu
konuda daha fazla bilgiye :ref:`Güvenlikle İlgili
Değerlendirmeler<security_considerations>` sayfasından ulaşabilirsiniz.

`King of the Ether <https://www.kingoftheether.com/>`'de
olduğu gibi, amacın "en zengin" olmak için sözleşmeye en fazla
parayı göndermek olduğu bir sözleşmede para çekme modelinin
nasıl kullanıldığına dair uygulamalı bir örnek aşağıda verilmiştir.

Aşağıdaki sözleşmede, artık en zengin olan değilseniz o anda en 
zengin olan kişinin fonlarını alırsınız.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract WithdrawalContract {
        address public richest;
        uint public mostSent;

        mapping (address => uint) pendingWithdrawals;

        /// Gönderilen Ether miktarı şu anki en yüksek
        /// miktardan yüksek değildi.
        error NotEnoughEther();

        constructor() payable {
            richest = msg.sender;
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            pendingWithdrawals[richest] += msg.value;
            richest = msg.sender;
            mostSent = msg.value;
        }

        function withdraw() public {
            uint amount = pendingWithdrawals[msg.sender];
            // Tekrar girme(re-entrancy), saldırılarını önlemek için gönderim
            // öncesinde geri ödemeyi sıfırlamayı unutmayın
            pendingWithdrawals[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

Akla daha yatkın olan gönderme modeli aşağıdaki gibidir ama güvenlik açığı içerir:

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract SendContract {
        address payable public richest;
        uint public mostSent;

        /// Gönderilen Ether miktarı şu anki en yüksek
        /// miktardan yüksek değildi.
        error NotEnoughEther();

        constructor() payable {
            richest = payable(msg.sender);
            mostSent = msg.value;
        }

        function becomeRichest() public payable {
            if (msg.value <= mostSent) revert NotEnoughEther();
            // Bu satır sorunlara neden olabilir (aşağıda açıklanmıştır).
            richest.transfer(msg.value);
            richest = payable(msg.sender);
            mostSent = msg.value;
        }
    }

Bu örnekte, bir saldırgan, ``richest``'ın başarısız olan bir receive veya callback fonksiyonuna sahip
bir sözleşmenin adresi olmasına sebep olarak (örneğin, ``revert()`` kullanarak veya yalnızca, onlara 
aktarılan 2300 gas ücretinden daha fazlasını tüketerek) sözleşmeyi kullanılamayacak bir duruma düşürebilir.
Bu şekilde, fonları "zehirlenmiş" sözleşmeye iletmek için ``transfer`` her çağrıldığında başarısız olur,
dolayısıyla ``becomeRichest`` fonksiyonu da başarısız olur ve sözleşme sonsuza kadar kilitli / takılı kalır.

Bunun aksine, ilk örnekten "çekme" modelini kullanırsanız saldırgan sözleşmenin kalanındaki işleyişin
değil, yalnızca kendi çekim işleminin başarısız olmasına sebep olabilir.

.. index:: access;restricting

******************
Erişimi Kısıtlamak
******************

Erişimi kısıtlamak sözleşmeler için yaygın bir modeldir.
Herhangi bir insanı veya bilgisayarı, işlemlerinizin içeriğini
veya sözleşmenizin durumunu okumak konusunda kesinlikle
kısıtlayamayacağınızı unutmayın. Şifreleme kullanarak bunu
bir miktar zorlaştırabilirsiniz ancak sözleşmenizin veri
okumasına izin verilmişse diğer herkes de okuyacaktır.

Sözleşme durum degişkenlerinin okuma erişimini **diğer sözleşmeler**
ile kısıtlayabilirsiniz. Bu aslında, durum değişkenlerinizi
``public`` olarak bildirmediğiniz sürece varsayılandır.

Ayrıca, sözleşmenizin durumunda değişiklik yapabilecek
kişileri kısıtlayabilir veya sözleşmenizin fonksiyonlarını
çağırabilirsiniz; bu bölümün konusu da budur.

.. index:: function;modifier

**Fonksiyon modifier'larının** kullanımı bu
kısıtlamaları oldukça okunur hale getirir.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract AccessRestriction {
        // Bunlar, `msg.sender`'ın bu sözleşmeyi
        // oluşturan hesap olduğu yapım aşamasında
        // atanacaktır.
        address public owner = msg.sender;
        uint public creationTime = block.timestamp;

        // Altta, bu sözleşmenin oluşturabileceği
        // hataların bir listesi, özel yorumlarda
        // yazılı bir açıklamayla birlikte
        // verilmiştir.

        /// Gönderici bu işlem için yetkili
        /// değildir.
        error Unauthorized();

        /// Fonksiyon çok erken çağrıldı.
        error TooEarly();

        /// Fonksiyon çağrısıyla yeterince Ether gönderilmedi.
        error NotEnoughEther();

        // Modifier'lar bir fonksiyonun gövdesini
        // değiştirmek için kullanılabilir.
        // Bu modifier kullanılırsa başa,
        // yalnızca fonksiyon belirli bir
        // adresten çağrıldığında geçen bir
        // kontrol ekleyecektir.
        modifier onlyBy(address account)
        {
            if (msg.sender != account)
                revert Unauthorized();
            // "_;" işaretini unutmayın! Modifier
            // kullanıldığında bu, gerçek fonksiyon
            // gövdesi ile değiştirilecektir.
            _;
        }

        /// `newOwner`'ı bu sözleşmenin yeni
        /// sahibi yapın.
        function changeOwner(address newOwner)
            public
            onlyBy(owner)
        {
            owner = newOwner;
        }

        modifier onlyAfter(uint time) {
            if (block.timestamp < time)
                revert TooEarly();
            _;
        }

        /// Sahiplik bilgilerini silin.
        /// Yalnızca sözleşme oluşturulduktan
        /// 6 hafta sonra çağrılabilir.
        function disown()
            public
            onlyBy(owner)
            onlyAfter(creationTime + 6 weeks)
        {
            delete owner;
        }

        // Bu modifier, bir fonksiyon çağrısının belirli
        // bir ücretle ilişkilendirilmesini gerektirir.
        // Çağıran kişi çok fazla göndermişse yalnızca
        // fonksiyon gövdesinden sonrası iade edilir.
        // Bu, `_;` sonrasındaki kısmı atlamanın mümkün
        // olduğu Solidity sürümü 0.4.0 öncesinde tehlikeliydi.
        modifier costs(uint amount) {
            if (msg.value < amount)
                revert NotEnoughEther();

            _;
            if (msg.value > amount)
                payable(msg.sender).transfer(msg.value - amount);
        }

        function forceOwnerChange(address newOwner)
            public
            payable
            costs(200 ether)
        {
            owner = newOwner;
            // yalnızca örnek bir koşul
            if (uint160(owner) & 0 == 1)
                // Sürüm 0.4.0 öncesinde bu, Solidity
                // iade yapmıyordu.
                return;
            // fazla ödenen ücretleri iade et
        }
    }

Fonksiyon çağrılarına erişimin kısıtlanabileceği
daha özel bir yol, bir sonraki örnekte
incelenecektir.

.. index:: state machine

*****************
Durum Makinesi
*****************

Sözleşmeler, sıklıkla, bir durum makinesi işlevi
görür; bu, içinde farklı davrandıkları veya farklı
fonksiyonların çağrılabildiği belirli **aşamalara**
sahip oldukları anlamına gelir.Bir fonksiyon çağrısı
genellikle bir aşamayı sonlandırır ve sözleşmeyi bir
sonraki aşamaya geçirir (özellikle sözleşme,
**etkileşimi** modellediğinde). Bazı aşamalara belirli
bir **anda** otomatik olarak ulaşılması da yaygındır.

Bunun bir örneği, "kör teklifleri kabul etme" aşamasından
başlayan, "teklifleri açıklama" aşamasına geçen ve "ihale
sonucunu belirleme" ile sonlanan kör ihale sözleşmesidir.

.. index:: function;modifier

Bu durumda, durumları modellemek ve sözleşmenin
yanlış kullanımına karşı korunmak için
fonksiyon modifier'ları kullanılabilir.

Örnek
=======

Aşağıdaki örnekte,
``atStage`` modifier'ı fonksiyonun yalnızca
belirli bir aşamada çağrılmasını sağlar.

Otomatik zaman ayarlı geçişler, tüm fonksiyonlar
tarafından kullanılması gereken ``timedTransitions``
modifier'ı ele alınır.

.. note::
    **Modifier Sırası Önemlidir**.
    atStage, timedTransitions ile birleştirilirse
    yeni aşamanın dikkate alınması için atStage'i
    timedTransitions'tan sonra belirttiğinizden
    emin olun.

Son olarak, fonksiyon sonlandığında otomatik olarak
bir sonraki aşamaya gitmek için ``transitionNext`` 
modifier'ı kullanılabilir.

.. note::
    **Modifier Atlanabilir**.
    Bu, yalnızca 0.4.0 öncesi Solidity sürümlerinde geçerlidir:
    Modifier'lar, fonksiyon çağrısı kullanarak değil,
    yalnızca kodu değiştirerek uygulandığından fonksiyonun
    kendisi return kullanırsa transitionNext modifier'ındaki
    kod atlanabilir. Bunu yapmak isterseniz nextStage'i o
    fonksiyonlardan manuel olarak çağırdığınızdan emin
    olun. 0.4.0 sürümünden itibaren modifier kodu, fonksiyon
    açıkça retun etse dahi çalışacaktır.

.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;

    contract StateMachine {
        enum Stages {
            AcceptingBlindedBids,
            RevealBids,
            AnotherStage,
            AreWeDoneYet,
            Finished
        }
        /// Bu noktada fonksiyon çağrılamaz.
        error FunctionInvalidAtThisStage();

        // Mevcut aşama budur.
        Stages public stage = Stages.AcceptingBlindedBids;

        uint public creationTime = block.timestamp;

        modifier atStage(Stages stage_) {
            if (stage != stage_)
                revert FunctionInvalidAtThisStage();
            _;
        }

        function nextStage() internal {
            stage = Stages(uint(stage) + 1);
        }

        // Zaman ayarlı geçişler gerçekleştirin. Önce bu
        // modifier'ı belirttiğinizden emin olun aksi halde
        // korumalar yeni aşamayı dikkate almaz.
        modifier timedTransitions() {
            if (stage == Stages.AcceptingBlindedBids &&
                        block.timestamp >= creationTime + 10 days)
                nextStage();
            if (stage == Stages.RevealBids &&
                    block.timestamp >= creationTime + 12 days)
                nextStage();
            // Diğer aşamalar işleme göre geçiş yapar
            _;
        }

        // Burada modifier'ların sırası önemlidir!
        function bid()
            public
            payable
            timedTransitions
            atStage(Stages.AcceptingBlindedBids)
        {
            // Onu burada uygulamayacağız
        }

        function reveal()
            public
            timedTransitions
            atStage(Stages.RevealBids)
        {
        }

        // Bu modifier, fonksiyonun tamamlanmasının
        // ardından sonraki aşamaya geçer.
        modifier transitionNext()
        {
            _;
            nextStage();
        }

        function g()
            public
            timedTransitions
            atStage(Stages.AnotherStage)
            transitionNext
        {
        }

        function h()
            public
            timedTransitions
            atStage(Stages.AreWeDoneYet)
            transitionNext
        {
        }

        function i()
            public
            timedTransitions
            atStage(Stages.Finished)
        {
        }
    }
