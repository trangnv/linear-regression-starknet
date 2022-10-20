// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak

// from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE, FALSE


struct Solution {
    number_of_features: felt,
    coef_s: felt*,
    intercept_: felt
}

@storage_var
func hash_storage(address: felt) -> (hashed_response: Uint256) {
}

@storage_var
func solution_storage(address: felt) -> (solution: Solution) {
}

// Computes the Pedersen hash chain on an array of size `length` starting from `data_ptr`.
func pedersen_hash_chain{hash_ptr: HashBuiltin*}(data_ptr: felt*, length: felt) -> (result: felt) {
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

func cal_hash{hash_ptr: HashBuiltin*}(result_int : felt, data_ptr : felt*, length: felt) -> (result : felt) {
    if(length == 0) {
        return (result=result_int);
    } else {
        let (result_int2) = hash2(x=result_int, y=[data_ptr]);
        let (result) = cal_hash(result_int=result_int2, data_ptr=data_ptr+1, length=length-1);
        return (result=result);
    }
    
}

@view
func view_pedersen_hash_chain{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(number_of_features: felt, coefs: felt*, intercept_: felt) -> (hashed_value: felt) {
    alloc_locals;
    let (coefs_hashed_value) = pedersen_hash_chain(coefs, number_of_features);
    hashed_value = hash2(coefs_hashed_value, intercept_);
    return (hashed_value=hashed_value);
}


@view
func view_solution{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_address: felt) -> (
    output : Solution
){
    let (output) = solution_storage.read(user_address);
    return (output = output);
}

@external
func commit_hash{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(hash: Uint256) {
    let (caller_address) = get_caller_address();
    hash_storage.write(caller_address, hash);
    return ();
}

@external
func reveal{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(coef_: felt, intercept_: felt) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_hash) = hash_storage.read(caller_address);
    let (is_eq_to_zero) = uint256_eq(committed_hash, Uint256(0, 0));
    with_attr error_message("You should first commit something") {
        assert is_eq_to_zero = FALSE;
    }
    let (current_hash) = view_get_keccak_hash(coef_, intercept_);
    let (is_eq) = uint256_eq(current_hash, committed_hash);
    with_attr error_message("You are trying to cheat") {
        assert is_eq = TRUE;
    }
    solution_storage.write(caller_address, Solution(coef_, intercept_));

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

