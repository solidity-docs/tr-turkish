.. index:: !mapping
.. _mapping-types:

Eşleme Türleri
===============

Eşleme türleri ``mapping(KeyType => ValueType)`` sözdizimi yapısını kullanır ve eşleme türünün değişlenleri, ``mapping(KeyType => ValueType) VariableName`` sözdizimi kullanılarak bildirilir.

``KeyType``, herhangi bir yerleşik değer türü, ``bytes``, ``string``, herhangi bir sözleşme ya da numaralandırma türü olabilir. Eşlemeler, yapılar veya dizi türleri gibi diğer kullanıcı tanımlı veya karmaşık türlere izin verilmez. ``ValueType``, eşlemeleri, dizileri ve yapıları içeren herhangi bir tür olabilir.  


Eşlemeleri, olası her anahtarın var olduğu ve bir türün :ref:`varsayılan değeri <default-value>` olan bayt temsilinin tamamı sıfır olan bir değere eşlendiği şekilde sanal olarak başlatılan `karma tablolar <https://en.wikipedia.org/wiki/Hash_table>`_ olarak düşünebilirsiniz. Benzerlik burada sona eriyor, anahtar veriler bir eşlemede saklanmıyor, değeri aramak için yalnızca ``keccak256`` karma değeri kullanılıyor.

Bu nedenle, eşlemelerin bir uzunluğu veya ayarlanan bir anahtar veya değer kavramı yoktur ve bu nedenle atanan anahtarlarla ilgili ek bilgi olmadan silinemezler (bkz. :ref:`clearing-mappings`).

Eşlemeler yalnızca ``storage`` veri konumuna sahip olabilir ve bu nedenle, fonksiyonlardaki depolama referans türleri olarak veya kitaplık fonksiyonları için parametreler olarak durum değişkenleri için izin verilir. Bunlar, genel olarak görülebilen sözleşme fonksiyonlarının parametreleri veya dönüş parametreleri olarak kullanılamazlar. Bu kısıtlamalar, eşlemeler içeren diziler ve yapılar için de geçerlidir.

Eşleme türündeki durum değişkenlerini ``public`` olarak işaretleyebilirsiniz ve Solidity sizin için bir :ref:`alıcı <visibility-and-getters>` oluşturur. ``KeyType``, alıcı için bir parametre olur. ``ValueType`` bir değer türü veya yapıysa, alıcı ``ValueType`` değerini döndürür. ``ValueType`` bir dizi veya eşleme ise, alıcının her bir ``KeyType`` için yinelemeli olarak bir parametresi vardır.

Aşağıdaki örnekte, ``MappingExample`` sözleşmesi, anahtar türü bir ``address`` olan genel bir ``balances`` eşlemesini ve bir Ethereum adresini işaretsiz bir tamsayı değerine eşleyen bir ``uint`` değer türünü tanımlar. ``uint`` bir değer türü olduğundan, alıcı, belirtilen adreste değeri döndüren ``MappingUser`` sözleşmesinde görebileceğiniz türle eşleşen bir değer döndürür.


.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.0 <0.9.0;

    contract MappingExample {
        mapping(address => uint) public balances;

        function update(uint newBalance) public {
            balances[msg.sender] = newBalance;
        }
    }

    contract MappingUser {
        function f() public returns (uint) {
            MappingExample m = new MappingExample();
            m.update(100);
            return m.balances(address(this));
        }
    }


Aşağıdaki örnek, bir `ERC20 tokenin <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol>`_ basitleştirilmiş bir versiyonudur. ``_allowances``, başka bir eşleme türü içindeki eşleme türüne bir örnektir. 

Aşağıdaki örnekte, başka birinin hesabınızdan çekmesine izin verilen tutarı kaydetmek için ``_allowances`` kullanılmıştır.

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.4.22 <0.9.0;

    contract MappingExample {

        mapping (address => uint256) private _balances;
        mapping (address => mapping (address => uint256)) private _allowances;

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

        function allowance(address owner, address spender) public view returns (uint256) {
            return _allowances[owner][spender];
        }

        function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
            require(_allowances[sender][msg.sender] >= amount, "ERC20: Allowance not high enough.");
            _allowances[sender][msg.sender] -= amount;
            _transfer(sender, recipient, amount);
            return true;
        }

        function approve(address spender, uint256 amount) public returns (bool) {
            require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }

        function _transfer(address sender, address recipient, uint256 amount) internal {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            require(_balances[sender] >= amount, "ERC20: Not enough funds.");

            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }


.. index:: !iterable mappings
.. _iterable-mappings:

Yinelenebilir Eşlemeler
------------------------

Eşlemeleri yineleyemezsiniz, yani anahtarlarını numaralandıramazsınız. Yine de bunların üzerine bir veri yapısı uygulamak ve bunun üzerinde yineleme yapmak mümkündür. Örneğin, aşağıdaki kod, ``User`` sözleşmesinin daha sonra veri eklediği bir ``IterableMapping`` kitaplığı uygular ve ``sum`` fonksiyonu tüm değerleri toplamak için yinelenir.


.. code-block:: solidity
    :force:

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.8.8;

    struct IndexValue { uint keyIndex; uint value; }
    struct KeyFlag { uint key; bool deleted; }

    struct itmap {
        mapping(uint => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }

    type Iterator is uint;

    library IterableMapping {
        function insert(itmap storage self, uint key, uint value) internal returns (bool replaced) {
            uint keyIndex = self.data[key].keyIndex;
            self.data[key].value = value;
            if (keyIndex > 0)
                return true;
            else {
                keyIndex = self.keys.length;
                self.keys.push();
                self.data[key].keyIndex = keyIndex + 1;
                self.keys[keyIndex].key = key;
                self.size++;
                return false;
            }
        }

        function remove(itmap storage self, uint key) internal returns (bool success) {
            uint keyIndex = self.data[key].keyIndex;
            if (keyIndex == 0)
                return false;
            delete self.data[key];
            self.keys[keyIndex - 1].deleted = true;
            self.size --;
        }

        function contains(itmap storage self, uint key) internal view returns (bool) {
            return self.data[key].keyIndex > 0;
        }

        function iterateStart(itmap storage self) internal view returns (Iterator) {
            return iteratorSkipDeleted(self, 0);
        }

        function iterateValid(itmap storage self, Iterator iterator) internal view returns (bool) {
            return Iterator.unwrap(iterator) < self.keys.length;
        }

        function iterateNext(itmap storage self, Iterator iterator) internal view returns (Iterator) {
            return iteratorSkipDeleted(self, Iterator.unwrap(iterator) + 1);
        }

        function iterateGet(itmap storage self, Iterator iterator) internal view returns (uint key, uint value) {
            uint keyIndex = Iterator.unwrap(iterator);
            key = self.keys[keyIndex].key;
            value = self.data[key].value;
        }

        function iteratorSkipDeleted(itmap storage self, uint keyIndex) private view returns (Iterator) {
            while (keyIndex < self.keys.length && self.keys[keyIndex].deleted)
                keyIndex++;
            return Iterator.wrap(keyIndex);
        }
    }

    // Nasıl kullanılır
    contract User {
        // Sadece verilerimizi tutan bir yapı.
        itmap data;
        // Veri türüne kitaplık fonksiyonlarını uygulayın.
        using IterableMapping for itmap;

        // Bir şeyleri ekle
        function insert(uint k, uint v) public returns (uint size) {
            // Bu, IterableMapping.insert(data, k, v)'yi çağırır.
            data.insert(k, v);
            // Yapının üyelerine hala erişebiliriz,
            // ama bunlarla uğraşmamaya özen göstermeliyiz.
            return data.size;
        }

        // Depolanan tüm verilerin toplamını hesaplar.
        function sum() public view returns (uint s) {
            for (
                Iterator i = data.iterateStart();
                data.iterateValid(i);
                i = data.iterateNext(i)
            ) {
                (, uint value) = data.iterateGet(i);
                s += value;
            }
        }
    }
