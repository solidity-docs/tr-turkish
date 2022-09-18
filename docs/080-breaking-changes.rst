********************************
Solidity v0.8.0 İşleyişi Bozan Değişiklikler
********************************

Bu bölüm, Solidity 0.8.0 sürümünde sunulan ana işleyişi bozan değişiklikleri vurgular.
Tam liste için `sürüm değişiklik günlüğü <https://github.com/ethereum/solidity/releases/tag/v0.8.0>`_
adresini kontrol edin.

Semantikte Sessiz Değişiklikler
===============================

Bu bölüm, derleyici size bildirmeden mevcut kodun davranışını değiştirdiği değişiklikleri listeler.

* Aritmetik işlemler alttan taşma ve üstten taşma durumunda geri döner. Önceki paketleme davranışını kullanmak için ``unchecked { ... }`` kullanarak önceki paketleme davranışını kullanabilirsiniz.

  Taşma kontrolleri çok yaygındır, bu nedenle gaz maliyetlerinde hafif bir artışa neden olsa bile kodun okunabilirliğini artırmak için bunları varsayılan hale getirdik.

* ABI coder v2 varsayılan olarak etkinleştirilmiştir.

  Eski davranışı kullanmayı ``pragma abicoder v1;`` kullanarak seçebilirsiniz. Pragma ``pragma experimental ABIEncoderV2;`` hala geçerlidir, ancak kullanımdan kaldırılmıştır ve hiçbir etkisi yoktur. Eğer doğrudan belirtmek istiyorsanız, lütfen bunun yerine ``pragma abicoder v2;`` kullanın.

  ABI coder v2'nin v1'den daha fazla türü desteklediğini ve girdiler üzerinde daha fazla sanity kontrolü gerçekleştirdiğini unutmayın. ABI coder v2 bazı fonksiyon çağrılarını daha pahalı hale getirir ve ayrıca parametre tiplerine uymayan veriler içerdiklerinde ABI coder v1 ile geri dönmeyen sözleşme çağrılarının geri dönmesine neden olabilir.

* Üs alma sağdan ilişkilidir, yani ``a**b**c`` ifadesi ``a**(b**c)`` olarak ayrıştırılır.
  0.8.0'dan önce ``(a**b)**c`` olarak ayrıştırılıyordu.

  Bu, üs alma operatörünü ayrıştırmanın yaygın yoludur.

* Başarısız iddialar ve sıfıra bölme veya aritmetik taşma gibi diğer dahili kontroller geçersiz işlem kodunu değil, bunun yerine geri döndürme işlem kodunu kullanır. Daha spesifik olarak, ``Panic(uint256)`` fonksiyon çağrısına eşit hata verilerini koşullara özgü bir hata koduyla kullanacaklardır.

  Bu, hatalarda gaz tasarrufu sağlarken, statik analiz araçlarının bu durumları, başarısız bir ``require`` gibi geçersiz bir girdi üzerindeki bir geri dönüşten ayırt etmesine izin verir.

* Depolama alanında uzunluğu yanlış kodlanmış bir bayt dizisine erişilmesi paniğe neden olunur.
  Depolama bayt dizilerinin ham gösterimini değiştirmek için inline assembly kullanılmadığı sürece bir sözleşme bu duruma giremez.

* Dizi uzunluğu ifadelerinde sabitler kullanılması halinde Solidity'nin önceki sürümleri, değerlendirme ağacının (evaluation tree) tüm dallarında (branch) rastgele (arbitrary) kesinlik kullanırdı. Artık, sabit değişkenler ara ifadeler olarak kullanıldığında, değerleri, çalışma zamanı ifadelerinde kullanıldıklarında olduğu gibi uygun şekilde yuvarlanacaktır.

* ``byte`` türü kaldırıldı. Bu ``bytes1`` türünün bir takma adıydı.

Yeni Kısıtlamalar
================

Bu bölümde, mevcut sözleşmelerin artık derlenmemesine neden olabilecek değişiklikler listelenmektedir.

* Literallerin açık dönüşümleri ile ilgili yeni kısıtlamalar vardır. Aşağıdaki durumlarda önceki davranış muhtemelen belirsizdi:

  1. Negatif literallerden ve ``type(uint160).max`` değerinden büyük literallerden ``address`` değerine açık dönüşümlere izin verilmez.
  2. Literaller ve ``T`` tamsayı tipi arasındaki açık dönüşümlere yalnızca literal ``type(T).min`` ve ``type(T).max`` arasında yer alıyorsa izin verilir. Özellikle, ``uint(-1)`` kullanımlarını ``type(uint).max`` ile değiştirin.
  3. Literaller ve enumlar arasındaki açık dönüşümlere yalnızca literal enumdaki bir değeri temsil edebiliyorsa izin verilir.
  4. Literaller ve ``address`` türü arasındaki açık dönüşümler (örneğin ``address(literal)``) ``address payable`` yerine ``address`` türüne sahiptir. Açık bir dönüşüm, yani ``payable(literal)`` kullanılarak payable(ödenebilir) bir adres türü elde edilebilir.

* :ref:`Address literals<address_literals>`, ``address payable`` yerine ``address`` türüne sahiptir. Açık bir dönüşüm kullanılarak ``address payable`` türüne dönüştürülebilirler, örneğin ``payable(0xdCad3a6d3569DF655070DEd06cb7A1b2Ccd1D3AF)``.

* Açık tip dönüşümlerinde yeni kısıtlamalar vardır. Dönüşüme yalnızca işaret, genişlik veya tür kategorisinde en fazla bir değişiklik olduğunda izin verilir (``int``, ``adres``, ``bytesNN``, vb.). Birden fazla değişiklik yapmak için birden fazla dönüşüm kullanın.

  Burada, ``T`` ve ``S`` tipleri ve ``x`` de ``S`` tipindeki herhangi bir rastgele(arbitrary) değişken olmak üzere, ``T(x)`` açık dönüşümünü belirtmek için ``T(S)`` notasyonunu kullanalım. Hem genişliği (8 bitten 16 bite) hem de işareti (işaretli tamsayıdan işaretsiz tamsayıya) değiştirdiği için bu tür bir izin verilmeyen dönüştürmeye örnek olarak ``uint16(int8)`` verilebilir. Dönüştürmeyi yapmak için bir ara türden geçmek gerekir. Önceki örnekte, bu ``uint16(uint8(int8))`` veya ``uint16(int16(int8))`` olacaktır. Dönüştürmenin iki yolunun farklı sonuçlar üreteceğini unutmayın, örneğin ``-1`` için. Aşağıda, bu kural tarafından izin verilmeyen bazı dönüşüm örnekleri verilmiştir.

- ``address(uint)`` ve ``uint(address)``: hem tür kategorisini hem de genişliği dönüştürüyor. Bunu sırasıyla ``address(uint160(uint))`` ve ``uint(uint160(address))`` ile değiştirin.
  - ``payable(uint160)``, ``payable(bytes20)`` ve ``payable(integer-literal)``: hem tür kategorisini hem de durum değiştirilebilirliğini dönüştürüyor. Bunu sırasıyla ``payable(address(uint160))``, ``payable(address(bytes20))`` ve ``payable(address(integer-literal))`` ile değiştirin. ``payable(0)``ın geçerli olduğunu ve kuralın bir istisnası olduğunu unutmayın.
  - ``int80(bytes10)`` ve ``bytes10(int80)``: hem tür kategorisini hem de işareti dönüştürüyor. Bunu sırasıyla ``int80(uint80(bytes10))`` ve ``bytes10(uint80(int80)`` ile değiştirin.
  - ``Contract(uint)``: hem tür kategorisini hem de genişliği dönüştürüyor. Bunu ``Contract(address(uint160(uint)))`` ile değiştirin.

  Belirsizliği önlemek için bu dönüşümlere izin verilmemiştir. Örneğin, ``uint16 x = uint16(int8(-1))`` ifadesinde, ``x`` değeri, işaret ve genişlik dönüşümünden hangisinin önce uygulandığına bağlı olacaktır.

* Fonksiyon çağrı seçenekleri sadece bir kez verilebilir, yani ``c.f{gas: 10000}{value: 1}()`` geçersizdir ve ``c.f{gas: 10000, value: 1}()`` olarak değiştirilmelidir.

* Global fonksiyonlar ``log0``, ``log1``, ``log2``, ``log3`` ve ``log4`` kaldırılmıştır.

  Bunlar büyük ölçüde kullanılmayan düşük seviyeli fonksiyonlardır. Davranışlarına inline assembly'den erişilebilir.

* ``enum`` tanımları 256`dan fazla üye içeremez.

  Bu, ABI'deki temel türün her zaman ``uint8`` olduğunu varsaymayı güvenli hale getirecektir.

* Public fonksiyonlar ve event`ler haricinde ``this``, ``super`` ve ``_`` isimli açıklamalara izin verilmez. İstisna, bu tür fonksiyon isimlerine izin veren Solidity dışındaki dillerde uygulanan sözleşmelerin arayüzlerini açıklamayı mümkün kılmaktır.

* Koddaki ``\b``, ``\f`` ve ``\v`` kaçış dizileri için destek kaldırılmıştır. Bunlar, onaltılık kaçış dizileri aracılığıyla eklenmeye devam edebilir; örneğin, sırasıyla ``\x08``, ``\x0c`` ve ``\x0b``.

* Global değişkenler ``tx.origin`` ve ``msg.sender``, ``address payable`` yerine ``address`` tipine sahiptir. Bunlar, açık bir dönüşüm kullanılarak ``address payable`` türüne, yani ``payable(tx.origin)`` veya ``payable(msg.sender)``a dönüştürülebilir.

  Bu değişiklik, derleyicinin bu adreslerin ödenebilir olup olmadığını belirleyememesi nedeniyle yapılmıştır, bu nedenle artık bu gereksinimi görünür kılmak için açık bir dönüşüm gerektirmektedir. 

* ``address`` türüne açık dönüştürme her zaman ödenebilir olmayan bir ``address`` türü döndürür. Özellikle, aşağıdaki açık dönüşümler ``address payable`` yerine ``address`` türüne sahiptir:

  - ``address(u)`` burada ``u`` ``uint160`` türünde bir değişkendir. Biri ``u`` türünü iki açık dönüşüm kullanarak ``address payable`` türüne dönüştürebilir, yani ``payable(address(u))``.
  - ``address(b)`` burada ``b`` ``bytes20`` tipinde bir değişkendir. Biri ``b`` türünü iki açık dönüşüm kullanarak `` address payable`` türüne dönüştürebilir, yani ``payable(address(b))``.
  - ``address(c)``, burada ``c`` bir sözleşmedir. Önceden, bu dönüşümün dönüş türü, sözleşmenin Ether alıp alamayacağına bağlıydı (bir receive fonksiyonuna veya bir payable fallback fonksiyonuna sahip olarak). ``payable(c)`` dönüşümü ``address payable`` türüne sahiptir ve yalnızca ``c`` sözleşmesi Ether alabildiğinde izin verilir. Genel olarak, aşağıdaki açık dönüşüm kullanılarak ``c`` her zaman ``address payable`` türüne dönüştürülebilir: ``payable(address(c))``. ``address(this)`` türünün ``address(c)`` ile aynı kategoriye girdiğini ve aynı kuralların onun için de geçerli olduğunu unutmayın.

* Inline assembly`de yerleşik ``chainid`` artık ``pure`` yerine ``view`` olarak kabul edilmektedir.

* Tekli negasyon artık işaretsiz tamsayılar üzerinde kullanılamaz, sadece işaretli tamsayılar üzerinde kullanılabilir.

Arayüz Değişiklikleri
=================

* ``--combined-json`` çıktısı değişti: JSON alanları ``abi``, ``devdoc``, ``userdoc`` ve
  ``storage-layout`` artık alt nesnelerdir. 0.8.0'dan önce string olarak serileştiriliyorlardı.

* "Eski AST" kaldırıldı (komut satırı arayüzünde ``--ast-json`` ve standart JSON için ``legacyAST``).
  Yerine "kompakt AST" (``--ast-compact--json`` resp. ``AST``) kullanın.

* Eski hata raporlayıcı (``--old-reporter``) kaldırıldı.


Kodunuzu nasıl güncelleyebilirsiniz?
=======================

- Aritmetik paketlemeye güveniyorsanız, her işlemi ``unchecked { ... }``.
- İsteğe bağlı: SafeMath veya benzer bir kütüphane kullanıyorsanız, ``x.add(y)`` ifadesini ``x + y``, ``x.mul(y)`` ifadesini ``x * y`` vb. olarak değiştirin.
- Eski ABI kodlayıcı ile kalmak istiyorsanız ``pragma abicoder v1;`` ekleyin.
- İsteğe bağlı olarak ``pragma experimental ABIEncoderV2`` veya ``pragma abicoder v2`` gereksiz olduğu için kaldırın.
- ``byte`` ifadesini ``bytes1`` olarak değiştirin.
- Gerekirse ara açık tip dönüşümleri ekleyin.
- ``c.f{gas: 10000}{value: 1}()`` ifadesini ``c.f{gas: 10000, value: 1}()`` olarak birleştirin.
- ``msg.sender.transfer(x)`` öğesini ``payable(msg.sender).transfer(x)`` olarak değiştirin veya ``address payable`` türünde bir saklı değişken kullanın.
- ``x**y**z`` ifadesini ``(x**y)**z`` olarak değiştirin.
- ``log0``, ..., ``log4`` yerine inline assembly kullanın.
- İşaretsiz tamsayıları, türün maksimum değerinden çıkarıp 1 ekleyerek negatifleştirin (örneğin ``type(uint256).max - x + 1``, `x`in sıfır olmadığından emin olarak)
