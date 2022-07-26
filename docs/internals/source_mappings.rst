.. index:: source mappings

***************
Mapping Kaynakları
***************

AST çıktısının bir parçası olarak derleyici, AST'deki ilgili node tarafından
temsil edilen kaynak kod aralığını sağlar. Bu durum AST'ye dayalı olarak rapor
veren statik analiz araçlarından, yerel değişkenleri ve kullanımlarını vurgulayan
hata ayıklama araçlarına kadar çeşitli amaçlar için kullanılabilir.

Ayrıca derleyici, bytecode'dan komutu oluşturan kaynak koddaki aralığa kadar bir
mapping de oluşturabilir. Bu durum bytecode seviyesinde çalışan statik analiz araçları
ve bir hata ayıklayıcı için kaynak koddaki mevcut konumu görüntülemek veya breakpoint
işleme açısından önemlidir. Bu mapping aynı zamanda atlama(jump) tipi ve modifier derinliği
gibi diğer bilgileri de içerir (aşağıya bakınız).

Her iki tür kaynak mapping'i de kaynak dosyalara başvurmak için tamsayı tanımlayıcıları
kullanır. Bir kaynak dosyasının tanımlayıcısı ``output['sources'][sourceName]['id']`` içinde
saklanır, buradaki ``output`` aynı zamanda JSON olarak ayrıştırılmış standart-json derleyici
arayüzünün çıktısıdır. Bazı yardımcı program rutinleri için derleyici, orijinal girdinin bir
parçası olmayan ancak kaynak mappinglerinden referans alınan “internal" kaynak dosyaları üretir.
Bu kaynak dosyalar tanımlayıcılarıyla birlikte
``output['contracts'][sourceName][contractName]['evm']['bytecode']['generatedSources']`` aracılığıyla elde edilebilir.

.. note ::
    Belirli bir kaynak dosyasıyla ilişkilendirilmemiş talimatlar söz konusu
    olduğunda, kaynak mapping ``-1`` değerinde bir tamsayı tanımlayıcı atar.
    Bu, derleyici tarafından oluşturulan satır içi assembly komutlarından
    kaynaklanan bytecode bölümleri için söz konusu olabilir.

AST içindeki kaynak mapping'leri aşağıdaki gösterimi kullanır:

``s:l:f``

Burada ``s`` kaynak dosyadaki aralığın başlangıcındaki bayt ofseti, ``l``
kaynak aralığının bayt cinsinden uzunluğu ve ``f`` yukarıda belirtilen kaynak indeksidir.

Bayt kodu için kaynak mapping'deki kodlama daha karmaşıktır: Bu, ``;`` ile ayrılmış
``s:l:f:j:m`` listesidir. Bu öğelerin her biri bir komuta karşılık gelir, yani bayt
ofsetini kullanamazsınız, ancak komut ofsetini kullanmanız gerekir (push komutları
tek bir bayttan daha uzundur). ``s``, ``l`` ve ``f`` alanları yukarıdaki gibidir.
``j`` alanı ``i``, ``o`` ya da ``-`` olabilir, bu da bir atlama(jump) talimatının bir
fonksiyona mı girdiğini, bir fonksiyondan mı döndüğünü ya da örneğin bir döngünün
parçası olarak normal bir atlama(jump) mı olduğunu gösterir. Son kısım olan ``m``, "
modifier derinliğini" ifade eden bir tamsayıdır. Bu derinlik, placeholder(yer tutucu) ifade (``_``)
bir modifier'a her girildiğinde artırılır ve tekrar bırakıldığında azaltılır.
Bu, hata ayıklayıcıların aynı modifier'ın iki kez kullanılması veya tek bir modifier'da
birden fazla placeholder(yer tutucu) ifadenin kullanılması gibi zor durumları takip etmesini sağlar.

Özellikle bytecode için bu kaynak mapping'lerini sıkıştırmak amacıyla aşağıdaki kurallar uygulanır:

- Eğer bir alan boşsa, bir önceki elemanın değeri kullanılır.
- Eğer bir ``:`` eksikse, takip eden tüm alanlar boş kabul edilir.

Bu, aşağıdaki kaynak mapping'lerinin aynı bilgiyi temsil ettiği anlamına gelir:

``1:2:1;1:9:1;2:1:2;2:1:2;2:1:2``

``1:2:1;:9;2:1:2;;``

Dikkat edilmesi gereken önemli bir nokta, :ref:`verbatim <yul-verbatim>` yerleşik
öğesi kullanıldığında, kaynak mapping'lerinin geçersiz olacağıdır: Yerleşik komut,
potansiyel olarak birden fazla komut yerine tek bir komut olarak kabul edilir.
