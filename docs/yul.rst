.. _yul:

###
Yul
###

.. index:: ! assembly, ! asm, ! evmasm, ! yul, julia, iulia

Yul (önceden JULIA veya IULIA olarak da adlandırılmıştır), farklı backend'ler için bayt koduna derlenebilen bir ara dildir.

EVM 1.0, EVM 1.5 ve Ewasm desteği planlanmış olup, her üç platformda 
kullanılabilir bir ortak paydası olacak şekilde 
tasarlanmıştır. Halihazırda Solidity içinde bağımsız modda ve 
"inline (satır-içi) Assembly" için kullanılabilir ve Solidity derleyicisinin Yul'u bir ara dil olarak 
kullanan  deneysel bir uygulaması bulunmaktadır. Yul, üst düzey optimizasyon aşamaları için 
tüm hedef platformlara eşit olarak fayda sağlayabilecek  iyi bir araçtır.

Motivasyon ve Üst-düzey Tanımı
=====================================

Yul'un tasarımı birkaç hedef doğrultusunda çalışmaktadır:

1. Yul'da yazılan programlar, yazılan kod Solidity veya bir başka üst düzey dilden bir derleyici tarafından oluşturulmuş olsa bile okunabilir olmalıdır.
2. Kontrol akışı, manuel incelemeye, resmi doğrulamaya ve optimizasyona yardımcı olmak amacıyla anlaşılması kolay olmalıdır.
3. Yul'den bytecode'a çeviri mümkün olduğunca basit olmalıdır.
4. Yul, programın tüm optimizasyonu için uygun olmalıdır..

Yul, birinci ve ikinci amaca ulaşmak için ``for`` döngüleri, ``if`` ve ``switch`` ifadeleri 
ve fonksiyon çağrıları gibi üst düzey yapılar sağlar. Bunlar, assembly programları için 
kontrol akışını yeterince ifade edebilir olmalıdır.
Bu nedenle, ``SWAP``, ``DUP``, ``JUMPDEST``, ``JUMP`` ve ``JUMPI`` 
için belirgin ifadeler sağlanmamaktadır, çünkü ilk ikisi veri akışını ve 
son ikisi de kontrol akışını belirsizleştirmektedir. Ayrıca, ``mul(add(x,y), 7)`` biçimindeki fonksiyonel 
ifadeler, ``7 y x add mul`` gibi saf işlem kodu ifadelerine tercih edilir, 
çünkü birinci biçimde, hangi işlemcinin hangi işlem kodu için kullanıldığını görmek çok daha kolaydır.

Stack (yığın) makineleri için tasarlanmış olsa da, Yul stack karmaşıklığını ortaya çıkarmaz. 
Programcı veya denetçinin stack hakkında endişelenmesine gerek yoktur.

Üçüncü hedef, daha üst düzey yapılar çok düzenli 
bir şekilde bytecode'a derlenerek elde edilir.
Derleyici tarafından gerçekleştirilen lokal olmayan tek işlem,
kullanıcının atadığı tanımlayıcıların (fonksiyonlar, değişkenler, …) 
ad araması ve yığından (stack) yerel değişkenlerin temizlenmesidir.

Değerler ve referanslar gibi kavramlar arasındaki karışıklığı 
önlemek için Yul statik olarak yazılır. Aynı zamanda, 
okunabilirliğe yardımcı olmak için her zaman ihmal edilebilecek 
bir varsayılan tür (genellikle hedef makinenin tamsayı sözcüğü) vardır.

Dili basit ve esnek tutmak için Yul, saf haliyle herhangi 
bir gömülü işlem, fonksiyon veya türe sahip değildir.
Bunlar, Yul'un farklı hedef platformların ve özellik kümelerinin 
gereksinimlerine göre özelleştirilmesine izin veren 
bir Yul diyalekti belirlenirken semantikleriyle birlikte eklenir.

Şu anda, Yul'un belirlenmiş yalnızca bir tane diyalekti var. Bu diyalekt, 
gömülü fonksiyonlar olarak EVM işlem kodlarını kullanır (aşağıya bakınız) 
ve yalnızca EVM'nin yerel 256 bit türü olan ``u256`` türünü tanımlar. 
Bu nedenle, aşağıdaki örneklerde türlerden bahsetmeyeceğiz.


Basit Bir Örnek
================

Aşağıdaki örnek program EVM diyalektiyle yazılmıştır ve üs alma işlemini hesaplar.
``solc --strict-assembly`` kullanılarak derlenebilir.
Yerleşik fonksiyonlar olan ``mul`` ve ``div``, sırasıyla çarpma ve bölme işlemlerini yapar.

.. code-block:: yul

    {
        function power(base, exponent) -> result
        {
            switch exponent
            case 0 { result := 1 }
            case 1 { result := base }
            default
            {
                result := power(mul(base, base), div(exponent, 2))
                switch mod(exponent, 2)
                    case 1 { result := mul(base, result) }
            }
        }
    }

Aynı fonksiyonu özyineleme (recursion) yerine bir for döngüsü 
kullanarak da uygulamak mümkündür. Burada ``lt(a, b)``, ``a``'nın ``b``'den küçük olup olmadığını hesaplar. 


.. code-block:: yul

    {
        function power(base, exponent) -> result
        {
            result := 1
            for { let i := 0 } lt(i, exponent) { i := add(i, 1) }
            {
                result := mul(result, base)
            }
        }
    }

:ref:`Bölümün sonunda <erc20yul>`, ERC-20 standardı ile ilgili eksiksiz bir uygulama bulunabilir.



Tek Başına Kullanım
====================

Yul'u Solidity derleyicisini kullanarak EVM diyalektinde tek başına kullanabilirsiniz. 
Bu, Yul nesne notasyonunu kullanır, böylece sözleşmeleri deploy etmek için koda veri 
olarak atıfta bulunulabilir. Bu Yul modu, komut satırı derleyicisi 
( ``--strict-assembly`` kullanın) ve :ref:`standard-json arayüzü <compiler-api>` için kullanılabilir:

.. code-block:: json

    {
        "language": "Yul",
        "sources": { "input.yul": { "content": "{ sstore(0, 1) }" } },
        "settings": {
            "outputSelection": { "*": { "*": ["*"], "": [ "*" ] } },
            "optimizer": { "enabled": true, "details": { "yul": true } }
        }
    }

.. warning::

    Yul aktif geliştirme aşamasındadır ve bayt kodu oluşturma, yalnızca hedef olarak EVM 1.0 
    ile Yul'un EVM diyalekti için tam olarak uygulanabilir.


Yul'un Resmi Olmayan Tanımı
===========================

Aşağıda Yul dilinin bütün yönleri hakkında konuşacağız. Örneklerde varsayılan EVM diyalektini kullanacağız.

Sözdizimi (Syntax)
-------------------

Yul, yorumları, değişmez değerleri ve tanımlayıcıları Solidity ile aynı şekilde ayrıştırır,
böylece örneğin yorumları belirtmek için  ``//`` ve ``/* */`` kullanabilirsiniz.  
Bir istisna vardır: Yul'daki tanımlayıcılar noktalar içerebilir: ``.``.

Yul, kod, veri ve alt nesnelerden oluşan “nesneler” belirleyebilir. 
Bununla ilgili ayrıntılar için lütfen aşağıdaki :ref:`Yul Nesneleri <yul-object>` bölümüne bakın. 
Bu bölümde, bu tür bir nesnenin sadece kod kısmı ile ilgileniyoruz.
Bu kod bölümü her zaman süslü parantezlerle ayrılmış bir bloktan oluşur. 
Çoğu araç, bir nesnenin olması beklenen yerde yalnızca bir 
kod bloğu tanımlamayı destekler.

Bir kod bloğu içinde aşağıdaki öğeler kullanılabilir 
(daha fazla ayrıntı için sonraki bölümlere bakınız):

- değişmez değerler (literal), yani ``0x123``, ``42`` veya ``"abc"`` (32 karaktere kadar string'ler)
- gömülü fonksiyonlara yapılan çağrılar, örneğin ``add(1, mload(0))``
- değişken tanımlamaları, örneğin ``let x := 7``, ``let x := add(y, 3)`` veya ``let x`` (başlangıç değeri olarak 0 atanır)
- tanımlayıcılar (değişkenler), örneğin ``add(3, x)``
- atamalar, örneğin ``x := add(y, 3)``
- yerel değişkenlerin kapsam dahilinde olduğu bloklar, ör., örneğin ``{ let x := 3 { let y := add(x, 1) } }``
- if ifadeleri, örneğin ``if lt(a, b) { sstore(0, 1) }``
- switch ifadeleri, örneğin ``switch mload(0) case 0 { revert() } default { mstore(0, 1) }``
- for döngünleri, örneğin ``for { let i := 0} lt(i, 10) { i := add(i, 1) } { mstore(i, 7) }``
- fonksiyon tanımlamaları, örneğin ``function f(a, b) -> c { c := add(a, b) }``

Birden fazla sözdizimsel öğe, yalnızca boşlukla ayrılmış olarak birbirini 
takip edebilir, yani ``;`` ile sonlandırma yoktur veya yeni satıra geçilmelidir.

Değişmezler (Literal)
-----------------------

Değişmezler olarak şunları kullanabilirsiniz:

- Ondalık (decimal) veya onaltılık (hexadecimal) notasyonda tamsayı sabitleri..

- ASCII dizeleri (ör. ``"abc"``), ``\xNN`` onaltılı çıkışlarını ve ``N``'nin onaltılık basamaklar olduğu ``\uNNNN`` Unicode çıkışlarını içerebilir.

- Onaltılık string'ler (örneğin ``hex"616263"``).

Yul'un EVM diyalektinde, değişmezler aşağıdaki gibi 256 bitlik sözcükleri temsil eder.:

- Ondalık veya onaltılık sabitler ``2**256`` değerinden küçük olmalıdır.
  Soldan okumalı (big-endian) kodlamada bu değere sahip 256 bitlik kelimeyi işaretsiz bir tamsayı olarak temsil ederler.

- Bir ASCII string ifadesi ilk önce bir bayt dizisi olarak görüntülenir 
  ve bunu çıkartılmamış bir ASCII karakterini değeri 
  ASCII kodu olan tek bir bayt olarak, ``\xNN`` çıkışını bu değere sahip tek bayt olarak
  ve ``\uNNNN`` çıkışını o kod noktasındaki UTF-8 bayt dizisi olarak gerçekleştirir.
  Bayt dizisi 32 baytı geçmemelidir. 
  Bayt dizisi, 32 bayta ulaşmak için sağdaki sıfırlarla doldurulur; 
  başka bir deyişle, dize sola hizalı olarak saklanır. Sıfırlarla doldurulmuş bayt dizisi, 
  en önemli 8 biti ilk bayttakilerden oluşan 256 bitlik bir kelimeyi temsil eder, 
  yani baytlar soldan okumalı (big-endian) biçiminde yorumlanır.

- Bir onaltılık string, önce her bir bitişik onaltılık basamak çifti 
  bir bayt olarak görüntülenecek şekilde bir bayt dizisi olarak görüntülenir. 
  Bayt dizisi 32 baytı (yani 64 onaltılık basamak) geçmemelidir ve yukarıdaki gibi işlem görür.

EVM için derlenirken bu, uygun bir PUSHi komutuna dönüştürülecektir. 
Aşağıdaki örnekte, 3 ve 2 eklenerek 5 elde edilir 
ve ardından bitsel ``and`` ile “abc” string'i hesaplanır. 
Sonuç değeri, ``x`` adlı yerel bir değişkene atanır.

Yukarıdaki 32 baytlık sınır, değişmez (literal) bağımsız değişkenler gerektiren gömülü 
fonksiyonlara geçirilen string değişmezleri (string literal) için geçerli değildir 
(örneğin, ``setimmutable`` veya ``loadimmutable``). Bu dizeler asla oluşturulan bayt kodunda bitmez.

.. code-block:: yul

    let x := and("abc", add(3, 2))

Unless it is the default type, the type of a literal
has to be specified after a colon:
Varsayılan tür olmadığı sürece, bir değişmez (literal) türünün 
iki nokta üst üste (:) işaretinden sonra belirtilmesi gerekir:

.. code-block:: yul

    // Bu derlenmeyecek (u32 ve u256 türü henüz uygulanmadı)
    let x := and("abc":u32, add(3:u256, 2:u256))


Fonksiyon Çağrıları
--------------------

Hem gömülü hem de kullanıcı tanımlı fonksiyonlar (aşağıya bakın)
önceki örnekte gösterildiği gibi çağrılabilir.
Fonksiyon tek bir değer döndürürse, tekrar doğrudan bir ifadenin 
içinde kullanılabilir. Birden fazla değer döndürürse, 
yerel değişkenlere atanmaları gerekir.

.. code-block:: yul

    function f(x, y) -> a, b { /* ... */ }
    mstore(0x80, add(mload(0x80), 3))
    // Burada, kullanıcı tanımlı `f` fonksiyonu iki değer döndürür.
    let x, y := f(1, mload(0))

EVM'nin gömülü fonksiyonları için, fonksiyonel ifadeler 
doğrudan bir işlem kodu akışına çevrilebilir: 
İşlem kodlarını elde etmek için ifadeyi sağdan sola 
okumanız yeterlidir. Örnekteki ilk satır söz konusu olduğunda, 
bu ``PUSH1 3 PUSH1 0x80 MLOAD ADD PUSH1 0x80 MSTORE``'dur.

Kullanıcı tanımlı fonksiyonlara yapılan çağrılar için, 
bağımsız değişkenler de yığına sağdan sola doğru yerleştirilir 
ve bu, bağımsız değişken listelerinin değerlendirilme sırasıdır. 
Yine de, return edilen değerler yığında (stack) soldan sağa olması beklenir, 
yani bu örnekte, ``y`` yığının üstünde ve ``x`` onun altındadır.

Değişken Atamaları
---------------------

Değişkenleri atamak için ``let`` anahtar sözcüğünü kullanabilirsiniz. 
Bir değişken sadece tanımlandığı ``{...}``-blokunun içinde görünür. 
EVM'ye derlenirken, değişken için ayrılmış yeni bir yığın (stack) 
yuvası oluşturulur ve bloğun sonuna ulaşıldığında otomatik 
olarak tekrar kaldırılır. Değişken için bir başlangıç 
değeri atayabilirsiniz. Bir değer atamazsanız, 
değişken sıfıra eşitlenerek başlatılır.

Değişkenler yığında depolandığından, belleği veya hafızayı 
doğrudan etkilemezler, ancak gömülü fonksiyonlar olan ``mstore``, 
``mload``, ``sstore`` ve ``sload``'da belleğe veya hafıza 
konumlarına işaretçiler (pointer) olarak kullanılabilirler. Gelecekteki 
diyalektler, bu tür işaretçiler için belirlenmiş türler sağlayabilir.

Bir değişkene referans verildiğinde, mevcut değeri kopyalanır. 
EVM için bu, bir ``DUP`` talimatı anlamına gelir.

.. code-block:: yul

    {
        let zero := 0
        let v := calldataload(zero)
        {
            let y := add(sload(v), 1)
            v := y
        } // y burada "serbest bırakılmıştır"
        sstore(v, zero)
    } // v ve sıfır burada "serbest bırakılmıştır"


Atanan değişkenin varsayılan (default) türden farklı bir türde olması gerekiyorsa, 
iki nokta üst üste işareti ile bunu belirtirsiniz. Ayrıca, birden 
çok değer döndüren bir fonksiyon çağrısından atama yaptığınızda, 
tek bir ifadede birden çok değişken atayabilirsiniz.

.. code-block:: yul

    // Bu derlenmeyecek (u32 ve u256 türü henüz uygulanmadı)
    {
        let zero:u32 := 0:u32
        let v:u256, t:u32 := f()
        let x, y := g()
    }

Optimize edici ayarlarına bağlı olarak derleyici, 
değişken hala kod bloğu kapsamında olsa bile, son kez kullanıldıktan 
sonra yığın yuvalarını serbest bırakabilir.


Atamalar
-----------

Değişkenler, tanımlarından sonra ``:=`` operatörü kullanılarak 
atanabilir. Aynı anda birden fazla değişken atamak mümkündür. 
Bunun için değerlerin sayı ve türlerinin eşleşmesi gerekir. 
Birden çok return parametresi olan bir fonksiyondan döndürülen 
değerleri atamak istiyorsanız, birden çok değişken 
tanımlamanız gerekir. Aynı değişken, bir atamanın 
sol tarafında birden çok kez bulunamaz, 
örn. ``x, x := f()`` geçersizdir.

.. code-block:: yul

    let v := 0
    // v değişkenini tekrar atama
    v := 2
    let t := add(v, 2)
    function f() -> a, b { }
    // birden çok değer atama
    v, t := f()


If
---

if ifadesi, koşullu olarak kod çalıştırmak için kullanılabilir. 
“else” bloğu tanımlanamaz. Birden fazla alternatife ihtiyacınız varsa, 
bunun yerine "switch" kullanmayı düşünebilirsiniz (aşağıya göz atın).

.. code-block:: yul

    if lt(calldatasize(), 4) { revert(0, 0) }

Kod bloğu için süslü parantez gereklidir.

Switch
------

if ifadesinin genişletilmiş bir versiyonu olarak bir switch 
ifadesi kullanabilirsiniz. Switch, bir ifadenin değerini alır ve onu birkaç 
değişmez sabitle karşılaştırır. Eşleşen sabite karşılık gelen kısım değerlendirmeye alınır. 
Diğer programlama dillerinin aksine, güvenlik nedeniyle, kontrol akışı 
bir durumdan diğerine devam etmez. Değişmez sabitlerin hiçbiri eşleşmezse 
alınan ve ``default`` olarak adlandırılan bir varsayılan ifade veya bir alternatif durum olabilir.

.. code-block:: yul

    {
        let x := 0
        switch calldataload(4)
        case 0 {
            x := calldataload(0x24)
        }
        default {
            x := calldataload(0x44)
        }
        sstore(0, div(x, 2))
    }

Switch ifadesindeki case'ler süslü parantezle çevrelenmez, ancak case'lerin kod blokları
için süslü parantezle çevreleme zorunluluğu vardır.

Döngüler (Loop)
----------------

Yul, bir başlatma bölümü, bir koşul, 
bir iterasyon sonrası bölümü ve bir kod gövdesi içeren
döngüleri destekler. Koşul bölümü bir ifade 
olmalıdır, diğer üçü ise bloklar şeklindedir. Başlatma bölümünde herhangi 
bir değişken en üst düzeyde atanırsa, bu 
değişkenlerin kapsamı döngünün diğer tüm bölümlerine kadar genişler.

``break`` ve ``continue`` ifadeleri kod gövdesinde sırasıyla döngüden çıkmak 
veya iterasyon sonrası bölümüne atlamak için kullanılabilir.

Aşağıdaki örnek, bellekteki bir alanın toplamını hesaplar.

.. code-block:: yul

    {
        let x := 0
        for { let i := 0 } lt(i, 0x100) { i := add(i, 0x20) } {
            x := add(x, mload(i))
        }
    }

For döngüleri, while döngülerinin yerine de kullanılabilir: 
Başlatma ve iterasyon sonrası bölümlerini boş bırakmanız yeterlidir.

.. code-block:: yul

    {
        let x := 0
        let i := 0
        for { } lt(i, 0x100) { } {     // while(i < 0x100)
            x := add(x, mload(i))
            i := add(i, 0x20)
        }
    }

Fonksiyon Atamaları
---------------------

Yul, fonksiyonların tanımlanmasına izin verir. Bunlar, hiçbir zaman bir 
sözleşmenin harici arayüzünün parçası olmadıkları ve Solidity fonksiyonlarından ayrı 
bir ad alanının parçası oldukları için Solidity'deki fonksiyonlarla karıştırılmamalıdır.

EVM için, Yul fonksiyonları bağımsız değişkenlerini (ve bir return PC'sini) 
yığından alır ve ayrıca sonuçları yığına koyar. 
Kullanıcı tanımlı fonksiyonlar ve gömülü fonksiyonlar tam olarak aynı şekilde çağrılır.

Fonksiyonlar herhangi bir yerde tanımlanabilir ve tanımlandıkları 
blokta görülebilir olurlar. Bir fonksiyonun içinde, o fonksiyonun 
dışında tanımlanan yerel değişkenlere erişemezsiniz.

Fonksiyonlar, Solidity'ye benzer şekilde parametreleri atar ve değişkenleri döndürür. 
Bir değer döndürmek için, onu return değişken(ler)ine atarsınız.

Birden çok değer döndüren bir fonksiyonu çağırırsanız, bunları
 ``a, b := f(x)`` veya ``let a, b := f(x)`` kullanarak birden çok değişkene atamanız gerekir.

``leave`` ifadesi, geçerli fonksiyondan çıkmak için kullanılabilir. 
Diğer dillerdeki ``return`` ifadesi gibi çalışır, sadece döndürmek için 
bir değer almaz, sadece fonksiyonlardan çıkar ve fonksiyon, dönüş (return) 
değişkenlerine o anda atanmış olan değerleri döndürür.

EVM diyalektinin, yalnızca geçerli yul fonksiyonundan değil, 
tam çalıştırma bağlamından (dahili mesaj çağrısı) çıkan 
``return`` adlı gömülü bir fonksiyonu olduğunu unutmayın.

Aşağıdaki örnek, power adlı fonksiyonun kare-ve-çarpma yöntemiyle bir uygulamasıdır.

.. code-block:: yul

    {
        function power(base, exponent) -> result {
            switch exponent
            case 0 { result := 1 }
            case 1 { result := base }
            default {
                result := power(mul(base, base), div(exponent, 2))
                switch mod(exponent, 2)
                    case 1 { result := mul(base, result) }
            }
        }
    }

Yul Tanımlaması
====================

Bu bölüm Yul kodunu resmi olarak açıklar. Yul kodu genellikle 
kendi bölümlerinde açıklandığı üzere Yul nesnelerinin içine yerleştirilir.

.. code-block:: none

    Block = '{' Statement* '}'
    Statement =
        Block |
        FunctionDefinition |
        VariableDeclaration |
        Assignment |
        If |
        Expression |
        Switch |
        ForLoop |
        BreakContinue |
        Leave
    FunctionDefinition =
        'function' Identifier '(' TypedIdentifierList? ')'
        ( '->' TypedIdentifierList )? Block
    VariableDeclaration =
        'let' TypedIdentifierList ( ':=' Expression )?
    Assignment =
        IdentifierList ':=' Expression
    Expression =
        FunctionCall | Identifier | Literal
    If =
        'if' Expression Block
    Switch =
        'switch' Expression ( Case+ Default? | Default )
    Case =
        'case' Literal Block
    Default =
        'default' Block
    ForLoop =
        'for' Block Expression Block Block
    BreakContinue =
        'break' | 'continue'
    Leave = 'leave'
    FunctionCall =
        Identifier '(' ( Expression ( ',' Expression )* )? ')'
    Identifier = [a-zA-Z_$] [a-zA-Z_$0-9.]*
    IdentifierList = Identifier ( ',' Identifier)*
    TypeName = Identifier
    TypedIdentifierList = Identifier ( ':' TypeName )? ( ',' Identifier ( ':' TypeName )? )*
    Literal =
        (NumberLiteral | StringLiteral | TrueLiteral | FalseLiteral) ( ':' TypeName )?
    NumberLiteral = HexNumber | DecimalNumber
    StringLiteral = '"' ([^"\r\n\\] | '\\' .)* '"'
    TrueLiteral = 'true'
    FalseLiteral = 'false'
    HexNumber = '0x' [0-9a-fA-F]+
    DecimalNumber = [0-9]+


Dilbilgisi ile İlgili Kısıtlamalar
------------------------------------

Doğrudan dilbilgisi tarafından dayatılanların dışında, 
aşağıdaki kısıtlamalar geçerlidir:

Switc ifadelerinin en az bir case'i (durumu) olmalıdır (default case dahil). 
Tüm case değerlerinin aynı türe ve farklı değerlere sahip olması gerekir. 
İfade türünün tüm olası değerleri kapsam dahilindeyse, default bir case 
ifadesine izin verilmez (yani, hem doğru hem de yanlış bir duruma sahip 
bir ``bool`` ifadesine sahip bir switch, default bir case'e izin vermez).

Her ifade sıfır veya daha fazla değer olarak ele alınır. 
Tanımlayıcılar (identifier) ve Değişmez Değerler (literal) tam 
bir değer olarak ele alınır ve fonksiyon çağrıları, 
çağrılan fonksiyonun return değişkenlerinin sayısına eşit sayıda değer olarak ele alınır.

Değişken bildirimlerinde ve atamalarında, 
eğer varsa sağ taraftaki ifadenin, 
sol taraftaki değişkenlerin sayısına eşit sayıda değer alması gerekir. 
Bu, birden fazla değeri ele alan bir ifadeye 
izin verilen tek durumdur. Aynı değişken 
adı, bir atamanın veya değişken bildiriminin 
sol tarafında birden fazla olamaz.

Aynı zamanda komut olan ifadeler (yani blok seviyesinde) 
0 değeri olarak değerlendirilmelidir.

Diğer tüm durumlarda, ifadeler tam olarak tek bir değere göre ele alınmalıdır.

``continue`` veya ``break`` ifadesi yalnızca aşağıdaki gibi bir for-loop gövdesi içinde kullanılabilir. 
İfadeyi içeren en içteki loop döngüsünü düşünün. 
Döngü ve ifade aynı fonksiyonda olmalı veya her ikisi de en üst seviyede olmalıdır. 
İfade, loop döngüsünün gövde bloğunda olmalıdır; 
döngünün başlatma bloğunda veya güncelleme bloğunda olamaz. 
Bu kısıtlamanın yalnızca ``continue`` veya ``break`` deyimini içeren en 
içteki döngü için geçerli olduğunu vurgulamakta fayda var: 
bu en içteki döngü (loop) ve dolayısıyla ``continue`` veya ``break`` ifadesi, 
bir dış döngünün herhangi bir yerinde, muhtemelen bir dış döngünün başlatma bloğunda 
veya güncelleme bloğunda görünebilir. Örneğin, aşağıdakiler yasaldır, çünkü ``break``, 
dış döngünün güncelleme bloğunda da meydana gelmesine rağmen, 
iç döngünün gövde bloğunda meydana gelir:

.. code-block:: yul

    for {} true { for {} true {} { break } }
    {
    }

For döngüsünün koşul kısmı tam olarak bir değere göre değerlendirilmelidir.

``leave`` ifadesi yalnızca bir fonksiyon içinde kullanılabilir.

Fonksiyonlar, döngü başlatma blokları söz konusu olduğunda herhangi bir yerde tanımlanamaz.

Değişmezler kendi türlerinden daha büyük olamaz. Tanımlanan en büyük tür 256 bit genişliğindedir.

Atamalar ve fonksiyon çağrıları sırasında ilgili değerlerin türlerinin eşleşmesi gerekir. 
Örtülü (implicit) tür dönüşümü yoktur. Genel olarak tür dönüştürme, yalnızca diyalekt 
bir türün değerini alan ve farklı bir türün değerini döndüren 
uygun bir gömülü fonksiyon sağladığında gerçekleştirilebilir.

Kapsam Belirleme Kuralları
----------------------------

Yul'daki kapsamlar (scope) Bloklara bağlıdır (fonksiyonlar ve aşağıda açıklandığı 
gibi for döngüsü hariç) ve tüm bildirimler 
(``FunctionDefinition``, ``VariableDeclaration``) 
bu kapsamlara yeni tanımlayıcılar (identifier) getirir.

Tanımlayıcılar, tanımlandıkları blokta görünürler 
(tüm alt düğümler ve alt bloklar dahil): fonksiyonlar tüm blokta 
(hatta tanımlandıkları yerden önce bile) görünürken, değişkenler 
yalnızca ``VariableDeclaration``'dan sonraki ifadeden başlayarak görünür.

Özellikle, değişkenlere kendi değişken 
atamalarının sağ tarafında referans verilemez. 
Fonksiyonlara, atamalarından önce 
referans verilebilir (eğer görünürlerse).


Genel kapsam belirleme kuralının bir istisnası olarak, 
for döngüsünün  "init" bölümünün (ilk blok) kapsamı, for döngüsünün diğer tüm bölümlerini içine alır. 
Bu, init bölümünde bildirilen (ancak init parçasının içindeki bir bloğun içerisinde değil) 
değişkenlerin ve fonksiyonların for döngüsünün diğer tüm bölümlerinde görünür olduğu anlamına gelir.

For döngüsünün diğer bölümlerinde bildirilen tanımlayıcılar, normal 
sözdizimsel kapsam belirleme kurallarına uyar.

Bu demektir ki ``for { I... } C { P... } { B... }`` şeklindeki bir for döngüsü
 ``{ I... for {} C { P... } { B... } }`` ifadesine eşittir.

Fonksiyonların parametreleri ve return parametreleri fonksiyon 
gövdesinde görünür ve isimleri farklı olmalıdır.

Fonksiyonların içinde, o fonksiyonun dışında bildirilen 
bir değişkene referans vermek mümkün değildir.

Gölgelemeye (shadowing) izin verilmez, yani aynı ada sahip başka bir tanımlayıcının da 
görünür olduğu bir noktada, geçerli işlevin dışında bildirildiği için 
ona başvurmak mümkün olmasa bile bir tanımlayıcı (identifier) atayamazsınız.

Resmi Şartname
--------------------

AST'nin çeşitli düğümlerinde(node) aşırı yüklenmiş bir E değerlendirme fonksiyonu 
sağlayarak resmi olarak Yul'u tanımlarız. Gömülü fonksiyonların yan etkileri olabileceğinden, 
E iki durum nesnesini (state object) ve AST düğümünü alır ve iki yeni durum 
nesnesi ve değişken sayıda başka değer döndürür. 
Bu iki durum nesnesinden birisi global durum nesnesi 
(EVM bağlamında blok zincirinin belleği, depolanması ve durumudur) 
ve diğeri de yerel durum nesnesidir 
(yerel değişkenlerin durumu, yani EVM'deki yığının bir bölümü).

AST düğümü bir ifadeyse, E iki durum nesnesini ve ``break``, ``continue`` ve ``leave`` 
komutları için kullanılan bir "mod"u döndürür. 
AST düğümü bir ifadeyse, E, iki durum nesnesini 
ve ifadenin değerlendirdiği sayıda değeri döndürür.


Bu üst düzey açıklama için global durumun (state) kesin hatları belirtilmemiştir. 
L yerel durumu , ``i`` tanımlayıcılarının ``L[i] = v`` olarak 
gösterilen ``v`` değerlerine eşlenmesidir.

Bir ``v`` tanımlayıcısı (identifier) için, tanımlayıcının adı ``$v`` olsun.

AST düğümleri (node) için bir destructuring notasyonu kullanacağız.

.. code-block:: none

    E(G, L, <{St1, ..., Stn}>: Block) =
        let G1, L1, mode = E(G, L, St1, ..., Stn)
        L2, L1'in L tanımlayıcılarına bir kısıtlaması olsun
        G1, L2, mode
    E(G, L, St1, ..., Stn: Statement) =
        if n is zero:
            G, L, regular
        else:
            let G1, L1, mode = E(G, L, St1)
            eğer mode regular ise
                E(G1, L1, St2, ..., Stn)
            değilse
                G1, L1, mode
    E(G, L, FunctionDefinition) =
        G, L, regular
    E(G, L, <let var_1, ..., var_n := rhs>: VariableDeclaration) =
        E(G, L, <var_1, ..., var_n := rhs>: Assignment)
    E(G, L, <let var_1, ..., var_n>: VariableDeclaration) =
        L1 in L nin kopyası olduğu durumda L1[$var_i] = 0 for i = 1, ..., n
        G, L1, regular
    E(G, L, <var_1, ..., var_n := rhs>: Assignment) =
        let G1, L1, v1, ..., vn = E(G, L, rhs)
        L2 nin L1 in kopyası olduğu durumda L2[$var_i] = vi for i = 1, ..., n
        G1, L2, regular
    E(G, L, <for { i1, ..., in } condition post body>: ForLoop) =
        if n >= 1:
            let G1, L1, mode = E(G, L, i1, ..., in)
            // mode regular olmalı veya sözdizimsel kısıtlamalar nedeniyle terk edilmelidir
            eğer mode leave ise o zaman
                G1, L1 değişkenleri L, leave değişkenlerine kısıtlıdır
            değilse
                let G2, L2, mode = E(G1, L1, for {} condition post body)
                G2, L2 değişkenleri L, mode değişkenlerine kısıtlıdır
        else:
            let G1, L1, v = E(G, L, condition)
            if v is false:
                G1, L1, regular
            else:
                let G2, L2, mode = E(G1, L, body)
                if mode is break:
                    G2, L2, regular
                otherwise if mode is leave:
                    G2, L2, leave
                else:
                    G3, L3, mode = E(G2, L2, post)
                    if mode is leave:
                        G3, L3, leave
                    otherwise
                        E(G3, L3, for {} condition post body)
    E(G, L, break: BreakContinue) =
        G, L, break
    E(G, L, continue: BreakContinue) =
        G, L, continue
    E(G, L, leave: Leave) =
        G, L, leave
    E(G, L, <if condition body>: If) =
        let G0, L0, v = E(G, L, condition)
        if v is true:
            E(G0, L0, body)
        else:
            G0, L0, regular
    E(G, L, <switch condition case l1:t1 st1 ... case ln:tn stn>: Switch) =
        E(G, L, switch condition case l1:t1 st1 ... case ln:tn stn default {})
    E(G, L, <switch condition case l1:t1 st1 ... case ln:tn stn default st'>: Switch) =
        let G0, L0, v = E(G, L, condition)
        // i = 1 .. n
        // Değişmezleri (literal) değerlendirin, bağlam önemli değil
        let _, _, v1 = E(G0, L0, l1)
        ...
        let _, _, vn = E(G0, L0, ln)
        vi = v olacak şekilde en küçük i varsa:
            E(G0, L0, sti)
        else:
            E(G0, L0, st')

    E(G, L, <name>: Identifier) =
        G, L, L[$name]
    E(G, L, <fname(arg1, ..., argn)>: FunctionCall) =
        G1, L1, vn = E(G, L, argn)
        ...
        G(n-1), L(n-1), v2 = E(G(n-2), L(n-2), arg2)
        Gn, Ln, v1 = E(G(n-1), L(n-1), arg1)
        Let <function fname (param1, ..., paramn) -> ret1, ..., retm block>
        be the function of name $fname visible at the point of the call.
        Let L' be a new local state such that
        L'[$parami] = vi and L'[$reti] = 0 for all i.
        Let G'', L'', mode = E(Gn, L', block)
        G'', Ln, L''[$ret1], ..., L''[$retm]
    E(G, L, l: StringLiteral) = G, L, str(l),
        burada str, EVM diyalekti için yukarıdaki 'Değişmezler' bölümünde 
        tanımlanan string değerlendirme fonksiyonudur.
    E(G, L, n: HexNumber) = G, L, hex(n)
        burada hex, bir onaltılık (hexadecimal) basamak dizisini soldan okumalı (big endian) 
        değerine dönüştüren onaltılık değerlendirme fonksiyonudur.
    E(G, L, n: DecimalNumber) = G, L, dec(n),
        where dec is the decimal evaluation function,
        which turns a sequence of decimal digits into their big endian value
        burada dec, ondalık (decimal) basamak dizisini soldan okumalı (büyük endian) değerine 
        dönüştüren ondalık değerlendirme fonksiyonudur.

.. _opcodes:

EVM Dialect
-----------

Yul'un varsayılan lehçesi şu anda EVM'nin mevcut sürümü için olan EVM lehçesidir.
 EVM'nin bir sürümü ile birlikte. Bu lehçede kullanılabilen tek tür, 
 Ethereum Sanal Makinesinin 256 bit yerel türü olan ``u256``'dır. 
 Bu tür, lehçenin varsayılan türü olduğu için görmezden gelinebilir.

Aşağıdaki tablo tüm gömülü fonksiyonları (EVM sürümüne bağlı olarak) 
listeler ve fonksiyonun / işlem kodunun semantiğinin kısa bir 
açıklamasını sunar. Bu belge, Ethereum sanal makinesinin tam bir açıklaması 
olmak istemediği için kesin semantikleriyle ilgileniyorsanız, 
lütfen farklı bir belgeye bakınız.

``-`` ile işaretlenen işlem kodları bir sonuç döndürmez ve diğerleri tam olarak bir değer döndürür. 
``F``, ``H``, ``B``, ``C``, ``I`` ve ``L`` ile işaretlenen işlem kodları sırasıyla Frontier, Homestead, 
Byzantium, Constantinople, Istanbul veya London'dan beri mevcuttur.

Aşağıda, ``mem[a...b)``, ``a`` konumundan başlayan ancak ``b`` konumuna kadar 
olmayan bellek baytlarını belirtir ve ``storage[p]``, ``p`` yuvasındaki depolama içeriğini belirtir.

Yul, yerel değişkenleri ve kontrol akışını yönettiğinden, 
bu özelliklere müdahale eden işlem kodları mevcut değildir. Bu, ``dup`` ve ``swap`` talimatlarının 
yanı sıra ``jump`` talimatlarını, etiketleri ve ``push`` talimatlarını içerir.

+-------------------------+-----+---+-----------------------------------------------------------------+
| Komut                   |     |   | Açıklama                                                        |
+=========================+=====+===+=================================================================+
| stop()                  | `-` | F | çalışmayı durdurur, return(0, 0) ile eşdeğerdir                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| add(x, y)               |     | F | x + y                                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sub(x, y)               |     | F | x - y                                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mul(x, y)               |     | F | x * y                                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| div(x, y)               |     | F | x / y veya 0 eğer y == 0 ise                                    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sdiv(x, y)              |     | F | x / y, ikinin tümleyenindeki işaretli sayılar için,             |
|                         |     |   | y == 0 ise 0                                                    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mod(x, y)               |     | F | x % y, y == 0 ise 0                                             |
+-------------------------+-----+---+-----------------------------------------------------------------+
| smod(x, y)              |     | F | x % y, ikinin tümleyenindeki işaretli sayılar için,             |
|                         |     |   | y == 0 ise 0                                                    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| exp(x, y)               |     | F | x in y ninci kuvveti                                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| not(x)                  |     | F | x'in bit düzeyinde "değil"i (x'in her biti reddedilir)          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| lt(x, y)                |     | F | x < y ise 1, değilse 0                                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gt(x, y)                |     | F | x > y ise 1, 0 değilse 0                                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| slt(x, y)               |     | F | x < y ise 1, değilse 0, ikinin tümleyenindeki                   |
|                         |     |   | işaretli sayılar için                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sgt(x, y)               |     | F | x > y ise 1, değilse 0, ikinin tümleyenindeki                   |
|                         |     |   | işaretli sayılar için                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| eq(x, y)                |     | F | x == y ise 1, değilse 0                                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| iszero(x)               |     | F | x == 0 ise 1, değilse 0                                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| and(x, y)               |     | F | x ve y için bit düzeyinde "and"                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| or(x, y)                |     | F | x ve y için bit düzeyinde "or"                                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| xor(x, y)               |     | F | x ve y için bit düzeyinde "xor"                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| byte(n, x)              |     | F | x'in n. baytı, burada en önemli bayt 0. bayttır                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| shl(x, y)               |     | C | y ile x bit sola mantıksal kaydırma                             |
+-------------------------+-----+---+-----------------------------------------------------------------+
| shr(x, y)               |     | C | y ile x bit sağa mantıksal kaydırma                             |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sar(x, y)               |     | C | işaretli aritmetik kaydırma sağa y ile x bit                    |
+-------------------------+-----+---+-----------------------------------------------------------------+
| addmod(x, y, m)         |     | F | (x + y) % m keyfi kesinlikli aritmetik ile, m == 0 ise 0        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mulmod(x, y, m)         |     | F | (x * y) % m keyfi kesinlikli aritmetik ile, m == 0 ise 0        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| signextend(i, x)        |     | F | işaret, en önemsizden başlayarak (i*8+7). bitten                |
|                         |     |   | başlayarak genişler                                             |
+-------------------------+-----+---+-----------------------------------------------------------------+
| keccak256(p, n)         |     | F | keccak(mem[p...(p+n)))                                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| pc()                    |     | F | koddaki geçerli konum                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| pop(x)                  | `-` | F | x değerini at                                                   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mload(p)                |     | F | mem[p...(p+32))                                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mstore(p, v)            | `-` | F | mem[p...(p+32)) := v                                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| mstore8(p, v)           | `-` | F | mem[p] := v & 0xff (yalnızca tek bir baytı değiştirir)          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sload(p)                |     | F | storage[p]                                                      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| sstore(p, v)            | `-` | F | storage[p] := v                                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| msize()                 |     | F | bellek boyutu, yani erişilen en büyük bellek indeksi            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gas()                   |     | F | gaz hala uygulama için kullanılabilir                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| address()               |     | F | mevcut sözleşmenin / uygulama bağlamının adresi                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| balance(a)              |     | F | a adresindeki wei bakiyesi                                      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| selfbalance()           |     | I | balance(address()) ile eşdeğer, ancak daha ucuz                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| caller()                |     | F | sender'ı çağırır (``delegatecall``'u' hariç tutarak)            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| callvalue()             |     | F | mevcut çağrı ile birlikte gönderilen wei                        |
+-------------------------+-----+---+-----------------------------------------------------------------+
| calldataload(p)         |     | F | p konumundan başlayan çağrı verileri (32 bayt)                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| calldatasize()          |     | F | bayt cinsinden çağrı verilerinin boyutu                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| calldatacopy(t, f, s)   | `-` | F | f konumundaki çağrı verilerinden t konumundaki                  |
|                         |     |   | mem'e s bayt kopyalayın                                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| codesize()              |     | F | mevcut sözleşme / uygulama bağlamının kodunun boyutu            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| codecopy(t, f, s)       | `-` | F | s baytını f konumundaki koddan t konumundaki mem'e kopyalayın   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| extcodesize(a)          |     | F | a adresindeki kodun boyutu                                      |
+-------------------------+-----+---+-----------------------------------------------------------------+
| extcodecopy(a, t, f, s) | `-` | F | codecopy(t, f, s) gibi ama a adresindeki kodu alır              |
+-------------------------+-----+---+-----------------------------------------------------------------+
| returndatasize()        |     | B | son returndata'nın boyutu                                       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| returndatacopy(t, f, s) | `-` | B | f konumundaki returndata'dan t konumundaki mem'e                |
|                         |     |   | s bayt kopyalayın                                               |
+-------------------------+-----+---+-----------------------------------------------------------------+
| extcodehash(a)          |     | C | a adresinin hash kodu                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| create(v, p, n)         |     | F | mem[p...(p+n)) koduyla yeni sözleşme oluştur ve v wei gönder    |
|                         |     |   | ve yeni adresi return et; hata durumunda 0 döndürür             |
+-------------------------+-----+---+-----------------------------------------------------------------+
| create2(v, p, n, s)     |     | C | keccak256(0xff . this .s .keccak256(mem[p…(p+n))) adresinde     |
|                         |     |   | mem[p…(p+n)) koduyla yeni sözleşme oluşturun ve v wei gönderin  |
|                         |     |   | ve yeni adresi döndürün, burada 0xff 1 baytlık bir değerdir,    |
|                         |     |   | bu 20 baytlık bir değer olarak mevcut sözleşmenin adresidir ve  |
|                         |     |   | s, soldan okumalı (big-endian) 256 bitlik bir değerdir;         |
|                         |     |   | hata durumunda 0 döndürür                                       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| call(g, a, v, in,       |     | F | a adresindeki mem[in…(in+insize) girişli                        |
| insize, out, outsize)   |     |   | çağrı sözleşmesi, g gaz, v wei ve                               |
|                         |     |   | mem[out...(out+outsize)) ise çıkış alanı                        |
|                         |     |   | hata durumunda 0 döndürür (örn. gazın bitmesi) başarı durumunda |
|                         |     |   | ise 1 döndürür :ref:`Daha fazla bilgi <yul-call-return-area>`   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| callcode(g, a, v, in,   |     | F | ``call`` ile aynıdır, ancak yalnızca a kodunu kullanın          |
| insize, out, outsize)   |     |   | ve aksi takdirde mevcut sözleşme bağlamında kalın               |
|                         |     |   | :ref:`Daha fazla bilgi <yul-call-return-area>`                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| delegatecall(g, a, in,  |     | H | ``callcode`` ile eşdeğerdir ama aynı zamanda ``caller``         |
| insize, out, outsize)   |     |   | ve ``callvalue`` değerini de tutar                              |
|                         |     |   | :ref:`Daha fazla bilgi <yul-call-return-area>`                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| staticcall(g, a, in,    |     | B | ``call(g, a, 0, in, insize, out, outsize)`` ile eşdeğerdir      |
| insize, out, outsize)   |     |   | ama durum değişikliklerine izin vermez                          |
|                         |     |   | :ref:`Daha fazla bilgi <yul-call-return-area>`                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| return(p, s)            | `-` | F | yürütmeyi sonlandırır, veriyi dönderir mem[p...(p+s))           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| revert(p, s)            | `-` | B | yürütmeyi sonlandırır, durum değişikliklerini geri alır         |
|                         |     |   | mem[p...(p+s) verisini dönderir                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| selfdestruct(a)         | `-` | F | yürütmeyi sonlandırır, mevcut sözleşmeyi yok eder               |
|                         |     |   | ve parayı a'ya gönderir                                         |
+-------------------------+-----+---+-----------------------------------------------------------------+
| invalid()               | `-` | F | geçersiz talimatla yürütmeyi sonlandır                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log0(p, s)              | `-` | F | topic ve mem[p...(p+s)) datası olmadan log aç                   |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log1(p, s, t1)          | `-` | F | t1 ve mem[p...(p+s)) datası ile log aç                          |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log2(p, s, t1, t2)      | `-` | F | t1, t2 topic'leri ve mem[p...(p+s)) datası ile log aç           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log3(p, s, t1, t2, t3)  | `-` | F | t1, t2, t3 topic'leri ve mem[p...(p+s)) datası ile log aç       |
+-------------------------+-----+---+-----------------------------------------------------------------+
| log4(p, s, t1, t2, t3,  | `-` | F | topics t1, t2, t3, t4 topic'leri ve mem[p...(p+s))              |
| t4)                     |     |   | datası ile log aç                                               |
+-------------------------+-----+---+-----------------------------------------------------------------+
| chainid()               |     | I | Yürütme zincirinin kimliği (EIP-1344)                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| basefee()               |     | L | mevcut bloğun taban ücreti (EIP-3198 ve EIP-1559)               |
+-------------------------+-----+---+-----------------------------------------------------------------+
| origin()                |     | F | işlem gönderen                                                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gasprice()              |     | F | işlemin gaz fiyatı                                              |
+-------------------------+-----+---+-----------------------------------------------------------------+
| blockhash(b)            |     | F | b nolu bloğun hash değeri - mevcut hariç yalnızca               |
|                         |     |   | son 256 blok için                                               |
+-------------------------+-----+---+-----------------------------------------------------------------+
| coinbase()              |     | F | mevcut madencilik faydalanıcısı                                 |
+-------------------------+-----+---+-----------------------------------------------------------------+
| timestamp()             |     | F | çağlardan bu yana geçerli bloğun saniye cinsindenzaman damgası  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| number()                |     | F | mevcut blok numarası                                            |
+-------------------------+-----+---+-----------------------------------------------------------------+
| difficulty()            |     | F | mevcut bloğun zorluğu                                           |
+-------------------------+-----+---+-----------------------------------------------------------------+
| gaslimit()              |     | F | mevcut bloğun gaz limitini engelle                              |
+-------------------------+-----+---+-----------------------------------------------------------------+

.. _yul-call-return-area:

.. note::
  ``call*`` komutları, return veya hata verilerinin yerleştirildiği bellekte bir alanı 
  tanımlamak için ``out`` ve ``outsize`` parametrelerini kullanır. Bu alan, çağrılan sözleşmenin 
  kaç bayt döndüğüne bağlı olarak yazılır. Daha fazla veri döndürürse, yalnızca ilk ``outsize`` baytlar yazılır. 
  Geri kalan verilere ``returndatacopy`` işlem kodunu kullanarak erişebilirsiniz. Daha az veri döndürürse, kalan 
  baytlara hiç dokunulmaz. Bu bellek alanının hangi bölümünün geri dönüş verilerini içerdiğini kontrol etmek için 
  ``returndatasize`` işlem kodunu kullanmanız gerekir. Kalan baytlar, çağrıdan önceki değerlerini koruyacaktır.


Bazı dahili diyalektlerde ek fonksiyonlar vardır:

datasize, dataoffset, datacopy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``datasize(x)``, ``dataoffset(x)`` ve ``datacopy(t, f, l)`` fonksiyonları bir 
Yul nesnesinin diğer bölümlerine erişmek için kullanılır.

``datasize`` ve ``dataoffset`` argüman olarak yalnızca string değişmezlerini (diğer nesnelerin adlarını)
 alabilir ve sırasıyla veri alanındaki boyutu ve ofseti döndürebilir. 
 EVM için ``datacopy`` fonksiyonu ``codecopy`` fonksiyonu ile eşdeğerdir.


setimmutable, loadimmutable
^^^^^^^^^^^^^^^^^^^^^^^^^^^

``setimmutable(offset, "name", value)`` ve ``loadimmutable("name")`` fonksiyonları, 
Solidity'deki değişmez mekanizma için kullanılır ve saf Yul ile hoş bir şekilde eşleşmez. 
``setimmutable(offset, "name", value)`` çağrısı, verilen adlandırılmış değişmezi içeren sözleşmenin 
çalışma zamanı (runtime) kodunun ofsette ``offset`` belleğe kopyalandığını ve yer tutucuyu (placeholder) içeren 
bellekteki tüm konumlara (``offset``'e göre) ``value`` yazacağını varsayar. 
Bu, çalışma zamanı kodunda ``loadimmutable("name")`` çağrıları için oluşturulmuştur.


linkersymbol
^^^^^^^^^^^^

``linkersymbol("library_id")`` fonksiyonu, bağlayıcı (linker) tarafından değiştirilecek bir 
adres değişmezi (literal) için bir yer tutucudur (placeholder). 
İlk ve tek bağımsız değişkeni bir string değişmezi olmalıdır ve eklenecek adresi benzersiz şekilde temsil eder. 
Tanımlayıcılar (identifier) isteğe bağlı olabilir, ancak derleyici Solidity kaynaklarından Yul kodu ürettiğinde, 
o kitaplığı tanımlayan kaynak birimin adıyla nitelenmiş bir kitaplık adı kullanır. 
Kodu belirli bir kitaplık adresiyle ilişkilendirmek için, komut satırındaki
``--libraries`` seçeneğine aynı tanımlayıcı verilmelidir.

Örneğin aşağıdaki kod

.. code-block:: yul

    let a := linkersymbol("file.sol:Math")

bağlayıcı (linker) ``--libraries "file.sol:Math=0x1234567890123456789012345678901234567890`` 
seçeneği ile çağrıldığında şu koda eşittir:

.. code-block:: yul

    let a := 0x1234567890123456789012345678901234567890

Solidity bağlayıcı (linker) hakkında ayrıntılar için :ref:`Komut Satırı Derleyicisini Kullanma <commandline-compiler>` bölümüne bakın.

memoryguard
^^^^^^^^^^^

Bu fonksiyon, nesnelerle birlikte EVM lehçesinde mevcuttur. 
``let ptr := memoryguard(size)`` (``size``'ın' değişmez bir sayı olması gerektiği yerde) 
çağıranı, yalnızca ``[0, size)`` aralığında veya ``ptr``'dan 
başlayan sınırsız aralıkta bellek kullandıklarında garanti verir.

Bir ``memoryguard`` çağrısının varlığı, tüm bellek erişiminin 
bu kısıtlamaya bağlı olduğunu gösterdiğinden, optimize edicinin 
ek optimizasyon adımları gerçekleştirmesine izin verir, örneğin, aksi takdirde 
belleğe erişilemeyecek olan yığın (stack) değişkenlerini taşımaya çalışan yığın limiti kaçağı gibi.

Yul optimizer, amaçları için yalnızca bellek aralığını ``[size, ptr)`` kullanmayı vaat eder. 
Optimize edicinin herhangi bir bellek ayırması gerekmiyorsa, ``ptr == size`` boyutunu tutar.

``memoryguard`` birden çok kez çağrılabilir, ancak bir Yul alt nesnesinde bağımsız değişkenle 
aynı değişmeze sahip olması gerekir. Bir alt nesnede en az bir ``memoryguard`` çağrısı bulunursa, 
bunun üzerinde ek optimize edici adımlar çalıştırılır.


.. _yul-verbatim:

verbatim
^^^^^^^^

``verbatim...`` gömülü fonksiyonlar kümesi, Yul derleyicisi tarafından bilinmeyen işlem kodları 
için bayt kodu oluşturmanıza olanak tanır. Ayrıca, optimize edici tarafından 
değiştirilmeyecek olan bayt kodu dizileri oluşturmanıza da olanak tanır.

Fonksiyonlar şu şekildedir: ``verbatim_<n>i_<m>o("<data>", ...)``, burada

- ``n`` giriş (input) yığını yuvalarının/değişkenlerinin sayısını belirten 0 ile 99 arasında bir ondalık sayıdır
- çıktı (output) yığını yuvalarının / değişkenlerinin sayısını belirten 0 ile 99 arasında bir ondalık sayıdır
- ``data`` bayt dizisini içeren bir string değişmezidir

Örneğin, optimize edicinin sabit değer olan ikiye dokunmadan girişi 
iki ile çarpan bir fonksiyon tanımlamak istiyorsanız, şöyle kullanabilirsiniz:

.. code-block:: yul

    let x := calldataload(0)
    let double := verbatim_1i_1o(hex"600202", x)

Bu kod, ``x``'i doğrudan almak amacıyla 
(yine de optimize edici, ``calldataload`` işlem kodunun sonucunu 
doğrudan yeniden kullanabilir) bir ``dup1`` işlem kodunun 
ardından ``600202`` ile sonuçlanır. Kodun, kopyalanan ``x`` değerini tükettiği 
ve sonucu yığının en üstünde ürettiği varsayılır. 
Derleyici daha sonra ``double`` için bir yığın yuvası 
tahsis etmek ve sonucu orada saklamak için kod üretir.

Tüm işlem kodlarında olduğu gibi, değişmez değerler en soldaki değişmez değer 
en üstte olacak şekilde yığın üzerinde düzenlenirken, 
return değerleri ise en sağdaki değişken, yığının 
en üstünde olacak şekilde düzenlendiği varsayılır.

``verbatim`` isteğe bağlı işlem kodları ve hatta Solidity derleyicisi 
tarafından bilinmeyen işlem kodları oluşturmak için kullanılabildiğinden, 
optimize edici ile birlikte ``verbatim`` kullanılırken dikkatli olunmalıdır. 
Optimize edici kapatıldığında bile, kod oluşturucu yığın düzenini 
belirlemelidir, bu da örneğin yığın yüksekliğini değiştirmek 
için ``verbatim`` kullanmak istediğinizde tanımsız davranışa yol açabilir.

Aşağıda, derleyici tarafından kontrol edilmeyen verbatim 
bayt kodundaki kısıtlamaların kapsamlı olmayan 
bir listesi bulunmaktadır. Bu kısıtlamaların ihlali, 
tanımlanmamış davranışlara neden olabilir.

- Kontrol akışı verbatim bloklarının içine veya dışına atlamamalıdır, 
  ancak aynı verbatim bloğu içinde atlayabilir.
- Giriş ve çıkış parametreleri dışındaki yığın 
  içeriklerine erişilmemelidir.
- Yığın yükseklik farkı tam olarak ``m - n`` olmalıdır 
  (çıkış yuvaları eksi giriş yuvaları).
- Verbatim bayt kodu, kapsayan bayt kodu hakkında herhangi 
  bir varsayımda bulunamaz. Gerekli tüm parametreler 
  yığın değişkenleri olarak iletilmelidir.

Optimize edici "verbatim" bayt kodunu analiz etmez ve her zaman 
durumun tüm yönlerini değiştirdiğini ve bu nedenle ``verbatim`` 
fonksiyon çağrılarında yalnızca çok az optimizasyon yapabileceğini varsayar.

Optimize edici, verbatim bayt kodunu opak bir kod bloğu olarak ele alır. 
Bölmez, ancak aynı verbatim bayt kodu bloklarıyla taşıyabilir, 
çoğaltabilir veya birleştirebilir. 
Bir "verbatim" bayt kodu bloğuna kontrol akışı 
tarafından ulaşılamıyorsa, kaldırılabilir.


.. warning::

    EVM iyileştirmelerinin mevcut akıllı sözleşmeleri bozup bozmayacağı 
    konusundaki tartışmalar sırasında, ``verbatim`` içindeki özellikler, 
    Solidity derleyicisinin kullandığı özelliklerle 
    aynı değerlendirmeyi alamaz.

.. note::

    Karışıklığı önlemek için, "verbatim" string'i başlayan tüm tanımlayıcılar reserv edilmiştir ve 
    kullanıcıların atadığı tanımlayıcılar için kullanılamaz.

.. _yul-object:

Specification of Yul Object
===========================

Yul nesneleri, adlandırılmış kod ve veri bölümlerini gruplandırmak için kullanılır. 
``datasize``, ``dataoffset`` ve ``datacopy`` fonksiyonları 
bu bölümlere kod içinden erişmek için kullanılabilir. 
Onaltılı (hex) string'ler, onaltılı kodlamada verileri belirtmek için kullanılabilir, 
yerel (native) kodlamada normal string'ler kullanılır. 
Kod için ``datacopy``, birleştirilmiş ikili (binary) gösterimine erişecektir.

.. code-block:: none

    Object = 'object' StringLiteral '{' Code ( Object | Data )* '}'
    Code = 'code' Block
    Data = 'data' StringLiteral ( HexLiteral | StringLiteral )
    HexLiteral = 'hex' ('"' ([0-9a-fA-F]{2})* '"' | '\'' ([0-9a-fA-F]{2})* '\'')
    StringLiteral = '"' ([^"\r\n\\] | '\\' .)* '"'

Yukarıda ``Block``, önceki bölümde Yul kodu dilbilgisinde açıklanan ``Block`` anlamına gelir.

.. note::

    ``_deployed`` ile biten bir ada sahip bir nesne, Yul optimizer tarafından deploy edilmiş 
    kod olarak değerlendirilir. Bunun tek sonucu, optimize edicide bulgusal olarak farklı bir gaz maliyeti yöntemidir.

.. note::

    Adında ``.`` bulunan veri nesneleri veya alt nesneler tanımlanabilir, 
    ancak bunlara ``datasize``, ``dataoffset`` veya ``datacopy`` üzerinden erişim 
    mümkün değildir, çünkü ``.``, başka bir nesnenin içindeki 
    nesnelere erişmek için ayırıcı olarak kullanılır.

.. note::

    ``".metadata"`` adı verilen veri nesnesinin özel bir anlamı vardır: 
    Koddan erişilemez ve nesnedeki konumundan bağımsız 
    olarak her zaman bayt kodunun en sonuna eklenir.

    Gelecekte özel öneme sahip diğer veri nesneleri eklenebilir, 
    ancak adları her zaman bir ``.`` ile başlayacaktır.


Örnek bir Yul Nesnesi aşağıda gösterilmiştir:

.. code-block:: yul

    // Bir sözleşme, dağıtılacak kodu veya oluşturabileceği diğer sözleşmeleri 
    // temsil eden alt nesnelere sahip tek bir nesneden oluşur.
    // Tek "kod" düğümü, nesnenin yürütülebilir kodudur.
    // Her (diğer) adlandırılmış nesne veya veri bölümü serileştirilir ve
    //  özel gömülü fonksiyonlar olan datacopy / dataoffset / datasize için erişilebilir hale getirilir.
    // Geçerli nesnenin içindeki geçerli nesne, alt nesneler ve 
    // veri öğeleri kapsam içindedir.
    object "Contract1" {
        // Bu, sözleşmenin yapıcı (constructor) kodudur.
        code {
            function allocate(size) -> ptr {
                ptr := mload(0x40)
                if iszero(ptr) { ptr := 0x60 }
                mstore(0x40, add(ptr, size))
            }

            // ilk olarak  "Contract2" oluştur 
            let size := datasize("Contract2")
            let offset := allocate(size)
            // Bu, EVM için kod kopyasına dönüşecek
            datacopy(offset, dataoffset("Contract2"), size)
            // yapıcı parametresi tek bir sayıdır 0x1234
            mstore(add(offset, size), 0x1234)
            pop(create(offset, add(size, 32), 0))

            // şimdi çalışma zamanı nesnesini döndür
            // (şu anda yürütülmekte olan kod, yapıcı kodudur)
            size := datasize("Contract1_deployed")
            offset := allocate(size)
            // Bu, Ewasm için bir memory->memory kopyasına ve
            // EVM için bir kod kopyasına dönüşecektir.
            datacopy(offset, dataoffset("Contract1_deployed"), size)
            return(offset, size)
        }

        data "Table2" hex"4123"

        object "Contract1_deployed" {
            code {
                function allocate(size) -> ptr {
                    ptr := mload(0x40)
                    if iszero(ptr) { ptr := 0x60 }
                    mstore(0x40, add(ptr, size))
                }

                // runtime code

                mstore(0, "Hello, World!")
                return(0, 0x20)
            }
        }

        // Gömülü nesne. Kullanım durumu, dışarının bir fabrika sözleşmesi olması ve 
        // Sözleşme2'nin fabrika tarafından oluşturulacak kod olmasıdır.
        object "Contract2" {
            code {
                // kod buraya ...
            }

            object "Contract2_deployed" {
                code {
                    // kod buraya ...
                }
            }

            data "Table1" hex"4123"
        }
    }

Yul Optimizer
=============

Yul optimize edicisi Yul kodunda çalışır ve giriş, çıkış ve  ara durumlar için aynı dili kullanır. 
Bu, optimize edicinin kolay hata ayıklamasını ve doğrulanmasını sağlar.

Farklı optimizasyon aşamaları ve optimize edicinin nasıl kullanılacağı hakkında 
daha fazla ayrıntı için lütfen :ref:`optimize edici dökümantasyonu <optimizer>` bölümüne bakın.

Solidity'yi bağımsız Yul modunda kullanmak istiyorsanız, optimize ediciyi ``--optimize`` 
kullanarak etkinleştirirsiniz ve isteğe bağlı olarak ``--optimize-runs`` ile 
:ref:`beklenen sözleşme yürütme sayısı <optimizer-parameter-runs>` belirtirsiniz:

.. code-block:: sh

    solc --strict-assembly --optimize --optimize-runs 200

Solidity modunda Yul optimizer, normal optimizer ile birlikte etkinleştirilir.

.. _optimization-step-sequence:

Optimizasyon Adım Sırası
--------------------------

Varsayılan olarak Yul optimizer(optimize edici), önceden tanımlanmış optimizasyon adımları dizisini oluşturulan assembly'ye uygular. 
Bu sırayı geçersiz kılabilir ve ``--yul-optimizations`` seçeneğini kullanarak kendinizinkini uygulatabilirsiniz:

.. code-block:: sh

    solc --optimize --ir-optimized --yul-optimizations 'dhfoD[xarrscLMcCTU]uljmul'

Adımların sırası önemlidir ve çıktının kalitesini etkiler. 
Ayrıca, bir adımı uygulamak, daha önce uygulanmış olan diğerleri için yeni optimizasyon 
fırsatlarını ortaya çıkarabilir, bu nedenle adımları tekrarlamak genellikle faydalıdır. 
Dizinin bir kısmını köşeli parantezler (``[]``) içine alarak, optimize ediciye, 
sonuçta ortaya çıkan assemby'nin boyutunu artık iyileştirmeyene kadar o kısmı 
tekrar tekrar uygulamasını söylersiniz. Köşeli ayraçları tek bir sırada 
birden çok kez kullanabilirsiniz ancak iç içe geçemezler.

Aşağıdaki optimizasyon adımları uygulanabilir:

============ ===============================
Kısaltma     Tam adı
============ ===============================
``f``        ``BlockFlattener``
``l``        ``CircularReferencesPruner``
``c``        ``CommonSubexpressionEliminator``
``C``        ``ConditionalSimplifier``
``U``        ``ConditionalUnsimplifier``
``n``        ``ControlFlowSimplifier``
``D``        ``DeadCodeEliminator``
``v``        ``EquivalentFunctionCombiner``
``e``        ``ExpressionInliner``
``j``        ``ExpressionJoiner``
``s``        ``ExpressionSimplifier``
``x``        ``ExpressionSplitter``
``I``        ``ForLoopConditionIntoBody``
``O``        ``ForLoopConditionOutOfBody``
``o``        ``ForLoopInitRewriter``
``i``        ``FullInliner``
``g``        ``FunctionGrouper``
``h``        ``FunctionHoister``
``F``        ``FunctionSpecializer``
``T``        ``LiteralRematerialiser``
``L``        ``LoadResolver``
``M``        ``LoopInvariantCodeMotion``
``r``        ``RedundantAssignEliminator``
``R``        ``ReasoningBasedSimplifier`` - son derece deneysel
``m``        ``Rematerialiser``
``V``        ``SSAReverser``
``a``        ``SSATransform``
``t``        ``StructuralSimplifier``
``u``        ``UnusedPruner``
``p``        ``UnusedFunctionParameterPruner``
``d``        ``VarDeclInitializer``
============ ===============================

Bazı adımlar ``BlockFlattener``, ``FunctionGrouper``, ``ForLoopInitRewriter`` tarafından sağlanan özelliklere bağlıdır. 
Bu nedenle Yul optimize edicisi, kullanıcı tarafından sağlanan herhangi bir adımı uygulamadan önce bunları uygular.

ReasoningBasedSimplifier, şu anda varsayılan adımlar kümesinde etkinleştirilmeyen bir 
optimize edici adımıdır. Aritmetik ifadeleri ve boole koşullarını basitleştirmek için bir 
SMT çözücüsü kullanır. Henüz kapsamlı bir test veya doğrulama almamıştır ve tekrarlanamayan 
sonuçlar üretebilir, bu yüzden lütfen dikkatli kullanın!

.. _erc20yul:

Tamamlanmış ERC20 Örneği
=========================

.. code-block:: yul

    object "Token" {
        code {
            // Oluşturucuyu sıfır yuvasında saklayın.
            sstore(0, caller())

            // Contratı deploy edin
            datacopy(0, dataoffset("runtime"), datasize("runtime"))
            return(0, datasize("runtime"))
        }
        object "runtime" {
            code {
                // Ether göndermeye karşı koruma
                require(iszero(callvalue()))

                // Transfer edici
                switch selector()
                case 0x70a08231 /* "balanceOf(address)" */ {
                    returnUint(balanceOf(decodeAsAddress(0)))
                }
                case 0x18160ddd /* "totalSupply()" */ {
                    returnUint(totalSupply())
                }
                case 0xa9059cbb /* "transfer(address,uint256)" */ {
                    transfer(decodeAsAddress(0), decodeAsUint(1))
                    returnTrue()
                }
                case 0x23b872dd /* "transferFrom(address,address,uint256)" */ {
                    transferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2))
                    returnTrue()
                }
                case 0x095ea7b3 /* "approve(address,uint256)" */ {
                    approve(decodeAsAddress(0), decodeAsUint(1))
                    returnTrue()
                }
                case 0xdd62ed3e /* "allowance(address,address)" */ {
                    returnUint(allowance(decodeAsAddress(0), decodeAsAddress(1)))
                }
                case 0x40c10f19 /* "mint(address,uint256)" */ {
                    mint(decodeAsAddress(0), decodeAsUint(1))
                    returnTrue()
                }
                default {
                    revert(0, 0)
                }

                function mint(account, amount) {
                    require(calledByOwner())

                    mintTokens(amount)
                    addToBalance(account, amount)
                    emitTransfer(0, account, amount)
                }
                function transfer(to, amount) {
                    executeTransfer(caller(), to, amount)
                }
                function approve(spender, amount) {
                    revertIfZeroAddress(spender)
                    setAllowance(caller(), spender, amount)
                    emitApproval(caller(), spender, amount)
                }
                function transferFrom(from, to, amount) {
                    decreaseAllowanceBy(from, caller(), amount)
                    executeTransfer(from, to, amount)
                }

                function executeTransfer(from, to, amount) {
                    revertIfZeroAddress(to)
                    deductFromBalance(from, amount)
                    addToBalance(to, amount)
                    emitTransfer(from, to, amount)
                }


                /* ---------- calldata decoding fonksiyonları ----------- */
                function selector() -> s {
                    s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
                }

                function decodeAsAddress(offset) -> v {
                    v := decodeAsUint(offset)
                    if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                        revert(0, 0)
                    }
                }
                function decodeAsUint(offset) -> v {
                    let pos := add(4, mul(offset, 0x20))
                    if lt(calldatasize(), add(pos, 0x20)) {
                        revert(0, 0)
                    }
                    v := calldataload(pos)
                }
                /* ---------- calldata encoding fonksiyonları ---------- */
                function returnUint(v) {
                    mstore(0, v)
                    return(0, 0x20)
                }
                function returnTrue() {
                    returnUint(1)
                }

                /* -------- olaylar (events) ---------- */
                function emitTransfer(from, to, amount) {
                    let signatureHash := 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
                    emitEvent(signatureHash, from, to, amount)
                }
                function emitApproval(from, spender, amount) {
                    let signatureHash := 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925
                    emitEvent(signatureHash, from, spender, amount)
                }
                function emitEvent(signatureHash, indexed1, indexed2, nonIndexed) {
                    mstore(0, nonIndexed)
                    log3(0, 0x20, signatureHash, indexed1, indexed2)
                }

                /* -------- depolama düzeni ---------- */
                function ownerPos() -> p { p := 0 }
                function totalSupplyPos() -> p { p := 1 }
                function accountToStorageOffset(account) -> offset {
                    offset := add(0x1000, account)
                }
                function allowanceStorageOffset(account, spender) -> offset {
                    offset := accountToStorageOffset(account)
                    mstore(0, offset)
                    mstore(0x20, spender)
                    offset := keccak256(0, 0x40)
                }

                /* -------- depolama erişimi ---------- */
                function owner() -> o {
                    o := sload(ownerPos())
                }
                function totalSupply() -> supply {
                    supply := sload(totalSupplyPos())
                }
                function mintTokens(amount) {
                    sstore(totalSupplyPos(), safeAdd(totalSupply(), amount))
                }
                function balanceOf(account) -> bal {
                    bal := sload(accountToStorageOffset(account))
                }
                function addToBalance(account, amount) {
                    let offset := accountToStorageOffset(account)
                    sstore(offset, safeAdd(sload(offset), amount))
                }
                function deductFromBalance(account, amount) {
                    let offset := accountToStorageOffset(account)
                    let bal := sload(offset)
                    require(lte(amount, bal))
                    sstore(offset, sub(bal, amount))
                }
                function allowance(account, spender) -> amount {
                    amount := sload(allowanceStorageOffset(account, spender))
                }
                function setAllowance(account, spender, amount) {
                    sstore(allowanceStorageOffset(account, spender), amount)
                }
                function decreaseAllowanceBy(account, spender, amount) {
                    let offset := allowanceStorageOffset(account, spender)
                    let currentAllowance := sload(offset)
                    require(lte(amount, currentAllowance))
                    sstore(offset, sub(currentAllowance, amount))
                }

                /* ---------- faydalı fonksiyonlar ---------- */
                function lte(a, b) -> r {
                    r := iszero(gt(a, b))
                }
                function gte(a, b) -> r {
                    r := iszero(lt(a, b))
                }
                function safeAdd(a, b) -> r {
                    r := add(a, b)
                    if or(lt(r, a), lt(r, b)) { revert(0, 0) }
                }
                function calledByOwner() -> cbo {
                    cbo := eq(owner(), caller())
                }
                function revertIfZeroAddress(addr) {
                    require(addr)
                }
                function require(condition) {
                    if iszero(condition) { revert(0, 0) }
                }
            }
        }
    }
