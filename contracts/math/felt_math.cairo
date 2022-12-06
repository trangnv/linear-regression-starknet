// %builtins output


func pow(base: felt, exp: felt) -> (res: felt) {
    if (exp == 0) {
        return (res=1);
    }

    let (res) = pow(base=base, exp=exp - 1);
    return (res=res * base);
}