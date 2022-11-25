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

// from contracts.libraries.types.data_types import DataTypes


// return perdersen hash with input is model which is an array of felt
@view
func view_pedersen_hash_model{pedersen_ptr: HashBuiltin*}(
    model_len: felt, model: felt*,
) -> (hashed_value: felt) {
    alloc_locals;
    let (hashed_value) = compute_hash_struct_array(model_len, model);
    return (hashed_value=hashed_value);
}

// how test_data should be organized for merkle root hash?
// leafs len: has to be even
// n x, then n y
@view
func view_merkle_root_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leafs_len: felt, leafs: felt*
) -> (res: felt) {
    alloc_locals;
    // check leafs_len even
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
    model_len: felt, model: felt*
) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_hash) = ContractStorage.model_hash_read(caller_address);

    with_attr error_message("You should first commit something") {
        assert committed_hash = 0;
    }

    let (current_hash) = view_pedersen_hash_model(model_len, model);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_hash;
    }

    // save model len
    ContractStorage.polynomial_len_write(caller_address, model_len);

    // save model
    save_model(caller_address, model_len, model);
    return ();
}

func save_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    // address: felt, model_len: felt, model: felt*
    address: felt, polynomial_len: felt, weight: felt*
) {
    alloc_locals;
    if (polynomial_len==0) {
        return ();
    }
    // ContractStorage.mononomial_write(address, model_len, [model]);
    ContractStorage.mononomial_write(address, polynomial_len, [weight]);


    // return save_model(address, model_len-1, model+1);
    return save_model(address, polynomial_len-1, weight+1);

}

// @external
// func reveal_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
//     // structure of test data
//     // number of data point
//     // list data points
//     // requirement: number of point match
// ) {
    
// }


