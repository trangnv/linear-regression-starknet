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
