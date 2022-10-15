# ML model on StarkNet

- Current status

  - The model: 1 variable linear regression model is solved with results are basically 2 numbers: `intercept_` and `coef_`

  Data and Ml workflow are in `ml_workflow`

  - Publising the model: those 2 numbers are pushed publicly

  - Prediction: call prediction function with input

  - [Contract on Voyager](https://goerli.voyager.online/contract/0x04621fb6734846b7451d4238d80beaa599caa330cd995b91509c3fc657ca9cfa)


- Next steps

  - *Hide* the input

  - Standardization of ML models e.g. ONNX 


# Publishing machine learning models on StarkNet with commit-reveal scheme

## The usecase
- A machine learning model that need to be developed with data publicly available
- Anyone can publish their model 
  - They will not reveal it in submission period
  - They will eventually need to reveal the actual model

## The first example and solution

### Machine learning model
- For the first version, it's a simple 1 feature linear regression model represented by 2 values: `intercept_` and `coef_`
- An example of such model is in the [notebook](https://github.com/trangnv/linear-regression-starknet/blob/main/ml_workflow/simple_linear_regression.ipynb)

### Commit-reveal scheme with `keccak_hash`
Everything on the blockchain is public which is can be a problem for the usecase. But it can be partly solved with commit-reveal scheme. 

A commitment scheme is a cryptographic primitive that allows one to commit to a chosen value (or chosen statement) while keeping it hidden to others, with the ability to reveal the committed value later - [wikipedia](https://en.wikipedia.org/wiki/Commitment_scheme)

### Solution
- User can submit the hash value of the model which is calculated by keccak_hash function with 2 inputs are `intercept_` and `coef_` by calling `commit_hash` method
  - The `view_get_keccak_hash` method is the helper function, user should never use it to generate hash value
  - Instead helper function `utils.py` can be used offline to generate hash value from array of input
- User after that can reveal the actual model by calling `reveal`

## Next steps
- 
  



