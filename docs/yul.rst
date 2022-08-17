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
==============

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
=================

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

.. uyarı::

    Yul aktif geliştirme aşamasındadır ve bayt kodu oluşturma, yalnızca hedef olarak EVM 1.0 
    ile Yul'un EVM diyalekti için tam olarak uygulanabilir.


Yul'un Resmi Olmayan Tanımı
===========================

Aşağıda Yul dilinin bütün yönleri hakkında konuşacağız. Örneklerde varsayılan EVM diyalektini kullanacağız.

Sözdizimi (Syntax)
------

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
--------

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

- Bir onaltılık dize, önce her bir bitişik onaltılık basamak çifti 
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
--------------

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
--

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
-----

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
---------------------------

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
-------------

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

AST'nin çeşitli düğümlerinde aşırı yüklenmiş bir E değerlendirme fonksiyonu 
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
        G, L2, regular
    E(G, L, <for { i1, ..., in } condition post body>: ForLoop) =
        if n >= 1:
            let G1, L, mode = E(G, L, i1, ..., in)
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
                        G2, L3, leave
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
| sar(x, y)               |     | C |  işaretli aritmetik kaydırma sağa y ile x bit                   |
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
| selfbalance()           |     | I |  balance(address()) ile eşdeğer, ancak daha ucuz                |
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
| callcode(g, a, v, in,   |     | F |  ``call`` ile aynıdır, ancak yalnızca a kodunu kullanın         |
| insize, out, outsize)   |     |   | ve aksi takdirde mevcut sözleşme bağlamında kalın               |
|                         |     |   | :ref:`Daha fazla bilgi <yul-call-return-area>`                  |
+-------------------------+-----+---+-----------------------------------------------------------------+
| delegatecall(g, a, in,  |     | H |  ``callcode`` ile eşdeğerdir ama aynı zamanda ``caller``        |
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

.. not::
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
The function ``linkersymbol("library_id")`` is a placeholder for an address literal to be substituted
by the linker.
Its first and only argument must be a string literal and uniquely represents the address to be inserted.
Identifiers can be arbitrary but when the compiler produces Yul code from Solidity sources,
it uses a library name qualified with the name of the source unit that defines that library.
To link the code with a particular library address, the same identifier must be provided to the
``--libraries`` option on the command line.

For example this code

.. code-block:: yul

    let a := linkersymbol("file.sol:Math")

is equivalent to

.. code-block:: yul

    let a := 0x1234567890123456789012345678901234567890

when the linker is invoked with ``--libraries "file.sol:Math=0x1234567890123456789012345678901234567890``
option.

See :ref:`Using the Commandline Compiler <commandline-compiler>` for details about the Solidity linker.

memoryguard
^^^^^^^^^^^

This function is available in the EVM dialect with objects. The caller of
``let ptr := memoryguard(size)`` (where ``size`` has to be a literal number)
promises that they only use memory in either the range ``[0, size)`` or the
unbounded range starting at ``ptr``.

Since the presence of a ``memoryguard`` call indicates that all memory access
adheres to this restriction, it allows the optimizer to perform additional
optimization steps, for example the stack limit evader, which attempts to move
stack variables that would otherwise be unreachable to memory.

The Yul optimizer promises to only use the memory range ``[size, ptr)`` for its purposes.
If the optimizer does not need to reserve any memory, it holds that ``ptr == size``.

``memoryguard`` can be called multiple times, but needs to have the same literal as argument
within one Yul subobject. If at least one ``memoryguard`` call is found in a subobject,
the additional optimiser steps will be run on it.


.. _yul-verbatim:

verbatim
^^^^^^^^

The set of ``verbatim...`` builtin functions lets you create bytecode for opcodes
that are not known to the Yul compiler. It also allows you to create
bytecode sequences that will not be modified by the optimizer.

The functions are ``verbatim_<n>i_<m>o("<data>", ...)``, where

- ``n`` is a decimal between 0 and 99 that specifies the number of input stack slots / variables
- ``m`` is a decimal between 0 and 99 that specifies the number of output stack slots / variables
- ``data`` is a string literal that contains the sequence of bytes

If you for example want to define a function that multiplies the input
by two, without the optimizer touching the constant two, you can use

.. code-block:: yul

    let x := calldataload(0)
    let double := verbatim_1i_1o(hex"600202", x)

This code will result in a ``dup1`` opcode to retrieve ``x``
(the optimizer might directly re-use result of the
``calldataload`` opcode, though)
directly followed by ``600202``. The code is assumed to
consume the copied value of ``x`` and produce the result
on the top of the stack. The compiler then generates code
to allocate a stack slot for ``double`` and store the result there.

As with all opcodes, the arguments are arranged on the stack
with the leftmost argument on the top, while the return values
are assumed to be laid out such that the rightmost variable is
at the top of the stack.

Since ``verbatim`` can be used to generate arbitrary opcodes
or even opcodes unknown to the Solidity compiler, care has to be taken
when using ``verbatim`` together with the optimizer. Even when the
optimizer is switched off, the code generator has to determine
the stack layout, which means that e.g. using ``verbatim`` to modify
the stack height can lead to undefined behaviour.

The following is a non-exhaustive list of restrictions on
verbatim bytecode that are not checked by
the compiler. Violations of these restrictions can result in
undefined behaviour.

- Control-flow should not jump into or out of verbatim blocks,
  but it can jump within the same verbatim block.
- Stack contents apart from the input and output parameters
  should not be accessed.
- The stack height difference should be exactly ``m - n``
  (output slots minus input slots).
- Verbatim bytecode cannot make any assumptions about the
  surrounding bytecode. All required parameters have to be
  passed in as stack variables.

The optimizer does not analyze verbatim bytecode and always
assumes that it modifies all aspects of state and thus can only
do very few optimizations across ``verbatim`` function calls.

The optimizer treats verbatim bytecode as an opaque block of code.
It will not split it but might move, duplicate
or combine it with identical verbatim bytecode blocks.
If a verbatim bytecode block is unreachable by the control-flow,
it can be removed.


.. warning::

    During discussions about whether or not EVM improvements
    might break existing smart contracts, features inside ``verbatim``
    cannot receive the same consideration as those used by the Solidity
    compiler itself.

.. note::

    To avoid confusion, all identifiers starting with the string ``verbatim`` are reserved
    and cannot be used for user-defined identifiers.

.. _yul-object:

Specification of Yul Object
===========================

Yul objects are used to group named code and data sections.
The functions ``datasize``, ``dataoffset`` and ``datacopy``
can be used to access these sections from within code.
Hex strings can be used to specify data in hex encoding,
regular strings in native encoding. For code,
``datacopy`` will access its assembled binary representation.

.. code-block:: none

    Object = 'object' StringLiteral '{' Code ( Object | Data )* '}'
    Code = 'code' Block
    Data = 'data' StringLiteral ( HexLiteral | StringLiteral )
    HexLiteral = 'hex' ('"' ([0-9a-fA-F]{2})* '"' | '\'' ([0-9a-fA-F]{2})* '\'')
    StringLiteral = '"' ([^"\r\n\\] | '\\' .)* '"'

Above, ``Block`` refers to ``Block`` in the Yul code grammar explained in the previous chapter.

.. note::

    An object with a name that ends in ``_deployed`` is treated as deployed code by the Yul optimizer.
    The only consequence of this is a different gas cost heuristic in the optimizer.

.. note::

    Data objects or sub-objects whose names contain a ``.`` can be defined
    but it is not possible to access them through ``datasize``,
    ``dataoffset`` or ``datacopy`` because ``.`` is used as a separator
    to access objects inside another object.

.. note::

    The data object called ``".metadata"`` has a special meaning:
    It cannot be accessed from code and is always appended to the very end of the
    bytecode, regardless of its position in the object.

    Other data objects with special significance might be added in the
    future, but their names will always start with a ``.``.


An example Yul Object is shown below:

.. code-block:: yul

    // A contract consists of a single object with sub-objects representing
    // the code to be deployed or other contracts it can create.
    // The single "code" node is the executable code of the object.
    // Every (other) named object or data section is serialized and
    // made accessible to the special built-in functions datacopy / dataoffset / datasize
    // The current object, sub-objects and data items inside the current object
    // are in scope.
    object "Contract1" {
        // This is the constructor code of the contract.
        code {
            function allocate(size) -> ptr {
                ptr := mload(0x40)
                if iszero(ptr) { ptr := 0x60 }
                mstore(0x40, add(ptr, size))
            }

            // first create "Contract2"
            let size := datasize("Contract2")
            let offset := allocate(size)
            // This will turn into codecopy for EVM
            datacopy(offset, dataoffset("Contract2"), size)
            // constructor parameter is a single number 0x1234
            mstore(add(offset, size), 0x1234)
            pop(create(offset, add(size, 32), 0))

            // now return the runtime object (the currently
            // executing code is the constructor code)
            size := datasize("Contract1_deployed")
            offset := allocate(size)
            // This will turn into a memory->memory copy for Ewasm and
            // a codecopy for EVM
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

        // Embedded object. Use case is that the outside is a factory contract,
        // and Contract2 is the code to be created by the factory
        object "Contract2" {
            code {
                // code here ...
            }

            object "Contract2_deployed" {
                code {
                    // code here ...
                }
            }

            data "Table1" hex"4123"
        }
    }

Yul Optimizer
=============

The Yul optimizer operates on Yul code and uses the same language for input, output and
intermediate states. This allows for easy debugging and verification of the optimizer.

Please refer to the general :ref:`optimizer documentation <optimizer>`
for more details about the different optimization stages and how to use the optimizer.

If you want to use Solidity in stand-alone Yul mode, you activate the optimizer using ``--optimize``
and optionally specify the :ref:`expected number of contract executions <optimizer-parameter-runs>` with
``--optimize-runs``:

.. code-block:: sh

    solc --strict-assembly --optimize --optimize-runs 200

In Solidity mode, the Yul optimizer is activated together with the regular optimizer.

.. _optimization-step-sequence:

Optimization Step Sequence
--------------------------

By default the Yul optimizer applies its predefined sequence of optimization steps to the generated assembly.
You can override this sequence and supply your own using the ``--yul-optimizations`` option:

.. code-block:: sh

    solc --optimize --ir-optimized --yul-optimizations 'dhfoD[xarrscLMcCTU]uljmul'

The order of steps is significant and affects the quality of the output.
Moreover, applying a step may uncover new optimization opportunities for others that were already
applied so repeating steps is often beneficial.
By enclosing part of the sequence in square brackets (``[]``) you tell the optimizer to repeatedly
apply that part until it no longer improves the size of the resulting assembly.
You can use brackets multiple times in a single sequence but they cannot be nested.

The following optimization steps are available:

============ ===============================
Abbreviation Full name
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
``R``        ``ReasoningBasedSimplifier`` - highly experimental
``m``        ``Rematerialiser``
``V``        ``SSAReverser``
``a``        ``SSATransform``
``t``        ``StructuralSimplifier``
``u``        ``UnusedPruner``
``p``        ``UnusedFunctionParameterPruner``
``d``        ``VarDeclInitializer``
============ ===============================

Some steps depend on properties ensured by ``BlockFlattener``, ``FunctionGrouper``, ``ForLoopInitRewriter``.
For this reason the Yul optimizer always applies them before applying any steps supplied by the user.

The ReasoningBasedSimplifier is an optimizer step that is currently not enabled
in the default set of steps. It uses an SMT solver to simplify arithmetic expressions
and boolean conditions. It has not received thorough testing or validation yet and can produce
non-reproducible results, so please use with care!

.. _erc20yul:

Complete ERC20 Example
======================

.. code-block:: yul

    object "Token" {
        code {
            // Store the creator in slot zero.
            sstore(0, caller())

            // Deploy the contract
            datacopy(0, dataoffset("runtime"), datasize("runtime"))
            return(0, datasize("runtime"))
        }
        object "runtime" {
            code {
                // Protection against sending Ether
                require(iszero(callvalue()))

                // Dispatcher
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


                /* ---------- calldata decoding functions ----------- */
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
                /* ---------- calldata encoding functions ---------- */
                function returnUint(v) {
                    mstore(0, v)
                    return(0, 0x20)
                }
                function returnTrue() {
                    returnUint(1)
                }

                /* -------- events ---------- */
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

                /* -------- storage layout ---------- */
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

                /* -------- storage access ---------- */
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

                /* ---------- utility functions ---------- */
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
