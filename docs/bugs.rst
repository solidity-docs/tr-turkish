.. index:: Bugs

.. _known_bugs:

##################
Bilinen Bugların Listesi
##################

Aşağıda, Solidity derleyicisindeki güvenlikle ilgili bilinen bazı hataların JSON
biçimli bir listesini bulabilirsiniz. Dosyanın kendisi `Github repository <https://github.com/ethereum/solidity/blob/develop/docs/bugs.json>`_'de
barındırılmaktadır. Liste 0.3.0 sürümüne kadar uzanmaktadır, yalnızca bundan önceki
sürümlerde mevcut olduğu bilinen hatalar listelenmemiştir.

Hangi hataların derleyicinin belirli bir sürümünü etkilediğini kontrol etmek için kullanılabilecek `bugs_by_version.json <https://github.com/ethereum/solidity/blob/develop/docs/bugs_by_version.json>`_ adlı başka bir dosya daha vardır.

Sözleşme kaynağı doğrulama araçları ve ayrıca sözleşmelerle etkileşime giren diğer araçlar aşağıdaki kriterlere göre bu listeye başvurmalıdır:

- Bir sözleşmenin yayınlanmış bir sürüm yerine gecelik bir derleyici sürümüyle derlenmiş olması biraz şüphelidir. Bu liste yayınlanmamış veya gecelik sürümlerin kaydını tutmaz.
- Bir sözleşmenin, sözleşmenin oluşturulduğu sırada en yeni sürüm olmayan bir sürümle derlenmiş olması da hafif derecede şüphelidir. Diğer sözleşmelerden oluşturulan sözleşmeler için, oluşturma zincirini bir işleme kadar takip etmeniz ve oluşturma tarihi olarak bu işlemin tarihini kullanmanız gerekir.
- Bir sözleşmenin bilinen bir hata içeren bir derleyici ile derlenmiş olması ve sözleşmenin, düzeltme içeren daha yeni bir derleyici sürümünün zaten yayınlanmış olduğu bir zamanda oluşturulmuş olması son derece şüphelidir.

Aşağıdaki bilinen hataların JSON dosyası, her hata için bir tane olmak üzere aşağıdaki anahtarlara sahip bir nesne dizisidir:

uid
    Hataya ``SOL-<year>-<number>`` şeklinde verilen benzersiz tanımlayıcı. Aynı uid
    ile birden fazla giriş olması mümkündür. Bu, birden fazla sürüm aralığının aynı
    hatadan etkilendiği anlamına gelir.
name
    Hataya verilen benzersiz isim
summary
    Hatanın kısa açıklaması
description
    Hatanın ayrıntılı açıklaması
link
    Daha ayrıntılı bilgi içeren bir web sitesinin URL'si, isteğe bağlı
introduced
    Hatayı içeren ilk yayınlanan derleyici sürümü, isteğe bağlıdır
fixed
    Artık hata içermeyen ilk yayınlanan derleyici sürümü
publish
    Hatanın kamuoyu tarafından bilindiği tarih, isteğe bağlıdır
severity
    Hatanın ciddiyeti: çok düşük, düşük, orta, yüksek. Sözleşme testlerinde
    keşfedilebilirliği, ortaya çıkma olasılığını ve istismarların potansiyel
    zararını dikkate alır.
conditions
    Hatayı tetiklemek için karşılanması gereken koşullar. Aşağıdaki anahtarlar
    kullanılabilir: ``optimizer``, hatayı etkinleştirmek için optimize edicinin
    açık olması gerektiği anlamına gelen Boolean değeri. ``evmVersion``, hangi
    EVM sürümü derleyici ayarlarının hatayı tetiklediğini gösteren bir dize. Dize
    karşılaştırma operatörleri içerebilir. Örneğin, ``">=constantinople"``, hatanın
    EVM sürümü ``constantinople`` veya üstü olarak ayarlandığında mevcut olduğu
    anlamına gelir. Herhangi bir koşul belirtilmezse, hatanın mevcut olduğu varsayılır.
check
    Bu alan, akıllı sözleşmenin hatayı içerip içermediğini bildiren farklı kontroller
    içerir. İlk kontrol türü, hatanın mevcut olması durumunda kaynak kodla ("source-regex")
    eşleştirilecek Javascript düzenli ifadeleridir.  Eşleşme yoksa, hata büyük olasılıkla 
    mevcut değildir. Eğer bir eşleşme varsa, hata mevcut olabilir.  Daha iyi tutarlılık
    için, kontroller yorumlar çıkarıldıktan sonra kaynak koda uygulanmalıdır. İkinci kontrol
    türü, Solidity programının kompakt AST'sinde ("ast-compact-json-path") kontrol edilecek
    kalıplardır. Belirtilen arama sorgusu bir `JsonPath <https://github.com/json-path/JsonPath>`_
    ifadesidir. Solidity AST'nin en az bir yolu sorguyla eşleşiyorsa, hata muhtemelen mevcuttur.

.. literalinclude:: bugs.json
   :language: js
