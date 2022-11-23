%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.hash import hash2
// from starkware.cairo.common.bool import TRUE
// from starkware.cairo.common.math_cmp import is_le_felt
from starkware.starknet.common.syscalls import get_caller_address

from contracts.contract_storage import ContractStorage
from contracts.crypto.pedersen_hash import compute_hash_struct_array
from contracts.crypto.merkle_root import cal_merkle_root

from contracts.libraries.types.data_types import DataTypes



// @constructor
// func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     _number_features: felt
// ) {
//     ContractStorage.number_features_write(_number_features);
//     return ();
// }

// return perdersen hash with input is model which is an array of felt
@view
func view_pedersen_hash_model{pedersen_ptr: HashBuiltin*}(
    model_len: felt, model: felt*,
) -> (hashed_value: felt) {
    alloc_locals;
    let (hashed_value) = compute_hash_struct_array(term_len, term);
    return (hashed_value=hashed_value);
}

@view
func view_merkle_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leafs_len: felt, leafs: felt*
) -> (res: felt) {
    alloc_locals;
    let (res) = cal_merkle_root(leafs_len, leafs);
    return (res=res);
}

@external
func commit_model_hash{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(hash: felt) {
    let (caller_address) = get_caller_address();
    ContractStorage.model_hash_write(caller_address, hash);
    return ();
}

@external
func commit_merkle_root_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    root: felt
) {
    let (caller_address) = get_caller_address();
    ContractStorage.merkle_root_test_data_write(caller_address, root);
    return ();
}

@external
func reveal_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    term_len: felt, term: DataTypes.Term5V*
) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_hash) = ContractStorage.model_hash_read(caller_address);

    with_attr error_message("You should first commit something") {
        assert committed_hash = 0;
    }

    let (current_hash) = view_pedersen_hash_model(term_len, term);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_hash;
    }

    // save model len
    ContractStorage.model_len_write(caller_address, term_len);

    // save terms
    save_model(caller_address, term_len, term);
    return ();
}

func save_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    address: felt, term_len: felt, term: DataTypes.Term5V*
) {
    alloc_locals;
    if (term_len==0) {
        return ();
    }
    ContractStorage.model_term_write(address, term_len, [term]);
    return save_model(address, term_len-1, term+1);
}

// @external
// func reveal_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     // structure of test data
//     // number of data point
//     // list data points
//     // requirement: number of point match
// ) {
    
// }


