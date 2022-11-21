# Universidad de Oriente Token - UDOT

![Image text](https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Logo_UDO.svg/1200px-Logo_UDO.svg.png)

This project was created under the idea of designing a decentralized and autonomous payment system, with which it is sought to serve as an economic and financial refuge for the "Universidad de Oriente". The main mission of this project is to allow the university to manage its funds autonomously and in turn offer students more transparency and different payment methods.

## Token characteristics

- Maximum supplement: 1.000.000 UDOT
- Used network: Polygon
- Contract address: 0xEc969d8308F5a9BE1C473CCDE957f08aa48Cfc64

### Use cases
The UDOT token is an ERC20 utility token. This can can be used as a digital currency. The main real uses that it could have are:

- Create reserve of university funds
- Currency used to pay university expenses (registration fees, payment of taxes, etc.)
- Currency to create funds for rewards or incentives for professors and teachers of the university
- Currency to create funds for rewards or incentives for outstanding students within the university.

### Notes

- UDOT will be a token which is backed by the native currency of the Polygon network (MATIC).
- The relationship between UDOT and MATIC will be 1:1, this means that each time a UDOT is created it will be backed in an equivalent way by a MATIC.
- As the relationship between UDON and MATIC is 1:1, every time a UDOT is burned, it will return the equivalent value in MATIC to the user.

## Getting started

The first step is to clone this repository:
```
# Get the latest version of the project
git clone https://github.com/Ljrr3045/udo-erc20-token.git

# Change to home directory
cd udo-erc20-token
```

To install all package dependencies run:
```
# Install all dependencies
npm i
```

This will install all packages in the monorepo as well as all the packages.

## Technologies and protocols used

This project uses the following technologies and protocols:
* [Solidity](https://docs.soliditylang.org/en/v0.8.17/)
* [Hardhat](https://hardhat.org/docs)
* [OpenZeppelin](https://docs.openzeppelin.com/)
* [Polygon](https://bscscan.com/) 
* [SushiSwap](https://docs.sushi.com/)

## Documentation

The information on smart contracts can be found at the following link:
* [Documentation](https://github.com/Ljrr3045/udo-erc20-token/blob/master/docs/index.md)

## Useful commands

```
# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test (or npx hardhat coverage)

# Run deploy script
npm run contract:deploy

# Generate documentation
npx hardhat docgen
```
