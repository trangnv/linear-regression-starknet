import os
import pytest

from starkware.starknet.testing.starknet import Starknet

from tests.helpers import cal_yhat, get_account_definition
from scripts.utils import merkle_root, pedersen_hash_chain
from scripts.signers import MockSigner

from scripts.utils import Account, get_contract_class


CONTRACT_FILE = os.path.join("contracts/competition", "polynomial_lr.cairo")
DEPLOYER_PRIVATE_KEY1 = 12345678987654321
DEPLOYER_PRIVATE_KEY2 = 1234567898765

signer1 = MockSigner(DEPLOYER_PRIVATE_KEY1)
signer2 = MockSigner(DEPLOYER_PRIVATE_KEY2)


@pytest.fixture
async def contract_factory():
    starknet = await Starknet.empty()
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    account = await starknet.deploy(
        contract_class=get_account_definition(),
        constructor_calldata=[signer1.public_key],
    )
    return contract, account


@pytest.fixture(scope="module")
def contract_classes():
    # account_cls = Account.get_class
    polynomial_lr_cls = get_contract_class("polynomial_lr")

    return polynomial_lr_cls


@pytest.mark.asyncio
async def test_reveal_test_data(contract_factory):
    """Test reveal_test_data method."""
    # contract, account = await contract_factory
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

    # reveal test data unsuccessully
    # expect revert
    await signer1.send_transaction(
        account1,
        contract.contract_address,
        "reveal_test_data",
        [len(X), *X, len(Y), *Y],
    )
    # fast forward

    # assertion
    # view test data len
    execution_info = await contract.view_test_data_len().call()
    assert execution_info.result.len == len(
        X
    ), "Something is wrong with length of test dataset"
    # view test data
    for i in range(len(X)):
        execution_info = await contract.view_test_data(i).call()
        assert (
            execution_info.result.data.x == X[i]
        ), "Something is wrong with test data storage_var"
        assert (
            execution_info.result.data.y == Y[i]
        ), "Something is wrong with test data storage_var"

    # reveal fake data failed


@pytest.mark.asyncio
async def test_reveal_model(contract_factory):
    """Test reveal_test_data method."""
    contract, account = await contract_factory
    model = [0, 1, 2, 3, 4, 5]

    hashed_model = pedersen_hash_chain(*model)

    # competitor commit model
    await signer.send_transaction(
        account, contract.contract_address, "commit_model", [hashed_model]
    )
    # check storage successful
    execution_info = await contract.view_model_commit(account.contract_address).call()
    assert execution_info.result.commit == hashed_model

    # check reveal
    await signer.send_transaction(
        account,
        contract.contract_address,
        "reveal_model",
        [len(model), *model],
    )
    # check model weight storage
    execution_info = await contract.view_model_len(account.contract_address).call()
    assert execution_info.result.len == len(
        model
    ), "Something is wrong with length of model"
    for i in range(len(model)):
        execution_info = await contract.view_model(account.contract_address, i).call()
        assert (
            execution_info.result.weight == model[i]
        ), "Something is wrong with model storage_var"


@pytest.mark.asyncio
async def test_cal_yhat(contract_factory):
    """Test reveal_test_data method."""
    contract, account = await contract_factory

    # commit test data
    X = [1, 2, 3]
    Y = [2, 3, 4]

    rootx = merkle_root(X)
    rooty = merkle_root(Y)
    root = merkle_root([rootx, rooty])

    await signer.send_transaction(
        account, contract.contract_address, "commit_test_data", [root]
    )
    # commit model
    model = [1, 2]  # [1] doesnot work
    hashed_model = pedersen_hash_chain(*model)
    # competitor commit model
    await signer.send_transaction(
        account, contract.contract_address, "commit_model", [hashed_model]
    )
    # reveal model
    await signer.send_transaction(
        account,
        contract.contract_address,
        "reveal_model",
        [len(model), *model],
    )
    # reveal test data
    await signer.send_transaction(
        account,
        contract.contract_address,
        "reveal_test_data",
        [len(X), *X, len(Y), *Y],
    )

    # check model weight storage
    execution_info = await contract.view_model_len(account.contract_address).call()
    assert execution_info.result.len == len(
        model
    ), "Something is wrong with length of model"
    for i in range(len(model)):
        execution_info = await contract.view_model(account.contract_address, i).call()
        assert (
            execution_info.result.weight == model[i]
        ), "Something is wrong with model storage_var"

    # check competitor_id
    execution_info = await contract.view_competitor(0).call()
    assert execution_info.result.competitor == account.contract_address

    #

    # test calculate yhat
    for i in range(len(X)):
        execution_info = await contract.cal_yhat(0, i).call()
        yhat = cal_yhat(X[i], model)
        assert execution_info.result.yhat == yhat
