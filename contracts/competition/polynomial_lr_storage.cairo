%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.libraries.data_types import DataTypes

@storage_var
func PolyLinearRegressionStorage_model_commit(address: felt) -> (commit: felt) {
}

@storage_var
func PolyLinearRegressionStorage_model_len(address: felt) -> (len: felt) {
}

@storage_var
func PolyLinearRegressionStorage_model(address, exponent) -> (weight: felt) {
}

@storage_var
func PolyLinearRegressionStorage_test_data_commit(address: felt) -> (commit: felt) {
}

@storage_var
func PolyLinearRegressionStorage_test_data_len() -> (len: felt) {
}
@storage_var
func PolyLinearRegressionStorage_test_data(i: felt) -> (data: DataTypes.DataPoint) {
}
// @storage_var
// func PolyLinearRegressionStorage_test_data_Y(i: felt) -> (y: felt) {
// }

@storage_var
func PolyLinearRegressionStorage_competitors_count() -> (count: felt) {
}

@storage_var
func PolyLinearRegressionStorage_competitors_list(competitor_id: felt) -> (address: felt) {
}

@storage_var
func PolyLinearRegressionStorage_stage() -> (stage: felt) {
}

@storage_var
func PolyLinearRegressionStorage_stage1_timestamp() -> (timestamp: felt) {
}

@storage_var
func PolyLinearRegressionStorage_max_error(address: felt) -> (max_error: felt) {
}







namespace PolyLinearRegressionStorage {
    //
    // Reads
    //

    func model_commit_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (model_commit: felt) {
        let (model_commit) = PolyLinearRegressionStorage_model_commit.read(address);
        return (model_commit=model_commit);
    }

    func model_len_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (model_len: felt) {
        let (model_len) = PolyLinearRegressionStorage_model_len.read(address);
        return (model_len=model_len);
    }

    func model_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, exponent: felt
    ) -> (weight: felt) {
        let (weight) = PolyLinearRegressionStorage_model.read(address, exponent);
        return (weight=weight);
    }


    func test_data_commit_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (commit: felt) {
        let (test_data_commit) = PolyLinearRegressionStorage_test_data_commit.read(address);
        return (commit=test_data_commit);
    }

    func test_data_len_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
         len: felt
    ){
        let (len) = PolyLinearRegressionStorage_test_data_len.read();
        return(len=len);
    }

    func test_data_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        i: felt
    ) -> (data: DataTypes.DataPoint) {
        let (data) = PolyLinearRegressionStorage_test_data.read(i);

        return (data=data);
    }

    func competitors_count_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        count: felt
    ){
        let (count) = PolyLinearRegressionStorage_competitors_count.read();
        return (count=count);
    }

    func competitors_list_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        competitor_id: felt
    ) -> (competitor: felt){
        let (competitor) = PolyLinearRegressionStorage_competitors_list.read(competitor_id);
        return (competitor=competitor);
    }

    func stage_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    ) -> (stage: felt){
        let (stage) = PolyLinearRegressionStorage_stage.read();
        return(stage=stage);
    }

    func stage1_timestamp_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        timestamp: felt
    ){
        let (timestamp) = PolyLinearRegressionStorage_stage1_timestamp.read();
        return(timestamp=timestamp);
    }

    func max_error_read{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (max_error: felt){
        let (max_error) = PolyLinearRegressionStorage_max_error.read(address);
        return(max_error=max_error);
    }


    //
    // Writes
    //

    func model_commit_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, model_commit: felt
    ) {
        PolyLinearRegressionStorage_model_commit.write(address, model_commit);
        return();
    }


    func model_len_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, model_len: felt
    ) {
        PolyLinearRegressionStorage_model_len.write(address, model_len);
        return();
    }

    func model_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, exponent: felt, weight: felt
    ) {
        PolyLinearRegressionStorage_model.write(address, exponent, weight);
        return();
    }

    func test_data_commit_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, test_data_commit: felt
    ) {
        PolyLinearRegressionStorage_test_data_commit.write(address, test_data_commit);
        return();
    }

    func test_data_len_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        test_data_len: felt
    ) {
        PolyLinearRegressionStorage_test_data_len.write(test_data_len);
        return();
    }

    func test_data_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        i: felt, x: felt, y: felt
    ) {
        PolyLinearRegressionStorage_test_data.write(i, DataTypes.DataPoint(x,y));
        return();
    }

    func competitors_count_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        count: felt
    ) {
        PolyLinearRegressionStorage_competitors_count.write(count);
        return();
    }

    func competitors_list_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        competitor_id: felt, address: felt
    ) {
        PolyLinearRegressionStorage_competitors_list.write(competitor_id, address);
        return();
    }

    func stage_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        stage: felt
    ) {
        PolyLinearRegressionStorage_stage.write(stage);
        return();
    }

    func stage1_timestamp_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        timestamp: felt
    ) {
        PolyLinearRegressionStorage_stage1_timestamp.write(timestamp);
        return();
    }

    func max_error_write{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, max_error: felt
    ) {
        PolyLinearRegressionStorage_max_error.write(address, max_error);
        return();
    }
}
