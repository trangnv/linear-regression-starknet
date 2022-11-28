%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin


// store the hash of user model
@storage_var
func ContractStorage_model_hash(address: felt) -> (model_hash: felt) {
}

// store the number of term, real model
@storage_var
func ContractStorage_polynomial_len(address: felt) -> (res: felt) {
}

@storage_var
func ContractStorage_mononomial(address, exponent) -> (res: felt) {
}

// store root hash of markle root of test data submission
@storage_var
func ContractStorage_merkle_root_test_data(address: felt) -> (root: felt) {
}

@storage_var
func ContractStorage_test_data_len() -> (res: felt) {
}
@storage_var
func ContractStorage_x(i: felt) -> (res: felt) {
}
@storage_var
func ContractStorage_y(i: felt) -> (res: felt) {
}

@storage_var
func ContractStorage_competitors_count() -> (count: felt) {
}

@storage_var
func ContractStorage_competitors_list(competitor_id) -> (address: felt) {
}




namespace ContractStorage {
    //
    // Reads
    //

    func model_hash_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (res: felt) {
        let (res) = ContractStorage_model_hash.read(address);
        return(res,);
    }

    func polynomial_len_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (number_of_term: felt) {
        let (term_len, term) = ContractStorage_polynomial_len.read(address);
        return (term_len);
    }

    func merkle_root_test_data_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (root: felt) {
        let (root) = ContractStorage_merkle_root_test_data.read(address);
        return(root,);
    }

    func test_data_len_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
         res: felt
    ){
        let (res) = ContractStorage_test_data_len.read();
        return(res=res);
    }

    func test_data_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        i: felt
    ) -> (x_i: felt, y_i: felt) {
        let (x_i) = ContractStorage_x.read(i);
        let (y_i) = ContractStorage_y.read(i);
        return (x_i=x_i, y_i=y_i);
    }

    func competitors_count_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        count: felt
    ){
        let (count) = ContractStorage_competitors_count.read();
        return (count=count);
    }


    //
    // Writes
    //

    func model_hash_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, hash_value: felt
    ) {
        ContractStorage_model_hash.write(address, hash_value);
        return();
    }


    func polynomial_len_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, len: felt
    ) {
        ContractStorage_polynomial_len.write(address, len);
        return();
    }

    func mononomial_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, exponent: felt, res: felt
    ) {
        ContractStorage_mononomial.write(address, exponent, res);
        return();
    }

    func merkle_root_test_data_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, root: felt
    ) {
        ContractStorage_merkle_root_test_data.write(address, root);
        return();
    }

    func test_data_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        i: felt, x: felt, y: felt
    ) {
        ContractStorage_x.write(i,x);
        ContractStorage_y.write(i,y);
        return();
    }

    func test_data_len_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        test_data_len: felt
    ) {
        ContractStorage_test_data_len.write(test_data_len);
        return();
    }

    func competitors_count_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        count: felt
    ) {
        ContractStorage_competitors_count.write(count);
    }
    

    // func y_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    //     i: felt, res: felt
    // ) {
    //     ContractStorage_y.write(i,res);
    //     return();
    // }
}
