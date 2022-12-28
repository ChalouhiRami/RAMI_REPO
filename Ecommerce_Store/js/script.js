
//pour faire un slideshow au debut 

var i=0;
var images= [];
images[0]='./Images/1.jpeg'
images[1]='./Images/2.jpg'

images[2]='./Images/3.jpg'
images[3]='./Images/5.jpeg'
window.onload = function() {
  Slideshow();
}
function Slideshow() {
  document.show.src = images[i];

  if (i <= images.length - 1) {
    i++;
  } else {
    document.show.src = images[0];
    i = 0;
    //pour que le slideshow redemmar 
  }

  setTimeout(Slideshow, 1000);
}

function contact() {
     var name = document.getElementById('name').value;
    var email = document.getElementById('email').value;
    var message = document.getElementById('message').value;
  
    // ne laisse pas valider tant que tout le forme est rempli 
    if (name == "" || email == "" || message == "") {
      alert("Please fill all the required fields in the form.");
      return;
    }
  
     alert("Message well recieved. Thank YOU!");
  }

 
  function buyItem(id) {
    if (confirm('Are you sure you want to buy this item?')) {
      alert('Thank you for your purchase. Hope to see you again!');
    }
  }



  