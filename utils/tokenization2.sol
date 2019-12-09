pragma solidity 0.5.11;
pragma experimental ABIEncoderV2;



contract main_structure{
    // stmt_token[] private __tokens_hold;;
    // store hash here (combination of address of the owner and address of the lender)
    mapping (address => stmt_token) private __tokens_hold;
    stmt_token_operations __token_generator;
    // this structure should be optimized? mapping would be better i guess (assuming it has dict structure, but for now lets leave as list)
    constructor(address[] memory other_party, int32[] memory balance, bytes[] memory balance_string, int16[] memory currency_type) public{
        add_new_tokens(other_party, balance, balance_string, currency_type);
    }
    
    function add_new_tokens(address[] memory other_party, int32[] memory balance, bytes[] memory balance_string, int16[] memory currency_type) public{
        __token_generator = new stmt_token_operations(other_party, balance, balance_string, currency_type);
        stmt_token[] memory first_tokens = __token_generator.get_tokens();
        for (uint i=0; i < first_tokens.length; i++){
            // we have to change this for hashing function (to include it logic below)
            address hash = hashing_function(first_tokens[i].get_token_owner(), first_tokens[i].get_token_other_party());
            __tokens_hold[hash] = first_tokens[i];
            // __tokens_hold[first_tokens[i].get_token_owner()] = first_tokens[i];
        }
    }
    
    function settle_tokens(address token_owner, address token_other_party) private{
        //try catch here
        address hash = hashing_function(token_owner, token_other_party);
        __tokens_hold[hash].settle_token();
        hash = hashing_function(token_other_party, token_owner);
        __tokens_hold[hash].settle_token();
    }
    
    function hashing_function(address start, address finish) private returns(address) {
        // hashing goes here
        address hash2 = finish;
        address hash = start;
        return hash;
    }
    
    function token_transfer(address transfer_origin, address transfer_destination, address accepting_party) public
    {
        // we settle original tokens
        address hash = hashing_function(transfer_origin, accepting_party);
        stmt_token original_token = __tokens_hold[hash];
        settle_tokens(transfer_origin, accepting_party);        
        // we create new ones for selected addresses.        
        // lender has to be first depending on hash structure!!!! this is very important
        address[] memory involved_party = new address[](2);
        if (original_token.get_token_owed()){
            involved_party[0] = transfer_destination;
            involved_party[1] = accepting_party;      
        }else{
            involved_party[0] = accepting_party;
            involved_party[1] = transfer_destination;
        }
        int32[] memory balance = new int32[](2);
        balance[0] = original_token.get_token_balance();
        balance[1] = balance[0];
        bytes[] memory balance_string = new bytes[](2);
        balance_string[0] = original_token.get_token_balance_string();
        balance_string[1] = balance_string[0];
        int16[] memory currency_type = new int16[](2);
        currency_type[0] = original_token.get_token_currency_type();
        currency_type[1] = currency_type[0];
        // this could be written better (a function to copy)
        add_new_tokens(involved_party, balance, balance_string, currency_type);
        
    }
    
    function settle_contract(address lender, address lendee) public{
        settle_tokens(lender, lendee);
    }
    
}


contract stmt_token_operations{
    
    stmt_token[] private __tokens;
    // we're assuming the preson who does this operation is the owner of the token.
    // interested parties are the usernames of people participating in the exchange. 
    // from the side of all operations we're assuming the creation is done 
    // if token_owed it assumes 0 idx from other_party is for lender and rest are other participants.
    // works for split payment. 
    // we need arguments balance/balance_string as arrays of appropriate types 
    // we're generating as many tokens as there are people in the transaction, with orientation 1 lender multiple lendees.
    // we generate as much tokens as usernames passed, with the specified split.
    // todo floading point operations in solidity
    // we can take the assumption that we multiply incomming transaction values by 100.
    // we sub them by multiplying the value of the transaction by 100. because there is no support for double/floats

    constructor(address[] memory other_party, int32[] memory balance, bytes[] memory balance_string, int16[] memory currency_type) public {
    // logic about barter.
    // if token_string is true it is a barter
        uint count = 0;
        for (uint i=1; i<other_party.length; i++){
            __tokens[count] = new stmt_token(other_party[0], other_party[i], balance[i], currency_type[i], balance_string[i], false);        
            count += 1;
            __tokens[count] = new stmt_token(other_party[i], other_party[0], balance[i], currency_type[i], balance_string[i], true);        
            count += 1;
        }
    }    
    
    
    function get_tokens() public view returns(stmt_token[] memory){
        return __tokens;
    }
}


contract stmt_token{

    address private __owner;
    address private __other_side;
    int32 private __balance;  // balance is how much you owe or are owed.
    int16 private __currency_type; // we're going to store it on the application config files. ex. EUR - 0, USD - 1, YEN - 2....
    bytes private __balance_string; // same as above but in objects.
    bool private __token_string; // indication if the token object is written in string
    bool private __token_status; // indication if the token is completed or not
    bool private __token_owed; // indication if the token is lendee or lender
    uint private __date_creation;
    uint private __date_settled;

    modifier is_owner{
        require((msg.sender == __owner || msg.sender == __other_side), "person attempting to settle is not the party involved");
        _;
    } 

    constructor(address owner, address other_side, int32 balance, int16 currency_type, bytes memory balance_string,
                bool token_owed) public 
    {
        __owner = owner;
        __other_side = other_side;
        __balance = balance;
        __currency_type = currency_type;
        __balance_string = balance_string;
        __token_status = true; // 1 for pending 0 for settled 
        __token_owed = token_owed;
        __date_creation = now;
        __date_settled = 0;
        if (keccak256(balance_string) == keccak256("")){
            __token_string = true;
        }
        else{
            __token_string = false;
        }
    }
    
    function set_token_status(bool status) private {
        __token_status = status;
    }
    
    function set_token_settled_date() private{
        __date_settled = now;
    }
    
    function get_token_owner() public view returns(address){
        return __owner;
    }
    
    function get_token_other_party() public view returns(address){
        return __other_side;
    }
    
    function get_token_balance() public view returns(int32){
        return __balance;
    }
    
    function get_token_balance_string() public view returns(bytes memory){
        return __balance_string;
    }
    
    function get_token_currency_type() public view returns(int16){
        return __currency_type;
    }
    
    function get_token_owed() public view returns(bool){
        return __token_owed;
    }
    
    function settle_token() is_owner public{
        set_token_settled_date();
        set_token_status(false);
    }  
    
}
