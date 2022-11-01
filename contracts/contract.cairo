%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.hash import hash2
// from starkware.cairo.common.bool import TRUE
// from starkware.cairo.common.math_cmp import is_le_felt
from starkware.starknet.common.syscalls import get_caller_address

from contracts.contract_storage import ContractStorage
from contracts.crypto.pedersen_hash import cal_pedersen_hash_chain
from contracts.crypto.merkle_root import cal_merkle_root




@storage_var
func coef_0_storage(address: felt) -> (coef_0: felt) {
}

@storage_var
func intercept_storage(address: felt) -> (res: felt) {
}


@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _number_features: felt
) {
    ContractStorage.number_features_write(_number_features);
    return ();
}

@view
func view_pedersen_hash_chain{pedersen_ptr: HashBuiltin*}(
    coefs_len: felt, coefs: felt*, intercept_: felt
) -> (hashed_value: felt) {
    alloc_locals;
    let (coefs_hashed_value) = cal_pedersen_hash_chain(coefs, coefs_len);
    let (hashed_value) = hash2{hash_ptr=pedersen_ptr}(coefs_hashed_value, intercept_);
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
func reveal_model{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(array_len: felt, array: felt*, intercept: felt) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_hash) = ContractStorage.model_hash_read(caller_address);

    with_attr error_message("You should first commit something") {
        assert committed_hash = 0;
    }

    // check array_len == number_of_features
    let (n) = ContractStorage.number_features_read();
    with_attr error_message("Wrong number of coefficient") {
        assert array_len = n;
    }

    let (current_hash) = view_pedersen_hash_chain(array_len, array, intercept);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_hash;
    }

    let (local new_array) = alloc();
    _save_model(array=array, new_array=new_array, length=array_len);  // save coefs to the new_array
    coef_0_storage.write(caller_address, [new_array]);  // coef_0 = [new_array] and the other coefs are followed

    intercept_storage.write(caller_address, intercept);  // store intercept

    return ();
}

func _save_model{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(array: felt*, new_array: felt*, length: felt) {
    if (length == 0) {
        return ();
    }
    assert [new_array] = [array];
    _save_model(array=array + 1, new_array=new_array + 1, length=length - 1);
    return ();
}
// @external
// func predict{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(input: felt) -> (
//     output: felt
// ) {
//     alloc_locals;
//     let (sender_address) = get_caller_address();
//     // load the models, hard code for now
//     tempvar coef_ = 100;
//     tempvar intercept_ = 23;

// // let calculation = coef_ * input + intercept_;
//     let _
//     caller_address_solution.write(sender_address, calculation);
//     return (output = calculation);

// // the prediction is onchain, anyone can run it, on user solution storage
//     // what if the prediction is too much for onchain???
// }
