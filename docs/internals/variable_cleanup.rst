.. index: variable cleanup

*********************
Değişkenlerin Temizlenmesi
*********************

Bir değer 256 bitten daha kısa olduğunda, bazı durumlarda kalan bitlerin temizlenmesi
gerekir. Solidity derleyicisi, kalan bitlerdeki potansiyel çöplerden olumsuz etkilenebilecek
herhangi bir işlemden önce bu tür kalan bitleri temizlemek üzere tasarlanmıştır. Örnek vermek
gerekirse, belleğe bir değer yazmadan öncede kalan bitlerin temizlenmesi gerekir çünkü bellek
içeriği hash hesaplamak için kullanılabilir veya bir mesaj çağrısının verisi olarak gönderilebilir.
Benzer şekilde, bir değeri depolamadan öncede aynı durum geçerlidir çünkü aksi takdirde bozuk değer
gözlemlenebilir.

Satır içi(inline) assembly yoluyla erişimin böyle bir işlem olarak kabul edilmediğini unutmayın:
Eğer 256 bitten kısa Solidity değişkenlerine erişmek için satır içi (inline) assembly kullanırsanız,
derleyici değerin düzgün bir şekilde temizlendiğini garanti etmez.

Dahası, hemen ardından gelen işlem tarafından etkilenmiyorsa bitleri temizlemeyiz. Örneğin, sıfır
olmayan herhangi bir değer ``JUMPI`` komutu tarafından ``true`` olarak kabul edildiğinden, boolean
değerlerini ``JUMPI`` için koşul olarak kullanılmadan önce temizlemiyoruz.

Yukarıdaki tasarım prensibine ek olarak, Solidity derleyicisi girdi verilerini yığına(stack) yüklendiğinde temizler.

Farklı türlerin geçersiz değerleri temizlemek için farklı kuralları vardır:

+---------------+---------------+-------------------+
| Tür           | Geçerli       | Geçersiz          |
|               | Değerler      | Değer Anlamları   |
+===============+===============+===================+
|n üyeli bir    |0'dan n - 1'e  |istisna            |
|enum           |kadar          |                   |
+---------------+---------------+-------------------+
|bool           |0 ya da 1      |1                  |
+---------------+---------------+-------------------+
|işaretli tam   |işareti        |şu anda sessizce   |
|sayılar        |uzatılmış      |kapsar; gelecekte  |
|               |kelime         |istisnalar         |
|               |               |atılacaktır        |
|               |               |                   |
|               |               |                   |
+---------------+---------------+-------------------+
|işaretsiz  tam |yüksek bitler  |şu anda sessizce   |
|sayılar        |sıfırlandı     |kapsar; gelecekte  |
|               |               |istisnalar         |
|               |               |atılacaktır        |
+---------------+---------------+-------------------+
