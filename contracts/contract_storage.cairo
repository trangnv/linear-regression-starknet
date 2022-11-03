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
func ContractStorage_model(address) -> (res:(expression_len: felt, expression: DataTypes.Expression5V)) {
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
    ) -> (expression_len:felt, expression: DataTypes.Expression5V*) {
        let (expression_len, expression) = ContractStorage_model.read(address);
        return (expression_len, expression);
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
        address: felt, expression_len: felt, expression: DataTypes.Expression5V
    ) {
        ContractStorage_model.write(address, (expression_len, expression));
        return();
    }

    func merkle_root_test_data_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, root: felt
    ) {
        ContractStorage_merkle_root_test_data.write(address, root);
        return();
    }
}
