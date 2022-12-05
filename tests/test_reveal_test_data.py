"""contract.cairo test file."""
import os

# from dataclasses import dataclass
import pytest

from scripts.utils import merkle_root

from tests.utils import (
    assert_events_emitted,
    assert_event_emitted,
    State,
    Account,
    get_contract_class,
    cached_contract,
)
from tests.signers import MockSigner
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.services.api.contract_class import ContractClass

CONTRACT_FILE = os.path.join("contracts", "contract.cairo")
PRIVATE_KEY = 12345678987654321
signer = MockSigner(PRIVATE_KEY)


@pytest.fixture(scope="module")
def contract_classes():
    account_cls = Account.get_class
    erc20_cls = get_contract_class("contract")

    return account_cls, erc20_cls


@pytest.fixture
def contract_factory(contract_classes, erc20_init):
    account_cls, erc20_cls = contract_classes
    state, account1, account2, erc20 = erc20_init
    _state = state.copy()
    account1 = cached_contract(_state, account_cls, account1)
    account2 = cached_contract(_state, account_cls, account2)
    erc20 = cached_contract(_state, erc20_cls, erc20)

    return erc20, account1, account2


def get_account_definition():
    with open("artifacts/Account.json", "r") as fp:
        return ContractClass.loads(fp.read())


@pytest.mark.asyncio
async def test_reveal_test_data():
    """Test reveal_test_data method."""
    starknet = await Starknet.empty()

    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    account = await starknet.deploy(
        contract_class=get_account_definition(),
        constructor_calldata=[signer.public_key],
    )

    X = [1, 2, 3]
    Y = [2, 3, 4]

    rootx = merkle_root(X)
    rooty = merkle_root(Y)
    root = merkle_root([rootx, rooty])

    await signer.send_transaction(
        account, contract.contract_address, "commit_test_data", [root]
    )

    # check test data commit
    execution_info = await contract.view_test_data_commit(
        account.contract_address
    ).call()
    assert (
        root == execution_info.result.commit
    ), "Something is wrong with commit merkle root of test data"
    # print(f"caller {account.contract_address} commit: {execution_info.result.commit}")

    # reveal test data successully
    await signer.send_transaction(
        account,
        contract.contract_address,
        "reveal_test_data",
        [len(X), *X, len(Y), *Y],
    )
