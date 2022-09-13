********************************
Solidity v0.7.0 İşleyişi Bozan Değişiklikler
********************************

Bu bölüm, Solidity 0.7.0 sürümünde getirilen ana işleyişi bozan değişiklikleri,
değişikliklerin arkasındaki gerekçeleri ve etkilenen kodun nasıl güncelleneceğini
vurgular. Tam liste için `sürüm değişiklik günlüğü <https://github.com/ethereum/solidity/releases/tag/v0.7.0>`_
adresini kontrol edin.


Semantiğin Sessiz Değişiklikleri
===============================

* Literallerin literal olmayanlarla üslendirilmesi ve kaydırılması (örneğin ``1 << x``
  veya ``2 ** x``) işlemi gerçekleştirmek için her zaman ``uint256`` (negatif olmayan
  literaller için) veya ``int256`` (negatif literaller için) türünü kullanacaktır.
  Önceden, işlem kaydırma miktarı / üstel türde gerçekleştiriliyordu ve bu da yanıltıcı
  olabiliyordu.


Sözdizimindeki Değişiklikler
=====================

* External fonksiyon ve sözleşme oluşturma çağrılarında, Ether ve gas artık yeni bir sözdizimi kullanılarak belirtiliyor: ``x.f{gaz: 10000, değer: 2 eter}(arg1, arg2)``. Eski sözdizimi -- ``x.f.gas(10000).value(2 ether)(arg1, arg2)`` -- bir hataya neden olacaktır.

* Global değişken ``now`` kullanımdan kaldırılmıştır, bunun yerine ``block.timestamp`` kullanılmalıdır. Tek tanımlayıcı ``now`` global bir değişken için çok geneldir ve işlem sırasında değiştiği izlenimini verebilir, oysa ``block.timestamp`` sadece bloğun bir özelliği olduğu gerçeğini doğru bir şekilde yansıtır.

* Değişkenler üzerindeki NatSpec yorumlarına yalnızca genel durum değişkenleri için izin verilir, yerel veya dahili değişkenler için izin verilmez.

* ``gwei`` belirteci artık bir anahtar kelimedir (örneğin ``2 gwei`` bir sayı olarak belirtmek için kullanılır) ve bir tanımlayıcı olarak kullanılamaz.

* String değişmezleri artık yalnızca yazdırılabilir ASCII karakterleri içerebilir ve bu aynı zamanda heksadesimal (``\xff``) ve unicode escapes (``\u20ac``) gibi çeşitli kaçış dizilerini de içerir.

* Unicode string literals artık geçerli UTF-8 dizilimlerini barındırmak için desteklenmektedir. Bunlar ``unicode`` öneki ile tanımlanır: ``unicode "Hello 😃"``.

* Durum Değiştirilebilirliği: Fonksiyonların durum değiştirilebilirliği artık kalıtım sırasında kısıtlanabilir: Varsayılan durum değiştirilebilirliğine sahip fonksiyonlar ``pure`` ve ``view`` fonksiyonları tarafından geçersiz kılınabilirken, ``view`` fonksiyonları ``pure`` fonksiyonları tarafından geçersiz kılınabilir. Aynı zamanda, genel durum değişkenleri sabitlerse ``view`` ve hatta ``pure`` olarak kabul edilir.



Inline Assembly
---------------

* Inline assembly'de kullanıcı tanımlı fonksiyon ve değişken isimlerinde ``.`` ifadesine izin vermeyin. Solidity'yi Yul-only modunda kullanırsanız bu durum hala geçerlidir.

* ``x`` depolama işaretçisi değişkeninin yuvasına ve ofsetine ``x_slot`` ve ``x_offset`` yerine ``x.slot`` ve ``x.offset`` üzerinden erişilir.

Kullanılmayan veya Güvenli Olmayan Özelliklerin Kaldırılması
====================================

Depolama dışındaki eşleştirmeler(Mappings outside Storage)
------------------------

* Bir struct veya dizi bir mapping içeriyorsa, yalnızca depolama alanında kullanılabilir. Önceden, mapping üyeleri bellekte sessizce atlanıyordu, bu da kafa karıştırıcı ve hataya açıktı.

* Depolama alanındaki struct veya dizilere yapılan atamalar, mapping içeriyorsa çalışmaz. Önceden, mappingler kopyalama işlemi sırasında sessizce atlanıyordu, bu da yanıltıcı ve hataya açıktı.

Fonksiyonlar ve Events
--------------------

* Görünürlük (``public`` / ``internal``) artık constructor`lar için gerekli değildir: Bir sözleşmenin oluşturulmasını önlemek için, sözleşme ``abstract`` olarak işaretlenebilir. Bu, constructor'lar için görünürlük kavramını geçersiz kılar.

* Tip Denetleyicisi: Kütüphane fonksiyonları için ``virtual`` işaretine izin vermeyin: Kütüphanelerden miras alınamayacağı için, kütüphane fonksiyonları sanal olmamalıdır.

* Aynı kalıtım hiyerarşisinde aynı isme ve parametre türlerine sahip birden fazla event'e izin verilmez.

* ``using A for B`` yalnızca içinde bahsedildiği sözleşmeyi etkiler. Önceden, etki kalıtsaldı. Şimdi, özelliği kullanan tüm türetilmiş sözleşmelerde ``using`` ifadesini tekrarlamanız gerekir.

İfadeler
-----------

* İşaretli türlere göre kaydırmalara izin verilmez. Daha önce, negatif miktarlarla kaydırmalara izin veriliyordu, ancak çalışma zamanında geri döndürülüyordu.

* ``finney`` ve ``szabo`` değerleri kaldırılmıştır. Bunlar nadiren kullanılır ve gerçek miktarı kolayca görünür hale getirmez. Bunun yerine, ``1e20`` veya çok yaygın olan ``gwei`` gibi açık değerler kullanılabilir.

Bildiriler
------------

* ``var`` anahtar sözcüğü artık kullanılamıyor. Önceden, bu anahtar sözcük ayrıştırılır ancak bir tür hatasına ve hangi türün kullanılacağına ilişkin bir öneriye neden olurdu. Şimdi, bir ayrıştırıcı hatasıyla sonuçlanıyor.

Arayüz Değişiklikleri
=================

* JSON AST: Hex string değişmezlerini ``kind: "hexString"`` ile işaretleyin.
* JSON AST: Değeri ``null`` olan üyeler JSON çıktısından kaldırılır.
* NatSpec: Constructor ve fonksiyonlar tutarlı userdoc çıktısına sahiptir.


Kodunuzu nasıl güncelleyebilirsiniz?
=======================

Bu bölümde, her işleyişi bozan değişiklik için önceki kodun nasıl güncelleneceğine ilişkin ayrıntılı talimatlar verilmektedir.

* ``x.f.value(...)()`` ifadesini ``x.f{value: ...}()`` olarak değiştirin. Benzer şekilde ``(new C).value(...)()`` ``new C{value: ...}()`` ve ``x.f.gas(...).value(...)()`` ``x.f{gas: ..., value: ...}()`` olarak değiştirin.
* ``now`` ifadesini ``block.timestamp`` olarak değiştirin.
* Kaydırma operatörlerindeki sağ operand tiplerini işaretsiz tipler olarak değiştirin. Örneğin ``x >> (256 - y)`` ifadesini ``x >> uint(256 - y)`` olarak değiştirin.
* Gerekirse tüm türetilmiş sözleşmelerde ``using A for B`` ifadelerini tekrarlayın.
* Her constructor`dan ``public`` anahtar sözcüğünü kaldırın.
* Her constructor`dan ``internal`` anahtar sözcüğünü kaldırın ve sözleşmeye ``abstract`` ekleyin (henüz mevcut değilse).
* Inline assembly`deki ``_slot`` ve ``_offset`` soneklerini sırasıyla ``.slot`` ve ``.offset`` olarak değiştirin.
