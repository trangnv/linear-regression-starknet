%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address

from contracts.contract_storage import ContractStorage
from contracts.crypto.pedersen_hash import cal_pedersen_hash_chain
from contracts.crypto.merkle import cal_merkle_root, hash_sorted
from contracts.libraries.types.data_types import DataTypes

from contracts.math.math_cmp import _is_lt_felt
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.pow import pow
// from contracts.math.felt_math import pow
// func pow(base: felt, exp: felt) -> (res: felt) {
//     if (exp == 0) {
//         return (res=1);
//     }

//     let (res) = pow(base=base, exp=exp - 1);
//     return (res=res * base);
// }


@view
func view_model_commit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (commit: felt){
    let (commit) = ContractStorage.model_commit_read(address);
    return(commit=commit);
}

@view
func view_test_data_commit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (commit: felt){
    let (commit) = ContractStorage.test_data_commit_read(address);
    return(commit=commit);
}

@view
func view_test_data_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (len: felt){
    let (len) = ContractStorage.test_data_len_read();
    return(len=len);
}

@view
func view_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    i: felt
) -> (data: DataTypes.DataPoint){
    //check i < len
    alloc_locals;
    let (len) = ContractStorage.test_data_len_read();
    let res_1 = _is_lt_felt(i, len);
    with_attr error_message("Out of range") {
        assert res_1 = TRUE;
    }
    let (data) = ContractStorage.test_data_read(i);
    return(data=data);
}
@view
func view_model_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (len: felt){
    let (len) = ContractStorage.model_len_read(address);
    return(len=len);
}

@view
func view_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt, exponent: felt
) -> (weight: felt){
    let (weight) = ContractStorage.model_read(address, exponent);
    return(weight=weight);
}
@view
func view_competitor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    competitor_id: felt
) -> (competitor: felt){
    let (competitor) = ContractStorage.competitors_list_read(competitor_id);
    return(competitor=competitor);
}

@external
func commit_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(commit: felt) {
    let (caller_address) = get_caller_address();
    ContractStorage.model_commit_write(caller_address, commit);
    return ();
}

@external
func commit_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    commit: felt
) {
    let (caller_address) = get_caller_address();
    ContractStorage.test_data_commit_write(caller_address, commit);
    return ();
}

@external
func reveal_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    model_len: felt, model: felt*
) {
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_model) = ContractStorage.model_commit_read(caller_address);
    let is_eq_to_zero = is_not_zero(committed_model); // Returns 1 if value != 0. Returns 0 otherwise.
    
    with_attr error_message("You should first commit something") {
        assert is_eq_to_zero = 1;
    }

    let (current_hash) = cal_pedersen_hash_chain(model, model_len);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_model;
    }

    // save competitor, increase competitors_count
    let (local competitors_count) = ContractStorage.competitors_count_read();
    ContractStorage.competitors_list_write(competitors_count, caller_address);
    ContractStorage.competitors_count_write(competitors_count+1);



    // save model len
    ContractStorage.model_len_write(caller_address, model_len);

    // save model
    save_model(caller_address, model_len, model);
    return ();
}

func save_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    address: felt, len: felt, weight: felt*
) {
    alloc_locals;
    let (model_len) = ContractStorage.model_len_read(address);
    if (len==0) {
        return ();
    }
    ContractStorage.model_write(address, model_len - len, [weight]);

    return save_model(address, len-1, weight+1);

}


@view
func view_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    x_len: felt, x: felt*, y_len: felt, y: felt*
) -> (root: felt) {
    alloc_locals;
    let (merkle_root_x) = cal_merkle_root(x_len, x);
    let (merkle_root_y) = cal_merkle_root(y_len, y);

    let (local array_tmp) = alloc();
    assert [array_tmp] = merkle_root_x;
    assert [array_tmp + 1] = merkle_root_y;

    let (current_merkle_root) = cal_merkle_root(2, array_tmp);
    return(root = current_merkle_root);
}
@external
func reveal_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    x_len: felt, x: felt*, y_len: felt, y: felt*
) {
    with_attr error_message("X and Y array need to have same size") {
        assert x_len = y_len;
    }
    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_merkle_root) = ContractStorage.test_data_commit_read(caller_address);
    let is_eq_to_zero = is_not_zero(committed_merkle_root); // Returns 1 if value != 0. Returns 0 otherwise.
    
    with_attr error_message("You should first commit something") {
        assert is_eq_to_zero = 1;
    }

    let (merkle_root_x) = cal_merkle_root(x_len, x);
    let (merkle_root_y) = cal_merkle_root(y_len, y);

    let (local array_tmp) = alloc();
    assert [array_tmp] = merkle_root_x;
    assert [array_tmp + 1] = merkle_root_y;

    let (current_merkle_root) = cal_merkle_root(2, array_tmp);

    with_attr error_message("You are trying to cheat") {
        assert current_merkle_root = committed_merkle_root;
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

func evaluation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(){
    // 
    // _evaluation(address)
    // so need a competitors storage to store all competitors Storage_competitor(i) -> address
    // address = competitor(i)
    // ContractStorage_polynomial_len(address)
    // e = ContractStorage_mononomial(address, exponent)
    // x = X[]
    // PREDICTION[] = sum(e * x^exponent)
    // evaluation(address) = f(Y, PREDICTION)


    return();
}

@view
func cal_yhat{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    competitor_id: felt, i: felt  // i: data point
// ) -> (x: felt, model_len: felt) {
) -> (yhat: felt) {

    // yhat = X[i] * 
    // for weight, exponent in enumerate(model)
    // yhat += weight * x^exponent
    alloc_locals;
    let (data) = ContractStorage.test_data_read(i);
    let x = data.x;
    let (competitor_address) = ContractStorage.competitors_list_read(competitor_id);
    let (model_len) = ContractStorage.model_len_read(competitor_address);
    let (yhat) = cal_polynomial(competitor_address, x, model_len);
    return(yhat=yhat);
    // return(x=x, model_len=model_len);
}

func cal_polynomial{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    competitor_address: felt, x: felt, len: felt
) -> (res: felt) {
    alloc_locals;
    if (len==1) {
        let (res)=ContractStorage.model_read(competitor_address,0);
        return (res=res);
    }

    let (weight) = ContractStorage.model_read(competitor_address, len-1);
    let (p) = pow(x, len-1);
    let term = weight * p;

    let (rest) = cal_polynomial(competitor_address,x,len-1);
    return (res=term+rest);
}

// func cal_polynomial{output_ptr: felt*}(
//     x: felt, len: felt, model: felt*
// ) -> (res: felt) {
//     alloc_locals;
//     if (len==1) {
//         let res=[model];
//         return (res=res);
//     }

//     let weight = model[len-1];
//     let (p) = pow(x, len-1);
//     let term = weight * p;

//     let (rest) = cal_polynomial(x,len-1, model);
//     return (res=term+rest);
// }
