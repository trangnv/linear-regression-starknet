%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func ContractStorage_submission_hash(address: felt) -> (submission_hash: felt) {
}

@storage_var
func ContractStorage_submission(address: felt) -> (submission: felt) {
}

