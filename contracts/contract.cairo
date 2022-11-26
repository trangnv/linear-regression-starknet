%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_le_felt
from starkware.starknet.common.syscalls import get_caller_address

from contracts.contract_storage import ContractStorage
from contracts.crypto.pedersen_hash import _compute_pedersen_hash_chain
from contracts.crypto.merkle_root import cal_merkle_root

// from contracts.libraries.types.data_types import DataTypes
func _is_lt_felt{range_check_ptr}(a: felt, b: felt) -> felt {
    if (a == b) {
        return FALSE;
    }
    return is_le_felt(a, b);
}

// return perdersen hash with input is model which is an array of felt
@view
func view_pedersen_hash{pedersen_ptr: HashBuiltin*}(
    mononomial_len: felt, mononomial: felt*,
) -> (hashed_value: felt) {
    alloc_locals;
    let (hashed_value) = _compute_pedersen_hash_chain(mononomial, mononomial_len);
    return (hashed_value=hashed_value);
}

// how test_data should be organized for merkle root hash?
// leafs len: has to be even
// n x, then n y
@view
func view_merkle_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leafs_len: felt, leafs: felt*
) -> (res: felt) {
    alloc_locals;
    // check leafs_len even
    let (res) = cal_merkle_root(leafs_len, leafs);
    return (res=res);
}

@view
func view_test_data_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt){
    let (res) = ContractStorage.test_data_len_read();
    return(res=res);
}

@view
func view_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    i: felt
) -> (x_i: felt, y_i: felt){
    //check i < len
    alloc_locals;
    let (len) = ContractStorage.test_data_len_read();
    let res_1 = _is_lt_felt(i, len);
    with_attr error_message("Out of range") {
        assert res_1 = TRUE;
    }
    let (x_i, y_i) = ContractStorage.test_data_read(i);
    return(x_i=x_i, y_i=y_i);
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
    mononomial_len: felt, mononomial: felt*
) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_hash) = ContractStorage.model_hash_read(caller_address);

    with_attr error_message("You should first commit something") {
        assert committed_hash = 0;
    }

    let (current_hash) = view_pedersen_hash(mononomial_len, mononomial);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_hash;
    }

    // save model len
    ContractStorage.polynomial_len_write(caller_address, mononomial_len);

    // save model
    save_model(caller_address, mononomial_len, mononomial);
    return ();
}

func save_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    // address: felt, model_len: felt, model: felt*
    address: felt, mononomial_len: felt, mononomial: felt*
) {
    alloc_locals;
    if (mononomial_len==0) {
        return ();
    }
    // ContractStorage.mononomial_write(address, model_len, [model]);
    ContractStorage.mononomial_write(address, mononomial_len, [mononomial]);


    // return save_model(address, model_len-1, model+1);
    return save_model(address, mononomial_len-1, mononomial+1);

}

@external
func reveal_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    // structure of test data
    // number of data point
    // list data points
    // requirement: number of point match
    x_len: felt, x: felt*, y_len: felt, y: felt*
) {
    // check x_len == y_len
    // save test_data_len
    // save array (x_len, x)
    // save array (y_len, y)
    // alloc_locals;
    with_attr error_message("X and Y array need to have same size") {
        assert x_len = y_len;
    }
    ContractStorage.test_data_len_write(x_len);
    save_test_data(x_len, x, y);
    return();
}

func save_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    array_len: felt, x: felt*, y: felt*
) {
    if (array_len==0) {
        ContractStorage.test_data_write(array_len, x[0], y[0]);
        return ();
    }
    ContractStorage.test_data_write(array_len-1, x[array_len-1], y[array_len-1]);
    return save_test_data(array_len-1, x, y);

}

// func contains(haystack : felt*, haystack_len : felt) -> (result : felt){
//     if (haystack_len == 0) {
//         return (result=0);
//     }
//     if (1 == [haystack]){
//         return (result=1);
//     }
//     let (next) = contains(haystack + 1, haystack_len -1);
//     return (result=next);
// }
