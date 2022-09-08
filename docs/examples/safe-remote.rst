.. index:: purchase, remote purchase, escrow

********************
Güvenli Uzaktan Alışveriş
********************

Uzaktan bir mal satın almak birden fazla tarafın birbirine güvenmesini gerektirir.
En basit durumda bir satıcı bir de alıcı olur. Alıcı ürünü satıcıdan almak ister, satıcı da 
karılığında parayı (ya da eş değeri bir şeyi) almak. Burada problemli kısım kargolama: Kesin olarak
malın alıcıya ulaştığından emin olmanın yolu yok. 

Bu problemmi çözmenin birden fazla yolu var ama hepsinin bir şekilde bir eksiği oluyor.
Aşağıdaki örnekte, iki taraf da kontrata malın değerinin iki katını yatırırlar. Yatırma 
gerçekleştiği anda alıcı onaylayana kadar iki tafaında parası içeride kitli kalır. Alıcı
satın almayı onayladığında malın değeri (yatırdığının yarısı) karşı tarafa geçer ve satıcı
malın üç katını (yatırdığı iki kat ve alıcının yatırdığı malın değeri) geri çeker. Bu sistemin
arkaplanındaki fikir iki tarafında problemi çözmeleri için gönüllü olmaları yoksa ikisinin parası
da içeride sonsuza kadar kitli kalacak

Bu kontrat tabi ki bu problemi çözmüyor ama makine benzeri  yapıları sözleşmede nasıl kullanabileceğinize
dair genel bir bakış sağlıyor.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.4;
    contract Purchase {
        uint public value;
        address payable public seller;
        address payable public buyer;

        enum State { Created, Locked, Release, Inactive }
        // state değişkeni varsayılan olarak ilk üyedir,  `State.created`
        State public state;

        modifier condition(bool condition_) {
            require(condition_);
            _;
        }

        /// Bu fonksiyonu sadece alıcı çağırabilir
        error OnlyBuyer();
        /// BU fonksyionu sadece satıcı çağırabilir.
        error OnlySeller();
        /// Bu fonksiyon şu an çağırılamaz.
        error InvalidState();
        /// Girilen değer çift olmalı.
        error ValueNotEven();

        modifier onlyBuyer() {
            if (msg.sender != buyer)
                revert OnlyBuyer();
            _;
        }

        modifier onlySeller() {
            if (msg.sender != seller)
                revert OnlySeller();
            _;
        }

        modifier inState(State state_) {
            if (state != state_)
                revert InvalidState();
            _;
        }

        event Aborted();
        event PurchaseConfirmed();
        event ItemReceived();
        event SellerRefunded();

        // `msg.value` in çift olduğundan emin ol.
        // Eğer tek sayı ise bölme kırpılmış bir sonuç olacak.
        // Çarpma ile tek sayı olmadığını kontrol et.
        constructor() payable {
            seller = payable(msg.sender);
            value = msg.value / 2;
            if ((2 * value) != msg.value)
                revert ValueNotEven();
        }

        /// Satın almayı iptal et ve etheri geri al.
        /// Sadece satıcı tarafından kontrat kitlenmeden
        /// önce çağırılabilir.
        function abort()
            external
            onlySeller
            inState(State.Created)
        {
            emit Aborted();
            state = State.Inactive;
            // Burada transfer'i direkt olarak kullanıyoruz.
            // Tekrar giriş (reentrancy) saldırılarına karşı güvenli
            // çünkü fonksiyondaki son çağrı (call) ve durumu (state)
            // zaten değiştirdik.
            seller.transfer(address(this).balance);
        }

        /// Alıcı olarak satın almayı onayla.
        /// İşlem `2 * value` kadar ether içermeli.
        /// Ether confirmReceived fonksiyonu çağırılana
        /// kadar kitli kalacak. 
        function confirmPurchase()
            external
            inState(State.Created)
            condition(msg.value == (2 * value))
            payable
        {
            emit PurchaseConfirmed();
            buyer = payable(msg.sender);
            state = State.Locked;
        }

        /// Malı teslim aldığını onayla (alıcı)
        /// Kitli etheri serbest bırakacak.
        function confirmReceived()
            external
            onlyBuyer
            inState(State.Locked)
        {
            emit ItemReceived();
            // Durumu (state) önceden değiştirmek oldukça önemli
            // yoksa aşağıdaki `send` i kontratlar burada tekrar 
            // bu fonksiyonu çağırabilir. (tekrar giriş saldırısı - reentrancy attack) 
            state = State.Release;

            buyer.transfer(value);
        }

        /// Bu fonksiyon satıcıya iade eder
        /// (satıcının kitli parasını geri öder)
        function refundSeller()
            external
            onlySeller
            inState(State.Release)
        {
            emit SellerRefunded();
            // Durumu (state) önceden değiştirmek oldukça önemli
            // yoksa aşağıdaki `send` i kontratlar burada tekrar 
            // bu fonksiyonu çağırabilir. (tekrar giriş saldırısı - reentrancy attack) 
            state = State.Inactive;

            seller.transfer(3 * value);
        }
    }
