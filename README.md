
# Instructions
Run the sql code in donator.sql to your database.

Follow the Tebex instructions to get Tebex installed on your server.
In your Tebex store on the packages you want coins to be added to do the following.
At the bottom of the package select "Add Game Server Command"
In the "When the package is purchased" section paste the following
```
donatorPurchase {"transactionId":"{transaction}", "package":"{packageName}"}
```

IMPORTANT
The packagename in the config needs to MACTH the package name in tebex.
So if you have a package named "coinpack1" in tebex then you need to have
```
    ["coinpack1"] = CoinAmountHere,
```
in the config.

Players can use the /redeem transactionId in game to have their coins added.