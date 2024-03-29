Aşağıdaki tablo, değerlendirme sırasına göre listelenen operatörler için öncelik sırasını belirtir.

+------------+-------------------------------------+--------------------------------------------+
| Öncelik    | Tanım                               | Operatör                                   |
+============+=====================================+============================================+
| *1*        | Son ek ile tırma ve azaltma         | ``++``, ``--``                             |
+            +-------------------------------------+--------------------------------------------+
|            | Yeni ifade                          | ``new <typename>``                         |
+            +-------------------------------------+--------------------------------------------+
|            | Dizi elamanı görüntüleme            | ``<array>[<index>]``                       |
+            +-------------------------------------+--------------------------------------------+
|            | Üye erişimi                         | ``<object>.<member>``                      |
+            +-------------------------------------+--------------------------------------------+
|            | Fonksiyon çağırımı                  | ``<func>(<args...>)``                      |
+            +-------------------------------------+--------------------------------------------+
|            | Parantezler                         | ``(<statement>)``                          |
+------------+-------------------------------------+--------------------------------------------+
| *2*        | Ön ek ile artırma ve azaltma        | ``++``, ``--``                             |
+            +-------------------------------------+--------------------------------------------+
|            | Tekli çıkarma                       | ``-``                                      |
+            +-------------------------------------+--------------------------------------------+
|            | Tekli işlemler                      | ``delete``                                 |
+            +-------------------------------------+--------------------------------------------+
|            | Mantıksal 'DEĞİL'                   | ``!``                                      |
+            +-------------------------------------+--------------------------------------------+
|            | Bitsel 'DEĞİL'                      | ``~``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *3*        | Üs alma                             | ``**``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *4*        | Çarpma, bölme ve mod alma           | ``*``, ``/``, ``%``                        |
+------------+-------------------------------------+--------------------------------------------+
| *5*        | Ekleme ve çıkarma                   | ``+``, ``-``                               |
+------------+-------------------------------------+--------------------------------------------+
| *6*        | Bitsel değiştirme operatörleri      | ``<<``, ``>>``                             |
+------------+-------------------------------------+--------------------------------------------+
| *7*        | Bitsel 'VE'                         | ``&``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *8*        | Bitsel 'Özel veya'                  | ``^``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *9*        | Bitsel 'YA DA'                      | ``|``                                      |
+------------+-------------------------------------+--------------------------------------------+
| *10*       | Eşitsizlik operatörleri             | ``<``, ``>``, ``<=``, ``>=``               |
+------------+-------------------------------------+--------------------------------------------+
| *11*       | Eşitlik operatörleri                | ``==``, ``!=``                             |
+------------+-------------------------------------+--------------------------------------------+
| *12*       | Mantıksal 'VE'                      | ``&&``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *13*       | Mantıksal 'YA DA'                   | ``||``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *14*       | Üçlü operatör                       | ``<conditional> ? <if-true> : <if-false>`` |
+            +-------------------------------------+--------------------------------------------+
|            | Atama operatörleri                  | ``=``, ``|=``, ``^=``, ``&=``, ``<<=``,    |
|            |                                     | ``>>=``, ``+=``, ``-=``, ``*=``, ``/=``,   |
|            |                                     | ``%=``                                     |
+------------+-------------------------------------+--------------------------------------------+
| *15*       | Virgül operatörü                    | ``,``                                      |
+------------+-------------------------------------+--------------------------------------------+
