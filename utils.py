from typing import List
from eth_hash.auto import keccak
import binascii
from starkware.python.utils import to_bytes

def keccak_ints(values: List[int]) -> str:
    """
    Computes the keccak of a list of ints.
    This function is compatible with
      Web3.solidityKeccak(['uint256[]'], [values]).hex()
    """
    return "0x" + binascii.hexlify(keccak(b"".join(to_bytes(value) for value in values))).decode(
        "ascii"
    )