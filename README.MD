# POC machine learning competition on StarkNet
First daap for implementation of Private Model, Public Input data science competitions

[Kanban board tasks](https://github.com/users/trangnv/projects/2)

[Notion page](https://snml.notion.site/First-implementation-Private-Model-Public-Input-c556d39ee0b24268a8f2bdb845077d4f)


## Data competition flow

### Stage 0
*Organizer*
- Puts training data publicly offchain (GDrive, IPFS, ...)
- Initiates the competition by deploying the contract
- Prepares test data offchain (need to be defined before the competition begins, but not viewable, otherwise participants would overfit it)
- Calculates merkle root of test data
- Commits testing data with that merkle root

Client can use [this](https://github.com/trangnv/starknet-notebook/blob/main/linear-regression-notebooks/organizer.ipynb) Jupyter notebook to deploy/interact with the contracts


### Stage 1
This phase last 1 week from the moment *organizer* commited test data <br> 
*Competitors*
- Use training data to train model
- Calculate hash of the model
- Commit model with that hash

Client can use [this](https://github.com/trangnv/starknet-notebook/blob/main/linear-regression-notebooks/competitor.ipynb) Jupyter notebook to calculate hash, commit model to the contract. Interacting with contract by Jupyter notebook makes the it seamlessly integrated to machine learning workflow.

### Stage 2
Starts when phase 1 finished <br>
The Jupyter notebooks mentioned above also support these functions invocation

*Competitors*
- Reveal model

*Organizer*
- Reveal testing data


### Stage 3
Now all submission models and testing data are available onchain
*Anyone* can call evaluation function calculate all competitors evaluation metrics and rank them.

## Contract on StarkScan



