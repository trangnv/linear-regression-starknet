%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address

@storage_var
func number_of_features() -> (res: felt) {
}

@storage_var
func coef_0_storage(address: felt) -> (coef_0: felt) {
}

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
    pedersen_ptr: HashBuiltin*,
}(data_ptr: felt*, length: felt) -> (result: felt) {
  alloc_locals;

  if (length == 2) {
        let (result) = hash2{hash_ptr=pedersen_ptr}(x=[data_ptr], y=[data_ptr + 1]);
        return (result=result);
    } else {
        let (result_int) = hash2{hash_ptr=pedersen_ptr}(x=[data_ptr], y=[data_ptr+1]);
        let (result) = cal_hash(result_int=result_int, data_ptr=data_ptr+2, length=length-2);
        return (result=result);
    }
}

func cal_hash{
    pedersen_ptr: HashBuiltin*,
}(result_int : felt, data_ptr : felt*, length: felt) -> (result : felt) {
    if(length == 0) {
        return (result=result_int);
    } else {
        let (result_int2) = hash2{hash_ptr=pedersen_ptr}(x=result_int, y=[data_ptr]);
        let (result) = cal_hash(result_int=result_int2, data_ptr=data_ptr+1, length=length-1);
        return (result=result);
    }
    
}

@view
func pedersen_hash_submission{
    pedersen_ptr: HashBuiltin*,
}(coefs_len: felt, coefs: felt*, intercept_: felt) -> (hashed_value: felt) {
    alloc_locals;
    let (coefs_hashed_value) = cal_pedersen_hash_chain(coefs, coefs_len);
    let (hashed_value) = hash2{hash_ptr=pedersen_ptr}(coefs_hashed_value, intercept_);
    return (hashed_value=hashed_value);
}

@external
func commit_hash{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(hash: felt) {
    let (caller_address) = get_caller_address();
    hash_storage.write(caller_address, hash);
    return ();
}

@external
func reveal{
    syscall_ptr: felt*, 
    pedersen_ptr: HashBuiltin*, 
    range_check_ptr, bitwise_ptr: BitwiseBuiltin*,
}(array_len: felt, array: felt*, intercept: felt) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_hash) = hash_storage.read(caller_address);

    with_attr error_message("You should first commit something") {
        assert committed_hash = 0;
    }

    // check array_len == number_of_features
    let (n) = number_of_features.read();
    with_attr error_message("Wrong number of coefficient") {
        assert array_len = n;
    }

    let (current_hash) = pedersen_hash_submission(array_len, array, intercept);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_hash;
    }

    let (local new_array) = alloc();
    _save_coefs(array=array, new_array=new_array, length=array_len); // save coefs to the new_array
    coef_0_storage.write(caller_address,[new_array]); // coef_0 = [new_array] and the other coefs are followed

    intercept_storage.write(caller_address,intercept); // store intercept

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

