# NFTransport

NFTransport

## Inspiration
NFTransport aim at making easy, transparent, and secure the exchange of nft with physical value associated. More and more of NFT collection propose or want to propose physical perks, but it's often hard for them. They sometimes even do it manually. Also, some markets like the sneakers one are often subject to scalper the get several shoes delivered to them with the sole purpose of selling them for profit. At least with NFTransport, it will avoid the ecological impact of several deliveries !

## What it does
For instance with a sneaker collection, buyer can decide to sell their nft before redeeming the physical shoes. At the same time, the buyers in second market can know for sure if the physical is still redeemable, without the nft needed to get burned.

## How we built it
We built it at first on polygon, aiming at offering low fees later on on main-net. But we got reliant on the opensea API which didn't allowed us to take full advantages of the mumbai testnet, so we went ahead on Rinkeby. We use our own system of dynamic NFT with a new array of string, serving as storage for the ipfs link to the (encripted) delivery informations. Later on a system of escrow could even be put in place, with those onchain proofs.

## Challenges we ran into
One of our goal was to send a confirmation email for the shipping of the sneaker.
We needed a web server to handle GET/POST requests to receive an url sent by the smart contract (json file containing the contact details of the customer).
Then parse the json to send an email to the customer to confirm the shipping.
We tried using AWS Lambda but we were not really familiar with it and didn't manage to make anything work. Then we decided to create our own http server in python to handler requests.

## Accomplishments that we're proud of
We're proud of delivering a first version that can be tested, and we already have a lot of ideas for future improvements !

## What we learned
We learned to not underestimate our weaknesses, as the frontend and the server communication from chainlink back to the blockchain gave us a lot of tough times.

## What's next for NFTransport
We aim at making our system more secure, reliable, and mostly easier to use (for devs and users) through a nice frontend gallery made for it 


## Develop

```bash
yarn start
```

## Test

```bash
yarn test
```

## Build

```bash
yarn build
```

# License

MIT
