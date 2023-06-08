import Account "account";
import TrieMap "mo:base/TrieMap";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Result "mo:base/Result"; 
import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import Option "mo:base/Option";

actor MotoCoin{

    type Account = Account.Account;
    var ledger = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);
    var supply : Nat = 0;

    //name
    public func name() : async Text{
        return "MotoCoin";
    };

    public func symbol() : async Text{
        return "MOC";
    };

    //totalSupply
    public func totalSupply() : async Nat{
        // var bal : Nat = 0;
        for((key, value) in ledger.entries()){
            supply += value;
        };
        return supply;
    };

    //balance
    public func balanceOf(account : Account): async Nat{ 
        let bal : ?Nat = ledger.get(account);
        switch bal{
            case (null) return 0;
            case (?bal)  return bal;
        };
    };

    //transfer
    public shared ({caller}) func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(),Text>{
        let balFrom = await balanceOf(from);
        if (balFrom < amount) return #err("Insufficient Funds");
        let balTo = await balanceOf(to);
        ledger.put(from, balFrom - amount);
        ledger.put(to, balTo + amount);
        return #ok();
    };

    //airdrop
    public func airdrop() : async Result.Result<(), Text>{
        let Bcanister = actor("rww3b-zqaaa-aaaam-abioa-cai") : actor{
            getAllStudentsPrincipal : shared () -> async [Principal];
        };
        let students = await Bcanister.getAllStudentsPrincipal();
        for(p in students.vals()){
            let account : Account = {
                owner = p;
                subaccount = null;
            };
            let currentValue = Option.get(ledger.get(account), 0);
            let newValue = currentValue + 100;
            ledger.put(account, newValue);
        };
        return #ok();
    };

};