import os
import pytest

from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.services.api.contract_class import ContractClass
from scripts.utils import merkle_root, pedersen_hash_chain

from scripts.utils import Account, get_contract_class
from scripts.signers import MockSigner

CONTRACT_FILE = os.path.join("contracts/competition", "polynomial_lr.cairo")
PRIVATE_KEY = 12345678987654321
signer = MockSigner(PRIVATE_KEY)


@pytest.fixture(scope="module")
def contract_classes():
    account_cls = Account.get_class
    erc20_cls = get_contract_class("contract")
    return account_cls, erc20_cls


@pytest.fixture
async def contract_factory():
    starknet = await Starknet.empty()
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )
    account = await starknet.deploy(
        contract_class=get_account_definition(),
        constructor_calldata=[signer.public_key],
    )
    return contract, account


def get_account_definition():
    with open("artifacts/Account.json", "r") as fp:
        return ContractClass.loads(fp.read())


@pytest.mark.asyncio
async def test_reveal_test_data(contract_factory):
    """Test reveal_test_data method."""
    contract, account = await contract_factory
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

    # reveal test data successully
    await signer.send_transaction(
        account,
        contract.contract_address,
        "reveal_test_data",
        [len(X), *X, len(Y), *Y],
    )
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


def cal_yhat(x, model: list):
    yhat = 0
    for exponent, weight in enumerate(model):
        yhat += weight * x**exponent
    return yhat
