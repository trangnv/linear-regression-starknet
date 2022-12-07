%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.pow import pow
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp

from openzeppelin.access.accesscontrol.library import AccessControl

from contracts.math.math_cmp import _is_lt_felt
from contracts.competition.polynomial_lr_storage import PolyLinearRegressionStorage
from contracts.crypto.pedersen_hash import cal_pedersen_hash_chain
from contracts.crypto.merkle import cal_merkle_root, hash_sorted
from contracts.libraries.data_types import DataTypes
from contracts.libraries.constants import ORGANIZER_ROLE, STAGE_1_TIME


@view
func view_model_commit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (commit: felt){
    let (commit) = PolyLinearRegressionStorage.model_commit_read(address);
    return(commit=commit);
}

@view
func view_test_data_commit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (commit: felt){
    let (commit) = PolyLinearRegressionStorage.test_data_commit_read(address);
    return(commit=commit);
}

@view
func view_test_data_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (len: felt){
    let (len) = PolyLinearRegressionStorage.test_data_len_read();
    return(len=len);
}

@view
func view_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    i: felt
) -> (data: DataTypes.DataPoint){
    //check i < len
    alloc_locals;
    let (len) = PolyLinearRegressionStorage.test_data_len_read();
    let cmp = _is_lt_felt(i, len);
    with_attr error_message("Out of range") {
        assert cmp = TRUE;
    }
    let (data) = PolyLinearRegressionStorage.test_data_read(i);
    return(data=data);
}
@view
func view_model_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (len: felt){
    let (len) = PolyLinearRegressionStorage.model_len_read(address);
    return(len=len);
}

@view
func view_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt, exponent: felt
) -> (weight: felt){
    let (weight) = PolyLinearRegressionStorage.model_read(address, exponent);
    return(weight=weight);
}
@view
func view_competitor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    competitor_id: felt
) -> (competitor: felt){
    let (competitor) = PolyLinearRegressionStorage.competitors_list_read(competitor_id);
    return(competitor=competitor);
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(){
    PolyLinearRegressionStorage.stage_write(0);
    let (caller_address) = get_caller_address();
    AccessControl.initializer();
    AccessControl._grant_role(ORGANIZER_ROLE, caller_address);
    return();
}

@external
func commit_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(commit: felt) {
    // check timestamp
    alloc_locals;
    let (current_timestamp) = get_block_timestamp();
    let (stage1_timestamp) = PolyLinearRegressionStorage.stage1_timestamp_read();
    let cmp = _is_lt_felt(current_timestamp, stage1_timestamp);
    with_attr error_message("Not in commit model stage") {
        assert cmp = TRUE;
    }
    let (caller_address) = get_caller_address();
    PolyLinearRegressionStorage.model_commit_write(caller_address, commit);
    return ();
}

@external
func commit_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    commit: felt
) {
    // check role organizer
    AccessControl.assert_only_role(ORGANIZER_ROLE);

    // check stage == 0
    let (stage) = PolyLinearRegressionStorage.stage_read();
    with_attr error_message("Only in stage 0") {
        assert stage = 1;
    }
    let (caller_address) = get_caller_address();
    PolyLinearRegressionStorage.test_data_commit_write(caller_address, commit);

    // change stage =1
    PolyLinearRegressionStorage.stage_write(1);

    // write stage1_timestamp (finishing commit time)
    let (timestamp) = get_block_timestamp();
    PolyLinearRegressionStorage.stage1_timestamp_write(timestamp + STAGE_1_TIME);
    return ();
}

@external
func reveal_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    model_len: felt, model: felt*
) {
    alloc_locals;
    // check stage == 2
    let (stage) = PolyLinearRegressionStorage.stage_read();
    with_attr error_message("Only in stage 2") {
        assert stage = 2;
    }
    
    let (caller_address) = get_caller_address();
    let (committed_model) = PolyLinearRegressionStorage.model_commit_read(caller_address);
    let is_eq_to_zero = is_not_zero(committed_model); // Returns 1 if value != 0. Returns 0 otherwise.
    
    with_attr error_message("You should first commit something") {
        assert is_eq_to_zero = 1;
    }

    let (current_hash) = cal_pedersen_hash_chain(model, model_len);

    with_attr error_message("You are trying to cheat") {
        assert current_hash = committed_model;
    }

    // save competitor, increase competitors_count
    let (local competitors_count) = PolyLinearRegressionStorage.competitors_count_read();
    PolyLinearRegressionStorage.competitors_list_write(competitors_count, caller_address);
    PolyLinearRegressionStorage.competitors_count_write(competitors_count+1);

    // save model len
    PolyLinearRegressionStorage.model_len_write(caller_address, model_len);

    // save model
    save_model(caller_address, model_len, model);
    return ();
}

func save_model{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    address: felt, len: felt, weight: felt*
) {
    alloc_locals;
    let (model_len) = PolyLinearRegressionStorage.model_len_read(address);
    if (len==0) {
        return ();
    }
    PolyLinearRegressionStorage.model_write(address, model_len - len, [weight]);

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
    alloc_locals;
    // assert ORGANIZER_ROLE just to be safe
    AccessControl.assert_only_role(ORGANIZER_ROLE);

    // assert stage 1 ended
    let (current_timestamp) = get_block_timestamp();
    let (stage1_timestamp) = PolyLinearRegressionStorage.stage1_timestamp_read();
    let cmp = _is_lt_felt(stage1_timestamp, current_timestamp);
    with_attr error_message("Not in reveal test data stage, stage 1 not finished yet") {
        assert cmp = TRUE;
    }

    with_attr error_message("X and Y array need to have same size") {
        assert x_len = y_len;
    }
    let (caller_address) = get_caller_address();
    let (committed_merkle_root) = PolyLinearRegressionStorage.test_data_commit_read(caller_address);
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

    PolyLinearRegressionStorage.test_data_len_write(x_len);
    save_test_data(x_len, x, y);

    // change stage to 2
    PolyLinearRegressionStorage.stage_write(2);
    return();
}

func save_test_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    array_len: felt, x: felt*, y: felt*
) {
    if (array_len==0) {
        PolyLinearRegressionStorage.test_data_write(array_len, x[0], y[0]);
        return ();
    }
    PolyLinearRegressionStorage.test_data_write(array_len-1, x[array_len-1], y[array_len-1]);
    return save_test_data(array_len-1, x, y);

}

func evaluation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(){
    // 
    // _evaluation(address)
    // so need a competitors storage to store all competitors Storage_competitor(i) -> address
    // address = competitor(i)
    // PolyLinearRegressionStorage_polynomial_len(address)
    // e = PolyLinearRegressionStorage_mononomial(address, exponent)
    // x = X[]
    // PREDICTION[] = sum(e * x^exponent)
    // evaluation(address) = f(Y, PREDICTION)
    // use several metrics, for suprise fun 
    // max error
    // mean_absolute_error
    // mean_squared_error


    return();
}

@view
func cal_yhat{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    competitor_id: felt, i: felt  // i: data point
) -> (yhat: felt) {
    alloc_locals;
    let (data) = PolyLinearRegressionStorage.test_data_read(i);
    let x = data.x;
    let (competitor_address) = PolyLinearRegressionStorage.competitors_list_read(competitor_id);
    let (model_len) = PolyLinearRegressionStorage.model_len_read(competitor_address);
    let (yhat) = cal_polynomial(competitor_address, x, model_len);
    return(yhat=yhat);
}

func cal_polynomial{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    competitor_address: felt, x: felt, len: felt
) -> (res: felt) {
    alloc_locals;
    if (len==1) {
        let (res)=PolyLinearRegressionStorage.model_read(competitor_address,0);
        return (res=res);
    }

    let (weight) = PolyLinearRegressionStorage.model_read(competitor_address, len-1);
    let (p) = pow(x, len-1);
    let term = weight * p;

    let (rest) = cal_polynomial(competitor_address,x,len-1);
    return (res=term+rest);
}
