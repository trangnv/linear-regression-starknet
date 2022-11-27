from starkware.crypto.signature.signature import pedersen_hash


def pedersen_hash_chain(*elements: int):
    cal_pedersen_hash = pedersen_hash(elements[0], elements[1])
    if len(elements) == 2:
        return cal_pedersen_hash
    for element in elements[2:]:
        cal_pedersen_hash = pedersen_hash(cal_pedersen_hash, element)
    return cal_pedersen_hash
