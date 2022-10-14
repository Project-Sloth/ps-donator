![image](https://user-images.githubusercontent.com/82112471/195740699-7fe040c6-bd35-4376-85c0-b045aa8ff4e4.png)

# Instructions
Run the sql code in donator.sql to your database.

Follow the Tebex instructions to get Tebex installed on your server.
In your Tebex store on the packages you want coins to be added to do the following.
At the bottom of the package select "Add Game Server Command"
![image](https://user-images.githubusercontent.com/7463741/193162239-df5c838a-63f4-4ac0-816f-0e783275026a.png)

In the "When the package is purchased" section paste the following
```
donatorPurchase {"transactionId":"{transaction}", "package":"{packageName}"}
```
![image](https://user-images.githubusercontent.com/7463741/193162202-93c9245d-c49e-4837-922c-53fe3a273c63.png)

IMPORTANT
The packagename in the config needs to MATCH the package name in tebex.
So if you have a package named "coinpack1" in tebex then you need to have in the config.
```
    ["coinpack1"] = CoinAmountHere,
```

Players can use the /redeem transactionId in game to have their coins added.
