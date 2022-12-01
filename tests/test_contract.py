"""contract.cairo test file."""
import os
from dataclasses import dataclass
import asyncio


from typing import Tuple
from starkware.starknet.testing.starknet import Starknet, StarknetContract
from starkware.starkware_utils.error_handling import StarkException

import pytest
from starkware.starknet.testing.starknet import Starknet

# from tests.utils import Signer
from nile.signer import Signer, from_call_to_call_array
from nile.common import TRANSACTION_VERSION


from nile.utils.get_accounts import get_accounts, get_predeployed_accounts
from nile.core.account import Account
from starkware.starknet.services.api.contract_class import ContractClass
from starkware.starknet.business_logic.transaction.objects import InternalTransaction
from starkware.starknet.services.api.gateway.transaction import InvokeFunction


def get_raw_invoke(sender, calls):
    """Construct and return StarkNet's internal raw_invocation."""
    call_array, calldata = from_call_to_call_array(calls)
    raw_invocation = sender.__execute__(call_array, calldata)
    return raw_invocation


PRIVATE_KEY = 12345678987654321
SIGNER = Signer(PRIVATE_KEY)


# def get_or_deploy_account(self, signer, watch_mode=None):
#     """Get or deploy an Account contract."""
#     return Account(signer=signer, network=self.network, watch_mode=watch_mode)

# Account()
# @dataclass
# class Account:
#     signer: Signer
#     contract: StarknetContract


from scripts.utils import (
    pedersen_hash_chain,
    # merkle,
    # get_merkle_root,
    generate_merkle_root,
    generate_merkle_proof,
)


# @pytest.fixture(scope="module")
# def event_loop():
#     return asyncio.new_event_loop()


# @pytest.fixture(scope="module")
# async def contract_factory() -> Tuple[Starknet, Account, Account, StarknetContract]:
#     starknet = await Starknet.empty()
#     some_signer = Signer(private_key=12345)
#     owner_account = Account(
#         signer=some_signer,
#         contract=await starknet.deploy(
#             "contracts/Account.cairo", constructor_calldata=[some_signer.public_key]
#         ),
#     )
#     some_other_signer = Signer(private_key=123456789)
#     signer_account = Account(
#         signer=some_other_signer,
#         contract=await starknet.deploy(
#             "contracts/Account.cairo",
#             constructor_calldata=[some_other_signer.public_key],
#         ),
#     )
#     contract = await starknet.deploy("contracts/contract.cairo")
#     return starknet, owner_account, signer_account, contract


# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "contract.cairo")


@pytest.mark.asyncio
async def test_pedersen_hash_chain():
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    hashing_array = [3, 2, 1, 0, 4]

    # get result from contract
    execution_info = await contract.view_pedersen_hash_chain(hashing_array).call()

    # get result from script
    cal_pedersen_hash = pedersen_hash_chain(*hashing_array)

    # assertion
    assert (
        execution_info.result.hashed_value == cal_pedersen_hash
    ), "Something is wrong with pedersen hash chain"


@pytest.mark.asyncio
async def test_merkle_root():
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    hashing_array = [1, 2, 3, 4]  # first element is lenght

    # get result from contract
    execution_info = await contract.view_merkle_root(hashing_array).call()

    # get result from script
    root = generate_merkle_root(hashing_array)

    # assertion
    assert (
        execution_info.result.res == root
    ), "Something is wrong with merkle root calculation"


def get_account_definition():
    with open("artifacts/Account.json", "r") as fp:
        return ContractClass.loads(fp.read())


from starkware.starknet.public.abi import get_selector_from_name

from starkware.cairo.common.hash_state import compute_hash_on_elements


def hash_message(sender, to, selector, calldata, nonce):
    message = [sender, to, selector, compute_hash_on_elements(calldata), nonce]
    return compute_hash_on_elements(message)


async def send_transaction(self, account, to, selector_name, calldata, nonce=None):
    if nonce is None:
        execution_info = await account.get_nonce().call()
        (nonce,) = execution_info.result

    selector = get_selector_from_name(selector_name)
    message_hash = hash_message(account.contract_address, to, selector, calldata, nonce)
    sig_r, sig_s = self.sign(message_hash)

    return await account.execute(to, selector, calldata, nonce).invoke(
        signature=[sig_r, sig_s]
    )


# async def send_transaction(
#     signer, account, to, selector_name, calldata, nonce=None, max_fee=0
# ):
#     return await send_transactions(
#         signer, account, [(to, selector_name, calldata)], nonce, max_fee
#     )


# async def send_transactions(signer, account, calls, nonce=None, max_fee=0):
#     # hexify address before passing to from_call_to_call_array
#     raw_invocation = get_raw_invoke(account, calls)
#     state = raw_invocation.state

#     if nonce is None:
#         nonce = await state.state.get_nonce_at(account.contract_address)

#     # get signature
#     calldata, sig_r, sig_s = signer.sign_invoke(
#         account.contract_address, calls, nonce, max_fee, TRANSACTION_VERSION
#     )

#     # craft invoke and execute tx
#     external_tx = InvokeFunction(
#         contract_address=account.contract_address,
#         calldata=calldata,
#         entry_point_selector=None,
#         signature=[sig_r, sig_s],
#         max_fee=max_fee,
#         version=TRANSACTION_VERSION,
#         nonce=nonce,
#     )

#     tx = InternalTransaction.from_external(
#         external_tx=external_tx, general_config=state.general_config
#     )
#     execution_info = await state.execute_tx(tx=tx)
#     return execution_info


@pytest.mark.asyncio
async def test_reveal_test_data():
    """Test reveal_test_data method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    # _, owner_account, signer_account = await contract_factory
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    account = await starknet.deploy(
        contract_class=get_account_definition(),
        constructor_calldata=[SIGNER.public_key],
    )
    # starknet = await Starknet.empty()

    # # Deploy the contract.
    # contract = await starknet.deploy(
    #     source=CONTRACT_FILE,
    # )

    # accountA = get_accounts("A")
    # accountA = get_or_deploy_account("ACCOUNT_A")

    X = [1, 2, 3, 4, 5]
    Y = [4, 5, 6, 7, 8]

    root = generate_merkle_root(X + Y)

    # await account.send_transaction(
    #     account=account.contract,
    #     to=contract.contract_address,
    #     selector_name="commit_merkle_root_test_data",
    #     calldata=[root],
    # )
    # Single tx
    nonce = await starknet.state.state.get_nonce_at(account.contract_address)
    await send_transaction(
        SIGNER,
        account,
        contract.contract_address,
        "commit_merkle_root_test_data",
        [root],
        nonce,
    )


#     # execute reveal_test_data
#     await contract.reveal_test_data(X, Y).execute()

#     # Check the result of test_data with view functions
#     execution_info = await contract.view_test_data_len().call()
#     print(execution_info.result)

#     for i in range(5):
#         execution_info = await contract.view_test_data(i).call()
#         print(execution_info.result)


# @pytest.mark.asyncio
# async def test_reveal_model():
#     """Test reveal_model method"""
#     # Create a new Starknet class that simulates the StarkNet
#     # system.
#     starknet = await Starknet.empty()

#     # Deploy the contract.
#     contract = await starknet.deploy(
#         source=CONTRACT_FILE,
#     )

#     model = []
#     # hash it with script
#     model_hash = model
#     # commit model_hash
#     await contract.commit_model_hash(model_hash).execute

#     # execute reveal model
#     await contract.reveal_model(model)

#     # asserttion
