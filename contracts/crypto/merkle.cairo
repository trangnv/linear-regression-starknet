from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le_felt
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.bool import TRUE


func cal_merkle_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leafs_len: felt, leafs: felt*
) -> (res: felt) {
    alloc_locals;
    if (leafs_len == 1) {
        return (res=[leafs]);
    }
    let (local new_leafs) = alloc();
    merkle_build_body{new_leafs=new_leafs, leafs=leafs, stop=leafs_len}(0);

    let (q, r) = unsigned_div_rem(leafs_len, 2);
    return cal_merkle_root(q + r, new_leafs);
}

func merkle_build_body{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    new_leafs: felt*,
    leafs: felt*,
    stop: felt,
}(i: felt) {
    let stop_loop = is_le_felt(stop, i);
    if (stop_loop == TRUE) {
        return ();
    }
    if (i == stop - 1) {
        let (n) = hash_sorted{hash_ptr=pedersen_ptr}([leafs + i], [leafs + i]);
        tempvar range_check_ptr = range_check_ptr;
    } else {
        let (n) = hash_sorted{hash_ptr=pedersen_ptr}([leafs + i], [leafs + i + 1]);
        tempvar range_check_ptr = range_check_ptr;
    }
    assert [new_leafs + i / 2] = n;
    return merkle_build_body(i + 2);
}

func hash_sorted{hash_ptr: HashBuiltin*, range_check_ptr}(a, b) -> (res: felt) {
    let le = is_le_felt(a, b);

    if (le == 1) {
        let (n) = hash2{hash_ptr=hash_ptr}(a, b);
    } else {
        let (n) = hash2{hash_ptr=hash_ptr}(b, a);
    }
    return (res=n);
}