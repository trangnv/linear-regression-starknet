// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address


// struct Prediction
@storage_var
func user_prediction_output(user_address: felt) -> (output: felt) {
}
@view
func view_user_prediction_output{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    user_address: felt) -> (
    output : felt
){
    return user_prediction_output.read(user_address);
}

@external
func predict{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(input: felt) -> (
    output: felt
) {
    alloc_locals;
    let (sender_address) = get_caller_address();
    // load the models, hard code for now
    tempvar coef_ = 100;
    tempvar intercept_ = 23;

    let calculation = coef_ * input + intercept_;
    user_prediction_output.write(sender_address, calculation);
    return (output = calculation);
}

