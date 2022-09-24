*********************************************
Solidity v0.6.0 İşleyişi Bozan Değişiklikler
*********************************************

Bu bölüm, Solidity 0.6.0 sürümünde getirilen ana işleyişi bozan değişiklikleri,
değişikliklerin arkasındaki gerekçeleri ve etkilenen kodun nasıl güncelleneceğini
vurgular. Tam liste için `sürüm değişiklik günlüğü <https://github.com/ethereum/solidity/releases/tag/v0.6.0>`_
adresini kontrol edin.


Derleyicinin Uyaramayabileceği Değişiklikler
=============================================

Bu bölümde, kodunuzun davranışının derleyici size haber vermeden değişebileceği değişiklikler listelenmektedir.

* Bir üs alma işleminin sonuç türü tabanın türüdür. Simetrik işlemlerde olduğu gibi, hem
  tabanın türünü hem de üssün türünü tutabilen en küçük tür olarak kullanılır. Ayrıca, üs
  alma işleminin tabanı için işaretli türlere izin verilir.


Açıklık Gereksinimleri
=========================

Bu bölüm, kodun artık daha açık olması gereken, ancak anlamın değişmediği değişiklikleri
listeler. Konuların çoğu için derleyici öneriler sağlayacaktır.

* Fonksiyonlar artık yalnızca ``virtual`` anahtar sözcüğü ile işaretlendiklerinde veya bir arayüzde tanımlandıklarında geçersiz kılınabilir. Bir arayüz dışında uygulaması olmayan fonksiyonlar ``virtual`` olarak işaretlenmelidir. Bir fonksiyon veya modifier geçersiz kılınırken, yeni ``override`` anahtar sözcüğü kullanılmalıdır. Birden fazla paralel tabanda tanımlanmış bir fonksiyon veya modifier geçersiz kılınırken, tüm tabanlar anahtar kelimeden sonra parantez içinde aşağıdaki gibi listelenmelidir: ``override(Base1, Base2)``.

* Dizilerin ``length`` öğesine üye erişimi artık depolama dizileri için bile her zaman salt okunurdur. Depolama dizilerini uzunluklarına yeni bir değer atayarak yeniden boyutlandırmak artık mümkün değildir. Bunun yerine ``push()``, ``push(value)`` veya ``pop()`` kullanın ya da tam bir dizi atayın, bu da elbette mevcut içeriğin üzerine yazacaktır. Bunun arkasındaki neden, devasa depolama dizilerinin depolama çakışmalarını önlemektir.

* Yeni anahtar kelime ``abstract`` sözleşmeleri soyut olarak işaretlemek için kullanılabilir. Bir sözleşme tüm fonksiyonlarını uygulamıyorsa kullanılmalıdır. Soyut sözleşmeler ``new`` operatörü kullanılarak oluşturulamaz ve derleme sırasında bunlar için bytecode üretmek mümkün değildir.

* Kütüphaneler sadece internal olanları değil, tüm fonksiyonlarını uygulamak zorundadır.

* Inline assembly'de bildirilen değişkenlerin adları artık ``_slot`` veya ``_offset`` ile bitemez.

* Inline assembly'deki değişken bildirimleri artık inline assembly bloğunun dışındaki herhangi bir bildirimi gölgeleyemez. İsim bir nokta içeriyorsa, noktaya kadar olan öneki, inline assembly bloğu dışındaki herhangi bir bildirimle çakışmayabilir.

* Durum değişkeni gölgelemesine artık izin verilmemektedir.  Türetilmiş bir sözleşme, yalnızca tabanlarının hiçbirinde aynı ada sahip görünür bir durum değişkeni yoksa ``x`` durum değişkenini bildirebilir.


Semantik ve Sentaktik Değişiklikler
====================================

Bu bölüm, kodunuzu değiştirmeniz gereken ve daha sonra başka bir şey yapan değişiklikleri listeler.

* External fonksiyon tiplerinden ``address`` e dönüşümlere artık izin verilmiyor. Bunun yerine harici fonksiyon tipleri, mevcut ``selector`` üyesine benzer şekilde ``address`` adlı bir üyeye sahiptir.

* Dinamik depolama dizileri için ``push(value)`` fonksiyonu artık yeni uzunluğu döndürmüyor (hiçbir şey döndürmüyor).

* Genellikle " fallback fonksiyonu" olarak adlandırılan isimsiz fonksiyon, ``fallback`` anahtar kelimesi kullanılarak tanımlanan yeni bir fallback fonksiyonuna ve ``receive`` anahtar kelimesi kullanılarak tanımlanan bir receive ether fonksiyonuna bölünmüştür.

  * Mevcutsa, çağrı verisi boş olduğunda ( ether alınsın ya da alınmasın) ether alma fonksiyonu çağrılır. Bu fonksiyon örtük olarak ``payable`` dır.

  * Yeni fallback fonksiyonu, başka hiçbir fonksiyon uyuşmadığında çağrılır (eğer receive ether fonksiyonu mevcut değilse, bu boş çağrı verisine sahip çağrıları da içerir). Bu fonksiyonu ``payable`` yapabilir ya da yapmayabilirsiniz. Eğer ``payable`` değilse, değer gönderen başka bir fonksiyonla eşleşmeyen işlemler geri dönecektir. Yeni fallback fonksiyonunu yalnızca bir yükseltme veya proxy modelini takip ediyorsanız uygulamanız gerekir.


Yeni Özellikler
===============

Bu bölümde Solidity 0.6.0 öncesinde mümkün olmayan veya başarılması daha zor olan şeyler listelenmektedir.

* ref:`try/catch deyimi <try-catch>` başarısız external çağrılara tepki vermenizi sağlar.
* ``struct`` ve ``enum`` türleri dosya düzeyinde bildirilebilir.
* Dizi dilimleri calldata dizileri için kullanılabilir, örneğin ``abi.decode(msg.data[4:], (uint, uint))`` fonksiyon çağrısı yükünün kodunu çözmenin düşük seviyeli bir yoludur.
* Natspec, geliştirici belgelerinde ``@param`` ile aynı adlandırma kontrolünü uygulayarak birden fazla dönüş parametresini destekler.
* Yul ve Inline Assembly, mevcut fonksiyondan çıkan ``leave`` adlı yeni bir deyime sahiptir.
* ``address``'den ``address payable``'a dönüşümler artık ``payable(x)`` ile mümkündür, burada ``x`` ``address`` tipinde olmalıdır.


Arayüz Değişiklikleri
======================

Bu bölümde, dilin kendisiyle ilgili olmayan ancak derleyicinin arayüzleri üzerinde
etkisi olan değişiklikler listelenmektedir. Bunlar derleyiciyi komut satırında nasıl
kullandığınızı, programlanabilir arayüzünü nasıl kullandığınızı veya derleyici tarafından
üretilen çıktıyı nasıl analiz ettiğinizi değiştirebilir.

Yeni Hata Raporlayıcısı
~~~~~~~~~~~~~~~~~~~~~~~~

Komut satırında daha erişilebilir hata mesajları üretmeyi amaçlayan yeni bir hata raporlayıcı tanıtıldı. Öntanımlı olarak etkindir, ancak ``--old-reporter`` geçildiğinde kullanımdan kaldırılmış eski hata raporlayıcısına geri dönülür.

Metadata Hash Seçenekleri
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Derleyici artık metadata dosyasının `IPFS <https://ipfs.io/>`_ hash'ini varsayılan olarak bytecode'un sonuna ekliyor (ayrıntılar için :doc:`contract metadata <metadata>` belgesine bakın). 0.6.0'dan önce derleyici varsayılan olarak `Swarm <https://ethersphere.github.io/swarm-home/>`_ hash'ini ekliyordu ve bu davranışı desteklemeye devam etmek için yeni komut satırı seçeneği ``--metadata-hash`` tanıtıldı. Bu, ``--metadata-hash`` komut satırı seçeneğine değer olarak ``ipfs`` veya ``swarm`` değerlerinden birini geçirerek üretilecek ve eklenecek hash'i seçmenize olanak tanır. ``none`` değerinin geçilmesi hash'i tamamen kaldırır.

Bu değişiklikler :ref:`Standard JSON Interface<compiler-api>` aracılığıyla da kullanılabilir ve derleyici tarafından oluşturulan metadata JSON'u etkiler.

Metadata'ları okumak için önerilen yol, CBOR şifrelemesinin uzunluğunu belirlemek için son iki baytı okumak ve :ref:`metadata section<encoding-of-the-metadata-hash-in-the-bytecode>` bölümünde açıklandığı gibi bu veri bloğu üzerinde uygun bir şifre çözme işlemi gerçekleştirmektir.

Yul Optimize Edici
~~~~~~~~~~~~~

Eski bytecode optimizer ile birlikte, :doc:`Yul <yul>` optimizer artık derleyiciyi ``--optimize`` ile çağırdığınızda varsayılan olarak etkinleştirilir. Derleyiciyi ``--no-optimize-yul`` ile çağırarak devre dışı bırakılabilir. Bu çoğunlukla ABI coder v2 kullanan kodları etkiler.

C API Değişiklikleri
~~~~~~~~~~~~~~~~~~~~~~~~~

``libsolc`` C API`sini kullanan istemci kodu artık derleyici tarafından kullanılan belleğin
kontrolünü elinde tutmaktadır. Bu değişikliği tutarlı hale getirmek için ``solidity_free``
fonksiyonu ``solidity_reset`` olarak yeniden adlandırıldı, ``solidity_alloc`` ve ``solidity_free``
fonksiyonları eklendi ve ``solidity_compile`` artık ``solidity_free()`` ile açıkça serbest bırakılması gereken bir string döndürüyor.


Kodunuzu nasıl güncelleyebilirsiniz?
=====================================

Bu bölüm, her işleyişi bozan değişiklik için önceki kodun nasıl güncelleneceğine ilişkin ayrıntılı talimatlar vermektedir.

* ``f`` external fonksiyon tipinde olduğu için ``address(f)`` ifadesini ``f.address`` olarak değiştirin.

* ``fonksiyon () external [payable] { ... }`` yerine ``receive() external payable { ... }``, ``fallback() external [payable] { ... }`` veya her ikisiyle. Mümkün olduğunda sadece ``receive`` fonksiyonunu kullanmayı tercih edin.

* ``uint length = array.push(value)`` ifadesini ``array.push(value);`` olarak değiştirin. Yeni uzunluğa ``array.length`` aracılığıyla erişilebilir.

* Bir depolama dizisinin uzunluğunu artırmak için ``array.length++`` öğesini ``array.push()`` olarak değiştirin ve azaltmak için ``pop()`` öğesini kullanın.

* Bir fonksiyonun ``@dev`` dokümantasyonundaki her adlandırılmış geri dönüş parametresi için, parametrenin adını ilk kelime olarak içeren bir ``@return`` girişi tanımlayın. Örneğin, ``f()`` fonksiyonu ``function f() public returns (uint value)`` şeklinde tanımlanmışsa ve ``@dev`` şeklinde bir açıklama varsa, geri dönüş parametrelerini aşağıdaki gibi belgeleyin: ``@return value Dönüş değeri.``. Bildirimler tuple dönüş türünde göründükleri sırada olduğu sürece, adlandırılmış ve adlandırılmamış dönüş parametreleri belgelerini karıştırabilirsiniz.

* Inline assembly'deki değişken bildirimleri için inline assembly bloğu dışındaki bildirimlerle çakışmayan benzersiz tanımlayıcılar seçin.

* Geçersiz kılmayı düşündüğünüz her arayüz dışı işleve ``virtual`` ekleyin. Arayüzler dışında uygulaması olmayan tüm fonksiyonlara ``virtual`` ekleyin. Tekli kalıtım için, her geçersiz kılma fonksiyonuna ``override`` ekleyin. Çoklu kalıtım için, ``override(A, B, ..)`` ekleyin, burada parantez içinde geçersiz kılınan fonksiyonu tanımlayan tüm sözleşmeleri listelersiniz. Birden fazla taban aynı fonksiyonu tanımladığında, devralan sözleşme çakışan tüm fonksiyonları geçersiz kılmalıdır.
