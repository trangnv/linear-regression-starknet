%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func ContractStorage_submission_hash(address: felt) -> (submission_hash: felt) {
}

@storage_var
func ContractStorage_model_hash(address: felt) -> (submission: felt) {
}

// number of features
@storage_var
func ContractStorage_number_features() -> (n: felt) {
}


// store root hash of markle root of test data
@storage_var
func ContractStorage_merkle_root(address: felt, test_data_id: felt) -> (root: felt) {
}

namespace ContractStorage {
    //
    // Reads
    //
    func number_features_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        ) -> (n: felt) {
        let (n) = ContractStorage_number_features.read();
        return (n,);
    }

    func model_hash_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (res: felt) {
        let (res) = ContractStorage_model_hash.read(address);
        return(res,);
    }


    //
    // Writes
    //
    func number_features_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        n: felt
    ) {
        ContractStorage_number_features.write(n);
        return ();
    }

    func model_hash_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, hash_value: felt
    ) {
        ContractStorage_model_hash.write(address, hash_value);
        return();
    }
}
