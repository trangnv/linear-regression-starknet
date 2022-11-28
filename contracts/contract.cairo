%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.starknet.common.syscalls import get_caller_address

from contracts.contract_storage import ContractStorage
from contracts.crypto.pedersen_hash import cal_pedersen_hash_chain
from contracts.crypto.merkle import cal_merkle_root

from contracts.math.math_cmp import _is_lt_felt

// return perdersen hash with input is model which is an array of felt
@view
func view_pedersen_hash_chain{pedersen_ptr: HashBuiltin*}(
    mononomial_len: felt, mononomial: felt*,
) -> (hashed_value: felt) {
    alloc_locals;
    let (hashed_value) = cal_pedersen_hash_chain(mononomial, mononomial_len);
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

    let (current_hash) = view_pedersen_hash_chain(mononomial_len, mononomial);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_hash;
    }

    // save competitor, increase competitors_count
    // ContractStorage.competitors_count_write ++
    let (local competitors_count) = ContractStorage.competitors_count_read();
    ContractStorage.competitors_count_write(competitors_count+1);
    // ContractStorage.polynomial_len_write: naming is bad here, need to change

    // save model len
    ContractStorage.polynomial_len_write(caller_address, mononomial_len);

    // save model
    save_model(caller_address, mononomial_len, mononomial);
    return ();
}

func save_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    address: felt, mononomial_len: felt, mononomial: felt*
) {
    alloc_locals;
    if (mononomial_len==0) {
        return ();
    }
    ContractStorage.mononomial_write(address, mononomial_len, [mononomial]);

    return save_model(address, mononomial_len-1, mononomial+1);

}

@external
func reveal_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    x_len: felt, x: felt*, y_len: felt, y: felt*
) {

    alloc_locals;
    let (caller_address) = get_caller_address();
    let (committed_merkle_root) = ContractStorage.merkle_root_test_data_read(caller_address);

    with_attr error_message("You should first commit something") {
        assert committed_merkle_root = 0;
    }
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
