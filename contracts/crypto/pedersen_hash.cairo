from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2


// Computes the Pedersen hash chain on an array of size `length` starting from `data_ptr`.
func cal_pedersen_hash_chain{pedersen_ptr: HashBuiltin*}(data_ptr: felt*, length: felt) -> (
    result: felt
) {
    alloc_locals;

    if (length == 2) {
        let (result) = hash2{hash_ptr=pedersen_ptr}(x=[data_ptr], y=[data_ptr + 1]);
        return (result=result);
    } else {
        let (result_int) = hash2{hash_ptr=pedersen_ptr}(x=[data_ptr], y=[data_ptr + 1]);
        let (result) = cal_hash(result_int=result_int, data_ptr=data_ptr + 2, length=length - 2);
        return (result=result);
    }
}

func cal_hash{pedersen_ptr: HashBuiltin*}(result_int: felt, data_ptr: felt*, length: felt) -> (
    result: felt
) {
    if (length == 0) {
        return (result=result_int);
    } else {
        let (result_int2) = hash2{hash_ptr=pedersen_ptr}(x=result_int, y=[data_ptr]);
        let (result) = cal_hash(result_int=result_int2, data_ptr=data_ptr + 1, length=length - 1);
        return (result=result);
    }
}