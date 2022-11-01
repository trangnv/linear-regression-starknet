%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.libraries.types.data_types import DataTypes

// number of features
@storage_var
func ContractStorage_number_features() -> (n: felt) {
}

// store the hash of user model
@storage_var
func ContractStorage_model_hash(address: felt) -> (model_hash: felt) {
}

// store the real model
@storage_var
func ContractStorage_model(address) -> (model: DataTypes.PolynomialRegressionModel) {
}

// store root hash of markle root of test data submission
@storage_var
func ContractStorage_merkle_root_test_data(address: felt) -> (root: felt) {
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

    func model_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (model: DataTypes.PolynomialRegressionModel) {
        let (model) = ContractStorage_model.read(address);
        return (model,);
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

    func model_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, model: DataTypes.PolynomialRegressionModel
    ) {
        ContractStorage_model.write(address, model);
        return();
    }

    func merkle_root_test_data_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, root: felt
    ) {
        ContractStorage_merkle_root_test_data.write(address, root);
        return();
    }
}
