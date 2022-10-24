// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
// from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak
from starkware.cairo.common.hash import hash2


// from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address
// from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE, FALSE

@storage_var
func number_of_features() -> (res: felt) {
}

// @storage_var
// func coef_0_storage(address: felt) -> (coef_0: felt) {
// }

@storage_var
func intercept_storage(address: felt) -> (res: felt) {
}

@storage_var
func hash_storage(address: felt) -> (hashed_response: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _number_of_features: felt
) {
    number_of_features.write(_number_of_features);
    return ();
}

// Computes the Pedersen hash chain on an array of size `length` starting from `data_ptr`.
func cal_pedersen_hash_chain{
    hash_ptr: HashBuiltin*
}(data_ptr: felt*, length: felt) -> (result: felt) {
  alloc_locals;

  if (length == 2) {
        let (result) = hash2(x=[data_ptr], y=[data_ptr + 1]);
        return (result=result);
    } else {
        let (result_int) = hash2(x=[data_ptr], y=[data_ptr+1]);
        let (result) = cal_hash(result_int=result_int, data_ptr=data_ptr+2, length=length-2);
        return (result=result);
    }
}

func cal_hash{
    hash_ptr: HashBuiltin*
}(result_int : felt, data_ptr : felt*, length: felt) -> (result : felt) {
    if(length == 0) {
        return (result=result_int);
    } else {
        let (result_int2) = hash2(x=result_int, y=[data_ptr]);
        let (result) = cal_hash(result_int=result_int2, data_ptr=data_ptr+1, length=length-1);
        return (result=result);
    }
    
}

// @view
func pedersen_hash_chain{
    hash_ptr: HashBuiltin*,
}(coefs_len: felt, coefs: felt*, intercept_: felt) -> (hashed_value: felt) {
    alloc_locals;
    let (coefs_hashed_value) = cal_pedersen_hash_chain(coefs, coefs_len);
    let (hashed_value) = hash2(coefs_hashed_value, intercept_);
    return (hashed_value=hashed_value);
}


@external
func commit_hash{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(hash: felt) {
    let (caller_address) = get_caller_address();
    hash_storage.write(caller_address, hash);
    return ();
}

// @external
func reveal{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*,
    hash_ptr: HashBuiltin*
}(array_len: felt, array: felt*, intercept: felt) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_hash) = hash_storage.read(caller_address);

    // let (is_eq_to_zero) = uint256_eq(committed_hash, Uint256(0, 0));
    with_attr error_message("You should first commit something") {
        assert committed_hash = 0;
    }

    // check len_arr == number_of_features
    let (n) = number_of_features.read();
    with_attr error_message("Wrong number of coefficient") {
        assert array_len = n;
    }

    let (current_hash) = _pedersen_hash_chain(array_len, array, intercept);
    // let (is_eq) = uint256_eq(current_hash, committed_hash);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_hash;
    }

    let (local new_array) = alloc(); // need to store this some how, maybe cast first coef
    _save_coefs(array=array, new_array=new_array, length=array_len);
    intercept_storage.write(caller_address,intercept);
    return ();
}

func _save_coefs{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(array: felt*, new_array: felt*, length: felt) {
    if (length == 0) {
        return ();
    }
    assert [new_array] = [array];
    _save_coefs(array=array + 1, new_array=new_array + 1, length=length - 1);
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

//     // let calculation = coef_ * input + intercept_;
//     let _
//     caller_address_solution.write(sender_address, calculation);
//     return (output = calculation);

//     // the prediction is onchain, anyone can run it, on user solution storage
//     // what if the prediction is too much for onchain???
// }

