import Time "mo:base/Time";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";

actor {
    public type Time = Int;

    public type Homework = {
        title : Text;
        description : Text;
        dueDate : Time;
        completed : Bool;
    };

    let homeworkDiary = Buffer.Buffer<Homework>(0);

    //Add a new homework task
    public shared func addHomework(homework : Homework) : async Nat {
        let index = homeworkDiary.size();
        homeworkDiary.add(homework);
        return index;
    };

    //get homework
    public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
        let size = homeworkDiary.size();
        if (id > size) {
            #err("homework is not exist");
        } else {
            let homework = homeworkDiary.get(id);
            #ok(homework);
        };

    };
    //update homework
    public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
        let size = homeworkDiary.size();
        if (id > size and id <= 0) {
            #err("ID not found");
        } else {
            homeworkDiary.put(id, homework);
            #ok();
        };

    };
    

//update markascompleted
public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
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
            #ok();
        };
    };
};
 // Delete a homework task by id
 public shared func deleteHomework(id : Nat) : async Result.Result<(), Text>{
        let size = homeworkDiary.size();
        if (id > size and id <= 0) {
            #err("ID not found");
        } else {
            let homework = homeworkDiary.remove(id);
            #ok();
        };

 };
  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework]{
    return Buffer.toArray(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework]{
    let pending = Buffer.clone(homeworkDiary);
    pending.filterEntries(func(_, x) = (x.completed == false));
    return Buffer.toArray(pending);
  };

   // Search for homework tasks based on a search terms
   public shared query func searchHomework(searchTerm : Text) : async [Homework]{
    let searched = Buffer.clone(homeworkDiary);
    searched.filterEntries(func(_, x) = (Text.contains(x.title, #text searchTerm) or Text.contains(x.description, #text searchTerm)));
    return Buffer.toArray(searched);
   };
};
