from starkware.starknet.services.api.contract_class import ContractClass


def cal_yhat(x, model: list):
    yhat = 0
    for exponent, weight in enumerate(model):
        yhat += weight * x**exponent
    return yhat


def get_account_definition():
    with open("artifacts/Account.json", "r") as fp:
        return ContractClass.loads(fp.read())
