from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

// Computes the Pedersen hash chain on an array of size `length` starting from `data_ptr`.
func cal_pedersen_hash_chain{pedersen_ptr: HashBuiltin*}(
    data_ptr: felt*, length: felt
) -> (res: felt) {
    alloc_locals;

    if (length == 2) {
        let (res) = hash2{hash_ptr=pedersen_ptr}(x=[data_ptr], y=[data_ptr + 1]);
        return (res=res);
    } else {
        let (res_int) = hash2{hash_ptr=pedersen_ptr}(x=[data_ptr], y=[data_ptr + 1]);
        let (res) = _compute_hash(res_int=res_int, data_ptr=data_ptr + 2, length=length - 2);
        return (res=res);
    }
}

func _compute_hash{pedersen_ptr: HashBuiltin*}(res_int: felt, data_ptr: felt*, length: felt) -> (
    res: felt
) {
    if (length == 0) {
        return (res=res_int);
    } else {
        let (res_int2) = hash2{hash_ptr=pedersen_ptr}(x=res_int, y=[data_ptr]);
        let (res) = _compute_hash(res_int=res_int2, data_ptr=data_ptr + 1, length=length - 1);
        return (res=res);
    }
}