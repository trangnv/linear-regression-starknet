# Linear regression machine learning competition on StarkNet
First daap for implementation of Private Model, Public Input data science competitions
For ideas, thesis discussion please haed over to [Notion page](https://snml.notion.site/First-implementation-Private-Model-Public-Input-c556d39ee0b24268a8f2bdb845077d4f)

## The usecase
- Model: linear regressions
- Dataset 'uploading'
  - Training + validation dataset
  - Testing dataset
- Model submission process: use commit-reveal scheme
  - Commit hash value of the model during submission period
  - Reveal real model when submission period end


## Iterations
- [First iteration: one feature linear regression model](#first)
- [Second iteration: Multiple linear regression](#second)


## [First iteration](https://github.com/trangnv/linear-regression-starknet/tree/simple-linear-regression) <a name="first"></a>

### Machine learning model
- For the first version, it's a simple 1 feature linear regression model represented by 2 values: `intercept_` and `coef_`
- An example of such model is in the [notebook](https://github.com/trangnv/linear-regression-starknet/blob/main/ml_workflow/simple_linear_regression.ipynb)

### Commit-reveal scheme with `keccak_hash`
Everything on the blockchain is public which is can be a problem for the usecase. But it can be partly solved with commit-reveal scheme. 

A commitment scheme is a cryptographic primitive that allows one to commit to a chosen value (or chosen statement) while keeping it hidden to others, with the ability to reveal the committed value later - [wikipedia](https://en.wikipedia.org/wiki/Commitment_scheme)

### Solution
- User submit the hash value of the model which is calculated by keccak_hash function with 2 inputs are `intercept_` and `coef_` by calling `commit_hash` method
  - The `view_get_keccak_hash` method is the helper function, user should never use it to generate hash value
  - Instead helper function `utils.py` can be used offline to generate hash value from array of input
- User after that can reveal the actual model by calling `reveal` and the model is public onchain

- **[Contract on Voyager](https://goerli.voyager.online/contract/0x02f11c9d3bf19226233c44ec919a337dd70837699b3e94fb326a5a89e763f628)**


## Second iteration: multiple linear regression model <a name="second"></a>
### Machine learning model
- Arbitrary number of features
- Example [notebook](https://github.com/trangnv/linear-regression-starknet/blob/multiple-linear-regression/ml_workflow/multiple_linear_regression.ipynb)

### Commit-reveal scheme with Pedersen hash
- Use `pedersen_hash_chain` which can hash arbitrary size of inputs x_0, x_1, ..., x_n: H(H(...H(H(x_0, x_1), x_2), ...,x_{n-1}), x_n)

### Contract
- Deploy: `nile deploy contract $N` <br>
Where `N` is number of features
- **[Example contract on Voyager](https://goerli.voyager.online/contract/0x04aab0c376c49d4862697cd9b96715a4d07caaa07d950eb36c98a240df00e716)**
  - Number of features: 3
  - User can 
    - Call view function `pedersen_hash_submission` with arguments are model coeffients and intercept
    - `commit_hash` 
    - `reveal` solution


## References
- [starknet-commit-reveal](https://github.com/gaetbout/starknet-commit-reveal) by gaetbout

  



