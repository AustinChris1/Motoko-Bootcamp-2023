import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import IC "ic";
import Error "mo:base/Error";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Homework "homework";

actor {

    public type TestResult = Result.Result<(), TestError>;
    public type TestError = {
        #UnexpectedValue : Text;
        #UnexpectedError : Text;
    };

    public type Homework = {
        title : Text;
        completed : Bool;
        dueDate : Time;
        description : Text;
    };

    public type StudentProfile = {
        name : Text;
        team : Text;
        graduate : Bool;
    };

    var studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);
    stable var preserveStudentProfile : [(Principal, StudentProfile)] = [];

    system func preupgrade() {
        preserveStudentProfile := Iter.toArray(studentProfileStore.entries());
    };

    system func postupgrade() {
        for ((caller, profile) in preserveStudentProfile.vals()) {
            studentProfileStore.put(caller, profile);
        };
    };

    // Add a new student
    public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        let existingProfile = studentProfileStore.get(caller);
        if (existingProfile != null) {
            return #err("Profile already exists for the caller.");
        } else {
            let sProfile : StudentProfile = {
                name = profile.name;
                team = profile.team;
                graduate = false;
            };
            let studentPrincipal : Principal = caller;
            studentProfileStore.put(studentPrincipal, sProfile);
            return #ok();
        };
    };

    //See student Profile

    public shared query ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
        let profileSize = studentProfileStore.size();
        switch (studentProfileStore.get(p)) {
            case (?profile) {
                return #ok(profile);
            };
            case (null) {
                return #err("No profile for " # Principal.toText(caller));
            };
        };
    };

    // Update student profile
    public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        if (studentProfileStore.size() < 1) {
            return #err("Invalid student " # Principal.toText(caller));
        } else {
            let existingProfile = studentProfileStore.get(caller);
            if (existingProfile == null) {
                return #err("Profile (" # Principal.toText(caller) # ") not found for the caller..");
            } else {
                let updatedProfile : StudentProfile = {
                    name = profile.name;
                    team = profile.team;
                    graduate = profile.graduate;
                };
                let res = studentProfileStore.put(caller, updatedProfile);
                return #ok();
            };
        };
    };

    //deleteMyProfile
    public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
        let existingProfile = studentProfileStore.get(caller);
        if (existingProfile != null) {
            studentProfileStore.delete(caller);
            return #ok();
        } else {
            return #err("Profile not found for the caller(" # Principal.toText(caller) # ").");

        };
    };

    // Part 2
    public shared func test(canisterId : Principal) : async TestResult {

        let calculatorCanister : actor {
            add : shared (Int) -> async Int;
            sub : shared (Nat) -> async Int;
            reset : shared () -> async Int;
        } = actor (Principal.toText(canisterId));

        //calling the canister
        try {
            //reset test
            let resetTest = await calculatorCanister.reset();
            if (resetTest != 0) {
                return (#err(#UnexpectedValue("Expected 0, got " # Int.toText(resetTest) # " for reset")));
            };
            //add test
            let addTest = await calculatorCanister.add(1);
            if (addTest != 1) {
                return (#err(#UnexpectedValue("Expected 0, got " # Int.toText(addTest) # " for add")));
            };
            //sub test
            let subTest = await calculatorCanister.sub(1);
            if (subTest != 0) {
                return (#err(#UnexpectedValue("Expected 0, got " # Int.toText(subTest) # " for sub")));
            };
            return #ok();

        } catch (e) {
            return (#err(#UnexpectedError("Something went wrong when calling the calculator canister: " # Error.message(e))));
        };

    };

    //calling the homework canister
    public shared func homeworkTest(canisterId : Principal) : async TestResult {

        let homeworkCanister : actor {
            addHomework : shared (Homework) -> async Nat;
            deleteHomework : shared (Nat) -> async Result;
            getAllHomework : shared query () -> async [Homework];
            getHomework : shared query (Nat) -> async Result_1;
            getPendingHomework : shared query () -> async [Homework];
            markAsCompleted : shared (Nat) -> async Result;
            searchHomework : shared query (Text) -> async [Homework];
            updateHomework : shared (Nat, Homework) -> async Result;
        } = actor (Principal.toText(canisterId));

        try{
            //add Homework
            let testAddHomework = await homeworkCanister.addHomework(Homework);
            if (testAddHomework : Nat){
                return #ok();
            }else{
                return (#err(#UnexpectedError("Expected Nat when adding homework")));
            }

        }catch(e){

        };
    };
    // Part 3
    private func _parseControllersFromCanisterStatusErrorIfCallerNotController(message : Text) : [Principal] {
        let lines = Iter.toArray(Text.split(message, #text("\n")));
        let words = Iter.toArray(Text.split(lines[1], #text(" ")));
        var i = 2;
        let controllers = Buffer.Buffer<Principal>(0);
        while (i < words.size()) {
            controllers.add(Principal.fromText(words[i]));
            i += 1;
        };
        Buffer.toArray<Principal>(controllers);

    };
    // Verify Ownership
    public shared func verifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
        let managementCanister : IC.ManagementCanister = actor ("aaaaa-aa");

        try {
            // let called = actor (Principal.toText(canisterId)) : ManagementCanister;
            let result = await managementCanister.canister_status({
                canister_id = canisterId;
            });
            let controllers = result.settings.controllers;
            for (p in controllers.vals()) {
                if (p == principalId) {
                    return true;
                };
            };
            return false;

        } catch (e) {
            let message : Text = Error.message(e);
            let controllers = _parseControllersFromCanisterStatusErrorIfCallerNotController(message);

            for (p in controllers.vals()) {
                if (p == principalId) {
                    return true;
                };
            };
            return false;
        };

    };

    // Part 4
    // Verifywork
    public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
        let isOwner = await verifyOwnership(canisterId, p);
        if (not isOwner) {
            return #err("The caller is not the owner of the canister");

        };
        let result = await test(canisterId);
        switch (result) {
            case (#err(_)) {
                return #err("The canister does not pass the tests");

            };
            case (#ok()) {
                switch (studentProfileStore.get(p)) {
                    case (null) {
                        return #err("Profile not found");
                    };
                    case (?profile) {
                        let newProfile = {
                            name = profile.name;
                            team = profile.team;
                            graduate = true;
                        };
                        studentProfileStore.put(p, newProfile);
                        return #ok();
                    };
                };
            };
        };
    };

};
