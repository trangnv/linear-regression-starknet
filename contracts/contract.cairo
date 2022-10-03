// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc

// struct Prediction
@storage_var
func user_prediction_output(user_address: felt, prediction_id: felt) -> (
    output_array_len: felt, output_array: felt*) {
}
// Starts the inference computation.
// @internal
func predict{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    input_array_len: felt, input_array: felt*, output_array_len: felt, output_array: felt*
) -> () {
    alloc_locals;
    // load the models, hard code for now
    tempvar coef_ = 9731;
    tempvar intercept_ = 1;

    if (input_array_len == 0) {
        return ();
    }
    // let squared_item = [array] * [array]
    // assert [squared_array] = squared_item
    let output_item = coef_ * [input_array] + intercept_;
    let output_array_len = input_array_len;
    assert [output_array] = output_item;
    return predict(input_array_len - 1, input_array + 1,  output_array_len -1, output_array + 1);
}

@external
func get_prediction{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    input_array_len: felt, input_array: felt*
) -> (
    output_array_len: felt, output_array: felt*
){
    alloc_locals;
    let (local output_array : felt*) = alloc();
    let output_array_len = input_array_len;

    predict(input_array_len, input_array, input_array_len, output_array);
    return (output_array_len = output_array_len, output_array = output_array);
}

// @vi
