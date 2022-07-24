
.. index: calldata layout

*******************
Çağrı Verilerinin Düzeni
*******************

Bir fonksiyon çağrısı için alınan girdi verisinin :ref:`ABI belirtimi <ABI>` tarafından
tanımlanan formatta olduğu varsayılır. Diğerlerinin yanı sıra, ABI belirtimi argümanların 32
baytın katları olacak şekilde eklenmesini zorunlu kılar. Dahili(internal) fonksiyon çağrıları
bundan farklı bir kural kullanır.

Bir sözleşmenin constructor fonksiyonu için argümanlar, ABI şifrelemesinde de sözleşmenin kodunun
sonuna doğrudan eklenir. Constructor fonksiyonu argümanlara ``codesize`` işlem kodunu kullanarak
değil, sabit kodlanmış bir ofset üzerinden erişir. Bunun nedeni ise koda veri eklerken bu ofsetin değişmesidir.
