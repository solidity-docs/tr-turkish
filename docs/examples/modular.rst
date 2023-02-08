.. index:: contract;modular, modular contract

********************
Modüler Kontratlar
********************

<<<<<<< HEAD
Kontratları oluştururken modüler bir yaklaşım izlemek kodların karışıklığını
azaltıp, okunabilirliğini arttırır. Bu durumda hataların ve açıkların daha
kolay bir şekilde bulunmasını sağlar. 
Eğer her modülün nasıl davranacağını izole bir şekilde tanımlar ve kontrol ederseniz,
sadece bütün kontratta olup biten yerine o kontratlar arasındaki ilişkileri inceleyebilirsiniz.
Aşağıdaki örnekte kontrat adresler arasında gönderilenin beklenen şekilde olup olmadığını
görmek için ``Balances`` :ref:`library <libraries>` kütüphanesinin ``move`` metodunu kullanır. 
``Balances`` kütüphanesinin asla nefatif bir bakiye çıkarmadığı ya da bütün bakiyelerin toplamından
overflow yaratmayacağı kolaylıkla doğrulanabilir ve bu durum kontratın yaşam süresi boyunca değişmez.
=======
A modular approach to building your contracts helps you reduce the complexity
and improve the readability which will help to identify bugs and vulnerabilities
during development and code review.
If you specify and control the behaviour of each module in isolation, the
interactions you have to consider are only those between the module specifications
and not every other moving part of the contract.
In the example below, the contract uses the ``move`` method
of the ``Balances`` :ref:`library <libraries>` to check that balances sent between
addresses match what you expect. In this way, the ``Balances`` library
provides an isolated component that properly tracks balances of accounts.
It is easy to verify that the ``Balances`` library never produces negative balances or overflows
and the sum of all balances is an invariant across the lifetime of the contract.
>>>>>>> v0.8.16

.. code-block:: solidity

    // SPDX-License-Identifier: GPL-3.0
    pragma solidity >=0.5.0 <0.9.0;

    library Balances {
        function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal {
            require(balances[from] >= amount);
            require(balances[to] + amount >= balances[to]);
            balances[from] -= amount;
            balances[to] += amount;
        }
    }

    contract Token {
        mapping(address => uint256) balances;
        using Balances for *;
        mapping(address => mapping (address => uint256)) allowed;

        event Transfer(address from, address to, uint amount);
        event Approval(address owner, address spender, uint amount);

        function transfer(address to, uint amount) external returns (bool success) {
            balances.move(msg.sender, to, amount);
            emit Transfer(msg.sender, to, amount);
            return true;

        }

        function transferFrom(address from, address to, uint amount) external returns (bool success) {
            require(allowed[from][msg.sender] >= amount);
            allowed[from][msg.sender] -= amount;
            balances.move(from, to, amount);
            emit Transfer(from, to, amount);
            return true;
        }

        function approve(address spender, uint tokens) external returns (bool success) {
            require(allowed[msg.sender][spender] == 0, "");
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }

        function balanceOf(address tokenOwner) external view returns (uint balance) {
            return balances[tokenOwner];
        }
    }
