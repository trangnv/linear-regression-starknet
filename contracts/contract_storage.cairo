%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
// from contracts.libraries.types.data_types import DataTypes


// store the hash of user model
@storage_var
func ContractStorage_model_hash(address: felt) -> (model_hash: felt) {
}

// store the number of term, real model
@storage_var
func ContractStorage_polynomial_len(address: felt) -> (res: felt) {
}

@storage_var
func ContractStorage_monomial(address, exponent) -> (res: felt) {
}


// store root hash of markle root of test data submission
@storage_var
func ContractStorage_merkle_root_test_data(address: felt) -> (root: felt) {
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
        ContractStorage_monomial.write(address, exponent, res);
        return();
    }

    func merkle_root_test_data_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, root: felt
    ) {
        ContractStorage_merkle_root_test_data.write(address, root);
        return();
    }
}
