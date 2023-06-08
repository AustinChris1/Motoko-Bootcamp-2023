import { createActor, student_wall_backend } from "../../declarations/student_wall_backend";
import { AuthClient } from "@dfinity/auth-client"
import { HttpAgent } from "@dfinity/agent";

let actor = student_wall_backend;

const greetButton = document.getElementById("greet");
greetButton.onclick = async (e) => {
  e.preventDefault();

  greetButton.setAttribute("disabled", true);

  // Interact with backend actor, calling the greet method
  const greeting = await actor.greet();

  greetButton.removeAttribute("disabled");
  swal("Your Principal ID is", greeting);
  // document.getElementById("greeting").innerText = greeting;

  return false;
};

const loginButton = document.getElementById("login");
loginButton.onclick = async (e) => {
  e.preventDefault();

  // create an auth client
  let authClient = await AuthClient.create();

  // start the login process and wait for it to finish
  await new Promise((resolve) => {
    authClient.login({
      identityProvider: process.env.II_URL,
      onSuccess: resolve,
    });
  });

  // At this point we're authenticated, and we can get the identity from the auth client:
  const identity = authClient.getIdentity();
  // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
  const agent = new HttpAgent({ identity });
  // Using the interface description of our webapp, we create an actor that we use to call the service methods.
  actor = createActor(process.env.STUDENT_WALL_BACKEND_CANISTER_ID, {
    agent,
  });

  return false;
};


// main deal
window.addEventListener("load", async function () {
  show();

});

async function show() {
  const response = await actor.getAllMessagesRanked();
  console.log(response);

  const tableBody = document.querySelector('#output');

  response.forEach((obj, index) => {
    const row = document.createElement('tr');

    const indexCell = document.createElement('td');
    indexCell.innerText = index;
    row.appendChild(indexCell);

    const contentCell = document.createElement('td');
    contentCell.innerText = JSON.stringify(obj.content.Text, null, 2);
    row.appendChild(contentCell);

    const creatorCell = document.createElement('td');
    creatorCell.innerText = obj.creator;
    row.appendChild(creatorCell);

    const voteCell = document.createElement('td');
    voteCell.innerText = obj.vote.toString();
    row.appendChild(voteCell);


    // create a new cell element for the upvote button
    const ubuttonCell = document.createElement("td");
    const upVoteButton = document.createElement("button");
    upVoteButton.classList.add("btn", "btn-success", `upVote-${index}`);
    upVoteButton.innerHTML = "&#43;";
    ubuttonCell.appendChild(upVoteButton);
    row.appendChild(ubuttonCell);

    // create a new cell element for the downvote button
    const dbuttonCell = document.createElement("td");
    const downVoteButton = document.createElement("button");
    downVoteButton.classList.add("btn", "btn-danger", `downVote-${index}`);
    downVoteButton.innerHTML = " &#8722 ";
    dbuttonCell.appendChild(downVoteButton);
    row.appendChild(dbuttonCell);


    // Event listener for upvote button
    upVoteButton.addEventListener("click", async () => {
      await upVote(index);
    });

    // Event listener for downvote button
    downVoteButton.addEventListener("click", async () => {
      await downVote(index);
    });

    // create a new cell element for the upvote button
    const vbuttonCell = document.createElement("td");
    const viewButton = document.createElement("button");
    viewButton.classList.add("btn", "btn-secondary", `view-${index}`);
    viewButton.innerHTML = "View";
    vbuttonCell.appendChild(viewButton);
    row.appendChild(vbuttonCell);

    viewButton.addEventListener("click", function() {
      swal({
        title: "Feature is coming soon!",
        text: "",
        icon: "warning",
      });
    });
    // create a new cell element for the upvote button
    const delbuttonCell = document.createElement("td");
    const delButton = document.createElement("button");
    delButton.classList.add("btn", "btn-danger", `delete-${index}`);
    delButton.innerHTML = " &times; ";
    delbuttonCell.appendChild(delButton);
    row.appendChild(delbuttonCell);

    // Event listener for delete button
    delButton.addEventListener("click", async () => {
      await deleteMessage(index);
    });


    tableBody.appendChild(row);



  });

  
  // const votes = await actor.getAllMessages();

}

  async function upVote(index) {
    const response = await actor.upVote(index);
    console.log(response);
  }
  
  async function downVote(index) {
    const response = await actor.downVote(index);
    console.log(response);
  }

  async function getVotes(index) {
    const response = await actor.getVoters(index);
    console.log(response);
  }
  async function deleteMessage(index) {
    const response = await actor.deleteMessage(index);
    console.log(response);
  }

//write message
document.querySelector("#writeForm").addEventListener("submit", async function(event){
  event.preventDefault();

  const btn = event.target.querySelector("#submit-btn");

  const inputText = document.getElementById("formText").value;


  if (document.getElementById("formText").value.length != 0){
      btn.setAttribute("disabled", true);
      await actor.writeMessage({Text:inputText, Image:inputText, Video:inputText});
      document.getElementById("formText").value = "";
  }
  // await dbank_backend.compound();

  show();
  btn.removeAttribute("disabled");

});
//update message
document.querySelector("#updateForm").addEventListener("submit", async function(event){
  event.preventDefault();

  const btn = event.target.querySelector("#update-btn");

  const id = document.getElementById("updateVal").value;
  const inputText = document.getElementById("updateText").value;


  if (document.getElementById("updateText").value.length != 0){
      btn.setAttribute("disabled", true);
      await actor.updateMessage({tag: id, value: inputText});
      document.getElementById("updateText").value = "";
  }
  // await dbank_backend.compound();

  show();
  btn.removeAttribute("disabled");

});
