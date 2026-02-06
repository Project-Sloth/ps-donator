# Archiving Older Repos (Focus on ps-mdt v3)

To help streamline things a bit around here (for the little work we actually do 😅), I’m going to be archiving the repos listed below. This doesn’t mean they’re broken or unusable, it just means we won’t be pushing any further updates to them for now.

Our main focus moving forward will be ps-mdt v3 and its dependencies.

![image](https://user-images.githubusercontent.com/82112471/195740699-7fe040c6-bd35-4376-85c0-b045aa8ff4e4.png)

# Requirements
[ox_inventory](https://github.com/overextended/ox_inventory)
[ox_lib](https://github.com/overextended/ox_lib)
[oxmysql](https://github.com/overextended/oxmysql)

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
