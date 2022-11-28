"""contract.cairo test file."""
import os

import pytest
from starkware.starknet.testing.starknet import Starknet

from scripts.utils import (
    pedersen_hash_chain,
    # merkle,
    # get_merkle_root,
    generate_merkle_root,
    generate_merkle_proof,
)


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


# @pytest.mark.asyncio
# async def test_reveal_test_data():
#     """Test reveal_test_data method."""
#     # Create a new Starknet class that simulates the StarkNet
#     # system.
#     starknet = await Starknet.empty()

#     # Deploy the contract.
#     contract = await starknet.deploy(
#         source=CONTRACT_FILE,
#     )

#     X = [1, 2, 3, 4, 5]
#     Y = [4, 5, 6, 7, 8]

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
