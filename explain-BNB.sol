//Source contract : https://etherscan.io/token/0xB8c77482e45F1F44dE1745F52C74426C631bDD52

/**
 *Submitted for verification at Etherscan.io on 2017-07-06
 */

pragma solidity ^0.4.8;

/**
Opérations mathématiques avec vérifications de sécurité
*/
contract SafeMath {
    //Fonction safeMul(uint256 a, uint256 b) : Cette fonction multiplie deux entiers uint256 en toute sécurité.
    function safeMul(uint256 a, uint256 b) internal returns (uint256) {
        // Elle effectue la multiplication normalement avec l'opérateur "*",
        uint256 c = a * b;

        //La vérification s'effectue en comparant le résultat de la multiplication divisé par l'opérande "a" avec l'opérande "b".
        //Si cette égalité n'est pas respectée, cela signifie qu'il y a eu un dépassement lors de la multiplication.
        assert(a == 0 || c / a == b);
        return c;
    }

    //__________________________________________________________________
    // Fonction safeDiv(uint256 a, uint256 b) : Cette fonction divise deux entiers uint256 en toute sécurité.
    function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
        //Avant de réaliser la division, elle vérifie que le diviseur "b" n'est pas égal à zéro pour éviter une division par zéro.
        assert(b > 0);

        //Ensuite, la division est effectuée normalement avec l'opérateur "/", puis une vérification est réalisée pour s'assurer que le résultat est cohérent.
        uint256 c = a / b;

        //Cette vérification compare le produit du diviseur "b" avec le quotient obtenu "c" à l'opérande "a" et ajoute le reste de la division "a % b".
        //Si cette égalité n'est pas respectée, cela signifie qu'il y a eu une erreur dans la division.
        assert(a == b * c + (a % b));
        return c;
    }

    //__________________________________________________________________
    // Fonction safeSub(uint256 a, uint256 b) : Cette fonction soustrait deux entiers uint256 en toute sécurité.
    function safeSub(uint256 a, uint256 b) internal returns (uint256) {
        // Elle effectue la soustraction normalement avec l'opérateur "-", puis vérifie que le résultat est cohérent.
        assert(b <= a);

        //La vérification s'effectue en comparant le résultat avec l'opérande "a". Si cette condition n'est pas respectée, cela signifie qu'il y a eu un dépassement lors de la soustraction.
        return a - b;
    }

    //__________________________________________________________________
    //Fonction safeAdd(uint256 a, uint256 b) : Cette fonction additionne deux entiers uint256 en toute sécurité.
    function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
        //Elle effectue l'addition normalement avec l'opérateur "+", puis vérifie que le résultat est cohérent.
        uint256 c = a + b;

        //La vérification s'effectue en comparant le résultat avec les opérandes "a" et "b".
        //Si le résultat est inférieur à l'une des deux opérandes, cela signifie qu'il y a eu un dépassement lors de l'addition.
        assert(c >= a && c >= b);
        return c;
    }

    //__________________________________________________________________
    // Fonction assert(bool assertion) : Cette fonction vérifie une assertion donnée en paramètre.
    function assert(bool assertion) internal {
        //Si l'assertion est fausse, c'est-à-dire si sa valeur est "false", elle génère une exception (throw).
        if (!assertion) {
            throw;
        }
    }
}

//__________________________________________________________________
//__________________________________________________________________

// Contrat du jeton BNB
contract BNB is SafeMath {
    // Variables publiques du jeton
    string public name; // Nom du jeton
    string public symbol; // Symbole du jeton
    uint8 public decimals; // Nombre de décimales
    uint256 public totalSupply; // Quantité totale de jetons émis
    address public owner; // Adresse du propriétaire du contrat

    //Les "mappings" sont des structures de données clé-valeur, dans lesquelles une clé est associée à une valeur.
    //Dans ce contrat, il y a trois "mappings" différents utilisés pour stocker des informations sur les utilisateurs de jetons :

    // ce mapping stocke le solde de chaque utilisateur de jetons en utilisant son adresse comme clé.
    mapping(address => uint256) public balanceOf;

    // ce mapping stocke le nombre de jetons gelés pour chaque utilisateur en utilisant son adresse comme clé.
    mapping(address => uint256) public freezeOf;

    //ce mapping stocke les autorisations de dépense pour chaque utilisateur.
    //Chaque utilisateur a une clé associée à un autre mapping, dans lequel
    //la clé est l'adresse de la personne autorisée à dépenser les jetons et la valeur est la quantité de jetons autorisée à être dépensée.
    mapping(address => mapping(address => uint256)) public allowance;

    // Ces "mappings" sont utilisés pour permettre aux utilisateurs de contrôler leurs jetons, en leur permettant de vérifier leur solde,
    // les jetons gelés et les autorisations de dépense qu'ils ont accordées.
    // Les "mappings" sont également utilisés pour stocker des informations importantes sur
    // les transferts de jetons,
    // les destructions de jetons,
    // les congélations de jetons et les dégels de jetons,
    // en utilisant des événements pour informer les utilisateurs de ces événements importants.

    //__________________________________________________________________
    //__________________________________________________________________
    //L'utilisation de l'attribut indexed sur les adresses dans les événements permet d'améliorer
    //l'efficacité des recherches dans les journaux des événements en utilisant ces adresses comme critères de recherche.
    //Cela facilite la récupération des informations spécifiques associées à une adresse donnée, car les événements indexés peuvent être filtrés par adresse.

    //Les paramètres from et to représentent respectivement l'adresse de l'expéditeur et du destinataire du transfert, tandis que value représente la quantité de jetons transférée.

    // Événement public déclenché lors d'un transfert de jetons
    event Transfer(address indexed from, address indexed to, uint256 value);
    // Événement public déclenché lors de la destruction de jetons
    event Burn(address indexed from, uint256 value);
    // Événement public déclenché lors de la congélation de jetons
    event Freeze(address indexed from, uint256 value);
    // Événement public déclenché lors du dégel de jetons
    event Unfreeze(address indexed from, uint256 value);

    //__________________________________________________________________
    //__________________________________________________________________
    /* Initialise le contrat avec l'offre initiale de tokens au créateur du contrat */
    function BNB(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
    ) {
        balanceOf[msg.sender] = initialSupply; // Donne tous les tokens initiaux au créateur
        totalSupply = initialSupply; // Met à jour l'offre totale
        name = tokenName; // Définit le nom pour l'affichage
        symbol = tokenSymbol; // Définit le symbole pour l'affichage
        decimals = decimalUnits; // Nombre de décimales pour l'affichage
        owner = msg.sender;
    }

    //__________________________________________________________________
    //__________________________________________________________________

    //Pourquoi dans le code suivant l'on retrouve des "_" devant, "to", "value", "spender", "from" ?

    //L'utilisation du préfixe _ est une convention de codage pour éviter toute confusion entre les paramètres locaux et les variables de stockage du contrat.
    //Cela rend le code plus lisible et facilite la distinction entre les différents types de variables.

    //Par exemple, dans la fonction transfer, le paramètre _to représente l'adresse du destinataire, _value représente la quantité de jetons à transférer, _spender dans la fonction approve représente
    //l'adresse du contract autorisé à dépenser des jetons en votre nom, et _from dans la fonction transferFrom représente l'adresse de l'expéditeur de jetons.

    //__________________________________________________________________
    /* Envoyer des coins */
    function transfer(address _to, uint256 _value) {
        if (_to == 0x0) throw; // Empêche le transfert à l'adresse 0x0. Utiliser burn() à la place
        if (_value <= 0) throw;
        if (balanceOf[msg.sender] < _value) throw; // Vérifie si l'expéditeur en a suffisamment
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Vérifie les débordements
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value); // Soustrait du compte de l'expéditeur
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value); // Ajoute la même somme au destinataire
        Transfer(msg.sender, _to, _value); // Notifie les auditeurs que le transfert a eu lieu
    }

    //__________________________________________________________________
    //__________________________________________________________________
    /* Autoriser un autre contrat à dépenser des tokens en votre nom */
    function approve(address _spender, uint256 _value) returns (bool success) {
        if (_value <= 0) throw;
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    //__________________________________________________________________
    //__________________________________________________________________
    /* Un contrat tente d'obtenir les tokens */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool success) {
        if (_to == 0x0) throw; // Empêche le transfert à l'adresse 0x0. Utiliser burn() à la place
        if (_value <= 0) throw;
        if (balanceOf[_from] < _value) throw; // Vérifie si l'expéditeur en a suffisamment
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Vérifie les débordements
        if (_value > allowance[_from][msg.sender]) throw; // Vérifie l'autorisation
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value); // Soustrait du compte de l'expéditeur
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value); // Ajoute la même somme au destinataire
        allowance[_from][msg.sender] = SafeMath.safeSub(
            allowance[_from][msg.sender],
            _value
        );
        Transfer(_from, _to, _value);
        return true;
    }

    //__________________________________________________________________
    //__________________________________________________________________
    // Cette fonction permet de brûler un nombre spécifique de tokens à partir du compte de l'expéditeur
    function burn(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw; // Vérifie si l'expéditeur dispose d'un solde suffisant
        if (_value <= 0) throw;
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value); // Soustrait le nombre de tokens de l'expéditeur
        totalSupply = SafeMath.safeSub(totalSupply, _value); // Met à jour le nombre total de tokens en circulation
        Burn(msg.sender, _value); // Émet un événement "Burn" pour enregistrer la transaction de brûlage
        return true;
    }

    //__________________________________________________________________
    //__________________________________________________________________
    // Cette fonction permet de geler un nombre spécifique de tokens du compte de l'expéditeur
    function freeze(uint256 _value) returns (bool success) {
        if (balanceOf[msg.sender] < _value) throw; // Vérifie si l'expéditeur dispose d'un solde suffisant
        if (_value <= 0) throw;
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value); // Soustrait le nombre de tokens de l'expéditeur
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value); // Ajoute le nombre de tokens gélés à l'adresse de l'expéditeur
        Freeze(msg.sender, _value); // Émet un événement "Freeze" pour enregistrer la transaction de gel
        return true;
    }

    //__________________________________________________________________
    //__________________________________________________________________
    // Cette fonction permet de dégeler un nombre spécifique de tokens du compte de l'expéditeur
    function unfreeze(uint256 _value) returns (bool success) {
        if (freezeOf[msg.sender] < _value) throw; // Vérifie si l'expéditeur dispose d'un solde de tokens gélés suffisant
        if (_value <= 0) throw;
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value); // Soustrait le nombre de tokens gélés de l'expéditeur
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value); // Ajoute le nombre de tokens dégelés à l'adresse de l'expéditeur
        Unfreeze(msg.sender, _value); // Émet un événement "Unfreeze" pour enregistrer la transaction de dégel
        return true;
    }

    //__________________________________________________________________
    //__________________________________________________________________
    // Cette fonction permet de transférer les ethers du contrat vers l'adresse du propriétaire
    function withdrawEther(uint256 amount) {
        if (msg.sender != owner) throw; // Vérifie si l'expéditeur est bien le propriétaire du contrat
        owner.transfer(amount); // Transfère les ethers à l'adresse du propriétaire
    }

    //__________________________________________________________________
    //__________________________________________________________________
    // Cette fonction permet au contrat d'accepter des ethers
    function() payable {}
}
