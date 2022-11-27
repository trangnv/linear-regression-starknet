import time


def run(nre):
    address, abi = nre.deploy("contract", alias="my_contract")
    print("deployed at", address)

    wait = 1  # seconds
    print(f"Waiting {wait} seconds for it to get confirmed")
    time.sleep(wait)

    # hash_ = nre.call("view_pedersen_hash", [2, 3])[0]
    # print(hash_)
    # print("token name:", felt_to_str(name))


# Auxiliary functions


def str_to_felt(text):

    b_text = bytes(text, "ascii")

    return int.from_bytes(b_text, "big")


def uint(a):

    return (a, 0)
