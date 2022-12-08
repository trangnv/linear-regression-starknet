import os
import pytest

from starkware.starknet.testing.starknet import Starknet
from nile.utils import assert_revert

from tests.helpers import cal_yhat, get_account_definition, update_starknet_block
from scripts.utils import merkle_root, pedersen_hash_chain
from scripts.signers import MockSigner

from scripts.utils import Account, get_contract_class

CONTRACT_FILE = os.path.join("contracts/competition", "polynomial_lr.cairo")
DEPLOYER_PRIVATE_KEY1 = 12345678987654321
DEPLOYER_PRIVATE_KEY2 = 1234567898765

signer1 = MockSigner(DEPLOYER_PRIVATE_KEY1)
signer2 = MockSigner(DEPLOYER_PRIVATE_KEY2)
STAGE1_END_TIME = 10000


@pytest.fixture
async def contract_factory():
    starknet = await Starknet.empty()
    account1 = await starknet.deploy(
        contract_class=get_account_definition(),
        constructor_calldata=[signer1.public_key],
    )
    account2 = await starknet.deploy(
        contract_class=get_account_definition(),
        constructor_calldata=[signer2.public_key],
    )
    contract = await starknet.deploy(
        source=CONTRACT_FILE, constructor_calldata=[account1.contract_address]
    )
    return starknet, contract, account1, account2


@pytest.mark.asyncio
async def test_reveal_test_data(contract_factory):
    """Test reveal_test_data method."""
    starknet, contract, account1, account2 = await contract_factory

    X = [1, 2, 3]
    Y = [2, 3, 4]

    rootx = merkle_root(X)
    rooty = merkle_root(Y)
    root = merkle_root([rootx, rooty])

    await signer1.send_transaction(
        account1, contract.contract_address, "commit_test_data", [root]
    )

    # check test data commit
    execution_info = await contract.view_test_data_commit(
        account1.contract_address
    ).call()
    assert (
        root == execution_info.result.commit
    ), "Something is wrong with commit merkle root of test data"

    # view block_info
    assert starknet.state.state.block_info.block_timestamp == 0
    # assert revert
    await assert_revert(
        signer1.send_transaction(
            account1,
            contract.contract_address,
            "reveal_test_data",
            [len(X), *X, len(Y), *Y],
        )
    )

    # fast forward update block_info
    block_timestamp = STAGE1_END_TIME + 1
    update_starknet_block(starknet, block_number=1, block_timestamp=block_timestamp)
    assert starknet.state.state.block_info.block_timestamp == block_timestamp

    # reveal fake data failed
    X_f = [3, 5, 7, 9, 0]
    Y_f = [3, 5, 6, 7, 8]
    await assert_revert(
        signer1.send_transaction(
            account1,
            contract.contract_address,
            "reveal_test_data",
            [len(X_f), *X_f, len(Y_f), *Y_f],
        )
    )

    await signer1.send_transaction(
        account1,
        contract.contract_address,
        "reveal_test_data",
        [len(X), *X, len(Y), *Y],
    )

    # # assertion
    # test data len
    execution_info = await contract.view_test_data_len().call()
    assert execution_info.result.len == len(
        X
    ), "Something is wrong with length of test dataset"

    # test data
    for i in range(len(X)):
        execution_info = await contract.view_test_data(i).call()
        assert (
            execution_info.result.data.x == X[i]
        ), "Something is wrong with test data storage_var"
        assert (
            execution_info.result.data.y == Y[i]
        ), "Something is wrong with test data storage_var"


@pytest.mark.asyncio
async def test_reveal_model(contract_factory):
    """Test reveal_test_data method."""
    starknet, contract, account1, account2 = await contract_factory

    X = [1, 2, 3]
    Y = [2, 3, 4]

    rootx = merkle_root(X)
    rooty = merkle_root(Y)
    root = merkle_root([rootx, rooty])

    # check stage
    execution_info = await contract.view_stage().call()
    # print(execution_info.result.stage)
    assert execution_info.result.stage == 0

    # account1 commit test data
    await signer1.send_transaction(
        account1, contract.contract_address, "commit_test_data", [root]
    )
    # check stage
    execution_info = await contract.view_stage().call()
    assert execution_info.result.stage == 1

    model = [0, 1, 2, 3, 4, 5]
    hashed_model = pedersen_hash_chain(*model)

    # account2 (competitor) commit model
    await signer2.send_transaction(
        account2, contract.contract_address, "commit_model", [hashed_model]
    )
    # check storage successful
    execution_info = await contract.view_model_commit(account2.contract_address).call()
    assert execution_info.result.commit == hashed_model

    # check reveal revert
    await assert_revert(
        signer2.send_transaction(
            account2,
            contract.contract_address,
            "reveal_model",
            [len(model), *model],
        )
    )

    # # fast forward update block_info
    block_timestamp = STAGE1_END_TIME + 1
    update_starknet_block(starknet, block_number=1, block_timestamp=block_timestamp)
    assert starknet.state.state.block_info.block_timestamp == block_timestamp

    # check stage
    execution_info = await contract.view_stage().call()
    assert execution_info.result.stage == 1

    # check commit model revert
    await assert_revert(
        signer2.send_transaction(
            account2, contract.contract_address, "commit_model", [hashed_model]
        )
    )

    # check reveal model revert
    await assert_revert(
        signer2.send_transaction(
            account2,
            contract.contract_address,
            "reveal_model",
            [len(model), *model],
        )
    )

    # account1 reveal test data
    await signer1.send_transaction(
        account1,
        contract.contract_address,
        "reveal_test_data",
        [len(X), *X, len(Y), *Y],
    )
    # check stage
    execution_info = await contract.view_stage().call()
    assert execution_info.result.stage == 2

    # account2 reveal model
    await signer2.send_transaction(
        account2,
        contract.contract_address,
        "reveal_model",
        [len(model), *model],
    )

    # check model weight storage
    execution_info = await contract.view_model_len(account2.contract_address).call()
    assert execution_info.result.len == len(
        model
    ), "Something is wrong with length of model"
    for i in range(len(model)):
        execution_info = await contract.view_model(account2.contract_address, i).call()
        assert (
            execution_info.result.weight == model[i]
        ), "Something is wrong with model storage_var"


@pytest.mark.asyncio
async def test_cal_yhat(contract_factory):
    """Test reveal_test_data method."""
    starknet, contract, account1, account2 = await contract_factory

    X = [1, 2, 3]
    Y = [2, 3, 4]

    rootx = merkle_root(X)
    rooty = merkle_root(Y)
    root = merkle_root([rootx, rooty])

    # check stage
    execution_info = await contract.view_stage().call()
    # print(execution_info.result.stage)
    assert execution_info.result.stage == 0

    # account1 commit test data
    await signer1.send_transaction(
        account1, contract.contract_address, "commit_test_data", [root]
    )
    # check stage
    execution_info = await contract.view_stage().call()
    assert execution_info.result.stage == 1

    model = [0, 1, 2, 3, 4, 5]
    hashed_model = pedersen_hash_chain(*model)

    # account2 (competitor) commit model
    await signer2.send_transaction(
        account2, contract.contract_address, "commit_model", [hashed_model]
    )
    # check storage successful
    execution_info = await contract.view_model_commit(account2.contract_address).call()
    assert execution_info.result.commit == hashed_model

    # check reveal revert
    await assert_revert(
        signer2.send_transaction(
            account2,
            contract.contract_address,
            "reveal_model",
            [len(model), *model],
        )
    )

    # # fast forward update block_info
    block_timestamp = STAGE1_END_TIME + 1
    update_starknet_block(starknet, block_number=1, block_timestamp=block_timestamp)
    assert starknet.state.state.block_info.block_timestamp == block_timestamp

    # check stage
    execution_info = await contract.view_stage().call()
    assert execution_info.result.stage == 1

    # check commit model revert
    await assert_revert(
        signer2.send_transaction(
            account2, contract.contract_address, "commit_model", [hashed_model]
        )
    )

    # check reveal model revert
    await assert_revert(
        signer2.send_transaction(
            account2,
            contract.contract_address,
            "reveal_model",
            [len(model), *model],
        )
    )

    # account1 reveal test data
    await signer1.send_transaction(
        account1,
        contract.contract_address,
        "reveal_test_data",
        [len(X), *X, len(Y), *Y],
    )
    # check stage
    execution_info = await contract.view_stage().call()
    assert execution_info.result.stage == 2

    # account2 reveal model
    await signer2.send_transaction(
        account2,
        contract.contract_address,
        "reveal_model",
        [len(model), *model],
    )

    # check model weight storage
    execution_info = await contract.view_model_len(account2.contract_address).call()
    assert execution_info.result.len == len(
        model
    ), "Something is wrong with length of model"
    for i in range(len(model)):
        execution_info = await contract.view_model(account2.contract_address, i).call()
        assert (
            execution_info.result.weight == model[i]
        ), "Something is wrong with model storage_var"
    # check competitor_id
    execution_info = await contract.view_competitor(0).call()
    assert execution_info.result.competitor == account2.contract_address

    # test calculate yhat
    for i in range(len(X)):
        execution_info = await contract.cal_yhat(0, i).call()
        yhat = cal_yhat(X[i], model)
        assert execution_info.result.yhat == yhat
