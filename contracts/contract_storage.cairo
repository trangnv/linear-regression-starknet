%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.libraries.types.data_types import DataTypes

@storage_var
func ContractStorage_model_commit(address: felt) -> (commit: felt) {
}

@storage_var
func ContractStorage_model_len(address: felt) -> (len: felt) {
}

@storage_var
func ContractStorage_model(address, exponent) -> (weight: felt) {
}

@storage_var
func ContractStorage_test_data_commit(address: felt) -> (commit: felt) {
}

@storage_var
func ContractStorage_test_data_len() -> (len: felt) {
}
@storage_var
func ContractStorage_test_data(i: felt) -> (data: DataTypes.DataPoint) {
}
// @storage_var
// func ContractStorage_test_data_Y(i: felt) -> (y: felt) {
// }

@storage_var
func ContractStorage_competitors_count() -> (count: felt) {
}

@storage_var
func ContractStorage_competitors_list(competitor_id: felt) -> (address: felt) {
}




namespace ContractStorage {
    //
    // Reads
    //

    func model_commit_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (model_commit: felt) {
        let (model_commit) = ContractStorage_model_commit.read(address);
        return (model_commit=model_commit);
    }

    func model_len_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (model_len: felt) {
        let (model_len) = ContractStorage_model_len.read(address);
        return model_len;
    }

    func model_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, exponent: felt
    ) -> (weight: felt) {
        let (weight) = ContractStorage_model.read(address, exponent);
        return weight;
    }


    func test_data_commit_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (commit: felt) {
        let (test_data_commit) = ContractStorage_test_data_commit.read(address);
        return (commit=test_data_commit);
    }

    func test_data_len_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
         len: felt
    ){
        let (len) = ContractStorage_test_data_len.read();
        return(len=len);
    }

    func test_data_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        i: felt
    ) -> (data: DataTypes.DataPoint) {
        let (data) = ContractStorage_test_data.read(i);

        return (data=data);
    }

    func competitors_count_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        count: felt
    ){
        let (count) = ContractStorage_competitors_count.read();
        return (count=count);
    }

    func competitors_list_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        competitor_id: felt
    ) -> (competitor: felt){
        let (competitor) = ContractStorage_competitors_list.read(competitor_id);
        return (competitor=competitor);
    }


    //
    // Writes
    //

    func model_commit_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, model_commit: felt
    ) {
        ContractStorage_model_commit.write(address, model_commit);
        return();
    }


    func model_len_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, model_len: felt
    ) {
        ContractStorage_model_len.write(address, model_len);
        return();
    }

    func model_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, exponent: felt, weight: felt
    ) {
        ContractStorage_model.write(address, exponent, weight);
        return();
    }

    func test_data_commit_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, test_data_commit: felt
    ) {
        ContractStorage_test_data_commit.write(address, test_data_commit);
        return();
    }

    func test_data_len_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        test_data_len: felt
    ) {
        ContractStorage_test_data_len.write(test_data_len);
        return();
    }

    func test_data_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        i: felt, x: felt, y: felt
    ) {
        // ContractStorage_x.write(i,x);
        // ContractStorage_y.write(i,y);
        ContractStorage_test_data.write(i, DataTypes.DataPoint(x,y));
        return();
    }

    func competitors_count_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        count: felt
    ) {
        ContractStorage_competitors_count.write(count);
        return();
    }

    func competitors_list_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        competitor_id: felt, address: felt
    ) {
        ContractStorage_competitors_list.write(competitor_id, address);
    }
}
