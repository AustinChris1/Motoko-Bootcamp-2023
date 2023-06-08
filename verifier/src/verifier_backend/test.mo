import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Result "mo:base/Result";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Order "mo:base/Order";
import Array "mo:base/Array";
import Debug "mo:base/Debug";

actor Students{

  public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
  };

  var studentProfileStore = HashMap.HashMap<Principal, StudentProfile>(0, Principal.equal, Principal.hash);
  stable var preserveStudentProfile : [(Principal, StudentProfile)] = [];

  system func preupgrade(){
    preserveStudentProfile := Iter.toArray(studentProfileStore.entries());
  };

  system func postupgrade(){
    for((caller, profile) in preserveStudentProfile.vals()){
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

  public shared query func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let profileSize = studentProfileStore.size();
    switch (studentProfileStore.get(p)) {
      case (?profile) {
        return #ok(profile);
      };
      case (null) {
        return #err("No profile");
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
        return #err("Profile not found for the caller..");
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
  public shared ({caller}) func deleteMyProfile() : async Result.Result<(), Text> {
    let existingProfile = studentProfileStore.get(caller);
    if (existingProfile != null) {
      studentProfileStore.delete(caller);
      return #ok();
    } else {
      return #err("Profile not found for the caller.");

    };
  };

};
