from starkware.starknet.services.api.contract_class import ContractClass
from starkware.starknet.business_logic.state.state_api_objects import BlockInfo
from starkware.cairo.lang.version import __version__ as STARKNET_VERSION
from starkware.starknet.definitions.general_config import (
    DEFAULT_GAS_PRICE,
    DEFAULT_SEQUENCER_ADDRESS,
)


def cal_yhat(x, model: list):
    yhat = 0
    for exponent, weight in enumerate(model):
        yhat += weight * x**exponent
    return yhat


def get_account_definition():
    with open("artifacts/Account.json", "r") as fp:
        return ContractClass.loads(fp.read())


def update_starknet_block(starknet, block_number, block_timestamp):
    starknet.state.state.block_info = BlockInfo(
        block_number=block_number,
        block_timestamp=block_timestamp,
        gas_price=DEFAULT_GAS_PRICE,
        sequencer_address=DEFAULT_SEQUENCER_ADDRESS,
        starknet_version=STARKNET_VERSION,
    )
