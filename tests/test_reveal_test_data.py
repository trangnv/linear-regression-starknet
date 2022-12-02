"""contract.cairo test file."""
import os
from dataclasses import dataclass
from scripts.utils import (
    pedersen_hash_chain,
    # merkle,
    # get_merkle_root,
    generate_merkle_root,
    generate_merkle_proof,
)
import pytest
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

CONTRACT_FILE = os.path.join("contracts", "contract.cairo")
from nile.signer import Signer, from_call_to_call_array


@pytest.fixture(scope="module")
def contract_classes():
    account_cls = Account.get_class
    erc20_cls = get_contract_class("contract")

    return account_cls, erc20_cls


PRIVATE_KEY = 12345678987654321

signer = MockSigner(123456789987654321)
# SIGNER = Signer(PRIVATE_KEY)


@pytest.fixture
def contract_factory(contract_classes, erc20_init):
    account_cls, erc20_cls = contract_classes
    state, account1, account2, erc20 = erc20_init
    _state = state.copy()
    account1 = cached_contract(_state, account_cls, account1)
    account2 = cached_contract(_state, account_cls, account2)
    erc20 = cached_contract(_state, erc20_cls, erc20)

    return erc20, account1, account2


from starkware.starknet.services.api.contract_class import ContractClass


def get_account_definition():
    with open("artifacts/Account.json", "r") as fp:
        return ContractClass.loads(fp.read())


@pytest.mark.asyncio
async def test_reveal_test_data():
    """Test reveal_test_data method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    # _, owner_account, signer_account = await contract_factory
    # erc20, account, _ = contract_factory
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    account = await starknet.deploy(
        contract_class=get_account_definition(),
        constructor_calldata=[signer.public_key],
    )

    X = [1, 2, 3, 4, 5]
    Y = [4, 5, 6, 7, 8]

    root = generate_merkle_root(X + Y)
    await signer.send_transaction(
        account, contract.contract_address, "commit_merkle_root_test_data", [root]
    )
