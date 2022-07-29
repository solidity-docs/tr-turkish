.. index:: voting, ballot

.. _oylama:

******
Oylama
******

Birazdan göreceğini kontrat biraz karışık ancak 
Solidity'nin bir çok özelliğini görebilirsiniz. 
Göreceğiniz kontrat bir oylama kontratıdır. Elektronik
oy kullanmada asıl problem oy hakkının doğru kişilere
nasıl verildiği ve manipülasyonun nasıl engelleneceğidir.
Bütün problemleri burada çözmeyeceğiz ama en azından 
yetkilendirilmiş kişilerle hem otomatik hem de şeffaf 
olarak nasıl oylama yapılacağını göstereceğiz.

Fikrimiz oy sandığı başına bir kontrat oluşturup her
seçenek için kısa isimler vermek. Sonrasında kontratın 
yaratıcısı, aynı zamanda seçim başkanı oluyor, her cüzdana
tek tek oy hakkı verecek.

Sonrasında cüzdan sahipleri kendilerine ya da güvendikleri bir 
kişiye oy verebilirler.

Oylamanın süresi dolduğunda, ``winningProposal()`` en yüksek 
oyu almış teklifi geri döndürecek. 

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.7.0 <0.9.0;
    /// @title Yetkili Oylama
    contract Ballot {
        // Bu sonrasında değişken olarak
        // kullanılmak için oluşturulmuş kompleks bir tür
        // Tek bir seçmeni temsil eder
        struct Voter {
            uint weight; // oyun seçimdeki etki ağırlığı
            bool voted;  // true ise oy kullanılmıştır
            address delegate; // yetkilendirilecek kişinin adresi
            uint vote;   // oy verilmiş proposalın index numarası
        }

        // Tekli teklif türü
        struct Proposal {
            bytes32 name;   // kısa ismi (32 bayta kadar)
            uint voteCount; // toplam oy miktarı
        }

        address public chairperson; // seçim başkanının adresi

        // Her adres için `Voter` (Oy kullanan kişi)
        // structına mapping (eşleştirme) değişkeni
        mapping(address => Voter) public voters;

        // `Proposal` structlarından oluşan bir dinamik dizi (dynamic array).
        Proposal[] public proposals;

        /// `proposalNames`lerden birini seçmek için bir oy sandığı oluşturur.
        constructor(bytes32[] memory proposalNames) {
            chairperson = msg.sender;
            voters[chairperson].weight = 1;

            // Her teklif ismi için bir teklif objesi oluşturup
            // dizinin (array) sonuna ekle
            for (uint i = 0; i < proposalNames.length; i++) {
                // `Proposal({...})` geçici bir Proposal (Teklif)
                // objesi oluşturur ve `proposals.push(...)`
                // objeyi `proposals` dizisinin sonuna ekler.
                proposals.push(Proposal({
                    name: proposalNames[i],
                    voteCount: 0
                }));
            }
        }

        // `voter`a bu sandıkta oy kullanma yetkisi ver.
        // `chairperson` bu fonksiyonu çağırabilir.
        function giveRightToVote(address voter) external {
            // Eğer `require`ın ilk argümanı `false`
            // gelirse işlem iptal olur ve Ether
            // harcamaları eski haline gelir
            // Eskiden bu durumda bütün gas harcanırdı 
            // ancak artık harcanmıyor.
            // Çoğu zaman fonksiyonun doğru çağrılıp
            // çağrılmadığını anlamak için `require`
            // kullanılırsa iyi olur
            // İkinci argüman olarak neyin hatalı olduğunu
            // açıklayan bir yazı girilebilir.
            require(
                msg.sender == chairperson,
                "Sadece chairperson yetki verebilir."
            );
            require(
                !voters[voter].voted,
                "Kişi zaten oy kullandı."
            );
            require(voters[voter].weight == 0);
            voters[voter].weight = 1;
        }

        /// Delege `to` ata.
        function delegate(address to) external {
            // referans atar
            Voter storage sender = voters[msg.sender];
            require(sender.weight != 0, "Oy verme yetkin yok");
            require(!sender.voted, "Zaten oy kullandın.");

            require(to != msg.sender, "Kendini temsilci gösteremezsin.");

            // Delege atamasını `to` da delege atandıysa
            // aktarır
            // Genelde bu tür döngüler oldukça tehlikelidir,
            // çünkü eğer çok fazla çalışırlar bloktaki
            // kullanılabilir gas'ten daha fazlasına ihtiyaç duyabilir.
            // Bu durumda, delege atama çalışmayacak
            // ama başka durumlarda bu tür döngüler
            // kontratın tamamiyle kitlenmesine sebep olabilir.
            while (voters[to].delegate != address(0)) {
                to = voters[to].delegate;

                // Delege atamada bir döngü bulduk, bunu istemiyoruz
                require(to != msg.sender, "Delege atamada döngü bulundu.");
            }

            Voter storage delegate_ = voters[to];

            // Oy kullanan kişi oy kullanamayan kişileri delege gösteremez.
            require(delegate_.weight >= 1);

            // `sender` bir referans olduğundan
            // `voters[msg.sender]` değişir.
            sender.voted = true;
            sender.delegate = to;

            if (delegate_.voted) {
                // Eğer delege zaten oylandıysa
                // otomatik olarak oylara eklenir
                proposals[delegate_.vote].voteCount += sender.weight;
            } else {
                // Eğer delege oylanmadıysa
                // ağırlığına eklenir.
                delegate_.weight += sender.weight;
            }
        }

        /// Oy kullan (sana atanmış oylar da dahil)
        /// teklif ismine `proposals[proposal].name`.
        function vote(uint proposal) external {
            Voter storage sender = voters[msg.sender];
            require(sender.weight != 0, "Oy kullanma yetkisi yok");
            require(!sender.voted, "Already voted.");
            sender.voted = true;
            sender.vote = proposal;

            // Eğer `proposal` dizinin içinde yoksa,
            // otomatik olarak bütün değişiklikler 
            // eski haline döner
            proposals[proposal].voteCount += sender.weight;
        }

        /// @dev Bütün oyları hesaplayarak kazanan 
        /// teklifi hesaplar
        function winningProposal() public view
                returns (uint winningProposal_)
        {
            uint winningVoteCount = 0;
            for (uint p = 0; p < proposals.length; p++) {
                if (proposals[p].voteCount > winningVoteCount) {
                    winningVoteCount = proposals[p].voteCount;
                    winningProposal_ = p;
                }
            }
        }

        // Kazanan teklifin indeks numarasını bulmak için
        // winningProposal() fonksiyonunu çağırır ardından 
        // kazanan teklifin adını döndürür.
        function winnerName() external view
                returns (bytes32 winnerName_)
        {
            winnerName_ = proposals[winningProposal()].name;
        }
    }


Olası İyileştirmeler
=====================

Şu an tüm katılımcılara yetki vermek için çok sayıda işlem 
gerçekleştirilmesi gerekiyor. Daha iyi bir yöntem düşünebiliyor 
musunuz?
