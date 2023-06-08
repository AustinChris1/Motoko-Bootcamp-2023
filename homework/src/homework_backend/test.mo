import Time "mo:base/Time";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";

actor {
  public type Time = Int;

  type Homework = {
    title : Text;
    description : Text;
    dueDate : Time;
    completed : Bool;
  };

  let homeworkDiary = Buffer.Buffer<Homework>(10);

  //Add a new homework task
  public func addHomeWork(homework : Homework) : async Nat {
    homeworkDiary.add(homework);
    return homeworkDiary.size();
  };

  //get homework
  public query func getHomework(id : Nat) : async Homework {
    return homeworkDiary.get(id);
  };

  //update homework
  public func updateHomework(id: Nat, homework: Homework) : async (){
    homeworkDiary.put(id, homework);
  };

  //update markascompleted
public func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
        let result : ?Homework = homeworkDiary.getOpt(id);

        switch (result) {
            case (null) { #err("Invalid index.") };
            case (?record) {
                var newRecord : Homework = {
                    title = record.title;
                    description = record.description;
                    dueDate = record.dueDate;
                    completed = true;
                };

                homeworkDiary.put(id, newRecord);
                #ok() 
            };
        };
    };
    }