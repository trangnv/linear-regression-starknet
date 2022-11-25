from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
// from contracts.libraries.types.data_types import DataTypes

func compute_hash_struct_array{pedersen_ptr: HashBuiltin*}(
    struct_len: felt, struct_ptr: felt*
) -> (res: felt) {
    alloc_locals;
    if (struct_len == 1) {
        let (res) = _compute_hash_struct(struct_ptr);
        return (res=res);
    } else {
        let (res_int) = compute_hash_struct_array(struct_len - 1, struct_ptr + 1);
        // let tmp = [struct_ptr];
        let (res) = _compute_hash_struct(struct_ptr);
        return (res=res);
    }
}
// compute pedersen hash of a struct
func _compute_hash_struct{pedersen_ptr: HashBuiltin*}(
    struct_ptr:felt*
) -> (res: felt) {
    let (res) = _compute_pedersen_hash_chain(struct_ptr, 5);
    return (res=res);
}

// Computes the Pedersen hash chain on an array of size `length` starting from `data_ptr`.
func _compute_pedersen_hash_chain{pedersen_ptr: HashBuiltin*}(
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