from starkware.crypto.signature.signature import pedersen_hash
from math import log2


def pedersen_hash_chain(*elements: int):
    cal_pedersen_hash = pedersen_hash(elements[0], elements[1])
    if len(elements) == 2:
        return cal_pedersen_hash
    for element in elements[2:]:
        cal_pedersen_hash = pedersen_hash(cal_pedersen_hash, element)
    return cal_pedersen_hash


# import hashlib

# # Hash pairs of items recursively until a single value is obtained
# def merkle(hashList):
#     if len(hashList) == 1:
#         return hashList[0]
#     newHashList = []
#     # Process pairs. For odd length, the last is skipped
#     for i in range(0, len(hashList) - 1, 2):
#         newHashList.append(hash2(hashList[i], hashList[i + 1]))
#     if len(hashList) % 2 == 1:  # odd, hash last item twice
#         newHashList.append(hash2(hashList[-1], hashList[-1]))
#     return merkle(newHashList)


# def hash2(a, b):
#     # Reverse inputs before and after hashing
#     # due to big-endian / little-endian nonsense
#     a = hex(a)
#     b = hex(b)
#     a1 = a.decode("hex")[::-1]
#     b1 = b.decode("hex")[::-1]
#     h = hashlib.sha256(hashlib.sha256(a1 + b1).digest()).digest()
#     return h[::-1].encode("hex")


# def get_merkle_root(values):
#     extended_length = 2 ** log2(len(values))
#     tree = (
#         [None] * extended_length
#         + values
#         + [b"\x00" * 32] * (extended_length - len(values))
#     )
#     for i in range(extended_length - 1, 0, -1):
#         tree[i] = hash(tree[i * 2] + tree[i * 2 + 1])
#     return tree[1]


from starkware.crypto.signature.fast_pedersen_hash import pedersen_hash

import logging
import string

from starkware.crypto.signature.signature import pedersen_hash

# from constants import N_COLS
N_COLS = 15

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


def number_to_index(n):
    row = n // N_COLS
    col = n % N_COLS
    return string.ascii_uppercase[col] + str(row + 1)


def hash2(x, y):
    return pedersen_hash(x, y) if x <= y else pedersen_hash(y, x)


def merkle_root(leafs):
    if len(leafs) == 1:
        return leafs[0]
    if len(leafs) % 2 == 1:
        leafs.append(leafs[-1])
    return merkle_root([hash2(x, y) for x, y in zip(leafs[::2], leafs[1::2])])


def address_to_leaf(address):
    return hash2(address, address)


def merkle_proof(address, addresses):
    """
    Returns the merkle proof for the given address belonging to the given list of addresses.
    """
    if address not in addresses:
        raise ValueError("Address not in addresses")
    leafs = [address_to_leaf(address) for address in addresses]
    if len(leafs) % 2 == 1:
        leafs.append(leafs[-1])
    index = addresses.index(address)
    proof = [leafs[(index + 1) if (index % 2 == 0) else (index - 1)]]

    while len(leafs) > 1:
        leafs = [hash2(x, y) for x, y in zip(leafs[::2], leafs[1::2])]
        if len(leafs) == 1:
            break
        if len(leafs) % 2 == 1:
            leafs.append(leafs[-1])
        index = index // 2
        proof.append(leafs[(index + 1) if (index % 2 == 0) else (index - 1)])

    return proof


def merkle_proofs(addresses):
    return {address: merkle_proof(address, addresses) for address in addresses}


def merkle_verify(leaf, root, proof):
    """
    Verifies the given merkle proof for the given address.
    """
    if len(proof) == 0:
        return leaf == root
    return merkle_verify(hash2(proof[0], leaf), root, proof[1:])


"""Utilities for testing Cairo contracts."""

from starkware.cairo.common.hash_state import compute_hash_on_elements
from starkware.crypto.signature.signature import private_to_stark_key, sign
from starkware.starknet.definitions.error_codes import StarknetErrorCode
from starkware.starkware_utils.error_handling import StarkException
from starkware.starknet.public.abi import get_selector_from_name

MAX_UINT256 = (2**128 - 1, 2**128 - 1)


def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")


def felt_to_str(felt):
    b_felt = felt.to_bytes(31, "big")
    return b_felt.decode()


def uint(a):
    return (a, 0)


def to_uint(a):
    """Takes in value, returns uint256-ish tuple."""
    return (a & ((1 << 128) - 1), a >> 128)


def from_uint(uint):
    """Takes in uint256-ish tuple, returns value."""
    return uint[0] + (uint[1] << 128)


def add_uint(a, b):
    """Returns the sum of two uint256-ish tuples."""
    a = from_uint(a)
    b = from_uint(b)
    c = a + b
    return to_uint(c)


def sub_uint(a, b):
    """Returns the difference of two uint256-ish tuples."""
    a = from_uint(a)
    b = from_uint(b)
    c = a - b
    return to_uint(c)


async def assert_revert(fun):
    try:
        await fun
        assert False
    except StarkException as err:
        _, error = err.args
        assert error["code"] == StarknetErrorCode.TRANSACTION_FAILED


class Signer:
    """
    Utility for sending signed transactions to an Account on Starknet.

    Parameters
    ----------

    private_key : int

    Examples
    ---------
    Constructing a Singer object

    >>> signer = Signer(1234)

    Sending a transaction

    >>> await signer.send_transaction(account,
                                      account.contract_address,
                                      'set_public_key',
                                      [other.public_key]
                                     )

    """

    def __init__(self, private_key):
        self.private_key = private_key
        self.public_key = private_to_stark_key(private_key)

    def sign(self, message_hash):
        return sign(msg_hash=message_hash, priv_key=self.private_key)

    async def send_transaction(self, account, to, selector_name, calldata, nonce=None):
        if nonce is None:
            execution_info = await account.get_nonce().call()
            (nonce,) = execution_info.result

        selector = get_selector_from_name(selector_name)
        message_hash = hash_message(
            account.contract_address, to, selector, calldata, nonce
        )
        sig_r, sig_s = self.sign(message_hash)

        return await account.execute(to, selector, calldata, nonce).invoke(
            signature=[sig_r, sig_s]
        )


def hash_message(sender, to, selector, calldata, nonce):
    message = [sender, to, selector, compute_hash_on_elements(calldata), nonce]
    return compute_hash_on_elements(message)


"""Utilities for testing Cairo contracts."""

import os
from pathlib import Path
from starkware.starknet.public.abi import get_selector_from_name
from starkware.starknet.business_logic.execution.objects import OrderedEvent
from starkware.starknet.compiler.compile import compile_starknet_files
from starkware.starknet.testing.starknet import StarknetContract
from starkware.starknet.testing.starknet import Starknet


MAX_UINT256 = (2**128 - 1, 2**128 - 1)
INVALID_UINT256 = (MAX_UINT256[0] + 1, MAX_UINT256[1])
ZERO_ADDRESS = 0
TRUE = 1
FALSE = 0
IACCOUNT_ID = 0xA66BD575

_root = Path(__file__).parent.parent


def get_cairo_path():
    CAIRO_PATH = os.getenv("CAIRO_PATH")
    cairo_path = []

    if CAIRO_PATH is not None:
        cairo_path = [p for p in CAIRO_PATH.split(":")]

    return cairo_path


def contract_path(name):
    if name.startswith("tests/"):
        return str(_root / name)
    else:
        return str(_root / "src" / name)


def assert_event_emitted(tx_exec_info, from_address, name, data, order=0):
    """Assert one single event is fired with correct data."""
    assert_events_emitted(tx_exec_info, [(order, from_address, name, data)])


def assert_events_emitted(tx_exec_info, events):
    """Assert events are fired with correct data."""
    for event in events:
        order, from_address, name, data = event
        event_obj = OrderedEvent(
            order=order,
            keys=[get_selector_from_name(name)],
            data=data,
        )

        base = tx_exec_info.call_info.internal_calls[0]
        if event_obj in base.events and from_address == base.contract_address:
            return

        try:
            base2 = base.internal_calls[0]
            if event_obj in base2.events and from_address == base2.contract_address:
                return
        except IndexError:
            pass

        raise BaseException("Event not fired or not fired correctly")


def _get_path_from_name(name):
    """Return the contract path by contract name."""
    dirs = ["src", "tests/mocks", "contracts/mocks"]
    for dir in dirs:
        for (dirpath, _, filenames) in os.walk(dir):
            for file in filenames:
                if file == f"{name}.cairo":
                    return os.path.join(dirpath, file)

    raise FileNotFoundError(f"Cannot find '{name}'.")


def get_contract_class(contract, is_path=False):
    """Return the contract class from the contract name or path"""
    if is_path:
        path = contract_path(contract)
    else:
        path = _get_path_from_name(contract)

    contract_class = compile_starknet_files(
        files=[path], debug_info=True, cairo_path=get_cairo_path()
    )
    return contract_class


def cached_contract(state, _class, deployed):
    """Return the cached contract"""
    contract = StarknetContract(
        state=state,
        abi=_class.abi,
        contract_address=deployed.contract_address,
        deploy_call_info=deployed.deploy_call_info,
    )
    return contract


class State:
    """
    Utility helper for Account class to initialize and return StarkNet state.

    Example
    ---------
    Initalize StarkNet state

    >>> starknet = await State.init()

    """

    async def init():
        global starknet
        starknet = await Starknet.empty()
        return starknet


class Account:
    """
    Utility for deploying Account contract.

    Parameters
    ----------

    public_key : int

    Examples
    ----------

    >>> starknet = await State.init()
    >>> account = await Account.deploy(public_key)

    """

    get_class = get_contract_class("Account")

    async def deploy(public_key):
        account = await starknet.deploy(
            contract_class=Account.get_class, constructor_calldata=[public_key]
        )
        return account
