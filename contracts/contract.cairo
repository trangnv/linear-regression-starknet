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
    coef_: felt,
    intercept_: felt,
}

@storage_var
func hash_storage(address: felt) -> (hashed_response: Uint256) {
}

@storage_var
func solution_storage(address: felt) -> (solution: Solution) {
}


@view
func view_get_keccak_hash{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*
}(coef_: felt, intercept_: felt) -> (hashed_value: Uint256) {
    alloc_locals;
    let (local keccak_ptr_start) = alloc();
    let keccak_ptr = keccak_ptr_start;
    let (local arr: felt*) = alloc();
    assert arr[0] = coef_;
    assert arr[1] = intercept_;
    let (hashed_value) = keccak_felts{keccak_ptr=keccak_ptr}(2, arr);
    finalize_keccak(keccak_ptr_start=keccak_ptr_start, keccak_ptr_end=keccak_ptr);
    return (hashed_value,);
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

