from starkware.cairo.common.math_cmp import is_le_felt
from starkware.cairo.common.bool import TRUE, FALSE

func _is_lt_felt{range_check_ptr}(a: felt, b: felt) -> felt {
    if (a == b) {
        return FALSE;
    }
    return is_le_felt(a, b);
}